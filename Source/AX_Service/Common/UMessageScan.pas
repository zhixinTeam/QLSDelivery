{*******************************************************************************
作者: juner11212436@163.com 2017/9/15
描述: 消息表扫描线程
*******************************************************************************}
unit UMessageScan;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBusiness ;

const
  get_AX_SaleOrder           = 'EDS_0001';
  get_AX_SaleOrderLine       = 'EDS_0002';
  get_AX_SupAgreement        = 'EDS_0003';
  get_AX_CreLimCust          = 'EDS_0004';
  get_AX_CreLimCusCont       = 'EDS_0005';
  get_AX_SalesContract       = 'EDS_0008';
  get_AX_SalesContLine       = 'EDS_0010';
  get_AX_VehicleNo           = 'EDS_0009';
  get_AX_PurOrder            = 'EPS_0001';
  get_AX_PurOrdLine          = 'EPS_0002';
  get_AX_Customer            = 'EDB_0006';
  get_AX_Providers           = 'EDB_0007';
  get_AX_Materails           = 'EDB_0008';
  get_AX_ThInfo              = 'EDS_0011';
  get_AX_YKAmount            = 'EDS_0011';
type
  TMessageScan = class;
  TMessageScanThread = class(TThread)
  private
    FOwner: TMessageScan;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    function GetOnLineModel: string;
    //获取在线模式
    function DoWork(var nProcessId, nCompId, nRecordId, nExXml: string): Boolean;
    //根据业务标识执行具体业务
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TMessageScan);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TMessageScan = class(TObject)
  private
    FThread: TMessageScanThread;
    //扫描线程
  public
    FSyncTime:Integer;
    //设定同步次数阀值
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
    procedure LoadConfig(const nFile:string);//载入配置文件
  end;

var
  gMessageScan: TMessageScan = nil;
  //全局使用


implementation
procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TMessageScan, 'SA消息扫描', nMsg);
end;

constructor TMessageScan.Create;
begin
  FThread := nil;
end;

destructor TMessageScan.Destroy;
begin
  Stop;
  inherited;
end;

procedure TMessageScan.Start;
begin
  if not Assigned(FThread) then
    FThread := TMessageScanThread.Create(Self);
  FThread.Wakeup;
end;

procedure TMessageScan.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//载入nFile配置文件
procedure TMessageScan.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      FSyncTime:= StrToInt(nNode.NodeByName('SyncTime').ValueAsString);
    except
      FSyncTime:= 5;
    end;
    gCompanyAct:= nNode.NodeByName('CompanyAct').ValueAsString;
    nTmp := nNode.NodeByName('URLAddr');
    if Assigned(nTmp) then
      gURLAddr := nTmp.ValueAsString
    else
      gURLAddr := '';
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TMessageScanThread.Create(AOwner: TMessageScan);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 10*1000;

  FSyncLock := TCrossProcWaitObject.Create('AXMIT_MessageScan');
  //process sync
end;

destructor TMessageScanThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TMessageScanThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TMessageScanThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMessageScanThread.Execute;
var nErr, nSuccessCount, nFailCount, nSyncTime: Integer;
    nStr: string;
    nXTProcessId,nRecid,nCompanyId,nXtIndexXml:string;
    nResult : Boolean;
    nInit: Int64;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      nStr:= 'select top 100 * from %s';
      nStr:= Format(nStr,[sTable_AxMsgList]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
          Continue;
        //无新消息
        nSuccessCount := 0;
        nFailCount := 0;
        WriteLog('共查询到'+ IntToStr(RecordCount) + '条消息，开始同步...');
        nInit := GetTickCount;

        First;

        while not Eof do
        begin
          nXTProcessId:= FieldByName('AX_ProcessId').AsString;
          nRecid:= FieldByName('AX_Recid').AsString;
          nCompanyId:= FieldByName('AX_CompanyId').AsString;
          nSyncTime:= FieldByName('AX_SyncTime').AsInteger;
          nXtIndexXml := FieldByName('AX_XtIndexXml').AsString;

          FDBConn.FConn.BeginTrans;
          try
            nResult := DoWork(nXTProcessId, nCompanyId, nRecid, nXtIndexXml);
            //根据不同业务执行具体业务

            if nResult then
            begin
              nStr := 'Delete from %s where AX_ProcessId = ''%s'' and AX_RecId = ''%s'' ';
              nStr:= Format(nStr,[sTable_AxMsgList, nXTProcessId, nRecid]);
              gDBConnManager.WorkerExec(FDBConn, nStr);
              //最后进行删除
              Inc(nSuccessCount);
            end
            else
            begin
              if nSyncTime > gMessageScan.FSyncTime then
              begin
                nStr := 'Delete from %s where AX_ProcessId = ''%s'' and AX_RecId = ''%s'' ';
                nStr:= Format(nStr,[sTable_AxMsgList, nXTProcessId, nRecid]);
                gDBConnManager.WorkerExec(FDBConn, nStr);
                WriteLog(nXTProcessId+'同步次数：'+IntToStr(nSyncTime)+'，进行删除操作...');
              end
              else
              begin
                nStr := 'Update %s Set AX_SyncTime = AX_SyncTime + 1 where AX_ProcessId = ''%s'' and AX_RecId = ''%s'' ';
                nStr:= Format(nStr,[sTable_AxMsgList, nXTProcessId, nRecid]);
                gDBConnManager.WorkerExec(FDBConn, nStr);
              end;
              Inc(nFailCount);
            end;
            FDBConn.FConn.CommitTrans;
          except
            if FDBConn.FConn.InTransaction then
              FDBConn.FConn.RollbackTrans;
          end ;
          WriteLog('第'+IntToStr(RecNo)+'条数据处理完成！业务ID为:'+nXTProcessId);
          Next;
        end;
      end;
      WriteLog(IntToStr(nSuccessCount) + '条消息同步成功，'
                + IntToStr(nFailCount) + '条消息同步失败，'
                + '耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//获取在线模式
function TMessageScanThread.GetOnLineModel: string;
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
    WriteLog('OnLineModel: '+Result);
  end;
end;

function TMessageScanThread.DoWork(var nProcessId, nCompId,
  nRecordId, nExXml: string): Boolean;
var  nOut: TWorkerBusinessAXCommand;
begin
  Result := False;
  if nProcessId = get_AX_SaleOrder then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXSalesOrder,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_SaleOrderLine then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXSalesOrdLine,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_SupAgreement then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXSupAgreement,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_CreLimCust then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXCreLimCust,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_CreLimCusCont then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXCreLimCusCont,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_SalesContract then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXSalesCont,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_SalesContLine then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXSalesContLine,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_VehicleNo then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXVehicleNo,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_PurOrder then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXPurOrder,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_PurOrdLine then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXPurOrdLine,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_Customer then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXCustNo,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_Providers then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXProvider,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_Materails then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXMaterails,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_ThInfo then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXThInfo,nCompId,nRecordId,nExXml,@nOut);
  end
  else
  if nProcessId = get_AX_YKAmount then
  begin
    Result:= TWorkerBusinessAXCommander.CallMe(cBC_AXYKAmount,nCompId,nRecordId,nExXml,@nOut);
  end
  else
    WriteLog('业务代码'+nProcessId+'无效！');
end;

initialization
  gMessageScan := nil;
finalization
  FreeAndNil(gMessageScan);
end.

