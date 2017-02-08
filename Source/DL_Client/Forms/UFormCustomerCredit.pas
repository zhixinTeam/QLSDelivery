{*******************************************************************************
  作者: dmzn@163.com 2010-3-17
  描述: 信用变动
*******************************************************************************}
unit UFormCustomerCredit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxDropDownEdit, cxCalendar,
  cxMemo, cxLabel, cxTextEdit, cxMaskEdit, dxLayoutControl, StdCtrls;

type
  TfFormCustomerCredit = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    EditSaleMan: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditCus: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditCredit: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    EditEnd: TcxDateEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSaleManPropertiesChange(Sender: TObject);
    procedure EditCusKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //基类方法
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UFormBase, UMgrControl, UAdjustForm, USysDB, USysConst, USysBusiness,
  UDataModule;

class function TfFormCustomerCredit.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not WorkPCHasPopedom then Exit;
  nP := nParam;

  with TfFormCustomerCredit.Create(Application) do
  begin
    Caption := '信用变动';
    if Assigned(nP) then
    begin
      InitFormData(nP.FParamA);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else
    begin
      InitFormData('');
      ShowModal;
    end;
    Free;
  end;
end;

class function TfFormCustomerCredit.FormID: integer;
begin
  Result := cFI_FormCusCredit;
end;

procedure TfFormCustomerCredit.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormCustomerCredit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormCustomerCredit.InitFormData(const nID: string);
var nStr: string;
begin
  EditEnd.Date := Now + 1;
  LoadSaleMan(EditSaleMan.Properties.Items);

  if nID <> '' then
  begin
    nStr := 'Select C_SaleMan From %s Where C_ID=''%s''';
    nStr := Format(nStr, [sTable_Customer, nID]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      SetCtrlData(EditSaleMan, Fields[0].AsString);
      SetCtrlData(EditCus, nID);
    end;
  end;
end;

procedure TfFormCustomerCredit.EditSaleManPropertiesChange(
  Sender: TObject);
var nStr: string;
begin
  if EditSaleMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSaleMan)]);
    LoadCustomer(EditCus.Properties.Items, nStr);
  end;
end;

//Desc: 快速选择客户
procedure TfFormCustomerCredit.EditCusKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    nP.FParamA := GetCtrlData(EditCus);

    if nP.FParamA = '' then
      nP.FParamA := EditCus.Text;
    //xxxxx

    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditSaleMan, nP.FParamD);
    SetCtrlData(EditCus, nP.FParamB);

    if EditCus.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditCus.Properties.Items, nStr);
      SetCtrlData(EditCus, nP.FParamB);
    end;
  end;
end;

function TfFormCustomerCredit.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditCus then
  begin
    Result := EditCus.ItemIndex >= 0;
    nHint := '请选择有效的客户';
  end else

  if Sender = EditCredit then
  begin
    Result := IsNumber(EditCredit.Text, True);
    nHint := '请填写有效的金额';
  end else

  if Sender = EditEnd then
  begin
    Result := EditEnd.Date > Now;
    nHint := '有效期应大于当前日期';
  end;
end;

//Desc: 授信
procedure TfFormCustomerCredit.BtnOKClick(Sender: TObject);
begin
  if IsDataValid and SaveCustomerCredit(GetCtrlData(EditCus), EditMemo.Text,
     StrToFloat(EditCredit.Text), EditEnd.Date) then
  begin
    ModalResult := mrOk;
    ShowMsg('授信成功', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormCustomerCredit, TfFormCustomerCredit.FormID);
end.
