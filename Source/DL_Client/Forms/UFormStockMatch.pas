{*******************************************************************************
  作者: lih 2017-10-16
  描述: 多品种共用道配置
*******************************************************************************}
unit UFormStockMatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls,
  dxLayoutcxEditAdapters, cxCheckComboBox, ExtCtrls;

type
  TfFormStockMatch = class(TfFormNormal)
    EditID: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    chkcbbStockname: TcxCheckComboBox;
    dxLayout1Item4: TdxLayoutItem;
    editStockno: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    editStockname: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    Timer1: TTimer;
    procedure BtnOKClick(Sender: TObject);
    function getStocknos:string;
    procedure setStocknos(const nstrs:string);
    procedure chkcbbStocknamePropertiesChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //标识
    FStocknoList:Tstrings;
    procedure InitFormData(const nID: string);
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据处理
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

function ShowAddStockMatchForm: Boolean;
function ShowEditStockMatchForm(const nID: string): Boolean;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, USysConst ,USysLoger;

type
  TLineStockItem = record
    FID   : string;
    FName : string;
  end;

var
  gStockItems: array of TLineStockItem;
  //品种列表
   gCheckValid: boolean;
  //通道钩选属性

function ShowAddStockMatchForm: Boolean;
begin
  with TfFormStockMatch.Create(Application) do
  try
    FID := '';
    Caption := '多品种共用通道 - 添加';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditStockMatchForm(const nID: string): Boolean;
begin
  with TfFormStockMatch.Create(Application) do
  try
    FID := nID;
    Caption := '多品种共用通道 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormStockMatch.FormID: integer;
begin
  Result := cFI_FormStockMatch;
end;

class function TfFormStockMatch.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormStockMatch.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
    nItem:TcxCheckComboBoxItem;
begin
  ResetHintAllForm(Self, 'T', sTable_StockMatch);
  //重置表名称

  if nID <> '' then
  begin
    EditID.Properties.ReadOnly := True;
    EditID.Enabled := False;
    nStr := 'Select * From %s Where R_ID=''%s''';
    nStr := Format(nStr, [sTable_StockMatch, nID]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      editStockno.Text := FDM.SqlTemp.FieldByName('M_ID').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);
    end;
  end;

  nStr := 'Select D_ParamB, D_Memo, D_Value From %s where D_Name = ''%s'' and D_Memo = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem, sFlag_Dai]);

  chkcbbStockname.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gStockItems[nIdx] do
      begin
        FID := Fields[0].AsString + Fields[1].AsString;
        FName := Fields[2].AsString;
        nItem := chkcbbStockname.Properties.Items.Add;
        nItem.Description := FID + '.' + FName;
        nItem.ShortDescription := FName;
        FStocknoList.Add(Fid);
      end;

      Inc(nIdx);
      Next;
    end;
  end;
  setStocknos(editStockno.Text);
end;

function TfFormStockMatch.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;
  
  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end;

end;

procedure TfFormStockMatch.GetData(Sender: TObject; var nData: string);
begin
  if Sender = CheckValid then
  begin
    if CheckValid.Checked   then
    begin
      nData := sFlag_Yes;
      gCheckValid := true;
    end else
    begin
      nData := sFlag_No;
      gCheckValid := false;
    end;
  end;

end;

function TfFormStockMatch.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Integer;
begin
  Result := True;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    Result := EditID.Text <> '';
    nHint := '请填写有效编号';
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '请填写有效名称';
  end;

  Result := getStocknos<>'';
  nHint := '请选择品种';
end;

procedure TfFormStockMatch.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nStr,nEvent: string;
begin
  if not IsDataValid then Exit;

  if FID = '' then
  begin
    nStr := MakeSQLByForm(Self, sTable_StockMatch, '', True, GetData);
  end else
  begin
    nStr := Format('R_ID=''%s''', [FID]);
    nStr := MakeSQLByForm(Self, sTable_StockMatch, nStr, False, GetData);
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  //--------------
  if   gCheckValid = false then
  begin
       nEvent := '通道 [ %s ] 关闭';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_ZTLineGroup, 'UFormStockMatch', nEvent);
  end;
  if   gCheckValid = true  then
  begin
       nEvent := '通道 [ %s ] 开启';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_ZTLineGroup, 'UFormStockMatch',nEvent);
  end;
  //--写入操作通道日志
  ShowMsg('通道已保存,请等待刷新', sHint);
end;

destructor TfFormStockMatch.Destroy;
begin
  FStocknoList.Free;
  inherited;
end;

constructor TfFormStockMatch.Create(AOwner: TComponent);
begin
  inherited;
  Fstocknolist := TStringList.Create;
end;

function TfFormStockMatch.getStocknos: string;
var
  i:Integer;
  nItem:TcxCheckComboBoxItem;
  nno:TStrings;
begin
  Result := '';
  nno := TStringList.Create;
  try
    for i := 0 to chkcbbStockname.Properties.Items.Count-1 do
    begin
      nItem := chkcbbStockname.Properties.Items[i];
      if chkcbbStockname.States[i]=cbsChecked then
      begin
        nno.Add(FStocknoList.Strings[i]);
      end;
    end;
    Result := nno.CommaText;
  finally
    nno.Free;
  end;
end;

procedure TfFormStockMatch.chkcbbStocknamePropertiesChange(Sender: TObject);
begin
  inherited;
  editStockno.Text := getStocknos;
  editStockname.Text := chkcbbStockname.Text;
end;

procedure TfFormStockMatch.setStocknos(const nstrs: string);
var
  i:Integer;
  nItem:TcxCheckComboBoxItem;
  nno:TStrings;
  nTmp,nSelNo:string;
begin
  nno := TStringList.Create;
  try
    nno.CommaText := nstrs;
    for i := 0 to chkcbbStockname.Properties.Items.Count-1 do
    begin
      nItem := chkcbbStockname.Properties.Items[i];
      nTmp := FStocknoList.Strings[i];
      if nno.IndexOf(nTmp)<>-1 then
      begin
        if Pos(nTmp,nItem.Description)>0 then
        begin
          chkcbbStockname.States[i] := cbsChecked;
        end;
      end;
    end;
  finally
    nno.Free;
  end;
end;

procedure TfFormStockMatch.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled := False;
  dxLayout1Item5.Visible := False;
  dxLayout1Item6.Visible := False;
end;

initialization
  gControlManager.RegCtrl(TfFormStockMatch, TfFormStockMatch.FormID);
end.
