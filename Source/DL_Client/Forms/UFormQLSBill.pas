{*******************************************************************************
  作者: lih 2017-04-07
  描述: 祁连山开提货单
*******************************************************************************}
unit UFormQLSBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxMaskEdit,
  cxDropDownEdit, cxListView, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls, cxButtonEdit, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxLayoutcxEditAdapters, cxCheckBox, cxLabel, Menus,
  cxButtons;

type
  TfFormQLSBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Group2: TdxLayoutGroup;
    chkIfHYprint: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    EditJXSTHD: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cbxSampleID: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    cbxCenterID: TcxComboBox;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    chkFenChe: TcxCheckBox;
    dxLayout1Item17: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item18: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditHYCus: TComboBox;
    dxLayout1Item20: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure cbxSampleIDPropertiesChange(Sender: TObject);
    procedure cbxCenterIDPropertiesEditValueChanged(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FBuDanFlag: string;
    //补单标记
    procedure LoadFormData;
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst;

var
  gZhiKa,gRecID,gSalesType,gStockNo,gStockName,gPrice,gType:string;
  gCusID,gCompanyID,gFYPlanStatus,gInventLocationId,gIDList:string;
  //全局使用

class function TfFormQLSBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool: Boolean;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  with TfFormQLSBill.Create(Application) do
  try
    {$IFDEF YDKP}
    dxLayout1Item5.Enabled:=True;
    dxLayout1Item5.Visible:=True;
    cxLabel1.Visible:=True;
    {$ELSE}
      {$IFDEF PLKP}
      dxLayout1Item5.Enabled:=True;
      dxLayout1Item5.Visible:=True;
      cxLabel1.Visible:=True;
      {$ELSE}
      dxLayout1Item5.Enabled:=False;
      dxLayout1Item5.Visible:=False;
      cxLabel1.Visible:=False;
      {$ENDIF}
    {$ENDIF}

    {$IFDEF QHSN}
    chkFenChe.Enabled:=True;
    chkFenChe.Visible:=True;
    {$ELSE}
      {$IFDEF MHSN}
      chkFenChe.Enabled:=True;
      chkFenChe.Visible:=True;
      {$ELSE}
      chkFenChe.Enabled:=False;
      chkFenChe.Visible:=False;
      {$ENDIF}
    {$ENDIF}

    BtnOK.Enabled := False;
    //gInfo.FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);

    Caption := '开提货单';
    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;
    FBuDanFlag := sFlag_No;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := gIDList
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormQLSBill.FormID: integer;
begin
  Result := cFI_FormQLSBill;
end;

procedure TfFormQLSBill.FormCreate(Sender: TObject);
var nStr: string;
    nIni,myini: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    //LoadMCListBoxConfig(Name, ListInfo, nIni);
    //LoadcxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  AdjustCtrlData(Self);
end;

procedure TfFormQLSBill.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    //SaveMCListBoxConfig(Name, ListInfo, nIni);
    //SavecxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: 回车键
procedure TfFormQLSBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditStock then ActiveControl := EditValue else
    //if Sender = EditValue then ActiveControl := BtnAdd else
    if Sender = EditTruck then ActiveControl := EditStock else

    if Sender = EditLading then
         ActiveControl := EditTruck
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 载入界面数据
procedure TfFormQLSBill.LoadFormData;
var nStr,nTmp: string;
    nDB,nDBSales,nDBLine: TDataSet;
    i,nIdx: integer;
begin
  BtnOK.Enabled := False;
  nDB := LoadAXPlanInfo(Trim(EditID.Text),nStr);
  if Assigned(nDB) then
  with nDB do
  begin
    EditTruck.Text := FieldByName('AX_VEHICLEId').AsString;
    EditHYCus.Text := FieldByName('AX_CUSTOMERNAME').AsString;
    EditValue.Text := FieldByName('AX_PLANQTY').AsString;

    gZhiKa := FieldByName('AX_SALESID').AsString;
    gRecID := FieldByName('AX_SALESLINERECID').AsString;
    gStockNo := FieldByName('AX_ITEMID').AsString;

    gPrice := FieldByName('AX_ITEMPRICE').AsString;
    gType := UpperCase(FieldByName('AX_ITEMTYPE').AsString);
    gStockName := FieldByName('AX_ITEMNAME').AsString;

    if gType = 'D' then
      gStockName := gStockName + '袋装'
    else
      gStockName := gStockName + '散装';
    EditStock.Text := gStockName;
    gCusID := FieldByName('AX_CUSTOMERID').AsString;
    gFYPlanStatus := FieldByName('AX_FYPlanStatus').AsString;
    gInventLocationId := FieldByName('AX_InventLocationId').AsString;
    GetCustomerExt(gCusID,EditHYCus);
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  nDBSales := LoadSalesInfo(gZhiKa,nStr);
  if Assigned(nDBSales) then
  with nDBSales do
  begin
    gSalesType := FieldByName('Z_SalesType').AsString; //0:记账日志类型不校验信用额度
    gCompanyID := FieldByName('DataAreaID').AsString;
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  nDBLine := LoadSaleLineInfo(gRecID,nStr);
  if Assigned(nDBLine) then
  with nDBSales do
  begin
    if FieldByName('D_Blocked').AsString = '1' then
    begin
      nStr := '订单已停止';
      ShowMsg(nStr,sHint);
      Exit;
    end;
    if FieldByName('D_Value').AsFloat < StrToFloat(EditValue.Text) then
    begin
      nStr := '订单剩余量不足';
      ShowMsg(nStr,sHint);
      Exit;
    end;
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;
  InitCenter(gStockNO,gType,cbxCenterID);

  BtnOK.Enabled := True;
  ActiveControl := BtnOK;
end;

//Dessc: 选择品种
function TfFormQLSBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex > -1;
    nHint := '请选择水泥类型';
  end else

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditLading then
  begin
    Result := EditLading.ItemIndex > -1;
    nHint := '请选择有效的提货方式';
  end; 

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '请填写有效的办理量';

    if not Result then Exit;
    if not OnVerifyCtrl(EditStock, nHint) then Exit;

    {with gStockList[StrToInt(GetCtrlData(EditStock))] do
    if FPrice > 0 then
    begin
      nVal := StrToFloat(EditValue.Text);
      nVal := Float2Float(nVal, cPrecision, False);
      //Result := FloatRelation(gInfo.FMoney / FPrice, nVal, rtGE, cPrecision);
      Result := FloatRelation(FValue, nVal, rtGE, cPrecision);

      nHint := '已超出可办理量';
      if not Result then Exit;

      //if FloatRelation(gInfo.FMoney / FPrice, nVal, rtEqual, cPrecision) then
      if FloatRelation(FValue, nVal, rtEqual, cPrecision) then
      begin
        nHint := '';
        Result := QueryDlg('确定要按最大可提货量全部开出吗?', sAsk);
        if not Result then ActiveControl := EditValue;
      end;
    end else
    begin
      Result := False;
      nHint := '单价[ 0 ]无效';
    end; }
  end;
end;

//Desc: 保存
procedure TfFormQLSBill.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
    nPos: Integer;
    nPlanW,nBatQuaS,nBatQuaE:Double;
    FSumTon:Double;
    nStr,nCenterYL,nStockNo,nCenterID:string;
    nYL:Double;
    FSampleID:string;
begin
  FSumTon:=0.00;
  if cbxCenterID.ItemIndex=-1 then
  begin
    ShowMsg('请选择生产线', sHint); Exit;
  end;
  nPos:=Pos('.',cbxCenterID.Text);
  if nPos>0 then
    nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
  else begin
    ShowMsg('生产线格式非法', sHint); Exit;
  end;
  {$IFDEF YDKP}
  if cbxSampleID.ItemIndex = -1 then
  begin
    ShowMsg('请录入选择试样编号', sHint); Exit;
  end;
  {$ENDIF}
  {$IFDEF PLKP}
  if cbxSampleID.ItemIndex = -1 then
  begin
    ShowMsg('请录入选择试样编号', sHint); Exit;
  end;
  {$ENDIF}

  if not IsDealerLadingIDExit(EditJXSTHD.Text) then
  begin
    ShowMsg('经销商提货单号重复', sHint); Exit;
  end;

  FSampleID := cbxSampleID.Text;
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //需打印品种

    {for nIdx:=Low(gStockList) to High(gStockList) do
    with gStockList[nIdx],nTmp do
    begin
      if not FSelecte then Continue; }
      //xxxxx

    with nTmp do
    begin
      Values['Type'] := gType;
      Values['StockNO'] := gStockNO;
      Values['StockName'] := Editstock.text;
      Values['Price'] := gPrice;
      Values['Value'] := EditValue.text;
      Values['RECID'] := gRecID;
      Values['SampleID'] := FSampleID;
      nStockNo:= Values['StockNO'];

      nList.Add(PackerEncodeStr(nTmp.Text));
      //new bill
      if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
        nPrint := nStocks.IndexOf(gStockNO) >= 0;
      //xxxxx
    end;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['LID'] := Trim(EditID.Text);
      Values['ZhiKa'] := gZhiKa;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := GetCtrlData(EditLading);
      //Values['VPListID']:=
      Values['IsVIP'] := GetCtrlData(EditType);
      //Values['Seal'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
      if chkIfHYprint.Checked then
        Values['IfHYprt'] := 'Y'
      else
        Values['IfHYprt'] := 'N';
      Values['SalesType'] := gSalesType;
      Values['CenterID']:= nCenterID;
      Values['JXSTHD'] := Trim(EditJXSTHD.Text);
      Values['Project'] := Trim(EditHYCus.Text);
      {$IFDEF QHSN}
      if chkFenChe.Checked then
        Values['IfFenChe'] := 'Y'
      else
        Values['IfFenChe'] := 'N';
      {$ELSE}
        {$IFDEF MHSN}
        if chkFenChe.Checked then
          Values['IfFenChe'] := 'Y'
        else
          Values['IfFenChe'] := 'N';
        {$ELSE}
        Values['IfFenChe'] := 'N';
        {$ENDIF}
      {$ENDIF}
      Values['KuWei'] := '';
      Values['LocationID']:= 'A';
      {nCenterYL:=GetCenterSUM(nStockNo,Values['CenterID']);
      if nCenterYL <> '' then
      begin
        if IsNumber(nCenterYL,True) then
        begin
          nYL:= StrToFloat(nCenterYL);
          if nYL <= 0 then
          begin
            ShowMsg('生产线余量不足：'+#13#10+FormatFloat('0.00',nYL),sHint);
            Exit;
          end;
        end;
      end; }
    end;
    gIDList := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if gIDList = '' then Exit;
  finally
    nTmp.Free;
    nList.Free;
    nStocks.Free;
  end;

  SaveCustomerExt(gCusID,Trim(EditHYCus.Text));
  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(gIDList, EditTruck.Text, True);
  //办理磁卡
  {$IFDEF PLKP}
  if nPrint then
    PrintDaiBill(gIDList, False);
  {$ELSE}
  if PrintYesNo then
    PrintDaiBill(gIDList, False);
  {$ENDIF}
  //print report

  ModalResult := mrOk;
  ShowMsg('提货单保存成功', sHint);
end;

procedure TfFormQLSBill.cbxSampleIDPropertiesChange(Sender: TObject);
begin
  {$IFDEF YDKP}
  if cbxSampleID.ItemIndex > -1 then chkIfHYprint.Checked:=True;
  {$ENDIF}
  if cxLabel1.Visible = True then
    cxLabel1.Caption:=Floattostr(GetSumTonnage(cbxSampleID.Text));
end;

procedure TfFormQLSBill.cbxCenterIDPropertiesEditValueChanged(
  Sender: TObject);
var
  nPos:Integer;
  nCenterID:string;
begin
  {$IFDEF YDKP}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('生产线格式非法', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
  {$IFDEF PLKP}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('生产线格式非法', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
  {$IFDEF QHSN}
  if cbxCenterID.ItemIndex>-1 then
  begin
    nPos:=Pos('.',cbxCenterID.Text);
    if nPos>0 then
      nCenterID:=Copy(cbxCenterID.Text,1,nPos-1)
    else begin
      ShowMsg('生产线格式非法', sHint); Exit;
    end;
    InitSampleID(gStockName,gType,nCenterID,cbxSampleID);
  end;
  {$ENDIF}
end;

procedure TfFormQLSBill.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then LoadFormData;
end;

procedure TfFormQLSBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  LoadFormData;
end;

initialization
  gControlManager.RegCtrl(TfFormQLSBill, TfFormQLSBill.FormID);
end.
