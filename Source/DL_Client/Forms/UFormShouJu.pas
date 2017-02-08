{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 收据管理
*******************************************************************************}
unit UFormShouJu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxDropDownEdit, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxMaskEdit, cxCalendar,
  dxLayoutControl, StdCtrls;

type
  TfFormShouJu = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxDateEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditMan: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item6: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditReason: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item11: TdxLayoutItem;
    EditBig: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    EditBank: TcxComboBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditMoneyExit(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FRecordID: string;
    FPrefixID: string;
    //前缀编号
    FIDLength: integer;
    //前缀长度
    procedure InitFormData(const nID: string);
    //载入数据
    procedure GetData(Sender: TObject; var nData: string);
    //获取数据
    function SetData(Sender: TObject; const nData: string): Boolean;
    //设置数据
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
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, UFormBase, UMgrControl, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule;

var
  gForm: TfFormShouJu = nil;
  //全局使用

class function TfFormShouJu.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormShouJu.Create(Application) do
    begin
      FRecordID := '';
      Caption := '收据 - 添加';

      EditName.Text := nP.FParamA;
      EditReason.Text := nP.FParamB;
      EditMoney.Text := nP.FParamC;
      EditMoneyExit(nil);

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormShouJu.Create(Application) do
    begin
      Caption := '收据 - 修改';
      FRecordID := nP.FParamA;

      InitFormData(FRecordID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
        gForm := TfFormShouJu.Create(Application);
      //xxxxx

      with gForm  do
      begin
        Caption := '收据 - 查看';
        FormStyle := fsStayOnTop;
        BtnOK.Visible := False;

        FRecordID := nP.FParamA;
        InitFormData(FRecordID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormShouJu.FormID: integer;
begin
  Result := cFI_FormShouJu;
end;

procedure TfFormShouJu.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'SJ');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
  finally
    nIni.Free;
  end;

  ResetHintAllForm(Self, 'T', sTable_SysShouJu);
  //重置表名称
end;

procedure TfFormShouJu.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
end;

//------------------------------------------------------------------------------
procedure TfFormShouJu.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditDate then
  begin
    nData := DateTime2Str(EditDate.Date);
  end;
end;

function TfFormShouJu.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;

  if Sender = EditDate then
  begin
    EditDate.Date := Str2DateTime(nData);
    Result := True;
  end;
end;

procedure TfFormShouJu.InitFormData(const nID: string);
var nStr: string;
begin
  EditDate.Date := Now;
  EditMan.Text := gSysParam.FUserID;

  if EditBank.Properties.Items.Count < 1 then
    LoadSysDictItem(sFlag_BankItem, EditBank.Properties.Items);
  //xxxxx
  
  if nID = '' then
  begin
    EditIDPropertiesButtonClick(nil, 0);
  end else
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_SysShouJu, nID]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), Self, '', SetData);
  end;
end;

//------------------------------------------------------------------------------
function SmallTOBig(small: real): string;
var
  SmallMonth, BigMonth: string;
  wei1, qianwei1: string[2];
  qianwei, dianweizhi, qian: integer;
  fs_bj: boolean;
