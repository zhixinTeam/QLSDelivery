unit UFormWorkSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, Grids, DBGrids, dxLayoutControl, StdCtrls, ADODB,
  DB, ExtCtrls, DBCtrls;

type
  TfFormWorkSet = class(TfFormNormal)
    DBGridWorkSet: TDBGrid;
    dxLayout1Item3: TdxLayoutItem;
    QryWorkSet: TADOQuery;
    DataSource1: TDataSource;
    DBNavigator1: TDBNavigator;
    dxLayout1Item4: TdxLayoutItem;
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormWorkSet: TfFormWorkSet;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, UBusinessConst, USysConst ,USysLoger, USmallFunc;

class function TfFormWorkSet.FormID: integer;
begin
  Result := cFI_FormWorkSet;
end;

class function TfFormWorkSet.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  with TfFormWorkSet.Create(Application) do
  try
    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '∞‡±…Ë÷√';
    end;
    QryWorkSet.Close;
    QryWorkSet.SQL.Text:='select * from '+sTable_ZTWorkSet;
    QryWorkSet.Open;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormWorkSet, TfFormWorkSet.FormID);

end.
