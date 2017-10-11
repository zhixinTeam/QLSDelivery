{
  by lih 2017-09-14
  功能描述：AX消息管理器
}
unit UMgrAxMsg;

interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UMemDataPool, SyncObjs;

type
  PAXSendDataInfo = ^TAXSendDataInfo;
  TAXSendDataInfo = record
    FCompanyId: string;
    //FProcessflag: string;
    FXTIndexXML: string;
    FXTProcessId: string;
    //FResult: string;
    //FSendNum: string;
    FRefRecid: string;
    Foperation: string;
    FRecId: string;
    FMsgNo: string;
  end;

  PCompanyIdUrl = ^TCompanyIdUrl;
  TCompanyIdUrl = record
    FCompanyId: string;
    FRemoteUrl: string;
    FEnable   : Boolean;
  end;

type
  TAxMsgManager = class;
  TScanAxMsgThread = class(TThread)
  private
    FOwner: TAxMsgManager;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure DoNewScanMsg;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TAxMsgManager);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TSendAxMsgThread = class(TThread)
  private
    FOwner: TAxMsgManager;
    //拥有者
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure BuildDefaultXMLPack;
    //构造XML基本结构
    function GetCompanyID: Pointer;
    procedure DoNewSendAXMsg;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TAxMsgManager);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TAxMsgManager = class(TObject)
  private
    FAXDATA: TList;
    //AX数据列表
    FURLIndx: Integer;
    FURLDATA: TList;
    //远程地址列表
    FIDSendDataInfo: Integer;
    FIDCompanyIdUrl: Integer;
    //数据标识
    FScanThread: TScanAxMsgThread;
    //扫描线程
    FSendThreadCount: Integer;
    //发送线程数量
    FSenders: array of TSendAxMsgThread;
    //发送线程数组
    FSyncCS:TCriticalSection;
    //同步临界变量
  protected
    procedure RegisterDataType;
    //注册数据
    procedure ClearList(nList: TList; nFree: Boolean);
    //清理数据列表
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停
    procedure LoadConfig(const nFile: string);
    //载入配置文件
  end;

var
  gAxMsgManager: TAxMsgManager=nil;
  //全局使用 

implementation

uses
  UWorkerBusinessRemote;

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TAxMsgManager, 'AX消息管理器', nMsg);
end;

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nSdi: PAXSendDataInfo;
    nCiu: PCompanyIdUrl;
begin
  if nFlag = 'AxMsgSDI' then
  begin
    New(nSdi);
    nData := nSdi;
  end else

  if nFlag = 'AxMsgCIU' then
  begin
    New(nCiu);
    nData := nCiu;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
begin
  if nFlag = 'AxMsgSDI' then
  begin
    Dispose(PAXSendDataInfo(nData));
  end else

  if nFlag = 'AxMsgCIU' then
  begin
    Dispose(PCompanyIdUrl(nData));
  end;
end;

constructor TAxMsgManager.Create;
begin
  FScanThread := nil;
  FURLIndx := 0;
  FURLDATA := TList.Create;

  FAXDATA := TList.Create;
  FSyncCS := TCriticalSection.Create;
  RegisterDataType;
  //由内存管理数据
end;

destructor TAxMsgManager.Destroy;
begin
  Stop;
  ClearList(FAXDATA, True);
  ClearList(FURLDATA, True);
  
  FSyncCS.Free;
  inherited;
end;

