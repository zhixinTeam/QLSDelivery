{*******************************************************************************
  作者: dmzn@163.com 2015-08-06
  描述: 注册管理系统对象的运行状态
*******************************************************************************}
unit UObjectStatus;

interface

uses
  Windows, Classes, SysUtils;

type
  TStatusObjectBase = class(TObject)
  protected
    procedure GetStatus(const nList: TStrings); virtual; abstract;
    //对象状态
  end;

  TObjectStatusManager = class(TObject)
  private
    FObjects: TList;
    //对象列表
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure AddObject(const nObj: TObject);
    procedure DelObject(const nObj: TObject);
    //添加删除
    procedure GetStatus(const nList: TStrings);
    //获取状态
  end;

var
  gObjectStatusManager: TObjectStatusManager = nil;
  //全局使用

implementation

constructor TObjectStatusManager.Create;
begin
  FObjects := TList.Create;
end;

destructor TObjectStatusManager.Destroy;
begin
  FObjects.Free;
  inherited;
end;

procedure TObjectStatusManager.AddObject(const nObj: TObject);
begin
  if not (nObj is TStatusObjectBase) then
    raise Exception.Create(ClassName + ': Object Is Not Support.');
  FObjects.Add(nObj);
end;

procedure TObjectStatusManager.DelObject(const nObj: TObject);
var nIdx: Integer;
begin
  nIdx := FObjects.IndexOf(nObj);
  if nIdx > -1 then
    FObjects.Delete(nIdx);
  //xxxxx
end;

procedure TObjectStatusManager.GetStatus(const nList: TStrings);
var nIdx,nLen: Integer;
begin
  nList.BeginUpdate;
  try
    nList.Clear;
    //init

    for nIdx:=0 to FObjects.Count - 1 do
    with TStatusObjectBase(FObjects[nIdx]) do
    begin
      if nIdx <> 0 then
        nList.Add('');
      //xxxxx

      nLen := Trunc((85 - Length(ClassName)) / 2);
      nList.Add(StringOfChar('+', nLen) + ' ' + ClassName + ' ' +
                StringOfChar('+', nLen));
      GetStatus(nList);
    end;
  finally
    nList.EndUpdate;
  end;
end;

initialization
  gObjectStatusManager := nil;
finalization
  FreeAndNil(gObjectStatusManager);
end.
