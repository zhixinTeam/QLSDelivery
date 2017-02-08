unit UFormWeixinReg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit;

type
  TfFormWeixinReg = class(TfFormNormal)
    cxTextEditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormWeixinReg: TfFormWeixinReg;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm;

class function TfFormWeixinReg.FormID: integer;
begin
  Result := cFI_FormWeixinReg;
end;

class function TfFormWeixinReg.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormWeixinReg.Create(Application) do
  begin
    Caption := 'Î¢ÐÅ×¢²á';
    ShowModal;
    Free;
  end;
end;

procedure TfFormWeixinReg.BtnOKClick(Sender: TObject);
var
  nMsg:string;
begin
  try
    nMsg:=GetCustomerInfo(PackerEncodeStr(Trim(cxTextEditPhone.Text)));
    ShowMsg(nMsg, sHint);
  finally

  end;
end;

procedure TfFormWeixinReg.FormCreate(Sender: TObject);
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

procedure TfFormWeixinReg.FormClose(Sender: TObject;
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

initialization
  gControlManager.RegCtrl(TfFormWeixinReg,TfFormWeixinReg.FormID);
end.
