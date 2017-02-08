{*******************************************************************************
  作者: dmzn@163.com 2011-01-23
  描述: 对全部客户扎账
*******************************************************************************}
unit UFormInvoiceZZAll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup;

type
  TfFormInvoiceZZAll = class(TfFormNormal)
    dxLayout1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    EditWeek: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FLastInterval: Cardinal;
    //上次执行
    FNowYear,FNowWeek,FWeekName: string;
    //周期参数
    procedure InitFormData;
    //载入数据
    procedure ShowNowWeek;
    //显示周期
    procedure ShowHintText(const nText: string);
    //提示内容
    procedure ZZ_All(const nNeedCombine: Boolean);
    //扎账操作
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UFormBase, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness;

class function TfFormInvoiceZZAll.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_AddData then Exit;

  with TfFormInvoiceZZAll.Create(Application) do
  try
    Caption := '扎账(全部客户)';
    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormInvoiceZZAll.FormID: integer;
begin
  Result := cFI_FormSaleZZALL;
end;

procedure TfFormInvoiceZZAll.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormInvoiceZZAll.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceZZAll.ShowNowWeek;
begin
  if FNowWeek = '' then
       EditWeek.Text := '请选择结算周期'
  else EditWeek.Text := Format('%s 年份:[ %s ]', [FWeekName, FNowYear]);

  EditWeek.SelStart := 0;
  EditWeek.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TfFormInvoiceZZAll.InitFormData;
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

  ShowNowWeek;
end;

procedure TfFormInvoiceZZAll.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
  Application.ProcessMessages;

  if GetTickCount - FLastInterval < 500 then
    Sleep(375);
  FLastInterval := GetTickCount;
end;

