{*******************************************************************************
  作者: dmzn@163.com 2015-01-22
  描述: 车辆档案管理
*******************************************************************************}
unit UFormDeduct;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxButtonEdit;

type
  TfFormDeduct = class(TfFormNormal)
    EditValue: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    CheckPercent: TcxCheckBox;
    EditStock: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCusPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FCusID: string;
    FStock: string;
    //客户物料
    FRecord: string;
    //记录编号
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormDeduct.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormDeduct.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '规则 - 添加';
      FRecord := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '规则 - 修改';
      FRecord := nP.FParamA;
    end;

    LoadFormData(FRecord); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormDeduct.FormID: integer;
begin
  Result := cFI_FormDeduct;
end;

procedure TfFormDeduct.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Deduct, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckPercent.Checked := True;
      CheckValid.Checked := True;
      Exit;
    end;

    FStock := FieldByName('D_Stock').AsString;
    EditStock.Text := FieldByName('D_Name').AsString;

    FCusID := FieldByName('D_CusID').AsString;
    EditCus.Text := FieldByName('D_CusName').AsString;
    EditValue.Text := FieldByName('D_Value').AsString;
    
    CheckValid.Checked := FieldByName('D_Valid').AsString = sFlag_Yes;
    CheckPercent.Checked := FieldByName('D_Type').AsString = sFlag_DeductPer;
  end;
end;

procedure TfFormDeduct.EditCusPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FParamA := '1';
  CreateBaseFormItem(cFI_FormGetNCStock, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FCusID := nP.FParamB;
    EditCus.Text := nP.FParamC;
  end;
end;

procedure TfFormDeduct.EditStockPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FParamA := '';
  CreateBaseFormItem(cFI_FormGetNCStock, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FStock := nP.FParamB;
    EditStock.Text := nP.FParamC;
  end;
end;

//Desc: 保存
procedure TfFormDeduct.BtnOKClick(Sender: TObject);
var nStr,nV,nP: string;
begin
  if FStock = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('请选择物料号', sHint);
    Exit;
  end;

  if (not IsNumber(EditValue.Text, True)) or
     (StrToFloat(EditValue.Text) < 0) then
  begin
    ActiveControl := EditValue;
    ShowMsg('请填写扣减量', sHint);
    Exit;
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if CheckPercent.Checked then
       nP := sFlag_DeductPer
  else nP := sFlag_DeductFix;

  if FRecord = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecord, sfVal);

  nStr := MakeSQLByStr([SF('D_Stock', FStock),
          SF('D_Name', EditStock.Text),
          SF('D_CusID', FCusID),
          SF('D_CusName', EditCus.Text),
          SF('D_Value', EditValue.Text, sfVal),
          SF('D_Type', nP),
          SF('D_Valid', nV)
          ], sTable_Deduct, nStr, FRecord = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('规则保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormDeduct, TfFormDeduct.FormID);
end.
