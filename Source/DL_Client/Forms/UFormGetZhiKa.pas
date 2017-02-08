{*******************************************************************************
  作者: dmzn@163.com 2014-09-01
  描述: 开提货单
*******************************************************************************}
unit UFormGetZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxListView,
  cxDropDownEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMCListBox,
  dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters;

type
  TfFormGetZhiKa = class(TfFormNormal)
    dxLayout1Item7: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item8: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditName: TcxComboBox;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListDetail: TcxListView;
    dxLayout1Item4: TdxLayoutItem;
    EditZK: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure EditZKPropertiesEditValueChanged(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditZKKeyPress(Sender: TObject; var Key: Char);
  protected
    { Private declarations }
    FShowPrice: Boolean;
    //显示单价
    FQueryFlag: Boolean;
    //查询互斥
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
  USysPopedom, USysGrid, USysDB, USysConst, USysBusiness;

type
TStockItem = record
    FType: string;
    FStockName: string;
    FPrice: string;
    FValue: string;
    FRecID: string;
  end;

var
  gParam: PFormCommandParam = nil;
  //全局使用
  gStockList: array of TStockItem;
  //

class function TfFormGetZhiKa.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;
  gParam := nParam;

  with TfFormGetZhiKa.Create(Application) do
  try
    Caption := '选择纸卡';
    InitFormData('');
    //FShowPrice := gPopedomManager.HasPopedom(nPopedom, sPopedom_ViewPrice);
    if gSysParam.FIsAdmin then FShowPrice:= True else FShowPrice:=False;
    
    gParam.FCommand := cCmd_ModalResult;
    gParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormGetZhiKa.FormID: integer;
begin
  Result := cFI_FormGetZhika;
end;

procedure TfFormGetZhiKa.FormCreate(Sender: TObject);
begin
  LoadMCListBoxConfig(Name, ListInfo);
  LoadcxListViewConfig(Name, ListDetail);
  FQueryFlag:=False;
end;

procedure TfFormGetZhiKa.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveMCListBoxConfig(Name, ListInfo);
  SavecxListViewConfig(Name, ListDetail);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormGetZhiKa.InitFormData(const nID: string);
begin
  dxGroup1.AlignVert := avTop;
  ActiveControl := EditZK;
end;

//Desc: 清理客户信息
procedure TfFormGetZhiKa.ClearCustomerInfo;
begin
  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;

  ListInfo.Clear;
  ActiveControl := EditName;
end;

//Desc: 载入nID客户的信息
function TfFormGetZhiKa.LoadCustomerInfo(const nID: string): Boolean;
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
    nCusName := FieldByName('Z_OrgAccountName').AsString;
  end;

  EditID.Text := nID;

  if GetStringsItemIndex(EditName.Properties.Items, nID) < 0 then
  begin
    nStr := Format('%s=%s.%s', [nID, nID, nCusName]);
    InsertStringsItem(EditName.Properties.Items, nStr);
  end;

  SetCtrlData(EditName, nID);
  //customer info done
  //if FQueryFlag then Exit;
  //----------------------------------------------------------------------------
  if EditZK.Text <> '' then Exit;
  nStr := 'Z_ID=Select Z_ID, Z_OrgAccountName From %s ' +
          'Where Z_OrgAccountNum=''%s'' '+
          'And ((Z_SalesStatus=''1'') or '+
          '((Z_SalesType=''0'') and '+
          '((Z_SalesStatus=''0'') or '+
          '(Z_SalesStatus=''1'')))) '+
          'Order By Z_ID';

  nStr := Format(nStr, [sTable_ZhiKa, nID]);

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


procedure TfFormGetZhiKa.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormGetZhiKa.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('请填写有效编号', sHint);
  end else
  begin
    LoadCustomerInfo(EditID.Text);
  end;
end;

procedure TfFormGetZhiKa.EditZKPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
    i,nIdx: Integer;
    nNewPrice: Double;
begin
  if EditZK.ItemIndex < 0 then Exit;

  SetLength(gStockList, 0);
  nStr := 'Select D_StockName,D_Price,D_Value,D_Type,D_RECID From %s Where D_Blocked=''0'' and D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, GetCtrlData(EditZK)]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg(GetCtrlData(EditZK)+'订单已停止',sHint);
      Exit;
    end;
    nIdx:=0;
    SetLength(gStockList, RecordCount);
    First;
    while not Eof do
    begin
      with gStockList[nIdx] do
      begin
        FType:= Fields[3].AsString;
        if Fields[3].AsString='D' then
          FStockName := Fields[0].AsString+'袋装'
        else
          FStockName := Fields[0].AsString+'散装';
        if FShowPrice then
            nStr := Format('%.2f',[Fields[1].AsFloat])
        else nStr := '---';
        FPrice:=nStr;
        FValue:=Format('%.2f',[Fields[2].AsFloat]);
        FRecID:=Fields[4].AsString;
      end;
      Inc(nIdx);
      Next;
    end;
  end;
  ListDetail.Clear;
  for i:=Low(gStockList) to High(gStockList) do
  begin
    with ListDetail.Items.Add do
    begin
      Checked := False;
      Caption := gStockList[i].FStockName;
      if FShowPrice then
      begin
        if LoadAddTreaty(gStockList[i].FRecID,nNewPrice) then
          SubItems.Add(Format('%.2f',[nNewPrice]))
        else
          SubItems.Add(gStockList[i].FPrice);
      end else
      begin
        SubItems.Add('---');
      end;
      SubItems.Add(gStockList[i].FValue);
    end;
  end;
end;

//Desc: 选择客户
procedure TfFormGetZhiKa.EditNameKeyPress(Sender: TObject; var Key: Char);
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

    SetCtrlData(EditName, nP.FParamB);
    SetCtrlData(EditZK, nP.FParamD);
    if EditName.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditName.Properties.Items, nStr);
      SetCtrlData(EditName, nP.FParamB);
    end;
    if EditZK.Text <> '' then EditZK.SetFocus;
  end;
