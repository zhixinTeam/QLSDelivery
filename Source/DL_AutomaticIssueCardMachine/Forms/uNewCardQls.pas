{*******************************************************************************
  作者: juner11212436@163.com 2017-10-3
  描述: 祁连山自助办卡
*******************************************************************************}
unit uNewCardQls;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Uszttce_api,Contnrs, dxSkinsCore,
  dxSkinsDefaultPainters;

type

  TfFormNewCardQls = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditCard: TcxTextEdit;
    EditCus: TcxTextEdit;
    EditCName: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditValue: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    EditType: TcxComboBox;
    PrintFH: TcxCheckBox;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item10: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    dxlytmLayout1Item11: TdxLayoutItem;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayout1Item7: TdxLayoutItem;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    EditID: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    LabInfo: TcxLabel;
    dxLayout1Item3: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item1: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    cbxCenterID: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure EditValue1KeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure editWebOrderNoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FErrorCode:Integer;
    FErrorMsg:string;
    FNewBillID,FWebOrderID:string;
    FSzttceApi:TSzttceApi;
    FAutoClose:Integer;
    function DownloadOrder(const nCard:string):Boolean;
    function SaveBillProxy:Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    procedure SetControlsReadOnly;
    function IsRepeatCard(const nLID:string):Boolean;
    function LoadValidZTLineGroup(const nStockno:string;const nList: TStrings):Boolean;
    function GetOutASH(const nStr: string): string;
    //获取批次号条件
    function GetStockType(const nStockno:string):string;
    function IsEleCardVaid(const nStockType, nTruckNo:string):Boolean;
    //电子标签是否启用
  public
    { Public declarations }
    procedure SetControlsClear;
    property SzttceApi:TSzttceApi read FSzttceApi write FSzttceApi;
  end;

var
  fFormNewCardQls: TfFormNewCardQls;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormCard,UFormBase,UDataReport,UDataModule,NativeXml,DB;
{$R *.dfm}

var
  gZhiKa,gRecID,gSalesType,gStockNo,gStockName,gPrice,gType:string;
  gCusID,gCompanyID,gFYPlanStatus,gInventLocationId,gIDList:string;
  //全局使用

procedure TfFormNewCardQls.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCardQls.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=  caFree;
  fFormNewCardQls := nil;
  FreeAndNil(FDR);
  fFormMain.TimerInsertCard.Enabled := True;
end;

procedure TfFormNewCardQls.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxLayout1Item9.Visible := True;
  EditTruck.Properties.Buttons[0].Visible := False;

  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
end;

procedure TfFormNewCardQls.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then Exit;
    Close;
  finally
    BtnOK.Enabled := True;
  end;
end;

procedure TfFormNewCardQls.FormCreate(Sender: TObject);
begin
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewCardQls.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '请先输入或扫描订单号';
      ShowMsg(nStr,sHint);
      LabInfo.Caption := nStr;
      Exit;
    end;
    editWebOrderNo.SelectAll;
    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCardQls.DownloadOrder(const nCard: string): Boolean;
var nStr,nStockNo: string;
    nDB,nDBSales,nDBLine: TDataSet;
    nRepeat: Boolean;
begin
  Result := False;
  nRepeat := IsRepeatCard(nCard);

  if nRepeat then
  begin
    ShowMsg('此订单已成功办卡，请勿重复操作',sHint);
    Exit;
  end;

  nDB := LoadAXPlanInfo(Trim(nCard),nStr);
  if Assigned(nDB) then
  with nDB do
  begin
    EditID.Text := FieldByName('AX_SALESLINERECID').AsString;
    EditCard.Text := FieldByName('AX_SALESID').AsString;
    EditTruck.Text := FieldByName('AX_VEHICLEId').AsString;
    EditCus.Text := FieldByName('AX_CUSTOMERID').AsString;
    EditValue.Text := FieldByName('AX_PLANQTY').AsString;

    gZhiKa := FieldByName('AX_SALESID').AsString;
    gRecID := FieldByName('AX_SALESLINERECID').AsString;
    gStockNo := FieldByName('AX_ITEMID').AsString;
    EditStock.Text := gStockNo;
    gPrice := FieldByName('AX_ITEMPRICE').AsString;
    gType := UpperCase(FieldByName('AX_ITEMTYPE').AsString);
    gStockName := FieldByName('AX_ITEMNAME').AsString;

    if gType = 'D' then
      gStockName := gStockName + '袋装'
    else
      gStockName := gStockName + '散装';
    nStockNo := gStockNo + gType;
    EditSName.Text := gStockName;
    gCusID := FieldByName('AX_CUSTOMERID').AsString;
    gFYPlanStatus := FieldByName('AX_FYPlanStatus').AsString;
    gInventLocationId := FieldByName('AX_InventLocationId').AsString;
    EditCName.Text := GetCustomerExtQls(gCusID);
    EditLading.ItemIndex := StrToIntDef(GetLadingWay(gZhiKa),0);
    EditType.ItemIndex := 0;
    InitCenter(nStockNO,gCusID,cbxCenterID);
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
    if not IsNumber(EditValue.Text,True) then
    begin
      ShowMsg('提货量非法！请检查提货单',sHint);
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
  Result := True;
