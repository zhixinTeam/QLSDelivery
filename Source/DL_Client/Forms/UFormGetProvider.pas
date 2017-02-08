{*******************************************************************************
  作者: fendou116688@163.com 2015/9/8
  描述: 选择供应商
*******************************************************************************}
unit UFormGetProvider;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetProvider = class(TfFormNormal)
    EditProvider: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListProvider: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListProviderKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListProviderDblClick(Sender: TObject);
  private
    { Private declarations }
    function QueryProvider(const nProvider: string): Boolean;
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

class function TfFormGetProvider.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetProvider.Create(Application) do
  begin
    Caption := '选择供应商';

    EditProvider.Text := nP.FParamA;
    QueryProvider(EditProvider.Text);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    with ListProvider.Items[ListProvider.ItemIndex] do
    begin
      nP.FParamB := Caption;
      nP.FParamC := SubItems[0];
      nP.FParamD := SubItems[1];
      nP.FParamE := SubItems[2];
    end;


    Free;
  end;
end;

class function TfFormGetProvider.FormID: integer;
begin
  Result := cFI_FormGetProvider;
end;

procedure TfFormGetProvider.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListProvider, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetProvider.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListProvider, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 查询车牌号
function TfFormGetProvider.QueryProvider(const nProvider: string): Boolean;
var nStr: string;
begin
  Result := False;
  if Trim(nProvider) = '' then Exit;
  ListProvider.Items.Clear;

  nStr := 'Select * From %s Where (P_PY Like ''%%%s%%'' or ' +
          'P_Name Like ''%%%s%%'' or P_Memo Like ''%%%s%%'')  Order By P_PY';
  nStr := Format(nStr, [sTable_Provider, Trim(nProvider), Trim(nProvider),
          Trim(nProvider)]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListProvider.Items.Add do
      begin
        Caption := FieldByName('P_ID').AsString;
        SubItems.Add(FieldByName('P_Name').AsString);
        SubItems.Add(FieldByName('P_Memo').AsString);
        SubItems.Add(FieldByName('P_Saler').AsString);

        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;

      Next;
    end;
  end;

  Result := ListProvider.Items.Count > 0;
  if Result then
  begin
    ActiveControl := ListProvider;
    ListProvider.ItemIndex := 0;
    ListProvider.ItemFocused := ListProvider.TopItem;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormGetProvider.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  QueryProvider(EditProvider.Text);
end;

procedure TfFormGetProvider.ListProviderKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListProvider.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetProvider.ListProviderDblClick(Sender: TObject);
begin
  if ListProvider.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetProvider.BtnOKClick(Sender: TObject);
begin
  if ListProvider.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetProvider, TfFormGetProvider.FormID);
end.
