{*******************************************************************************
  作者: dmzn@163.com 2009-7-15
  描述: 退购查询
*******************************************************************************}
unit UFrameZhiKaVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameZhiKaVerify = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditZK: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameZhiKaVerify.FrameID: integer;
begin
  Result := cFI_FrameZhiKaVerify;
end;

procedure TfFrameZhiKaVerify.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameZhiKaVerify.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameZhiKaVerify.BtnExitClick(Sender: TObject);
begin
  inherited;
  Close;
end;

function TfFrameZhiKaVerify.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nStr := 'Select zk.*,iom.*,sm.S_Name,cus.C_Name,cus.C_PY From $ZK zk ' +
          ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $IOM iom On iom.M_ZID=zk.Z_ID ';
  //xxxxx

  if nWhere = '' then
       nStr := nStr + 'Where (Z_Verified<>''$Yes'' Or ' +
                      'M_Type=''$HK'') And (Z_Date>=''$Start'' And ' +
                      'Z_Date <''$End'') and (Z_InValid Is Null or ' +
                      'Z_InValid<>''$Yes'')'
  else nStr := nStr + 'Where (' + nWhere + ')';

  Result := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
            MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
            MI('$IOM', sTable_InOutMoney), MI('$HK', sFlag_MoneyZhiKa),
            MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 审核
procedure TfFrameZhiKaVerify.BtnAddClick(Sender: TObject);
var nStr: string;
    nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要审核的纸卡', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('Z_Verified').AsString;
  if nStr = sFlag_Yes then
  begin
    ShowMsg('该纸卡已审核通过', sHint); Exit;
  end;

  if not BtnAdd.Enabled then Exit;
  nParam.FParamA := SQLQuery.FieldByName('Z_ID').AsString;
  CreateBaseFormItem(cFI_FormZhiKaVerify, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 快捷菜单
procedure TfFrameZhiKaVerify.N1Click(Sender: TObject);
begin
  BtnAddClick(nil);
end;

//Desc: 双击处理
procedure TfFrameZhiKaVerify.cxView1DblClick(Sender: TObject);
begin
  BtnAddClick(nil);
end;

//Desc: 日期筛选
procedure TfFrameZhiKaVerify.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFrameZhiKaVerify.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%S%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditZK then
  begin
    EditZK.Text := Trim(EditZK.Text);
    if EditZK.Text = '' then Exit;

    FWhere := 'Z_ID like ''%' + EditZK.Text + '%''';
    InitFormData(FWhere);
  end;
end;

//Desc: 快捷查询
procedure TfFrameZhiKaVerify.N5Click(Sender: TObject);
var nStr: string;
begin
  case TComponent(Sender).Tag of
   10:
    begin
      nStr := 'M_ZID Is Null And IsNull(Z_Verified, '''')<>''%s''';
      FWhere := Format(nStr, [sFlag_Yes]);
    end;
   20:
    begin
      nStr := 'M_ZID Is Not Null And (Z_Date>=''%s'' And Z_Date <''%s'')';
      FWhere := Format(nStr, [Date2Str(FStart), Date2Str(FEnd + 1)]);
    end;
  end;

  InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameZhiKaVerify, TfFrameZhiKaVerify.FrameID);
end.
