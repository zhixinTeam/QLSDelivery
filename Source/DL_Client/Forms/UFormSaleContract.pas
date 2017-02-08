{*******************************************************************************
  作者: dmzn@163.com 2009-6-12
  描述: 销售合同管理
*******************************************************************************}
unit UFormSaleContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxLabel,
  cxCheckBox, cxTextEdit, cxDropDownEdit, cxMCListBox, cxMaskEdit,
  cxButtonEdit, StdCtrls, cxMemo;

type
  TfFormSaleContract = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditID: TcxButtonEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    dxLayoutControl1Group9: TdxLayoutGroup;
    dxLayoutControl1Group2: TdxLayoutGroup;
    StockList1: TcxMCListBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditSalesMan: TcxComboBox;
    dxLayoutControl1Item5: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditCustomer: TcxComboBox;
    dxLayoutControl1Item6: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayoutControl1Item7: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    EditPayment: TcxComboBox;
    dxLayoutControl1Item12: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    dxLayoutControl1Group6: TdxLayoutGroup;
    dxLayoutControl1Group7: TdxLayoutGroup;
    EditName: TcxTextEdit;
    dxLayoutControl1Item14: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayoutControl1Item15: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayoutControl1Item16: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item17: TdxLayoutItem;
    dxLayoutControl1Group8: TdxLayoutGroup;
    EditDate: TcxButtonEdit;
    dxLayoutControl1Item19: TdxLayoutItem;
    cxButtonEdit1: TcxButtonEdit;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group10: TdxLayoutGroup;
    Check1: TcxCheckBox;
    dxLayoutControl1Item18: TdxLayoutItem;
    EditDays: TcxTextEdit;
    dxLayoutControl1Item20: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayoutControl1Item21: TdxLayoutItem;
    dxLayoutControl1Group11: TdxLayoutGroup;
    dxLayoutControl1Group12: TdxLayoutGroup;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group13: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure StockList1Click(Sender: TObject);
    procedure EditValueExit(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSalesManKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSalesManPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FContractID: string;
    //合同标识
    FPrefixID: string;
    //前缀编号
    FIDLength: integer;
    //前缀长度
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
  DB, IniFiles, ULibFun, UFormCtrl, UAdjustForm, UMgrControl, UFormBaseInfo,
  USysBusiness, USysGrid, USysDB, USysConst;

var
  gForm: TfFormSaleContract = nil;
  //全局使用

class function TfFormSaleContract.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormSaleContract.Create(Application) do
    begin
      FContractID := '';
      Caption := '合同 - 添加';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormSaleContract.Create(Application) do
    begin
      FContractID := nP.FParamA;
      Caption := '合同 - 修改';

      InitFormData(FContractID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormSaleContract.Create(Application);
        with gForm do
        begin
          Caption := '合同 - 查看';
          FormStyle := fsStayOnTop;
          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FContractID := nP.FParamA;
        InitFormData(FContractID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormSaleContract.FormID: integer;
begin
  Result := cFI_FormSaleContract;
end;

//------------------------------------------------------------------------------
procedure TfFormSaleContract.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, StockList1, nIni);

    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'HT');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
  finally
    nIni.Free;
  end;

  EditDate.Text := DateTime2Str(Now);
  ResetHintAllForm(Self, 'T', sTable_SaleContract);
  //重置表名称
end;

procedure TfFormSaleContract.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, StockList1, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormSaleContract.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormSaleContract.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 将nDS的数据与nStockList现有数据合并
procedure LoadStockList(const nDS: TDataSet; const nStockList: TcxMCListBox);
var nList: TStrings;
    i,nCount: integer;
begin
  nList := TStringList.Create;
  try
    nCount := nStockList.Items.Count - 1;
    for i:=0 to nCount do
    begin
      SplitStr(nStockList.Items[i], nList, 0, nStockList.Delimiter);
      if nList.Count > 1 then
      begin
        nStockList.Items[i] := CombinStr([nList[0], nList[1],
             '0', '0', '0', '0', nList[6]], nStockList.Delimiter);
      end else Continue;

      if nDS.RecordCount < 1 then
           Continue
      else nDS.First;
      
      while not nDS.Eof do
      begin
        if nDS.FieldByName('E_StockNo').AsString = nList[6] then
        begin
          nStockList.Items[i] := CombinStr([nList[0], nList[1],
                  nDS.FieldByName('E_Value').AsString,
                  nDS.FieldByName('E_Price').AsString,
                  nDS.FieldByName('E_Money').AsString,
                  nDS.FieldByName('E_Price').AsString,
                  nList[6]], nStockList.Delimiter);
          Break;
        end;
        nDS.Next;
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2009-6-2
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormSaleContract.InitFormData(const nID: string);
var nStr: string;
    nArray: TDynamicStrArray;
begin
  if EditPayment.Properties.Items.Count < 1 then
  begin
    EditPayment.Clear;
    nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                        MI('$Name', sFlag_PaymentItem)]);
    //数据字典中付款方式信息项

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        EditPayment.Properties.Items.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  end;

  if EditSalesMan.Properties.Items.Count < 1 then
  begin
    nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
            'Where S_InValid<>''%s'' Order By S_PY';
    nStr := Format(nStr, [sTable_Salesman, sFlag_Yes]);

    SetLength(nArray, 1);
    nArray[0] := 'S_ID';
    FDM.FillStringsData(EditSalesMan.Properties.Items, nStr, -1, '.', nArray);
    AdjustStringsItem(EditSalesMan.Properties.Items, False);
  end;

  if StockList1.Items.Count < 1 then
  begin
    nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                        MI('$Name', sFlag_StockItem)]);
    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := CombinStr([FieldByName('D_Memo').AsString,
                FieldByName('D_Value').AsString,
                '0', '0', '0', '0',
                FieldByName('D_ParamB').AsString], StockList1.Delimiter);
        StockList1.Items.Add(nStr);
        Next;
      end;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where C_ID=''%s''';
    nStr := Format(nStr, [sTable_SaleContract, nID]);

    LoadDataToCtrl(FDM.QuerySQL(nStr), Self);
    Check1.Checked := FDM.SqlQuery.FieldByName('C_XuNi').AsString = sFlag_Yes;

    nStr := 'Select * From %s Where E_CID=''%s''';
    nStr := Format(nStr, [sTable_SContractExt, nID]);
    LoadStockList(FDM.QueryTemp(nStr), StockList1);
  end;
