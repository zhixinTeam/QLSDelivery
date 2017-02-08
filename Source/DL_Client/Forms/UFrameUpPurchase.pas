{*******************************************************************************
  作者:  lih 2016-09-1
  描述: 采购上传查询
*******************************************************************************}
unit UFrameUpPurchase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit, Menus;

type
  TfFrameUpPurchase = class(TfFrameNormal)
    EditBill: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FWhereNo: string;
    //未开条件
    FStart,FEnd: TDate;
    //时间区间
    FQuerySales,FQueryPursh: Boolean;
    //查询开关
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameUpPurchase: TfFrameUpPurchase;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, UBusinessConst, UFormBase, USysDataDict,
  UDataModule, UFormDateFilter, UForminputbox, USysConst, USysDB, USysGrid;

class function TfFrameUpPurchase.FrameID: integer;
begin
  Result := cFI_FrameUpPurchase;
end;

procedure TfFrameUpPurchase.OnCreateFrame;
begin
  inherited;
  FWhereNo := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameUpPurchase.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameUpPurchase.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
begin
  nDefault := False;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nStr := 'Select * From $Order a, $OrderDtl b ';
  //xxxxx

  if FWhere = '' then
       nStr := nStr + 'Where (a.O_ID=b.D_OID) and (O_Date>=''$S'' and O_Date<''$End'')'
  else nStr := nStr + 'Where (a.O_ID=b.D_OID) and (O_Date>=''$S'' and O_Date<''$End'') and (' + FWhere + ')';

  {if CheckDelete.Checked then
    nStr := MacroValue(nStr, [MI('$Bill', sTable_OrderBak),
            MI('$OrderDtl', sTable_OrderDtlBak),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))])
  else}
    nStr := MacroValue(nStr, [MI('$Order', sTable_Order),
            MI('$OrderDtl', sTable_OrderDtl),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);

  FDM.QueryData(SQLQuery, nStr);

end;

procedure TfFrameUpPurchase.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameUpPurchase.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere :=  'a.O_ProPY like ''%%%s%%'' Or a.O_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end else

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'a.O_ID like ''%' + EditBill.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end else
  
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'a.O_Truck like ''%' + EditTruck.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);
  end;
end;

//未上传磅单
procedure TfFrameUpPurchase.N1Click(Sender: TObject);
begin
  FWhere := '(D_BDAX=''0'') and (D_BDNUM>=3)';
  InitFormData(FWhere);
end;

procedure TfFrameUpPurchase.N2Click(Sender: TObject);
begin
  FWhere := '1=1';
  InitFormData(FWhere);
end;

procedure TfFrameUpPurchase.N4Click(Sender: TObject);
var
  nStr,nSQL:string;
begin
  nSQL := '确定要对采购磅单执行批量上传操作吗?';

  nSQL := Format(nSQL, [nStr]);
  if not QueryDlg(nSQL, sAsk) then Exit;

  nSQL := 'Update %s Set D_BDNUM=0 Where D_BDNUM>=3';
  nSQL := Format(nSQL, [sTable_OrderDtl]);
  FDM.ExecuteSQL(nSQL);

  InitFormData(FWhere);
  ShowMsg('操作成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFrameUpPurchase, TfFrameUpPurchase.FrameID);

end.
