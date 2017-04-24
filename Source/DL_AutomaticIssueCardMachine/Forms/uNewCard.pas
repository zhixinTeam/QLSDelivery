unit uNewCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Uszttce_api,Contnrs;

type
  PWorkshop=^TWorkshop;
  TWorkshop = record
    code:string;
    desc:string;
    remainder:Integer;
    WarehouseList:TStringList;
  end;
  TfFormNewCard = class(TForm)
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
    EditDate: TcxTextEdit;
    EditArea: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditMax: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    EditType: TcxComboBox;
    PrintFH: TcxCheckBox;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxlytmLayout1Item6: TdxLayoutItem;
    dxlytmLayout1Item8: TdxLayoutItem;
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
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    EditID: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    LabInfo: TcxLabel;
    dxLayout1Item3: TdxLayoutItem;
    EditToaddr: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditIdNo: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure EditValue1KeyPress(Sender: TObject; var Key: Char);
    procedure lvOrdersClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure editWebOrderNoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FErrorCode:Integer;
    FErrorMsg:string;
    FCardData,FComentData:TStrings;
    FNewBillID,FWebOrderID:string;
    FWebOrderItems:array of stMallOrderItem;
    FWebOrderIndex,FWebOrderCount:Integer;
    FSzttceApi:TSzttceApi;
    FGetBatchCode:Boolean;
    FWorkshopList:TList;
    FAutoClose:Integer;
    function DownloadOrder(const nCard:string):Boolean;
    function CheckYunTianOrderInfo(const nOrderId:string;var nWebOrderItem:stMallOrderItem):Boolean;
    function SaveBillProxy:Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    procedure SaveWebOrderMatch;
    procedure SetControlsReadOnly;
    procedure InitListView;
    procedure LoadSingleOrder;
    procedure AddListViewItem(var nWebOrderItem:stMallOrderItem);
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function LoadValidZTLineGroup(const nStockno:string;const nList: TStrings):Boolean;
    function LoadWarehouseConfig:Boolean;
    function GetOutASH(const nStr: string): string;
    //获取批次号条件
    function GetStockType(const nStockno:string):string;
  public
    { Public declarations }
    procedure SetControlsClear;
    property SzttceApi:TSzttceApi read FSzttceApi write FSzttceApi;
  end;

var
  fFormNewCard: TfFormNewCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormCard,UFormBase,UDataReport,UDataModule,NativeXml;
{$R *.dfm}

procedure TfFormNewCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i:Integer;
  nItem:PWorkshop;
begin
  Action:=  caFree;
  fFormNewCard := nil;
  FCardData.Free;
  FComentData.Free;
  for i := FWorkshopList.Count-1 downto 0 do
  begin
    nItem := PWorkshop(FWorkshopList.Items[i]);
    nItem.WarehouseList.Free;
    Dispose(nItem);
  end;
  FWorkshopList.Free;
  FreeAndNil(FDR);
  fFormMain.TimerInsertCard.Enabled := True;
end;

procedure TfFormNewCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxLayout1Item9.Visible := True;
  dxlytmLayout1Item6.Visible := False;
  dxlytmLayout1Item8.Visible := False;

//  dxLayout1Item11.Visible := False;
//  dxlytmLayout1Item11.Visible := False;
  dxlytmLayout1Item13.Visible := False;
  EditTruck.Properties.Buttons[0].Visible := False;

  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;  
end;

procedure TfFormNewCard.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then Exit;
    Close;
  finally
    BtnOK.Enabled := True;
  end;
end;

procedure TfFormNewCard.FormCreate(Sender: TObject);
begin
  FCardData := TStringList.Create;
  FComentData := TStringList.Create;
  FWorkshopList := TList.Create;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  if not LoadWarehouseConfig then
  begin
    ShowMsg(FErrorMsg,sHint);
  end;
  InitListView;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewCard.btnQueryClick(Sender: TObject);
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
    lvOrders.Items.Clear;
    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nIDCard:string;
  nListA,nListB:TStringList;
  i,j:Integer;
