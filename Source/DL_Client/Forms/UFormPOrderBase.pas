{*******************************************************************************
  作者: fendou116688@163.com 2015/8/8
  描述: 新建采购申请单
*******************************************************************************}
unit UFormPOrderBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxLabel,
  cxCheckBox, cxTextEdit, cxDropDownEdit, cxMCListBox, cxMaskEdit,
  cxButtonEdit, StdCtrls, cxMemo;

type
  TProviderParam = record
    FID   : string;
    FName : string;
    FSaler: string;
  end;

  TMeterailsParam = record
    FID   : string;
    FName : string;
  end;

  TfFormPOrderBase = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group9: TdxLayoutGroup;
    EditSalesMan: TcxComboBox;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditProject: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditArea: TcxButtonEdit;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditMate: TcxComboBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditProvider: TcxButtonEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    cxCheckBox1: TcxCheckBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayoutControl1Item7: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    EditWarnValue: TcxTextEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    EditLimValue: TcxTextEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    dxLayoutControl1Item14: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayoutControl1Group5: TdxLayoutGroup;
    cxLabel3: TcxLabel;
    dxLayoutControl1Item15: TdxLayoutItem;
    dxLayoutControl1Group6: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
   
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSalesManKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditProviderKeyPress(Sender: TObject; var Key: Char);
    procedure EditMateKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FOrderID: string;
    FListA  : TStrings;
    FProvider: TProviderParam;
    FMeterail: TMeterailsParam;
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormCtrl, UAdjustForm, UMgrControl, UFormBaseInfo,
  USysBusiness, USysGrid, USysDB, USysConst, UBusinessPacker;

var
  gForm: TfFormPOrderBase = nil;
  //全局使用

class function TfFormPOrderBase.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormPOrderBase.Create(Application) do
    begin
      Caption := '申请单 - 添加';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormPOrderBase.Create(Application) do
    begin
      FOrderID := nP.FParamA;
      Caption := '申请单 - 修改';

      InitFormData(FOrderID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormPOrderBase.Create(Application);
        with gForm do
        begin
          Caption := '申请单 - 查看';
          FormStyle := fsStayOnTop;
          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FOrderID := nP.FParamA;
        InitFormData(FOrderID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormPOrderBase.FormID: integer;
begin
  Result := cFI_FormOrderBase;
end;

//------------------------------------------------------------------------------
procedure TfFormPOrderBase.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  FillChar(FProvider, 1, #0);
  FillChar(FMeterail, 1, #0);

  FListA := TStringList.Create;
  AdjustCtrlData(Self);
end;

procedure TfFormPOrderBase.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  FListA.Free;
  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormPOrderBase.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormPOrderBase.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//Date: 2009-6-2
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormPOrderBase.InitFormData(const nID: string);
var nStr: string;
    nArray: TDynamicStrArray;
begin
  if EditSalesMan.Properties.Items.Count < 1 then
  begin
    nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
            'Where S_InValid<>''%s'' Order By S_PY';
    nStr := Format(nStr, [sTable_Salesman, sFlag_Yes]);

    SetLength(nArray, 1);
    nArray[0] := 'S_ID';
    FDM.FillStringsData(EditSalesMan.Properties.Items, nStr, -1, '.', nArray);
    AdjustStringsItem(EditSalesMan.Properties.Items, False);
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderBase, nID]);

    LoadDataToCtrl(FDM.QuerySQL(nStr), Self);
  end;
end;

function GetStrValue(nStr: string): string;
var nPos: Integer;
begin
  nPos := Pos('.', nStr);
  Delete(nStr, 1, nPos);
  Result := nStr;
end;  

//Desc: 当前时间
procedure TfFormPOrderBase.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  TcxButtonEdit(Sender).Text := DateTime2Str(Now);
end;

//Desc: 选择区域
procedure TfFormPOrderBase.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nBool,nSelected: Boolean;
begin
  nBool := True;
  nSelected := True;

  with ShowBaseInfoEditForm(nBool, nSelected, '区域', '', sFlag_AreaItem) do
  begin
    if nSelected then TcxButtonEdit(Sender).Text := FText;
  end;
end;

//Desc: 快速定位
procedure TfFormPOrderBase.EditSalesManKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var i,nCount: integer;
    nBox: TcxComboBox;
begin
  if Key = 13 then
  begin
    Key := 0;
    nBox := Sender as TcxComboBox;

    nCount := nBox.Properties.Items.Count - 1;
    for i:=0 to nCount do
    if Pos(LowerCase(nBox.Text), LowerCase(nBox.Properties.Items[i])) > 0 then
    begin
      nBox.ItemIndex := i; Break;
    end;
  end;
end;

//Desc: 保存数据
procedure TfFormPOrderBase.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal, nWarnVal, nLimVal: Double;
begin
  nVal    := StrToFloatDef(EditValue.Text, 0);
  nLimVal := StrToFloatDef(EditLimValue.Text, 0);
  nWarnVal:= StrToFloatDef(EditWarnValue.Text, 0);

  nStr := Trim(EditProvider.Text);
  if Length(nStr)<1 then
  begin
    ShowMsg('供应商不能为空', sWarn);
    EditProvider.SetFocus;
    Exit;
  end;

  nStr := Trim(EditMate.Text);
  if Length(nStr)<1 then
  begin
    ShowMsg('原料名不能为空', sWarn);
    EditMate.SetFocus;
    Exit;
  end;

  with FListA do
  begin
    Clear;
    if cxCheckBox1.Checked then
          Values['IsValid'] := sFlag_Yes
    else  Values['IsValid'] := sFlag_No;

    Values['Area']          := EditArea.Text;
    Values['Project']       := EditProject.Text;

    Values['SaleID']        := GetCtrlData(EditSalesMan);
    Values['SaleMan']       := GetStrValue(EditSalesMan.Text);

    Values['ProviderID']    := FProvider.FID;
    Values['ProviderName']  := Trim(EditProvider.Text);

    Values['StockNO']       := FMeterail.FID;
    Values['StockName']     := Trim(EditMate.Text);

    Values['Value']         := Format('%.2f', [nVal]);
    Values['LimValue']      := Format('%.2f', [nLimVal]);
    Values['WarnValue']     := Format('%.2f', [nWarnVal]);
  end;

  FOrderID := SaveOrderBase(PackerEncodeStr(FListA.Text));
  if FOrderID='' then Exit;

  ModalResult := mrOK;
  ShowMsg('采购申请单保存成功', sHint);
end;

procedure TfFormPOrderBase.EditProviderKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    
    nP.FParamA := EditProvider.Text;
    CreateBaseFormItem(cFI_FormGetProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FProvider do
    begin
      FID   := nP.FParamB;
      FName := nP.FParamC;
      FSaler:= nP.FParamE;

      EditProvider.Text := FName;
    end;                               

    EditProvider.SelectAll;
  end;
end;

procedure TfFormPOrderBase.EditMateKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    
    nP.FParamA := EditMate.Text;
    CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FMeterail do
    begin
      FID := nP.FParamB;
      FName:=nP.FParamC;

      EditMate.Text := FName;
    end;  

    EditMate.SelectAll;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPOrderBase, TfFormPOrderBase.FormID);
end.