end;

function TfFormNewCardQls.SaveBillProxy: Boolean;
var
  nBillValue:Double;
  nHint:string;

  nList,nTmp,nStocks: TStrings;
  nPrint:Boolean;
  nBillData:string;
  nNewCardNo:string;
  nStr,nType:string;
  nPos:Integer;
  nZID,nCenterID,nSampleID:string;
begin
  FNewBillID := '';
  Result := False;
  //校验提货单信息
  if EditID.Text='' then
  begin
    ShowMsg('未查询网上订单',sHint);
    LabInfo.Caption := '未查询网上订单';
    Exit;
  end;
  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    LabInfo.Caption := nHint;
    Exit;
  end;
  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    LabInfo.Caption := nHint;
    Exit;
  end;
  {$IFDEF ZXKP}
  if not CheckTruckOK(Trim(EditTruck.Text)) then
  begin
    ShowMsg(EditTruck.Text+'刚出厂，禁止开单',sHint);
    Exit;
  end;
  if not CheckTruckBilling(Trim(EditTruck.Text)) then
  begin
    ShowMsg(EditTruck.Text+'非法，禁止开单',sHint);
    Exit;
  end;
  {$ENDIF}
  
  {$IFDEF CXSY}
  if cbxCenterID.Text= '' then
  begin
    ShowMsg('生产线为空！请联系管理员', sHint); Exit;
  end;
  if not IsEleCardVaid(gType,EditTruck.Text) then
  begin
    ShowMsg('车辆未办理电子标签或电子标签未启用！请联系管理员', sHint); Exit;
  end;
  {$ENDIF}
  if gSysParam.FUserID = '' then gSysParam.FUserID := 'AICM';
  nCenterID := cbxCenterID.Text;
  nSampleID := '';

  //青海不需要开票获取试样编号
  {nSampleID := GetSamplelNo(FCardData.Values['XCB_CementName'],nCenterID);
  if nSampleID = '' then
  begin
    nHint := '试样编号使用完毕，请联系工作人员。';
    ShowMsg(nHint,sHint);
    LabInfo.Caption := nHint;
    Exit;
  end;}
  if QueryDlg('是否需要打印化验单?', sAsk) then
    PrintFH.Checked := True
  else
    PrintFH.Checked := False;
  //保存提货单
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    with nTmp do
    begin
      Values['Type'] := gType;
      Values['StockNO'] := gStockNO;
      Values['StockName'] := EditSName.text;
      Values['Price'] := gPrice;
      Values['Value'] := EditValue.text;
      Values['RECID'] := gRecID;
      Values['SampleID'] := '';
      {$IFDEF ZXKP}
      if not CheckTruckCount(Trim(EditSName.text)) then
      begin
        ShowMsg('厂内车辆达到上限，禁止开单',sHint);
        Exit;
      end;
      {$ENDIF}
    end;

    nList.Add(PackerEncodeStr(nTmp.Text));
    nPrint := nStocks.IndexOf(gStockNO) >= 0;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['LID'] := Trim(editWebOrderNo.Text);
      Values['ZhiKa'] := gZhiKa;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := IntToStr(EditLading.ItemIndex);
      //Values['VPListID']:=
      Values['IsVIP'] := EditType.Text;
      //Values['Seal'] := EditFQ.Text;
      Values['BuDan'] := 'N';
      if PrintFH.Checked then
        Values['IfHYprt'] := 'Y'
      else
        Values['IfHYprt'] := 'N';
      Values['SalesType'] := gSalesType;
      Values['CenterID']:= nCenterID;
      Values['JXSTHD'] := '';
      Values['Project'] := Trim(EditCName.Text);
      Values['IfFenChe'] := 'N';
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
    nBillData := PackerEncodeStr(nList.Text);
    FNewBillID := SaveBill(nBillData);
    if FNewBillID = '' then
    begin
      ShowMsg('提货单保存失败！请联系管理员', sHint);
      Exit;
    end;
  finally
    nStocks.Free;
    nList.Free;
    nTmp.Free;
  end;
  ShowMsg('提货单保存成功', sHint);
  //发卡
  if not FSzttceApi.IssueOneCard(nNewCardNo) then
  begin
    nHint := '出卡失败,请到开票窗口补办磁卡：[errorcode=%d,errormsg=%s]';
    nHint := Format(nHint,[FSzttceApi.ErrorCode,FSzttceApi.ErrorMsg]);
    ShowMsg(nHint,sHint);
    LabInfo.Caption := nHint;
  end
  else begin
    ShowMsg('发卡成功,卡号['+nNewCardNo+'],请收好您的卡片',sHint);
    SetBillCard(FNewBillID, EditTruck.Text,nNewCardNo, True);
  end;
  Result := True;
  {$IFDEF PLKP}
  if nPrint then  //平凉使用
  {$ELSE}
  if PrintYesNo then
  {$ENDIF}
    PrintBillReport(FNewBillID, False);
  //print report

  //if IFPrintFYD then
  //  PrintBillFYDReport(FNewBillID, True);
  //打印发运单

  Close;
