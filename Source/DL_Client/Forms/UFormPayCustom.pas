{*******************************************************************************
  作者: dmzn@163.com 2010-3-17
  描述: 销售退购
*******************************************************************************}
unit UFormPayCustom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxLabel, cxMemo, cxTextEdit,
  cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit, dxLayoutControl,
  StdCtrls, cxControls, cxButtonEdit, cxMCListBox, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TfFormPayCustom = class(TfFormNormal)
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
    dxLayout1Group2: TdxLayoutGroup;
    EditCard: TcxButtonEdit;
    dxLayout1Item11: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCardPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
  protected
    { Private declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure GetSaveSQLList(const nList: TStrings); override;
    //基类方法
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
class function TfFormPayCustom.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  nP := nParam;
  Result := nil;

  with TfFormPayCustom.Create(Application) do
  begin
    Caption := '销售退购';
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

class function TfFormPayCustom.FormID: integer;
begin
  Result := cFI_FormPayCustom;
end;

procedure TfFormPayCustom.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormPayCustom.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormPayCustom.InitFormData(const nID: string);
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  LoadSaleMan(EditSalesMan.Properties.Items);

  LoadSysDictItem(sFlag_PaymentItem2, EditType.Properties.Items);
  EditType.ItemIndex := 0;

  if nID <> '' then
  begin
    ActiveControl := EditMoney;
    LoadCustomerInfo(nID);
  end else ActiveControl := EditCard;
end;

//Desc: 清理客户信息
procedure TfFormPayCustom.ClearCustomerInfo;
begin
  ListInfo.Clear;
  dxGroup2.Caption := '资金返还';

  if not EditID.Focused then EditID.Clear;
  if not EditCard.Focused then EditCard.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;
end;

//Desc: 载入nID客户的信息
function TfFormPayCustom.LoadCustomerInfo(const nID: string): Boolean;
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
  
  nStr := Format('可用金额: %.2f元', [GetCustomerValidMoney(gInfo.FCusID)]);
  dxGroup2.Caption := nStr;
end;

procedure TfFormPayCustom.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormPayCustom.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormPayCustom.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('请填写有效编号', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

procedure TfFormPayCustom.EditCardPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  ClearCustomerInfo;
  EditCard.Text := Trim(EditCard.Text);
  
  if EditCard.Text = '' then
  begin
    EditCard.SetFocus;
    ShowMsg('请填写有效卡号', sHint); Exit;
  end;

  nStr := 'Select Z_Custom From %s,%s Where Z_ID=C_ZID And C_Card=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sTable_ZhiKaCard, EditCard.Text]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
         LoadCustomerInfo(Fields[0].AsString)
    else ShowMsg('没有该卡对应的客户', sHint);
  end;
end;

//Desc: 选择客户
procedure TfFormPayCustom.EditNameKeyPress(Sender: TObject; var Key: Char);
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
function TfFormPayCustom.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
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
    nHint := '请填写支付方式';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True) and
              (StrToFloat(EditMoney.Text) > 0);
    nHint := '请填写有效的金额';

    if not Result then Exit;
    nVal := GetCustomerValidMoney(gInfo.FCusID);
    Result := Float2PInt(nVal, cPrecision, False) >=
              Float2PInt(StrToFloat(EditMoney.Text), cPrecision, True);
    //xxxxx

    if not Result then
    begin
      nHint := '已超出可返还最大金额';
      dxGroup2.Caption := Format('可用金额: %.2f元', [nVal]);
    end;
  end;
end;

procedure TfFormPayCustom.GetSaveSQLList(const nList: TStrings);
var nStr: string;
begin
  nStr := 'Update %s Set A_Compensation=A_Compensation+%s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, EditMoney.Text, gInfo.FCusID]);
  nList.Add(nStr);

  nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,' +
          'M_Type,M_Payment,M_Money,M_Date,M_Man,M_Memo) ' +
          'Values(''%s'',''%s'',''%s'',''%s'',''%s'',%s,%s,''%s'',''%s'')';
  nStr := Format(nStr, [sTable_InOutMoney, GetCtrlData(EditSalesMan),
          gInfo.FCusID, gInfo.FCusName, sFlag_MoneyFanHuan, EditType.Text,
          EditMoney.Text, FDM.SQLServerNow, gSysParam.FUserID, EditDesc.Text]);
  nList.Add(nStr);
end;

initialization
  gControlManager.RegCtrl(TfFormPayCustom, TfFormPayCustom.FormID);
end.
