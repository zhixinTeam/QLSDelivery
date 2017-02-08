unit UFormWeiXinBindUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit, cxGroupBox, cxRadioGroup;

type
  TfFormWeiXinBindUser = class(TfFormNormal)
    cxTextEditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxRadioGroupBind: TcxRadioGroup;
    dxLayout1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormWeiXinBindUser: TfFormWeiXinBindUser;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm;

class function TfFormWeiXinBindUser.FormID: integer;
begin
  Result := cFI_FormWeixinBind;
end;

class function TfFormWeiXinBindUser.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormWeiXinBindUser.Create(Application) do
  begin
    Caption := '∞Û∂®”√ªß';
    ShowModal;
    Free;
  end;
end;

procedure TfFormWeiXinBindUser.FormCreate(Sender: TObject);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormWeiXinBindUser.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormWeiXinBindUser.BtnOKClick(Sender: TObject);
var
  nMsg:string;
  nList:TStrings;
begin
  try
    nList:=TStringList.Create;
    with nList do
    begin
      Values['Phone']:=trim(cxTextEditPhone.Text);
      Values['IsBind']:=IntToStr(cxRadioGroupBind.ItemIndex);
    end;
    nMsg:=GetBindUser(PackerEncodeStr(nList.Text));
    ShowMsg(nMsg,sHint);
  finally
    nList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormWeiXinBindUser,TfFormWeiXinBindUser.FormID);
end.
