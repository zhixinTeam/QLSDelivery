{*******************************************************************************
  作者: lih 2017-5-3
  描述: 验收通道配置
*******************************************************************************}
unit UFormYSLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls,
  dxLayoutcxEditAdapters;

type
  TfFormYSLine = class(TfFormNormal)
    EditID: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditStockID: TcxComboBox;
    dxLayout1Item21: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockIDPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //标识
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
  end;

function ShowAddYSLineForm: Boolean;
function ShowEditYSLineForm(const nID: string): Boolean;
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

function ShowAddYSLineForm: Boolean;
begin
  with TfFormYSLine.Create(Application) do
  try
    FID := '';
    Caption := '验收通道 - 添加';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditYSLineForm(const nID: string): Boolean;
begin
  with TfFormYSLine.Create(Application) do
  try
    FID := nID;
    Caption := '验收通道 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormYSLine.FormID: integer;
begin
  Result := cFI_FormYSLine;
end;

class function TfFormYSLine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormYSLine.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  ResetHintAllForm(Self, 'T', sTable_YSLines);
  //重置表名称

  if nID <> '' then
  begin
    EditID.Properties.ReadOnly := True;
    nStr := 'Select * From %s Where R_ID=''%s''';
    nStr := Format(nStr, [sTable_YSLines, nID]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      EditStockID.Text := FDM.SqlTemp.FieldByName('Z_StockNo').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);
    end;
  end;

  nStr := 'Select M_ID, M_Name From %s ';
  nStr := Format(nStr, [sTable_Materails]);

  EditStockID.Properties.Items.Clear;
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
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditStockID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;

function TfFormYSLine.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;
  
  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end;
end;

procedure TfFormYSLine.GetData(Sender: TObject; var nData: string);
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

function TfFormYSLine.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
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
  end else

  if Sender = EditStockID then
  begin
    Result := EditStockID.ItemIndex >= 0;
    nHint := '请选择品种';
  end;
end;

procedure TfFormYSLine.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    nStr,nEvent: string;
begin
  if not IsDataValid then Exit;

  nList := TStringList.Create;
  try
    nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
    nList.Add(Format('Z_StockNo=''%s''', [gStockItems[nIdx].FID]));

    //ext fields

    if FID = '' then
    begin
      nStr := MakeSQLByForm(Self, sTable_YSLines, '', True, GetData, nList);
    end else
    begin
      nStr := Format('R_ID=''%s''', [FID]);
      nStr := MakeSQLByForm(Self, sTable_YSLines, nStr, False, GetData, nList);
    end;
  finally
    nList.Free;
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  //--------------
  if   gCheckValid = false then
  begin
       nEvent := '通道 [ %s ] 关闭';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromYSline', nEvent);
  end;
  if   gCheckValid = true  then
  begin
       nEvent := '通道 [ %s ] 开启';
       nEvent := Format(nEvent, [EditID.Text]);
       FDM.WriteSysLog(sFlag_TruckQueue, 'UFromYSline',nEvent);
  end;
  //--写入操作通道日志
  ShowMsg('通道已保存,请等待刷新', sHint);
end;

procedure TfFormYSLine.EditStockIDPropertiesChange(Sender: TObject);
var nIdx,i: Integer;
begin
  if (not EditStockID.Focused) or (EditStockID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
  EditStockName.Text := gStockItems[nIdx].FName;
end;

initialization
  gControlManager.RegCtrl(TfFormYSLine, TfFormYSLine.FormID);
end.
