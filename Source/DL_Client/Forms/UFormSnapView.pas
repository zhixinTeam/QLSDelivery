{*******************************************************************************
  作者: juner11212436@163.com 2016-06-20
  描述: 抓拍图片预览
*******************************************************************************}
unit UFormSnapView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxContainer, cxEdit,
  cxTextEdit, cxControls, cxMemo, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxImage, jpeg, DB, cxMaskEdit, cxDropDownEdit;

type
  TfFormSnapView = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    ImageTruck: TcxImage;
    dxLayoutControl1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FPicPath: string;
    //图片路径
    procedure InitFormData;
    {*初始化界面*}
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysConst, USysDB, USysPopedom, UFormWait,
  USysBusiness, UBusinessPacker;

//------------------------------------------------------------------------------
class function TfFormSnapView.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormSnapView.Create(Application) do
  begin
    nP.FCommand := cCmd_ModalResult;
    FPicPath := nP.FParamA;
    InitFormData;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);

    ShowModal;
    Free;
  end;
end;

class function TfFormSnapView.FormID: integer;
begin
  Result := cFI_FormSnapView;
end;

//Desc: 初始化界面数据
procedure TfFormSnapView.InitFormData;
var nStr: string;
    nJpg: TjpegImage;
begin
  if FPicPath = '' then
  begin
    ShowMsg('图片路径为空',sHint);
    Exit;
  end;
  if not FileExists(FPicPath) then
  begin
    ShowMsg('图片不存在',sHint);
    Exit;
  end;
  ShowWaitForm(Self, '读取图片', True);
  try
    nJpg:=TJPEGImage.Create;
    nJpg.LoadFromFile(FPicPath);
    ImageTruck.Picture.Assign(nJpg);
  finally
    if Assigned(nJpg) then nJpg.Free;
    CloseWaitForm;
  end;
end;

//Desc: 保存
procedure TfFormSnapView.BtnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

initialization
  gControlManager.RegCtrl(TfFormSnapView, TfFormSnapView.FormID);
end.
