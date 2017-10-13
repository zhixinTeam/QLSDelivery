{*******************************************************************************
  作者: lih 2017-5-3
  描述: 验收通道配置
*******************************************************************************}
unit UFrameYSLines;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters,Menus,
  dxLayoutcxEditAdapters;

type
  TfFrameYSLines = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
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
  UBusinessPacker, UFormYSLine;

class function TfFrameYSLines.FrameID: integer;
begin
  Result := cFI_FrameYSLines;
end;

function TfFrameYSLines.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_YSLines;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID';
end;

//Desc: 添加
procedure TfFrameYSLines.BtnAddClick(Sender: TObject);
begin
  if ShowAddYSLineForm then InitFormData();
end;

//Desc: 修改
procedure TfFrameYSLines.BtnEditClick(Sender: TObject);
var nFID:string;
begin
  if SQLQuery.RecordCount < 1 then
  begin
    ShowMsg('请选择需要修改的记录',sHint);
    Exit;
  end;
  nFID := SQLQuery.FieldByName('R_ID').AsString;
  if ShowEditYSLineForm(nFID) then InitFormData();
end;

//Desc: 删除
procedure TfFrameYSLines.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('Y_Name').AsString;
    nStr := Format('确定要删除验收通道[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_YSLines, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameYSLines.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then
    begin
      InitFormData('');
      Exit;
    end;

    FWhere := Format('(Y_Stock Like ''%%%s%%'') or (Y_Stockno Like ''%%%s%%'')', [EditName.Text,EditName.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameYSLines, TfFrameYSLines.FrameID);
end.
