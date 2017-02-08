{*******************************************************************************
  作者: dmzn@163.com 2011-11-14
  描述: 中间件数据通道管理器
*******************************************************************************}
unit UMgrChannel;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, uROClient, uROWinInetHttpChannel,
  uROBinMessage, UObjectStatus;

type
  PChannelItem = ^TChannelItem;
  TChannelItem = record
    FUsed: Boolean;                //是否占用
    FType: Integer;                //通道类型
    FChannel: IUnknown;            //通道对象

    FMsg: TROBinMessage;           //消息对象
    FHttp: TROWinInetHTTPChannel;  //通道对象
  end;

  TChannelManager = class(TStatusObjectBase)
  private
    FChannels: TList;
    //通道列表
    FMaxCount: Integer;
    //通道峰值
    FLock: TCriticalSection;
    //同步锁
    FNumLocked: Integer;
    //锁定个数
    FFreeing: Integer;
    FClearing: Integer;
    //对象状态
  protected
    function GetCount: Integer;
    procedure SetChannelMax(const nValue: Integer);
    //属性处理
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function LockChannel(const nType: Integer = -1): PChannelItem;
    procedure ReleaseChannel(const nChannel: PChannelItem);
    //通道处理
    procedure ClearChannel;
    //清理通道
    procedure GetStatus(const nList: TStrings); override;
    //对象状态
    property ChannelCount: Integer read GetCount;
    property ChannelMax: Integer read FMaxCount write SetChannelMax;
    //属性相关
  end;

var
  gChannelManager: TChannelManager = nil;
  //全局使用

implementation

const
  cYes  = $0002;
  cNo   = $0005;

constructor TChannelManager.Create;
begin
  FMaxCount := 5;
  FNumLocked := 0;

  FFreeing := cNo;
  FClearing := cNo;
  
  FChannels := TList.Create;
  FLock := TCriticalSection.Create;

  if Assigned(gObjectStatusManager) then
    gObjectStatusManager.AddObject(Self);
  //xxxxx
end;

destructor TChannelManager.Destroy;
begin
  InterlockedExchange(FFreeing, cYes);
  ClearChannel;
  FChannels.Free;

  if Assigned(gObjectStatusManager) then
    gObjectStatusManager.DelObject(Self);
  //xxxxx
  
  FLock.Free;
  inherited;
end;

//Desc: 清理通道对象
procedure TChannelManager.ClearChannel;
var nIdx: Integer;
    nItem: PChannelItem;
begin
  InterlockedExchange(FClearing, cYes);
  //set clear flag

  FLock.Enter;
  try
    if FNumLocked > 0 then
    try
      FLock.Leave;
      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FLock.Enter;
    end;

    for nIdx:=FChannels.Count - 1 downto 0 do
    begin
      nItem := FChannels[nIdx];
      FChannels.Delete(nIdx);

      with nItem^ do
      begin
        if Assigned(FHttp) then FreeAndNil(FHttp);
        if Assigned(FMsg) then FreeAndNil(FMsg);

        if Assigned(FChannel) then FChannel := nil;
        Dispose(nItem);
      end;
    end;
  finally
    InterlockedExchange(FClearing, cNo);
    FLock.Leave;
  end;
end;

//Desc: 通道数量
function TChannelManager.GetCount: Integer;
begin
  FLock.Enter;
  Result := FChannels.Count;
  FLock.Leave;
end;

//Desc: 最大通道数
procedure TChannelManager.SetChannelMax(const nValue: Integer);
begin
  FLock.Enter;
  FMaxCount := nValue;
  FLock.Leave;
end;

//Desc: 锁定通道
function TChannelManager.LockChannel(const nType: Integer): PChannelItem;
var nIdx,nFit: Integer;
    nItem: PChannelItem;
begin
  Result := nil; 
  if FFreeing = cYes then Exit;
  if FClearing = cYes then Exit;

  FLock.Enter;
  try
    if FFreeing = cYes then Exit;
    if FClearing = cYes then Exit;
    nFit := -1;

    for nIdx:=0 to FChannels.Count - 1 do
    begin
      nItem := FChannels[nIdx];
      if nItem.FUsed then Continue;

      with nItem^ do
      begin
        if (nType > -1) and (FType = nType) then
        begin
          Result := nItem;
          Exit;
        end;

        if nFit < 0 then
          nFit := nIdx;
        //first idle

        if nType < 0 then
          Break;
        //no check type
      end;
    end;

    if FChannels.Count < FMaxCount then
    begin
      New(nItem);
      FChannels.Add(nItem);

      with nItem^ do
      begin
        FType := nType;
        FChannel := nil;

        FMsg := TROBinMessage.Create;
        FHttp := TROWinInetHTTPChannel.Create(nil);
      end;

      Result := nItem;
      Exit;
    end;

    if nFit > -1 then
    begin
      Result := FChannels[nFit];
      Result.FType := nType;
      Result.FChannel := nil;
    end;
  finally
    if Assigned(Result) then
    begin
      Result.FUsed := True;
      InterlockedIncrement(FNumLocked);
    end;
    FLock.Leave;
  end;
end;

//Desc: 释放通道
procedure TChannelManager.ReleaseChannel(const nChannel: PChannelItem);
begin
  if Assigned(nChannel) then
  begin
    FLock.Enter;
    try
      nChannel.FUsed := False;
      InterlockedDecrement(FNumLocked);
    finally
      FLock.Leave;
    end;
  end;
end;

procedure TChannelManager.GetStatus(const nList: TStrings);
begin
  FLock.Enter;
  try
    nList.Add('MaxCount: ' + #9 + IntToStr(FMaxCount));
    nList.Add('ChannelCount: ' + #9 + IntToStr(FChannels.Count));
    nList.Add('ChannelLocked: ' + #9 + IntToStr(FNumLocked));
  finally
    FLock.Leave;
  end;
end;

initialization
  gChannelManager := nil;
finalization
  FreeAndNil(gChannelManager);
end.
