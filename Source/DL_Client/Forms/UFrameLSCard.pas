{
  临时卡办理
}
unit UFrameLSCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxMaskEdit, cxButtonEdit,
  cxTextEdit, Menus;

type
  TfFrameLSCard = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameLSCard: TfFrameLSCard;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UFormBase, UDataModule,
  UFormDateFilter, UFormLSCard;

class function TfFrameLSCard.FrameID: integer;
begin
  Result := cFI_FrameLSCard;
end;

procedure TfFrameLSCard.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameLSCard.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameLSCard.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $InFac ';
  //提货单

  if (nWhere = '') then
  begin
    Result := Result + 'Where (I_Date>=''$ST'' and I_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where (I_Date>=''$ST'' and I_Date <''$End'') and ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  Result := MacroValue(Result, [MI('$InFac', sTable_InOutFatory)]);
end;


procedure TfFrameLSCard.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameLSCard.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then Exit;

  FWhere := Format('I_Truck like ''%%%s%%''', [EditTruck.Text]);
  InitFormData(FWhere);
end;

procedure TfFrameLSCard.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('I_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameLSCard.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormLSCard, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameLSCard.N1Click(Sender: TObject);
var
  nID:Integer;
  nStr,nCard:string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('R_ID').AsInteger;
    nCard:=SQLQuery.FieldByName('I_Card').AsString;
    nStr := 'Update %s Set I_Card=''注''+I_Card Where I_Card=''%s'' ';
    nStr := Format(nStr, [sTable_InOutFatory, nCard]);
    FDM.ExecuteSQL(nStr);
    ShowMsg('注销卡号成功', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameLSCard, TfFrameLSCard.FrameID);

end.
 