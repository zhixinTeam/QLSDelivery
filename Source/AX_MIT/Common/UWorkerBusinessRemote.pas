{
  by lih 2017-09-18
  描述：远程调用工厂MIT
}
unit UWorkerBusinessRemote;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, Variants, NativeXml, UWorkerBusiness,
  UBusinessWorker, UBusinessPacker, UBusinessConst, UMgrChannel;

type
  TFactoryWorkerBase = class(TMITDBWorker)
  protected
    FChannel: PChannelItem;
    //数据通道
    FXML: TNativeXml;
    //数据解析
    FCompanyID: string;
    //工厂标识
    FListA,FListB,FListC,FListD: TStrings;
    //数据列表
    function DoMITWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterCallMIT(var nData: string): Boolean; virtual;
    function DoAfterCallMITDone(var nData: string): Boolean; virtual;
    //调用工厂MIT
  public
    constructor Create; override;
    destructor Destroy; override;
    //创建释放
    function DoDBWork(var nData: string): Boolean; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
    //执行业务
  end;

  TSendAXMsgWorker = class(TFactoryWorkerBase)
  protected
    FIn: TWorkerMessageData;
    FOut: TWorkerMessageData;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoMITWork(var nData: string): Boolean; override; 
  public                                       
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
  end;


function CallRemoteWorker(const nWorkerName: string; const nData,nExt,nMsgNo: string;
 const nOut: PWorkerMessageData; const nCmd: Integer = 0): Boolean;
//入口函数

implementation

uses
  ULibFun, UMgrDBConn, UChannelChooser, USysDB, UFormCtrl, USysLoger, MIT_Service_Intf;

//Date: 2017-09-18
//Parm: 对象;命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallRemoteWorker(const nWorkerName: string; const nData,nExt,nMsgNo: string;
 const nOut: PWorkerMessageData; const nCmd: Integer): Boolean;
var nStr: string;
    nIn: TWorkerMessageData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FMsgNO := nMsgNo;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessMessage);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(nWorkerName);
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

//------------------------------------------------------------------------------
constructor TFactoryWorkerBase.Create;
begin
  inherited;
  FXML := TNativeXml.Create;

  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
end;

destructor TFactoryWorkerBase.Destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  
  FreeAndNil(FXML);
  inherited;
end;

//Date: 2017-09-18
//Parm: 数据;结果
//lih: 数据业务调用完毕,执行结果
function TFactoryWorkerBase.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;

  Result := DoAfterCallMIT(nData);
  if not Result then Exit;

  if FDataOut.FResult then
  begin
    Result := DoAfterCallMITDone(nData);
    if not Result then Exit;
  end; //business is done

  if FDataOut.FResult then
       FDataIn.FKEY := sFlag_Yes
  else FDataIn.FKEY := sFlag_No;
end;

//Date: 2017-09-18
//Parm: 入参数据
//lih: 工厂MIT调用结束后
function TFactoryWorkerBase.DoAfterCallMIT(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2017-09-18
//Parm: 入参数据
//Desc: 工厂MIT调用成功后
function TFactoryWorkerBase.DoAfterCallMITDone(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2017-09-18
//Parm: 入参数据
//lih: 获取连接工厂MIT时所需的资源
function TFactoryWorkerBase.DoDBWork(var nData: string): Boolean;
var nInit: Int64;
  nIn:TWorkerMessageData;
  nPacker: TBusinessPackerBase;
begin
  FChannel := nil;
  try
    Result := False;
    //default return
    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessMessage);
    nPacker.InitData(@nIn, True, False);
    //init
    nPacker.UnPackIn(nData, @nIn);
    
    FChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FChannel) then
    begin
      nData := '连接工厂服务失败(BUS-MIT No Channel).';
      Exit;
    end;

    with FChannel^ do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      if nIn.FExtParam <> '' then
        FHttp.TargetURL := nIn.FExtParam
      else
        FHttp.TargetURL := gChannelChoolser.ActiveURL;

      nInit := GetTickCount;
      Result := DoMITWork(nData);
      WriteLog(Format('对象: %s 执行: %d毫秒', [FunctionName, GetTickCount-nInit]));
    except
      on E: Exception do
      begin
        nData := '对象[ %s ]执行业务异常.';
        nData := Format(nData, [FunctionName]);
        WriteLog(E.Message);
      end;
    end;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gChannelManager.ReleaseChannel(FChannel);
  end;
end;

//------------------------------------------------------------------------------
class function TSendAXMsgWorker.FunctionName: string;
begin
  Result := sCLI_BusinessMessage;
end;

