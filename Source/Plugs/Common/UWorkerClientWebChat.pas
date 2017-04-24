{*******************************************************************************
  作者: fendou116688@163.com 2017/4/11
  描述: 微信业务查询
*******************************************************************************}
unit UWorkerClientWebChat;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UChannelChooser, UBusinessWorker,
  UBusinessConst, UBusinessPacker, ULibFun;

type
  TClient2WebChatWorker = class(TBusinessWorkerBase)
  protected
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

  TClientBusinessWebChat = class(TClient2WebChatWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
//调用远程服务对象 
implementation

uses
  UFormWait, Forms, USysLoger, UMITConst, MIT_Service_Intf;

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

//Date: 2012-3-11
//Parm: 日志内容
//Desc: 记录日志
procedure TClient2WebChatWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, '客户业务对象', nEvent);
end;

constructor TClient2WebChatWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClient2WebChatWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: 入参;出参
//Desc: 执行业务并对异常做处理
function TClient2WebChatWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
begin
  nStr := '<?xml version="1.0" encoding="utf-8"?>'
          +'<Head>'
          +'  <Command>%d</Command>'
          +'  <Data>%s</Data>'
          +'  <ExtParam>%s</ExtParam>'
          +'  <RemoteUL></RemoteUL>'
          +'</Head>';

  with PWorkerBusinessCommand(nIn)^ do
  nStr := Format(nStr, [FCommand, FData, FExtParam]);

  Result := MITWork(nStr);

  with PWorkerBusinessCommand(nOut)^ do
  begin
    FData := nStr;
  end;
end;

//Date: 2012-3-20
//Parm: 代码;描述
//Desc: 格式化错误描述
function TClient2WebChatWorker.ErrDescription(const nCode, nDesc: string;
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
function TClient2WebChatWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: 入参数据
//Desc: 连接MIT执行具体业务
function TClient2WebChatWorker.MITWork(var nData: string): Boolean;
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
        FChannel := CoSrvWebchat.Create(FMsg, FHttp);
      //xxxxx

      if GetFixedServiceURL = '' then
           FHttp.TargetURL := gChannelChoolser.ActiveURL
      else FHttp.TargetURL := GetFixedServiceURL;

      Result := ISrvWebChat(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E:Exception do
      begin
        if (GetFixedServiceURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s.', [E.Message]);
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
class function TClientBusinessWebChat.FunctionName: string;
begin
  Result := sCLI_BusinessWebchat;
end;

function TClientBusinessWebChat.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessWebchat;
  end;
end;

function TClientBusinessWebChat.GetFixedServiceURL: string;
begin
  Result := gSysParam.FGPWSURL;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientBusinessWebChat, sPlug_ModuleBus);
end.
