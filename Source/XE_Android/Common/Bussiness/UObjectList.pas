{*******************************************************************************
  作者: dmzn@163.com 2013-11-20
  描述: 存储带有标识的对象和类类型的列表

  备注:
  *.列表支持TObject,TClass等,函数也分为对应的几组,当确定列表使用哪种类型时,只能
    调用类型对应的函数,不可交叉使用.
  *.如TObject类型的列表,只能使用含有TObject的函数.
*******************************************************************************}
unit UObjectList;

interface

uses
  Classes, SysUtils, SyncObjs;

type
  PObjectDataItem = ^TObjectDataItem;
  TObjectDataItem = record
    FItemID : string;            //对象标识
    FObject : TObject;           //对象指针
    FClass  : TClass;            //类型指针
    FComponent: TComponentClass; //类型指针
    FData   : Pointer;           //对象数据
  end;

  TObjectDataType = (dtObject, dtClass, dtComponent);
  //数据类型
  TObjectDeleteAction = (daNone, daFree);
  //删除动作

  TOnFreeObjectDataItemProc = procedure (const nItem: Pointer;
    const nType: TObjectDataType);
  TOnFreeObjectDataItemEvent = procedure (const nItem: Pointer;
    const nType: TObjectDataType) of object;
  //事件定义

  TObjectDataList = class(TObject)
  private
    FDataList: TList;
    //数据列表
    FDataType: TObjectDataType;
    //数据类型
    FDelAction: TObjectDeleteAction;
    //删除执行
    FFreeProc: TOnFreeObjectDataItemProc;
    FFreeEvent: TOnFreeObjectDataItemEvent;
    //释放动作
  protected
    procedure ClearList(const nFree: Boolean);
    //清理资源
    function GetObject(Index: Integer): TObject;
    function GetClass(Index: Integer): TClass;
    function GetComponent(Index: Integer): TComponentClass;
    function GetItemEx(Index: Integer): PObjectDataItem;
    //检索对象
    procedure CheckDataType(const nType: TObjectDataType);
    //验证类型
  public
    constructor Create(const nType: TObjectDataType);
    destructor Destroy; override;
    //创建释放
    function AddItem(const nItem: TObject; const nID: string = '';
     const nData: Pointer = nil): Integer; overload;
    function AddItem(const nItem: TClass; const nID: string = '';
     const nData: Pointer = nil): Integer; overload;
    function AddItem(const nItem: TComponentClass; const nID: string = '';
     const nData: Pointer = nil): Integer; overload;
    //添加对象
    procedure DeleteItem(const nItem: TObject); overload;
    procedure DeleteItem(const nItem: TClass); overload;
    procedure DeleteItem(const nItem: TComponentClass); overload;
    procedure DeleteItem(const nIdx: Integer); overload;
    procedure ClearAll;
    //删除对象
    function Count: Integer;
    function ItemLow: Integer;
    function ItemHigh: Integer;
    //检索边界
    function FindItem(const nItem: TObject): Integer; overload;
    function FindItem(const nItem: TClass): Integer; overload;
    function FindItem(const nItem: TComponentClass): Integer; overload;
    function FindItem(const nID: string): Integer; overload;
    //索引检索
    procedure MoveData(const nDest: TObjectDataList);
    //移动数据
    property DataType: TObjectDataType read FDataType;
    property ObjectA[Index: Integer]: TObject read GetObject;
    property ClassA[Index: Integer]: TClass read GetClass;
    property ComponentA[Index: Integer]: TComponentClass read GetComponent;
    property Item[Index: Integer]: PObjectDataItem read GetItemEx; default;
    property DeleteAction: TObjectDeleteAction read FDelAction write FDelAction;
    property OnFreeProc: TOnFreeObjectDataItemProc read FFreeProc write FFreeProc;
    property OnFreeEvent: TOnFreeObjectDataItemEvent read FFreeEvent write FFreeEvent;
    //属性相关
  end;

  //----------------------------------------------------------------------------
  TObjectPoolNew = function (const nClass: TClass): TObject;
  TObjectPoolFree = procedure (const nObject: TObject);
  //创建释放回调函数

  PObjectPoolItem = ^TObjectPoolItem;
  TObjectPoolItem = record
    FObject: TObject;             //对象
    FUsed: Boolean;               //使用中
  end;

  PObjectPoolDataItem = ^TObjectPoolDataItem;
  TObjectPoolDataItem = record
    FClass: TClass;               //类型
    FNew: TObjectPoolNew;         //创建
    FFree: TObjectPoolFree;       //释放
    FObjectList: TList;           //对象列表
  end;

  TObjectPoolManager = class(TObject)
  private
    FPool: TList;
    //对象池
    FNumLocked: Integer;
    //锁定对象
    FSrvClosed: Integer;
    //服务关闭 
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearPool(const nFree: Boolean);
    procedure ClearList(const nList: TList; const nFree: TObjectPoolFree);
    //清理资源
    function FindPoolData(const nClass: TClass): Integer;
    //检索内容
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure RegClass(const nClass: TClass; const nNew: TObjectPoolNew = nil;
      const nFree: TObjectPoolFree = nil);
    procedure UnregClass(const nClass: TClass);
    //注册新类
    function LockObject(const nClass: TClass): PObjectPoolItem;
    procedure ReleaseObject(const nItem: PObjectPoolItem);
    //锁定释放
  end;

