{*******************************************************************************
  作者: 289525016@163.com 2016-9-27
  描述: 微信账号绑定
*******************************************************************************}
unit UFrameWeixinBind;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters,Menus,
  dxLayoutcxEditAdapters;

type
  TfFrameWeixinBind = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
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
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker;

class function TfFrameWeixinBind.FrameID: integer;
begin
  Result := cFI_FrameWXBind;
end;

function TfFrameWeixinBind.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_WeixinBind;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By wcb_Phone';
end;

//Desc: 添加
procedure TfFrameWeixinBind.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormWeixinBind, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameWeixinBind.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
//  if cxView1.DataController.GetSelectedCount > 0 then
//  begin
//    nP.FCommand := cCmd_EditData;
//    nP.FParamA := SQLQuery.FieldByName('P_ID').AsString;
//    CreateBaseFormItem(cFI_FormSPrice, '', @nP);
//
//    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
//    begin
//      InitFormData(FWhere);
//    end;
//  end;
end;

//Desc: 删除
procedure TfFrameWeixinBind.BtnDelClick(Sender: TObject);
var nStr: string;
  nStockNo,nStockName:string;
  nXmlStr:string;  
begin
//
end;

//Desc: 查询
procedure TfFrameWeixinBind.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('wcb_Phone Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameWeixinBind, TfFrameWeixinBind.FrameID);
end.
