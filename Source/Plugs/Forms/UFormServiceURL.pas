{*******************************************************************************
  作者: dmzn@163.com 2013-12-05
  描述: 管理服务地址
*******************************************************************************}
unit UFormServiceURL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrParam, UFormBase, ExtCtrls, StdCtrls;

type
  TfFormServiceURL = class(TBaseForm)
    Bevel1: TBevel;
    BtnExit: TButton;
    BtnOK: TButton;
    Label1: TLabel;
    MemoLocal: TMemo;
    Label2: TLabel;
    MemoRemote: TMemo;
    procedure MemoLocalChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData;
    //界面数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TFormCreateResult; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UMITConst;

class function TfFormServiceURL.CreateForm(const nPopedom: string;
  const nParam: Pointer): TFormCreateResult;
begin
  Result := inherited CreateForm(nPopedom, nParam);
  
  with TfFormServiceURL.Create(Application) do
  try
    BtnOK.Enabled := False;
    if gSysParam.FIsAdmin then
         BtnOK.Tag := 10
    else BtnOK.Tag := 0;

    InitFormData;
    Result.FModalResult := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormServiceURL.FormID: integer;
begin
  Result := cFI_FormServiceURL;
end;

procedure TfFormServiceURL.InitFormData;
begin
  MemoLocal.Text := gParamManager.URLLocal.Text;
  MemoRemote.Text := gParamManager.URLRemote.Text;
end;

procedure TfFormServiceURL.MemoLocalChange(Sender: TObject);
begin
  if ActiveControl = Sender then
    BtnOK.Enabled := BtnOK.Tag > 0;
  //xxxxx
end;

procedure TfFormServiceURL.BtnOKClick(Sender: TObject);
begin
  gParamManager.URLLocal.Text := Trim(MemoLocal.Text);
  gParamManager.URLRemote.Text := Trim(MemoRemote.Text);
  
  gParamManager.Modified := True;
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormServiceURL, TfFormServiceURL.FormID);
end.
