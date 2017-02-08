{*******************************************************************************
  作者: dmzn@163.com 2012-09-07
  描述: 喷码机(驱动)管理器
*******************************************************************************}
unit UMgrCodePrinter;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdGlobal,
  IdTCPConnection, IdTCPClient, NativeXml, ULibFun, USysLoger;

const
  cCP_KeepOnLine = 3 * 1000;     //在线保持时间
  //CP=code printer
  
type
  PCodePrinter = ^TCodePrinter;
  TCodePrinter = record
    FID     : string;            //标识
    FIP     : string;            //地址
    FPort   : Integer;           //端口
    FTunnel : string;            //通道

    FDriver : string;            //驱动
    FEnable : Boolean;           //启用
    FOnline : Boolean;           //在线
    FLastOn : Int64;             //上次在线
  end;

  TCodePrinterManager = class;
  //define manager object
  
  TCodePrinterBase = class(TObject)
  protected
    FPrinter: PCodePrinter;
    //喷码机
    FClient: TIdTCPClient;
    //客户端
    FFlagLock: Boolean;
    //锁定标记
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; virtual; abstract;
    //打印编码
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    class function DriverName: string; virtual; abstract;
    //驱动名称
    function Print(const nPrinter: PCodePrinter; const nCode: string;
     var nHint: string): Boolean;
    //打印编码
    function IsOnline(const nPrinter: PCodePrinter): Boolean;
    //是否在线
    procedure LockMe;
    procedure UnlockMe;
    function IsLocked: Boolean;
    //驱动状态
  end;

  TCodePrinterMonitor = class(TThread)
  private
    FOwner: TCodePrinterManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TCodePrinterManager);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TCodePrinterDriverClass = class of TCodePrinterBase;
  //the driver class define

  TCodePrinterManager = class(TObject)
  private
    FDriverClass: array of TCodePrinterDriverClass;
    FDrivers: array of TCodePrinterBase;
    //驱动列表
    FPrinters: TList;
    //喷码机列表
    FMonIdx: Integer;
    FMonitor: array[0..1]of TCodePrinterMonitor;
    //监控线程
    FTunnelCode: TStrings;
    //通道喷码
    FSyncLock: TCriticalSection;
    //同步对象
    FEnablePrinter: Boolean;
    FEnableJSQ: Boolean;
    //系统开关
  protected
    procedure ClearDrivers;
    procedure ClearPrinters(const nFree: Boolean);
    //释放资源
    function GetPrinter(const nTunnel: string): PCodePrinter;
    //检索喷码机
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //载入配置
    procedure StartMon;
    procedure StopMon;
    //起停监控
    procedure RegDriver(const nDriver: TCodePrinterDriverClass);
    //注册驱动
    function LockDriver(const nName: string): TCodePrinterBase;
    procedure UnlockDriver(const nDriver: TCodePrinterBase);
    //获取驱动
    function PrintCode(const nTunnel,nCode: string; var nHint: string): Boolean;
    //打印编码
    function IsPrinterOnline(const nTunnel: string): Boolean;
    //是否在线
    function IsPrinterEnable(const nTunnel: string): Boolean;
    procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
    //起停喷码机
    property EnablePrinter: Boolean read FEnablePrinter;
    //属性相关
  end;

var
  gCodePrinterManager: TCodePrinterManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCodePrinterManager, '喷码机管理器', nEvent);
end;

