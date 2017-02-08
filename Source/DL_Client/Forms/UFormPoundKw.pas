unit UFormPoundKw;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxLabel;

type
  TfFormPoundKw = class(TfFormNormal)
    cxLabel1: TcxLabel;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditLID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPID: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecordID:string;
    //记录编号
    FHisPValue,FHisTruck:string;
    //历史皮重,历史车号
    procedure LoadFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormPoundKw: TfFormPoundKw;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UAdjustForm, USysDB, USysConst,
  UDataModule;

class function TfFormPoundKw.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormPoundKw.Create(Application) do
  try
    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '称重查询 - 勘误';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPoundKw.FormID: integer;
begin
  Result := cFI_FormPoundKw;
end;

procedure TfFormPoundKw.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s a,%s b Where a.P_Bill=b.L_ID and a.R_ID=%s';
    nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
    with FDM.QueryTemp(nStr) do
    if RecordCount>0 then
    begin
      if (FieldByName('L_Status').AsString = sFlag_TruckBFP) or
        (FieldByName('L_Status').AsString = sFlag_TruckFH) or
        (FieldByName('L_Status').AsString = sFlag_TruckZT) then
      begin
        EditLID.Text := FieldByName('L_ID').AsString;
        EditPID.Text := FieldByName('P_ID').AsString;
        FHisTruck := FieldByName('P_Truck').AsString;
        EditTruck.Text :=FHisTruck;
        FHisPValue:= FieldByName('P_PValue').AsString;
        EditPValue.Text:=FHisPValue;
        BtnOK.Enabled:=True;
      end else
      begin
        BtnOK.Enabled:=False;
        ShowMsg('禁止勘误',sHint);
        Exit;
      end;
    end else
    begin
      ShowMsg('提货单无效',sHint);
      Exit;
    end;
  end;
end;

procedure TfFormPoundKw.BtnOKClick(Sender: TObject);
var
  nStr:string;
begin
  if FRecordID='' then
  begin
    ShowMsg('勘误失效',sHint);
    Exit;
  end;
  if not IsNumber(EditPValue.Text,True) then
  begin
    EditPValue.Focused;
    ShowMsg('皮重无效，请重新录入',sHint);
    Exit;
  end;
  if (FHisTruck=EditTruck.Text) and (FHisPValue=EditPValue.Text) then
  begin
    ShowMsg('无更新数据，勘误无效',sHint);
    Exit;
  end;
  try
    nStr := SF('L_ID', EditLID.Text);
    nStr := MakeSQLByStr([SF('L_Truck', EditTruck.Text),
            SF('L_PValue', EditPValue.Text)
            ], sTable_Bill, nStr, False);
    FDM.ExecuteSQL(nStr);
  except
    ShowMsg('勘误失败',sHint);
    Exit;
  end;
  try
    nStr := SF('R_ID', FRecordID, sfVal);
    nStr := MakeSQLByStr([SF('P_Truck', EditTruck.Text),
            SF('P_PValue', EditPValue.Text),
            SF('P_HisTruck', FHisTruck),
            SF('P_HisPValue', FHisPValue),
            SF('P_KWDate', sField_SQLServer_Now, sfVal)
            ], sTable_PoundLog, nStr, False);
    FDM.ExecuteSQL(nStr);
  except
    ShowMsg('勘误失败',sHint);
    Exit;
  end;

  ModalResult := mrOk;
  ShowMsg('勘误保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPoundKw, TfFormPoundKw.FormID);

end.