var
  gObjectPoolManager: TObjectPoolManager = nil;
  //全局使用
  
implementation

const
  cYes  = $0002;
  cNo   = $0005;
  
constructor TObjectDataList.Create(const nType: TObjectDataType);
begin
  FDelAction := daFree;
  FDataType := nType;
  FDataList := TList.Create;
end;

destructor TObjectDataList.Destroy;
begin
  ClearList(True);
  inherited;
end;

function TObjectDataList.Count: Integer;
begin
  Result := FDataList.Count;
end;

function TObjectDataList.ItemLow: Integer;
begin
  Result := 0;
end;

function TObjectDataList.ItemHigh: Integer;
begin
  Result := FDataList.Count - 1;
end;

procedure TObjectDataList.ClearAll;
begin
  ClearList(False);
end;

//Desc: 删除索引为nIdx的数据项
procedure TObjectDataList.DeleteItem(const nIdx: Integer);
var nItem: PObjectDataItem;
begin
  if nIdx < ItemLow then Exit;
  nItem := FDataList[nIdx];

  if (FDataType = dtObject) and
     (FDelAction = daFree) and Assigned(nItem.FObject) then
    FreeAndNil(nItem.FObject);
  //xxxxx

  if Assigned(nItem.FData) then
  begin
    if Assigned(FFreeProc) then
      FFreeProc(nItem.FData, FDataType);
    //xxxxx

    if Assigned(FFreeEvent) then
      FFreeEvent(nItem.FData, FDataType);
    //xxxxx
  end;

  Dispose(nItem);
  FDataList.Delete(nIdx);
end;

//Desc: 清空列表
procedure TObjectDataList.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=ItemHigh downto ItemLow do
    DeleteItem(nIdx);
  //xxxxx

  if nFree then
    FreeAndNil(FDataList);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 验证nType类型是否与当前列表类型匹配
procedure TObjectDataList.CheckDataType(const nType: TObjectDataType);
begin
  if nType <> FDataType then
    raise Exception.Create('操作的数据类型与列表不匹配.');
  //xxxxx
end;

//Desc: 添加nItem对象
function TObjectDataList.AddItem(const nItem: TObject; const nID: string;
  const nData: Pointer): Integer;
var nP: PObjectDataItem;
begin
  CheckDataType(dtObject);
  Result := FindItem(nItem);

  if Result < 0 then
  begin
    New(nP);
    Result := FDataList.Add(nP);
  end else nP := FDataList[Result];

  with nP^ do
  begin
    FObject := nItem;
    FItemID := nID;
    FData := nData;
  end;
end;

//Desc: 添加nItem类型
function TObjectDataList.AddItem(const nItem: TClass; const nID: string;
  const nData: Pointer): Integer;
var nP: PObjectDataItem;
begin
  CheckDataType(dtClass);
  Result := FindItem(nItem);

  if Result < 0 then
  begin
    New(nP);
    Result := FDataList.Add(nP);
  end else nP := FDataList[Result];

  with nP^ do
  begin
    FClass := nItem;
    FItemID := nID;
    FData := nData;
  end;
