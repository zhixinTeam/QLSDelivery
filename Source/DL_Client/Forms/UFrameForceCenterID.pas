{*******************************************************************************
  作者: juner11212436@163.com 2017-10-20
  描述: 强制生产线
*******************************************************************************}
unit UFrameForceCenterID;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus;

type
  TfFrameForceCenterID = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
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
  ULibFun, UMgrControl, USysBusiness, USysConst, USysDB, UDataModule, UFormBase,
  uFormForceCenterID;

class function TfFrameForceCenterID.FrameID: integer;
begin
  Result := cFI_FrameForceCenterID;
end;

function TfFrameForceCenterID.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_ForceCenterID;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By R_ID';
end;

//Desc: 添加
procedure TfFrameForceCenterID.BtnAddClick(Sender: TObject);
begin
  if ShowAddForceCenterIDForm then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameForceCenterID.BtnEditClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('R_ID').AsString;

    if ShowEditForceCenterIDForm(nStr) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameForceCenterID.BtnDelClick(Sender: TObject);
var nStr,nID,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('F_ID').AsString;
    nStr   := Format('确定要删除客户[ %s ]的强制生产线吗?', [nID]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_ForceCenterID, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除客户[ %s ]强制生产线信息.';
    nEvent := Format(nEvent, [nID]);
    FDM.WriteSysLog(sFlag_CommonItem, nID, nEvent);

    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameForceCenterID.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('F_ID Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameForceCenterID, TfFrameForceCenterID.FrameID);
end.
