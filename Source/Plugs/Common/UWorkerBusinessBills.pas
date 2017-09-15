{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessBills;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml, revicewstest, BPM2ERPService, HTTPApp,
  UWorkerBusiness;

type
  TStockMatchItem = record
    FStock: string;         //品种
    FGroup: string;         //分组
    FRecord: string;        //记录
  end;

  TBillLadingLine = record
    FBill: string;          //交货单
    FLine: string;          //装车线
    FName: string;          //线名称
    FPerW: Integer;         //袋重
    FTotal: Integer;        //总袋数
    FNormal: Integer;       //正常
    FBuCha: Integer;        //补差
    FHKBills: string;       //合卡单
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //散装多单
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //分组匹配
    FBillLines: array of TBillLadingLine;
    //装车线
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //物料分组
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    //
    function GetOnLineModel: string;
    //获取在线模式
    function LoadZhiKaInfo(const nZID: string; var nHint: string): TDataset;
    //载入纸卡
    function GetRemCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
    //在线远程获取客户信用和资金
    function GetRemTriCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
    //在线远程获取三角贸易客户信用和资金
    function SaveBills(var nData: string): Boolean;
    //保存交货单
    function DeleteBill(var nData: string): Boolean;
    //删除交货单
    function ChangeBillTruck(var nData: string): Boolean;
    //修改车牌号
    function BillSaleAdjust(var nData: string): Boolean;
    //销售调拨
    function SaveBillCard(var nData: string): Boolean;
    //绑定磁卡
    function LogoffCard(var nData: string): Boolean;
    //注销磁卡
    function GetPostBillItems(var nData: string): Boolean;
    //获取岗位交货单
    function SavePostBillItems(var nData: string): Boolean;
    //保存岗位交货单
    function DelBillSendMsgWx(LID:string):Boolean;
    //删单发送微信消息
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //验证车牌是否有效
  end;

implementation
uses
  UWorkerClientWebChat,UMgrQueue,UDataModule,UHardBusiness;

class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaleAdjust          : Result := BillSaleAdjust(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索nStock对应的物料分组
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索车辆队列中与nStock同品种,或同组的记录
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '有效的车牌号长度为3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('车牌号[ %s ]无效.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: 允许散装多单
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Lih  2016-09-01
//载入nZID的信息返回查询数据集
function TWorkerBusinessBills.LoadZhiKaInfo(const nZID: string; var nHint: string): TDataset;
var nStr: string;
begin
  nStr := 'Select zk.*,con.C_ContQuota,cus.C_Name,cus.C_PY,con.C_Area From $ZK zk ' +
          ' Left Join $Con con On con.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract),
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  Result := gDBConnManager.WorkerQuery(FDBConn, nStr);
end;

//Date: 2014-09-15
//Desc: 验证能否开单
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
    nDBZhiKa: TDataSet;
    nOut: TWorkerBusinessCommand;
    nHint: string;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  if Length(FListA.Values['LID']) > 8 then
  begin
    nStr := 'Select Count(*) From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FListA.Values['LID']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      nData := '单据号[ %s ]已存在,不能重复开单.';
      nData := Format(nData, [FListA.Values['LID']]);
      Exit;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  FSanMultiBill := AllowedSanMultiBill;
  //散装允许开多单

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select a.R_ID,a.T_Bill,a.T_StockNo,a.T_Type,'+
          'a.T_InFact,a.T_Valid,b.L_Status From %s a ' +
          'left join %s b on a.T_Bill = b.L_ID '+
          'Where a.T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, sTable_Bill, nTruck]);
  //还在队列中车辆

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) and
        (FieldByName('L_Status').AsString <> sFlag_TruckOut) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
        // (FieldByName('T_InFact').AsString <> '') and
         (FieldByName('L_Status').AsString <> sFlag_TruckOut) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; {else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '车辆[ %s ]有已出队的交货单[ %s ],需先处理.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; }

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select * From %s Where O_CType = ''G'' and O_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_Order, nTruck]);
  //车辆办理采购长期卡

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('O_Card').AsString <> '' then
    begin
      nStr := '车辆[ %s ]已经办理[ %s ]采购长期卡，请先到采购制卡处注销采购卡！.';
      nData := Format(nStr, [nTruck, FieldByName('O_StockName').AsString]);
      Exit;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  //----------------------------------------------------------------------------
  {nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$ZID', FListA.Values['ZhiKa'])]);  }
  nDBZhiKa:=LoadZhiKaInfo(FListA.Values['ZhiKa'], nHint);
  //纸卡信息
  with nDBZhiKa,FListA do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [Values['ZhiKa']]);
      Exit;
    end;

    nStr := FieldByName('Z_TJStatus').AsString;
    if nStr  <> '' then
    begin
      if nStr = sFlag_TJOver then
           nData := '纸卡[ %s ]已调价,请重新开单.'
      else nData := '纸卡[ %s ]正在调价,请稍后.';

      nData := Format(nData, [Values['ZhiKa']]);
      Exit;
    end;

    {if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [Values['ZhiKa'],
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;   }
    Values['TriaTrade'] := FieldByName('Z_TriangleTrade').AsString;  //1：是三角贸易 0：否
    if Values['TriaTrade']='1' then
    begin
      Values['CusID'] := FieldByName('Z_OrgAccountNum').AsString;
      Values['CusName'] := FieldByName('Z_OrgAccountName').AsString;
      Values['CusPY'] := '';
    end else
    begin
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
    end;

    Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    Values['CompanyId'] := FieldByName('Z_CompanyId').AsString;
    Values['ContQuota'] := FieldByName('C_ContQuota').AsString;

    Values['ContractID'] := FieldByName('Z_CID').AsString;
    Values['Area'] := FieldByName('Z_XSQYBM').AsString;
    Values['KHSBM'] := FieldByName('Z_KHSBM').AsString;

    Values['OrgXSQYMC'] := FieldByName('Z_OrgXSQYMC').AsString;
    if (Pos('湟中祁连山商砼',FieldByName('Z_Name').AsString)>0) then
      Values['IfNeiDao'] := 'Y'
    else
      Values['IfNeiDao'] := 'N';
  end;

  Result := True;
  //verify done
end;

//获取在线模式
function TWorkerBusinessBills.GetOnLineModel: string;
var
  nStr: string;
begin
  Result:=sFlag_Yes;
  nStr := 'select D_Value from %s where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_OnLineModel]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result:=Fields[0].AsString;
  end;
end;

//在线远程获取客户信用和资金
function TWorkerBusinessBills.GetRemCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
var
  nStr:string;
  nCusID,nZcid,nContQuota: string;
  nOut: TWorkerBusinessCommand;
  nDBZhiKa:TDataSet;
  nHint: string;
begin
  nRemMoney:= 0.00;

  nStr := 'Select zk.*,con.C_ContQuota From $ZK zk ' +
          ' Left Join $Con con On con.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), 
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  //纸卡信息
  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    nCusID := FieldByName('Z_Customer').AsString;
    nContQuota := FieldByName('C_ContQuota').AsString;
    nZcid:= FieldByName('Z_CID').AsString;
    if nContQuota='1' then
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_GetTprGemCont, nCusID+','+nZcid, gCompanyAct, @nOut) then
      begin
        nMsg := Format('在线获取[ %s ]合同信用额度信息失败,已终止.', [nCusID+','+nZcid]);
        Result := False;
        Exit;
      end;
      Result:=True;
      nRemMoney := StrToFloat(nOut.FExtParam);
      WriteLog('ZAX Money: '+nOut.FExtParam);
      
      if nOut.FData=sFlag_No then nMsg:='['+nCusID+']资金余额不足.';
    end else
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_GetTprGem, nCusID, gCompanyAct, @nOut) then
      begin
        nMsg := Format('在线获取[ %s ]客户信用额度信息失败,已终止.', [nCusID]);
        Result := False;
        Exit;
      end;
      Result:=True;
      nRemMoney := StrToFloat(nOut.FExtParam);
      WriteLog('ZAX Money: '+nOut.FExtParam);

      if nOut.FData=sFlag_No then nMsg:='['+nCusID+']资金余额不足.';
    end;
  end;
