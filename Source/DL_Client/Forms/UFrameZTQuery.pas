unit UFrameZTQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit, Menus;

type
  TfFrameZTQuery = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    pm1: TPopupMenu;
    N1: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure N1Click(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
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
  fFrameZTQuery: TfFrameZTQuery;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

class function TfFrameZTQuery.FrameID: integer;
begin
  Result := cFI_FrameZhanTaiQuery;
end;

procedure TfFrameZTQuery.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameZTQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameZTQuery.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Bill ';
  //提货单

  if (nWhere = '') then
  begin
    Result := Result + 'Where ((L_HYDan<>'''') and (L_HYDan is not null)) and (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ((L_HYDan<>'''') and (L_HYDan is not null)) and ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameZTQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameZTQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then Exit;

  FWhere := Format('L_Truck like ''%%%s%%''', [EditTruck.Text]);
  InitFormData(FWhere);
end;

procedure TfFrameZTQuery.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('L_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameZTQuery.N1Click(Sender: TObject);
var nStr:string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintDaiBill(nStr, False);
  end;
end;

procedure TfFrameZTQuery.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_EditData;
  CreateBaseFormItem(cFI_FormWorkSet, '', @nP);
end;

initialization
  gControlManager.RegCtrl(TfFrameZTQuery, TfFrameZTQuery.FrameID);

end.
