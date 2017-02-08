{*******************************************************************************
  作者: dmzn@163.com 2011-01-26
  描述: 开发票
*******************************************************************************}
unit UFormInvoiceK;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, cxGraphics, dxLayoutControl, cxMemo, cxTextEdit,
  cxMCListBox, cxDropDownEdit, cxCalendar, cxContainer, cxEdit, cxMaskEdit,
  cxButtonEdit, StdCtrls, cxControls, cxLookAndFeels, cxLookAndFeelPainters;

type
  PInvoiceDataItem = ^TInvoiceDataItem;
  TInvoiceDataItem = record
    FRecordID: string;    //记录 
    FStockType: string;   //类型
    FStockName: string;   //品种
    FPrice: Double;       //提货价
    FKPrice: Double;      //开票价
    FZPrice: Double;      //折扣价

    FValue: Double;       //待开量
    FKValue: Double;      //已开量 
  end;

  PKInvoiceParam = ^TKInvoiceParam;
  TKInvoiceParam = record
    FWeek: string;        //开票周期
    FFlag: string;        //发票标记(申请,日常等)

    FSaleID: string;      //业务员名
    FSaleMan: string;     //业务员号
    FCusID: string;       //客户编号
    FCustomer: string;    //客户名称
  end;

  TfFormInvoiceK = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditInvoice: TcxComboBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditZheKou: TcxTextEdit;
    dxLayoutControl1Item4: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    ListDetail: TcxMCListBox;
    dxLayoutControl1Item7: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group7: TdxLayoutGroup;
    EditZK: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    dxLayoutControl1Group6: TdxLayoutGroup;
    EditCus: TcxTextEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    EditSale: TcxTextEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    dxLayoutControl1Group9: TdxLayoutGroup;
    dxLayoutControl1Group3: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListDetailClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditValueFocusChanged(Sender: TObject);
  private
    { Private declarations }
    FDataItem: TList;
    //数据项
    FParam: PKInvoiceParam;
    //选项
    FDetailIndex: Integer;
    //明细索引
    procedure InitFormData(const nData: TList);
    procedure LoadDetailList(const nData: TList);
    procedure LoadInvoice(const nID: string);
    //载入数据
  public
    { Public declarations }
  end;

procedure ClearInvoiceDataItemList(const nList: TList; const nFree: Boolean);
function ShowSaleKInvioceForm(const nData: TList; nParam: PKInvoiceParam): Boolean;
procedure ShowInvoiceInfoForm(const nID: string);
procedure CloseInvoiceInfoForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysGrid, USysDB, USysConst,
  USysFun, USysBusiness;

var
  gForm: TfFormInvoiceK = nil;
  //global use

//Desc: 依据nData开发票
function ShowSaleKInvioceForm(const nData: TList; nParam: PKInvoiceParam): Boolean;
begin
  with TfFormInvoiceK.Create(Application) do
  begin
    Caption := '开发票';
    FParam := nParam;
    FDataItem := nData;

    InitFormData(nData);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

procedure ShowInvoiceInfoForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormInvoiceK.Create(Application);
    with gForm do
    begin
      Caption := '发票 - 明细';
      FormStyle := fsStayOnTop;
      BtnOK.Visible := False;
      FDataItem := TList.Create;
    end;
  end;

  gForm.LoadInvoice(nID);
  if not gForm.Showing then gForm.Show;
end;

procedure CloseInvoiceInfoForm;
begin
  FreeAndNil(gForm);
end;

