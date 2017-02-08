{*******************************************************************************
  作者: fendou116688@163.com 2016-02-27
  描述: 短倒明细
*******************************************************************************}
unit UFrameQueryTransferDetail;

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
  TfFrameTransferDetailQuery = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    AX1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N2Click(Sender: TObject);
    procedure AX1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件 
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, UFormWait, USysPopedom,
  USysBusiness, UBusinessConst, USysConst, USysDB;

class function TfFrameTransferDetailQuery.FrameID: integer;
begin
  Result := cFI_FrameTransferDetailQuery;
end;

procedure TfFrameTransferDetailQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameTransferDetailQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameTransferDetailQuery.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select *,(T_MValue-T_PValue) As T_NetWeight From $Transfer ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (T_Date>=''$S'' and T_Date <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  Result := MacroValue(Result, [MI('$Transfer', sTable_Transfer),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//Desc: 日期筛选
procedure TfFrameTransferDetailQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFrameTransferDetailQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'T_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'T_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditID.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc:
procedure TfFrameTransferDetailQuery.N2Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(T_Date>=''%s'' and T_Date <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: 同步交货单
procedure TfFrameTransferDetailQuery.AX1Click(Sender: TObject);
var nStr: string;
    nRes: Boolean;
begin
  nRes := False;
  //init

  if cxView1.DataController.GetSelectedCount > 0 then
  try  
    ShowWaitForm(ParentForm, '正在同步');
    nStr := SQLQuery.FieldByName('T_ID').AsString;
    //nRes := AXSyncDuanDao(nStr);
  finally
    CloseWaitForm;
    if nRes then
      InitFormData(Fwhere);
    //xxxxx
  end;
end;

procedure TfFrameTransferDetailQuery.N4Click(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_ID').AsString;
    PrintDuanDaoReport(nStr, False);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameTransferDetailQuery, TfFrameTransferDetailQuery.FrameID);
end.
