{*******************************************************************************
  作者: juner11212436@163.com 2017-10-20
  描述: 装车线管理
*******************************************************************************}
unit UFormForceCenterID;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxLabel, cxCheckBox, cxTextEdit, dxLayoutControl, StdCtrls,
  dxLayoutcxEditAdapters;

type
  TfFormForceCenterID = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditStockID: TcxComboBox;
    dxLayout1Item21: TdxLayoutItem;
    cbxCenterID: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditID: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    cbxCusGroup: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockIDPropertiesChange(Sender: TObject);
    procedure cbxCenterIDPropertiesChange(Sender: TObject);
    procedure EditIDPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FID: string;
    //标识
    procedure InitFormData(const nID: string);
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据处理
    function IsRepeat(const nCusID, nStockNo: string) : Boolean;
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

function ShowAddForceCenterIDForm: Boolean;
function ShowEditForceCenterIDForm(const nID: string): Boolean;
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
    FGroup: string;
  end;
  TCenterItem = record
    FGroup: string;
    FID   : string;
    FName : string;
  end;
  TCusItem = record
    FID   : string;
    FName : string;
  end;

var
  gStockItems: array of TLineStockItem;
  //品种列表
   gCheckValid: boolean;
  //通道钩选属性
  gCenterItem: array of TCenterItem;
  //生产线列表
  gCusItem: array of TCusItem;
  //客户列表

function ShowAddForceCenterIDForm: Boolean;
begin
  with TfFormForceCenterID.Create(Application) do
  try
    FID := '';
    Caption := '生产线关联 - 添加';

    InitFormData('');
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function ShowEditForceCenterIDForm(const nID: string): Boolean;
begin
  with TfFormForceCenterID.Create(Application) do
  try
    FID := nID;
    Caption := '生产线关联 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

class function TfFormForceCenterID.FormID: integer;
begin
  Result := cFI_FormForceCenterID;
end;

class function TfFormForceCenterID.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
end;

//------------------------------------------------------------------------------
procedure TfFormForceCenterID.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  ResetHintAllForm(Self, 'F', sTable_ForceCenterID);
  //重置表名称
  if nID <> '' then
  begin
    nIdx := StrToIntDef(nID,0);
    EditID.Properties.ReadOnly := True;
    nStr := 'Select * From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_ForceCenterID, nIdx]);

    if FDM.QueryTemp(nStr).RecordCount > 0 then
    begin
      EditID.Text:= FDM.SqlTemp.FieldByName('F_ID').AsString;
      EditName.Text:= FDM.SqlTemp.FieldByName('F_Name').AsString;
      EditStockID.Text := FDM.SqlTemp.FieldByName('F_StockNo').AsString;
      EditStock.Text := FDM.SqlTemp.FieldByName('F_Stock').AsString;
      cbxCenterID.Text := FDM.SqlTemp.FieldByName('F_CenterID').AsString;
      cbxCusGroup.Text := FDM.SqlTemp.FieldByName('F_CusGroup').AsString;
      LoadDataToCtrl(FDM.SqlTemp, Self, '', SetData);
    end;
  end;

  nStr := 'Select D_Value,D_ParamB+D_Memo as D_ParamB,D_Desc From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  EditStockID.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    try
      EditStockID.Properties.BeginUpdate;
      while not Eof do
      begin
        with gStockItems[nIdx] do
        begin
          FID := Fields[1].AsString;
          FName := Fields[0].AsString;
          FGroup := Fields[2].AsString;
          EditStockID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
        end;
        Inc(nIdx);
        Next;
      end;
    finally
      EditStockID.Properties.EndUpdate();
    end;
  end;

  nStr := 'select a.G_ItemGroupID,a.G_InventCenterID,b.I_Name from %s a,%s b '+  //生产线列表
          'where a.G_InventCenterID=b.I_CenterID ';
  nStr := Format(nStr, [sTable_InvCenGroup,sTable_InventCenter]);
  SetLength(gCenterItem, 0);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gCenterItem, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gCenterItem[nIdx] do
      begin
        FGroup:= Fields[0].AsString;
        FID := Fields[1].AsString;
        FName := Fields[2].AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select C_ID, C_Name From %s '; //客户列表
  nStr := Format(nStr, [sTable_Customer]);

  EditID.Properties.Items.Clear;
  SetLength(gCusItem, 0);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gCusItem, RecordCount);

    nIdx := 0;
    First;

    try
      EditID.Properties.BeginUpdate;
      while not Eof do
      begin
        with gCusItem[nIdx] do
        begin
          FID := Fields[0].AsString;
          FName := Fields[1].AsString;
          EditID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
        end;
        Inc(nIdx);
        Next;
      end;
    finally
      EditID.Properties.EndUpdate();
    end;
  end;

  nStr := 'Select distinct(F_CusGroup) From %s '; //获取已存在用户组
  nStr := Format(nStr, [sTable_ForceCenterID]);

  cbxCusGroup.Properties.Items.Clear;

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    First;

    while not Eof do
    begin
      cbxCusGroup.Properties.Items.Add(Fields[0].AsString);
      Next;
    end;
  end;
