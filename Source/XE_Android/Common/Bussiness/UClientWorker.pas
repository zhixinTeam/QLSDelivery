{*******************************************************************************
  作者: dmzn@163.com 2011-10-22
  描述: 客户端业务处理工作对象
*******************************************************************************}
unit UClientWorker;

interface

uses
  SysUtils, Classes, UBusinessWorker, UBusinessConst, UBusinessPacker,
  FMX.Dialogs, System.Types, System.UITypes, Soap;

const
  sFlag_ForceHint  = 'Bus_HintMsg';               //强制提示

type
  TDynamicStrArray = array of string;
  //字符串数组

  TClient2MITWorker = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //字符列表
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

  TClientWorkerQueryField = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessCommand = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessSaleBill = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessPurchaseOrder = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessHardware = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

implementation
uses FMX.PlatForm.Android,FMX.Forms;

     //Date: 2010-3-5
//Parm: 字符串;数组;忽略大小写
//Desc: 检索nStr在nArray中的索引位置
function StrArrayIndex(const nStr: string; const nArray: TDynamicStrArray;
  const nIgnoreCase: Boolean = True): integer;
var nIdx: integer;
    nRes: Boolean;
begin
  Result := -1;
  for nIdx:=Low(nArray) to High(nArray) do
  begin
    if nIgnoreCase then
         nRes := CompareText(nStr, nArray[nIdx]) = 0
    else nRes := nStr = nArray[nIdx];

    if nRes then
    begin
      Result := nIdx; Exit;
    end;
  end;
end;

constructor TClient2MITWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClient2MITWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: 入参;出参
//Desc: 执行业务并对异常做处理
function TClient2MITWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^ do
  begin
    nParam := FParam;
    FPacker.InitData(nIn, True, False);

    with FFrom, gSysParam do
    begin
      FUser   := FOperator;
      FIP     := FHostIP;
      FMAC    := FHostMAC;
      FTime   := Now;
      FKpLong := 0;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr);

  if not Result then
  begin
    if Pos(sParam_NoHintOnError, nParam) < 1 then
    begin
      ShowMessage(nStr);
    end else PBWDataBase(nOut)^.FErrDesc := nStr;
    
    Exit;
  end;
  
  FPacker.UnPackOut(nStr, nOut);
  with PBWDataBase(nOut)^ do
  begin
    nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
    nStr := Format(nStr, ['', FunctionName, FVia.FIP,
             0]);

    Result := FResult;
    if Result then
    begin
      if FErrCode = sFlag_ForceHint then
      begin
        nStr := '业务执行成功,提示信息如下: ' + #13#10#13#10 + FErrDesc;
        ShowMessage(nStr);
      end;

      Exit;
    end;

    if Pos(sParam_NoHintOnError, nParam) < 1 then
    begin
      SetLength(nArray, 0);

      nStr := '业务执行异常,描述如下: ' + #13#10#13#10 +

              ErrDescription(FErrCode, FErrDesc, nArray) +

              '请检查输入参数、操作是否有效,或联系管理员!' + #32#32#32;
      ShowMessage(nStr);
    end;
  end;
end;

//Date: 2012-3-20
//Parm: 代码;描述
//Desc: 格式化错误描述
function TClient2MITWorker.ErrDescription(const nCode, nDesc: string;
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
function TClient2MITWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: 入参数据
//Desc: 连接MIT执行具体业务
function TClient2MITWorker.MITWork(var nData: string): Boolean;
var nSvr: SrvBusiness;
    nStr: string;
    FAction: SrvBusiness___Action;
    FActionResponse:SrvBusiness___ActionResponse;
begin
  Result := False;

  nStr := GetFixedServiceURL;
  nSvr := GetSrvBusiness(True, nStr, nil);
  if not Assigned(nSvr) then ShowMessage( '获取地址失败');

  FAction := SrvBusiness___Action.Create;
  try
    FAction.nData    := nData;
    FAction.nFunName := GetFlagStr(cWorker_GetMITName);

    FActionResponse := nSvr.Action(FAction);

    Result := FActionResponse.Result;
    nData  := FActionResponse.nData;
  finally
    FreeAndNil(FAction);
    FreeAndNil(FActionResponse);
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

function TClientBusinessCommand.GetFixedServiceURL: string;
var nStrURL: string;
begin
  nStrURL := 'http://%s:%d/Soap?service=SrvBusiness';
  Result  := Format(nStrURL, [gSysParam.FServIP, gSysParam.FServPort]);
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
class function TClientBusinessPurchaseOrder.FunctionName: string;
begin
  Result := sCLI_BusinessPurchaseOrder;
end;

function TClientBusinessPurchaseOrder.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessPurchaseOrder;
  end;
end;

function TClientBusinessPurchaseOrder.GetFixedServiceURL: string;
var nStrURL: string;
begin
  nStrURL := 'http://%s:%d/Soap?service=SrvBusiness';
  Result  := Format(nStrURL, [gSysParam.FServIP, gSysParam.FServPort]);
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

function TClientBusinessHardware.GetFixedServiceURL: string;
begin
  Result := '';
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientWorkerQueryField);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessCommand);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessSaleBill);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessHardware);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessPurchaseOrder);
end.