end;

//在线远程获取三角贸易客户信用和资金
function TWorkerBusinessBills.GetRemTriCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
var
  nStr:string;
  nOrgCusID,nOriSalesId,nCompanyId,nZcid,nContQuota: string;
  nOut: TWorkerBusinessCommand;
  nDBZhiKa:TDataSet;
  nHint: string;
begin
  nRemMoney:= 0.00;
  nStr := 'Select Z_CompanyId,Z_OrgAccountNum,Z_IntComOriSalesId From $ZK Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ID', nZID)]);
  //纸卡信息
  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nMsg := Format('[ %s ]销售订单不存在,已终止.', [nZID]);
      Result:=False;
      Exit;
    end;
    nOrgCusID := FieldByName('Z_OrgAccountNum').AsString;
    nOriSalesId := FieldByName('Z_IntComOriSalesId').AsString;
    nCompanyId := FieldByName('Z_CompanyId').AsString;
  end;
  
  if not TWorkerBusinessCommander.CallMe(cBC_GetAXContQuota, nOriSalesId, nCompanyId, @nOut) then
  begin
    nMsg := Format('三角贸易订单[ %s ]在线获取合同信息失败,已终止.', [nZID]);
    Result := False;
    Exit;
  end;
  nContQuota := nOut.FData;
  nZcid:= nOut.FExtParam;
  if nContQuota = sFlag_Yes then
  begin
    if not TWorkerBusinessCommander.CallMe(cBC_GetTprGemCont, nOrgCusID+','+nZcid, nCompanyId, @nOut) then
    begin
      nMsg := Format('在线获取[ %s ]合同信用额度信息失败,已终止.', [nOrgCusID+','+nZcid]);
      Result := False;
      Exit;
    end;
    Result:=True;
    nRemMoney := StrToFloat(nOut.FExtParam);
    WriteLog('SAX Money: '+nOut.FExtParam);

    if nOut.FData=sFlag_No then nMsg:='['+nOrgCusID+']资金余额不足.';
  end else
  begin
    if not TWorkerBusinessCommander.CallMe(cBC_GetTprGem, nOrgCusID, nCompanyId, @nOut) then
    begin
      nMsg := Format('在线获取[ %s ]客户信用额度信息失败,已终止.', [nOrgCusID]);
      Result := False;
      Exit;
    end;
    Result:=True;
    nRemMoney := StrToFloat(nOut.FExtParam);
    WriteLog('SAX Money: '+nOut.FExtParam);

    if nOut.FData=sFlag_No then nMsg:='['+nOrgCusID+']资金余额不足.';
  end;
end;

//Date: 2014-09-15
//Desc: 保存交货单
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nStr,nSQL,nFixMoney: string;
    nIdx: Integer;
    nVal,nMoney: Double;
    nOut: TWorkerBusinessCommand;
    nBxz: Boolean;
    nAxMoney,nSendValue: Double;
    nAxMsg,nOnLineModel: string;
    nWebOrderID: string;
