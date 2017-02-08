unit UMainFrom;

interface

uses
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Nfc,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts;

type
  TMainForm = class(TForm)
    ScaledLayout: TScaledLayout;
    Layout_Menu: TLayout;
    Panel_Menu: TPanel;
    ScrollBox_Menu: TScrollBox;
    Rectangle_Menu: TRectangle;
    BtnSet: TButton;
    BtnExit2: TButton;
    BtnReadCard: TSpeedButton;
    BtnExit: TSpeedButton;
    BtnSetup: TSpeedButton;
    Label1: TLabel;
    BtnLogin: TButton;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnReadCardClick(Sender: TObject);
    procedure BtnTruckClick(Sender: TObject);
    procedure BtnSetupClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure BtnSetClick(Sender: TObject);
    procedure ScrollBox_MenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnLoginClick(Sender: TObject);
  private
    { Private declarations }
    function UserLogin: Boolean;
    procedure RegisterDelphiNativeMethods;
  public
    { Public declarations }
    procedure OnNewIntent(Intent: JIntent);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  UUserSetup, UReadCard, USearchTruck, ULogin,  // Forms
  UBase64, UBusinessConst, USysBusiness, UNFCManager,//Bussiness

  FMX.PlatForm.Android,                  //MainActivity
  FMX.Helpers.Android,
  Androidapi.NativeActivity,
  Androidapi.Helpers,
  Androidapi.JNIBridge,

  Androidapi.JNI,
  Androidapi.JNI.Os,
  Androidapi.JNI.Toast,
  Androidapi.JNI.JavaTypes;

{ TMainForm }

{$REGION 'JNI setup code and callback'}
procedure OnNewIntentNative(PEnv: PJNIEnv; This: JNIObject; NewIntent: JNIObject); cdecl;
begin
  Log.d('Queuing native routine to run synchronized');
  TThread.Queue(nil,
    procedure
    begin
      Log.d('+ThreadSwitcher');
      Log.d('Thread: Main: %.8x, Current: %.8x, Java:%.8d (%2:.8x)', [MainThreadID, TThread.CurrentThread.ThreadID,
        TJThread.JavaClass.CurrentThread.getId]);
      MainForm.OnNewIntent(TJIntent.Wrap(NewIntent));
      Log.d('-ThreadSwitcher');
    end);
end;

procedure TMainForm.RegisterDelphiNativeMethods;
var
  PEnv: PJNIEnv;
  ActivityClass: JNIClass;
  NativeMethod: JNINativeMethod;
begin
  Log.d('Starting the registration JNI stuff');

  PEnv := TJNIResolver.GetJNIEnv;

  Log.d('Registering interop method');

  NativeMethod.Name := 'onNewIntentNative';
  NativeMethod.Signature := '(Landroid/content/Intent;)V';
  NativeMethod.FnPtr := @OnNewIntentNative;

  ActivityClass := PEnv^.GetObjectClass(PEnv,
    PANativeActivity(System.DelphiActivity).clazz);

  PEnv^.RegisterNatives(PEnv, ActivityClass, @NativeMethod, 1);

  PEnv^.DeleteLocalRef(PEnv, ActivityClass);
end;
{$ENDREGION}

procedure TMainForm.BtnExitClick(Sender: TObject);
begin
  SaveParamToIni;
  MainActivity.finish;
end;

procedure TMainForm.BtnLoginClick(Sender: TObject);
begin
  gSysParam.FHasLogin := False;
  if not Assigned(frmLogin) then
     frmLogin := TfrmLogin.Create(Self);
  frmLogin.Show;
end;

procedure TMainForm.BtnReadCardClick(Sender: TObject);
begin
  if not Assigned(FrmReadCard) then
     FrmReadCard := TFrmReadCard.Create(Self);
  FrmReadCard.Show;
end;

procedure TMainForm.BtnSetClick(Sender: TObject);
begin
  Layout_Menu.Visible := False;
  if not Assigned(FrmSetup) then
     FrmSetup := TFrmSetup.Create(Self);
  FrmSetup.Show;
end;

procedure TMainForm.BtnSetupClick(Sender: TObject);
begin
  if not Assigned(FrmSetup) then
     FrmSetup := TFrmSetup.Create(Self);
  FrmSetup.Show;
end;

procedure TMainForm.BtnTruckClick(Sender: TObject);
begin
  if not Assigned(FrmGetTruck) then
     FrmGetTruck := TFrmGetTruck.Create(Self);
  FrmGetTruck.Show;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  nIntent: JIntent;
begin
  Log.d('OnActivate');

  if not UserLogin then Exit;

  with gNFCManager do
  begin
    if HasNFC then
    begin
      if not IsNFCEnabled then
      begin
        Toast('请在系统设置中开启NFC功能');
        SetNFCEnabled;
      end;
    end;
  end;

  nIntent := SharedActivity.getIntent;
  if not TJIntent.JavaClass.ACTION_MAIN.equals(nIntent.getAction) then
  begin
    Log.d('Passing along received intent');
    OnNewIntent(nIntent);
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveParamToIni;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Log.d('OnCreate');
  LoadParamFromIni;
  RegisterDelphiNativeMethods;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkHardwareBack then//如果按下物理返回键
  begin
    if Layout_Menu.Visible then  Layout_Menu.Visible := False
    else
    MessageDlg('确认退出吗？', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnExitClick(Self);
      end
      );
      //退出程序

    Key := 0;//必须的，不然按否也会退出
    Exit;
  end;

  if Key = vkMenu then
  begin
    Layout_Menu.Visible := not Layout_Menu.Visible;
    Key := 0;
  end;
end;

//以下调整菜单的尺寸
procedure TMainForm.FormResize(Sender: TObject);
begin
  //Panel_SubMenu.Height := Panel_Menu.Height - Rectangle_Menu.Height;
  // 保证在窗口的最下面

  if Self.Width > self.Height then // 保证菜单的宽度 284
       Rectangle_Menu.Margins.Right := ScrollBox_Menu.Width - (284 + 50)
  else Rectangle_Menu.Margins.Right := 50;
  // 以上调整菜单的尺寸
end;

procedure TMainForm.ScrollBox_MenuClick(Sender: TObject);
begin
  Layout_menu.Visible := false;// 隐藏菜单
end;


procedure TMainForm.OnNewIntent(Intent: JIntent);
begin
  if not UserLogin then Exit;

  SharedActivity.setIntent(Intent);

  if Assigned(Intent) then
  begin
    gNFCManager.DoNFCReceived(Intent);
    BtnReadCard.OnClick(Self);
  end;
end;

function TMainForm.UserLogin:Boolean;
begin
  if not gSysParam.FHasLogin then
  begin
    if not Assigned(frmLogin) then
     frmLogin := TfrmLogin.Create(Self);
    frmLogin.Show;
  end;

  Result := gSysParam.FHasLogin;
end;

end.
