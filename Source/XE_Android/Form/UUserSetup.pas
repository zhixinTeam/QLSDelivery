unit UUserSetup;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmSetup = class(TfrmFormBase)
    Label1: TLabel;
    BtnCancel: TSpeedButton;
    BtnSave: TSpeedButton;
    EditPort: TEdit;
    Label4: TLabel;
    EditServIP: TEdit;
    Label3: TLabel;
    EditPsw: TEdit;
    Label2: TLabel;
    EditUser: TEdit;
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditUserChange(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSetup: TFrmSetup;

implementation
uses UBusinessConst, System.IniFiles, System.IOUtils, UBase64;

{$R *.fmx}

procedure TFrmSetup.BtnCancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TFrmSetup.BtnSaveClick(Sender: TObject);
begin
  with gSysParam do
  begin
    FOperator := EditUser.Text;
    FPassword := EditPsw.Text;

    FServIP   := EditServIP.Text;
    FServPort := StrToIntDef(EditPort.Text, 8082);
  end;

  //SaveParamToIni;
  Close;
end;

procedure TFrmSetup.EditUserChange(Sender: TObject);
begin
  inherited;
  if Trim(EditUser.Text) = 'admin' then
  begin
    EditPort.ReadOnly := False;
    EditServIP.ReadOnly := False;
  end;
end;

procedure TFrmSetup.FormActivate(Sender: TObject);
begin
  inherited;
  EditServIP.ReadOnly := True;
  EditPort.ReadOnly   := True;
  with gSysParam do
  begin
    EditUser.Text := FOperator;
    EditPsw.Text  := FPassword;

    EditServIP.Text:= FServIP;
    EditPort.Text := IntToStr(FServPort);
  end;
end;

procedure TFrmSetup.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//如果按下物理返回键
  begin
    MessageDlg('确认退出吗？', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //退出程序

    Key := 0;//必须的，不然按否也会退出
    Exit;
  end;}
end;

end.
