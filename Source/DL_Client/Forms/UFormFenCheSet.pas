unit UFormFenCheSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit;

type
  TfFormFenCheSet = class(TfFormNormal)
    EditStart: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditLValue: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditRValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditLValuePropertiesChange(Sender: TObject);
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

class function TfFormFenCheSet.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormFenCheSet.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '分票打印参数 - 添加';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '分票打印参数 - 修改';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormFenCheSet.FormID: integer;
begin
  Result := cFI_FormFenCheSet;
end;

procedure TfFormFenCheSet.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where ID=%s';
    nStr := Format(nStr, [sTable_FenCheSet, nID]);
    with FDM.QueryTemp(nStr) do
    if RecordCount>0 then
    begin
      EditStart.Text := FieldByName('F_StartValue').AsString;
      EditEnd.Text := FieldByName('F_EndValue').AsString;
      EditLValue.Text := FieldByName('F_LPro').AsString;
      EditRValue.Text := FieldByName('F_RPro').AsString;
    end;
  end;
end;

procedure TfFormFenCheSet.BtnOKClick(Sender: TObject);
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
  EditLValue.Text := Trim(EditLValue.Text);
  if not IsNumber(EditLValue.Text,True) then
  begin
    EditLValue.SetFocus;
    ShowMsg('请填写有效的比例值', sHint); Exit;
  end;

  if StrToFloat(EditStart.Text)>=StrToFloat(EditEnd.Text) then
  begin
    EditStart.SetFocus;
    ShowMsg('请填写有效的开始吨位和结束吨位', sHint); Exit;
  end;

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('F_StartValue', EditStart.Text),
          SF('F_EndValue', EditEnd.Text),
          SF('F_LPro', EditLValue.Text),
          SF('F_RPro', EditRValue.Text),
          SF('F_Date', sField_SQLServer_Now, sfVal)
          ], sTable_FenCheSet, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('信息保存成功', sHint);
end;

procedure TfFormFenCheSet.EditLValuePropertiesChange(Sender: TObject);
var nInt: Integer;
begin
  if not IsNumber(EditLValue.Text,False) then
  begin
    EditLValue.Text := '';
    EditRValue.Text := '';
    EditLValue.SetFocus;
    ShowMsg('请填写有效的比例值(0-10)', sHint); Exit;
  end;
  nInt := StrToInt(EditLValue.Text);
  if (nInt < 0) or (nInt > 10) then
  begin
    EditLValue.Text := '';
    EditRValue.Text := '';
    EditLValue.SetFocus;
    ShowMsg('请填写有效的比例值(0-10)', sHint); Exit;
  end;
  EditRValue.Text := IntToStr(10 - nInt);
end;

initialization
  gControlManager.RegCtrl(TfFormFenCheSet, TfFormFenCheSet.FormID);

end.
