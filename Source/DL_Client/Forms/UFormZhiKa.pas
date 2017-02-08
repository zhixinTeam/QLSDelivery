{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 纸卡办理
*******************************************************************************}
unit UFormZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, cxContainer, cxEdit, Menus,
  cxDropDownEdit, cxCalendar, cxCheckBox, cxLabel, cxMaskEdit,
  cxButtonEdit, cxTextEdit, cxListView, dxLayoutControl, StdCtrls,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  dxLayoutcxEditAdapters;

type
  TStockItem = record
   FStock: string;
   FType: string;
   FName: string;
   FPrice: Double;
   FValue: Double;
   FSelected: Boolean;
  end;

  TZhiKaItem = record
    FContract: string;
    FIsXuNi: Boolean;
    FIsValid: Boolean;
    
    FSaleMan: string;
    FSaleName: string;
    FSalePY: string;
    FCustomer: string;
    FCusName: string;
  end;

  TfFormZhiKa = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    ListDetail: TcxListView;
    dxLayout1Item3: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditCID: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditPName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditSMan: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditCustom: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    EditPayment: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    EditMoney: TcxTextEdit;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item16: TdxLayoutItem;
    cxLabel2: TcxLabel;
    Check1: TcxCheckBox;
    dxLayout1Item17: TdxLayoutItem;
    EditDays: TcxDateEdit;
    dxLayout1Item18: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSManPropertiesEditValueChanged(Sender: TObject);
    procedure EditCIDExit(Sender: TObject);
    procedure ListDetailClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure EditCIDKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure EditCustomKeyPress(Sender: TObject; var Key: Char);
    procedure EditPricePropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FRecordID: string;
    //记录编号
    FItemIndex: Integer;
    //记录索引
    FZhiKa: TZhiKaItem;
    FStockList: array of TStockItem;
    //纸卡信息
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //基类方法
    procedure InitFormData(const nID: string);
    //载入数据
    procedure LoadStockList;
    procedure LoadStockListSummary;
    //水泥列表
    procedure LoadSaleContract(const nCID: string);
    //载入合同
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, UFrameBase,
  USysGrid, USysDB, USysConst, USysBusiness, UDataModule;

var
  gForm: TfFormZhiKa = nil;

//------------------------------------------------------------------------------
class function TfFormZhiKa.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
    nD: TFormCommandParam;
begin
  Result := nil;
  nD.FCommand := cCmd_AddData;

  if Assigned(nParam) then
       nP := nParam
  else nP := @nD;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormZhiKa.Create(Application) do
    begin
      FRecordID := '';
      Caption := '纸卡 - 办理';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormZhiKa.Create(Application) do
    begin
      FRecordID := nP.FParamA;
      Caption := '纸卡 - 修改';

      InitFormData(FRecordID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormZhiKa.Create(Application);
        with gForm do
        begin
          FormStyle := fsStayOnTop; 
          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FRecordID := nP.FParamA;
        Caption := '纸卡 - ' + FRecordID;
        
        InitFormData(FRecordID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormZhiKa.FormID: integer;
begin
  Result := cFI_FormZhiKa;
end;

procedure TfFormZhiKa.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListDetail, nIni);
    Check1.Checked := nIni.ReadBool(Name, 'XianTi', False);
  finally
    nIni.Free;
  end;

  FItemIndex := -1;
  AdjustCtrlData(Self);
end;

procedure TfFormZhiKa.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListDetail, nIni);
    nIni.WriteBool(Name, 'XianTi', Check1.Checked);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: 纸卡编号
procedure TfFormZhiKa.InitFormData(const nID: string);
var nStr: string;
    nZK: TZhiKaItem;
    i,nIdx: integer;
    nDStr: TDynamicStrArray;
    nItem: array of TStockItem;
