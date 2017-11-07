{*******************************************************************************
  作者: lih@163.com 2017-11-04
  描述: 扫描二维码打印化验单
*******************************************************************************}
unit UFormHYPrint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, dxLayoutcxEditAdapters, ExtCtrls,
  CPort, Menus, cxButtons;

type
  TfFormHYPrint = class(TfFormNormal)
    editWebOrderNo: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item3: TdxLayoutItem;
    btnClear: TcxButton;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FParam: PFormCommandParam;
    function GetHYDan(const nLID:string; var nHYDan,nStockname:string):Boolean;
    procedure Writelog(nMsg:string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst, USysDB,
  UDataModule,USysLoger;

class function TfFormHYPrint.FormID: integer;
begin
  Result := cFI_FormHYPrint;
end;

class function TfFormHYPrint.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;
  with TfFormHYPrint.Create(Application) do
  try
    ActiveControl := editWebOrderNo;
    FParam := nParam;
    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    Free;
  end;

end;

procedure TfFormHYPrint.BtnOKClick(Sender: TObject);
var
  nLID:string;
  nHyDan,nstockname:string;
  nMsg:string;
begin
  nLID := 'TF'+Trim(editWebOrderNo.Text);  //注意：平凉提货单号是TH开头
  if nLID='' then
  begin
    nMsg:= '请录入提货单号';
    ShowMsg(nMsg,sHint);
    Exit;
  end;
  if not GetHYDan(nLID,nHyDan,nstockname) then Exit;
  FParam.FParamB := nHyDan;
  FParam.FParamC := nstockname;
  FParam.FParamD := nLID;
  ModalResult := mrok;
end;

function TfFormHYPrint.GetHYDan(const nLID:string;var nHYDan,nStockname: string): Boolean;
var
  nStr:string;
  nBillno:string;
  nMsg:string;
  nStatus:string;
begin
  Result := False;

  nStr := 'select L_Status,L_HYDan,L_StockName from %s where L_ID=''%s''';
  nStr := Format(nStr,[sTable_Bill,nLID]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount<1 then
    begin
      nMsg := '提货单不存在或已删除';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      Exit;
    end;
    nStatus := FieldByName('L_Status').AsString;
    if (nStatus<>sFlag_TruckOut) then
    begin
      nMsg := '请在车辆出厂后再打印化验单';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      Exit;
    end;
    nHYDan := FieldByName('L_HYDan').AsString;
    nStockName := FieldByName('L_StockName').AsString;
    Result := True;
  end;  
end;

procedure TfFormHYPrint.btnClearClick(Sender: TObject);
begin
  editWebOrderNo.Clear;
  self.ActiveControl := editWebOrderNo;
end;

procedure TfFormHYPrint.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]';
  nStr := Format(nStr,[editWebOrderNo.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

procedure TfFormHYPrint.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnok.Click;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormHYPrint, TfFormHYPrint.FormID);
end.
