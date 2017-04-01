{*******************************************************************************
  作者: fendou116688@163.com 2016-02-27
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessDuanDao;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusiness, BPM2ERPService;

type
  TWorkerBusinessDuanDao = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveDDCard(var nData: string): Boolean;
    function LogoffDDCard(var nData: string): Boolean;

    function GetPostDDItems(var nData: string): Boolean;
    //获取岗位短倒单
    function SavePostDDItems(var nData: string): Boolean;
    //保存岗位短倒单
    function AXSyncDuanDao(var nData: string): Boolean;
    //同步单据
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//------------------------------------------------------------------------------
class function TWorkerBusinessDuanDao.FunctionName: string;
begin
  Result := sBus_BusinessDuanDao;
end;

constructor TWorkerBusinessDuanDao.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessDuanDao.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessDuanDao.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessDuanDao.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessDuanDao.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveDDCard        : Result := SaveDDCard(nData);
   cBC_LogoffDDCard      : Result := LogoffDDCard(nData);
   cBC_GetPostDDs        : Result := GetPostDDItems(nData);
   cBC_SavePostDDs       : Result := SavePostDDItems(nData);
   cBC_AXSyncDuanDao     : Result := AXSyncDuanDao(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------ 
//Date: 2016-02-27
//Parm: 短倒单号[FIn.FData]
//Desc: 同步短倒单到AX
function TWorkerBusinessDuanDao.AXSyncDuanDao(var nData: string): Boolean;
var nID,nIdx: Integer;
    nStr,nWeightMan:string;
    nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nsWeightTime:string;
begin
  Result := False;
  nSQL := 'select * From %s where T_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_Transfer,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的短倒磅单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',FieldByName('T_MDate').AsDateTime);
    if nsWeightTime<>'' then
    begin
      nsWeightTime:=Copy(nsWeightTime,12,Length(nsWeightTime)-11);
      WriteLog(nsWeightTime);
    end;
    nStr := '<PRIMARY>';
    nStr := nStr+'<PurchId>'+FieldByName('T_BID').AsString+'</PurchId>';
    nStr := nStr+'<PurchLineRecid>'+FieldByName('T_BRecID').AsString+'</PurchLineRecid>';
    nStr := nStr+'<DlvModeId></DlvModeId>';
    nStr := nStr+'<applyvehicle></applyvehicle>';
    nStr := nStr+'<TareWeight>'+FieldByName('T_PValue').AsString+'</TareWeight>';
    nStr := nStr+'<GrossWeight>'+FieldByName('T_MValue').AsString+'</GrossWeight>';
    nStr := nStr+'<Netweight>'+FieldByName('T_Value').AsString+'</Netweight>';
    nStr := nStr+'<CMTCW></CMTCW>';
    nStr := nStr+'<VehicleNum>'+FieldByName('T_Truck').AsString+'</VehicleNum>';
    nStr := nStr+'<WeightMan>'+FieldByName('T_MMan').AsString+'</WeightMan>';
    nStr := nStr+'<WeightTime>'+nsWeightTime+'</WeightTime>';
    nStr := nStr+'<WeightDate>'+FieldByName('T_MDate').AsString+'</WeightDate>';
    nStr := nStr+'<description></description>';
    nStr := nStr+'<WeighingNum>'+FieldByName('T_ID').AsString+'</WeighingNum>';
    nStr := nStr+'<tabletransporter></tabletransporter>';
    nStr := nStr+'<COMPANYID>'+gCompanyAct+'</COMPANYID>';
    nStr := nStr+'<TransportBill></TransportBill>';
    nStr := nStr+'<TransportBillQty></TransportBillQty>';
    nStr := nStr+'</PRIMARY>';
    //----------------------------------------------------------------------------
    //nStr :=UTF8Encode(nStr);
    //{$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    //{$ENDIF}
    try
      nService:=GetBPM2ERPServiceSoap(True,'',nil);
      nMsg:=nService.WRZS2ERPInfo('WRZS_003',nStr,'000');
      if nMsg=1 then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('T_ID').AsString+'同步成功');
        nSQL:='update %s set T_DDAX=''1'',T_SyncNum=T_SyncNum+1 where T_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_OrderDtl,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('T_ID').AsString+'同步失败');
        nSQL:='update %s set T_SyncNum=T_SyncNum+1 where T_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_OrderDtl,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      nStr := '同步采购磅单数据到AX系统失败.';
      raise Exception.Create(nStr);
    end;
  finally

  end;
end;