end;

function TfFormNewCardQls.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '办理吨数无效！请联系管理员';
    if not Result then Exit;

//    nVal := StrToFloat(EditValue.Text);
//    Result := FloatRelation(nVal, StrToFloat(EditMax.Text),rtLE);
//    nHint := '已超出可提货量';
  end;
end;

procedure TfFormNewCardQls.editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCardQls.EditValue1KeyPress(Sender: TObject; var Key: Char);
begin
  if key=Char(vk_return) then
  begin
    key := #0;
    BtnOK.Click;
  end;
end;

procedure TfFormNewCardQls.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;

procedure TfFormNewCardQls.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
//  editIdCard.Properties.ReadOnly := True;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
end;


function TfFormNewCardQls.IsRepeatCard(const nLID: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where L_ID=''%s'' ';
  nStr := Format(nStr,[sTable_Bill,nLID]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCardQls.LoadValidZTLineGroup(const nStockno: string;const nList: TStrings): Boolean;
var
  nSql,nStr,nSql2:string;
  i:Integer;
  code,desc:string;
  nData: PStringsItemData;
begin
  Result := False;
  for i := 0 to nList.Count-1 do
  begin
    Dispose(Pointer(nList.Objects[i]));
    nList.Objects[i] := nil;
  end;
  nList.Clear;

  nSql := 'select distinct z_group from %s where z_valid=''Y'' and z_stockno=''%s''';
  nSql :=Format(nSql,[sTable_ZTLines,nStockno]);
  if FDM.QueryTemp(nSql).RecordCount<1 then
  begin
    FErrorCode := 1010;
    FErrorMsg := '当前没有可用的装车线，请等候';
    Exit;
  end;
  with FDM.QueryTemp(nSql) do
  begin
    for i := 0 to RecordCount-1 do
    begin
      code := FieldByName('z_group').AsString;
      nSql2 := 'select d_memo from %s where d_name=''%s'' and d_value=''%s''';
      nSql2 :=Format(nSql2,[sTable_SysDict,sFlag_ZTLineGroup,code]);
      desc := FDM.QuerySQL(nSql2).FieldByName('d_memo').AsString;

      New(nData);
      nList.Add(desc+'.');
      nData.FString := code;
      nList.Objects[i] := TObject(nData);
      Next;
    end;
  end;
  Result := True;
end;

function TfFormNewCardQls.GetOutASH(const nStr: string): string;
var nPos: Integer;
    nTmp: string;
begin
  nTmp := nStr;
  nPos := Pos('.', nTmp);

  System.Delete(nTmp, 1, nPos);
  Result := nTmp;
end;

function TfFormNewCardQls.getStockType(const nStockno: string): string;
var
  nSql:string;
begin
  Result := '';
  nSql := 'select D_Memo from %s where d_name = ''%s'' and d_paramB=''%s''';
  nSql := Format(nSql,[sTable_SysDict,sFlag_StockItem,nStockno]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      Result := FieldByName('D_Memo').AsString;
    end;
  end;
end;

procedure TfFormNewCardQls.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

procedure TfFormNewCardQls.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCardQls.editWebOrderNoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
end;

function TfFormNewCardQls.IsEleCardVaid(const nStockType,
  nTruckNo: string): Boolean;
var
  nSql:string;
begin
  Result := False;
  if nStockType <> 'S' then
  begin
    Result := True;
    Exit;
  end;
  nSql := 'select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruckNo]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      if (FieldByName('T_Card').AsString = '') and (FieldByName('T_Card2').AsString = '') then
        Exit;
      Result := FieldByName('T_CardUse').AsString = sFlag_Yes;
    end;
  end;
end;

end.
