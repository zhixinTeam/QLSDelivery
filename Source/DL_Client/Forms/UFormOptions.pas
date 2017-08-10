{*******************************************************************************
  作者: dmzn@163.com 2017-07-06
  描述: 系统设置
*******************************************************************************}
unit UFormOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, StdCtrls, cxPC,
  dxLayoutControl;

type
  TfFormOptions = class(TfFormNormal)
    wPage: TcxPageControl;
    dxLayout1Item3: TdxLayoutItem;
    cxSheet1: TcxTabSheet;
    Label5: TLabel;
    EditShadow: TcxTextEdit;
    Label1: TLabel;
    procedure wPageChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditShadowPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData;
    procedure LoadBaseParam;
    procedure SaveBaseParam;
    //基本参数
  public
    { Public declarations }
    class function FormID: integer; override;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    //base
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  UAdjustForm;

type
  TSysParam = record
    FLoaded: Boolean;
    FSaved: Boolean;
    FShadowWeight: Double;
  end;

var
  gSysParam: TSysParam;
  //系统参数
  
class function TfFormOptions.FormID: integer;
begin
  Result := cFI_FormOptions;
end;

class function TfFormOptions.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormOptions.Create(Application) do
  begin
    InitFormData;
    ShowModal;
    Free;
  end;
end;

procedure TfFormOptions.InitFormData;
begin
  wPage.ActivePage := cxSheet1;
  LoadBaseParam;
end;

//------------------------------------------------------------------------------
procedure TfFormOptions.LoadBaseParam;
var nStr: string;
begin
  with gSysParam do
  begin
    FLoaded := True;
    FSaved := True;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[1].AsString = sFlag_ShadowWeight then
        gSysParam.FShadowWeight := Fields[0].AsFloat;
      //xxxxx

      Next;
    end;
  end;

  with gSysParam do
  begin
    EditShadow.Text := FloatToStr(FShadowWeight);
  end;
end;

procedure TfFormOptions.SaveBaseParam;
var nStr: string;
begin
  with gSysParam do
  begin
    nStr := 'Update %s Set D_Value=''%f'' Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, FShadowWeight, sFlag_SysParam,
            sFlag_ShadowWeight]);
    FDM.ExecuteSQL(nStr);

    FSaved := True;
  end;
end;

procedure TfFormOptions.EditShadowPropertiesChange(Sender: TObject);
begin
  with gSysParam do
  begin
    if Sender = EditShadow then
    begin
      if IsNumber(EditShadow.Text, True) then
      begin
        FShadowWeight := StrToFloat(EditShadow.Text);
        FSaved := False;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormOptions.wPageChange(Sender: TObject);
begin
  case wPage.ActivePageIndex of
   0: if not gSysParam.FLoaded then LoadBaseParam;
  end;
end;

//Desc: 保存数据
procedure TfFormOptions.BtnOKClick(Sender: TObject);
begin
  with gSysParam do
    if FLoaded and (not FSaved) then SaveBaseParam;
  //xxxxx

  ModalResult := mrOk;
  ShowMsg('保存完毕', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormOptions, TfFormOptions.FormID);
end.
