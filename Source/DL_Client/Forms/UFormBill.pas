{*******************************************************************************
  作者: dmzn@163.com 2014-09-01
  描述: 开提货单
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxMaskEdit,
  cxDropDownEdit, cxListView, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls, cxButtonEdit, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxLayoutcxEditAdapters, cxCheckBox, cxLabel;

type
  TfFormBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item4: TdxLayoutItem;
    ListBill: TcxListView;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    BtnAdd: TButton;
    dxLayout1Item10: TdxLayoutItem;
    BtnDel: TButton;
    dxLayout1Item11: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
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
    cbxKw: TcxComboBox;
    dxLayout1Item16: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesChange(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure cbxSampleIDPropertiesChange(Sender: TObject);
    procedure cbxCenterIDPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FBuDanFlag: string;
    //补单标记
    procedure LoadFormData;
    procedure LoadStockList;
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

type
  TCommonInfo = record
    FZhiKa: string;
    FCusID: string;
    FMoney: Double;
    FOnlyMoney: Boolean;
    FIDList: string;
    FShowPrice: Boolean;
    FPriceChanged: Boolean;
    FSalesType: string;  //订单类型（0：记账日志 1报价 2预定3销售订单 4退回物料 5总订单 6物料需求）
  end;

  TStockItem = record
    FType: string;
    FStockNO: string;
    FStockName: string;
    FPrice: Double;
    FValue: Double;
    FSelecte: Boolean;
    FRecID: string;
    FSampleID: string;
  end;

var
  gInfo: TCommonInfo;
  gStockList: array of TStockItem;
  gSelect:Integer;
  gStockName,gType:string;
  //全局使用

class function TfFormBill.CreateForm(const nPopedom: string;
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

  try
    CreateBaseFormItem(cFI_FormGetZhika, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    gInfo.FZhiKa := nP.FParamB;
    gSelect := np.FParamD;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    {$IFDEF YDKP}
    dxLayout1Item5.Enabled:=True;
    dxLayout1Item5.Visible:=True;
    dxLayout1Item16.Enabled:=True;
    dxLayout1Item16.Visible:=True;
    cxLabel1.Visible:=True;
    {$ELSE}
    dxLayout1Item5.Enabled:=False;
    dxLayout1Item5.Visible:=False;
    dxLayout1Item16.Enabled:=False;
    dxLayout1Item16.Visible:=False;
    cxLabel1.Visible:=False;
    {$ENDIF}
    LoadFormData;
    //try load data

    if not BtnOK.Enabled then Exit;
    gInfo.FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);

    Caption := '开提货单';
    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;

    if nPopedom = 'MAIN_D04' then //补单
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := gInfo.FIDList
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
var nStr: string;
    nIni,myini: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    {nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr; }
    //xxxxx

    LoadMCListBoxConfig(Name, ListInfo, nIni);
    LoadcxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  AdjustCtrlData(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveMCListBoxConfig(Name, ListInfo, nIni);
    SavecxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: 回车键
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditStock then ActiveControl := EditValue else
    if Sender = EditValue then ActiveControl := BtnAdd else
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
procedure TfFormBill.LoadFormData;
var nStr,nTmp: string;
    nDB: TDataSet;
    i,nIdx: integer;
    nZcid: string;//合同编号
    nNewPrice: Double;
begin
  BtnOK.Enabled := False;
  nDB := LoadZhiKaInfo(gInfo.FZhiKa, ListInfo, nStr);

  if Assigned(nDB) then
  with gInfo do
  begin
    FCusID := nDB.FieldByName('Z_Customer').AsString;
    FPriceChanged := nDB.FieldByName('Z_TJStatus').AsString = sFlag_TJOver;

    SetCtrlData(EditLading, nDB.FieldByName('Z_Lading').AsString);
    FSalesType:=nDB.fieldByName('Z_SalesType').AsString; //0:记账日志类型不校验信用额度
    //FMoney := GetZhikaValidMoney(gInfo.FZhiKa, gInfo.FOnlyMoney);
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;
  {if gInfo.FSalesType <> '0' then
    BtnOK.Enabled := IsCustomerCreditValid(gInfo.FCusID)
  else}
    BtnOK.Enabled := True;
  if not BtnOK.Enabled then Exit;
  //to verify credit

  SetLength(gStockList, 0);
  nStr := 'Select D_Type,upper(D_StockNo) as D_StockNo1,* From %s Where D_Blocked=''0'' and D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, gInfo.FZhiKa]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '';
    nIdx := 0;
    SetLength(gStockList, RecordCount);

    First;  
    while not Eof do
    with gStockList[nIdx] do
    begin
      FType := FieldByName('D_Type').AsString;
      if FType = '0' then FType:='S';
      FStockNO := FieldByName('D_StockNo1').AsString;
      if FType='D' then
        FStockName := FieldByName('D_StockName').AsString+'袋装'
      else
        FStockName := FieldByName('D_StockName').AsString+'散装';
      FPrice := FieldByName('D_Price').AsFloat;
        //FValue := 0;
      FValue:= FieldByName('D_Value').AsFloat;
      FSelecte := False;
      FRecID := FieldByName('D_RECID').AsString;
      {if gInfo.FPriceChanged then
      begin
        nTmp := '品种:[ %-8s ] 原价:[ %.2f ] 现价:[ %.2f ]' + #32#32;
        nTmp := Format(nTmp, [FStockName, FieldByName('D_PPrice').AsFloat, FPrice]);
        nStr := nStr + nTmp + #13#10;
      end;}

      Inc(nIdx);
      Next;
    end;
    for i:=Low(gStockList) to High(gStockList) do
    begin
      if LoadAddTreaty(gStockList[i].FRecID,nNewPrice) then
        gStockList[i].FPrice:=nNewPrice;
    end;
  end else
  begin
    nStr := Format('纸卡[ %s ]没有可提的水泥品种,已终止.', [gInfo.FZhiKa]);
    ShowDlg(nStr, sHint);
    BtnOK.Enabled := False; Exit;
  end;

  {if gInfo.FPriceChanged then
  begin
    nStr := '管理员已调整纸卡[ %s ]的价格,明细如下: ' + #13#10#13#10 +
            AdjustHintToRead(nStr) + #13#10 +
            '请询问客户是否接受新单价,接受点"是"按钮.' ;
    nStr := Format(nStr, [gInfo.FZhiKa]);

    BtnOK.Enabled := QueryDlg(nStr, sHint);
    if not BtnOK.Enabled then Exit;

    nStr := 'Update %s Set Z_TJStatus=Null Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, gInfo.FZhiKa]);
    FDM.ExecuteSQL(nStr);
  end; }

  LoadStockList;
  //load stock into window
  
  //EditType.ItemIndex := 0;
  ActiveControl := EditTruck;
end;

//Desc: 刷新水泥列表到窗体
procedure TfFormBill.LoadStockList;
var nStr: string;
    i,nIdx: integer;
begin
  AdjustCXComboBoxItem(EditStock, True);
  nIdx := ListBill.ItemIndex;

  ListBill.Items.BeginUpdate;
  try
    ListBill.Clear;
    for i:=Low(gStockList) to High(gStockList) do
    if gStockList[i].FSelecte then
    begin
      with ListBill.Items.Add do
      begin
        Caption := gStockList[i].FStockName;
        SubItems.Add(EditTruck.Text);
        SubItems.Add(FloatToStr(gStockList[i].FValue));

        Data := Pointer(i);
        ImageIndex := cItemIconIndex;
      end;
    end else
    begin
      nStr := Format('%d=%s', [i, gStockList[i].FStockName]);
      EditStock.Properties.Items.Add(nStr);
    end;
  finally
    ListBill.Items.EndUpdate;
    if ListBill.Items.Count > nIdx then
      ListBill.ItemIndex := nIdx;
    //xxxxx

    AdjustCXComboBoxItem(EditStock, False);
    EditStock.ItemIndex := gSelect;
  end;
end;

//Dessc: 选择品种
procedure TfFormBill.EditStockPropertiesChange(Sender: TObject);
var nInt: Int64;
begin
  dxGroup2.Caption := '提单明细';
  if EditStock.ItemIndex < 0 then Exit;

  with gStockList[StrToInt(GetCtrlData(EditStock))] do
  if FPrice > 0 then
  begin
    //nInt := Float2PInt(gInfo.FMoney / FPrice, cPrecision, False);
    nInt := Float2PInt(FValue, cPrecision, False);
    EditValue.Text := FloatToStr(nInt / cPrecision);

    if gInfo.FShowPrice then
      dxGroup2.Caption := Format('提单明细 单价:%.2f元/吨', [FPrice]);
    //xxxxx
  end;
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
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

    with gStockList[StrToInt(GetCtrlData(EditStock))] do
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
    end;
  end;
end;

//Desc: 添加
procedure TfFormBill.BtnAddClick(Sender: TObject);
var nIdx: Integer;
    nSampleDate: string;
    nLocationID: string;
begin
  if IsDataValid then
  begin
    nIdx := StrToInt(GetCtrlData(EditStock));
    with gStockList[nIdx] do
    begin
      if (FType = sFlag_San) and (ListBill.Items.Count > 0) then
      begin
        ShowMsg('散装水泥不能混装', sHint);
        ActiveControl := EditStock;
        Exit;
      end;
      FValue := StrToFloat(EditValue.Text);
      FValue := Float2Float(FValue, cPrecision, False);
      InitCenter(FStockNO,FType,cbxCenterID);
      {$IFDEF YDKP}
      gStockName:=FStockName;
      gType:=FType;
      //InitSampleID(FStockName,FType,cbxCenterID.Text,cbxSampleID);
      if pos('熟',FStockName)>0 then
      begin
        InitKuWei('熟料',cbxKw);
      end else
      if pos('袋',FStockName)>0 then
      begin
        InitKuWei('袋装',cbxKw);
      end else
      begin
        InitKuWei('散装',cbxKw);
      end;
      {$ENDIF}
      FSelecte := True;

      EditTruck.Properties.ReadOnly := True;
      //gInfo.FMoney := gInfo.FMoney - FPrice * FValue;
    end;

    LoadStockList;
    ActiveControl := BtnOK;
  end;
end;

//Desc: 删除
procedure TfFormBill.BtnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if ListBill.ItemIndex > -1 then
  begin
    nIdx := Integer(ListBill.Items[ListBill.ItemIndex].Data);
    with gStockList[nIdx] do
    begin
      FSelecte := False;
      //gInfo.FMoney := gInfo.FMoney + FPrice * FValue;
    end;

    LoadStockList;
    EditTruck.Properties.ReadOnly := ListBill.Items.Count > 0;
    cbxCenterID.ItemIndex:=-1;
    cbxSampleID.ItemIndex:=-1;
  end;
end;

//Desc: 保存
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
    nPos: Integer;
    nPlanW,nBatQuaS,nBatQuaE:Double;
    FSumTon:Double;
    nStr,nCenterYL,nStockNo,nCenterID:string;
    nYL:Double;
begin
  FSumTon:=0.00;
  if ListBill.Items.Count < 1 then
  begin
    ShowMsg('请先办理提货单', sHint); Exit;
  end;
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
  if Trim(EditJXSTHD.Text) = '' then
  begin
    ShowMsg('请录入经销商提货单号', sHint); Exit;
  end;
  if not CheckTruckOK(Trim(EditTruck.Text)) then
  begin
    ShowMsg(Trim(EditTruck.Text)+'车辆禁止开单',sHint);
    Exit;
  end;

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //需打印品种

    for nIdx:=Low(gStockList) to High(gStockList) do
    with gStockList[nIdx],nTmp do
    begin
      if not FSelecte then Continue;
      //xxxxx
      Values['Type'] := FType;
      Values['StockNO'] := FStockNO;
      Values['StockName'] := FStockName;
      Values['Price'] := FloatToStr(FPrice);
      Values['Value'] := FloatToStr(FValue);
      Values['RECID'] := FRecID;
      {$IFDEF YDKP}//开票录入试样编号
      if cbxSampleID.Enabled=True then
      begin
        if LoadNoSampleID(FStockNO) then
        begin
          FSampleID:='';
        end else
        begin
          if cbxSampleID.ItemIndex < 0 then
          begin
            ShowMsg('请选择试样编号！',sHint);
            Exit;
          end;
          FSampleID:=cbxSampleID.Text;
        end;
      end else
      begin
        FSampleID:='';
      end;
      if FSampleID <> '' then
      begin
        FSumTon:=GetSumTonnage(FSampleID);
        cxLabel1.Caption:=Floattostr(FSumTon);
        if GetSampleTonnage(FSampleID, nBatQuaS, nBatQuaE) then
        begin
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('试样编号['+FSampleID+']已超量',sHint);
            if UpdateSampleValid(FSampleID) then
              InitSampleID(FStockName,FType,nCenterID,cbxSampleID);
            Exit;
          end;

          nPlanW:=FValue;
          FSumTon:=FSumTon+nPlanW;
          if nBatQuaS-FSumTon<=nBatQuaE then    //到预警量
          begin
            nStr:='试样编号['+FSampleID+']已到预警量,是否继续保存？';
            if not QueryDlg(nStr, sAsk) then
            begin
              {if UpdateSampleValid(cbxSampleID.Text) then
                GetSampleID(EditStockName.Text,EditType.Text); }
              Exit;
            end;
          end;
          if FSumTon-nBatQuaS>0 then
          begin
            ShowMsg('试样编号['+FSampleID+']已超量',sHint);
            Exit;
          end;
        end else
        begin
          ShowMsg('试样编号['+FSampleID+']已失效',sHint);
          Exit;
        end;
      end;
      {$ENDIF}
      Values['SampleID'] := FSampleID;
      nStockNo:= Values['StockNO'];
      nList.Add(PackerEncodeStr(nTmp.Text));
      //new bill

      if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
        nPrint := nStocks.IndexOf(FStockNO) >= 0;
      //xxxxx
    end;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := gInfo.FZhiKa;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := GetCtrlData(EditLading);
      //Values['VPListID']:=
      //Values['IsVIP'] := GetCtrlData(EditType);
      //Values['Seal'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
      if chkIfHYprint.Checked then
        Values['IfHYprt'] := 'Y'
      else
        Values['IfHYprt'] := 'N';
      Values['SalesType'] := gInfo.FSalesType;
      Values['CenterID']:=nCenterID;
      Values['JXSTHD'] := Trim(EditJXSTHD.Text);

      {$IFDEF YDKP}
      if cbxKw.Itemindex< 0 then
      begin
        ShowMsg('请选择库位号', sHint); Exit;
      end;
      nPos:=Pos('.',cbxKw.Text);
      if (nPos>0) and (nPos<Length(cbxKw.Text)) then
      begin
        Values['KuWei']:= Copy(cbxKw.Text,1,nPos-1);
        Values['LocationID']:= Copy(cbxKw.Text,nPos+1,Length(cbxKw.Text)-nPos);
      end else
      begin
        ShowMsg('库位格式非法', sHint); Exit;
      end;
      {$ELSE}
      Values['KuWei'] := '';
      Values['LocationID']:= 'A';
      {$ENDIF}
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
    gInfo.FIDList := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if gInfo.FIDList = '' then Exit;
  finally
    nTmp.Free;
    nList.Free;
    nStocks.Free;
  end;

  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(gInfo.FIDList, EditTruck.Text, True);
  //办理磁卡

  if PrintYesNo then
    PrintDaiBill(gInfo.FIDList, True);
  //print report
  
  ModalResult := mrOk;
  ShowMsg('提货单保存成功', sHint);
end;

procedure TfFormBill.cbxSampleIDPropertiesChange(Sender: TObject);
begin
  {$IFDEF YDKP}
  if cbxSampleID.ItemIndex > -1 then chkIfHYprint.Checked:=True;
  {$ENDIF}
end;

procedure TfFormBill.cbxCenterIDPropertiesEditValueChanged(
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
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
