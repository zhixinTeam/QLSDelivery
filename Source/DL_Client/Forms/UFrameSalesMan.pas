{*******************************************************************************
  作者: dmzn@163.com 2009-6-12
  描述: 业务员管理
*******************************************************************************}
unit UFrameSalesMan;

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
  TfFrameSalesMan = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
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
  ULibFun, UMgrControl, UFormBase, UFormWait, UDataModule, USysBusiness,
  USysConst, USysDB;

class function TfFrameSalesMan.FrameID: integer;
begin
  Result := cFI_FrameSalesMan;
end;

//Desc: 数据查询SQL
function TfFrameSalesMan.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From $SM';
  if nWhere = '' then
       Result := Result + ' Where S_InValid<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$SM', sTable_Salesman),
            MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: 关闭
procedure TfFrameSalesMan.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormSaleMan, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 添加
procedure TfFrameSalesMan.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleMan, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameSalesMan.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('S_ID').AsString;
  CreateBaseFormItem(cFI_FormSaleMan, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFrameSalesMan.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('S_ID').AsString;
  nSQL := 'Select Count(*) From %s Where C_SaleMan=''%s''';
  nSQL := Format(nSQL, [sTable_SaleContract, nStr]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该业务人员不能删除', '已签合同'); Exit;
  end;

  nStr := SQLQuery.FieldByName('S_Name').AsString;
  if not QueryDlg('确定要删除名称为[ ' + nStr + ' ]的业务员吗', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('S_ID').AsString;
    nSQL := 'Delete From %s Where S_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Salesman, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_SalesmanItem, nStr]); 
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

//Desc: 查看内容
procedure TfFrameSalesMan.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('S_ID').AsString;
    CreateBaseFormItem(cFI_FormSaleMan, PopedomItem, @nParam);
  end;
end;

//Desc: 执行查询
procedure TfFrameSalesMan.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'S_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'S_Name like ''%%%s%%'' Or S_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameSalesMan.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N3.Visible := True;
  N4.Visible := True;
  {$ELSE}
  N3.Visible := False;
  N4.Visible := False;
  {$ENDIF}
end;

//Desc: 快捷菜单
procedure TfFrameSalesMan.N2Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('S_InValid=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameSalesMan.N4Click(Sender: TObject);
begin
  ShowWaitForm(ParentForm, '正在同步,请稍后');
  try
    if SyncRemoteSaleMan then InitFormData(FWhere);
  finally
    CloseWaitForm;
  end; 
end;

initialization
  gControlManager.RegCtrl(TfFrameSalesMan, TfFrameSalesMan.FrameID);
end.