//Desc: 清理列表
procedure ClearInvoiceDataItemList(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PInvoiceDataItem(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then nList.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceK.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FDetailIndex := -1;
  //no item
  
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListDetail, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoiceK.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListDetail);
  finally
    nIni.Free;
  end;

  Action := caFree;
  if not (fsModal in FormState) then
  begin
    gForm := nil;
    ClearInvoiceDataItemList(FDataItem, True);
  end;
end;

procedure TfFormInvoiceK.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormInvoiceK.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-10-12
//Parm: 待开票明细
//Desc: 载入nData明细到界面
procedure TfFormInvoiceK.InitFormData(const nData: TList);
var nStr: string;
begin
  EditCus.Text := FParam.FCustomer;
  EditSale.Text := FParam.FSaleMan;
  LoadDetailList(nData);

  if EditInvoice.Properties.Items.Count < 1 then
  begin
    nStr := 'Select I_ID From %s Where I_Status=''%s'' Order By I_ID';
    nStr := Format(nStr, [sTable_Invoice, sFlag_InvNormal]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        EditInvoice.Properties.Items.Add(Fields[0].AsString);
        Next;
      end;
    end;
  end;
end;

//Desc: 载入开票明细
procedure TfFormInvoiceK.LoadDetailList(const nData: TList);
var nStr: string;
    nV,nZ: Double;
    i,nCount,nIdx: integer;
begin
  nIdx := ListDetail.ItemIndex;
  ListDetail.Items.BeginUpdate;
  try
    nV := 0; nZ := 0;
    ListDetail.Items.Clear;
    nCount := nData.Count - 1;

    for i:=0 to nCount do
    with PInvoiceDataItem(nData[i])^ do
    begin
      nV := nV + FKPrice * FKValue;
      nZ := nZ + Float2Float(FZPrice * FKValue, cPrecision, False);

      nStr := CombinStr([FStockName, Format('%.2f', [FPrice]),
              Format('%.2f', [FKPrice]), Format('%.2f', [FValue]),
              Format('%.2f', [FKValue])], ListDetail.Delimiter);
      ListDetail.Items.Add(nStr);
    end;

    EditMoney.Text := Format('%.2f', [nV]);
    EditZheKou.Text := Format('%.2f', [nZ]);
  finally
    ListDetail.Items.EndUpdate;
    ListDetail.ItemIndex := nIdx;
  end;
end;

//Desc: 载入nID发票的明细
procedure TfFormInvoiceK.LoadInvoice(const nID: string);
var nStr: string;
    nItem: PInvoiceDataItem;
begin
  nStr := 'Select I_SaleMan,I_Customer,I_Memo From %s Where I_ID=''%s''';
  nStr := Format(nStr, [sTable_Invoice, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    EditInvoice.Properties.ReadOnly := True;
    EditInvoice.Properties.DropDownListStyle := lsEditList;
    EditInvoice.Text := nID;

    EditSale.Text := Fields[0].AsString;
    EditCus.Text := Fields[1].AsString;
    EditMemo.Text := Fields[2].AsString;
  end else Exit;

  ClearInvoiceDataItemList(FDataItem, False);
  nStr := 'Select * From %s Where D_Invoice=''%s''';
  nStr := Format(nStr, [sTable_InvoiceDtl, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      New(nItem);
      FDataItem.Add(nItem);

      with nItem^ do
      begin
        FStockType := FieldByName('D_Type').AsString;
        FStockName := FieldByName('D_Stock').AsString;
        FPrice := FieldByName('D_Price').AsFloat;
        FKPrice := FieldByName('D_KPrice').AsFloat;
        FZPrice := FieldByName('D_DisCount').AsFloat;
        FValue := FieldByName('D_Value').AsFloat;
        FKValue := FValue;
      end;

      Next;
    end;
  end;

  LoadDetailList(FDataItem);
end;

//Desc: 显示明细
procedure TfFormInvoiceK.ListDetailClick(Sender: TObject);
var nIdx: Integer;
begin
  nIdx := ListDetail.ItemIndex;
  if nIdx < 0 then Exit;

  with PInvoiceDataItem(FDataItem[nIdx])^ do
  begin
    EditStock.Text := FStockName;
    EditPrice.Text := Format('%.2f', [FKPrice]);
    EditValue.Text := Format('%.2f', [FKValue]);
    EditZK.Text := Format('%.2f', [FZPrice * FKValue]);

    FDetailIndex := nIdx;
    //明细被激活
  end;
end;

//Desc: 设置数据
procedure TfFormInvoiceK.EditValueFocusChanged(Sender: TObject);
var nVal: Double;
begin
  if FDetailIndex < 0 then Exit;
  if EditValue.IsFocused then Exit;
  if not IsNumber(EditValue.Text, True) then Exit;

  nVal := Float2Float(StrToFloat(EditValue.Text), cPrecision, False);
  if nVal < 0 then Exit;
  if PInvoiceDataItem(FDataItem[FDetailIndex]).FKValue = nVal then Exit;

  with PInvoiceDataItem(FDataItem[FDetailIndex])^ do
  begin
    if nVal > Float2Float(FValue, cPrecision, False) then
    begin
      ShowMsg('已超出可开票吨数', sHint); Exit;
    end;

    FKValue := nVal;
    EditZK.Text := Format('%.2f', [FZPrice * FKValue]);
    LoadDetailList(FDataItem);
  end;
end;

//Desc: 保存数据
procedure TfFormInvoiceK.BtnOKClick(Sender: TObject);
var nVal: Double;
    nStr,nSQL: string;
    i,nCount: integer;
begin
  if EditInvoice.ItemIndex < 0 then
  begin
    EditInvoice.SetFocus;
    ShowMsg('请选择有效的发票号', sHint); Exit;
  end;

  nSQL := 'Select Count(*) From %s Where I_ID=''%s'' And I_Status=''%s''';
  nSQL := Format(nSQL, [sTable_Invoice, EditInvoice.Text, sFlag_InvNormal]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger < 1 then
  begin
    EditInvoice.SetFocus;
    ShowMsg('该发票已无效', sHint); Exit;
  end;

  if Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <= 0 then
  begin
    ShowMsg('开票量为零,不用保存!', sHint); Exit;
  end;

  if StrToFloat(EditZheKou.Text) <> 0 then
  begin
    nStr := '客户[ %s ]有折扣,将为其账户返还资金[ %s ]元.' + #13#10 +
            '要继续吗?';
    nStr := Format(nStr, [EditCus.Text, EditZheKou.Text]);
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  FDM.ADOConn.BeginTrans;
  with FParam^ do
  try
    nSQL := MakeSQLByStr([Format('I_Week=''%s''', [FParam.FWeek]),
            Format('I_CusID=''%s''', [FCusID]),
            Format('I_Customer=''%s''', [FCustomer]),
            Format('I_SaleID=''%s''', [FSaleID]),
            Format('I_SaleMan=''%s''', [FSaleMan]),
            Format('I_Status=''%s''', [sFlag_InvHasUsed]),
            Format('I_Flag=''%s''', [FParam.FFlag]),
            Format('I_OutMan=''%s''', [gSysParam.FUserID]),
            Format('I_OutDate=%s', [FDM.SQLServerNow]),
            Format('I_Memo=''%s''', [EditMemo.Text])],
            sTable_Invoice, Format('I_ID=''%s''', [EditInvoice.Text]), False);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Insert Into %s(D_Invoice, D_Type, D_Stock, D_Price, D_Value,' +
            'D_KPrice, D_DisCount, D_DisMoney) Values(''%s'', ''$Type'', ' +
            '''$Stock'', $Price, $Value, $KPrice, $ZK, $ZMon)';
    nSQL := Format(nSQL, [sTable_InvoiceDtl, EditInvoice.Text]);

    nCount := FDataItem.Count - 1;
    for i:=0 to nCount do
    with PInvoiceDataItem(FDataItem[i])^ do
    begin
      nVal := Float2Float(FZPrice * FKValue, cPrecision, False);
      //折扣金额

      nStr := MacroValue(nSQL, [MI('$Type', FStockType),
              MI('$Stock', FStockName), MI('$Price', FloatToStr(FPrice)),
              MI('$Value', FloatToStr(FKValue)), MI('$KPrice', FloatToStr(FKPrice)),
              MI('$ZK', FloatToStr(FZPrice)), MI('$ZMon', FloatToStr(nVal))]);
      FDM.ExecuteSQL(nStr);
    end;

    nSQL := 'Update %s Set R_KValue=R_KValue+$Value Where R_ID=$ID';
    nSQL := Format(nSQL, [sTable_InvoiceReq, FParam.FWeek]);
    //更新申请已开

    nCount := FDataItem.Count - 1;
    for i:=0 to nCount do
    with PInvoiceDataItem(FDataItem[i])^ do
    begin
      nStr := MacroValue(nSQL, [MI('$Value', FloatToStr(FKValue)),
                                MI('$ID', FRecordID)]);
      FDM.ExecuteSQL(nStr);
    end;

    nVal := StrToFloat(EditZheKou.Text);
    nVal := -nVal;
    //补偿金与折扣相反

    if nVal <> 0 then
    begin
      nStr := Format('开发票[ %s ]时折扣返还', [EditInvoice.Text]);
      if not SaveCompensation(FSaleID, FCusID, FCustomer, '结算折扣',
        nStr, nVal) then raise Exception.Create('');
    end;

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOk;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('保存数据失败', sError);
  end;
end;

end.