//------------------------------------------------------------------------------
constructor TCodePrinterMonitor.Create(AOwner: TCodePrinterManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TCodePrinterMonitor.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TCodePrinterMonitor.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCodePrinterMonitor.Execute;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  while not Terminated do
  with FOwner do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FSyncLock.Enter;
    try
      if FMonIdx >= FPrinters.Count then
        FMonIdx := 0;
      //xxxxx
    finally
      FSyncLock.Leave;
    end;

    while True do
    begin
      FSyncLock.Enter;
      try
        nPrinter := nil;
        if FMonIdx >= FPrinters.Count then Break;
        
        nPrinter := FPrinters[FMonIdx];
        Inc(FMonIdx);

        if not nPrinter.FEnable then Continue;
        if GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine then Continue;
      finally
        FSyncLock.Leave;
      end;

      if not Assigned(nPrinter) then Break;
      nDriver := LockDriver(nPrinter.FDriver);
      try
        nDriver.IsOnline(nPrinter);
      finally
        UnlockDriver(nDriver);
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterManager.Create;
begin
  FEnablePrinter := False;
  FEnableJSQ := False;

  FPrinters := TList.Create;
  FTunnelCode := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TCodePrinterManager.Destroy;
begin
  StopMon;
  ClearDrivers;
  ClearPrinters(True);

  FTunnelCode.Free;
  FSyncLock.Free;
  inherited;
end;

procedure TCodePrinterManager.ClearPrinters(const nFree: Boolean);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FPrinters.Count - 1 downto 0 do
      Dispose(PCodePrinter(FPrinters[nIdx]));
    //xxxxx

    if nFree then
         FPrinters.Free
    else FPrinters.Clear;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TCodePrinterManager.ClearDrivers;
var nIdx: Integer;
begin
  for nIdx:=Low(FDrivers) to High(FDrivers) do
    FDrivers[nIdx].Free;
  SetLength(FDrivers, 0);
end;

procedure TCodePrinterManager.StartMon;
var nIdx: Integer;
begin
  if FEnablePrinter then
  begin
    if FPrinters.Count > 0 then
         FMonIdx := 0
    else Exit;

    for nIdx:=Low(FMonitor) to High(FMonitor) do
    begin
      FMonitor[nIdx] := nil;
      Exit; //关闭喷码机在线监测

      if nIdx >= FPrinters.Count then Break;
      //探测线程不超过喷码机个数

      if not Assigned(FMonitor[nIdx]) then
        FMonitor[nIdx] := TCodePrinterMonitor.Create(Self);
      //xxxxx
    end;
  end;
end;

procedure TCodePrinterManager.StopMon;
var nIdx: Integer;
begin
  for nIdx:=Low(FMonitor) to High(FMonitor) do
   if Assigned(FMonitor[nIdx]) then
   begin
     FMonitor[nIdx].StopMe;
     FMonitor[nIdx] := nil;
   end;
end;

procedure TCodePrinterManager.RegDriver(const nDriver: TCodePrinterDriverClass);
var nIdx: Integer;
begin
  for nIdx:=Low(FDriverClass) to High(FDriverClass) do
   if FDriverClass[nIdx].DriverName = nDriver.DriverName then Exit;
  //driver exists

  nIdx := Length(FDriverClass);
  SetLength(FDriverClass, nIdx + 1);
  FDriverClass[nIdx] := nDriver;
end;

//Date: 2012-9-7
//Parm: 驱动名称
//Desc: 锁定nName驱动对象
function TCodePrinterManager.LockDriver(const nName: string): TCodePrinterBase;
var nIdx,nInt: Integer;
begin
  Result := nil;
  FSyncLock.Enter;
  try
    for nIdx:=Low(FDrivers) to High(FDrivers) do
    if (not FDrivers[nIdx].IsLocked) and
       (CompareText(FDrivers[nIdx].DriverName, nName) = 0) then
    begin
      Result := FDrivers[nIdx];
      Exit;
    end;

    for nIdx:=Low(FDriverClass) to High(FDriverClass) do
    if CompareText(FDriverClass[nIdx].DriverName, nName) = 0 then
    begin
      nInt := Length(FDrivers);
      SetLength(FDrivers, nInt + 1);

      Result := FDriverClass[nIdx].Create;
      FDrivers[nInt] := Result;
      Exit;
    end;

    WriteLog(Format('无法锁定名称为[ %s ]喷码机驱动.', [nName]));
  finally
    if Assigned(Result) then
      Result.LockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: 驱动对象
//Desc: 对nDriver解锁
procedure TCodePrinterManager.UnlockDriver(const nDriver: TCodePrinterBase);
begin
  if Assigned(nDriver) then
  begin
    FSyncLock.Enter;
    nDriver.UnlockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: 通道
//Desc: 检索nTunnel通道上的喷码机
function TCodePrinterManager.GetPrinter(const nTunnel: string): PCodePrinter;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPrinters.Count - 1 downto 0 do
  begin
    Result := FPrinters[nIdx];
    if CompareText(Result.FTunnel, nTunnel) = 0 then
         Break
    else Result := nil;
  end;
end;

//Date: 2012-9-7
//Parm: 通道
//Desc: 判断nTunnel的喷码机是否在线
function TCodePrinterManager.IsPrinterOnline(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    WriteLog(Format('通道[ %s ]没有配置喷码机.', [nTunnel]));
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
      Result := nDriver.IsOnline(nPrinter);
    //xxxxx
  finally
    UnlockDriver(nDriver);
  end;
end;

//Date: 2013-07-23
//Parm: 通道号
//Desc: 查询nTunnel通道上的喷码机状态
function TCodePrinterManager.IsPrinterEnable(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
begin
  Result := False;

  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      Result := nPrinter.FEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 通道;起停标识
//Desc: 起停nTunnel通道上的喷码机
procedure TCodePrinterManager.PrinterEnable(const nTunnel: string;
  const nEnable: Boolean);
var nPrinter: PCodePrinter;
begin
  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      nPrinter.FEnable := nEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 通道;编码
//Desc: 在nTunnel通道的喷码机上打印nCode
function TCodePrinterManager.PrintCode(const nTunnel, nCode: string;
  var nHint: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  if FTunnelCode.Values[nTunnel] = nCode then
  begin
    Result := True;
    Exit;
  end; //通道喷码已发送
  
  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    nHint := Format('通道[ %s ]没有配置喷码机.', [nTunnel]);
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
         Result := nDriver.Print(nPrinter, nCode, nHint)
    else nHint := Format('加载名称为[ %s ]的喷码机失败.', [nPrinter.FDriver]);
  finally
    UnlockDriver(nDriver);
  end;

  if Result then
    FTunnelCode.Values[nTunnel] := nCode;
  //保存上次有效喷码
end;

//Desc: 读取nFile喷码机配置文件
procedure TCodePrinterManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nPrinter: PCodePrinter;
begin
  nXML := TNativeXml.Create;
  try
    ClearPrinters(False);
    nXML.LoadFromFile(nFile);

    nTmp := nXML.Root.FindNode('config');
    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('enableprinter').ValueAsInteger;
      FEnablePrinter := nIdx = 1;

      nIdx := nTmp.NodeByName('enablejsq').ValueAsInteger;
      FEnableJSQ := nIdx = 1;
    end;

    nTmp := nXML.Root.FindNode('printers');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nPrinter);
        FPrinters.Add(nPrinter);

        nNode := nTmp.Nodes[nIdx];
        with nPrinter^ do
        begin
          FID := nNode.AttributeByName['id'];
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
          FDriver := nNode.NodeByName('driver').ValueAsString;
          FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;

          FOnline := False;
          FLastOn := 0;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterBase.Create;
begin
  FFlagLock := False;
  FClient := TIdTCPClient.Create;
  FClient.ConnectTimeout := 5 * 1000;
  FClient.ReadTimeout := 3 * 1000;
end;

destructor TCodePrinterBase.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;
  inherited;
end;

procedure TCodePrinterBase.LockMe;
begin
  FFlagLock := True;
end;

procedure TCodePrinterBase.UnlockMe;
begin
  FFlagLock := False;
end;

function TCodePrinterBase.IsLocked: Boolean;
begin
  Result := FFlagLock;
end;

//Desc: 判断nPrinter是否在线
function TCodePrinterBase.IsOnline(const nPrinter: PCodePrinter): Boolean;
begin
  if (not nPrinter.FEnable) or
     (GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine) then
  begin
    Result := True;
    Exit;
  end else Result := False;

  try
    if (FClient.Host <> nPrinter.FIP) or (FClient.Port <> nPrinter.FPort) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx

      FClient.Host := nPrinter.FIP;
      FClient.Port := nPrinter.FPort;
    end;

    if not FClient.Connected then
      FClient.Connect;
    Result := FClient.Connected;

    nPrinter.FOnline := Result;
    if Result then
      nPrinter.FLastOn := GetTickCount;
    //xxxxx
  except
    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 喷码机;编码
//Desc: 向nPrinter发送nCode编码.
function TCodePrinterBase.Print(const nPrinter: PCodePrinter;
  const nCode: string; var nHint: string): Boolean;
begin
  if not nPrinter.FEnable then
  begin
    Result := True;
    Exit;
  end else Result := False;

  if not IsOnline(nPrinter) then
  begin
    nHint := Format('喷码机[ %s ]网络通讯异常.', [nPrinter.FID]);
    Exit;
  end;

  try
    if Assigned(FClient.IOHandler) then
    begin
      FClient.IOHandler.InputBuffer.Clear;
      FClient.IOHandler.WriteBufferClear;
    end;

    FPrinter := nPrinter;
    Result := PrintCode(nCode, nHint);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      nHint := Format('向喷码机[ %s ]发送内容失败.', [nPrinter.FID]);

      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx
    end;
  end;
end;

//------------------------------------------------------------------------------
type
  TByteWord = record
    FH: Byte;
    FL: Byte;
  end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // 移到高字节
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //只测试最高位
         crc := (crc shl 1) xor genpoly     // 最高位为1，移位和异或处理
    else crc := crc shl 1;                  // 否则只移位（乘2）
    data := data shl 1;                     // 处理下一位
  end;

  Result := crc;
end;

function CRC16(const nStr: string; const nStart,nEnd: Integer): Word;
var nIdx: Integer;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  for nIdx:=nStart to nEnd do
  begin
    Result := CalCRC16(Ord(nStr[nIdx]), Result, $1021);
  end;
end;

//------------------------------------------------------------------------------
type
  TPrinterZero = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;
  
class function TPrinterZero.DriverName: string;
begin
  Result := 'zero';
end;

//Desc: 打印编码
function TPrinterZero.PrintCode(const nCode: string;
  var nHint: string): Boolean;
  var nData: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
    nDatatemp: string;
    nstr: string  ;
begin
  //protocol: 55 7F len order datas crc16 AA
  nData := Char($55) + Char($7F) + Char(Length(nCode) + 1);
  nData := nData + Char($54) + Char($01);
  nData := nData + nCode;

  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  SetLength(nBuf, 0);
  FClient.Socket.ReadBytes(nBuf, 9, False);

  nstr:= BytesToString(nBuf,Indy8BitEncoding);

  nDatatemp :=  Char($55) + Char($FF) + Char($02)+ Char($54)+ Char($4F);
  nDatatemp :=  nDatatemp + Char($4B)+ Char($5D) + Char($E4) + Char($AA);


  if nstr <> nDatatemp then
   begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
   end;
                    

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterJY = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterJY.DriverName: string;
begin
  Result := 'JY';
end;

function TPrinterJY.PrintCode(const nCode: string;
  var nHint: string): Boolean;
  var nData: string;
  nBuf: TIdBytes;
  nstr: string;
begin

  //久易喷码机
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  // 1B 41 29 为开头数据
  // 27 表示喷码的字的个数 （27表示为1个） 计数的方式为16进制
  // 20 表示通道的编码      （20为通道1）  计数的方式为16进制
  // 40 37 表示喷码数据的开始
  // ***  喷码的数据        传送的方式为ASCII码
  // 40 39 表示喷码数据的结尾
  // 0D   表示整体传送的结尾

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  SetLength(nBuf, 0);
  FClient.Socket.ReadBytes(nBuf, Length(nData), False);

  nstr:= BytesToString(nBuf, Indy8BitEncoding);
  if nstr <> nData then
   begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
   end;

  Result := True;
end;


//-----------------------------------------------------------------------
type
  TPrinterWSD = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSD.DriverName: string;
begin
  Result := 'WSD';
end;

function TPrinterWSD.PrintCode(const nCode: string;
  var nHint: string): Boolean;
  var nData: string;
  nBuf: TIdBytes;
  nstr: string;
begin
  //威士德喷码机
  //1B 41 29 2A 20 40 37 32 33 34 35 40 39 0D

  //1B 41 29 起始位
  //2A 表示该条指令后面的字节长度+20（蓝色与红色字的长度），计数的方式为16进制
  //20  表示通道的编码（20为通道1，21为通道2，以此类推）  计数的方式为16进制
  //40 37 表示喷码数据的开始
  //40 39 表示喷码数据的结尾
  //0D   表示整体传送的结尾

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 32 + 6);
  nData := nData+Char(2 + 31 )+Char($40)+Char($37);
  nData := nData+nCode;
  nData := nData+Char($40)+Char($39)+Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);

  SetLength(nBuf, 0);
  FClient.Socket.ReadBytes(nBuf, Length(nData), False);

  nstr:= BytesToString(nBuf, Indy8BitEncoding);
  if nstr <> nData then
   begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
   end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterSGB = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSGB.DriverName: string;
begin
  Result := 'SGB';
end;

function TPrinterSGB.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //仕贵宝喷码机
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  //1B 41 2C 22 channel(start 31) 0D;
  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  Sleep(800);
  //for delay
  
  nData := Char($1B) + Char($41) + Char($2C) +Char($22);
  nData := nData + Char(2 + 31) + Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  //SetLength(nBuf, 0);
  //FClient.Socket.ReadBytes(nBuf, Length(nData), False);

  Result := True;
end;

initialization
  gCodePrinterManager := TCodePrinterManager.Create;
  gCodePrinterManager.RegDriver(TPrinterZero);
  gCodePrinterManager.RegDriver(TPrinterJY);
  gCodePrinterManager.RegDriver(TPrinterWSD);
  gCodePrinterManager.RegDriver(TPrinterSGB);
finalization
  FreeAndNil(gCodePrinterManager);
end.
