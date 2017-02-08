{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务对象调用封装器
*******************************************************************************}
unit UBusinessWorker;

interface

uses
  Classes, SyncObjs, SysUtils, UObjectList,
  UBusinessPacker;

const
  {*worker action code*}
  cWorker_GetPackerName       = $0010;
  cWorker_GetSAPName          = $0011;
  cWorker_GetRFCName          = $0012;
  cWorker_GetMITName          = $0015;

type
  TBusinessWorkerBase = class(TObject)
  protected
    FEnabled: Boolean;
    //可用标记
    FPacker: TBusinessPackerBase;
    //封装器
    FWorkTime: TDateTime;
    FWorkTimeInit: Cardinal;
    //开始时间
    function DoWork(var nData: string): Boolean; overload; virtual;
    function DoWork(const nIn,nOut: Pointer): Boolean; overload; virtual; 
    //子类处理
    procedure WriteLog(const nEvent: string);
    //记录日志
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //创建释放
    class function FunctionName: string; virtual;
    //函数名
    function GetFlagStr(const nFlag: Integer): string; virtual;
    //标记内容
    function WorkActive(var nData: string): Boolean; overload;
    function WorkActive(const nIn,nOut: Pointer): Boolean; overload;
    //执行业务
  end;

  TBusinessWorkerSweetHeart = class(TBusinessWorkerBase)
  public
    class function FunctionName: string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    class procedure RegWorker(const nSrvURL: string);
    //注册对象
  end;

  TBusinessWorkerClass = class of TBusinessWorkerBase;
  //class type

  TBusinessWorkerManager = class(TObject)
  private
    FWorkerClass: TObjectDataList;
    //类列表
    FWorkerPool: TObjectDataList;
    //对象池
    FNumLocked: Integer;
    //锁定对象
    FSrvClosed: Integer;
    //服务关闭
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    function GetWorker(const nFunName: string): TBusinessWorkerBase;
    //获取工作对象
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure RegisteWorker(const nWorker: TBusinessWorkerClass;
      const nWorkerID: string = '');
    procedure UnRegistePacker(const nWorkerID: string);
    //注册类
    function LockWorker(const nFunName: string;
      const nExceptionOnNull: Boolean = True): TBusinessWorkerBase;
    procedure RelaseWorker(const nWorkder: TBusinessWorkerBase);
    //锁定释放
    procedure MoveTo(const nManager: TBusinessWorkerManager);
    //移动数据
  end;

var
  gBusinessWorkerManager: TBusinessWorkerManager = nil;
  //全局使用

Resourcestring
  sSys_SweetHeart = 'Sys_SweetHeart';       //心跳指令

implementation

const
  cYes  = $0002;
  cNo   = $0005;

var
  gLocalServiceURL: string;
  //本地服务地址列表

class function TBusinessWorkerSweetHeart.FunctionName: string;
begin
  Result := sSys_SweetHeart;
end;

function TBusinessWorkerSweetHeart.DoWork(var nData: string): Boolean;
begin
  nData := PackerEncodeStr(gLocalServiceURL);
  Result := True;
end;

class procedure TBusinessWorkerSweetHeart.RegWorker(const nSrvURL: string);
begin
  gLocalServiceURL := nSrvURL;
  if Assigned(gBusinessWorkerManager) then
    gBusinessWorkerManager.RegisteWorker(TBusinessWorkerSweetHeart);
  //registe
end;

//------------------------------------------------------------------------------
constructor TBusinessWorkerManager.Create;
begin
  FNumLocked := 0;
  FSrvClosed := cNo;

  FSyncLock := TCriticalSection.Create;
  FWorkerPool := TObjectDataList.Create(dtObject);
  FWorkerClass := TObjectDataList.Create(dtClass);
end;

destructor TBusinessWorkerManager.Destroy;
begin
  FSrvClosed := cYes;
  //set close float

  FSyncLock.Enter;
  try
    if FNumLocked > 0 then
    try
      FSyncLock.Leave;
      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FSyncLock.Enter;
    end;
    
    FreeAndNil(FWorkerPool);
    FreeAndNil(FWorkerClass);
  finally
    FSyncLock.Leave;
  end;

  FreeAndNil(FSyncLock);
  inherited;
end;

//Date: 2012-3-7
//Parm: 工作对象类;标识
//Desc: 注册nWorker类
procedure TBusinessWorkerManager.RegisteWorker(
  const nWorker: TBusinessWorkerClass; const nWorkerID: string);
begin
  FSyncLock.Enter;
  try
    FWorkerClass.AddItem(nWorker, nWorkerID);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-22
