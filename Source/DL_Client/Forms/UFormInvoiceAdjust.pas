{*******************************************************************************
  作者: dmzn@163.com 2011-02-14
  描述: 修改申请量和开票单价
*******************************************************************************}
unit UFormInvoiceAdjust;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMemo,
  dxLayoutControl, StdCtrls, cxLabel;

type
  TfFormInvoiceAdjust = class(TfFormNormal)
    EditPrice: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item6: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FParam: PFormCommandParam;
    //参数
    procedure InitFormData(const nParam: PFormCommandParam);
    //载入数据
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //验证数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysDB, USysConst, UDataModule, USysBusiness;

//------------------------------------------------------------------------------
class function TfFormInvoiceAdjust.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_EditData then Exit;

  with TfFormInvoiceAdjust.Create(Application) do
  begin
    Caption := '开票申请 - 修改';
    FParam := nP;
    InitFormData(nP);
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormInvoiceAdjust.FormID: integer;
begin
  Result := cFI_FormInvAdjust;
end;

procedure TfFormInvoiceAdjust.FormCreate(Sender: TObject);
begin
  inherited;
  LoadFormConfig(Self);
end;

procedure TfFormInvoiceAdjust.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  inherited;
end;

procedure TfFormInvoiceAdjust.InitFormData(const nParam: PFormCommandParam);
var nStr: string;
begin
  nStr := '※.最大可申请量为 %s 吨,请填写新值:';
  cxLabel1.Caption := Format(nStr, [nParam.FParamE]);
  EditValue.Text := nParam.FParamD;

  nStr := '※.当前开票价为 %s 元/吨,请填写新值:';
  cxLabel2.Caption := Format(nStr, [nParam.FParamC]);
  EditPrice.Text := nParam.FParamC;
end;

function TfFormInvoiceAdjust.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True);
    nHint := '请填写有效的数值';
    if not Result then Exit;

    nVal := FParam.FParamE;
    Result := FloatRelation(nVal, StrToFloat(EditValue.Text), rtGE);
    nHint := '已超出最大可申请量';

    if Result then
    begin
      nVal := StrToFloat(EditValue.Text);
      nVal := Float2Float(nVal, cPrecision, False);
      EditValue.Text := FloatToStr(nVal);
    end;
  end else

  if Sender = EditPrice then
  begin
    Result := IsNumber(EditPrice.Text, True) and (StrToFloat(EditPrice.Text) > 0);
    nHint := '请填写有效的单价';
  end;
end;

//Desc: 保存
procedure TfFormInvoiceAdjust.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if not IsDataValid then Exit;

  nStr := FParam.FParamB;
  if IsNextWeekEnable(nStr) then
  begin
    ShowMsg('周期已经结束', '保存失败'); Exit;
  end;

  nStr := 'Update %s Set R_ReqValue=%s,R_KPrice=%s Where R_ID=%s';
  nStr := Format(nStr, [sTable_InvoiceReq, EditValue.Text, EditPrice.Text, FParam.FParamA]);
  FDM.ExecuteSQL(nStr);

  nStr := '修改开票信息,申请量:[ %s->%s ] 单价:[ %s->%s ]';
  nStr := Format(nStr, [FParam.FParamD, EditValue.Text, FParam.FParamC, EditPrice.Text]);
  FDM.WriteSysLog(sFlag_CommonItem, FParam.FParamA, nStr);

  ModalResult := mrOk;
  ShowMsg('修改成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormInvoiceAdjust, TfFormInvoiceAdjust.FormID);
end.
