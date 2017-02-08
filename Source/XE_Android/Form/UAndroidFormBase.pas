unit UAndroidFormBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Controls.Presentation, FMX.Layouts,
  FMX.VirtualKeyboard, FMX.Platform;

type
  TfrmFormBase = class(TForm)
    MainVertScrollBox: TScrollBox;
    MainLayout: TLayout;
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
    procedure EditMouseEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    // 键盘操作相关
    FKBBounds: TRectF;
    FNeedOffset: Boolean;
    FService: IFMXVirtualKeyboardToolbarService;
    FService_kb: FMX.VirtualKeyboard.IFMXVirtualKeyboardService;

    procedure UpdateKBBounds;
    procedure RestorePosition;
    procedure CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
  public
    { Public declarations }
  end;

var
  frmFormBase: TfrmFormBase;

implementation

{$R *.fmx}

procedure TfrmFormBase.FormCreate(Sender: TObject);
begin
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
  IInterface(FService_kb));
  if TPlatformServices.Current.SupportsPlatformService
  (IFMXVirtualKeyboardToolbarService, IInterface(FService)) then
  begin
    FService.SetToolbarEnabled(true);
    FService.SetHideKeyboardButtonVisibility(true);
  end;
  MainVertScrollBox.OnCalcContentBounds := CalcContentBoundsProc;
end;

procedure TfrmFormBase.FormFocusChanged(Sender: TObject);
begin
  UpdateKBBounds;
end;

procedure TfrmFormBase.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;//标识不需要重设所有控件的位置
  RestorePosition;
end;

procedure TfrmFormBase.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := ScreenToClient(FKBBounds.BottomRight);
  UpdateKBBounds;
end;

procedure TfrmFormBase.EditMouseEnter(Sender: TObject);
begin
  { Android: 有些输入法有隐藏键(如 qq， 百度等), 当虚拟键盘按下隐藏键后(不会触发
  VirtualKeyboardOnHide 事件), 此时再点击编辑框，则再不会显示虚拟键盘,
  所以这里判断下在已经有焦点时，再次触发显示。 IOS: 暂未测试 }
  {$IFDEF ANDROID}
  if TEdit(Sender).IsFocused and Assigned(FService_kb) then
  try
    FService_kb.ShowVirtualKeyboard(TEdit(Sender));
  except
  end;
  {$ENDIF}
end;

function Max(const x, y: Single): Single;
begin
  if x>y then
       Result := x
  else Result := y;
end;

procedure TfrmFormBase.CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
begin
  if FNeedOffset and (FKBBounds.Top > 0) then
  begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FKBBounds.Top);
  end;
end;

procedure TfrmFormBase.RestorePosition; //还原所有控件的位置
begin
  MainVertScrollBox.ViewportPosition := PointF(MainVertScrollBox.ViewportPosition.X, 0);
  MainLayout.Align := TAlignLayout.alClient;
  MainVertScrollBox.RealignContent;
end;

//Discrpit:重设所有控件的位置，让其向上移动一个虚拟键盘的高度
procedure TfrmFormBase.UpdateKBBounds;
var
  LFocused: TControl;
  LFocusRect: TRectF;
begin
  FNeedOffset := False;
  //xxxxx

  if Assigned(Focused) then
  begin
    LFocused := TControl(Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(MainVertScrollBox.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and
    (LFocusRect.Bottom > FKBBounds.Top) then
    begin
      FNeedOffset := True;

      Application.ProcessMessages;
      MainLayout.Align := TAlignLayout.alHorizontal;

      MainVertScrollBox.RealignContent;
      MainVertScrollBox.ViewportPosition :=PointF(MainVertScrollBox.ViewportPosition.X,
                                        LFocusRect.Bottom - FKBBounds.Top);
      //xxxx
    end;
  end;

  if not FNeedOffset then
    RestorePosition;
end;

end.
