unit ULogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Layouts, FMX.Edit, FMX.Controls.Presentation,
  FMX.Objects;

type
  TfrmLogin = class(TfrmFormBase)
    Label1: TLabel;
    Label2: TLabel;
    EditUser: TEdit;
    EditPsd: TEdit;
    cbSavePsd: TCheckBox;
    cbAutoLogin: TCheckBox;
    BtnLogin: TButton;
    BtnExit: TButton;
    Layout_Menu: TLayout;
    Panel_Menu: TPanel;
    ScrollBox_Menu: TScrollBox;
    Rectangle_Menu: TRectangle;
    BtnSet: TButton;
    BtnExit2: TButton;
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtnSetClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation
uses FMX.PlatForm.Android,                  //MainActivity
     UBusinessConst, USysBusiness,
     UUserSetup, UMainFrom;
{$R *.fmx}

procedure TfrmLogin.BtnExitClick(Sender: TObject);
begin
  inherited;
  SaveParamToIni;
  MainActivity.finish;
end;

procedure TfrmLogin.BtnLoginClick(Sender: TObject);
begin
  inherited;
  with gSysParam do
  begin
    FSavePswd := cbSavePsd.IsChecked;
    FAutoLogin:= cbAutoLogin.IsChecked;

    FOperator := Trim(EditUser.Text);
    FPassword := Trim(EditPsd.Text);

    FHasLogin := Login;
    if FHasLogin then MainForm.Show;
  end;
end;

procedure TfrmLogin.BtnSetClick(Sender: TObject);
begin
  inherited;
  Layout_Menu.Visible := False;
  if not Assigned(FrmSetup) then
     FrmSetup := TFrmSetup.Create(Self);
  FrmSetup.Show;
end;

procedure TfrmLogin.FormActivate(Sender: TObject);
begin
  inherited;
  cbSavePsd.IsChecked  := gSysParam.FSavePswd;
  cbAutoLogin.IsChecked:= gSysParam.FAutoLogin;

  EditUser.Text        := gSysParam.FOperator;
  EditPsd.Text         := gSysParam.FPassword;
end;

procedure TfrmLogin.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  inherited;
  if Key = vkHardwareBack then//如果按下物理返回键
  begin
    if Layout_Menu.Visible then Layout_Menu.Visible := False
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

end.