end;

//Desc: 业务员变更,提取相关客户
procedure TfFormSaleContract.EditSalesManPropertiesEditValueChanged(
  Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    AdjustCXComboBoxItem(EditCustomer, True);
    nStr := 'C_ID=Select C_ID,C_Name From %s Where C_SaleMan=''%s''';
    nStr := Format(nStr, [sTable_Customer, GetCtrlData(EditSalesMan)]);

    FDM.FillStringsData(EditCustomer.Properties.Items, nStr, -1, '.');
    AdjustCXComboBoxItem(EditCustomer, False);
  end;
end;

//Desc: 生成随机编号
procedure TfFormSaleContract.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := FDM.GetSerialID(FPrefixID, sTable_SaleContract, 'C_ID');
end;

//Desc: 当前时间
procedure TfFormSaleContract.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  TcxButtonEdit(Sender).Text := DateTime2Str(Now);
end;

//Desc: 选择区域
procedure TfFormSaleContract.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nBool,nSelected: Boolean;
begin
  nBool := True;
  nSelected := True;

  with ShowBaseInfoEditForm(nBool, nSelected, '区域', '', sFlag_AreaItem) do
  begin
    if nSelected then TcxButtonEdit(Sender).Text := FText;
  end;
end;

//Desc: 快速定位
procedure TfFormSaleContract.EditSalesManKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var i,nCount: integer;
    nBox: TcxComboBox;
begin
  if Key = 13 then
  begin
    Key := 0;
    nBox := Sender as TcxComboBox;

    nCount := nBox.Properties.Items.Count - 1;
    for i:=0 to nCount do
    if Pos(LowerCase(nBox.Text), LowerCase(nBox.Properties.Items[i])) > 0 then
    begin
      nBox.ItemIndex := i; Break;
    end;
  end;
end;

//Desc: 显示明细数据
procedure TfFormSaleContract.StockList1Click(Sender: TObject);
var nStr: string;
    nList: TStrings;
begin
  if StockList1.ItemIndex < 0 then
       Exit
  else nList := TStringList.Create;

  try
    nStr := StockList1.Items[StockList1.ItemIndex];
    if SplitStr(nStr, nList, 7, StockList1.Delimiter) then
    begin
      EditName.Text := nList[1];
      EditValue.Text := nList[2];
      EditPrice.Text := nList[3];
      EditMoney.Text := nList[4];

      EditValue.SetFocus;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 离开焦点时确认输入
procedure TfFormSaleContract.EditValueExit(Sender: TObject);
var nStr: string;
    nList: TStrings;
begin
  if (StockList1.ItemIndex < 0) or (not (Sender is TcxTextEdit)) then Exit;
  if not TcxTextEdit(Sender).EditModified then Exit;

  nList := TStringList.Create;
  try
    nStr := StockList1.Items[StockList1.ItemIndex];
    if SplitStr(nStr, nList, 7, StockList1.Delimiter) then
    begin
      if not IsNumber(EditValue.Text, True) then EditValue.Text := '0';
      if not IsNumber(EditPrice.Text, True) then EditPrice.Text := '0';

      if Sender <> EditMoney then
        EditMoney.Text := FloatToStr(StrToFloat(EditValue.Text) *
                                     StrToFloat(EditPrice.Text));
      if not IsNumber(EditMoney.Text, True) then EditMoney.Text := '0';

      nList[2] := EditValue.Text;
      nList[3] := EditPrice.Text;
      nList[4] := EditMoney.Text;

      nStr := StockList1.Delimiter;
      StockList1.Items[StockList1.ItemIndex] := CombinStr(nList, nStr);
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 保存数据
procedure TfFormSaleContract.BtnOKClick(Sender: TObject);
var nList: TStrings;
    nStr,nSQL: string;
    i,nCount: integer;
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMsg('请填写有效的合同编号', sHint); Exit;
  end;

  if (not IsNumber(EditDays.Text, False)) Or (StrToInt(EditDays.Text) < 0 ) then
  begin
    EditDays.SetFocus;
    ShowMsg('请填写有效的时长', sHint); Exit;
  end;

  nList := TStringList.Create;
  try
    if Check1.Checked then
         nStr := 'C_XuNi=''$Y'''
    else nStr := 'C_XuNi=''$N''';
    nList.Text := MacroValue(nStr, [MI('$Y', sFlag_Yes), MI('$N', sFlag_No)]); 

    if FContractID = '' then
    begin
      nStr := 'Select Count(*) From %s Where C_ID=''%s''';
      nStr := Format(nStr, [sTable_SaleContract, EditID.Text]);
      //查询编号是否存在

      with FDM.QueryTemp(nStr) do
       if Fields[0].AsInteger > 0 then
       begin
         nList.Free;
         EditID.SetFocus;
         ShowMsg('该编号的合同已经存在', sHint); Exit;
       end;

       nSQL := MakeSQLByForm(Self, sTable_SaleContract, '', True, nil, nList);
    end else
    begin
      EditID.Text := FContractID;
      nStr := 'C_ID=''' + FContractID + '''';
      nSQL := MakeSQLByForm(Self, sTable_SaleContract, nStr, False, nil, nList);
    end;

    FDM.ADOConn.BeginTrans;
    FDM.ExecuteSQL(nSQL);

    if FContractID <> '' then
    begin
      nSQL := 'Delete From %s Where E_CID=''%s''';
      nSQL := Format(nSQL, [sTable_SContractExt, FContractID]);
      FDM.ExecuteSQL(nSQL);
    end;

    nCount := StockList1.Items.Count - 1; 
    for i:=0 to nCount do
    if SplitStr(StockList1.Items[i], nList, 7, StockList1.Delimiter) then
    begin
      if nList[2] = '0' then Continue;
      //数量为0不予保存

      nStr := MakeSQLByStr([SF('E_CID', EditID.Text),
              SF('E_Type', nList[0]),
              SF('E_StockName', nList[1]),
              SF('E_Value', nList[2], sfVal),
              SF('E_Price', nList[3], sfVal),
              SF('E_Money', nList[4], sfVal),
              SF('E_StockNo', nList[6])
              ], sTable_SContractExt, '', True);
      FDM.ExecuteSQL(nStr);

      if (FContractID <> '') and (nList[3] <> nList[5]) and (nList[5] <> '0') then
      begin
        nStr := '品种[ %s ]单价由[ %s ] 改为[ %s ]';
        nStr := Format(nStr, [nList[1], nList[5], nList[3]]);
        FDM.WriteSysLog(sFlag_ContractItem, EditID.Text, nStr, False);
      end;
    end;

    nList.Free;
    FDM.ADOConn.CommitTrans;
    PrintSaleContractReport(EditID.Text, True);

    ModalResult := mrOK;
    ShowMsg('数据已保存', sHint);
  except
    nList.Free;
    FDM.ADOConn.RollbackTrans;
    ShowMsg('数据保存失败', '未知原因');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormSaleContract, TfFormSaleContract.FormID);
end.