begin
  Result := False;
  nBxz:= True; //默认强制信用额度
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  nOnLineModel:=GetOnLineModel; //获取是否在线模式
  if FListA.Values['SalesType'] = '0' then
  begin
    nBxz:=False;
  end else
  begin
    if FListA.Values['TriaTrade']='1' then
    begin
      if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_GetAXMaCredLmt, //是否强制信用额度
                FListA.Values['CusID'], FListA.Values['CompanyId'], @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        if nOut.FData = sFlag_No then
        begin
          nBxz:=False;
        end;
        if nBxz then
        begin
          if not GetRemTriCustomerMoney(FListA.Values['ZhiKa'],nAxMoney,nAxMsg) then
          begin
            nData:=nAxMsg;
            Exit;
          end;
        end;
      end else
      begin
        nData := '离线模式，获取三角贸易客户信息失败';
        Exit;
      end;
    end else
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_CustomerMaCredLmt, //是否强制信用额度
                FListA.Values['CusID'], '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
      if nOut.FData = sFlag_No then
      begin
        nBxz:=False;
      end;
      if nBxz then
      begin
        if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
        begin
          if not GetRemCustomerMoney(FListA.Values['ZhiKa'],nAxMoney,nAxMsg) then
          begin
            nData:=nAxMsg;
            Exit;
          end;
        end;
        if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney,  //获取本地资金额度
               FListA.Values['ZhiKa'], '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        nMoney := StrToFloat(nOut.FData);
        //nFixMoney := nOut.FExtParam;
        nFixMoney := sFlag_No;
        //Customer money
      end;
    end;
    if nBxz and (nOnLineModel=sFlag_Yes) then
    begin
      nStr := 'select IsNull(SUM(L_Value*L_Price),''0'') as L_TotalMoney from %s where L_BDAX = ''2'' and L_CusID=''%s'' ';
      nStr := Format(nStr,[sTable_Bill, FListA.Values['CusID']]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        nAxMoney := nAxMoney - Fields[0].AsFloat;
        WriteLog(FListA.Values['CusID']+': '+FloatToStr(nAxMoney));
      end;
    end;
  end;

  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);
  //unpack bill list
  nVal := 0;
  for nIdx:=0 to FListB.Count - 1 do
  begin
    FListC.Text := PackerDecodeStr(FListB[nIdx]);
    //get bill info

    with FListC do
      nVal := nVal + Float2Float(StrToFloat(Values['Price']) *
                     StrToFloat(Values['Value']), cPrecision, True);
    //xxxx
  end;
  
  if nBxz then
  begin
    if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
    begin
      if (FloatRelation(nVal, nAxMoney, rtGreater)) then
      begin
        nData := '客户[ %s ]没有足够的金额,详情如下:' + #13#10#13#10 +
                 '可用金额: %.2f' + #13#10 +
                 '开单金额: %.2f' + #13#10#13#10 +
                 '请减小提货量后再开单.';
        nData := Format(nData, [FListA.Values['CusID'], nAxMoney, nVal]);
        Exit;
      end;
    end;
    if FListA.Values['TriaTrade'] <> '1' then
    begin
      if (FloatRelation(nVal, nMoney, rtGreater)) then
      begin
        nData := '客户[ %s ]没有足够的金额,详情如下:' + #13#10#13#10 +
                 '可用金额: %.2f' + #13#10 +
                 '开单金额: %.2f' + #13#10#13#10 +
                 '请减小提货量后再开单.';
        nData := Format(nData, [FListA.Values['CusID'], nMoney, nVal]);
        Exit;
      end;
    end;
  end;
  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    for nIdx:=0 to FListB.Count - 1 do
    begin
      FListC.Values['Group'] :=sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_BillNo;
      //to get serial no

      //{$IFDEF GGJC}
      if Length(FListA.Values['LID']) > 8 then
        nOut.FData := FListA.Values['LID']
      else
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      end;
      //{$ELSE}
      {if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData); }
      //xxxxx
      //{$ENDIF}
      
      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill
      FListC.Text := PackerDecodeStr(FListB[nIdx]);
      //get bill info
      if FListA.Values['LocationID']='' then FListA.Values['LocationID'] := 'A';
      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FListA.Values['ZhiKa']),
              SF('L_Project', FListA.Values['Project']),

              SF('L_CusID', FListA.Values['CusID']),
              SF('L_CusName', FListA.Values['CusName']),
              SF('L_CusPY', FListA.Values['CusPY']),

              SF('L_Type', FListC.Values['Type']),
              SF('L_StockNo', FListC.Values['StockNO']),
              SF('L_StockName', FListC.Values['StockName']),

              SF('L_Value', FListC.Values['Value'], sfVal),
              SF('L_PlanQty', FListC.Values['Value'], sfVal),
              SF('L_Price', FListC.Values['Price'], sfVal),
              SF('L_LineRecID', FListC.Values['RECID']),
              
              SF('L_ZKMoney', nFixMoney),
              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Status', sFlag_BillNew),

              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListA.Values['Seal']),

              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal),
              SF('L_IfHYPrint', FListA.Values['IfHYprt']),

              SF('L_HYDan', FListC.Values['SampleID']),
              SF('L_SalesType', FListA.Values['SalesType']),
              SF('L_InvCenterId', FListA.Values['CenterID']),

              SF('L_InvLocationId', FListA.Values['LocationID']),
              SF('L_Area', FListA.Values['Area']),
              SF('L_KHSBM', FListA.Values['KHSBM']),

              SF('L_JXSTHD', FListA.Values['JXSTHD']),
              SF('L_OrgXSQYMC', FListA.Values['OrgXSQYMC']),
              SF('L_CW', FListA.Values['KuWei']),

              SF('L_IfFenChe', FListA.Values['IfFenChe']),
              SF('L_IfNeiDao', FListA.Values['IfNeiDao']),
              SF('L_TriaTrade', FListA.Values['TriaTrade']),

              SF('L_ContQuota', FListA.Values['ContQuota']),
              SF('L_ToAddr', FListA.Values['ToAddr']),
              SF('L_IdNumber', FListA.Values['IdNumber'])
              ], sTable_Bill, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      if FListA.Values['BuDan'] = sFlag_Yes then //补单
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        if FListC.Values['Type'] = sFlag_San then
        begin
          nStr := '';
          //散装不予合单
        end else
        begin
          nStr := FListC.Values['StockNO'];
          nStr := GetMatchRecord(nStr);
          //该品种在装车队列中的记录号
        end;

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr), MI('$Val', FListC.Values['Value']),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          nSQL := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListC.Values['StockNO']+FListC.Values['Type']),
            SF('T_Stock'   , FListC.Values['StockName']),
            SF('T_Type'    , FListC.Values['Type']),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListC.Values['Value'], sfVal),
            SF('T_VIP'     , FListA.Values['IsVIP']),
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
      end;
    end;

    if FListA.Values['BuDan'] = sFlag_Yes then //补单
    begin
      {if FListA.Values['ContQuota'] = '1' then
      begin
        nStr := 'Update %s Set A_ConOutMoney=A_ConOutMoney+%s Where A_CID=''%s''';
        nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                FListA.Values['CusID']]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        nStr := 'Update %s Set A_OutMoney=A_OutMoney+%s Where A_CID=''%s''';
        nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                FListA.Values['CusID']]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;  }
      //freeze money from account
    end else
    begin
      if FListA.Values['TriaTrade'] <> '1' then
      begin
        if FListA.Values['ContQuota'] = '1' then
        begin
          nStr := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney+%s Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                  FListA.Values['CusID']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end else
        begin
          nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney+%s Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                  FListA.Values['CusID']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
        //freeze money from account
        WriteLog('['+nOut.FData+']Add YKMoney: '+nStr);
      end;
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    nStr := 'select IsNull(SUM(L_Value),''0'') as SendValue from %s where L_LineRecID=''%s'' ';
    nStr := Format(nStr,[sTable_Bill, FListC.Values['RECID']]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nSendValue := Fields[0].AsFloat;
    end;

    nStr := 'Update %s Set D_Value=D_TotalValue-(%.2f) Where D_RECID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nSendValue, FListC.Values['RECID']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  if gSysParam.FGPWSURL <> '' then
  begin
    {$IFNDEF PLKP}
    nWebOrderID := FListA.Values['WebOrderID'];
    //修改商城订单状态
    ModifyWebOrderStatus(nOut.FData,c_WeChatStatusCreateCard,nWebOrderID);
    {$ENDIF}
    //发送微信消息
    SendMsgToWebMall(nOut.FData,cSendWeChatMsgType_AddBill,sFlag_Sale);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: 交货单[FIn.FData];车牌号[FIn.FExtParam]
//Desc: 修改指定交货单的车牌号
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if Fields[1].AsString <> '' then
    begin
      nData := '交货单[ %s ]已提货,无法修改车牌号.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;


    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-30
//Parm: 交货单号[FIn.FData];新纸卡[FIn.FExtParam]
//Desc: 将交货单调拨给新纸卡的客户
function TWorkerBusinessBills.BillSaleAdjust(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal,nMon: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  //----------------------------------------------------------------------------
  nStr := 'Select L_CusID,L_StockNo,L_StockName,L_Value,L_Price,L_ZhiKa,' +
          'L_ZKMoney,L_OutFact From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    if FieldByName('L_OutFact').AsString = '' then
    begin
      nData := '车辆出厂后(提货完毕)才能调拨.';
      Exit;
    end;

    FListB.Clear;
    with FListB do
    begin
      Values['CusID'] := FieldByName('L_CusID').AsString;
      Values['StockNo'] := FieldByName('L_StockNo').AsString;
      Values['StockName'] := FieldByName('L_StockName').AsString;
      Values['ZhiKa'] := FieldByName('L_ZhiKa').AsString;
      Values['ZKMoney'] := FieldByName('L_ZKMoney').AsString;
    end;
    
    nVal := FieldByName('L_Value').AsFloat;
    nMon := nVal * FieldByName('L_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FIn.FExtParam)]);
  //纸卡信息

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [FIn.FExtParam,
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    FListA.Clear;
    with FListA do
    begin
      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Price From %s Where D_ZID=''%s'' And D_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FIn.FExtParam, FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '纸卡[ %s ]上没有名称为[ %s ]的品种.';
      nData := Format(nData, [FIn.FExtParam, FListB.Values['StockName']]);
      Exit;
    end;

    FListC.Clear;
    nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListB.Values['CusID']]);
    FListC.Add(nStr); //还原提货方出金

    if FListB.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) ' +
              'Where Z_ID=''%s'' And Z_OnlyMoney=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon,
              FListB.Values['ZhiKa'], sFlag_Yes]);
      FListC.Add(nStr); //还原提货方限提金额
    end;

    nMon := nVal * FieldByName('D_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);

    if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FIn.FExtParam, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    if FloatRelation(nMon, StrToFloat(nOut.FData), rtGreater, cPrecision) then
    begin
      nData := '客户[ %s.%s ]余额不足,详情如下:' + #13#10#13#10 +
               '※.可用余额: %.2f元' + #13#10 +
               '※.调拨所需: %.2f元' + #13#10 +
               '※.需 补 交: %.2f元' + #13#10#13#10 +
               '请到财务室办理"补交货款"手续,然后再次调拨.';
      nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
               StrToFloat(nOut.FData), nMon,
               Float2Float(nMon - StrToFloat(nOut.FData), cPrecision, True)]);
      Exit;
    end;

    nStr := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListA.Values['CusID']]);
    FListC.Add(nStr); //增加调拨方出金

    if FListA.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon, FIn.FExtParam]);
      FListC.Add(nStr); //扣减调拨方限提金额
    end;

    nStr := MakeSQLByStr([SF('L_ZhiKa', FIn.FExtParam),
            SF('L_Project', FListA.Values['Project']),
            SF('L_Area', FListA.Values['Area']),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', FListA.Values['CusPY']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),
            SF('L_Price', FieldByName('D_Price').AsFloat, sfVal),
            SF('L_ZKMoney', FListA.Values['ZKMoney'])
            ], sTable_Bill, SF('L_ID', FIn.FData), False);
    FListC.Add(nStr); //增加调拨方出金
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//by lih 2016-06-06
//删单发送微信消息
function TWorkerBusinessBills.DelBillSendMsgWx(LID:string):Boolean;
var
  nSql,nStr: string;
  nRID:string;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  errcode,errmsg:string;
