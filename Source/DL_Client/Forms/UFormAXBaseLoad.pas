unit UFormAXBaseLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxCheckBox;

type
  TfFormAXBaseLoad = class(TfFormNormal)
    chkCustomer: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    chkTPRESTIGEMANAGE: TcxCheckBox;
    chkTPRESTIGEMBYCONT: TcxCheckBox;
    chkProviders: TcxCheckBox;
    chkInvent: TcxCheckBox;
    chkINVENTDIM: TcxCheckBox;
    chkINVENTLOCATION: TcxCheckBox;
    chkInvCenGroup: TcxCheckBox;
    chkEmpl: TcxCheckBox;
    chkINVENTCENTER: TcxCheckBox;
    chkCement: TcxCheckBox;
    chkTruck: TcxCheckBox;
    chkSalOrder: TcxCheckBox;
    chkSalOrderLine: TcxCheckBox;
    chkContract: TcxCheckBox;
    chkContractLine: TcxCheckBox;
    chkPurOrder: TcxCheckBox;
    chkPurOrdLine: TcxCheckBox;
    chkSupAgr: TcxCheckBox;
    chkKuWei: TcxCheckBox;
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
  fFormAXBaseLoad: TfFormAXBaseLoad;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom, UBusinessPacker, UAdjustForm, UFormWait;

class function TfFormAXBaseLoad.FormID: integer;
begin
  Result := cFI_FormAXBaseLoad;
end;

class function TfFormAXBaseLoad.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormAXBaseLoad.Create(Application) do
  begin
    if not gSysParam.FIsAdmin then
    begin
      chkInvent.Visible:=False;
      chkCement.Visible:=False;
      chkINVENTDIM.Visible:=False;
      chkINVENTLOCATION.Visible:=False;
      chkINVENTCENTER.Visible:=False;
      chkInvCenGroup.Visible:=False;
      chkEmpl.Visible:=False;
      chkTruck.Visible:=False;
    end;
    Caption := '基础表数据下载';
    ShowModal;
    Free;
  end;
end;

procedure TfFormAXBaseLoad.FormCreate(Sender: TObject);
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

procedure TfFormAXBaseLoad.FormClose(Sender: TObject;
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

procedure TfFormAXBaseLoad.BtnOKClick(Sender: TObject);
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
    if chkProviders.Checked then
    begin
      if SyncRemoteProviders then
        nMsg:='供应商信息同步成功'
      else
        nMsg:='供应商信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkInvent.Checked then
    begin
      if SyncRemoteMeterails then
        nMsg:='原材料信息同步成功'
      else
        nMsg:='原材料信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkCement.Checked then
    begin
      if SyncCement then
        nMsg:='水泥信息同步成功'
      else
        nMsg:='水泥信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTDIM.Checked then
    begin
      if SyncINVENTDIM then
        nMsg:='维度信息同步成功'
      else
        nMsg:='维度信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTLOCATION.Checked then
    begin
      if SyncINVENTLOCATION then
        nMsg:='仓库信息同步成功'
      else
        nMsg:='仓库信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkINVENTCENTER.Checked then
    begin
      if SyncINVENTCENTER then
        nMsg:='生产线信息同步成功'
      else
        nMsg:='生产线信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkInvCenGroup.Checked then
    begin
      if SyncInvCenGroup then
        nMsg:='物料组生产线信息同步成功'
      else
        nMsg:='物料组生产线信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkEmpl.Checked then
    begin
      if SyncEmpTable then
        nMsg:='员工信息同步成功'
      else
        nMsg:='员工信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkTruck.Checked then
    begin
      if GetAXVehicleNo then
        nMsg:='车辆信息同步成功'
      else
        nMsg:='车辆信息同步失败';
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
    if chkPurOrder.Checked then
    begin
      if GetAXPurOrder then
        nMsg:='采购订单同步成功'
      else
        nMsg:='采购订单同步失败';
      ShowMsg(nMsg,sHint);
    end;
    if chkPurOrdLine.Checked then
    begin
      if GetAXPurOrdLine then
        nMsg:='采购订单行同步成功'
      else
        nMsg:='采购订单行同步失败';
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
    if chkKuWei.Checked then
    begin
      if SyncWmsLocation then
        nMsg:='库位信息同步成功'
      else
        nMsg:='库位信息同步失败';
      ShowMsg(nMsg,sHint);
    end;
  finally
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAXBaseLoad,TfFormAXBaseLoad.FormID);

end.
