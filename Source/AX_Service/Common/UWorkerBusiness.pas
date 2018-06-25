{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml, HTTPApp;

type

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TWorkerBusinessAXCommander = class(TMITDBWorker)
  private
    FListA: TStrings;
    //list
    FIn: TWorkerBusinessAXCommand;
    FOut: TWorkerBusinessAXCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetAXSaleOrder(var nData: string): Boolean;
    //获取AX销售订单
    function GetAXSaleOrderLine(var nData: string): Boolean;
    //获取AX销售订单行
    function GetAXSupAgreement(var nData: string): Boolean;
    //获取补充协议
    function GetAXCreLimCust(var nData: string): Boolean;
    //获取信用额度增减（客户）
    function GetAXCreLimCusCont(var nData: string): Boolean;
    //获取信用额度增减（客户-合同）
    function GetAXSalesContract(var nData: string): Boolean;
    //获取销售合同
    function GetAXSalesContLine(var nData: string): Boolean;
    //获取销售合同行
    function GetAXVehicleNo(var nData: string): Boolean;
    //获取车号
    function GetAXPurOrder(var nData: string): Boolean;
    //获取采购订单
    function GetAXPurOrdLine(var nData: string): Boolean;
    //获取采购订单行
    function GetAXCustomer(var nData: string): Boolean;
    //获取客户信息
    function GetAXProviders(var nData: string): Boolean;
    //获取供应商信息
    function GetAXMaterails(var nData: string): Boolean;
    //获取物料信息
    function GetAXThInfo(var nData: string): Boolean;
    //获取提货信息
    function UpdateYKAmount(var nData: string): Boolean;
    //更新预扣金额
    function GetTransPriceByLadingType(nID,nDataAreaID,nPrice: string): string ;
    //通过提货类型返回运输单价  类型2为两票制返回nPrice其他返回0
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt,nExXml: string;
      const nOut: PWorkerBusinessAXCommand): Boolean;
    //local call
  end;

implementation
uses
  UDataModule;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessAXCommander.FunctionName: string;
begin
  Result := sBus_BusinessAXCommand;
end;

constructor TWorkerBusinessAXCommander.Create;
begin
  FListA := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessAXCommander.destroy;
begin
  FreeAndNil(FListA);
  inherited;
end;

function TWorkerBusinessAXCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessAXCommand;
  end;
end;

