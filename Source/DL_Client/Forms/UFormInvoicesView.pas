{*******************************************************************************
  作者: dmzn@163.com 2011-02-13
  描述: 查看已开发票列表
*******************************************************************************}
unit UFormInvoicesView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxContainer, cxEdit, cxTextEdit, cxMemo,
  dxLayoutControl, StdCtrls, cxControls, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxMCListBox;

type
  TfFormInvoicesView = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    ListDetail: TcxMCListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    { Protected declarations }
    procedure InitFormData(const nCusID,nType,nStock,nPrice: string);
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysDB, USysConst, USysGrid, UFormBase,
  UDataModule;

var
  gForm: TfFormInvoicesView = nil;
  //全局使用

//------------------------------------------------------------------------------
class function TfFormInvoicesView.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormInvoicesView.Create(Application);
        with gForm do
        begin
          Caption := '开票明细';
          FormStyle := fsStayOnTop;
          BtnOK.Visible := False;
        end;
      end;

      gForm.InitFormData(nP.FParamA, nP.FParamB, nP.FParamC, nP.FParamD);
      if not gForm.Showing then gForm.Show;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormInvoicesView.FormID: integer;
begin
  Result := cFI_FormViewInvoices;
end;

procedure TfFormInvoicesView.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListDetail, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoicesView.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListDetail);
  finally
    nIni.Free;
  end;

  Action := caFree;
  gForm := nil;
end;

//Desc: 更新界面数据
procedure TfFormInvoicesView.InitFormData(const nCusID,nType,nStock,nPrice: string);
var nStr: string;
    nVal: Double;
begin
  nStr := 'Select dtl.*,I_OutDate From $Inv inv ' +
          ' Left Join $Dtl dtl On dtl.D_Invoice=inv.I_ID ' +
          'Where I_Status=''$Used'' And I_CusID=''$Cus'' And D_Type=''$Type'' ' +
          'And D_Stock=''$Stock'' And D_Price=$Price Order By I_ID';
  nStr := MacroValue(nStr, [MI('$Inv', sTable_Invoice), MI('$Dtl', sTable_InvoiceDtl),
          MI('$Used', sFlag_InvHasUsed), MI('$Cus', nCusID),
          MI('$Type', nType), MI('$Stock', nStock), MI('$Price', nPrice)]);
  //xxxxx

  ListDetail.Items.BeginUpdate;
  try
    ListDetail.Items.Clear;

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nVal := FieldByName('D_Price').AsFloat - FieldByName('D_DisCount').AsFloat;
        //开票价

        nStr := CombinStr([FieldByName('D_Invoice').AsString,
                FieldByName('D_Price').AsString,
                Format('%.2f', [nVal]),
                FieldByName('D_Value').AsString,
                Format('%.2f', [FieldByName('D_Value').AsFloat * nVal]),
                FieldByName('D_DisMoney').AsString,
                FieldByName('I_OutDate').AsString], ListDetail.Delimiter);
        ListDetail.Items.Add(nStr);
        Next;
      end;
    end;
  finally
    ListDetail.Items.EndUpdate;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormInvoicesView, TfFormInvoicesView.FormID);
end.
