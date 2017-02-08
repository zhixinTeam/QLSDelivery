{*******************************************************************************
  作者: dmzn@163.com 2014-12-02
  描述: 微信发送日志
*******************************************************************************}
unit UFrameWeiXinSendlog;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameWXSendlog = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
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
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, USysBusiness,
  USysConst, USysDB;

class function TfFrameWXSendlog.FrameID: integer;
begin
  Result := cFI_FrameWXSendLog;
end;

//Desc: 数据查询SQL
function TfFrameWXSendlog.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_WeixinLog;

  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 修改
procedure TfFrameWXSendlog.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('R_ID').AsString;
  CreateBaseFormItem(cFI_FormWXSendlog, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFrameWXSendlog.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  if QueryDlg('确定要删除编号为[ ' + nStr + ' ]的记录吗?', sAsk) then
  begin
    nSQL := 'Delete From %s Where R_ID=%s';
    nSQL := Format(nSQL, [sTable_WeixinLog, nStr]);

    FDM.ExecuteSQL(nSQL);
    InitFormData(FWhere);
    ShowMsg('删除成功', sHint);
  end;
end;

//Desc: 查看日志
procedure TfFrameWXSendlog.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormWXSendlog, PopedomItem, @nParam);
  end;
end;

//Desc: 执行查询
procedure TfFrameWXSendlog.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'L_UserID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameWXSendlog, TfFrameWXSendlog.FrameID);
end.