begin
  EditName.Text := '标准纸卡';
  FZhiKa.FContract := '';
  FZhiKa.FIsValid := False;
  SetLength(FStockList, 0);

  if EditPayment.Properties.Items.Count < 1 then
  begin
    EditPayment.Clear;
    EditPayment.Text := '赊现';
    LoadSysDictItem(sFlag_PaymentItem, EditPayment.Properties.Items);
  end;

  if nID <> '' then
  begin
    nStr := 'Select zk.*,S_Name,S_PY,C_Name From $ZK zk ' +
            ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan' +
            ' Left Join $Cus cus On cus.c_ID=zk.Z_Customer ' +
            'Where Z_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
            MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
            MI('$ID', nID)]);
    //xxxxx

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      with nZK do
      begin
        FContract := FieldByName('Z_CID').AsString;
        FSaleMan := FieldByName('Z_SaleMan').AsString;
        FSaleName := FieldByName('S_Name').AsString;
        FSalePY := FieldByName('S_PY').AsString;
        FCustomer := FieldByName('Z_Customer').AsString;
        FCusName := FieldByName('C_Name').AsString;
      end;

      EditName.Text := FieldByName('Z_Name').AsString;
      SetLength(nDStr, 4);
      
      nDStr[0] := FieldByName('Z_Project').AsString;
      nDStr[1] := FieldByName('Z_Lading').AsString;
      nDStr[2] := FieldByName('Z_Payment').AsString;
      nDStr[3] := Date2Str(FieldByName('Z_ValidDays').AsDateTime);

      EditMoney.Text := FieldByName('Z_YFMoney').AsString;
      //预付金

      nStr := 'Select * From %s Where D_ZID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nID]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        SetLength(nItem, RecordCount);
        nIdx := 0;
        First;

        while not Eof do
        with nItem[nIdx] do
        begin
          FStock := FieldByName('D_StockNo').AsString;
          FType := FieldByName('D_Type').AsString;
          FName := FieldByName('D_StockName').AsString;
          FPrice := FieldByName('D_Price').AsFloat;
          FValue := FieldByName('D_Value').AsFloat;

          Inc(nIdx);
          Next;
        end;
      end;

      LoadSaleContract(nZK.FContract);
      //读取合同

      if FZhiKa.FIsValid then
      begin
        FZhiKa.FSaleMan := nZK.FSaleMan;
        FZhiKa.FSaleName := nZK.FSaleName;
        FZhiKa.FSalePY := nZK.FSalePY;
        FZhiKa.FCustomer := nZK.FCustomer;
        FZhiKa.FCusName := nZK.FCusName;
      end else Exit;

      EditCID.Text := FZhiKa.FContract;
      EditPName.Text := nDStr[0];

      if FZhiKa.FIsXuNi then
      begin
        SetCtrlData(EditSMan, FZhiKa.FSaleMan);
        if GetStringsItemIndex(EditCustom.Properties.Items, FZhiKa.FCustomer) < 0 then
        begin
          nStr := Format('%s=%s.%s', [FZhiKa.FCustomer, FZhiKa.FCustomer,
                                      FZhiKa.FCusName]);
          InsertStringsItem(EditCustom.Properties.Items, nStr);
        end;
        SetCtrlData(EditCustom, FZhiKa.FCustomer);
      end else
      begin
        EditSMan.Text := Format('%s.%s', [FZhiKa.FSalePY, FZhiKa.FSaleName]);
        EditCustom.Text := Format('%s.%s', [FZhiKa.FCustomer, FZhiKa.FCusName]);
      end;

      SetCtrlData(EditLading, nDStr[1]);
      EditPayment.Text := nDStr[2];
      EditDays.Date := Str2Date(nDStr[3]);

      for nIdx:=Low(nItem) to High(nItem) do
      begin
        nStr := '';

        for i:=Low(FStockList) to High(FStockList) do
        if (FStockList[i].FType = nItem[nIdx].FType) and
           (FStockList[i].FName = nItem[nIdx].FName) then
        begin
          FStockList[i].FPrice := nItem[nIdx].FPrice;
          FStockList[i].FValue := nItem[nIdx].FValue;

          FStockList[i].FSelected := True;
          nStr := 'Y';
          Break;
        end;

        if nStr = '' then
        begin
          i := Length(FStockList);
          SetLength(FStockList, i + 1);

          FStockList[i].FStock := nItem[nIdx].FStock;
          FStockList[i].FType := nItem[nIdx].FType;
          FStockList[i].FName := nItem[nIdx].FName;
          FStockList[i].FPrice := nItem[nIdx].FPrice;
          FStockList[i].FValue := nItem[nIdx].FValue;
          FStockList[i].FSelected := True;
        end;
      end;
    end;

    LoadStockList;
    LoadStockListSummary;
  end;