//  nOrderItem:stMallOrderItem;
begin
  Result := False;
  FWebOrderIndex := 0;
  nIDCard := Trim(editWebOrderNo.Text);
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'      <NO>%s</NO>'
            +'</head>'
            +'</DATA>';

  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nIDCard]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := get_shoporderbyno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('未查询到网上商城订单['+nIDCard+']详细信息，请检查订单号是否正确',sHint);
    LabInfo.Caption := '未查询到网上商城订单['+nIDCard+']详细信息，请检查订单号是否正确';
    Exit;
  end;

  //解析网城订单信息
  nData := PackerDecodeStr(nData);
  gSysLoger.AddLog('get_shoporderbyno res:'+nData);
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
//    nListA.add(nData);
    nListA.Text := nData;
    for i := nListA.Count-1 downto 0 do
    begin
      if Trim(nListA.Strings[i])='' then
      begin
        nListA.Delete(i);
      end;
    end;
    FWebOrderCount := nListA.Count;
    SetLength(FWebOrderItems,FWebOrderCount);
    for i := 0 to nListA.Count-1 do
    begin
      nListB.CommaText := nListA.Strings[i];
      FWebOrderItems[i].FOrder_id := nListB.Values['order_id'];
      FWebOrderItems[i].FOrdernumber := nListB.Values['ordernumber'];
      FWebOrderItems[i].FGoodsID := nListB.Values['goodsID'];
      FWebOrderItems[i].FGoodstype := nListB.Values['goodstype'];
      FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
      FWebOrderItems[i].FData := nListB.Values['data'];
      FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
      FWebOrderItems[i].FYunTianOrderId := nListB.Values['fac_order_no'];
      gSysParam.FUserID := nListB.Values['namepinyin'];
      FWebOrderItems[i].Ftoaddress := nListB.Values['toaddress'];
      FWebOrderItems[i].Fidnumber := nListB.Values['idnumber'];
      AddListViewItem(FWebOrderItems[i]);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
  FGetBatchCode := True;
  LoadSingleOrder;
end;

function TfFormNewCard.CheckYunTianOrderInfo(const nOrderId: string;
  var nWebOrderItem: stMallOrderItem): Boolean;
var
  nCardDataStr: string;
  nIn: TWorkerBusinessCommand;
  nOut: TWorkerBusinessCommand;
  nCard,nParam:string;
  nList: TStrings;

  nYuntianOrderItem:stMallOrderItem;
  nOrderNumberWeb,nOrderNumberYT:Double;
  nType:string;
begin
  if FGetBatchCode then FComentData.Clear;
  FCardData.Clear;

  nCardDataStr := nOrderId;
  if not (YT_ReadCardInfo(nCardDataStr)) then
  begin
    ShowMsg(nCardDataStr,sHint);
    LabInfo.Caption := nCardDataStr;
    Exit;
  end;

  FCardData.Text := PackerDecodeStr(nCardDataStr);

  nYuntianOrderItem.FGoodsID := FCardData.Values['XCB_Cement'];
  nYuntianOrderItem.FGoodsname := FCardData.Values['XCB_CementName'];
  nYuntianOrderItem.FOrdernumber := FCardData.Values['XCB_RemainNum'];
  nYuntianOrderItem.FCusID := FCardData.Values['XCB_Client'];
  nYuntianOrderItem.FCusName := FCardData.Values['XCB_ClientName'];

//  if nWebOrderItem.FCusID<>nYuntianOrderItem.FCusID then
//  begin
//    ShowMsg('商城订单中客户编号['+nWebOrderItem.FCusID+']有误。',sError);
//    Result := False;
//  end;

//  if nWebOrderItem.FCusName<>nYuntianOrderItem.FCusName then
//  begin
//    ShowMsg('商城订单中客户名称['+nWebOrderItem.FCusName+']有误。',sError);
//    Result := False;
//  end;

  if UpperCase(nWebOrderItem.FGoodsID)<>UpperCase(nYuntianOrderItem.FGoodsID) then
  begin
    ShowMsg('商城订单中产品型号['+nWebOrderItem.FOrder_id+']有误。',sError);
    LabInfo.Caption := '商城订单中产品型号['+nWebOrderItem.FOrder_id+']有误。';
    Result := False;
    Exit;
  end;

  if nWebOrderItem.FGoodsname<>nYuntianOrderItem.FGoodsname then
  begin
    ShowMsg('商城订单中产品名称['+nWebOrderItem.FGoodsname+']有误。',sError);
    LabInfo.Caption := '商城订单中产品名称['+nWebOrderItem.FGoodsname+']有误。';
    Result := False;
    Exit;
  end;

  nOrderNumberWeb := StrToFloatDef(nWebOrderItem.FData,0);
  //nOrderNumberYT := StrToFloatDef(nYuntianOrderItem.FOrdernumber,0);
  nOrderNumberYT := GetZhikaYL(FCardData.Values['XCB_ID']);

  if (nOrderNumberWeb<=0.000001) or (nOrderNumberYT<=0.000001) then
  begin
    ShowMsg('订单中提货数量格式有误。',sError);
    LabInfo.Caption := '订单中提货数量格式有误。';
    Result := False;
    Exit;
  end;

  if nOrderNumberWeb>nOrderNumberYT then
  begin
    ShowMsg('商城订单中提货数量有误，最多可提货数量为['+FloattoStr(nOrderNumberYT)+']。',sError);
    LabInfo.Caption := '商城订单中提货数量有误，最多可提货数量为['+FloattoStr(nOrderNumberYT)+']。';
    Result := False;
    Exit;
  end;

  if not gSysParam.FSanZhuangACIM then
  begin
    nType := GetStockType(nWebOrderItem.FGoodsID);
    if nType = sFlag_San then
    begin
      ShowMsg('当前不允许散装产品办理此业务。',sError);
      LabInfo.Caption := '当前不允许散装产品办理此业务。';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function TfFormNewCard.SaveBillProxy: Boolean;
