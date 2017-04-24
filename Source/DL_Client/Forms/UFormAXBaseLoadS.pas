unit UFormAXBaseLoadS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormAXBaseLoadS = class(TfFormNormal)
    chkCustomer: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    chkTPRESTIGEMANAGE: TcxCheckBox;
    chkTPRESTIGEMBYCONT: TcxCheckBox;
    chkSalOrder: TcxCheckBox;
    chkSalOrderLine: TcxCheckBox;
    chkContract: TcxCheckBox;
    chkContractLine: TcxCheckBox;
    chkSupAgr: TcxCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormAXBaseLoadS: TfFormAXBaseLoadS;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormAXBaseLoadS.FormID: integer;
begin
  Result := cFI_FormAXBaseLoadS;
end;

class function TfFormAXBaseLoadS.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormAXBaseLoadS.Create(Application) do
  begin
    Caption := '销售基础数据下载';
    ShowModal;
    Free;
  end;
end;

procedure TfFormAXBaseLoadS.FormCreate(Sender: TObject);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormAXBaseLoadS.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni:TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormAXBaseLoadS.BtnOKClick(Sender: TObject);
var
  nMsg:string;
begin
  ShowWaitForm(Self, '正在下载...', True);
  try
    if chkCustomer.Checked then
    begin
      if SyncRemoteCustomer then
        nMsg:='客户信息同步成功'
      else
        nMsg:='客户信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkTPRESTIGEMANAGE.Checked then
    begin
      if SyncTPRESTIGEMANAGE then
        nMsg:='信用额度（客户）同步成功'
      else
        nMsg:='信用额度（客户）同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkTPRESTIGEMBYCONT.Checked then
    begin
      if SyncTPRESTIGEMBYCONT then
        nMsg:='信用额度（客户-合同）同步成功'
      else
        nMsg:='信用额度（客户-合同）同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkSalOrder.Checked then
    begin
      if GetAXSalesOrder then
        nMsg:='销售订单同步成功'
      else
        nMsg:='销售订单同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkSalOrderLine.Checked then
    begin
      if GetAXSalesOrdLine then
        nMsg:='销售订单行同步成功'
      else
        nMsg:='销售订单行同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkContract.Checked then
    begin
      if GetAXSalesContract then
        nMsg:='销售合同同步成功'
      else
        nMsg:='销售合同同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkContractLine.Checked then
    begin
      if GetAXSalesContLine then
        nMsg:='销售合同行同步成功'
      else
        nMsg:='销售合同行同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkSupAgr.Checked then
    begin
      if GetAXSupAgreement then
        nMsg:='补充协议同步成功'
      else
        nMsg:='补充协议同步失败';
      ShowMsg(nMsg,sHint);
    end;
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAXBaseLoadS,TfFormAXBaseLoadS.FormID);

end.