procedure TWorkerBusinessAXCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessAXCommander.CallMe(const nCmd: Integer;
  const nData, nExt,nExXml: string; const nOut: PWorkerBusinessAXCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessAXCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FExXml:= nExXml;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessAXCommand);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessAXCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_AXSalesOrder         : Result := GetAXSaleOrder(nData);
   cBC_AXSalesOrdLine       : Result := GetAXSaleOrderLine(nData);
   cBC_AXSupAgreement       : Result := GetAXSupAgreement(nData);
   cBC_AXCreLimCust         : Result := GetAXCreLimCust(nData);
   cBC_AXCreLimCusCont      : Result := GetAXCreLimCusCont(nData);
   cBC_AXSalesCont          : Result := GetAXSalesContract(nData);
   cBC_AXSalesContLine      : Result := GetAXSalesContLine(nData);
   cBC_AXVehicleNo          : Result := GetAXVehicleNo(nData);
   cBC_AXPurOrder           : Result := GetAXPurOrder(nData);
   cBC_AXPurOrdLine         : Result := GetAXPurOrdLine(nData);
   cBC_AXCustNo             : Result := GetAXCustomer(nData);
   cBC_AXProvider           : Result := GetAXProviders(nData);
   cBC_AXMaterails          : Result := GetAXMaterails(nData);
   cBC_AXThInfo             : Result := GetAXThInfo(nData);
   cBC_AXYKAmount           : Result := UpdateYKAmount(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2017-09-16
//Desc: 获取AX销售订单
function TWorkerBusinessAXCommander.GetAXSaleOrder(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select SalesId, SalesName, CMT_ContractNo, CustAccount, FixedDueDate,'
           + 'salesstatus, SalesType, CMT_TriangleTrade, CMT_OrgAccountNum, CMT_OrgAccountName,'
           + 'InterCompanyOriginalSalesId, XSQYBM, CMT_KHSBM, XTFreightNew, InterCompanyCompanyId,'
           + ' innerQYBM From %s Where DataAreaID=''%s'' and Recid=''%s'' and xtDProdBusinessId=''SN'' ';
    nStr := Format(nStr, [sTable_AX_Sales, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的销售订单不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['Z_ID']:= FieldByName('SalesId').AsString;
        Values['Z_Name']:= FieldByName('SalesName').AsString;
        Values['Z_CID']:= FieldByName('CMT_ContractNo').AsString;
        Values['Z_Customer']:= FieldByName('CustAccount').AsString;
        if (Pos('1900',FieldByName('FixedDueDate').AsString)>0) then
          Values['Z_ValidDays']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now+1)
        else
          Values['Z_ValidDays']:= FieldByName('FixedDueDate').AsString;
        Values['Z_SalesStatus']:= FieldByName('salesstatus').AsString;
        Values['Z_SalesType']:= FieldByName('SalesType').AsString;
        Values['Z_TriangleTrade']:= FieldByName('CMT_TriangleTrade').AsString;
        Values['Z_OrgAccountNum']:= FieldByName('CMT_OrgAccountNum').AsString;
        Values['Z_OrgAccountName']:= FieldByName('CMT_OrgAccountName').AsString;
        Values['Z_IntComOriSalesId']:= FieldByName('InterCompanyOriginalSalesId').AsString;
        Values['Z_XSQYBM']:= FieldByName('XSQYBM').AsString;
        Values['Z_KHSBM']:= FieldByName('CMT_KHSBM').AsString;
        Values['Z_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
        Values['Z_Lading']:= FieldByName('XTFreightNew').AsString;
        Values['Z_CompanyId']:= FieldByName('InterCompanyCompanyId').AsString;
        Values['Z_OrgXSQYBM']:= FieldByName('innerQYBM').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select Z_ID from %s where Z_ID=''%s'' and DataAreaID=''%s'' ';
  nStr := Format(nStr, [sTable_ZhiKa, FListA.Values['Z_ID'], FIn.FData]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('Z_ID', Values['Z_ID'])+' and '+SF('DataAreaID', FIn.FData);
        nStr := MakeSQLByStr([
                SF('Z_Name', Values['Z_Name']),
                SF('Z_CID', Values['Z_CID']),
                SF('Z_Customer', Values['Z_Customer']),
                SF('Z_ValidDays', Values['Z_ValidDays']),
                SF('Z_SalesStatus', Values['Z_SalesStatus']),
                SF('Z_SalesType', Values['Z_SalesType']),
                SF('Z_TriangleTrade', Values['Z_TriangleTrade']),
                SF('Z_OrgAccountNum', Values['Z_OrgAccountNum']),
                SF('Z_OrgAccountName', Values['Z_OrgAccountName']),
                SF('Z_IntComOriSalesId', Values['Z_IntComOriSalesId']),
                SF('Z_Date', Values['Z_Date']),
                SF('Z_XSQYBM', Values['Z_XSQYBM']),
                SF('Z_KHSBM', Values['Z_KHSBM']),
                SF('Z_Lading', Values['Z_Lading']),
                SF('Z_CompanyId', Values['Z_CompanyId']),
                SF('Z_OrgXSQYBM', Values['Z_OrgXSQYBM'])
                ], sTable_ZhiKa, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('Z_ID', Values['Z_ID']),
                SF('Z_Name', Values['Z_Name']),
                SF('Z_CID', Values['Z_CID']),
                SF('Z_Customer', Values['Z_Customer']),
                SF('Z_ValidDays', Values['Z_ValidDays']),
                SF('Z_SalesStatus', Values['Z_SalesStatus']),
                SF('Z_SalesType', Values['Z_SalesType']),
                SF('Z_TriangleTrade', Values['Z_TriangleTrade']),
                SF('Z_OrgAccountNum', Values['Z_OrgAccountNum']),
                SF('Z_OrgAccountName', Values['Z_OrgAccountName']),
                SF('Z_IntComOriSalesId', Values['Z_IntComOriSalesId']),
                SF('Z_Date', Values['Z_Date']),
                SF('Z_XSQYBM', Values['Z_XSQYBM']),
                SF('Z_KHSBM', Values['Z_KHSBM']),
                SF('Z_Lading', Values['Z_Lading']),
                SF('Z_CompanyId', Values['Z_CompanyId']),
                SF('DataAreaID', FIn.FData),
                SF('Z_OrgXSQYBM', Values['Z_OrgXSQYBM'])
                ], sTable_ZhiKa, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+ nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取AX销售订单行
function TWorkerBusinessAXCommander.GetAXSaleOrderLine(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select SalesId, CMT_PACKTYPE, ItemId,' +
            ' Name, SalesStatus, SalesPrice, RemainSalesPhysical,' +
            ' Blocked, CMT_Notes, SalesQty, CMT_YFPrice From %s Where DataAreaID=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_SalLine, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的销售订单行不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['D_ZID']:= FieldByName('SalesId').AsString;
        if FieldByName('CMT_PACKTYPE').AsString='1' then
          Values['D_Type']:='D'
        else if FieldByName('CMT_PACKTYPE').AsString='2' then
          Values['D_Type']:='S'
        else
          Values['D_Type']:= FieldByName('CMT_PACKTYPE').AsString;
        Values['D_StockNo']:= UpperCase(FieldByName('ItemId').AsString);
        Values['D_StockName']:= FieldByName('Name').AsString;
        Values['D_SalesStatus']:= FieldByName('SalesStatus').AsString;
        Values['D_Price']:= FieldByName('SalesPrice').AsString;
        Values['D_Value']:= FieldByName('RemainSalesPhysical').AsString;
        Values['D_Blocked']:= FieldByName('Blocked').AsString;
        Values['D_Memo']:= FieldByName('CMT_Notes').AsString;
        Values['D_TotalValue']:= FieldByName('SalesQty').AsString;
        Values['D_TransPrice']:= GetTransPriceByLadingType(FieldByName('SalesId').AsString,
                                 FIn.FData,FieldByName('CMT_YFPrice').AsString);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select D_ZID from %s where D_ZID=''%s'' and DataAreaID=''%s'' and D_RECID=''%s'' ';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FListA.Values['D_ZID'], FIn.FData, FIn.FExtParam]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('D_ZID', Values['D_ZID'])+' and '+SF('DataAreaID', FIn.FData)+
                   ' and '+SF('D_RECID', FIn.FExtParam);
        nStr := MakeSQLByStr([
                SF('D_Type', Values['D_Type']),
                SF('D_StockNo', Values['D_StockNo']),
                SF('D_StockName', Values['D_StockName']),
                SF('D_SalesStatus', Values['D_SalesStatus']),
                SF('D_Price', Values['D_Price']),
                SF('D_TotalValue', Values['D_TotalValue']),
                SF('D_Blocked', Values['D_Blocked']),
                SF('D_TransPrice', Values['D_TransPrice']),
                SF('D_Memo', Values['D_Memo'])
                ], sTable_ZhiKaDtl, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('D_ZID', Values['D_ZID']),
                SF('D_Type', Values['D_Type']),
                SF('D_StockNo', Values['D_StockNo']),
                SF('D_StockName', Values['D_StockName']),
                SF('D_SalesStatus', Values['D_SalesStatus']),
                SF('D_Price', Values['D_Price']),
                SF('D_Value', Values['D_Value']),
                SF('D_TotalValue', Values['D_TotalValue']),
                SF('D_Blocked', Values['D_Blocked']),
                SF('D_TransPrice', Values['D_TransPrice']),
                SF('D_Memo', Values['D_Memo']),
                SF('DataAreaID', FIn.FData),
                SF('D_RECID', FIn.FExtParam)
                ], sTable_ZhiKaDtl, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+ nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取补充协议
function TWorkerBusinessAXCommander.GetAXSupAgreement(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select XTEadjustBillNum, RefRecid, SalesId, ItemId, SalesNewAmount,'+
            ' TakeEffectDate, TakeEffectTime From %s Where DataAreaID=''%s'' and RecId=''%s'' ';
    nStr := Format(nStr, [sTable_AX_SupAgre, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的补充协议不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['A_XTEadjustBillNum']:= FieldByName('XTEadjustBillNum').AsString;
        Values['RefRecid']:= FieldByName('RefRecid').AsString;
        Values['A_SalesId']:= FieldByName('SalesId').AsString;
        Values['A_ItemId']:= UpperCase(FieldByName('ItemId').AsString);
        Values['A_SalesNewAmount']:= FieldByName('SalesNewAmount').AsString;
        Values['A_TakeEffectDate']:= FieldByName('TakeEffectDate').AsString;
        values['A_TakeEffectTime']:= FieldByName('TakeEffectTime').AsString;
        Values['A_Date']:=FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select Recid from %s where Recid=''%s'' and DataAreaID=''%s'' ';
  nStr := Format(nStr, [sTable_AddTreaty, FIn.FExtParam, FIn.FData]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('DataAreaID', FIn.FData)+' and '+SF('Recid', FIn.FExtParam);
        nStr := MakeSQLByStr([
                SF('A_SalesId', Values['A_SalesId']),
                SF('A_ItemId', Values['A_ItemId']),
                SF('A_SalesNewAmount', Values['A_SalesNewAmount']),
                SF('A_TakeEffectDate', Values['A_TakeEffectDate']),
                SF('A_TakeEffectTime', Values['A_TakeEffectTime']),
                SF('A_Date', Values['A_Date'])
                ], sTable_AddTreaty, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('A_XTEadjustBillNum', Values['A_XTEadjustBillNum']),
                SF('A_SalesId', Values['A_SalesId']),
                SF('A_ItemId', Values['A_ItemId']),
                SF('A_SalesNewAmount', Values['A_SalesNewAmount']),
                SF('A_TakeEffectDate', Values['A_TakeEffectDate']),
                SF('A_TakeEffectTime', Values['A_TakeEffectTime']),
                SF('RefRecid', Values['RefRecid']),
                SF('A_Date', Values['A_Date']),
                SF('DataAreaID', FIn.FData),
                SF('Recid', FIn.FExtParam)
                ], sTable_AddTreaty, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+ nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取信用额度增减（客户）
function TWorkerBusinessAXCommander.GetAXCreLimCust(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
    nInt : Integer;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  nInt := 0 ;
  try
    nStr := 'Select CustAccount, XTSubCash, XTSubThreeBill, XTSubSixBill,'+
            ' XTSubTmp, PRESTIGEQUOTA, Createdby, Createddatetime, YKAmount,'+
            ' CMT_TransPlanID From %s Where DataAreaID=''%s'' and RecId=''%s'' ';
    nStr := Format(nStr, [sTable_AX_CreLimLog, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的信用额度增减记录不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['C_CusID']:= FieldByName('CustAccount').AsString;
        Values['C_SubCash']:= FieldByName('XTSubCash').AsString;
        Values['C_SubThreeBill']:= FieldByName('XTSubThreeBill').AsString;
        Values['C_SubSixBil']:= FieldByName('XTSubSixBill').AsString;
        Values['C_SubTmp']:= FieldByName('XTSubTmp').AsString;
        values['C_SubPrest']:= FieldByName('PRESTIGEQUOTA').AsString;
        Values['C_Createdby']:= FieldByName('Createdby').AsString;
        Values['C_Createdate']:= FieldByName('Createddatetime').AsString;
        Values['C_YKAmount']:= FieldByName('YKAmount').AsString;
        Values['C_TransPlanID']:= FieldByName('CMT_TransPlanID').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select RecID from %s where DataAreaID=''%s'' and RecID=''%s'' ';
  nStr := Format(nStr, [sTable_CustPresLog, FIn.FData, FIn.FExtParam]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := MakeSQLByStr([
                SF('C_CusID', Values['C_CusID']),
                SF('C_SubCash', Values['C_SubCash']),
                SF('C_SubThreeBill', Values['C_SubThreeBill']),
                SF('C_SubSixBil', Values['C_SubSixBil']),
                SF('C_SubTmp', Values['C_SubTmp']),
                SF('C_SubPrest', Values['C_SubPrest']),
                SF('C_Createdby', Values['C_Createdby']),
                SF('C_YKAmount', Values['C_YKAmount']),
                SF('C_TransPlanID', Values['C_TransPlanID']),
                SF('C_Createdate', Values['C_Createdate']),
                SF('DataAreaID', FIn.FData),
                SF('RecID', FIn.FExtParam)
                ], sTable_CustPresLog, '', True);
        nInt := gDBConnManager.WorkerExec(FDBConn, nStr);
        FDBConn.FConn.CommitTrans;
      end
      else
      begin
        WriteLog(sTable_CustPresLog+'信用额度增减(客户)记录已存在:'+ FIn.FData + '，' + FIn.FExtParam);
        Result := True;
      end;
    end;
    if nInt > 0 then//插入成功,开始计算信用额度（客户）
    begin
      nStr:='select C_CusID from %s where C_CusID=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_CusCredit, FListA.Values['C_CusID'], FIn.FData]);

      FDBConn.FConn.BeginTrans;

      with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
      begin
        if RecordCount > 0 then
        begin
          nStr:='update %s set C_CashBalance=C_CashBalance+(%s),'+
                'C_BillBalance3M=C_BillBalance3M+(%s),'+
                'C_BillBalance6M=C_BillBalance6M+(%s),'+
                'C_TemporBalance=C_TemporBalance+(%s),'+
                'C_PrestigeQuota=C_PrestigeQuota+(%s),'+
                'C_Date=''%s'',C_Man=''%s'' '+
                ' where C_CusID=''%s'' and DataAreaID=''%s'' ';
          nStr:=Format(nStr, [sTable_CusCredit, Values['C_SubCash'],
                              Values['C_SubThreeBill'], Values['C_SubSixBil'],
                              Values['C_SubTmp'], values['C_SubPrest'],
                              FormatDateTime('yyyy-mm-dd hh:mm:ss',Now), Values['C_Createdby'],
                              Values['C_CusID'], FIn.FData]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end
        else
        begin
          nStr := MakeSQLByStr([
                  SF('C_CusID', Values['C_CusID']),
                  SF('C_CashBalance', Values['C_SubCash']),
                  SF('C_BillBalance3M', Values['C_SubThreeBill']),
                  SF('C_BillBalance6M', Values['C_SubSixBil']),
                  SF('C_TemporBalance', Values['C_SubTmp']),
                  SF('C_PrestigeQuota', Values['C_SubPrest']),
                  SF('C_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                  SF('C_Man', Values['C_Createdby']),
                  SF('DataAreaID', FIn.FData)
                  ], sTable_CusCredit, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
      end;
      FDBConn.FConn.CommitTrans;
      Result := True;
    end;
  except
    WriteLog('业务执行失败:'+sTable_CusCredit+'信用额度增减(客户)Sql:'+ nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取信用额度增减（客户-合同）
function TWorkerBusinessAXCommander.GetAXCreLimCusCont(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
    nInt : Integer;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  nInt := 0 ;
  try
    nStr := 'Select CustAccount, XTSubCash, XTSubThreeBill, XTSubSixBill,' +
            ' XTSubTmp, PRESTIGEQUOTA, Createdby, Createddatetime, CMT_ContractId,' +
            ' YKAmount, CMT_TransPlanID From %s Where DataAreaID=''%s'' and RecId=''%s'' ';
    nStr := Format(nStr, [sTable_AX_ContCreLimLog, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的信用额度增减记录(客户-合同)不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['C_CusID']:= FieldByName('CustAccount').AsString;
        Values['C_SubCash']:= FieldByName('XTSubCash').AsString;
        Values['C_SubThreeBill']:= FieldByName('XTSubThreeBill').AsString;
        Values['C_SubSixBil']:= FieldByName('XTSubSixBill').AsString;
        Values['C_SubTmp']:= FieldByName('XTSubTmp').AsString;
        values['C_SubPrest']:= FieldByName('PRESTIGEQUOTA').AsString;
        Values['C_Createdby']:= FieldByName('Createdby').AsString;
        Values['C_Createdate']:= FieldByName('Createddatetime').AsString;
        Values['C_ContractId']:=FieldByName('CMT_ContractId').AsString;
        Values['C_YKAmount']:= FieldByName('YKAmount').AsString;
        Values['C_TransPlanID']:= FieldByName('CMT_TransPlanID').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select RecID from %s where DataAreaID=''%s'' and RecID=''%s'' ';
  nStr := Format(nStr, [sTable_ContPresLog, FIn.FData, FIn.FExtParam]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := MakeSQLByStr([
                SF('C_CusID', Values['C_CusID']),
                SF('C_SubCash', Values['C_SubCash']),
                SF('C_SubThreeBill', Values['C_SubThreeBill']),
                SF('C_SubSixBil', Values['C_SubSixBil']),
                SF('C_SubTmp', Values['C_SubTmp']),
                SF('C_SubPrest', Values['C_SubPrest']),
                SF('C_Createdby', Values['C_Createdby']),
                SF('C_YKAmount', Values['C_YKAmount']),
                SF('C_TransPlanID', Values['C_TransPlanID']),
                SF('C_Createdate', Values['C_Createdate']),
                SF('C_ContractId', Values['C_ContractId']),
                SF('DataAreaID', FIn.FData),
                SF('RecID', FIn.FExtParam)
                ], sTable_ContPresLog, '', True);
        nInt := gDBConnManager.WorkerExec(FDBConn, nStr);
        FDBConn.FConn.CommitTrans;
      end
      else
      begin
        WriteLog(sTable_ContPresLog+'信用额度增减(客户-合同)记录已存在:'+ FIn.FData + '，' + FIn.FExtParam);
        Result := True;
      end;
    end;
    if nInt > 0 then//插入成功,开始计算信用额度（客户-合同）
    begin
      nStr:='select C_CusID from %s where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_CusContCredit, FListA.Values['C_CusID'], FListA.Values['C_ContractId'], FIn.FData]);

      FDBConn.FConn.BeginTrans;

      with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
      begin
        if RecordCount > 0 then
        begin
          nStr:='update %s set C_CashBalance=C_CashBalance+(%s),'+
                'C_BillBalance3M=C_BillBalance3M+(%s),'+
                'C_BillBalance6M=C_BillBalance6M+(%s),'+
                'C_TemporBalance=C_TemporBalance+(%s),'+
                'C_PrestigeQuota=C_PrestigeQuota+(%s),'+
                'C_Date=''%s'' '+
                ' where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
          nStr:=Format(nStr, [sTable_CusContCredit, Values['C_SubCash'],
                              Values['C_SubThreeBill'], Values['C_SubSixBil'],
                              Values['C_SubTmp'], values['C_SubPrest'],
                              FormatDateTime('yyyy-mm-dd hh:mm:ss',Now),
                              Values['C_CusID'], Values['C_ContractId'], FIn.FData]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end
        else
        begin
          nStr := MakeSQLByStr([
                  SF('C_CusID', Values['C_CusID']),
                  SF('C_ContractId', Values['C_ContractId']),
                  SF('C_CashBalance', Values['C_SubCash']),
                  SF('C_BillBalance3M', Values['C_SubThreeBill']),
                  SF('C_BillBalance6M', Values['C_SubSixBil']),
                  SF('C_TemporBalance', Values['C_SubTmp']),
                  SF('C_PrestigeQuota', Values['C_SubPrest']),
                  SF('C_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
//                  SF('C_Man', Values['C_Createdby']),
                  SF('DataAreaID', FIn.FData)
                  ], sTable_CusContCredit, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
      end;
      FDBConn.FConn.CommitTrans;
      Result := True;
    end;
  except
    WriteLog('业务执行失败：'+sTable_CusContCredit+'信用额度增减(客户)Sql:'+ nStr);
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取销售合同
function TWorkerBusinessAXCommander.GetAXSalesContract(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select ContactId, CUST, custname, ContactAddress, CMT_SFSP, xtEContractSuperType,' +
            ' XTContactQuota From %s Where companyid=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_SalesCont, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的销售合同不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['C_ID']:= FieldByName('ContactId').AsString;
        Values['C_Customer']:= FieldByName('CUST').AsString;
        Values['C_CustName']:= FieldByName('custname').AsString;
        values['C_Addr']:= FieldByName('ContactAddress').AsString;
        Values['C_SFSP']:= FieldByName('CMT_SFSP').AsString;
        Values['C_ContType']:= FieldByName('xtEContractSuperType').AsString;
        Values['C_ContQuota']:= FieldByName('XTContactQuota').AsString;
        Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select C_ID from %s where C_ID=''%s'' and DataAreaID=''%s'' ';
  nStr := Format(nStr, [sTable_SaleContract, FListA.Values['C_ID'], FIn.FData]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('DataAreaID', FIn.FData)+' and '+SF('C_ID', Values['C_ID']);
        nStr := MakeSQLByStr([
                SF('C_Customer', Values['C_Customer']),
                SF('C_CustName', Values['C_CustName']),
                SF('C_Addr', Values['C_Addr']),
                SF('C_SFSP', Values['C_SFSP']),
                SF('C_ContType', Values['C_ContType']),
                SF('C_ContQuota', Values['C_ContQuota'])
                ], sTable_SaleContract, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('C_ID', Values['C_ID']),
                SF('C_Customer', Values['C_Customer']),
                SF('C_CustName', Values['C_CustName']),
                SF('C_Addr', Values['C_Addr']),
                SF('C_SFSP', Values['C_SFSP']),
                SF('C_ContType', Values['C_ContType']),
                SF('C_ContQuota', Values['C_ContQuota']),
                SF('C_Date', Values['C_Date']),
                SF('DataAreaID', FIn.FData)
                ], sTable_SaleContract, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取销售合同行
function TWorkerBusinessAXCommander.GetAXSalesContLine(var nData: string): Boolean;
var nStr, nType: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select packtype, ContactId, itemid, itemname, qty, price, amount'+
            ' From %s Where DataAreaID=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_SalContLine, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的销售合同行不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        if FieldByName('packtype').AsString='1' then
          nType:='D'
        else if FieldByName('packtype').AsString='2' then
          nType:='S'
        else
          nType:=FieldByName('packtype').AsString;
        Values['E_CID']:= FieldByName('ContactId').AsString;
        Values['E_Type']:= nType;
        Values['E_StockNo']:= UpperCase(FieldByName('itemid').AsString);
        values['E_StockName']:= FieldByName('itemname').AsString;
        Values['E_Value']:= FieldByName('qty').AsString;
        Values['E_Price']:= FieldByName('price').AsString;
        Values['E_Money']:= FieldByName('amount').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select E_RecID from %s where DataAreaID=''%s'' and E_RecID=''%s'' ';
  nStr := Format(nStr, [sTable_SContractExt, FIn.FData, FIn.FExtParam]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('DataAreaID', FIn.FData)+' and '+SF('E_RecID', FIn.FExtParam);
        nStr := MakeSQLByStr([
                SF('E_Type', Values['E_Type']),
                SF('E_StockNo', Values['E_StockNo']),
                SF('E_StockName', Values['E_StockName']),
                SF('E_Value', Values['E_Value']),
                SF('E_Price', Values['E_Price']),
                SF('E_Money', Values['E_Money'])
                ], sTable_SContractExt, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('E_CID', Values['E_CID']),
                SF('E_Type', Values['E_Type']),
                SF('E_StockNo', Values['E_StockNo']),
                SF('E_StockName', Values['E_StockName']),
                SF('E_Value', Values['E_Value']),
                SF('E_Price', Values['E_Price']),
                SF('E_Money', Values['E_Money']),
                SF('E_RecID', FIn.FExtParam),
                SF('DataAreaID', FIn.FData)
                ], sTable_SContractExt, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取车号
function TWorkerBusinessAXCommander.GetAXVehicleNo(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;

  Result:= True;
  Exit;//由于会影响电子标签,不再同步

  nDBWorker := nil;
  try
    nStr := 'Select VehicleId, CZ, DriverId, CMT_PrivateId, companyid, XTECB,'+
            ' VendAccount From %s Where companyid=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_VehicleNo, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的车辆信息不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['T_Truck']:= FieldByName('VehicleId').AsString;
        Values['T_Owner']:= FieldByName('CZ').AsString;
        Values['T_Driver']:= FieldByName('DriverId').AsString;
        values['T_Card']:= FieldByName('CMT_PrivateId').AsString;
        Values['T_CompanyID']:= FieldByName('companyid').AsString;
        Values['T_XTECB']:= FieldByName('XTECB').AsString;
        Values['T_VendAccount']:= FieldByName('VendAccount').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select T_Truck from %s where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_Truck, FListA.Values['T_Truck']]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('T_Truck', Values['T_Truck']);
        nStr := MakeSQLByStr([
                SF('T_Owner', Values['T_Owner']),
                SF('T_Driver', Values['T_Driver']),
                SF('T_Card', Values['T_Card']),
                SF('T_CompanyID', Values['T_CompanyID']),
                SF('T_XTECB', Values['T_XTECB']),
                SF('T_VendAccount', Values['T_VendAccount'])
                ], sTable_Truck, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('T_Truck', Values['T_Truck']),
                SF('T_Owner', Values['T_Owner']),
                SF('T_Driver', Values['T_Driver']),
                SF('T_Card', Values['T_Card']),
                SF('T_CompanyID', Values['T_CompanyID']),
                SF('T_XTECB', Values['T_XTECB']),
                SF('T_VendAccount', Values['T_VendAccount'])
                ], sTable_Truck, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取采购订单
function TWorkerBusinessAXCommander.GetAXPurOrder(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select PurchId, OrderAccount, xtContractId, PURCHNAME, PurchStatus,'+
            ' CMT_TriangleTrade, InterCompanyOriginalSalesId, PurchaseType,'+
            ' DocumentState From %s Where DataAreaID=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_PurOrder, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的采购订单不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['M_ID']:= FieldByName('PurchId').AsString;
        Values['M_ProID']:= FieldByName('OrderAccount').AsString;
        Values['M_ProName']:= FieldByName('PURCHNAME').AsString;
        Values['M_ProPY']:= GetPinYinOfStr(FieldByName('PURCHNAME').AsString);
        Values['M_CID']:= FieldByName('xtContractId').AsString;
        Values['M_BStatus']:= FieldByName('PurchStatus').AsString;
        Values['M_TriangleTrade']:= FieldByName('CMT_TriangleTrade').AsString;
        Values['M_IntComOriSalesId']:= FieldByName('InterCompanyOriginalSalesId').AsString;
        Values['M_PurchType']:= FieldByName('PurchaseType').AsString;
        Values['M_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
        Values['M_DState']:= FieldByName('DocumentState').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select M_ID from %s where M_ID=''%s'' ';
  nStr := Format(nStr, [sTable_OrderBaseMain, FListA.Values['M_ID']]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('DataAreaID', FIn.FData)+' and '+SF('M_ID', Values['M_ID']);
        nStr := MakeSQLByStr([
                SF('M_ProID', Values['M_ProID']),
                SF('M_ProName', Values['M_ProName']),
                SF('M_ProPY', Values['M_ProPY']),
                SF('M_CID', Values['M_CID']),
                SF('M_BStatus', Values['M_BStatus']),
                SF('M_TriangleTrade', Values['M_TriangleTrade']),
                SF('M_IntComOriSalesId', Values['M_IntComOriSalesId']),
                SF('M_PurchType', Values['M_PurchType']),
                SF('M_DState', Values['M_DState']),
                SF('M_Date', Values['M_Date'])
                ], sTable_OrderBaseMain, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('M_ID', Values['M_ID']),
                SF('M_ProID', Values['M_ProID']),
                SF('M_ProName', Values['M_ProName']),
                SF('M_ProPY', Values['M_ProPY']),
                SF('M_CID', Values['M_CID']),
                SF('M_BStatus', Values['M_BStatus']),
                SF('M_TriangleTrade', Values['M_TriangleTrade']),
                SF('M_IntComOriSalesId', Values['M_IntComOriSalesId']),
                SF('M_PurchType', Values['M_PurchType']),
                SF('M_DState', Values['M_DState']),
                SF('M_Date', Values['M_Date']),
                SF('DataAreaID', FIn.FData)
                ], sTable_OrderBaseMain, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取采购订单行
function TWorkerBusinessAXCommander.GetAXPurOrdLine(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select PurchId, CMT_PACKTYPE, ItemId, Name, PurchStatus, QtyOrdered,'+
            ' PurchReceivedNow, RemainPurchPhysical, Blocked '+
            ' From %s Where DataAreaID=''%s'' and Recid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_PurOrdLine, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的采购订单行不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['B_ID']:= FieldByName('PurchId').AsString;
        Values['B_StockType']:= FieldByName('CMT_PACKTYPE').AsString;
        Values['B_StockNo']:= UpperCase(FieldByName('ItemId').AsString);
        Values['B_StockName']:= FieldByName('Name').AsString;
        Values['B_BStatus']:= FieldByName('PurchStatus').AsString;
        Values['B_Value']:= FieldByName('QtyOrdered').AsString;
        Values['B_SentValue']:= FieldByName('PurchReceivedNow').AsString;
        Values['B_RestValue']:= FieldByName('RemainPurchPhysical').AsString;
        Values['B_Blocked']:= FieldByName('Blocked').AsString;
        Values['B_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select B_RecID from %s where DataAreaID=''%s'' and B_RecID=''%s'' ';
  nStr := Format(nStr, [sTable_OrderBase, FIn.FData, FIn.FExtParam]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('DataAreaID', FIn.FData)+' and '+SF('B_ID', Values['B_ID'])+' and '+SF('B_RECID', FIn.FExtParam);
        nStr := MakeSQLByStr([
                SF('B_StockType', Values['B_StockType']),
                SF('B_StockNo', Values['B_StockNo']),
                SF('B_StockName', Values['B_StockName']),
                SF('B_BStatus', Values['B_BStatus']),
                SF('B_Value', Values['B_Value']),
                SF('B_SentValue', Values['B_SentValue']),
                SF('B_RestValue', Values['B_RestValue']),
                SF('B_Blocked', Values['B_Blocked']),
                SF('B_Date', Values['B_Date'])
                ], sTable_OrderBase, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('B_ID', Values['B_ID']),
                SF('B_StockNo', Values['B_StockNo']),
                SF('B_StockName', Values['B_StockName']),
                SF('B_BStatus', Values['B_BStatus']),
                SF('B_Value', Values['B_Value']),
                SF('B_SentValue', Values['B_SentValue']),
                SF('B_RestValue', Values['B_RestValue']),
                SF('B_Blocked', Values['B_Blocked']),
                SF('B_Date', Values['B_Date']),
                SF('B_RECID', FIn.FExtParam),
                SF('DataAreaID', FIn.FData)
                ], sTable_OrderBase, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取客户信息
function TWorkerBusinessAXCommander.GetAXCustomer(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select AccountNum,Name,CreditMax,MandatoryCreditLimit,' +
            'ContactPersonId,CMT_KHYH,CMT_KHZH '+
            'From %s where DataAreaID=''%s'' and RecID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_Cust, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的客户信息不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['C_ID']:= FieldByName('AccountNum').AsString;
        Values['C_Name']:= FieldByName('Name').AsString;
        Values['C_PY']:= GetPinYinOfStr(FieldByName('Name').AsString);
        Values['C_CredMax']:= FieldByName('CreditMax').AsString;
        Values['C_MaCredLmt']:= FieldByName('MandatoryCreditLimit').AsString;
        Values['C_Account']:= FieldByName('CMT_KHZH').AsString;
        Values['C_XuNi']:= sFlag_No;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select C_ID from %s where C_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Customer, FListA.Values['C_ID']]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('C_ID', Values['C_ID']);
        nStr := MakeSQLByStr([
                SF('C_Name', Values['C_Name']),
                SF('C_PY', Values['C_PY']),
                SF('C_CredMax', Values['C_CredMax']),
                SF('C_MaCredLmt', Values['C_MaCredLmt']),
                SF('C_Account', Values['C_Account']),
                SF('C_XuNi', Values['C_XuNi'])
                ], sTable_Customer, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('C_ID', Values['C_ID']),
                SF('C_Name', Values['C_Name']),
                SF('C_PY', Values['C_PY']),
                SF('C_CredMax', Values['C_CredMax']),
                SF('C_MaCredLmt', Values['C_MaCredLmt']),
                SF('C_Account', Values['C_Account']),
                SF('C_XuNi', Values['C_XuNi'])
                ], sTable_Customer, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      FDBConn.FConn.CommitTrans;
    end;

    nStr:='select A_CID from %s where A_CID=''%s'' ';
    nStr := Format(nStr, [sTable_CusAccount, FListA.Values['C_ID']]);

    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := MakeSQLByStr([
                SF('A_CID', Values['C_ID']),
                SF('A_Date', Formatdatetime('yyyy-mm-dd hh:mm:ss',Now))
                ], sTable_CusAccount, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      FDBConn.FConn.CommitTrans;
    end;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取供应商信息
function TWorkerBusinessAXCommander.GetAXProviders(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select AccountNum,Name From %s where DataAreaID=''%s'' and RecID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_VEND, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的供应商信息不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['P_ID']:= FieldByName('AccountNum').AsString;
        Values['P_Name']:= FieldByName('Name').AsString;
        Values['P_PY']:= GetPinYinOfStr(FieldByName('Name').AsString);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select P_ID from %s where P_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Provider, FListA.Values['P_ID']]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('P_ID', Values['P_ID']);
        nStr := MakeSQLByStr([
                SF('P_Name', Values['P_Name']),
                SF('P_PY', Values['P_PY'])
                ], sTable_Provider, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('P_ID', Values['P_ID']),
                SF('P_Name', Values['P_Name']),
                SF('P_PY', Values['P_PY'])
                ], sTable_Provider, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-09-18
//Desc: 获取供应商信息
function TWorkerBusinessAXCommander.GetAXMaterails(var nData: string): Boolean;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select ItemId,ItemName,ItemGroupId,Weighning From %s where DataAreaID=''%s'' and RecID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_INVENT, FIn.FData, FIn.FExtParam]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '编号为[ %s ]的物料信息不存在.';
        nStr := Format(nStr, [FIn.FExtParam]);
        WriteLog(nStr);
        Exit;
      end;
      with FListA do
      begin
        Values['M_ID']:= FieldByName('ItemId').AsString;
        Values['M_Name']:= FieldByName('ItemName').AsString;
        Values['M_PY']:= GetPinYinOfStr(FieldByName('ItemName').AsString);
        Values['M_GroupID']:= FieldByName('ItemGroupId').AsString;
        Values['M_Weighning']:= FieldByName('Weighning').AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  nStr:='select M_ID from %s where M_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Materails, FListA.Values['M_ID']]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nStr := SF('M_ID', Values['M_ID']);
        nStr := MakeSQLByStr([
                SF('M_Name', Values['M_Name']),
                SF('M_PY', Values['M_PY']),
                SF('M_GroupID', Values['M_GroupID']),
                SF('M_Weighning', Values['M_Weighning'])
                ], sTable_Materails, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('M_ID', Values['M_ID']),
                SF('M_Name', Values['M_Name']),
                SF('M_PY', Values['M_PY']),
                SF('M_GroupID', Values['M_GroupID']),
                SF('M_Weighning', Values['M_Weighning'])
                ], sTable_Materails, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessAXCommander.GetAXThInfo(
  var nData: string): Boolean;
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  Result := False;
  FListA.Clear;
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+FIn.FExXml+'</DATA>');
    nNode := nXML.Root;
    if not Assigned(nNode) then
    begin
      WriteLog('提货信息xml加载失败！'+ FIn.FExXml);
      Exit;
    end;

    nTmp := nNode.NodeByName('CMT_WEIGHTSTATUS');
    if Assigned(nTmp) then
      FListA.Values['CMT_WEIGHTSTATUS']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('COMPANYID');
    if Assigned(nTmp) then
      FListA.Values['COMPANYID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('CUSTACCOUNT');
    if Assigned(nTmp) then
      FListA.Values['CUSTACCOUNT']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('CUSTNAME');
    if Assigned(nTmp) then
      FListA.Values['CUSTNAME']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('DESTINATIONCODE');
    if Assigned(nTmp) then
      FListA.Values['DESTINATIONCODE']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('INVENTLOCATIONID');
    if Assigned(nTmp) then
      FListA.Values['INVENTLOCATIONID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMID');
    if Assigned(nTmp) then
      FListA.Values['ITEMID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMPRICE');
    if Assigned(nTmp) then
      FListA.Values['ITEMPRICE']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('PLANQTY');
    if Assigned(nTmp) then
      FListA.Values['PLANQTY']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('POST');
    if Assigned(nTmp) then
      FListA.Values['POST']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('SALESID');
    if Assigned(nTmp) then
      FListA.Values['SALESID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('SALESLINERECID');
    if Assigned(nTmp) then
      FListA.Values['SALESLINERECID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('TRANSPLANID');
    if Assigned(nTmp) then
      FListA.Values['TRANSPLANID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('TRANSPORTER');
    if Assigned(nTmp) then
      FListA.Values['TRANSPORTER']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('VEHICLEID');
    if Assigned(nTmp) then
      FListA.Values['VEHICLEID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('WMSLOCATIONID');
    if Assigned(nTmp) then
      FListA.Values['WMSLOCATIONID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('XTDINVENTCENTERID');
    if Assigned(nTmp) then
      FListA.Values['XTDINVENTCENTERID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('RECVERSION');
    if Assigned(nTmp) then
      FListA.Values['RECVERSION']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('PARTITION');
    if Assigned(nTmp) then
      FListA.Values['PARTITION']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('CARDID');
    if Assigned(nTmp) then
      FListA.Values['CARDID']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('MODE_');
    if Assigned(nTmp) then
      FListA.Values['MODE_']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMNAME');
    if Assigned(nTmp) then
      FListA.Values['ITEMNAME']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMTYPE');
    if Assigned(nTmp) then
      FListA.Values['ITEMTYPE']:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('RESULT');
    if Assigned(nTmp) then
      FListA.Values['RESULT']:= nTmp.ValueAsString;

  finally
    nXML.Free;
  end;

  if Pos('缓凝',FListA.Values['ITEMNAME']) > 0 then//此水泥名称不完整
  begin
    nStr := 'select D_Value from %s where D_ParamB = ''%s'' and D_Memo = ''%s'' ';
    nStr := Format(nStr,[sTable_SysDict, FListA.Values['ITEMID'],
                                         FListA.Values['ITEMTYPE']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nStr := Fields[0].AsString;
        nStr := StringReplace(nStr,'袋装','',[rfReplaceAll]);
        nStr := StringReplace(nStr,'散装','',[rfReplaceAll]);
        FListA.Values['ITEMNAME'] := Trim(nStr);
      end;
    end;
  end;

  try
    FDBConn.FConn.BeginTrans;

    with FListA do
    begin
      nStr := MakeSQLByStr([
              SF('AX_WEIGHTSTATUS', Values['CMT_WEIGHTSTATUS']),
              SF('AX_COMPANYID', Values['COMPANYID']),
              SF('AX_CUSTOMERID', Values['CUSTACCOUNT']),
              SF('AX_CUSTOMERNAME', Values['CUSTNAME']),
              SF('AX_Destinationcode', Values['DESTINATIONCODE']),
              SF('AX_InventLocationId', Values['INVENTLOCATIONID']),
              SF('AX_ITEMID', Values['ITEMID']),
              SF('AX_ITEMPRICE', Values['ITEMPRICE']),
              SF('AX_PLANQTY', Values['PLANQTY']),
              SF('AX_POST', Values['POST']),
              SF('AX_SALESID', Values['SALESID']),
              SF('AX_SALESLINERECID', Values['SALESLINERECID']),
              SF('AX_TRANSPLANID', Values['TRANSPLANID']),
              SF('AX_TRANSPORTER', Values['TRANSPORTER']),
              SF('AX_VEHICLEID', Values['VEHICLEID']),
              SF('AX_WMSLocationId', Values['WMSLOCATIONID']),
              SF('AX_xtDInventCenterId', Values['XTDINVENTCENTERID']),
              SF('AX_RECVERSION', Values['RECVERSION']),
              SF('AX_PARTITION', Values['PARTITION']),
              SF('AX_CARDID', Values['CARDID']),
              SF('AX_MODE', Values['MODE_']),
              SF('AX_ITEMNAME', Values['ITEMNAME']),
              SF('AX_ITEMTYPE', Values['ITEMTYPE']),
              SF('AX_RESULT', Values['RESULT'])
              ], sTable_AxPlanInfo, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessAXCommander.UpdateYKAmount(
  var nData: string): Boolean;
var nStr, nLID, nCustAcc, nContQuota: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nTRANSPLANID,nDataAreaID:string;
    nYKMouney: Double;
begin
  Result := False;
  FListA.Clear;
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+FIn.FExXml+'</DATA>');
    nNode := nXML.Root;
    if not Assigned(nNode) then
    begin
      WriteLog('预扣金额xml加载失败！'+ FIn.FExXml);
      Exit;
    end;

    nTmp := nNode.NodeByName('TRANSPLANID');
    if Assigned(nTmp) then
      nTRANSPLANID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('DataAreaID');
    if Assigned(nTmp) then
      nDataAreaID:= nTmp.ValueAsString;

  finally
    nXML.Free;
  end;

  if (nTRANSPLANID='') or (nDataAreaID='') then
  begin
    WriteLog('预扣金额数据异常：'+ nTRANSPLANID+'/'+nDataAreaID);
    Exit;
  end;

  nLID:='T'+nTRANSPLANID;
  nStr:='select L_Value*L_Price as L_TotalMoney,L_CusID,L_ContQuota from %s where L_BDAX=''2'' and L_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Bill, nLID]);

  try
    FDBConn.FConn.BeginTrans;

    with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
    begin
      if RecordCount > 0 then
      begin
        nYKMouney := FieldByName('L_TotalMoney').AsFloat;
        nCustAcc := FieldByName('L_CusID').AsString;
        nContQuota:= FieldByName('L_ContQuota').AsString;

        if nContQuota = '1' then
        begin
          nStr:='Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%s) Where A_CID=''%s''';
          nStr:= Format(nStr, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
        end else
        begin
          nStr:='Update %s Set A_FreezeMoney=A_FreezeMoney-(%s) Where A_CID=''%s''';
          nStr:= Format(nStr, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
        end;
        gDBConnManager.WorkerExec(FDBConn, nStr);

        nStr:='Update %s Set L_BDAX=''1'' Where L_ID=''%s'' ';
        nStr:= Format(nStr, [sTable_Bill, nLID]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end
      else
      begin
        WriteLog('查询数据为空：' + nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    WriteLog('业务执行失败：'+nStr);
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessAXCommander.GetTransPriceByLadingType(nID,nDataAreaID,
  nPrice: string): string;
var nStr: string;
begin
  Result := '0';
  nStr:='select Z_Lading from %s where Z_ID=''%s'' and DataAreaID=''%s'' ';
  nStr := Format(nStr, [sTable_ZhiKa, nID, nDataAreaID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), FListA do
  begin
    if RecordCount > 0 then
    begin
       if FieldByName('Z_Lading').AsString = '2' then
         Result := nPrice;
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessAXCommander, sPlug_ModuleBus);
end.