//Date: 2016/2/27
//Parm: 
//Desc: 短倒业务办理磁卡
function TWorkerBusinessDuanDao.SaveDDCard(var nData: string): Boolean;
var nSQL: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nSQL := 'Update %s Set T_Card=''%s'' Where T_Truck =''%s''';
      nSQL := Format(nSQL, [sTable_Truck, FIn.FExtParam, FIn.FData]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FIn.FData),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nSQL := Format('C_Card=''%s''', [FIn.FExtParam]);
      nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FIn.FData),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016/2/27
//Parm: 
//Desc: 短倒业务注销磁卡
function TWorkerBusinessDuanDao.LogoffDDCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set T_Card=Null Where T_Card=''%s''';
    nStr := Format(nStr, [sTable_Truck, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
            'Where C_Card=''%s''';
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
function TWorkerBusinessDuanDao.GetPostDDItems(var nData: string): Boolean;
var nStr: string;
    nBills: TLadingBillItems;
begin
  Result := False;

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
      nData := '磁卡[ %s ]当前状态为[ %s ],无法使用.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '磁卡[ %s ]已被冻结,无法使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select T_Truck, T_MatePID, T_MateID, T_MateName, T_Card,' +
          'T_PrePValue, T_PrePMan, T_PrePTime, ' +
          'T_SrcAddr, T_DestAddr From $Truck b ';
  nStr := nStr + 'Where T_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$Truck', sTable_Truck),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '磁卡号[ %s ]没有倒运车辆.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('T_MateID').AsString;
      FCusName    := FieldByName('T_SrcAddr').AsString + '-->' +
                     FieldByName('T_DestAddr').AsString;
      FTruck      := FieldByName('T_Truck').AsString;

      FType       := SFlag_San;
      FStockNo    := FieldByName('T_MateID').AsString;
      FStockName  := FieldByName('T_MateName').AsString;

      FCard       := FieldByName('T_Card').AsString;
      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      with FPData do
      begin
        FDate   := FieldByName('T_PrePTime').AsDateTime;
        FValue  := FieldByName('T_PrePValue').AsFloat;
        FOperator := FieldByName('T_PrePMan').AsString;

        if FValue <=0 then FNextStatus := sFlag_TruckBFP;
      end;

      FMemo         := FieldByName('T_SrcAddr').AsString;
      FYSValid      := FieldByName('T_DestAddr').AsString;
      
      FSelected := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessDuanDao.SavePostDDItems(var nData: string): Boolean;
var nSQL: string;
    nInt, nIdx: Integer;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //解析数据

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了短倒业务合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //预置皮重
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Other),
            SF('P_Truck', FTruck),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '临时'),
            SF('P_PModel', sFlag_PoundLS),
            SF('P_Status', ''),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_PrePValue', FPData.FValue, sfVal),
              SF('T_PrePTime', sField_SQLServer_Now, sfVal),
              SF('T_PrePMan', FIn.FBase.FFrom.FUser)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('P_ID', FOut.FData),
              SF('P_Type', sFlag_DuanDao),
              SF('P_Truck', FTruck),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', DateTime2Str(FPData.FDate)),
              SF('P_PMan', FPData.FOperator),
              SF('P_PStation', FPData.FStation),
              SF('P_MValue', FMData.FValue, sfVal),
              SF('P_MDate', sField_SQLServer_Now, sfVal),
              SF('P_MMan', FIn.FBase.FFrom.FUser),
              SF('P_MStation', FMData.FStation),

              SF('P_FactID', FFactory),
              SF('P_Direction', '短倒'),
              SF('P_PModel', sFlag_PoundPD),
              SF('P_Status', ''),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_ID', nOut.FData),
              SF('T_Card', FCard),
              SF('T_Truck', FTruck),
              SF('T_PID', FOut.FData),
              SF('T_SrcAddr', FMemo),
              SF('T_DestAddr', FYSValid),

              SF('T_PValue', FPData.FValue, sfVal),
              SF('T_PDate', DateTime2Str(FPData.FDate)),
              SF('T_PMan', FPData.FOperator),
              SF('T_MValue', FMData.FValue, sfVal),
              SF('T_MDate', sField_SQLServer_Now, sfVal),
              SF('T_MMan', FIn.FBase.FFrom.FUser),

              SF('T_Type', FType),
              SF('T_StockNo', FStockNo),
              SF('T_StockName', FStockName),
              SF('T_Man', FIn.FBase.FFrom.FUser),
              SF('T_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Transfer, '', True);
      FListA.Add(nSQL);
    end;
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
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessDuanDao.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
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

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessDuanDao, sPlug_ModuleBus);
end.