begin
  Result:=False;
  try
    nSql := 'Select a.R_ID,b.C_Factory,b.C_ToUser,a.L_ID,a.L_Card,a.L_Truck,a.L_StockNo,' +
            'a.L_StockName,a.L_CusID,a.L_CusName,a.L_CusAccount,a.L_MDate,a.L_MMan,' +
            'a.L_TransID,a.L_TransName,a.L_Searial,a.L_OutFact,a.L_OutMan From %s a,%s b ' +
            'Where a.L_CusID=b.C_ID and b.C_IsBind=''1'' and a.L_ID =''%s'' ';
    nSql := Format(nSql, [sTable_BillBak,sTable_Customer,LID]);
    {$IFDEF DEBUG}
    WriteLog(nSql);
    {$ENDIF}
    with gDBConnManager.WorkerQuery(FDBConn, nSql) do
    if RecordCount > 0 then
    begin
      nRID:=Fields[0].AsString;
      nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
            '<DATA>'+
            '<head>'+
            '<Factory>'+Fields[1].AsString+'</Factory>'+
            '<ToUser>'+Fields[2].AsString+'</ToUser>'+
            '<MsgType>4</MsgType>'+
            '</head>'+
            '<Items>'+
              '<Item>'+
              '<BillID>'+Fields[3].AsString+'</BillID>'+
              '<Card>'+Fields[4].AsString+'</Card>'+
              '<Truck>'+Fields[5].AsString+'</Truck>'+
              '<StockNo>'+Fields[6].AsString+'</StockNo>'+
              '<StockName>'+Fields[7].AsString+'</StockName>'+
              '<CusID>'+Fields[8].AsString+'</CusID>'+
              '<CusName>'+Fields[9].AsString+'</CusName>'+
              '<CusAccount>'+Fields[10].AsString+'</CusAccount>'+
              '<MakeDate>'+Fields[11].AsString+'</MakeDate>'+
              '<MakeMan>'+Fields[12].AsString+'</MakeMan>'+
              '<TransID>'+Fields[13].AsString+'</TransID>'+
              '<TransName>'+Fields[14].AsString+'</TransName>'+
              '<Searial>'+Fields[15].AsString+'</Searial>'+
              '<OutFact>'+Fields[16].AsString+'</OutFact>'+
              '<OutMan>'+Fields[17].AsString+'</OutMan>'+
              '</Item>'+
            '</Items>'+
             '<remark/>'+
            '</DATA>';
      {$IFDEF DEBUG}
      WriteLog(nStr);
      {$ENDIF}
      wxservice:=GetReviceWS(true,'',nil);
      nMsg:=wxservice.mainfuncs('send_event_msg',nStr);
      {$IFDEF DEBUG}
      WriteLog(nMsg);
      {$ENDIF}
      FPacker.XMLBuilder.ReadFromString(nMsg);
      with FPacker.XMLBuilder do
      begin
        nhead:=Root.FindNode('head');
        if Assigned(nhead) then
        begin
          errcode:=nhead.NodebyName('errcode').ValueAsString;
          errmsg:=nhead.NodebyName('errmsg').ValueAsString;
          if errcode='0' then
          begin
            nSql:='update %s set L_DelSendWx=''Y'' where R_ID=%s';
            nSql:=Format(nSql,[sTable_BillBak,nRID]);
            gDBConnManager.WorkerExec(FDBConn,nSql);
            Result:=True;
          end;
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