begin
  if small < 0 then
    fs_bj := True
  else
    fs_bj := False;
  small      := abs(small);
  {------- 修改参数令值更精确 -------}
  {小数点后的位置，需要的话也可以改动-2值}
  qianwei    := -2;
  {转换成货币形式，需要的话小数点后加多几个零}
  Smallmonth := formatfloat('0.00', small);
  {---------------------------------}
  dianweizhi := pos('.', Smallmonth);{小数点的位置}
  {循环小写货币的每一位，从小写的右边位置到左边}
  for qian := length(Smallmonth) downto 1 do
  begin
    {如果读到的不是小数点就继续}
    if qian <> dianweizhi then
    begin
      {位置上的数转换成大写}
      case StrToInt(Smallmonth[qian]) of
        1: wei1 := '壹';
        2: wei1 := '贰';
        3: wei1 := '叁';
        4: wei1 := '肆';
        5: wei1 := '伍';
        6: wei1 := '陆';
        7: wei1 := '柒';
        8: wei1 := '捌';
        9: wei1 := '玖';
        0: wei1 := '零';
      end;
      {判断大写位置，可以继续增大到real类型的最大值}
      case qianwei of
        -3: qianwei1 := '厘';
        -2: qianwei1 := '分';
        -1: qianwei1 := '角';
        0: qianwei1  := '元';
        1: qianwei1  := '拾';
        2: qianwei1  := '佰';
        3: qianwei1  := '仟';
        4: qianwei1  := '万';
        5: qianwei1  := '拾';
        6: qianwei1  := '佰';
        7: qianwei1  := '仟';
        8: qianwei1  := '亿';
        9: qianwei1  := '拾';
        10: qianwei1 := '佰';
        11: qianwei1 := '仟';
      end;
      inc(qianwei);
      BigMonth := wei1 + qianwei1 + BigMonth;{组合成大写金额}
    end;
  end;

  BigMonth := StringReplace(BigMonth, '零拾', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零佰', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零仟', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零亿', '亿', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零万', '万', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零元', '元', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '亿万', '亿', [rfReplaceAll]);
  BigMonth := BigMonth + '整';
  BigMonth := StringReplace(BigMonth, '分整', '分', [rfReplaceAll]);

  if BigMonth = '元整' then
    BigMonth := '零元整';
  if copy(BigMonth, 1, 2) = '元' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if copy(BigMonth, 1, 2) = '零' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if fs_bj = True then
    SmallTOBig := '- ' + BigMonth
  else
    SmallTOBig := BigMonth;
end;

//Desc: 单据编号
procedure TfFormShouJu.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nID: integer;
begin
  nID := FDM.GetFieldMax(sTable_SysShouJu, 'R_ID') + 1;
  EditID.Text := FDM.GetSerialID2(FPrefixID, sTable_SysShouJu, 'R_ID', 'S_Code', nID);
end;

procedure TfFormShouJu.EditMoneyExit(Sender: TObject);
begin
  if IsNumber(EditMoney.Text, True) then
       EditBig.Text := SmallTOBig(StrToFloat(EditMoney.Text))
  else EditBig.Text := '';
end;

//Desc: 验证数据
function TfFormShouJu.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = EditID then
  begin
    Result := Trim(EditID.Text) <> '';
    nHint := '请填写有效的凭单号码';
    if not Result then Exit;

    nStr := 'Select Count(*) From %s Where S_Code=''%s''';
    nStr := Format(nStr, [sTable_SysShouJu, EditID.Text]);

    if FRecordID <> '' then
      nStr := nStr + ' And R_ID<>' + FRecordID;
    //xxxxx

    Result := FDM.QueryTemp(nStr).Fields[0].AsInteger < 1;
    nHint := '该凭单号码已经存在';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True);
    nHint := '请填写有效的金额';
  end;
end;

//Desc: 保存
procedure TfFormShouJu.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if not IsDataValid then Exit;

  if FRecordID = '' then
  begin
    nStr := MakeSQLByForm(Self, sTable_SysShouJu, '', True, GetData);
  end else
  begin
    nStr := 'R_ID=' + FRecordID;
    nStr := MakeSQLByForm(Self, sTable_SysShouJu, nStr, False, GetData);
  end;

  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    if FRecordID = '' then
         nStr := IntToStr(FDM.GetFieldMax(sTable_SysShouJu, 'R_ID'))
    else nStr := FRecordID;

    FDM.ADOConn.CommitTrans;
    PrintShouJuReport(nStr, True);

    ModalResult := mrOK;
    ShowMsg('单据已保存', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('单据保存失败', sError);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormShouJu, TfFormShouJu.FormID);
end.
