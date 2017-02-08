{*******************************************************************************
  作者: fendou116688@163.com 2015/9/8
  描述: 选择原材料
*******************************************************************************}
unit UFormGetMeterails;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetMeterails = class(TfFormNormal)
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    ListMeterails: TcxListView;
    EditMeterails: TcxButtonEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListMeterailsKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListMeterailsDblClick(Sender: TObject);
  private
    { Private declarations }
    function QueryMeterails(const nMeterails: string): Boolean;
    //查询供应商
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormBase, USysGrid, USysDB, USysConst,
  USysBusiness, UDataModule, UFormInputbox;

class function TfFormGetMeterails.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetMeterails.Create(Application) do
  begin
    Caption := '选择原材料';

    EditMeterails.Text := nP.FParamA;
    QueryMeterails(EditMeterails.Text);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    with ListMeterails.Items[ListMeterails.ItemIndex] do
    begin
      nP.FParamB := Caption;
      nP.FParamC := SubItems[0];
      nP.FParamD := SubItems[1];
    end;

    Free;
  end;
end;

class function TfFormGetMeterails.FormID: integer;
begin
  Result := cFI_FormGetMeterail;
end;

procedure TfFormGetMeterails.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListMeterails, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetMeterails.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListMeterails, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 查询车牌号
function TfFormGetMeterails.QueryMeterails(const nMeterails: string): Boolean;
var nStr: string;
begin
  Result := False;
  if Trim(nMeterails) = '' then Exit;
  ListMeterails.Items.Clear;

  nStr := 'Select * From %s Where (M_PY Like ''%%%s%%'' or ' +
          'M_Name Like ''%%%s%%'' or M_Memo Like ''%%%s%%'')  Order By M_PY';
  nStr := Format(nStr, [sTable_Materails, Trim(nMeterails), Trim(nMeterails),
          Trim(nMeterails)]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListMeterails.Items.Add do
      begin
        Caption := FieldByName('M_ID').AsString;
        SubItems.Add(FieldByName('M_Name').AsString);
        SubItems.Add(FieldByName('M_Memo').AsString);

        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;

      Next;
    end;
  end;

  Result := ListMeterails.Items.Count > 0;
  if Result then
  begin
    ActiveControl := ListMeterails;
    ListMeterails.ItemIndex := 0;
    ListMeterails.ItemFocused := ListMeterails.TopItem;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormGetMeterails.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  QueryMeterails(EditMeterails.Text);
end;

procedure TfFormGetMeterails.ListMeterailsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListMeterails.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetMeterails.ListMeterailsDblClick(Sender: TObject);
begin
  if ListMeterails.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetMeterails.BtnOKClick(Sender: TObject);
begin
  if ListMeterails.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetMeterails, TfFormGetMeterails.FormID);
end.
