{*******************************************************************************
  作者: dmzn@163.com 2010-3-15
  描述: 纸卡审核
*******************************************************************************}
unit UFormZhiKaVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxMaskEdit,
  cxDropDownEdit, cxMemo, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls;

type
  TfFormZhiKaVerify = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    EditMoney: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditDesc: TcxMemo;
    dxLayout1Item4: TdxLayoutItem;
    EditZID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    EditInfo: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClick(Sender: TObject);
  protected
    { Protected declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure GetSaveSQLList(const nList: TStrings); override;
    procedure AfterSaveData(var nDefault: Boolean); override;
    //基类方法
    procedure LoadFormData(const nID: string);
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
  DB, IniFiles, ULibFun, UMgrControl, UFormBase, USysConst, USysGrid, USysDB,
  USysBusiness, UDataModule, USysPopedom;

type
  TCommonInfo = record
    FZhiKa: string;
    FSaleMan: string;
    FCusID: string;
    FCusName: string;

    FDtlNum: integer;
    FDtlMoney: Double;
    FDtlValue: Double;
  end;

var
  gInfo: TCommonInfo;
  //全局使用
  
//------------------------------------------------------------------------------
class function TfFormZhiKaVerify.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormZhiKaVerify.Create(Application) do
  begin
    Caption := '纸卡审核';
    with EditMoney,gPopedomManager do
      Properties.ReadOnly := not HasPopedom(nPopedom, sPopedom_Edit);  
    LoadFormData(nP.FParamA);
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZhiKaVerify.FormID: integer;
begin
  Result := cFI_FormZhiKaVerify;
end;

procedure TfFormZhiKaVerify.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZhiKaVerify.FormClick(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 载入界面数据
procedure TfFormZhiKaVerify.LoadFormData(const nID: string);
var nStr: string;
    nDS: TDataSet;
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  nDS := LoadZhiKaInfo(nID, ListInfo, nStr);

  if Assigned(nDS) then
  begin
    EditZID.Text := nID;
    ActiveControl := EditMoney;
    EditMoney.Text := nDS.FieldByName('Z_YFMoney').AsString;    
  end else
  begin
    BtnOK.Enabled := False;
    ShowMsg(nStr, sHint); Exit;
  end;

  gInfo.FZhiKa := nID;
  gInfo.FSaleMan := nDS.FieldByName('Z_SaleMan').AsString;
  gInfo.FCusID := nDS.FieldByName('Z_Customer').AsString;
  gInfo.FCusName := nDS.FieldByName('C_Name').AsString;

  LoadSysDictItem(sFlag_PaymentItem2, EditType.Properties.Items);
  EditType.ItemIndex := 0;

  nStr := 'Select D_Price,D_Value From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    with gInfo do
    begin
      FDtlValue := FDtlValue + Fields[1].AsFloat;
      FDtlMoney := FDtlMoney +  Fields[0].AsFloat * Fields[1].AsFloat;
      FDtlNum := FDtlNum + 1;
      Next;
    end;
  end;

  with gInfo do
  if FDtlNum > 0 then
  begin
    nStr := '有效量[ %.2f ]吨,合计需[ %.2f ]元';
    EditInfo.Text := Format(nStr, [FDtlValue, FDtlMoney]);
  end else EditInfo.Text := '该纸卡无明细,可不用审核.';
end;

//Desc: 验证数据
function TfFormZhiKaVerify.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nStr: string;
    nVal: Double;
begin
  Result := True;

  if Sender = EditType then
  begin
    Result := Trim(EditType.Text) <> '';
    nHint := '请填写有效的付款方式';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True);
    nHint := '请填写有效的金额';
    if not Result then Exit;

    nVal := StrToFloat(EditMoney.Text);
    nVal := nVal + GetCustomerValidMoney(gInfo.FCusID);

    if nVal < gInfo.FDtlMoney then
    begin
      nStr := '*.该客户当前可用金为: %.2f元' + #13#10 +
              '*.当前纸卡办理金额为: %.2f元 差额: %.2f元' + #13#10 + #13#10 +
              '客户资金余额不足,会导致无法提货!要继续审核吗?' + #13#10 +
              '继续审核请点"是"按钮.';
      nStr := Format(nStr, [nVal, gInfo.FDtlMoney, gInfo.FDtlMoney - nVal]);
      
      Result := QueryDlg(nStr, sAsk);
      nHint := '请缴纳足够的金额';
    end;
  end;
end;

procedure TfFormZhiKaVerify.GetSaveSQLList(const nList: TStrings);
var nStr: string;
begin
  nStr := 'Update %s Set Z_Verified=''%s'' Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sFlag_Yes, gInfo.FZhiKa]);
  nList.Add(nStr);

  nStr := 'Update %s Set A_InMoney=A_InMoney+%s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, EditMoney.Text, gInfo.FCusID]);
  nList.Add(nStr);

  EditDesc.Text := Trim(EditDesc.Text);
  if EditDesc.Text = '' then
    EditDesc.Text := Format('审核纸卡[ %s ]时缴纳', [gInfo.FZhiKa]);
  //xxxxx

  nStr := 'Insert Into $IOM(M_SaleMan,M_CusID,M_CusName,M_Type,M_Money,' +
          'M_Payment,M_ZID,M_Date,M_Man,M_Memo) Values(''$SM'',''$CID'',' +
          '''$CName'', ''$Type'', $Money, ''$Pay'',''$ZID'', $Date,' +
          '''$Man'',''$Memo'')';
  nStr := MacroValue(nStr, [MI('$IOM', sTable_InOutMoney),
          MI('$CID', gInfo.FCusID), MI('$CName', gInfo.FCusName),
          MI('$SM', gInfo.FSaleMan), MI('$Type', sFlag_MoneyZhiKa),
          MI('$Money', EditMoney.Text), MI('$ZID', gInfo.FZhiKa),
          MI('$Date', FDM.SQLServerNow), MI('$Man', gSysParam.FUserID),
          MI('$Memo', EditDesc.Text), MI('$Pay', EditType.Text)]);
  nList.Add(nStr);
end;

//Desc: 保存完毕,打收据
procedure TfFormZhiKaVerify.AfterSaveData(var nDefault: Boolean);
var nP: TFormCommandParam;
begin
  if StrToFloat(EditMoney.Text) > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    nP.FParamA := gInfo.FCusName;
    nP.FParamB := Format('审核纸卡[ %s ]时缴纳水泥款', [gInfo.FZhiKa]);
    nP.FParamC := EditMoney.Text;
    CreateBaseFormItem(cFI_FormShouJu, '', @nP);
  end;

  nDefault := False;
  ModalResult := mrOk;
  ShowMsg('纸卡审核成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormZhiKaVerify, TfFormZhiKaVerify.FormID);
end.
