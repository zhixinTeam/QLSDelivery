unit UFramePoundDevia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFramePoundDevia = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
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
  fFramePoundDevia: TfFramePoundDevia;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

class function TfFramePoundDevia.FrameID: integer;
begin
  Result := cFI_FramePoundDevia;
end;

procedure TfFramePoundDevia.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePoundDevia.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFramePoundDevia.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Devia ';
  //提货单

  if (nWhere = '') then
  begin
    Result := Result + 'Where (D_Date>=''$ST'' and D_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where (D_Date>=''$ST'' and D_Date <''$End'') and ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  Result := MacroValue(Result, [MI('$Devia', sTable_PoundDevia)]);
end;

procedure TfFramePoundDevia.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFramePoundDevia.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then Exit;

  FWhere := Format('D_Truck like ''%%%s%%''', [EditTruck.Text]);
  InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFramePoundDevia, TfFramePoundDevia.FrameID);

end.
