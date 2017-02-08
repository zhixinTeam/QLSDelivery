{*******************************************************************************
  作者: dmzn@163.com 2014/8/27
  描述: 安全验证
*******************************************************************************}
unit UFormAuthorize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit;

type
  TfFormAuthorize = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditMAC: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditFact: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditSerial: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDepart: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  UMgrControl, UDataModule, UFormBase, UFormCtrl, USysDB, USysConst;

class function TfFormAuthorize.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormAuthorize.Create(Application) do
  try
    with gSysParam do
    begin
      EditMAC.Text := FLocalMAC;
      EditName.Text := FLocalName;
    end;

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormAuthorize.FormID: integer;
begin
  Result := cFI_FormAuthorize;
end;

function TfFormAuthorize.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditFact then
  begin
    EditFact.Text := Trim(EditFact.Text);
    Result := EditFact.Text <> '';
    nHint := '请填写工厂编号';
  end else

  if Sender = EditSerial then
  begin
    EditSerial.Text := Trim(EditSerial.Text);
    Result := EditSerial.Text <> '';
    nHint := '请填写电脑编号';
  end;
end;

procedure TfFormAuthorize.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if not IsDataValid then Exit;
  nStr := SF('W_MAC', gSysParam.FLocalMAC);
  
  nStr := MakeSQLByStr([SF('W_Name', EditName.Text),
          SF('W_Factory', EditFact.Text),
          SF('W_Departmen', EditDepart.Text),
          SF('W_Serial', EditSerial.Text),
          SF('W_ReqMan', gSysParam.FUserID),
          SF('W_ReqTime', sField_SQLServer_Now, sfVal)
          ], sTable_WorkePC, nStr, False);
  //xxxxx

  if FDM.ExecuteSQL(nStr) > 0 then
  begin
    ModalResult := mrOk;
    Exit;
  end;

  nStr := MakeSQLByStr([SF('W_Name', EditName.Text),
          SF('W_MAC', gSysParam.FLocalMAC),
          SF('W_Factory', EditFact.Text),
          SF('W_Departmen', EditDepart.Text),
          SF('W_Serial', EditSerial.Text),
          SF('W_ReqMan', gSysParam.FUserID),
          SF('W_ReqTime', sField_SQLServer_Now, sfVal)
          ], sTable_WorkePC, '', True);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormAuthorize, TfFormAuthorize.FormID);
end.