end;

//Desc: 添加nItem组件类型
function TObjectDataList.AddItem(const nItem: TComponentClass;
  const nID: string; const nData: Pointer): Integer;
var nP: PObjectDataItem;
begin
  CheckDataType(dtComponent);
  Result := FindItem(nItem);

  if Result < 0 then
  begin
    New(nP);
    Result := FDataList.Add(nP);
  end else nP := FDataList[Result];

  with nP^ do
  begin
    FComponent := nItem;
    FItemID := nID;
    FData := nData;
  end;
end;

//Desc: 删除nItem对象
procedure TObjectDataList.DeleteItem(const nItem: TObject);
begin
  CheckDataType(dtObject);
  DeleteItem(FindItem(nItem));
end;

//Desc: 删除nItem类型
procedure TObjectDataList.DeleteItem(const nItem: TClass);
begin
  CheckDataType(dtClass);
  DeleteItem(FindItem(nItem));
end;

//Desc: 删除nItem组件类型
procedure TObjectDataList.DeleteItem(const nItem: TComponentClass);
begin
  CheckDataType(dtComponent);
  DeleteItem(FindItem(nItem));
end;

//------------------------------------------------------------------------------
//Desc: 检索nItem对象的索引
function TObjectDataList.FindItem(const nItem: TObject): Integer;
var nIdx: Integer;
begin
  CheckDataType(dtObject);
  Result := -1;

  for nIdx:=ItemLow to ItemHigh do
  if PObjectDataItem(FDataList[nIdx]).FObject = nItem then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: 检索nItem类型的索引
function TObjectDataList.FindItem(const nItem: TClass): Integer;
var nIdx: Integer;
begin
  CheckDataType(dtClass);
  Result := -1;

  for nIdx:=ItemLow to ItemHigh do
  if PObjectDataItem(FDataList[nIdx]).FClass = nItem then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: 检索nItem组件类的索引
function TObjectDataList.FindItem(const nItem: TComponentClass): Integer;
var nIdx: Integer;
begin
  CheckDataType(dtComponent);
  Result := -1;

  for nIdx:=ItemLow to ItemHigh do
  if PObjectDataItem(FDataList[nIdx]).FComponent = nItem then
  begin
    Result := nIdx;
    Break;
  end
end;