end;

//Desc: 载入水泥列表
procedure TfFormZhiKa.LoadStockList;
var nIdx,nItem: integer;
begin
  nItem := ListDetail.ItemIndex;
  ListDetail.Items.BeginUpdate;
  try
    ListDetail.Items.Clear;

    for nIdx:=Low(FStockList) to High(FStockList) do
     with ListDetail.Items.Add do
     begin
       Caption := FStockList[nIdx].FName;
       SubItems.Add(Format('%.2f', [FStockList[nIdx].FPrice]));
       SubItems.Add(Format('%.2f', [FStockList[nIdx].FValue]));
       Checked := FStockList[nIdx].FSelected;
     end;
  finally
    ListDetail.Items.EndUpdate;
    ListDetail.ItemIndex := nItem;
  end;
end;

//Desc: 载入摘要
procedure TfFormZhiKa.LoadStockListSummary;
var nMoney: Double;
    nIdx,nNum: integer;
begin
  nNum := 0;
  nMoney := 0;
  dxGroup2.Caption := '办理明细';

  for nIdx:=Low(FStockList) to High(FStockList) do
  if FStockList[nIdx].FSelected then
  begin
    Inc(nNum);
    nMoney := nMoney + FStockList[nIdx].FPrice * FStockList[nIdx].FValue;
  end;

  if nNum > 0 then
    dxGroup2.Caption := dxGroup2.Caption +
      Format(' 已选:[ %d ]种 总额:[ %.2f ]元', [nNum, nMoney]);
  //xxxxx
end;

//Desc: 载入编号为nCID的合同到窗体
procedure TfFormZhiKa.LoadSaleContract(const nCID: string);
var nStr: string;
    nIdx: integer;
begin
  if CompareText(nCID, FZhiKa.FContract) = 0 then
  begin
    EditCID.Text := nCID; Exit;
  end else FZhiKa.FIsValid := False;
  
  nStr := 'Select sc.*,sm.S_Name,sm.S_PY,cus.C_Name as CusName,' +
          '$Now as S_Now From $SC sc' +
          ' Left Join $SM sm On sm.S_ID=sc.C_SaleMan' +
          ' Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
          'Where sc.C_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$ID', nCID), MI('$Now', FDM.SQLServerNow)]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    with FZhiKa do
    begin
      FIsXuNi := FieldByName('C_XuNi').AsString = sFlag_Yes;
      FSaleMan := FieldByName('C_SaleMan').AsString;
      FSaleName := FieldByName('S_Name').AsString;
      FSalePY := FieldByName('S_PY').AsString;
      FCustomer := FieldByName('C_Customer').AsString;
      FCusName := FieldByName('CusName').AsString;
    end;

    EditPName.Text := FieldByName('C_Project').AsString;
    EditDays.Date := FieldByName('S_Now').AsFloat +
                     FieldByName('C_ZKDays').AsInteger;
    //当前 + 时长
    
    //EditPName.Properties.ReadOnly := not FZhiKa.FIsXuNi;
    EditSMan.Properties.ReadOnly := not FZhiKa.FIsXuNi;
    EditCustom.Properties.ReadOnly := not FZhiKa.FIsXuNi;

    if FZhiKa.FIsXuNi then
    begin
      EditSMan.Properties.DropDownListStyle := lsEditFixedList;
      EditCustom.Properties.DropDownListStyle := lsEditList;

      if EditSMan.Properties.Items.Count < 1 then
        LoadSaleMan(EditSMan.Properties.Items);
      SetCtrlData(EditSMan, FZhiKa.FSaleMan);
      //设置业务员

      if EditCustom.Properties.Items.Count < 1 then
      begin
        nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSMan)]);
        LoadCustomer(EditCustom.Properties.Items, nStr);
      end;
      SetCtrlData(EditCustom, FZhiKa.FCustomer);
      //设置客户名
    end else
    begin
      EditSMan.Properties.DropDownListStyle := lsEditList;
      EditCustom.Properties.DropDownListStyle := lsEditList;

      EditSMan.Text := Format('%s.%s', [FZhiKa.FSalePY, FZhiKa.FSaleName]);
      EditCustom.Text := Format('%s.%s', [FZhiKa.FCustomer, FZhiKa.FCusName]);
    end;

    SetLength(FStockList, 0);
    nStr := 'Select * From %s Where E_CID=''%s''';
    nStr := Format(nStr, [sTable_SContractExt, nCID]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      SetLength(FStockList, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      with FStockList[nIdx] do
      begin
        FStock := FieldByName('E_StockNo').AsString;
        FType := FieldByName('E_Type').AsString;
        FName := FieldByName('E_StockName').AsString;
        FPrice := FieldByName('E_Price').AsFloat;
        FValue := 0;

        Next;
        Inc(nIdx);
      end;
    end;

    LoadStockList;
    EditCID.Text := nCID;
    
    FZhiKa.FIsValid := True;
    FZhiKa.FContract := nCID;
  end;
end;

//Desc: 业务员变更,提取相关客户
procedure TfFormZhiKa.EditSManPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  if FZhiKa.FIsXuNi and (EditSMan.ItemIndex > -1) then
  begin
    EditCustom.Text := '';
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSMan)]);
    LoadCustomer(EditCustom.Properties.Items, nStr);
  end;
