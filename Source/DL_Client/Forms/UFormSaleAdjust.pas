{*******************************************************************************
  作者: dmzn@163.com 2014-09-30
  描述: 销售调拨

  备注:
  *.调拨指A出厂的货发到B处
*******************************************************************************}
unit UFormSaleAdjust;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxListView,
  cxDropDownEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMCListBox,
  dxLayoutControl, StdCtrls;

type
  TfFormSaleAdjust = class(TfFormNormal)
    dxLayout1Item7: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item8: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditSalesMan: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditName: TcxComboBox;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListDetail: TcxListView;
    dxLayout1Item4: TdxLayoutItem;
    EditZK: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure EditZKPropertiesEditValueChanged(Sender: TObject);
  protected
    { Private declarations }
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
  USysGrid, USysDB, USysConst, USysBusiness;

class function TfFormSaleAdjust.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormSaleAdjust.Create(Application) do
  try
    Caption := '销售调拨';
    InitFormData('');
    ShowModal;
  finally
    Free;
  end;
end;

class function TfFormSaleAdjust.FormID: integer;
begin
  Result := cFI_FormSaleAdjust;
end;

procedure TfFormSaleAdjust.FormCreate(Sender: TObject);
begin
  LoadMCListBoxConfig(Name, ListInfo);
  LoadcxListViewConfig(Name, ListDetail);
end;

procedure TfFormSaleAdjust.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveMCListBoxConfig(Name, ListInfo);
  SavecxListViewConfig(Name, ListDetail);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormSaleAdjust.InitFormData(const nID: string);
begin
  dxGroup1.AlignVert := avTop;
  ActiveControl := EditName; 
  LoadSaleMan(EditSalesMan.Properties.Items);
end;

//Desc: 清理客户信息
procedure TfFormSaleAdjust.ClearCustomerInfo;
begin
  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;

  ListInfo.Clear;
  ActiveControl := EditName;
end;

//Desc: 载入nID客户的信息
function TfFormSaleAdjust.LoadCustomerInfo(const nID: string): Boolean;
var nDS: TDataSet;
    nStr,nCusName,nSaleMan: string;
begin
  ClearCustomerInfo;
  nDS := USysBusiness.LoadCustomerInfo(nID, ListInfo, nStr);

  Result := Assigned(nDS);
  BtnOK.Enabled := Result;

  if not Result then
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  with nDS do
  begin
    nCusName := FieldByName('C_Name').AsString;
    nSaleMan := FieldByName('C_SaleMan').AsString;
  end;
  
  EditID.Text := nID;
  SetCtrlData(EditSalesMan, nSaleMan);

  if GetStringsItemIndex(EditName.Properties.Items, nID) < 0 then
  begin
    nStr := Format('%s=%s.%s', [nID, nID, nCusName]);
    InsertStringsItem(EditName.Properties.Items, nStr);
  end;

  SetCtrlData(EditName, nID);
  //customer info done

  //----------------------------------------------------------------------------
  nStr := 'Z_ID=Select Z_ID, Z_Name From %s ' +
          'Where Z_Customer=''%s'' And Z_ValidDays>%s Order By Z_ID';
  nStr := Format(nStr, [sTable_ZhiKa, nID, sField_SQLServer_Now]);

  with EditZK.Properties do
  begin
    AdjustStringsItem(Items, True);
    FDM.FillStringsData(Items, nStr, 0, '.');
    AdjustStringsItem(Items, False);

    if Items.Count > 0 then
      EditZK.ItemIndex := 0;
    //xxxxx

    ActiveControl := BtnOK;
    //准备开单
  end;
end;

procedure TfFormSaleAdjust.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormSaleAdjust.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormSaleAdjust.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('请填写有效编号', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

procedure TfFormSaleAdjust.EditZKPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  ListDetail.Clear;
  if EditZK.ItemIndex < 0 then Exit;

  nStr := 'Select D_StockName,D_Price,D_Value From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, GetCtrlData(EditZK)]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 0 then Exit;
    //no data
    First;

    while not Eof do
    begin
      with ListDetail.Items.Add do
      begin
        Checked := True;
        Caption := Fields[0].AsString;
        SubItems.Add(Format('%.2f',[Fields[1].AsFloat]));
        SubItems.Add(Format('%.2f',[Fields[2].AsFloat]));
      end;

      Next;
    end;
  end;
end;

//Desc: 选择客户
procedure TfFormSaleAdjust.EditNameKeyPress(Sender: TObject; var Key: Char);
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

initialization
  gControlManager.RegCtrl(TfFormSaleAdjust, TfFormSaleAdjust.FormID);
end.
