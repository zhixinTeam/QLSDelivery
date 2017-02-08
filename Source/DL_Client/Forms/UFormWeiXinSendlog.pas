{*******************************************************************************
  作者: dmzn@163.com 2014-12-02
  描述: 发送日志
*******************************************************************************}
unit UFormWeiXinSendlog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxCheckBox, cxMemo, cxMaskEdit,
  cxDropDownEdit;

type
  TfFormWXSendlog = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSend: TcxMemo;
    dxLayout1Item5: TdxLayoutItem;
    EditRecv: TcxMemo;
    dxLayout1Item6: TdxLayoutItem;
    EditNum: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditStatus: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FRecord: string;
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, UBase64, USysBusiness,
  USysDB, USysConst;

class function TfFormWXSendlog.FormID: integer;
begin
  Result := cFI_FormWXSendlog;
end;

class function TfFormWXSendlog.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormWXSendlog.Create(Application) do
  try
    if nP.FCommand = cCmd_EditData then
         Caption := '日志 - 修改'
    else Caption := '日志 - 查看';

    BtnOK.Visible := nP.FCommand = cCmd_EditData;
    FRecord := nP.FParamA;
    InitFormData();

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormWXSendlog.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormWXSendlog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormWXSendlog.InitFormData;
var nStr: string;
begin
  if FRecord <> '' then
  begin
    nStr := 'Select * from %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_WeixinLog, FRecord]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('日志记录已丢失', sHint);
        Exit;
      end;

      EditSend.Text := DecodeBase64(FieldByName('L_Data').AsString);
      EditRecv.Text := DecodeBase64(FieldByName('L_Result').AsString);
      EditName.Text := FieldByName('L_UserID').AsString;

      EditNum.Text := FieldByName('L_Count').AsString;
      nStr := FieldByName('L_Status').AsString;

      if nStr = 'Y' then EditStatus.ItemIndex := 2 else
      if nStr = 'I' then EditStatus.ItemIndex := 1 else EditStatus.ItemIndex := 0;
    end;
  end;
end;

procedure TfFormWXSendlog.BtnOKClick(Sender: TObject);
var nFlag,nSQL: string;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    ActiveControl := EditName;
    ShowMsg('请输入接收人', sHint); Exit;
  end;

  if not IsNumber(EditNum.Text, False) then
  begin
    ActiveControl := EditNum;
    ShowMsg('请输入发送次数', sHint); Exit;
  end;

  case EditStatus.ItemIndex of
   1: nFlag := 'I';
   2: nFlag := 'Y' else nFlag := 'N';
  end;

  nSQL := MakeSQLByStr([SF('L_UserID', EditName.Text),
          SF('L_Data', EncodeBase64(EditSend.Text)),
          SF('L_Result', EncodeBase64(EditRecv.Text)),
          SF('L_Count', EditNum.Text, sfVal),
          SF('L_Status', nFlag)
          ], sTable_WeixinLog, SF('R_ID', FRecord), False);
  FDM.ExecuteSQL(nSQL);

  ModalResult := mrOk;
  ShowMsg('保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormWXSendlog, TfFormWXSendlog.FormID);
end.
