unit UFormPWuCha;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit;

type
  TfFormPWuCha = class(TfFormNormal)
    EditStart: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditZValue: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditFValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecordID:string;
    //记录编号
    procedure LoadFormData(const nID: string);
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
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UAdjustForm, USysDB, USysConst,
  UDataModule;

class function TfFormPWuCha.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormPWuCha.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '误差参数 - 添加';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '误差参数 - 修改';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPWuCha.FormID: integer;
begin
  Result := cFI_FormPoundWc;
end;

procedure TfFormPWuCha.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where ID=%s';
    nStr := Format(nStr, [sTable_PoundWucha, nID]);
    with FDM.QueryTemp(nStr) do
    if RecordCount>0 then
    begin
      EditStart.Text := FieldByName('W_StartValue').AsString;
      EditEnd.Text := FieldByName('W_EndValue').AsString;
      EditZValue.Text := FieldByName('W_ZValue').AsString;
      EditFValue.Text := FieldByName('W_FValue').AsString;
    end;
  end;
end;

procedure TfFormPWuCha.BtnOKClick(Sender: TObject);
var nList: TStrings;
    nStr,nSQL,nRecord: string;
begin
  EditStart.Text := Trim(EditStart.Text);
  if not IsNumber(EditStart.Text,True) then
  begin
    EditStart.SetFocus;
    ShowMsg('请填写有效的开始吨位', sHint); Exit;
  end;
  EditEnd.Text := Trim(EditEnd.Text);
  if not IsNumber(EditEnd.Text,True) then
  begin
    EditEnd.SetFocus;
    ShowMsg('请填写有效的结束吨位', sHint); Exit;
  end;
  EditZValue.Text := Trim(EditZValue.Text);
  if not IsNumber(EditZValue.Text,True) then
  begin
    EditZValue.SetFocus;
    ShowMsg('请填写有效的正误差值', sHint); Exit;
  end;
  EditFValue.Text := Trim(EditFValue.Text);
  if not IsNumber(EditFValue.Text,True) then
  begin
    EditFValue.SetFocus;
    ShowMsg('请填写有效的负误差值', sHint); Exit;
  end;

  if StrToFloat(EditStart.Text)>=StrToFloat(EditEnd.Text) then
  begin
    EditStart.SetFocus;
    ShowMsg('请填写有效的开始吨位和结束吨位', sHint); Exit;
  end;

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('W_StartValue', EditStart.Text),
          SF('W_EndValue', EditEnd.Text),
          SF('W_ZValue', EditZValue.Text),
          SF('W_FValue', EditFValue.Text),
          SF('W_Date', sField_SQLServer_Now, sfVal)
          ], sTable_PoundWucha, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPWuCha, TfFormPWuCha.FormID);

end.