var
  nTruck,nPrice:string;
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
  if gSysParam.FUserID = '' then gSysParam.FUserID := 'AICM';
  nCenterID := 'SL1';
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
  
  nHint := FCardData.Values['XCB_ID'];
  if not ReadStockPrice(nHint) then
  begin
    ShowMsg(nHint,sHint);
    LabInfo.Caption := nHint;
    Exit;
  end;
  nPrice := nHint;

  nPos := Pos(';',FCardData.Values['XCB_CardId']);
  if nPos > 0 then
    nZID := Copy(FCardData.Values['XCB_CardId'],1,nPos-1)
  else
    nZID := FCardData.Values['XCB_CardId'];

  //保存提货单
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;  
  try
    LoadSysDictItem(sFlag_PrintBill, nStocks);

    nTmp.Values['Type'] := FCardData.Values['XCB_CementType'];
    nTmp.Values['StockNO'] := Copy(FCardData.Values['XCB_Cement'], 1, Length(FCardData.Values['XCB_Cement'])-1);
    nTmp.Values['StockName'] := FCardData.Values['XCB_CementName'];
    nTmp.Values['Price'] := nPrice;
    nTmp.Values['Value'] := EditValue.Text;
    nTmp.Values['RECID'] := FCardData.Values['XCB_ID'];
    nTmp.Values['SampleID'] := nSampleID;

    nList.Add(PackerEncodeStr(nTmp.Text));
    nPrint := nStocks.IndexOf(Copy(FCardData.Values['XCB_Cement'], 1, Length(FCardData.Values['XCB_Cement'])-1)) >= 0;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := nZID;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := FCardData.Values['XCB_LadeType'];
      Values['Memo']  := EmptyStr;
      Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
      Values['BuDan'] := sFlag_No;

      Values['CenterID'] := nCenterID;
      if PrintFH.Checked  then
        Values['IfHYprt'] := sFlag_Yes
      else
        Values['IfHYprt'] := sFlag_No;
      Values['LID'] := '';
      Values['Project'] := EditCName.Text;
      Values['WebOrderID'] := FWebOrderID;
      Values['ToAddr'] := EditToaddr.Text;
      Values['IdNumber'] := EditIdNo.Text;
    end;
    nBillData := PackerEncodeStr(nList.Text);
    FNewBillID := SaveBill(nBillData);
    if FNewBillID = '' then Exit;
    SaveWebOrderMatch;
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

  //if nPrint then  //平凉使用
  if PrintYesNo then
    PrintBillReport(FNewBillID, False);
  //print report

  //if IFPrintFYD then
  //  PrintBillFYDReport(FNewBillID, True);
  //打印发运单 

  Close;
end;

function TfFormNewCard.VerifyCtrl(Sender: TObject;
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
    nHint := '请填写有效的办理量';
    if not Result then Exit;
                    
    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(EditMax.Text),rtLE);
    nHint := '已超出可提货量';
  end;
end;

procedure TfFormNewCard.editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCard.EditValue1KeyPress(Sender: TObject; var Key: Char);
begin
  if key=Char(vk_return) then
  begin
    key := #0;
    BtnOK.Click;
  end;
end;

procedure TfFormNewCard.SaveWebOrderMatch;
var
  nStr:string;
begin
  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID) values(''%s'',''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,FWebOrderID,FNewBillID]);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;

procedure TfFormNewCard.SetControlsClear;
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

procedure TfFormNewCard.SetControlsReadOnly;
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

procedure TfFormNewCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '网上订单编号';
  col.Width := 300;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥型号';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥名称';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '提货车辆';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '办理吨数';
  col.Width := 150;
end;