end;

procedure TfFormForceCenterID.EditStockIDPropertiesChange(Sender: TObject);
var nIdx,i: Integer;
begin
  if (not EditStockID.Focused) or (EditStockID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
  EditStock.Text := gStockItems[nIdx].FName;
  cbxCenterID.Properties.Items.Clear;
  for i:= Low(gCenterItem) to High(gCenterItem) do
  begin
    if gStockItems[nIdx].FGroup=gCenterItem[i].FGroup then
      cbxCenterID.Properties.Items.AddObject(gCenterItem[i].FID + '.' + gCenterItem[i].FName, Pointer(nIdx));
  end;
end;

function TfFormForceCenterID.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;

  if Sender = CheckValid then
  begin
    Result := True;
    CheckValid.Checked := nData <> sFlag_No;
  end;
end;

procedure TfFormForceCenterID.GetData(Sender: TObject; var nData: string);
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

function TfFormForceCenterID.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Integer;
begin
  Result := True;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    Result := EditID.Text <> '';
    nHint := '请选择客户编号';
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
  end else

  if Sender= cbxCenterID then
  begin
    cbxCenterID.Text:=Trim(cbxCenterID.Text);
    Result:=cbxCenterID.Text<>'';
    nHint:= '请选择生产线';
  end;

end;

procedure TfFormForceCenterID.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    nStr, nCusID, nStockNo: string;
begin
  if not IsDataValid then Exit;

  nIdx := Integer(EditID.Properties.Items.Objects[EditID.ItemIndex]);
  nCusID := gCusItem[nIdx].FID;

  nIdx := Integer(EditStockID.Properties.Items.Objects[EditStockID.ItemIndex]);
  nStockNo := gStockItems[nIdx].FID;

  if FID = '' then
  if IsRepeat(nCusID, nStockNo) then
  begin
    ShowMsg('该条记录已存在', sHint);
    Exit;
  end;

  nList := TStringList.Create;
  try
    nList.Add(Format('F_ID=''%s''', [nCusID]));

    nList.Add(Format('F_StockNo=''%s''', [nStockNo]));

    for nIdx:= Low(gCenterItem) to High(gCenterItem) do
    begin
      if gCenterItem[nIdx].FID+'.'+gCenterItem[nIdx].FName=Trim(cbxCenterID.Text) then
      begin
        nList.Add(Format('F_CenterID=''%s''', [gCenterItem[nIdx].FID]));
        Break;
      end;
    end;

    nList.Add(Format('F_CusGroup=''%s''', [cbxCusGroup.Text]));

    if FID = '' then
    begin
      nStr := MakeSQLByForm(Self, sTable_ForceCenterID, '', True, GetData, nList);
    end else
    begin
      nIdx := StrToInt(FID);
      nStr := Format('R_ID=%d', [nIdx]);
      nStr := MakeSQLByForm(Self, sTable_ForceCenterID, nStr, False, GetData, nList);
    end;
  finally
    nList.Free;
  end;

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;

  ShowMsg('数据保存成功', sHint);
end;

procedure TfFormForceCenterID.cbxCenterIDPropertiesChange(Sender: TObject);
var nIdx:Integer;
begin
  inherited;
  if (not cbxCenterID.Focused) or (cbxCenterID.ItemIndex < 0) then Exit;
  nIdx := Integer(cbxCenterID.Properties.Items.Objects[cbxCenterID.ItemIndex]);
  //cbxCenterID.Text:=gCenterItem[nIdx].FID;
end;

procedure TfFormForceCenterID.EditIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditID.Focused) or (EditID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditID.Properties.Items.Objects[EditID.ItemIndex]);
  EditName.Text := gCusItem[nIdx].FName;
end;

function TfFormForceCenterID.IsRepeat(const nCusID,
  nStockNo: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select F_ID From %s Where F_ID=''%s'' and F_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ForceCenterID, nCusID, nStockNo]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    Result := True;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormForceCenterID, TfFormForceCenterID.FormID);
end.
