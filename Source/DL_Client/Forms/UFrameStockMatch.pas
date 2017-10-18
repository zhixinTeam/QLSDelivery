{*******************************************************************************
  作者: lih 2017-10-16
  描述: 多品种共用道设置
*******************************************************************************}
unit UFrameStockMatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin;

type
  TfFrameStockMatch = class(TfFrameNormal)
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker, UFormStockMatch;

class function TfFrameStockMatch.FrameID: integer;
begin
  Result := cFI_FrameStockMatch;
end;

function TfFrameStockMatch.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_StockMatch;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID';
end;

procedure TfFrameStockMatch.BtnAddClick(Sender: TObject);
begin
  if ShowAddStockMatchForm then InitFormData();
end;

procedure TfFrameStockMatch.BtnEditClick(Sender: TObject);
var nFID: string;
begin
  if SQLQuery.RecordCount < 1 then
  begin
    ShowMsg('请选择需要修改的记录',sHint);
    Exit;
  end;
  nFID := SQLQuery.FieldByName('R_ID').AsString;
  if ShowEditStockMatchForm(nFID) then InitFormData();
end;

procedure TfFrameStockMatch.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('M_Name').AsString;
    nStr := Format('确定要删除验收通道[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StockMatch, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameStockMatch, TfFrameStockMatch.FrameID);

end.
 