//注册数据类型
procedure TAxMsgManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('TAxMsgManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
  begin
    FIDSendDataInfo := RegDataType('AxMsgSDI', 'TAXSendDataInfo', OnNew, OnFree, 2);
    FIDCompanyIdUrl := RegDataType('AxMsgCIU', 'TCompanyIdUrl', OnNew, OnFree, 2);
  end;
end;

//清理数据列表
procedure TAxMsgManager.ClearList(nList: TList; nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gMemDataManager.UnLockData(nList[nIdx]);
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

procedure TAxMsgManager.Start;
var
  nIdx:Integer;
begin
  Stop;
  
  if not Assigned(FScanThread) then
    FScanThread := TScanAxMsgThread.Create(self);
  FScanThread.Wakeup;

  SetLength(FSenders, FSendThreadCount);
  for nIdx:= Low(FSenders) to High(FSenders) do
    FSenders[nIdx]:= nil;
  //xxxxx

  for nIdx:= Low(FSenders) to High(FSenders) do
  begin
    if not Assigned(FSenders[nIdx]) then
       FSenders[nIdx]:= TSendAxMsgThread.Create(Self);
    //xxxxx
  end;

  for nIdx:= Low(FSenders) to High(FSenders) do
    FSenders[nIdx].Wakeup;
  //xxxxx
end;

procedure TAxMsgManager.Stop;
var nIdx:Integer;
begin
  if Assigned(FScanThread) then
    FScanThread.StopMe;
  FScanThread:= nil;

  for nIdx:= Low(FSenders) to High(FSenders) do
  begin
    if Assigned(FSenders[nIdx]) then
      FSenders[nIdx].Terminate;
    //xxxxx
  end;
  
  for nIdx:= Low(FSenders) to High(FSenders) do
  begin
    if Assigned(FSenders[nIdx]) then
       FSenders[nIdx].StopMe;
    FSenders[nIdx]:= nil;
  end;
end;

//载入配置文件
procedure TAxMsgManager.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nRoot, nNode, nTmp: TXmlNode;
    nIdx: Integer;
    nCIU: PCompanyIdUrl;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nRoot := nXML.Root.FindNode('Head');

    if not Assigned(nRoot) then
      raise Exception.Create('Invalid UrlConfig Head File.');
    //xxxxx

    nNode := nRoot.NodeByName('SendThreadCount');
    if Assigned(nNode) then
         FSendThreadCount := nNode.ValueAsInteger
    else FSendThreadCount := 3;

    nRoot := nXML.Root.FindNode('Items');
    if not Assigned(nRoot) then
      raise Exception.Create('Invalid UrlConfig Items File.');
    //xxxxx

    for nIdx := 0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText(nNode.Name, 'Item') <> 0 then Continue;
      
      New(nCIU);
      FURLDATA.Add(nCIU);

      with nCIU^ do
      begin
        nTmp := nNode.NodeByName('CompanyId');
        if Assigned(nTmp) then
             FCompanyId:= nTmp.ValueAsString
        else FCompanyId:= '';

        nTmp := nNode.NodeByName('RemoteURL');
        if Assigned(nTmp) then
             FRemoteUrl := nTmp.ValueAsString
        else FRemoteUrl := '';

        FEnable := True;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

constructor TScanAxMsgThread.Create(AOwner:TAxMsgManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;

  FXMLBuilder := TNativeXml.Create; 
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 6 * 1000;
end;

destructor TScanAxMsgThread.Destroy;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;

  FXMLBuilder.Free;
  FWaiter.Free;
  inherited;
end;

procedure TScanAxMsgThread.Wakeup;
begin
  FWaiter.Wakeup();
end;

procedure TScanAxMsgThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup();

  WaitFor;
  Free;
end;

procedure TScanAxMsgThread.Execute;
var
  nErr: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated  then Exit;

    FDBConn := nil;
    try
      with gParamManager.ActiveParam^ do
        FDBConn := gDBConnManager.GetConnection(FDB.FID, nErr);
      //xxxxx

      if not Assigned(FDBConn) then
      begin
        WriteLog(Format('连接数据库失败(DBConn Is Null,Code: %d).', [nErr]));
        Continue;
      end;

      DoNewScanMsg;
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TScanAxMsgThread.DoNewScanMsg;
var
  nIdx:Integer;
  nSQL:string;
  nSDI, nOldSDI:PAXSendDataInfo;
  nRepeat: Boolean;
  nList: TStrings;
begin
  nList := nil;
  with FOwner do
  try
    FSyncCS.Enter;
    nRepeat:= False;
    nList := TStringList.Create; 

    nSQL:= 'select top 1 * from %s where SyncCounter<10 and SyncDone is null';
    nSQL:= Format(nSQL, [sTable_XT_TRANSPLAN]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      for nIdx := 0 to FAXDATA.Count - 1 do
      begin
        nOldSDI:= FAXDATA[nIdx];
        if nOldSDI.FRecId = FieldByName('TRANSPLANID').AsString then
        begin
          nRepeat:= True;
          Break;
        end;
      end;
          
      if not nRepeat then
      begin
        nSDI:= gMemDataManager.LockData(FIDSendDataInfo);
        FAXDATA.Add(nSDI);

        with nSDI^ do
        begin
          FMsgNo := '1';
          FCompanyId := FieldByName('CompanyId').AsString;
          FXTProcessId := 'EDS_0011';
          Foperation := FieldByName('MODE_').AsString;
          FRecId := FieldByName('TRANSPLANID').AsString;

          FXTIndexXML :=
            '<CMT_WEIGHTSTATUS>'+FieldByName('CMT_WEIGHTSTATUS').AsString+'</CMT_WEIGHTSTATUS>'+
            '<COMPANYID>'+FieldByName('COMPANYID').AsString+'</COMPANYID>'+
            '<CUSTACCOUNT>'+FieldByName('CUSTACCOUNT').AsString+'</CUSTACCOUNT>'+
            '<CUSTNAME>'+FieldByName('CUSTNAME').AsString+'</CUSTNAME>'+
            '<DESTINATIONCODE>'+FieldByName('DESTINATIONCODE').AsString+'</DESTINATIONCODE>'+
            '<INVENTLOCATIONID>'+FieldByName('INVENTLOCATIONID').AsString+'</INVENTLOCATIONID>'+
            '<ITEMID>'+FieldByName('ITEMID').AsString+'</ITEMID>'+
            '<ITEMPRICE>'+FieldByName('ITEMPRICE').AsString+'</ITEMPRICE>'+
            '<PLANQTY>'+FieldByName('PLANQTY').AsString+'</PLANQTY>'+
            '<POST>'+FieldByName('POST').AsString+'</POST>'+
            '<SALESID>'+FieldByName('SALESID').AsString+'</SALESID>'+
            '<SALESLINERECID>'+FieldByName('SALESLINERECID').AsString+'</SALESLINERECID>'+
            '<TRANSPLANID>'+FieldByName('TRANSPLANID').AsString+'</TRANSPLANID>'+
            '<TRANSPORTER>'+FieldByName('TRANSPORTER').AsString+'</TRANSPORTER>'+
            '<VEHICLEID>'+FieldByName('VEHICLEID').AsString+'</VEHICLEID>'+
            '<WMSLOCATIONID>'+FieldByName('WMSLOCATIONID').AsString+'</WMSLOCATIONID>'+
            '<XTDINVENTCENTERID>'+FieldByName('XTDINVENTCENTERID').AsString+'</XTDINVENTCENTERID>'+
            '<RECVERSION>'+FieldByName('RECVERSION').AsString+'</RECVERSION>'+
            '<PARTITION>'+FieldByName('PARTITION').AsString+'</PARTITION>'+
            '<CARDID>'+FieldByName('CARDID').AsString+'</CARDID>'+
            '<MODE_>'+FieldByName('MODE_').AsString+'</MODE_>'+
            '<ITEMNAME>'+FieldByName('ITEMNAME').AsString+'</ITEMNAME>'+
            '<ITEMTYPE>'+FieldByName('ITEMTYPE').AsString+'</ITEMTYPE>';
        end;
        
        nSQL:= 'update %s set SyncStart= ''%s'' where TRANSPLANID= ''%s''';
        nSQL:= Format(nSQL, [sTable_XT_TRANSPLAN, FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz', Now), FieldByName('TRANSPLANID').AsString]);
        nList.Add(nSQL);
      end;
    end;

    //nSQL:= 'select top 10 CompanyId, XTProcessId, RefRecid, operation, RecId from %s where Processflag=0 order by COMPANYID';
    nSQL:= 'select top 1 CompanyId, XTProcessId, RefRecid, operation, RecId from %s where SyncCounter<10 and SyncDone is null';
    nSQL:= Format(nSQL,[sTable_XT_MsgTables]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin

      nIdx := 0;
      //First;
      //while not Eof do
      begin
        for nIdx := 0 to FAXDATA.Count - 1 do
        begin
          nOldSDI:= FAXDATA[nIdx];
          if nOldSDI.FRecId = FieldByName('RecId').AsString then Exit;
        end;
          
        nSDI:= gMemDataManager.LockData(FIDSendDataInfo);
        FAXDATA.Add(nSDI);
        
        with nSDI^ do
        begin
          FMsgNo := '0';
          FCompanyId := FieldByName('CompanyId').AsString;
          FXTProcessId := FieldByName('XTProcessId').AsString;
          FRefRecid := FieldByName('RefRecid').AsString;
          Foperation := FieldByName('operation').AsString;
          FRecId := FieldByName('RecId').AsString;
        end;
        
        nSQL:= 'update %s set SyncStart= ''%s'' where RecId= ''%s''';
        nSQL:= Format(nSQL, [sTable_XT_MsgTables, FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz', Now), FieldByName('RecId').AsString]);
        nList.Add(nSQL);
        //Next;
      end;
    end;

    if nList.Count> 0 then
    try
      FDBConn.FConn.BeginTrans;
      for nIdx := 0 to nList.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, nList[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    nList.Free;
    FOwner.FSyncCS.Leave;
  end;
  WriteLog('ScanAxMsgThread');
end;

//------------------------------------------------------------------------------
constructor TSendAxMsgThread.Create(AOwner:TAxMsgManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;
  
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;

  FXMLBuilder := TNativeXml.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1 * 1000;
end;

destructor TSendAxMsgThread.Destroy;
begin 
  FListA.Free;
  FListB.Free;
  FListC.Free;

  FXMLBuilder.Free;
  FWaiter.Free;
  inherited;
end;

procedure TSendAxMsgThread.Wakeup;
begin
  FWaiter.Wakeup();
end;

procedure TSendAxMsgThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup();

  WaitFor;
  Free;
end;

procedure TSendAxMsgThread.Execute;
var nErr: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated  then Exit;

    DoNewSendAXMsg;
    //send data
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2017-09-28
//Desc: 默认XML参数
procedure TSendAxMsgThread.BuildDefaultXMLPack;
begin
  with FXMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
  end;
end;

//Date: 2017-09-28
//Desc: 获取工厂信息
function TSendAxMsgThread.GetCompanyID: Pointer;
begin
  with FOwner do
  begin
    if FURLIndx >= FURLDATA.Count then
      raise Exception.Create('URLDATA is invalid.');
    //xxxxx

    Result := FURLDATA[FURLIndx];
    Inc(FURLIndx);

    if FURLIndx >= FURLDATA.Count then
      FURLIndx := 0;
    //reset index
  end;
end;

procedure TSendAxMsgThread.DoNewSendAXMsg;
var nIdx:Integer;
    nBool: Boolean;
    nCIU: PCompanyIdUrl;
    nSDI: PAXSendDataInfo;
    nData: TAXSendDataInfo;
    nOut: TWorkerBusinessCommand;
begin
  with FOwner do
  try
    FSyncCS.Enter;
    //lock first
    BuildDefaultXMLPack;
    //init xml

    nCIU := GetCompanyId;
    nBool := False;
    nIdx := 0;
    
    while nIdx < FAXDATA.Count do
    begin
      nSDI:= FAXDATA[nIdx];
      //data item
      
      if CompareText(nCIU.FCompanyId, nSDI.FCompanyId) = 0 then
      begin
        nData := nSDI^;
        //copy data
        
        with nData, FXMLBuilder.Root.NodeNew('Item') do
        begin
          NodeNew('CompanyId').ValueAsString   := FCompanyId;
          NodeNew('XTINDEXXML').ValueAsString  := FXTIndexXML;
          NodeNew('XTProcessId').ValueAsString := FXTProcessId;
          NodeNew('RefRecid').ValueAsString    := FRefRecid;
          NodeNew('operation').ValueAsString   := Foperation;
          NodeNew('RecId').ValueAsString       := FRecId;
        end;

        gMemDataManager.UnLockData(nSDI);
        FAXDATA.Delete(nIdx);
        
        nBool := True;
        Break;
      end else
      begin
        Inc(nIdx);
        //next data
      end;
    end;
  finally
    FSyncCS.Leave;
  end;

  if nBool then
  begin
    CallRemoteWorker(sCLI_BusinessMessage, FXMLBuilder.WriteToString, nCIU.FRemoteUrl, nData.FMsgNo, @nOut);
    WriteLog('SendAxMsgThread');
  end;
end;

initialization
  gAxMsgManager := nil;
finalization
  FreeAndNil(gAxMsgManager);
end.
 