//Desc: 检索标识为nID的数据索引
function TObjectDataList.FindItem(const nID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=ItemLow to ItemHigh do
  if CompareText(nID, PObjectDataItem(FDataList[nIdx]).FItemID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;  
end;

function TObjectDataList.GetObject(Index: Integer): TObject;
begin
  CheckDataType(dtObject);
  Result := PObjectDataItem(FDataList[Index]).FObject;
end;

function TObjectDataList.GetClass(Index: Integer): TClass;
begin
  CheckDataType(dtClass);
  Result := PObjectDataItem(FDataList[Index]).FClass;
end;

function TObjectDataList.GetComponent(Index: Integer): TComponentClass;
begin
  CheckDataType(dtComponent);
  Result := PObjectDataItem(FDataList[Index]).FComponent;
end;

function TObjectDataList.GetItemEx(Index: Integer): PObjectDataItem;
begin
  Result := FDataList[Index];
end;

//Desc: 将数据移动到nDest列表中
procedure TObjectDataList.MoveData(const nDest: TObjectDataList);
var nIdx: Integer;
begin
  CheckDataType(nDest.DataType);
  for nIdx:=ItemLow to ItemHigh do
    nDest.FDataList.Add(FDataList[nIdx]);
  FDataList.Clear;
end;

//------------------------------------------------------------------------------
constructor TObjectPoolManager.Create;
begin
  FNumLocked := 0;
  FSrvClosed := cNo;
  
  FPool := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TObjectPoolManager.Destroy;
begin
  FSrvClosed:=cYes;
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
  finally
    FSyncLock.Leave;
  end;

  ClearPool(True);
  FSyncLock.Free;
  inherited;
end;

//Desc: 清理对象池
procedure TObjectPoolManager.ClearPool(const nFree: Boolean);
var nIdx: Integer;
    nItem: PObjectPoolDataItem;
begin
  for nIdx:=FPool.Count - 1 downto 0 do
  begin
    nItem := FPool[nIdx];
    ClearList(nItem.FObjectList, nItem.FFree);

    Dispose(nItem);
    FPool.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FPool);
  //xxxxx
end;

//Desc: 清理对象列表
procedure TObjectPoolManager.ClearList(const nList: TList; const nFree: TObjectPoolFree);
var nIdx: Integer;
    nItem: PObjectPoolItem;
begin
  if Assigned(nList) then
  begin
    for nIdx:=nList.Count - 1 downto 0 do
    begin
      nItem := nList[nIdx];
      if Assigned(nFree) then
           nFree(nItem.FObject)
      else nItem.FObject.Free;
      
      Dispose(nItem);
      nList.Delete(nIdx);
    end;

    nList.Free;
  end;
end;

//Date: 2015-03-02
//Parm: 类型
//Desc: 检索nClass的类型数据
function TObjectPoolManager.FindPoolData(const nClass: TClass): Integer;
var nIdx: Integer;
    nItem: PObjectPoolDataItem;
begin
  Result := -1;

  for nIdx:=FPool.Count - 1 downto 0 do
  begin
    nItem := FPool[nIdx];
    if nItem.FClass = nClass then
    begin
      Result := nIdx;
      Break;
    end;
  end;
end;

//Date: 2015-03-02
//Parm: 类型;创建;释放
//Desc: 注册新类型
procedure TObjectPoolManager.RegClass(const nClass: TClass;
  const nNew: TObjectPoolNew; const nFree: TObjectPoolFree);
var nIdx: Integer;
    nItem: PObjectPoolDataItem;
begin
  FSyncLock.Enter;
  try
    nIdx := FindPoolData(nClass);
    if nIdx < 0 then
    begin
      New(nItem);
      FPool.Add(nItem);

      FillChar(nItem^, SizeOf(TObjectPoolDataItem), #0);
      nItem.FClass := nClass;
    end else nItem := FPool[nIdx];

    nItem.FNew := nNew;
    nItem.FFree := nFree;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-03-02
//Parm: 类型
//Desc: 反注册类型
procedure TObjectPoolManager.UnregClass(const nClass: TClass);
var nIdx: Integer;
    nItem: PObjectPoolDataItem;
begin
  FSyncLock.Enter;
  try
    nIdx := FindPoolData(nClass);
    if nIdx >= 0 then
    begin
      nItem := FPool[nIdx];
      ClearList(nItem.FObjectList, nItem.FFree);

      Dispose(nItem);
      FPool.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-03-02
//Parm: 对象类型
//Desc: 返回nClass的对象指针
function TObjectPoolManager.LockObject(const nClass: TClass): PObjectPoolItem;
var nIdx: Integer;
    nItem: PObjectPoolDataItem;
begin
  Result := nil;
  if FSrvClosed = cYes then Exit;

  FSyncLock.Enter;
  try
    if FSrvClosed = cYes then Exit;
    nIdx := FindPoolData(nClass);
    if nIdx < 0 then Exit;

    nItem := FPool[nIdx];
    if not Assigned(nItem.FObjectList) then
      nItem.FObjectList := TList.Create;
    //xxxxx

    for nIdx:=nItem.FObjectList.Count - 1 downto 0 do
    begin
      Result := nItem.FObjectList[nIdx];
      if not Result.FUsed then
           Break
      else Result := nil;
    end;

    if not Assigned(Result) then
    begin
      New(Result);
      nItem.FObjectList.Add(Result);

      if Assigned(nItem.FNew) then
           Result.FObject := nItem.FNew(nItem.FClass)
      else Result.FObject := nItem.FClass.Create;
    end;

    Result.FUsed := True;
  finally
    if Assigned(Result) then
      Inc(FNumLocked);
    FSyncLock.Leave;
  end;
end;

//Date: 2015-03-02
//Parm: 对象指针
//Desc: 释放对象
procedure TObjectPoolManager.ReleaseObject(const nItem: PObjectPoolItem);
begin
  if Assigned(nItem) then
  try
    FSyncLock.Enter;
    nItem.FUsed := False;
    Dec(FNumLocked);
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gObjectPoolManager := nil;
finalization
  FreeAndNil(gObjectPoolManager);
end.