procedure TfFormInvoiceZZAll.EditWeekPropertiesButtonClick(Sender: TObject;
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
  end;

  ShowNowWeek;
end;

//Desc: 开始扎账
procedure TfFormInvoiceZZAll.BtnOKClick(Sender: TObject);
var nStr: string;
    nInt: Integer;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('请选择有效的周期', sHint); Exit;
  end;

  if not IsWeekValid(FNowWeek, nStr) then
  begin
    EditWeek.SetFocus;
    ShowMsg(nStr, sHint); Exit;
  end;

  if IsNextWeekEnable(FNowWeek) then
  begin
    nStr := '本周期已结束,系统禁止再次扎账!';
    ShowDlg(nStr, sHint); Exit;
  end;

  nInt := IsPreWeekOver(FNowWeek);
  if nInt > 0 then
  begin
    nStr := Format('以前周期还有[ %d ]笔未结算完毕,请先处理!', [nInt]);
    ShowDlg(nStr, sHint); Exit;
  end;

  if IsWeekHasEnable(FNowWeek) then
  begin
    nStr := '该周期已扎账,再次扎账会覆盖上次的内容.' + #13#10 +
            '要继续吗?';
    if not QueryDlg(nStr, sAsk) then Exit;

    nInt := 10;
  end else nInt := 0;

  nStr := '该操作可能需要一段时间,请耐心等候.' + #13#10 +
          '要继续吗?';
  if not QueryDlg(nStr, sAsk) then Exit;

  BtnOK.Enabled := False;
  try
    EditMemo.Clear;          
    ZZ_All(nInt > 0);
  except
    on E:Exception do
    begin
      BtnOK.Enabled := True;
      ShowHintText(E.Message); Exit;
    end;
  end;

  FDM.ADOConn.BeginTrans;
  try
    if nInt > 0 then
    begin
      nStr := 'Delete From %s Where R_Week=''%s''';
      nStr := Format(nStr, [sTable_InvoiceReq, FNowWeek]);
      FDM.ExecuteSQL(nStr);
    end;

    nStr := 'Insert Into %s(R_Week,R_CusID,R_Customer,R_SaleID,R_SaleMan,' +
            'R_Type,R_Stock,R_Price,R_Value,R_PreHasK,R_ReqValue,R_KPrice,' +
            'R_KValue,R_KOther,R_Man,R_Date) ' +
            ' Select R_Week,R_CusID,R_Customer,R_SaleID,R_SaleMan,' +
            ' R_Type,R_Stock,R_Price,R_Value,R_PreHasK,R_ReqValue,R_KPrice,' +
            ' R_KValue,R_KOther,R_Man,R_Date From %s';
    //move into normal table

    nStr := Format(nStr, [sTable_InvoiceReq, sTable_InvReqtemp]);
    FDM.ExecuteSQL(nStr);

    nStr := '用户[ %s ]对周期[ %s ]执行扎账操作.';
    nStr := Format(nStr, [gSysParam.FUserID, FWeekName]);
    FDM.WriteSysLog(sFlag_CommonItem, FNowWeek, nStr, False);

    FDM.ADOConn.CommitTrans;      
    ModalResult := mrOk;
    ShowMsg('扎账操作完成', sHint);
  except
    on E:Exception do
    begin
      BtnOK.Enabled := True;
      FDM.ADOConn.RollbackTrans;
      ShowHintText(E.Message);
    end;
  end;
end;

//Desc: 执行扎账
procedure TfFormInvoiceZZAll.ZZ_All(const nNeedCombine: Boolean);
var nStr,nSQL: string;
begin
  nStr := 'Delete From ' + sTable_InvReqtemp;
  FDM.ExecuteSQL(nStr);
  //清空临时表

  nSQL := 'Select L_SaleID,L_CusID,L_Type,L_StockName,L_Price,' +
          'Sum(L_Value) as L_Value,L_SaleMan,L_CusName From $Bill ' +
          'Where L_OutFact Is Not Null ' +
          'Group By L_SaleID,L_SaleMan,L_CusID,L_CusName,L_Type,L_StockName,L_Price';
  nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill)]);
  //同客户同品种同单价合并

  nStr := 'Select ''$W'' As R_Week,''$Man'' As R_Man,$Now As R_Date,' +
          'b.* From ($Bill) b ';
  nSQL := MacroValue(nStr, [MI('$W', FNowWeek), MI('$Bill', nSQL),
           MI('$Man', gSysParam.FUserID), MI('$Now', FDM.SQLServerNow)]);
  //合并有效内容

  nStr := 'Insert Into %s(R_Week,R_Man,R_Date,R_SaleID,R_CusID,' +
          'R_Type,R_Stock,R_Price,R_Value,R_SaleMan,R_Customer) Select * From (%s) t';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('开始计算客户总提货量...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('客户总提货量计算完毕!');

  //----------------------------------------------------------------------------
  nSQL := 'Select I_CusID,I_SaleID,D_Type,D_Stock,D_Price,' +
          'Sum(D_Value) As D_Value From (Select * From $Dtl ' +
          '  Left Join $Inv On I_ID=D_Invoice ' +
          'Where I_Status=''$Use'' And I_Week<>''$W''' +
          ') inv Group By I_CusID,I_SaleID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed)]);
  //非本周期的所有发票

  nStr := 'Update %s Set R_PreHasK=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And I_SaleID=R_SaleID And D_Type=R_Type And ' +
          'D_Stock=R_Stock And D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('开始计算客户本周期之前总开票量...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('客户本周期之前总开票量计算完毕!');

  //----------------------------------------------------------------------------
  {+2011.02.15: 暂时未使用非申请
  nSQL := 'Select I_CusID,D_Type,D_Stock,D_Price,Sum(D_Value) As D_Value From' +
          '( Select * From $Dtl Left Join $Inv On I_ID=D_Invoice ' +
          '  Where I_Status=''$Use'' And I_Week=''$W'' And ' +
          '  IsNull(I_Flag,'''')<>''$Req''' +
          ') inv Group By I_CusID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed),
          MI('$Req', sFlag_InvRequst)]);
  //本周期的非申请所开

  nStr := 'Update %s Set R_KOther=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And D_Type=R_Type And D_Stock=R_Stock And ' +
          'D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('开始计算客户本周期非申请已开票量...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('客户本周期非申请已开票量计算完毕!');
  }
  //----------------------------------------------------------------------------
  nSQL := 'Select I_CusID,I_SaleID,D_Type,D_Stock,D_Price,Sum(D_Value) As D_Value From' +
          '( Select * From $Dtl Left Join $Inv On I_ID=D_Invoice ' +
          '  Where I_Status=''$Use'' And I_Week=''$W'' And I_Flag=''$Req''' +
          ') inv Group By I_CusID,I_SaleID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed),
          MI('$Req', sFlag_InvRequst)]);
  //本周期的申请所开

  nStr := 'Update %s Set R_KValue=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And I_SaleID=R_SaleID And D_Type=R_Type And ' +
          'D_Stock=R_Stock And D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('开始计算客户本周期申请已开票量...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('客户本周期申请已开票量计算完毕!');

  //----------------------------------------------------------------------------
  if nNeedCombine then
  begin
    nSQL := 'Update $T Set $T.R_KPrice=$R.R_KPrice,$T.R_ReqValue=$R.R_ReqValue ' +
            'From $R Where $R.R_Week=''$W'' And $T.R_CusID=$R.R_CusID And ' +
            '$T.R_SaleID=$R.R_SaleID And $T.R_Type=$R.R_Type And ' +
            '$T.R_Stock=$R.R_Stock And $T.R_Price=$R.R_Price';
    nStr := MacroValue(nSQL, [MI('$T', sTable_InvReqtemp),
            MI('$R', sTable_InvoiceReq), MI('$W', FNowWeek)]);
    //xxxxx

    ShowHintText('开始合并上次扎账数据...');
    FDM.ExecuteSQL(nStr);
    ShowHintText('合并上次扎账数据完毕!');
  end;

  nSQL := 'Update %s Set R_KPrice=R_Price,R_ReqValue=R_Value-' +
          'IsNull(R_PreHasK,0)-IsNull(R_KOther,0) ' +
          'Where IsNull(R_KPrice,0)=0 Or IsNull(R_ReqValue,0)=0';
  nStr := Format(nSQL, [sTable_InvReqtemp]);

  ShowHintText('开始合并最终数据...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('数据合并完毕!');
  
  nStr := 'Delete From %s Where IsNull(R_ReqValue,0)=0';
  nStr := Format(nStr, [sTable_InvReqtemp]);

  ShowHintText('开始清理临时无效数据...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('无效数据清理完毕!');
end;

initialization
  gControlManager.RegCtrl(TfFormInvoiceZZAll, TfFormInvoiceZZAll.FormID);
end.
