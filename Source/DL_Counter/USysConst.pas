{*******************************************************************************
  作者: dmzn@163.com 2012-4-29
  描述: 常量定义
*******************************************************************************}
unit USysConst;

interface

uses
  Windows, Classes, SysUtils, UBusinessPacker, UBusinessWorker, UBusinessConst,
  UClientWorker, UMITPacker, UWaitItem, ULibFun, UMultiJS, USysDB, USysLoger;

type
  TSysParam = record
    FUserID     : string;                            //用户标识
    FUserName   : string;                            //当前用户
    FUserPwd    : string;                            //用户口令
    FGroupID    : string;                            //所在组
    FIsAdmin    : Boolean;                           //是否管理员
    FIsNormal   : Boolean;                           //帐户是否正常

    FLocalIP    : string;                            //本机IP
    FLocalMAC   : string;                            //本机MAC
    FLocalName  : string;                            //本机名称
    FHardMonURL : string;                            //硬件守护
  end;
  //系统参数

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //编号
    FName     : string;      //名称
    FStock    : string;      //品名
    FWeight   : Integer;     //袋重
    FValid    : Boolean;     //是否有效
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //车牌号
    FLine     : string;      //通道
    FBill     : string;      //提货单
    FValue    : Double;      //提货量
    FDai      : Integer;     //袋数
    FTotal    : Integer;     //总数
    FInFact   : Boolean;     //是否进厂
    FIsRun    : Boolean;     //是否运行    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  TMITReader = class(TThread)
  private
    FList: TStrings;
    FWaiter: TWaitObject;
    //等待对象
    FTunnel: TMultiJSTunnel;
    FOnData: TMultiJSEvent;
  protected
    procedure DoSync;
    procedure Execute; override;
  public
    constructor Create(AEvent: TMultiJSEvent);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //程序所在路径
  gSysParam:TSysParam;                               //程序环境参数
  gMITReader: TMITReader = nil;                      //中间件读取

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//读取车辆队列
function RemoteExecuteSQL(const nSQL: string): Boolean;
//远程写数据库
function SaveTruckCountData(const nBill: string; nDaiNum: Integer): Boolean;
//保存交货单提货袋数
function StartJS(const nTunnel,nTruck,nBill: string; nDai: Integer): Boolean;
function PauseJS(const nTunnel: string): Boolean;
function StopJS(const nTunnel: string): Boolean;
//计数器相关业务
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
//向喷码机发送喷码请求

//------------------------------------------------------------------------------
resourceString
  sHint               = '提示';                      //对话框标题
  sWarn               = '警告';                      //==
  sAsk                = '询问';                      //询问对话框
  sError              = '未知错误';                  //错误对话框

  sDate               = '日期:【%s】';               //任务栏日期
  sTime               = '时间:【%s】';               //任务栏时间
  sUser               = '用户:【%s】';               //任务栏用户

  sConfigFile         = 'Config.Ini';                //主配置文件
  sConfigSec          = 'Config';                    //主配置小节
  sVerifyCode         = ';Verify:';                  //校验码标记
  sFormConfig         = 'FormInfo.ini';              //窗体配置

  sInvalidConfig      = '配置文件无效或已经损坏';    //配置文件无效
  sCloseQuery         = '确定要退出程序吗?';         //主窗口退出

implementation

constructor TMITReader.Create(AEvent: TMultiJSEvent);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOnData := AEvent;
  FList := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TMITReader.Destroy;
begin
  FWaiter.Free;
  FList.Free;  
  inherited;
end;

procedure TMITReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMITReader.Execute;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    nWorker := nil;
    try
      nIn.FCommand := cBC_JSGetStatus;
      nIn.FBase.FParam := sParam_NoHintOnError;
      
      nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
      if not nWorker.WorkActive(@nIn, @nOut) then Continue;

      FList.Text := nOut.FData;
      if Assigned(FOnData) then
        Synchronize(DoSync);
      //xxxxx
    finally
      gBusinessWorkerManager.RelaseWorker(nWorker);
    end;
  except
    on E:Exception do
    begin
      gSysLoger.AddLog(E.Message);
    end;
  end;
end;

procedure TMITReader.DoSync;
var nIdx: Integer;
begin
  for nIdx:=0 to FList.Count - 1 do
  begin
    FTunnel.FID := FList.Names[nIdx];
    if not IsNumber(FList.Values[FTunnel.FID], False) then Continue;

    FTunnel.FHasDone := StrToInt(FList.Values[FTunnel.FID]);
    FOnData(@FTunnel);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-25
//Parm: 通道;车辆
//Desc: 读取车辆队列数据
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings; 
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nIn.FData := sFlag_Yes
    else nIn.FData := sFlag_No;

    nIn.FCommand := cBC_GetQueueData;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);

    Result := nWorker.WorkActive(@nIn, @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-4-27
//Parm: SQL语句
//Desc: 远程执行nSQL
function RemoteExecuteSQL(const nSQL: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_RemoteExecSQL;
    nIn.FData := PackerEncodeStr(nSQL);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-4-30
//Parm: 交货单;袋数
//Desc: 保存nBill的计数结果
function SaveTruckCountData(const nBill: string; nDaiNum: Integer): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nBill;
    nList.Values['Dai'] := IntToStr(nDaiNum);

    nIn.FCommand := cBC_SaveCountData;
    nIn.FBase.FParam := sParam_NoHintOnError;
    nIn.FData := PackerEncodeStr(nList.Text);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-21
//Parm: 通道;车牌;交货单;袋数
//Desc: 开启一个新的计数
function StartJS(const nTunnel,nTruck,nBill: string; nDai: Integer): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    with nList do
    begin
      Values['Tunnel'] := nTunnel;
      Values['Truck']  := nTruck;
      Values['Bill']   := nBill;
      Values['DaiNum']    := IntToStr(nDai);
    end;

    nIn.FCommand := cBC_JSStart;
    nIn.FBase.FParam := sParam_NoHintOnError;
    nIn.FData := nList.Text;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-17
//Parm: 通道号
//Desc: 暂停nTunnel计数
function PauseJS(const nTunnel: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_JSPause;
    nIn.FData := nTunnel;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-17
//Parm: 通道号
//Desc: 停止nTunnel计数
function StopJS(const nTunnel: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_JSStop;
    nIn.FData := nTunnel;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-9-14
//Parm: 通道号;交货单;提示
//Desc: 向nTunnel的喷码机发送打印nBill请求
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    with nIn do
    begin
      FCommand := cBC_PrintCode;
      FData := nBill;
      FExtParam := nTunnel;
      FBase.FParam := sParam_NoHintOnError;
    end;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);

    if not Result then
      nHint := nOut.FBase.FErrDesc;
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

end.
