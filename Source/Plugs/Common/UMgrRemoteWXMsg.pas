{*******************************************************************************
  作者: fendou116688@163.com 2014/12/1
  描述: 微信公众平台模板消息发送
*******************************************************************************}
unit UMgrRemoteWXMsg;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdComponent, IdTCPConnection,
  IdTCPClient, IdUDPServer, IdGlobal, IdSocketHandle, USysLoger, UWaitItem,
  ULibFun, UBase64;

type
  PWXDataBase = ^TWXDataBase;
  TWXDataBase = record
    FCommand   : Byte;     //命令字
    FDataLen   : Word;     //数据长
  end;

  PWXTemplateMsg = ^TWXTemplateMsg;
  TWXTemplateMsg = record
    FBase      : TWXDataBase;
    FData      : string;
  end;

const
  cWXCmd_SendMsg  = $12;  //
  cWXBus_OutFact  = 'OUTFACT';
  cWXBus_MakeCard = 'MAKECARD';
  cSizeWXDataBase = SizeOf(TWXDataBase);
  
type
  TWXPlatFormItem = record
    FID        : string;
    FName      : string;
    FHost      : string;
    FPort      : Integer;
    FEnable    : Boolean;
  end;

  TWXPlatFormHelper = class;
  TTWXPlatFormConnector = class(TThread)
  private
    FOwner: TWXPlatFormHelper;
    //拥有者
    FBuffer: TList;
    //发送缓冲
    FWaiter: TWaitObject;
    //等待对象
    FClient: TIdTCPClient;
    //网络对象
  protected
    procedure DoExuecte;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TWXPlatFormHelper);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TWXPlatFormHelper = class(TObject)
  private
    FHost: TWXPlatFormItem;
    FPlatConnector: TTWXPlatFormConnector;
    //发送模版数据对象
    FBuffData: TList;
    //临时缓冲
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    procedure ClearBuffer(const nList: TList);
    //清理缓冲
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartPlatConnector;
    procedure StopPlatConnector;
    //启停读取
    procedure WXSendMsg(const nData: string); overload;
    //发送数据
    procedure WXSendMsg(const nBusType, nBusData: string); overload;
  end;

var
  gWXPlatFormHelper: TWXPlatFormHelper = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TWXPlatFormHelper, '微信模板消息服务', nEvent);
end;

constructor TWXPlatFormHelper.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TWXPlatFormHelper.Destroy;
begin
  StopPlatConnector;
  ClearBuffer(FBuffData);
  FBuffData.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TWXPlatFormHelper.ClearBuffer(const nList: TList);
var nIdx: Integer;
    nBase: PWXDataBase;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nBase := nList[nIdx];

    case nBase.FCommand of
     cWXCmd_SendMsg : Dispose(PWXTemplateMsg(nBase));
    end;

    nList.Delete(nIdx);
  end;
end;

procedure TWXPlatFormHelper.StartPlatConnector;
begin
  if not Assigned(FPlatConnector) then
    FPlatConnector := TTWXPlatFormConnector.Create(Self);
  if FHost.FEnable then FPlatConnector.WakupMe;
end;

procedure TWXPlatFormHelper.StopPlatConnector;
begin
  if Assigned(FPlatConnector) then
    FPlatConnector.StopMe;
  FPlatConnector := nil;
end;

//Date: 2014/12/1
//Parm:
//Desc:
procedure TWXPlatFormHelper.WXSendMsg(const nData: string);
var nIdx: Integer;
    nPtr: PWXTemplateMsg;
    nBase: PWXDataBase;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nBase := FBuffData[nIdx];
      if nBase.FCommand <> cWXCmd_SendMsg then Continue;

      nPtr := PWXTemplateMsg(nBase);
      if CompareText(nData, nPtr.FData) = 0 then Exit;
    end;

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCommand := cWXCmd_SendMsg;
    nPtr.FData := EncodeBase64(nData);

    if Assigned(FPlatConnector) and FHost.FEnable then
      FPlatConnector.WakupMe;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014/12/1
//Parm: 业务类型;业务数据
//Desc: 发送模板消息
procedure TWXPlatFormHelper.WXSendMsg(const nBusType, nBusData: string);
var nIdx: Integer;
    nPtr: PWXTemplateMsg;
    nData: string;nBase: PWXDataBase;
begin
  FSyncLock.Enter;
  try
    nData := nBusType + '#' + nBusData;
    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nBase := FBuffData[nIdx];
      if nBase.FCommand <> cWXCmd_SendMsg then Continue;

      nPtr := PWXTemplateMsg(nBase);
      if CompareText(nData, nPtr.FData) = 0 then Exit;
    end;

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCommand := cWXCmd_SendMsg;
    nPtr.FData := EncodeBase64(nData);

    if Assigned(FPlatConnector) and FHost.FEnable  then
      FPlatConnector.WakupMe;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 载入nFile配置文件
procedure TWXPlatFormHelper.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('item');

    with FHost do
    begin
      FID    := nNode.NodeByName('id').ValueAsString;
      FName  := nNode.NodeByName('name').ValueAsString;
      FHost  := nNode.NodeByName('ip').ValueAsString;
      FPort  := nNode.NodeByName('port').ValueAsInteger;

      nTmp := nNode.FindNode('enable');
      if Assigned(nTmp) then
            FEnable := nTmp.ValueAsString <> '0'
      else  FEnable := False;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TTWXPlatFormConnector.Create(AOwner: TWXPlatFormHelper);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;
  
  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor TTWXPlatFormConnector.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FOwner.ClearBuffer(FBuffer);
  FBuffer.Free;

  FWaiter.Free;
  inherited;
end;

procedure TTWXPlatFormConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TTWXPlatFormConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TTWXPlatFormConnector.Execute;
var nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated or (not FOwner.FHost.FEnable) then Exit;

    try
      if not FClient.Connected then
      begin
        FClient.Host := FOwner.FHost.FHost;
        FClient.Port := FOwner.FHost.FPort;
        FClient.Connect;
      end;
    except
      WriteLog('连接微信模版消息发送服务失败.');
      FClient.Disconnect;
      Continue;
    end;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        FBuffer.Add(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    try
      DoExuecte;
      FOwner.ClearBuffer(FBuffer);
    except
      FOwner.ClearBuffer(FBuffer);
      FClient.Disconnect;
      
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      raise;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TTWXPlatFormConnector.DoExuecte;
var nIdx: Integer;
    nBuf,nTmp: TIdBytes;
    nPBase: PWXDataBase;
begin
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nPBase := FBuffer[nIdx];

    if nPBase.FCommand = cWXCmd_SendMsg then
    begin
      SetLength(nTmp, 0);
      nTmp := ToBytes(PWXTemplateMsg(nPBase).FData);
      nPBase.FDataLen := Length(nTmp);

      nBuf := RawToBytes(nPBase^, cSizeWXDataBase);
      AppendBytes(nBuf, nTmp);
      FClient.Socket.Write(nBuf);
    end;
  end;  
end;

initialization
  gWXPlatFormHelper := TWXPlatFormHelper.Create;
finalization
  FreeAndNil(gWXPlatFormHelper);
end.

 