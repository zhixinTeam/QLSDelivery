{*******************************************************************************
  作者: dmzn@163.com 2011-10-22
  描述: 客户端业务处理工作对象
*******************************************************************************}
unit UWorkerSelfRemote;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UChannelChooser, UBusinessWorker,
  UBusinessConst, UBusinessPacker, ULibFun;

type
  TRemote2MITWorker = class(TBusinessWorkerBase)
  protected
    FRemoteMITUL: String;
    //工厂服务器UL
    FListA,FListB: TStrings;
    //字符列表
    procedure WriteLog(const nEvent: string);
    //记录日志
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TDynamicStrArray): string;
    //错误描述
    function MITWork(var nData: string): Boolean;
    //执行业务
    function GetFixedServiceURL: string; virtual;
    //固定地址
  public
    constructor Create; override;
    destructor destroy; override;
    //创建释放
    function DoWork(const nIn, nOut: Pointer): Boolean; override;
    //执行业务
  end;

  TClientWorkerQueryField = class(TRemote2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessCommand = class(TRemote2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessSaleBill = class(TRemote2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;
  
  TClientBusinessHardware = class(TRemote2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
//访问有效服务 

implementation

uses
  UFormWait, Forms, USysLoger, UMITConst, USysDB, MIT_Service_Intf,
  UMgrParam;
  
//Desc: 记录nEvent日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TClientBusinessHardware, 'uworkerselfremove.writelog' , nEvent);
end;
//Date: 2014-09-15
//Parm: 对象;命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FBase.FParam := nRemoteUL;

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nWorker := gBusinessWorkerManager.LockWorker(nCLIWorkerName);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-3-11
//Parm: 日志内容
//Desc: 记录日志
procedure TRemote2MITWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, 'MIT服务互访业务对象', nEvent);
end;

constructor TRemote2MITWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TRemote2MITWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: 入参;出参
//Desc: 执行业务并对异常做处理
function TRemote2MITWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^ do
  begin
    FRemoteMITUL := FParam;
    FPacker.InitData(nIn, True, False);
    
    with FFrom do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr);

  if not Result then
  begin
    PWorkerBusinessCommand(nOut).FData := nStr;
    WriteLog(nStr);
    Exit;
  end;  

  FPacker.UnPackOut(nStr, nOut);
  with PBWDataBase(nOut)^ do
  begin
    nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
    nStr := Format(nStr, [gSysParam.FAppFlag, FunctionName, FVia.FIP,
            GetTickCount - FWorkTimeInit]);

    Result := FResult;
    if Result then
    begin
      if FErrCode = sFlag_ForceHint then
      begin
        nStr := '业务执行成功,提示信息如下: ' + #13#10#13#10 + FErrDesc;
        WriteLog(nStr);
      end;

      Exit;
    end;

    SetLength(nArray, 0);
    nStr := '业务执行异常,描述如下: ' + #13#10#13#10 +

            ErrDescription(FErrCode, FErrDesc, nArray) +

            '请检查输入参数、操作是否有效,或联系管理员!' + #32#32#32;
    WriteLog(nStr);
  end;
end;

//Date: 2012-3-20
//Parm: 代码;描述
//Desc: 格式化错误描述
function TRemote2MITWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TDynamicStrArray): string;
var nIdx: Integer;
begin
  FListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
  FListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

  if FListA.Count <> FListB.Count then
  begin
    Result := '※.代码: ' + nCode + #13#10 +
              '   描述: ' + nDesc + #13#10#13#10;
  end else Result := '';

  for nIdx:=0 to FListA.Count - 1 do
  if (Length(nInclude) = 0) or (StrArrayIndex(FListA[nIdx], nInclude) > -1) then
  begin
    Result := Result + '※.代码: ' + FListA[nIdx] + #13#10 +
                       '   描述: ' + FListB[nIdx] + #13#10#13#10;
  end;
end;

//Desc: 强制指定服务地址
function TRemote2MITWorker.GetFixedServiceURL: string;
begin
  Result := FRemoteMITUL;
end;

//Date: 2012-3-9
//Parm: 入参数据
//Desc: 连接MIT执行具体业务
function TRemote2MITWorker.MITWork(var nData: string): Boolean;
var nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '连接MIT服务失败(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    while True do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      //xxxxx

      if GetFixedServiceURL = '' then
      begin
        nData := '未制定工厂MIT服务地址.';
        Exit;
      end
      else FHttp.TargetURL := GetFixedServiceURL;

      Result := ISrvBusiness(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E:Exception do
      begin
        if (GetFixedServiceURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s(BY %s ).', [E.Message, gSysParam.FLocalName]);
          WriteLog('Function:[ ' + FunctionName + ' ]' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    gChannelManager.ReleaseChannel(nChannel);
  end;
end;

//------------------------------------------------------------------------------
class function TClientWorkerQueryField.FunctionName: string;
begin
  Result := sCLI_GetQueryField;
end;

function TClientWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
   cWorker_GetMITName    : Result := sBus_GetQueryField;
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessCommand.FunctionName: string;
begin
  Result := sCLI_BusinessCommand;
end;

function TClientBusinessCommand.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessCommand;
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessSaleBill.FunctionName: string;
begin
  Result := sCLI_BusinessSaleBill;
end;

function TClientBusinessSaleBill.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessSaleBill;
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessHardware.FunctionName: string;
begin
  Result := sCLI_HardwareCommand;
end;

function TClientBusinessHardware.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_HardwareCommand;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientWorkerQueryField, sPlug_ModuleRemote);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessCommand, sPlug_ModuleRemote);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessSaleBill, sPlug_ModuleRemote);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessHardware, sPlug_ModuleRemote);
end.