end;

//Desc: 载入合同
procedure TfFormZhiKa.EditCIDExit(Sender: TObject);
begin
  EditCID.Text := Trim(EditCID.Text);
  if EditCID.Text <> '' then LoadSaleContract(EditCID.Text);
end;

//Desc: 同步更新办理明细
procedure TfFormZhiKa.ListDetailClick(Sender: TObject);
var nIdx: Integer;
    nChanged: Boolean;
begin
  nChanged := False;
  for nIdx:=Low(FStockList) to High(FStockList) do
  if FStockList[nIdx].FSelected <> ListDetail.Items[nIdx].Checked then
  begin
    nChanged := True;
    FStockList[nIdx].FSelected := ListDetail.Items[nIdx].Checked;
  end;

  if nChanged then LoadStockListSummary;
  //update summary

  if ListDetail.ItemIndex >= 0 then
  begin
    FItemIndex := -1;

    EditStock.Text := FStockList[ListDetail.ItemIndex].FName;
    EditPrice.Text := Format('%.2f', [FStockList[ListDetail.ItemIndex].FPrice]);
    
    EditValue.Text := Format('%.2f', [FStockList[ListDetail.ItemIndex].FValue]);
    //EditValue.SetFocus;
    FItemIndex := ListDetail.ItemIndex;
  end;
end;

//Desc: 更新设置
procedure TfFormZhiKa.EditPricePropertiesEditValueChanged(Sender: TObject);
var nInt: Integer;
    nChanged: Boolean;
begin
  if (FItemIndex >= 0) and IsNumber(EditPrice.Text, True) and
     IsNumber(EditValue.Text, True) then
  begin
    nInt := Float2PInt(StrToFloat(EditPrice.Text), cPrecision);
    if nInt <> Float2PInt(FStockList[FItemIndex].FPrice, cPrecision) then
    begin
      nChanged := True;
      FStockList[FItemIndex].FPrice := nInt / cPrecision;
    end else nChanged := False;

    nInt := Float2PInt(StrToFloat(EditValue.Text), cPrecision);
    if nInt <> Float2PInt(FStockList[FItemIndex].FValue, cPrecision) then
    begin
      nChanged := True;
      FStockList[FItemIndex].FValue := nInt / cPrecision;
    end;

    if not (EditPrice.IsFocused or EditValue.IsFocused) then
      FItemIndex := -1;
    //xxxxx

    if nChanged then
    begin
      LoadStockList;
      LoadStockListSummary;
    end;
  end;
end;

//Desc: 快捷菜单
procedure TfFormZhiKa.N3Click(Sender: TObject);
var nIdx: integer;
    nBool: Boolean;