//Parm: 标识
//Desc: 反注册nWorkerID的类和对象
procedure TBusinessWorkerManager.UnRegistePacker(const nWorkerID: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FWorkerClass.ItemHigh downto FWorkerClass.ItemLow do
     if FWorkerClass[nIdx].FItemID = nWorkerID then
      FWorkerClass.DeleteItem(nIdx);
    //反注册类

    if FNumLocked > 0 then
    try
      FSrvClosed := cYes;
      FSyncLock.Leave;

      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FSyncLock.Enter;
      FSrvClosed := cNo;
    end;

    for nIdx:=FWorkerPool.ItemHigh downto FWorkerPool.ItemLow do
     if FWorkerPool[nIdx].FItemID = nWorkerID then
      FWorkerPool.DeleteItem(nIdx);
    //释放对象
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-3-7
//Parm: 函数名
//Desc: 获取可以执行nFunName的工作对象
function TBusinessWorkerManager.GetWorker(
  const nFunName: string): TBusinessWorkerBase;
var nIdx: Integer;
    nWorker: TBusinessWorkerBase;
    nClass: TBusinessWorkerClass;
begin
  Result := nil;

  for nIdx:=FWorkerPool.ItemLow to FWorkerPool.ItemHigh do
  begin
    nWorker := TBusinessWorkerBase(FWorkerPool.ObjectA[nIdx]);
    if nWorker.FEnabled and (nWorker.FunctionName = nFunName) then
    begin
      Result := nWorker;
      Result.FEnabled := False;
      Exit;
    end;
  end;

  for nIdx:=FWorkerClass.ItemLow to FWorkerClass.ItemHigh do
  begin
    nClass := TBusinessWorkerClass(FWorkerClass.ClassA[nIdx]);
    if nClass.FunctionName = nFunName then
    begin
      Result := nClass.Create;
      Result.FEnabled := False;

      FWorkerPool.AddItem(Result, FWorkerClass[nIdx].FItemID);
      Exit;
    end;
  end;
end;

//Desc: 获取工作对象
function TBusinessWorkerManager.LockWorker(const nFunName: string;
  const nExceptionOnNull: Boolean): TBusinessWorkerBase;
begin
  Result := nil;
  if FSrvClosed = cYes then Exit;

  FSyncLock.Enter;
  try
    if FSrvClosed = cYes then Exit;
    Result := GetWorker(nFunName);
    
    if (not Assigned(Result)) and nExceptionOnNull then
      raise Exception.Create(Format('Worker "%s" is invalid.', [nFunName]));
    //xxxxx
  finally
    if Assigned(Result) then
      Inc(FNumLocked);
    FSyncLock.Leave;
  end;
end;

//Desc: 释放工作对象
procedure TBusinessWorkerManager.RelaseWorker(
  const nWorkder: TBusinessWorkerBase);
begin
  if Assigned(nWorkder) then
  try
    FSyncLock.Enter;
    nWorkder.FEnabled := True;
    Dec(FNumLocked);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 将数据交由nManager管理
procedure TBusinessWorkerManager.MoveTo(const nManager: TBusinessWorkerManager);
begin
  FWorkerClass.MoveData(nManager.FWorkerClass);
  FWorkerPool.MoveData(nManager.FWorkerPool);
end;

//------------------------------------------------------------------------------
constructor TBusinessWorkerBase.Create;
begin
  FEnabled := True;
end;

destructor TBusinessWorkerBase.Destroy;
begin
  //nothing
  inherited;
end;

class function TBusinessWorkerBase.FunctionName: string;
begin
  Result := '';
end;

function TBusinessWorkerBase.GetFlagStr(const nFlag: Integer): string;
begin
  Result := '';
end;

function TBusinessWorkerBase.DoWork(var nData: string): Boolean;
begin
  Result := True;
end;

function TBusinessWorkerBase.DoWork(const nIn, nOut: Pointer): Boolean;
begin
  Result := True;
end;

procedure TBusinessWorkerBase.WriteLog(const nEvent: string);
begin
  //gSysLoger.AddLog(ClassType, '业务工作对象', nEvent);
end;

//Date: 2012-3-9
//Parm: 入参数据
//Desc: 执行以nData为数据的业务逻辑
function TBusinessWorkerBase.WorkActive(var nData: string): Boolean;
var nStr: string;
begin
  FPacker := nil;
  try
    nStr := GetFlagStr(cWorker_GetPackerName);
    if nStr <> '' then
    begin
      FPacker := gBusinessPackerManager.LockPacker(nStr);
      if FPacker.PackerName <> nStr then
      begin
        nData := '远程调用失败(Packer Is Null).';
        Result := False;
        Exit;
      end;
    end;

    FWorkTime := Now;
    //FWorkTimeInit := GetTickCount;
    FWorkTimeInit := 0;
    Result := DoWork(nData);
  finally
    gBusinessPackerManager.RelasePacker(FPacker);
  end;
end;

//Date: 2012-3-11
//Parm: 指针入参;指针出参
//Desc: 执行以nData为数据的业务逻辑
function TBusinessWorkerBase.WorkActive(const nIn,nOut: Pointer): Boolean;
var nPacker: string;
begin
  FPacker := nil;
  try
    nPacker := GetFlagStr(cWorker_GetPackerName);
    if nPacker <> '' then
    begin
      FPacker := gBusinessPackerManager.LockPacker(nPacker);

      if FPacker.PackerName <> nPacker then
      begin
        Result := False;
        Exit;
      end;
    end;

    FWorkTime := Now;
    //FWorkTimeInit := GetTickCount;
    FWorkTimeInit := 0;
    Result := DoWork(nIn, nOut);
  finally
    gBusinessPackerManager.RelasePacker(FPacker);
  end;
end;

initialization
  gBusinessWorkerManager := TBusinessWorkerManager.Create;
finalization
  FreeAndNil(gBusinessWorkerManager);
end.


