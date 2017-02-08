{*******************************************************************************
作者: fendou116688@163.com 2016/2/26
描述: 短倒业务办理磁卡
*******************************************************************************}
unit UFormTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit;

type
  TfFormTransfer = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditMate: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditSrcAddr: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDstAddr: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditDC: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    EditDR: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    cbxSaleID: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure EditDCPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FRecID:Int64;
    procedure LoadMateInfo(const nSelected, nInfo: String);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  UMgrControl, UDataModule, UFormBase, UFormCtrl, USysDB, USysConst, UAdjustForm;

type
  TMateItem = record
    FID   : string;
    FName : string;
  end;

var
  gMateItems: array of TMateItem;
  //品种列表

class function TfFormTransfer.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormTransfer.Create(Application) do
  try
    EditTruck.Text  := nP.FParamA;
    EditSrcAddr.Text:= nP.FParamD;
    EditDstAddr.Text:= nP.FParamE;

    LoadMateInfo(nP.FParamB, nP.FParamC);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTransfer.FormID: integer;
begin
  Result := cFI_FormTransfer;
end;

procedure TfFormTransfer.BtnOKClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nP: TFormCommandParam;
begin
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);

  nP.FParamA := gMateItems[nIdx].FID;
  nP.FParamB := Trim(EditTruck.Text);
  nP.FParamC := sFlag_DuanDao;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  nStr := 'Update %s Set T_MatePID=T_MateID,T_MateID=''%s'',T_MateName=''%s'','+
          'T_SrcAddr=''%s'',T_DestAddr=''%s'' Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, gMateItems[nIdx].FID,
          gMateItems[nIdx].FName,Trim(EditSrcAddr.Text),Trim(EditDstAddr.Text),
          Trim(EditTruck.Text)]);
  //xxxxx
  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;
end;

procedure TfFormTransfer.LoadMateInfo(const nSelected, nInfo: String);
var nStr: string;
    nInt, nIdx: Integer;
begin
  nStr := 'B_ID=Select B_ID,B_StockName From %s a, %s b Where a.B_ID=b.M_ID and M_PurchType=''0'' ';
  nStr := Format(nStr, [sTable_OrderBase, sTable_OrderBaseMain]);

  FDM.FillStringsData(cbxSaleID.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(cbxSaleID, False);

  nStr := 'Select M_ID,M_Name From ' + sTable_Materails;

  EditMID.Properties.Items.Clear;
  SetLength(gMateItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gMateItems, RecordCount);

    nInt := 0;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with gMateItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditMID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));

        if CompareText(FID, nSelected) = 0 then nInt := nIdx;
      end;

      Inc(nIdx);
      Next;
    end;

    EditMID.ItemIndex := nInt;
    EditMate.Text := gMateItems[nInt].FName;
  end;

  {nStr := 'P_ID=Select P_ID,P_Name From %s Where P_Type=''%s'' Order By P_Name DESC';
  nStr := Format(nStr, [sTable_Provider, sFlag_ProvideD]);

  FDM.FillStringsData(EditDC.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDC, False);

  FDM.FillStringsData(EditDR.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDR, False);  }
end;  

procedure TfFormTransfer.EditMIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditMID.Focused) or (EditMID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
  EditMate.Text := gMateItems[nIdx].FName;
end;

procedure TfFormTransfer.EditDCPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditDC then
    EditSrcAddr.Text := nStr
  else if Sender = EditDR then
    EditDstAddr.Text := nStr;
  //xxxxx
end;

initialization
  gControlManager.RegCtrl(TfFormTransfer, TfFormTransfer.FormID);
end.