procedure TfFormNewCard.LoadSingleOrder;
var
  nOrderItem:stMallOrderItem;
  nRepeat:Boolean;
  nCorrectBatchCode,nCementCodeID:string;
  nStr,nZhiKaYL:string;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  FWebOrderID := nOrderItem.FOrdernumber;
  nRepeat := IsRepeatCard(FWebOrderID);

  if nRepeat then
  begin
    ShowMsg('此订单已成功办卡，请勿重复操作',sHint);
    Exit;
  end;
  //订单有效性校验
  if not CheckYunTianOrderInfo(nOrderItem.FYunTianOrderId,nOrderItem) then
  begin
    BtnOK.Enabled := False;
    Exit;
  end;
  nZhiKaYL:=FloatToStr(GetZhikaYL(FCardData.Values['XCB_ID']));

  //填充界面信息
  //基本信息
  EditID.Text     := FCardData.Values['XCB_ID'];
  EditCard.Text   := FCardData.Values['XCB_CardId'];
  EditCus.Text    := FCardData.Values['XCB_Client'];
  EditCName.Text  := FCardData.Values['XCB_ClientName'];
  EditDate.Text   := FCardData.Values['XCB_CDate'];
  EditArea.Text   := FCardData.Values['pcb_name'];

  //提单信息
  EditType.ItemIndex := 0;
  if FComentData.Text <> '' then
  begin
    FCardData.Values['XCB_CementCode'] := FComentData.Values['XCB_CementCode'];
    FCardData.Values['XCB_CementCodeID'] := FComentData.Values['XCB_CementCodeID'];
  end;
  EditStock.Text  := FCardData.Values['XCB_Cement'];
  EditSName.Text  := FCardData.Values['XCB_CementName'];
  //EditMax.Text    := FCardData.Values['XCB_RemainNum'];
  EditMax.Text  := nZhiKaYL;
  EditValue.Text := nOrderItem.FData;
  EditTruck.Text := nOrderItem.Ftracknumber;
  EditToaddr.Text := nOrderItem.Ftoaddress;
  EditIdNo.Text := nOrderItem.Fidnumber;
  BtnOK.Enabled := not nRepeat;
end;

procedure TfFormNewCard.AddListViewItem(
  var nWebOrderItem: stMallOrderItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrdernumber;

  nlistitem.SubItems.Add(nWebOrderItem.FGoodsID);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
end;

procedure TfFormNewCard.lvOrdersClick(Sender: TObject);
var
  nSelItem:TListItem;
  i:Integer;
begin
  nSelItem := lvorders.Selected;
  if Assigned(nSelItem) then
  begin
    for i := 0 to lvOrders.Items.Count-1 do
    begin
      if nSelItem = lvOrders.Items[i] then
      begin
        FWebOrderIndex := i;
        LoadSingleOrder;
        Break;
      end;
    end;
  end;
end;

function TfFormNewCard.IsRepeatCard(const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s'' and WOM_deleted=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem,sFlag_No]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCard.LoadValidZTLineGroup(const nStockno: string;const nList: TStrings): Boolean;
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

function TfFormNewCard.LoadWarehouseConfig: Boolean;
var
  nFileName:string;
  nRoot,nworkshopNode, nWarehouseNode: TXmlNode;
  nXML: TNativeXml;
  nPWorkshopItem:PWorkshop;
  i,j,nworkshopCount,nWarehouseCount:Integer;
  nStr:string;
begin
  Result := False;
  nFileName := ExtractFilePath(ParamStr(0))+'Warehouse_config.xml';
  if not FileExists(nFileName) then
  begin
    FErrorCode := 1000;
    FErrorMsg := '系统配置文件['+nFileName+']不存在';
    Exit;
  end;

  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFileName);
    nRoot := nXML.Root;
    nworkshopCount := nRoot.NodeCount;
    for i := 0 to nworkshopCount-1 do
    begin
      nworkshopNode := nRoot.Nodes[i];
      New(nPWorkshopItem);
      nPWorkshopItem.code := UTF8Decode(nworkshopNode.ReadAttributeString('code'));
      nPWorkshopItem.desc := UTF8Decode(nworkshopNode.ReadAttributeString('desc'));
      nPWorkshopItem.remainder := StrToIntDef(UTF8Decode(nworkshopNode.ReadAttributeString('remainder')),0);
      nPWorkshopItem.WarehouseList := TStringList.Create;
      nWarehouseCount := nworkshopNode.NodeCount;
      for j := 0 to nWarehouseCount-1 do
      begin
        nWarehouseNode := nworkshopNode.Nodes[j];
        nStr := UTF8Decode(nWarehouseNode.ValueAsString);
        nPWorkshopItem.WarehouseList.Add(nStr);
      end;
      FWorkshopList.Add(nPWorkshopItem);
    end;
    Result := True;
  finally
    nXML.Free;
  end;
end;

function TfFormNewCard.GetOutASH(const nStr: string): string;
var nPos: Integer;
    nTmp: string;
begin
  nTmp := nStr;
  nPos := Pos('.', nTmp);

  System.Delete(nTmp, 1, nPos);
  Result := nTmp;
end;

function TfFormNewCard.getStockType(const nStockno: string): string;
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

procedure TfFormNewCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

procedure TfFormNewCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCard.editWebOrderNoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
end;

end.
