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
    N2: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure N1Click(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
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
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FJBWhere := '';
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
  if FJBWhere = '' then
  begin
    if (nWhere = '') then
    begin
      Result := Result + 'Where ((L_HYDan<>'''') and (L_HYDan is not null)) ' +
                ' and (L_LadeTime>=''$ST'' and L_LadeTime <''$End'')';
      nStr := ' And ';
    end else nStr := ' Where ((L_HYDan<>'''') and (L_HYDan is not null)) and ';

    if nWhere <> '' then
      Result := Result + nStr + '(' + nWhere + ')';
    //xxxxx
  end
  else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

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

procedure TfFrameZTQuery.N2Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(L_LadeTime>=''%s'' and L_LadeTime <''%s'') and ((L_HYDan<>'''') and (L_HYDan is not null))';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameZTQuery, TfFrameZTQuery.FrameID);

end.
