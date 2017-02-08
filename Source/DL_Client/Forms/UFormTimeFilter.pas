{*******************************************************************************
  作者: dmzn@163.com 2009-6-5
  描述: 日期筛选框
*******************************************************************************}
unit UFormTimeFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, dxLayoutControl, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxControls, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, cxSpinEdit, cxTimeEdit,
  cxButtonEdit;

type
  TfFormTimeFilter = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    ItemID: TcxButtonEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditStart: TcxTimeEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditEnd: TcxTimeEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowTimeFilterForm(var nStart,nEnd: TTime; nAdd: Boolean = True): Boolean;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, USysConst;

//Date: 2009-6-5
//Parm: 开始日期;结束日期
//Desc: 显示时间段筛选窗口
function ShowTimeFilterForm(var nStart,nEnd: TTime; nAdd: Boolean): Boolean;
begin
  with TfFormTimeFilter.Create(Application) do
  begin
    if nAdd then
          Caption := '增加时间段'
    else  Caption := '删除时间段';

    EditStart.Time := nStart;
    EditEnd.Time := nEnd;

    Result := ShowModal = mrOK;
    if Result then
    begin
      nStart := EditStart.Time;
      nEnd := EditEnd.Time;
    end;
    Free;
  end;
end;

//Desc: 日期选择
procedure TfFormTimeFilter.BtnOKClick(Sender: TObject);
begin
  if EditEnd.Time < EditStart.Time then
  begin
    EditEnd.SetFocus;
    ShowMsg('结束时间不能小于开始时间', sHint);
  end else ModalResult := mrOK;
end;

end.
