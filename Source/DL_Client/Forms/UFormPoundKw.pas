unit UFormPoundKw;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, dxSkinsCore,
  dxSkinsDefaultPainters;

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
    EditMValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecordID:string;
    //记录编号
    FOrderID,FBillID,FStatus:string;
    //订单号，提货单号 ，车辆当前状态
    FHisPValue,FHisMValue:string;
    //历史皮重,历史毛重
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
      FOrderID := nP.FParamB;
      FBillID := nP.FParamC;
      if FOrderID = '' then
        dxLayout1Item5.Caption := '提货单号:'
      else
      dxLayout1Item5.Caption := '订单编号:'
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
    if FOrderID = '' then
    begin
      nStr := 'Select * From %s a,%s b Where a.P_Bill=b.L_ID and a.R_ID=%s';
      nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
    end
    else
    begin
      nStr := 'Select b.D_Status as L_Status, b.D_ID as L_ID, * From %s a,%s b Where a.P_Order=b.D_ID and a.R_ID=%s';
      nStr := Format(nStr, [sTable_PoundLog, sTable_OrderDtl, nID]);
    end;
    with FDM.QueryTemp(nStr) do
    if RecordCount>0 then
    begin
      if (FieldByName('L_Status').AsString = sFlag_TruckBFP) or
        (FieldByName('L_Status').AsString = sFlag_TruckFH) or
        (FieldByName('L_Status').AsString = sFlag_TruckZT) or
        (FieldByName('L_Status').AsString = sFlag_TruckBFM) or
        (FieldByName('L_Status').AsString = sFlag_TruckXH) then
      begin
        FStatus := FieldByName('L_Status').AsString;
        if FStatus = sFlag_TruckBFM then
          dxLayout1Item8.Visible := True
        else
          dxLayout1Item8.Visible := False;
        EditLID.Text := FieldByName('L_ID').AsString;
        EditPID.Text := FieldByName('P_ID').AsString;
        EditTruck.Text := FieldByName('P_Truck').AsString;
        FHisPValue:= FieldByName('P_PValue').AsString;
        EditPValue.Text:=FHisPValue;
        FHisMValue:= FieldByName('P_MValue').AsString;
        EditMValue.Text:=FHisMValue;
        BtnOK.Enabled:=True;
      end else
      begin
        BtnOK.Enabled:=False;
        ShowMsg('车辆当前状态不能进行勘误',sHint);
        Exit;
      end;
    end else
    begin
      ShowMsg('无相关数据',sHint);
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
  if FStatus = sFlag_TruckBFM then
  if not IsNumber(EditMValue.Text,True) then
  begin
    EditMValue.Focused;
    ShowMsg('毛重无效，请重新录入',sHint);
    Exit;
  end;
  if (FHisMValue=EditMValue.Text) and (FHisPValue=EditPValue.Text) then
  begin
    ShowMsg('无更新数据，勘误无效',sHint);
    Exit;
  end;
  try
    if FOrderID = '' then
    begin
      nStr := SF('L_ID', EditLID.Text);
      if FStatus = sFlag_TruckBFM then
      begin
        nStr := MakeSQLByStr([SF('L_MValue', EditMValue.Text),
                SF('L_PValue', EditPValue.Text)
                ], sTable_Bill, nStr, False);
        FDM.ExecuteSQL(nStr);

        nStr := 'Update %s set L_Value = L_MValue - L_PValue where L_ID=''%s'' and L_Type <> ''D''';
        nStr := Format(nStr, [sTable_Bill, EditLID.Text]);
        FDM.ExecuteSQL(nStr);
        //更新净重
      end
      else
      begin
        nStr := MakeSQLByStr([SF('L_PValue', EditPValue.Text)
                ], sTable_Bill, nStr, False);
        FDM.ExecuteSQL(nStr);
      end;

    end
    else
    begin
      nStr := SF('D_ID', EditLID.Text);
      if FStatus = sFlag_TruckBFM then
      begin
        nStr := MakeSQLByStr([SF('D_MValue', EditMValue.Text),
                SF('D_PValue', EditPValue.Text)
                ], sTable_OrderDtl, nStr, False);
        FDM.ExecuteSQL(nStr);

        nStr := 'Update %s set D_Value = D_MValue - D_PValue where D_ID=''%s'' ';
        nStr := Format(nStr, [sTable_OrderDtl, EditLID.Text]);
        FDM.ExecuteSQL(nStr);
        //更新净重
      end
      else
      begin
        nStr := MakeSQLByStr([SF('D_PValue', EditPValue.Text)
                ], sTable_OrderDtl, nStr, False);
        FDM.ExecuteSQL(nStr);
      end;

    end;
  except
    ShowMsg('勘误失败',sHint);
    Exit;
  end;
  try
    if FHisMValue = '' then
      FHisMValue := '0';
    if FHisPValue = '' then
      FHisPValue := '0';
    nStr := SF('R_ID', FRecordID, sfVal);
    if FStatus = sFlag_TruckBFM then
    begin
      nStr := MakeSQLByStr([SF('P_KwMan', gSysParam.FUserID),
              SF('P_PValue', EditPValue.Text),
              SF('P_MValue', EditMValue.Text),
              SF('P_HisMValue', FHisMValue),
              SF('P_HisPValue', FHisPValue),
              SF('P_KWDate', sField_SQLServer_Now, sfVal)
              ], sTable_PoundLog, nStr, False);
    end
    else
    begin
      nStr := MakeSQLByStr([SF('P_KwMan', gSysParam.FUserID),
              SF('P_PValue', EditPValue.Text),
              SF('P_HisPValue', FHisPValue),
              SF('P_KWDate', sField_SQLServer_Now, sfVal)
              ], sTable_PoundLog, nStr, False);
    end;
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
