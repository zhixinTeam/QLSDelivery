{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 纸卡冻结
*******************************************************************************}
unit UFormZhiKaFreeze;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup, cxCheckComboBox, cxCheckBox,
  cxGroupBox, cxCheckGroup, cxCheckListBox, ImgList;

type
  TfFormZKFreeze = class(TfFormNormal)
    Radio1: TcxRadioButton;
    dxLayout1Item3: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item4: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    ListStock: TcxCheckListBox;
    dxLayout1Item9: TdxLayoutItem;
    cxImageList1: TcxImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure Check1PropertiesEditValueChanged(Sender: TObject);
    procedure ListStockDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    procedure InitFormData;
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
  IniFiles, ULibFun, UFormBase, UMgrControl, USysDB, USysConst, USysBusiness,
  UDataModule;

var
  gItems: TDynamicStockItemArray;
  //品种列表

//------------------------------------------------------------------------------
class function TfFormZKFreeze.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormZKFreeze.Create(Application) do
  begin
    Caption := '纸卡冻结';
    InitFormData;
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZKFreeze.FormID: integer;
begin
  Result := cFI_FormFreezeZK;
end;

procedure TfFormZKFreeze.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZKFreeze.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormZKFreeze.InitFormData;
var nIdx,nLen: Integer;
begin
  ListStock.Items.Clear;
  if not GetLadingStockItems(gItems) then Exit;

  nLen := Length(gItems);
  if nLen > 5 then
       ListStock.Columns := 2
  else ListStock.Columns := 0;

  for nIdx:=0 to nLen - 1 do
  with ListStock.Items.Add do
  begin
    Text := gItems[nIdx].FName;
    State := cbsUnchecked;
    Tag := nIdx;
  end;
end;

//Desc: 快速选择
procedure TfFormZKFreeze.Check1PropertiesEditValueChanged(Sender: TObject);
var nIdx: Integer;
    nType: string;
    nStatus: TcxCheckBoxState;
begin
  if Sender = Check1 then
  begin
    nType := sFlag_Dai;
    if Check1.Checked then
         nStatus := cbsChecked
    else nStatus := cbsUnchecked;
  end else

  if Sender = Check2 then
  begin
    nType := sFlag_San;
    if Check2.Checked then
         nStatus := cbsChecked
    else nStatus := cbsUnchecked;
  end else Exit;

  for nIdx:=Low(gItems) to High(gItems) do
   if gItems[nIdx].FType = nType then
    ListStock.Items[nIdx].State := nStatus;
  //xxxxx
end;

procedure TfFormZKFreeze.ListStockDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin 
  if ListStock.Items[Index].State = cbsChecked then
       ListStock.Items[Index].ImageIndex := 1
  else ListStock.Items[Index].ImageIndex := 0;

  inherited;
end;

procedure TfFormZKFreeze.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nStr,nStock: string;
begin
  nStock := '';
  for nIdx:=Low(gItems) to High(gItems) do
  if ListStock.Items[nIdx].State = cbsChecked then
  begin
    if nStock = '' then
         nStock := '''' + gItems[nIdx].FID + ''''
    else nStock := nStock + ',''' + gItems[nIdx].FID + '''';
  end;

  if nStock = '' then
  begin
    ListStock.SetFocus;
    ShowMsg('请选择有效的水泥品种', sHint); Exit;
  end;

  nStr := '确定要%s所有包含被选中品种的纸卡吗?';
  if Radio1.Checked then
       nStr := Format(nStr, ['冻结', nStock])
  else nStr := Format(nStr, ['解冻', nStock]);
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  if Radio1.Checked then
  begin
    nStr := 'Update $ZK Set Z_TJStatus=''$Frz'' Where Z_ID In (' +
            'Select D_ZID From $Dtl Where D_StockNo In ($Stock)) and ' +
            'IsNull(Z_InValid,'''')<>''$Yes'' And Z_ValidDays>$Now';
    //tjing
  end else
  begin
    nStr := 'Update $ZK Set Z_TJStatus=''$Ovr'' Where Z_ID In (' +
            'Select D_ZID From $Dtl Where D_StockNo In ($Stock)) and ' +
            'Z_TJStatus=''$Frz''';
    //jtover
  end;

  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Stock', nStock),
          MI('$Dtl', sTable_ZhiKaDtl), MI('$Frz', sFlag_TJing),
          MI('$Ovr', sFlag_TJOver), MI('$Yes', sFlag_Yes),
          MI('$Now', FDM.SQLServerNow)]);
  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZKFreeze, TfFormZKFreeze.FormID);
end.
