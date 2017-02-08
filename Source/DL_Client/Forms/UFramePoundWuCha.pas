{
   称重误差参数设置
}
unit UFramePoundWuCha;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit, Menus, StdCtrls, cxButtons;

type
  TfFramePoundWuCha = class(TfFrameNormal)
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

var
  fFramePoundWuCha: TfFramePoundWuCha;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, USysFun, USysConst, USysGrid, USysDB, UMgrControl, UFormBase,
  UFormPWuCha, UDataModule;

class function TfFramePoundWuCha.FrameID: integer;
begin
  Result := cFI_FramePoundWc;
end;

//Desc: 数据查询SQL
function TfFramePoundWuCha.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  Result := 'Select * From ' + sTable_PoundWucha;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By ID';
end;


procedure TfFramePoundWuCha.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormPoundWc, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFramePoundWuCha.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('ID').AsString;
    CreateBaseFormItem(cFI_FormPoundWc, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

procedure TfFramePoundWuCha.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('ID').AsString;
  if not QueryDlg('确定要删除编号为[ ' + nStr + ' ]的误差值吗', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Delete From %s Where ID=''%s''';
    nSQL := Format(nSQL, [sTable_PoundWucha, nStr]);
    FDM.ExecuteSQL(nSQL);
    FDM.ADOConn.CommitTrans;

    InitFormData(FWhere);
    ShowMsg('记录已成功删除', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('记录删除失败', sError);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePoundWuCha, TfFramePoundWuCha.FrameID);

end.
