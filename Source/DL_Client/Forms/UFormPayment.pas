{*******************************************************************************
  作者: dmzn@163.com 2010-3-17
  描述: 销售回款
*******************************************************************************}
unit UFormPayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxButtonEdit, cxMCListBox,
  cxLabel, cxMemo, cxTextEdit, cxMaskEdit, cxDropDownEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormPayment = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDesc: TcxMemo;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item8: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditSalesMan: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditName: TcxComboBox;
    dxGroup3: TdxLayoutGroup;
    dxLayout1Item12: TdxLayoutItem;
    EditIn: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditOut: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Group4: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Private declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure InitFormData(const nID: string);
    //载入数据
    procedure ClearCustomerInfo;
    function LoadCustomerInfo(const nID: string): Boolean;
    //载入客户
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule, 
  USysDB, USysConst, USysBusiness;

type
  TCommonInfo = record
    FCusID: string;
    FCusName: string;
    FSaleMan: string;
  end;

var
  gInfo: TCommonInfo;
  //全局使用

//------------------------------------------------------------------------------
class function TfFormPayment.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin 
  Result := nil;
  if not WorkPCHasPopedom then Exit;
  nP := nParam;

  with TfFormPayment.Create(Application) do
  try
    Caption := '货款回收';
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
  finally
    Free;
  end;
end;

class function TfFormPayment.FormID: integer;
begin
  Result := cFI_FormPayment;
end;

procedure TfFormPayment.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormPayment.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormPayment.InitFormData(const nID: string);
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  LoadSaleMan(EditSalesMan.Properties.Items);

  LoadSysDictItem(sFlag_PaymentItem2, EditType.Properties.Items);
  EditType.ItemIndex := 0;
  
  if nID <> '' then
  begin
    ActiveControl := EditMoney;
    LoadCustomerInfo(nID);
  end else ActiveControl := EditID;
end;

//Desc: 清理客户信息
procedure TfFormPayment.ClearCustomerInfo;
begin
  ListInfo.Clear;
  EditIn.Text := '0';
  EditOut.Text := '0';

  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;
end;

//Desc: 载入nID客户的信息
function TfFormPayment.LoadCustomerInfo(const nID: string): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  ClearCustomerInfo;
  nDS := USysBusiness.LoadCustomerInfo(nID, ListInfo, nStr);
  
  Result := Assigned(nDS);
  BtnOK.Enabled := Result;

  if not Result then
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  with nDS,gInfo do       
  begin
    FCusID := nID;
    FCusName := FieldByName('C_Name').AsString;
    FSaleMan := FieldByName('C_SaleMan').AsString;
  end;

  EditID.Text := nID;
  SetCtrlData(EditSalesMan, gInfo.FSaleMan);

  if GetStringsItemIndex(EditName.Properties.Items, nID) < 0 then
  begin
    nStr := Format('%s=%s.%s', [nID, nID, gInfo.FCusName]);
    InsertStringsItem(EditName.Properties.Items, nStr);
  end;
  SetCtrlData(EditName, nID);

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    EditIn.Text := Format('%.2f', [FieldByName('A_InMoney').AsFloat]);
    EditOut.Text := Format('%.2f', [FieldByName('A_OutMoney').AsFloat]);
  end;

  ActiveControl := EditMoney;
end;

procedure TfFormPayment.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormPayment.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormPayment.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('请填写有效编号', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

//Desc: 选择客户
procedure TfFormPayment.EditNameKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    nP.FParamA := GetCtrlData(EditName);
    
    if nP.FParamA = '' then
      nP.FParamA := EditName.Text;
    //xxxxx

    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditSalesMan, nP.FParamD);
    SetCtrlData(EditName, nP.FParamB);
    
    if EditName.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditName.Properties.Items, nStr);
      SetCtrlData(EditName, nP.FParamB);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfFormPayment.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditName then
  begin
    Result := EditName.ItemIndex > -1;
    nHint := '请选择有效的客户';
  end else

  if Sender = EditType then
  begin
    Result := Trim(EditType.Text) <> '';
    nHint := '请填写付款方式';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True) and
              (Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <> 0);
    nHint := '请填写有效的金额';
  end;
end;

procedure TfFormPayment.BtnOKClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if not IsDataValid then Exit;
  if not SaveCustomerPayment(gInfo.FCusID, gInfo.FCusName,
     GetCtrlData(EditSalesMan), sFlag_MoneyHuiKuan, EditType.Text, EditDesc.Text,
     StrToFloat(EditMoney.Text), True) then
  begin
    ShowMsg('回款操作失败', sError); Exit;
  end;

  if StrToFloat(EditMoney.Text) > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    nP.FParamA := gInfo.FCusName;
    nP.FParamB := '销售回款或预付款';
    nP.FParamC := EditMoney.Text;
    CreateBaseFormItem(cFI_FormShouJu, '', @nP);
  end;

  ModalResult := mrOk;
  ShowMsg('回款操作成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPayment, TfFormPayment.FormID);
end.