end;

procedure TfFormGetZhiKa.BtnOKClick(Sender: TObject);
var
  nIdx:Integer;
begin
  if EditZK.ItemIndex < 0 then
  begin
    ShowMsg('请选择纸卡', sHint);
    Exit;
  end;
  gParam.FParamD:=0;
  for nIdx:= 0 to ListDetail.Items.Count-1 do
  begin
    if ListDetail.Items.Item[nIdx].Checked then
    begin
      gParam.FParamD:=nIdx;
      Break;
    end;
  end;

  gParam.FParamB := GetCtrlData(EditZK);
  ModalResult := mrOk;
end;

procedure TfFormGetZhiKa.EditZKKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    EditZK.Properties.Items.Clear;
    EditZK.Text:=Trim(EditZK.Text);
    nStr := 'Z_ID=Select Z_ID, Z_OrgAccountName From $ZK zk '+
            'Where Z_ID Like ''%$ID%'' '+
            'And ((Z_SalesStatus=''1'') or '+
            '((Z_SalesType=''0'') and '+
            '((Z_SalesStatus=''0'') or '+
            '(Z_SalesStatus=''1'')))) '+
            'Order By Z_ID';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ID', EditZK.Text)]);
    with EditZK.Properties do
    begin
      AdjustStringsItem(Items, True);
      FDM.FillStringsData(Items, nStr, 0, '.');
      AdjustStringsItem(Items, False);

      if Items.Count > 0 then
      begin
        EditZK.ItemIndex := 0;
        FQueryFlag:=True;
      end else
      begin
        ShowMsg('订单号无效',sHint);
        Exit;
      end;

      ActiveControl := BtnOK;
      //准备开单
    end;
  end;
  {if Key = #13 then
  begin
    Key := #0;
    nP.FParamA := GetCtrlData(EditZK);

    if nP.FParamA = '' then
      nP.FParamA := EditZK.Text;
    //xxxxx


    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditName, nP.FParamB);

    if EditName.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditName.Properties.Items, nStr);
      SetCtrlData(EditName, nP.FParamB);
    end;
  end;}
end;

initialization
  gControlManager.RegCtrl(TfFormGetZhiKa, TfFormGetZhiKa.FormID);
end.