function TSendAXMsgWorker.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessMessage;
   cWorker_GetMITName : Result := sBus_BusinessMessage;
  end;
end;

procedure TSendAXMsgWorker.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TSendAXMsgWorker.DoMITWork(var nData: string): Boolean;
var nStr: string;
    nNode,nTmp: TXmlNode;
    nPacker: TBusinessPackerBase;
    nOut: TWorkerMessageData;
begin
  Result := False;
  nStr := nData;

  Result := ISrvBusiness(FChannel.FChannel).Action(GetFlagStr(cWorker_GetMITName), nData);
  //remote call

  //nPacker.UnPackOut(nData, @nOut);
  {$IFDEF DEBUG}
  WriteLog('TSendAXMsgWorker Send::: ' + nStr);
  WriteLog('TSendAXMsgWorker Result::: ' + nOut.FData);
  {$ENDIF}
  {if Result then
  begin
    FXML.ReadFromString(nOut.FData);
    for i := 0 to FXML.Root.NodeCount -1 do
    begin
      if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
      begin
        nData := 'AX返回无效节点(DATA.Item Null).';
        Exit;
      end;

      nNode := nNode.NodeByName('Item');
      Result := nNode.NodeByName('MsgResult').ValueAsString = '1';
      nTmp := nNode.FindNode('RecId');

      if Assigned(nTmp) then
           nData := nTmp.ValueAsString
      else nData := '未描述的错误.';
    end;
  end; }
end;

function TSendAXMsgWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
var nStr, nZID, nSID: string;
    nHasSync: Boolean;
    nVal: Double;
    nIdx: Integer;
    nNode,nTmp: TXmlNode;
begin
  Result := inherited DoAfterDBWork(nData, nResult);
  //parent default

  FXML.ReadFromString(FIn.FData);
  for nIdx := 0 to FXML.Root.NodeCount - 1 do
  begin
    nNode := FXML.Root.FindNode('Item');
    if Assigned(nNode) then
    begin
      nTmp := nNode.FindNode('RecId');
      if Assigned(nTmp) then nZID:= nZID + ',' +''''+ nTmp.ValueAsString+'''';
    end;
  end;
  if Length(nZID) < 1 then Exit;
  nZID := Copy(nZID, 2, Length(nZID)-1);
  
  if FIn.FBase.FMsgNO='0' then
  begin
    if nResult then //成功
    begin
      nStr := 'Select * From %s Where RecId in (%s)';
      nStr := Format(nStr, [sTable_XT_MsgTables, nZID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nData := 'AX变更消息 [%s] 信息已丢失!';
          nData := Format(nData, [FIn.FData]);
          Exit;
        end;
      end;

      FDBConn.FConn.BeginTrans;
      try
        nStr := 'Update %s Set SyncCounter=SyncCounter+1, SyncDone=''%s'' Where RecId in (%s)';
        nStr := Format(nStr, [sTable_XT_MsgTables, FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz',Now), nZID]);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        FDBConn.FConn.CommitTrans;
        //Finished
      except
        FDBConn.FConn.RollbackTrans;
        nData := Format('AX变更消息[ %s ] 保存信息失败!', [FIn.FData]);
        Exit;
      end;
    end else
    begin
      nStr := 'Update %s Set SyncCounter=SyncCounter+1 Where RecId in (%s)';
      nStr := Format(nStr, [sTable_XT_MsgTables, nZID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //write status
    end;
  end else
  if FIn.FBase.FMsgNO = '1' then
  begin
    if nResult then //成功
    begin
      nStr := 'Select * From %s Where TRANSPLANID in (%s)';
      nStr := Format(nStr, [sTable_XT_TRANSPLAN, nZID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nData := 'AX变更消息 [%s] 信息已丢失!';
          nData := Format(nData, [FIn.FData]);
          Exit;
        end;
      end;

      FDBConn.FConn.BeginTrans;
      try
        nStr := 'Update %s Set SyncCounter=SyncCounter+1, SyncDone=''%s'' Where TRANSPLANID in (%s)';
        nStr := Format(nStr, [sTable_XT_TRANSPLAN, FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz',Now), nZID]);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        FDBConn.FConn.CommitTrans;
        //Finished
      except
        FDBConn.FConn.RollbackTrans;
        nData := Format('AX变更消息[ %s ] 保存信息失败!', [FIn.FData]);
        Exit;
      end;
    end else
    begin
      nStr := 'Update %s Set SyncCounter=SyncCounter+1 Where TRANSPLANID in (%s)';
      nStr := Format(nStr, [sTable_XT_TRANSPLAN, nZID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //write status
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TSendAXMsgWorker, sPlug_ModuleBus);

end.
 