//Date: 2014-09-16
//Parm: 交货单号[FIn.FData]
//Desc: 删除指定交货单
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nHasOut: Boolean;
    nVal,nMoney: Double;
    nStr,nP,nFix,nRID,nCus,nBill,nZK: string;
    nOut:TWorkerBusinessCommand;
    nDBZhiKa:TDataSet;
    nHint,nLineRecID:string;
    nSendValue:Double;
begin
  Result := False;
  //init

  nStr := 'Select L_ZhiKa,L_Value,L_Price,L_CusID,L_OutFact,L_ZKMoney,L_LineRecID From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    //已出厂

    if nHasOut then
    begin
      nData := '交货单[ %s ]已出厂,不允许删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    
    nCus := FieldByName('L_CusID').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nFix := FieldByName('L_ZKMoney').AsString;

    nVal := FieldByName('L_Value').AsFloat;
    nMoney := Float2Float(nVal*FieldByName('L_Price').AsFloat, cPrecision, True);
    nLineRecID := FieldByName('L_LineRecID').AsString;
  end;
                   
  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]出现在多条记录上,异常终止!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //移出合单列表

      if nBill = FIn.FData then
        nBill := FListA[0];
      //更换交货单

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新合单信息
    end;

    //--------------------------------------------------------------------------
    {if nHasOut then
    begin
      nDBZhiKa:=LoadZhiKaInfo(nZK,nHint);
      with nDBZhiKa do
      begin
        if FieldByName('C_ContQuota').AsString='1' then
        begin
          nStr := 'Update %s Set A_ConOutMoney=A_ConOutMoney-(%.2f) Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
        end else
        begin
          nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
        end;
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      //释放出金
    end else}
    //if (GetOnLineModel <> sFlag_Yes) then
    begin
      nDBZhiKa:=LoadZhiKaInfo(nZK,nHint);
      if Assigned(nDBZhiKa) then
      with nDBZhiKa do
      begin
        if FieldByName('Z_TriangleTrade').AsString <> '1' then
        begin
          if FieldByName('C_ContQuota').AsString='1' then
          begin
            nStr := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%.2f) Where A_CID=''%s''';
            nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
          end else
          begin
            nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
            nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
          end;
          gDBConnManager.WorkerExec(FDBConn, nStr);
          WriteLog('['+FIn.FData+']Release YKMoney: '+nStr);
        end;
      end;
      //释放冻结金
    end;

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    FDBConn.FConn.CommitTrans;

    nStr := 'select IsNull(SUM(L_Value),''0'') as SendValue from %s where L_LineRecID=''%s'' ';
    nStr := Format(nStr,[sTable_Bill, nLineRecID]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nSendValue := Fields[0].AsFloat;
    end;

    nStr := 'Update %s Set D_Value=D_TotalValue-(%.2f) Where D_RECID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nSendValue, nLineRecID]);
    //xxxxx
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  if gSysParam.FGPWSURL <> '' then
  begin
    //修改商城订单状态
    ModifyWebOrderStatus(FIn.FData,2);
  end;
end;

//Date: 2014-09-17
//Parm: 交货单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为交货单绑定磁卡
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType,nLid: string;
begin  
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //交货单列表
  nLid := nStr;

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '交货单[ %s ]已出厂,禁止办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '交货单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '交货单[ %s ]同为散装,不能并单.'
        else nData := '交货单[ %s ]的水泥类型不一致,不能并单.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //交货单列表
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '车辆[ %s ]正在使用该卡,无法并单.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '车辆[ %s ]正在使用该卡,相同牌号才能并单.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

  //还在队列中车辆
  nStr := '';
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    try
      nStr := nStr + Fields[0].AsString;
    finally
      Next;
    end;

    nStr := Copy(nStr, 1, Length(nStr)-1);
    nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
  end; 

  nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
  //队列中交货单列表

  nSQL := 'Select L_Card From %s Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if (Fields[0].AsString <> '') and
         (Fields[0].AsString <> FIn.FExtParam) then
      begin
        nData := '车辆[ %s ]的磁卡号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单磁卡: [%s]' + #13#10 +
                 '*.其它磁卡: [%s]' + #13#10#13#10 +
                 '相同磁卡号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
        Exit;
      end;

      Next;
    end;  
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  if gSysParam.FGPWSURL <> '' then
  begin
    {$IFDEF PLKP}
    nLid := Copy(nLid,2,Length(nLid)-2);
    ModifyWebOrderStatus(nLid,c_WeChatStatusCreateCard,'');
    {$ENDIF}
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData]
//Desc: 注销磁卡
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足交货单编码规则,则视为交货单号
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,L_SalesType,'+
          'L_EmptyOut,L_LineRecID,L_InvLocationId,L_InvCenterId,'+
          'L_IfNeiDao,L_TriaTrade From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '交货单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]没有交货单.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FSalesType    := FieldByName('L_SalesType').AsString;

      FYSValid      := FieldByName('L_EmptyOut').AsString;
      FRecID        := FieldByName('L_LineRecID').AsString;
      FLocationID   := FieldByName('L_InvLocationId').AsString;

      FCenterID     := FieldByName('L_InvCenterId').AsString;
      FNeiDao       := FieldByName('L_IfNeiDao').AsString;
      FTriaTrade    := FieldByName('L_TriaTrade').AsString;
      
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp: string;
    f,m,nVal,nMVal: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nUpdateVal: Double;
    nBxz:Boolean;
    nAxMoney: Double;
    nAxMsg,nOnLineModel: string;
    nDBZhiKa:TDataSet;
    nHint,nReiNo: string;
    nTriaTrade: string;
    nTriCusID, nCompanyId: string;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '岗位[ %s ]提交了散装合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //袋装不过磅
    end; 

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //更新队列车辆进厂状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的皮重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //保存车辆有效皮重

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //返回榜单号,用于拍照绑定

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //栈台现场
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //已称皮
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      {$IFDEF QHSN}
      nStr := 'select Z_Name,Z_CenterID from %s a,%s b '+
              'where a.Z_ID = b.T_Line and b.T_Bill = ''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines,sTable_ZTTrucks,FID]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        FCenterID:= FieldByName('Z_CenterID').AsString;
        FKw:= FieldByName('Z_Name').AsString;
      end;
      
      if not TWorkerBusinessCommander.CallMe(cBC_GetSampleID,
        FStockName, FCenterID, @nOut) then
      begin
        WriteLog(nOut.FData);
        raise Exception.Create(nOut.FData);
      end;
      if nOut.FData='' then
      begin
        nData := '岗位[ %s ]试样编号使用完毕.';
        nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
        WriteLog(nData);
        Exit;
      end;

      nReiNo:=nOut.FData;  //获取式样编号
      WriteLog('['+FID+']GetSampleID: '+nReiNo);

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              SF('L_InvCenterId', FCenterID),
              SF('L_HYDan', nReiNo),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ELSE}
      nSQL := MakeSQLByStr([SF('L_Status', FStatus),              SF('L_NextStatus', FNextStatus),              SF('L_LadeTime', sField_SQLServer_Now, sfVal),              SF('L_LadeMan', FIn.FBase.FFrom.FUser),              SF('L_HYDan', FSampleID),              SF('L_EmptyOut', FYSValid),              SF('L_WorkOrder', FWorkOrder),              SF('L_CW', FKw)              ], sTable_Bill, SF('L_ID', FID), False);      {$ENDIF}
      FListA.Add(nSQL);
      
      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //放灰现场
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      {$IFDEF QHSN}
      nStr := 'select Z_Name,Z_CenterID from %s a,%s b '+
              'where a.Z_ID = b.T_Line and b.T_Bill = ''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines,sTable_ZTTrucks,FID]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        FCenterID:= FieldByName('Z_CenterID').AsString;
        FKw:= FieldByName('Z_Name').AsString;
      end;
      
      if not TWorkerBusinessCommander.CallMe(cBC_GetSampleID,
        FStockName, FCenterID, @nOut) then
      begin
        WriteLog(nOut.FData);
        raise Exception.Create(nOut.FData);
      end;
      if nOut.FData='' then
      begin
        nData := '岗位[ %s ]试样编号使用完毕.';
        nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
        WriteLog(nData);
        Exit;
      end;

      nReiNo:=nOut.FData; //获取式样编号
      WriteLog('['+FID+']GetSampleID: '+nReiNo);
      
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              SF('L_InvCenterId', FCenterID),
              SF('L_HYDan', nReiNo),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ELSE}
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),              SF('L_NextStatus', sFlag_TruckBFM),              SF('L_LadeTime', sField_SQLServer_Now, sfVal),              SF('L_LadeMan', FIn.FBase.FFrom.FUser),              SF('L_HYDan', FSampleID),              SF('L_EmptyOut', FYSValid),              SF('L_WorkOrder', FWorkOrder),              SF('L_CW', FKw)              ], sTable_Bill, SF('L_ID', FID), False);      {$ENDIF}
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    nBxz := True;
    nInt := -1;
    nMVal := 0;
    
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的毛重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    with nBills[0] do//散装袋装均需校验资金额
    begin
      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        nOnLineModel:=GetOnLineModel; //获取是否在线模式
        if nBills[0].FSalesType='0' then
        begin
          nBxz:=False;
        end else
        begin
          {if not TWorkerBusinessCommander.CallMe(cBC_GetTriangleTrade,    //获取是否三角贸易
                nBills[0].FZhiKa, '', @nOut) then
          begin
            nData := nOut.FData;
            Exit;
          end;
          nTriaTrade:=nOut.FData;
          if nTriaTrade = sFlag_Yes then }   // 三角贸易
          WriteLog('贸易类型：'+FTriaTrade);
          if FTriaTrade = '1' then    // 三角贸易
          begin
            if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
            begin
              if not TWorkerBusinessCommander.CallMe(cBC_GetCustNo,    //获取最终客户
                    nBills[0].FZhiKa, '', @nOut) then
              begin
                nData := nOut.FData;
                WriteLog(nData);
                Exit;
              end;
              nTriCusID:= nOut.FData;
              nCompanyId:= nOut.FExtParam;
              if nCompanyId = '' then nCompanyId := gCompanyAct;
              if not TWorkerBusinessCommander.CallMe(cBC_GetAXMaCredLmt, //是否强制信用额度
                      nTriCusID, nCompanyId, @nOut) then
              begin
                nData := nOut.FData;
                WriteLog(nData);
                Result:= True;
                Exit;
              end;
              if nOut.FData = sFlag_No then
              begin
                nBxz:=False;
              end;
              if nBxz then
              begin
                if not GetRemTriCustomerMoney(nBills[0].FZhiKa,nAxMoney,nAxMsg) then
                begin
                  nData:=nAxMsg;
                  Result:=True;
                  Exit;
                end;
              end;

              //+dmzn: 2017-07-24,强制使用本地信用
              nStr := 'Select C_AntiAXCredit From %s Where C_ID=''%s''';
              nStr := Format(nStr, [sTable_Customer, nTriCusID]);

              with gDBConnManager.WorkerQuery(FDBConn, nStr) do
              if RecordCount > 0 then
              begin
                nVal := Fields[0].AsFloat;
                if nVal > 0 then
                begin
                  nAxMoney := nAxMoney + nVal;
                  nStr := '客户[ %s ]验证订单[ %s ]时使用临时授信[ %.2f ]元.';
                  WriteLog(Format(nStr, [nTriCusID, nBills[0].FZhiKa, nVal]));
                end;
                nAxMoney := Float2Float(nAxMoney, cPrecision, False);
              end;
            end else
            begin
              nData:='离线模式，获取三角贸易客户信息失败';
              WriteLog(nData);
              Result:=True;
              Exit;
            end;
          end else
          begin
            if not TWorkerBusinessCommander.CallMe(cBC_CustomerMaCredLmt,
                  nBills[0].FCusID, '', @nOut) then
            begin
              nData := nOut.FData;
              Exit;
            end;
            if nOut.FData= sFlag_No then
            begin
              nBxz:=False;
            end;
            if nBxz then
            begin
              if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
              begin
                if not GetRemCustomerMoney(nBills[0].FZhiKa,nAxMoney,nAxMsg) then
                begin
                  nData:=nAxMsg;
                  Result:=True;
                  Exit;
                end;
              end;
              if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney,  //本地获取客户资金额度
               nBills[0].FZhiKa, '', @nOut) then
              begin
                nData := nOut.FData;
                Result:=True;
                Exit;
              end;
              m := StrToFloat(nOut.FData);
              WriteLog(nBills[0].FID+'本地资金：'+Floattostr(m));
              m := m + Float2Float(FPrice * FValue, cPrecision, False);
              WriteLog(nBills[0].FCusID+'冻结资金：'+Floattostr(Float2Float(FPrice * FValue, cPrecision, False)));
              //客户可用金
            end;
          end;
          if nBxz and (nOnLineModel=sFlag_Yes) then
          begin
            nStr := 'select IsNull(SUM(L_Value*L_Price),''0'') as L_TotalMoney from %s where L_BDAX=''2'' and L_CusID=''%s'' ';
            nStr := Format(nStr,[sTable_Bill, FCusID]);
            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            if RecordCount > 0 then
            begin
              nAxMoney := nAxMoney - Fields[0].AsFloat;
            end;
            WriteLog(nBills[0].FID+'在线资金：'+Floattostr(nAxMoney));
          end;
        end;

        if FType = sFlag_Dai then
        begin
          if nBxz then
          begin
            if nOnLineModel=sFlag_Yes then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - nAxMoney;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, nAxMoney, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
            //if nTriaTrade <> sFlag_Yes then
            if FTriaTrade <> '1' then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - m;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, m, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
          end;
        end else
        begin
          nVal := FValue;
          FValue := nMVal - FPData.FValue;
            //新净重,实际提货量
          if nBxz then
          begin
            if nOnLineModel=sFlag_Yes then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - nAxMoney;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, nAxMoney, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
            //if nTriaTrade <> sFlag_Yes then
            if FTriaTrade <> '1' then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - m;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, m, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
          end;

          //if nTriaTrade <> sFlag_Yes then
          if FTriaTrade <> '1' then
          begin
            m := Float2Float(FPrice * FValue, cPrecision, True);
            m := m - Float2Float(FPrice * nVal, cPrecision, True);
            //新增冻结金额
            nDBZhiKa:=LoadZhiKaInfo(nBills[0].FZhiKa,nHint);
            with nDBZhiKa do
            begin
              if FieldByName('C_ContQuota').AsString='1' then
              begin
                nSQL := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney+(%.2f) ' +
                        'Where A_CID=''%s''';
                nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
              end else
              begin
                nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney+(%.2f) ' +
                        'Where A_CID=''%s''';
                nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
              end;
              FListA.Add(nSQL); //更新账户
              WriteLog('['+FID+']Update YKMoney: '+nSQL);
            end;
          end;
          
          nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
                  ], sTable_Bill, SF('L_ID', FID), False);
          FListA.Add(nSQL); //更新提货量

          nUpdateVal := FValue-nVal;
          nSQL := 'Update %s Set D_Value=D_Value-(%.2f) ' +
                  'Where D_RECID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKaDtl, nUpdateVal, FRecID]);
          FListA.Add(nSQL); //更新纸卡余量
        end;
      end else
      begin
        nSQL := 'Update %s Set D_Value=D_Value+(%.2f) ' +
                'Where D_RECID=''%s''';
        nSQL := Format(nSQL, [sTable_ZhiKaDtl, FValue, FRecID]);
        FListA.Add(nSQL); //更新纸卡余量

        m := Float2Float(FPrice * FValue, cPrecision, True);
        WriteLog('空车出厂：'+FYSValid);
        nDBZhiKa:=LoadZhiKaInfo(FZhiKa,nHint);

        with nDBZhiKa do
        begin
          if FieldByName('Z_TriangleTrade').AsString <> '1' then
          begin
            if FieldByName('C_ContQuota').AsString='1' then
            begin
              nSQL := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%.2f) Where A_CID=''%s''';
              nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
            end else
            begin
              nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
              nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
            end;
            FListA.Add(nSQL); //更新客户资金(可能不同客户)
            WriteLog('['+FID+']Relese YKMoney: '+nSQL);
          end;
        end;
      end;
    end;
    
    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
        //累计净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //扣减已累计的净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //出厂模式,毛重不生效
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //未称毛重记录

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //出厂模式,不更新状态

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //排除本次称重
      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        nSQL := MakeSQLByStr([SF('L_Value', 0.00, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //未过重交货单列表

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的提货记录的皮重,等于本次的毛重

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的过磅记录的皮重,等于本次的毛重
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
      
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //更新交货单

      nVal := Float2Float(FPrice * FValue, cPrecision, True);
      //提货金额
      if (FYSValid = sFlag_Yes) and (FTriaTrade <> '1') then   //判断是否空车出厂
      begin
        nDBZhiKa:=LoadZhiKaInfo(nBills[nIdx].FZhiKa,nHint);
        with nDBZhiKa do
        begin
          if FieldByName('C_ContQuota').AsString='1' then
          begin
            nSQL := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%.2f) Where A_CID=''%s''';
            nSQL := Format(nSQL, [sTable_CusAccount, nVal, FCusID]);
          end else
          begin
            nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
            nSQL := Format(nSQL, [sTable_CusAccount, nVal, FCusID]);
          end;
          FListA.Add(nSQL); //更新客户资金(可能不同客户)
          WriteLog('['+FID+']Relese YKMoney: '+nSQL);
        end;
      end;
    end;

    nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //更新磁卡状态

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //交货单列表

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //合卡,但非主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //袋重无效

        i := Trunc(FValue * 1000 / FPerW);
        //袋数

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //扣减合卡副单的装车量
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //合卡主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    //WriteLog('Clear Trucks: '+nSQL);
    FListA.Add(nSQL); //清理装车队列
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    {$IFDEF QHSN}
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FNeiDao='Y' then
      begin
        if Assigned(gHardShareData) then
          gHardShareData('TruckOut:' + nBills[0].FCard);
        //磅房处理自动出厂
      end;
    end;
    {$ELSE}
       {$IFNDEF ZXKP}
       if Assigned(gHardShareData) then
          gHardShareData('TruckOut:' + nBills[0].FCard);
        //磅房处理自动出厂
       {$ENDIF}
    {$ENDIF}
  end;

end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.