begin
  for nIdx:=Low(FStockList) to High(FStockList) do
  begin
    case TComponent(Sender).Tag of
     10: nBool := True;
     20: nBool := False;
     30: nBool := not FStockList[nIdx].FSelected else nBool := False;
    end;

    FStockList[nIdx].FSelected := nBool;
    ListDetail.Items[nIdx].Checked := nBool;
    LoadStockListSummary;
  end;
end;

//Desc: 快速选择合同
procedure TfFormZhiKa.EditCIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    TcxButtonEdit(Sender).Properties.OnButtonClick(Sender, 0);
  end;
end;

//Desc: 快速选择客户
procedure TfFormZhiKa.EditCustomKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    nP.FParamA := GetCtrlData(EditCustom);
    
    if nP.FParamA = '' then
      nP.FParamA := EditCustom.Text;
    //xxxxx

    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditSMan, nP.FParamD);
    if EditSMan.ItemIndex < 0 then
    begin
      ShowMsg('无效的业务员', sHint); Exit;
    end;

    SetCtrlData(EditCustom, nP.FParamB);
    if EditCustom.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditCustom.Properties.Items, nStr);
      SetCtrlData(EditCustom, nP.FParamB);
    end;
  end;
end;

procedure TfFormZhiKa.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FParamA := Trim(EditCID.Text);
  CreateBaseFormItem(cFI_FormGetContract, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    LoadSaleContract(nP.FParamB);
  EditCID.SelectAll;
end;

//Desc: 验证Sender控件
function TfFormZhiKa.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;
  if Sender = EditCID then
  begin
    Result := FZhiKa.FIsValid;
    nHint := '请填写有效的合同编号';
  end else

  if Sender = EditSMan then
  begin
    Result := (not FZhiKa.FIsXuNi) or (EditSMan.ItemIndex >= 0);
    nHint := '请选择有效的业务员';
  end else

  if Sender = EditCustom then
  begin
    Result := (not FZhiKa.FIsXuNi) or (EditCustom.Text <> '');
    nHint := '请选择有效的客户';
  end else

  if Sender = EditDays then
  begin
    Result := EditDays.Text <> '';
    nHint := '请填写有效的时长';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True) and (StrToFloat(EditMoney.Text) >= 0);
    nHint := '请输入有效的预付金额';
  end;
end;

//Desc: 获取nCusID的当前可用金额
function GetCustomValidMoney(const nCusID: string): string;
var nStr: string;
    nVal: Double;
begin
  nStr := 'Select Sum(Z_FixedMoney) From %s ' +
          'Where Z_Customer=''%s'' and Z_OnlyMoney=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, nCusID, sFlag_Yes]);

  nVal := FDM.QueryTemp(nStr).Fields[0].AsFloat;
  nVal := GetCustomerValidMoney(nCusID) - nVal;
  
  if nVal < 0 then
       Result := '0'
  else Result := Format('%.2f', [nVal]);
end;

//Desc: 保存数据
procedure TfFormZhiKa.BtnOKClick(Sender: TObject);
var nIdx: integer;
    nList: TStrings;
    nParam: TFormCommandParam;
    nStr,nSQL,nZID,nCID: string;
