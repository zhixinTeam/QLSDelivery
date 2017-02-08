{*******************************************************************************
  作者: dmzn@163.com 2010-01-24
  描述: 销售扎账
*******************************************************************************}
unit UFrameInvoiceZZ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxDropDownEdit, Menus;

type
  TfFrameInvoiceZZ = class(TfFrameNormal)
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditWeek: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCusPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnEditClick(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FNowYear,FNowWeek,FWeekName: string;
    //当前周期
    procedure OnCreateFrame; override;
    {*基类函数*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
    procedure LoadDefaultWeek;
    //默认周期
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormDateFilter,
  UFormBase, USysBusiness;

class function TfFrameInvoiceZZ.FrameID: integer;
begin
  Result := cFI_FrameSaleZZ;
end;

procedure TfFrameInvoiceZZ.OnCreateFrame;
begin
  inherited;
  LoadDefaultWeek;
end;

//------------------------------------------------------------------------------
//Desc: 数据查询SQL
function TfFrameInvoiceZZ.InitFormDataSQL(const nWhere: string): string;
var nInt: Integer;
    nStr,nWeek: string;
begin
  if (FNowYear = '') and (FNowWeek = '') then
  begin
    Result := '';
    EditWeek.Text := '请选择结算周期'; Exit;
  end else
  begin
    nStr := '年份:[ %s ] 周期:[ %s ]';
    EditWeek.Text := Format(nStr, [FNowYear, FWeekName]);

    if FNowWeek = '' then
    begin
      nWeek := 'Where (W_Begin>=''$S'' and ' +
               'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
               'Order By W_Begin';
      nInt := StrToInt(FNowYear);
      
      nWeek := MacroValue(nWeek, [MI('$W', sTable_InvoiceWeek),
              MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1))]);
      //xxxxx
    end else
    begin
      nWeek := Format('Where R_Week=''%s''', [FNowWeek]);
    end;
  end;

  Result := 'Select req.*,(R_ReqValue-R_KValue) as R_Need,W_Name From $Req req ' +
            ' Left Join $Week On W_NO=req.R_Week ';
  //xxxxx
  
  if nWhere = '' then
       Result := Result + nWeek
  else Result := Result + 'Where ( ' + nWhere + ' )';

  Result := MacroValue(Result, [MI('$Req', sTable_InvoiceReq),
            MI('$Week', sTable_InvoiceWeek)]);
  //xxxxx
end;

//Desc: 载入默认周期
procedure TfFrameInvoiceZZ.LoadDefaultWeek;
var nP: TFormCommandParam;
begin
  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  nP.FCommand := cCmd_GetData;
  
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  nP.FParamE := sFlag_Yes;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if nP.FCommand = cCmd_ModalResult then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;
end;

procedure TfFrameInvoiceZZ.EditWeekPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_GetData;
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
    InitFormData(FWhere);
  end;
end;

//Desc: 扎账(全部)
procedure TfFrameInvoiceZZ.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleZZALL, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 按客户扎账
procedure TfFrameInvoiceZZ.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleZZCus, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除申请记录
procedure TfFrameInvoiceZZ.BtnDelClick(Sender: TObject);
var nStr: string;
    nVal: Double;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  nStr := Format('确定要删除编号为[ %s ]的记录吗?', [nStr]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nVal := SQLQuery.FieldByName('R_KValue').AsFloat;
  if nVal > 0 then
  begin
    nStr := Format('该记录已开发票[ %.2f ]吨,禁止删除!', [nVal]);
    ShowDlg(nStr, sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('R_Week').AsString;
  if not IsWeekValid(nStr, nStr) then
  begin
    ShowDlg(nStr, sHint); Exit;
  end;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('R_ID').AsString;
    nStr := Format('Delete From %s Where R_ID=%s', [sTable_InvoiceReq, nStr]);
    FDM.ExecuteSQL(nStr);

    with SQLQuery do
    begin
      nStr := Format('删除扎账记录,编号:%s 客户:%s 品种:%s 待开:%.2f吨', [
              FieldByName('R_ID').AsString, FieldByName('R_Customer').AsString,
              FieldByName('R_Stock').AsString, FieldByName('R_ReqValue').AsFloat]);
      FDM.WriteSysLog(sFlag_CommonItem, FieldByName('R_CusID').AsString, nStr, False);
    end;

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('记录删除失败', sHint); Exit;
  end;

  InitFormData(FWhere);
  ShowMsg('记录已删除', sHint);
end;

//Desc: 查询
procedure TfFrameInvoiceZZ.EditCusPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'R_CusID Like ''%%%s%%'' Or R_Customer Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameInvoiceZZ.PMenu1Popup(Sender: TObject);
begin
  N1.Enabled := BtnEdit.Enabled;
end;

//Desc: 修改开票价格&开票量
procedure TfFrameInvoiceZZ.N1Click(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;

  nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
  nP.FParamB := SQLQuery.FieldByName('R_Week').AsString;
  nP.FParamC := SQLQuery.FieldByName('R_KPrice').AsFloat;
  nP.FParamD := SQLQuery.FieldByName('R_ReqValue').AsFloat;

  nP.FParamE := SQLQuery.FieldByName('R_Value').AsFloat -
                SQLQuery.FieldByName('R_PreHasK').AsFloat -
                SQLQuery.FieldByName('R_KOther').AsFloat;
  nP.FParamE := Float2Float(nP.FParamE, cPrecision, False);
  //limite value

  nP.FCommand := cCmd_EditData;
  CreateBaseFormItem(cFI_FormInvAdjust, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameInvoiceZZ, TfFrameInvoiceZZ.FrameID);
end.
