{*******************************************************************************
  作者: dmzn@163.com 2011-01-23
  描述: 筛选周期
*******************************************************************************}
unit UFormInvoiceGetWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup;

type
  TfFormInvoiceGetWeek = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    EditYear: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditWeek: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditYearPropertiesEditValueChanged(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nYear,nWeek: string);
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
  ULibFun, UFormBase, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  UAdjustForm;

class function TfFormInvoiceGetWeek.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
    nForm: TfFormInvoiceGetWeek;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_GetData then Exit;
  nForm := TfFormInvoiceGetWeek.Create(Application);

  with nForm do
  try
    Caption := '周期 - 选择';
    InitFormData(nP.FParamA, nP.FParamB);

    if nP.FParamE <> sFlag_Yes then
      nP.FParamA := ShowModal;
    //only get default week

    nP.FCommand := cCmd_ModalResult;
    nP.FParamB := EditYear.Text;
    nP.FParamC := GetCtrlData(EditWeek);
    nP.FParamD := EditWeek.Text;

    if nP.FParamC = nP.FParamD then
      nP.FParamC := '';
    //set all weeks
  finally
    ReleaseCtrlData(nForm);
    Free;
  end;
end;

class function TfFormInvoiceGetWeek.FormID: integer;
begin
  Result := cFI_FormInvGetWeek;
end;

procedure TfFormInvoiceGetWeek.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormInvoiceGetWeek.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceGetWeek.InitFormData(const nYear,nWeek: string);
var nStr: string;
    nInt: Integer;
    nY1,nY2,nM,nD: Word;
begin
  EditYear.Properties.Items.Clear;
  nStr := 'SELECT MIN(W_Begin) AS W_Begin, MAX(W_End) AS W_End FROM %s';
  nStr := Format(nStr, [sTable_InvoiceWeek]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    DecodeDate(Fields[0].AsDateTime, nY1, nM, nD);
    DecodeDate(Fields[1].AsDateTime, nY2, nM, nD);

    for nInt:=nY1 to nY2 do
      EditYear.Properties.Items.Add(IntToStr(nInt));
    //xxxxx
  end;

  with EditYear.Properties do
  begin
    if Items.Count < 1 then
    begin
      ShowMsg('未找到有效周期', sHint); Exit;
    end;

    if nYear = '' then
    begin
      DecodeDate(Now, nY1, nM, nD);
      EditYear.ItemIndex := Items.IndexOf(IntToStr(nY1));
    end else EditYear.ItemIndex := Items.IndexOf(nYear);
  end; //focus to load week list

  with EditWeek.Properties do
  begin
    if Items.Count < 1 then Exit;
    //no week in list

    if nWeek = '' then
    begin
      nStr := 'Select Top 1 W_NO From $W ' +
              'Where (W_Begin<=$Now And W_End+1>$Now) Or (W_Begin>=$Now) ' +
              'Order By W_Begin ASC';
      nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
              MI('$Now', FDM.SQLServerNow)]);
      //get now fix week

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
           nStr := Fields[0].AsString
      else nStr := '';
    end else nStr := nWeek;

    if nStr = '' then
         EditWeek.ItemIndex := 0
    else EditWeek.ItemIndex := GetStringsItemIndex(Items, nStr);
  end;
end;

//Desc: 年份变化,更新周期
procedure TfFormInvoiceGetWeek.EditYearPropertiesEditValueChanged(
  Sender: TObject);
var nStr: string;
    nInt: Integer;
    nExt: TDynamicStrArray;
begin
  if EditYear.ItemIndex > -1 then
  with EditWeek.Properties do
  begin
    nInt := StrToInt(EditYear.Text);
    AdjustStringsItem(Items, True);

    nStr := 'W_NO=Select W_NO,W_Name From $W Where (W_Begin>=''$S'' and ' +
            'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
            'Order By W_Begin';
    nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
            MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1))]);
    //xxxxx

    SetLength(nExt, 1);
    nExt[0] := 'W_NO';
    FDM.FillStringsData(Items, nStr, 0, '', nExt);

    InsertStringsItem(Items, '全部周期', 0);
    AdjustStringsItem(EditWeek.Properties.Items, False);
  end;
end;

procedure TfFormInvoiceGetWeek.BtnOKClick(Sender: TObject);
begin
  if EditYear.ItemIndex < 0 then
  begin
    EditYear.SetFocus;
    ShowMsg('请选择年份', sHint); Exit;
  end;

  if EditWeek.ItemIndex < 0 then
  begin
    EditWeek.SetFocus;
    ShowMsg('请选择有效周期', sHint); Exit;
  end;

  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormInvoiceGetWeek, TfFormInvoiceGetWeek.FormID);
end.