begin
  if not IsDataValid then Exit;
  if FZhiKa.FIsXuNi then
  begin
    if EditCustom.ItemIndex > -1 then
         nCID := GetCtrlData(EditCustom)
    else nCID := SaveXuNiCustomer(EditCustom.Text, GetCtrlData(EditSMan));
  end else nCID := FZhiKa.FCustomer;

  if FRecordID = '' then
  begin
    nParam.FCommand := cCmd_EditData;
    nParam.FParamA := nCID;
    CreateBaseFormItem(cFI_FormZhiKaAdjust, '', @nParam);

    if (nParam.FCommand <> cCmd_ModalResult) or (nParam.FParamA <> mrOK) then
      Exit;
    //旧卡校正没有完成
  end;

  nList := TStringList.Create;
  FDM.ADOConn.BeginTrans;
  try
    if FZhiKa.FIsXuNi then
         nStr := GetCtrlData(EditSMan)
    else nStr := FZhiKa.FSaleMan;

    nList.Add(Format('Z_Name=''%s''', [Trim(EditName.Text)]));
    nList.Add(Format('Z_Customer=''%s''', [nCID]));
    nList.Add(Format('Z_SaleMan=''%s''', [nStr]));
    nList.Add(Format('Z_CID=''%s''', [FZhiKa.FContract]));
    nList.Add(Format('Z_Project=''%s''', [Trim(EditPName.Text)]));
    
    nList.Add(Format('Z_Payment=''%s''', [EditPayment.Text]));
    nList.Add(Format('Z_Lading=''%s''', [GetCtrlData(EditLading)]));
    nList.Add(Format('Z_ValidDays=''%s''', [Date2Str(EditDays.Date)]));
    nList.Add(Format('Z_YFMoney=%s', [EditMoney.Text]));
    nList.Add(Format('Z_SalesStatus=%s', ['1']));

    if FRecordID = '' then
    begin
      nZID := GetSerialNo(sFlag_BusGroup, sFlag_ZhiKa, True);
      if nZID = '' then
        raise Exception.Create('获取纸卡号失败');
      //xxxxx

      nList.Add(Format('Z_ID=''%s''', [nZID]));
      if IsZhiKaNeedVerify then
           nStr := sFlag_No
      else nStr := sFlag_Yes;
      nList.Add(Format('Z_Verified=''%s''', [nStr]));

      nList.Add(Format('Z_Man=''%s''', [gSysParam.FUserName]));
      nList.Add(Format('Z_Date=%s', [FDM.SQLServerNow]));
      nSQL := MakeSQLByForm(Self, sTable_ZhiKa, '', True, nil, nList);
    end else
    begin
      nZID := FRecordID;
      nStr := Format('Z_ID=''%s''', [FRecordID]);
      nSQL := MakeSQLByForm(Self, sTable_ZhiKa, nStr, False, nil, nList);
    end;

     FDM.ExecuteSQL(nSQL);
    //write data

    if FRecordID <> '' then
    begin
      nSQL := 'Delete From %s Where D_ZID=''%s''';
      nSQL := Format(nSQL, [sTable_ZhiKaDtl, nZID]);
      FDM.ExecuteSQL(nSQL);
    end;

    for nIdx:=Low(FStockList) to High(FStockList) do
    with FStockList[nIdx] do
    begin
      if not FSelected then Continue;
      //no selected

      nSQL := MakeSQLByStr([SF('D_ZID', nZID),
              SF('D_Type', FType),
              SF('D_StockNo', FStock),
              SF('D_StockName', FName),
              SF('D_Price', FPrice, sfVal),
              SF('D_Value', FValue, sfVal)
              ], sTable_ZhiKaDtl, '', True);
      FDM.ExecuteSQL(nSQL);
    end;

    if nParam.FParamB <> '' then
    begin
      nList.Text := MacroValue(nParam.FParamB, [MI('$NewZK', nZID)]);
      if Pos('$Money', nList.Text) > 0 then
      begin
        nStr := GetCustomValidMoney(nCID);
        nList.Text := MacroValue(nList.Text, [MI('$Money', nStr)]);
      end;

      for nIdx:=nList.Count - 1 downto 0 do
        FDM.ExecuteSQL(nList[nIdx]);
      //xxxxx
    end;
    //旧卡调整

    FreeAndNil(nList);
    FDM.ADOConn.CommitTrans;
  except
    nList.Free;
    if FDM.ADOConn.InTransaction then
      FDM.ADOConn.RollbackTrans;
    ShowMsg('纸卡保存失败', sError); Exit;
  end;

  if Check1.Checked then
  begin
    Visible := False;
    Application.ProcessMessages;

    nParam.FParamA := nZID;
    CreateBaseFormItem(cFI_FormZhiKaFixMoney, '', @nParam);

    Visible := True;
    Application.ProcessMessages;
  end; //限提

  if IsPrintZK then
    PrintZhiKaReport(nZID, True);
  //print report

  ModalResult := mrOK;
  ShowMsg('纸卡已保存', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormZhiKa, TfFormZhiKa.FormID);
end.
