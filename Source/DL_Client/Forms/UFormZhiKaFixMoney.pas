{*******************************************************************************
  作者: dmzn@163.com 2010-3-15
  描述: 卡片限提金额

  备注:
  *.若纸卡有限提金额,则该纸卡最多只能提出这么多银两的货.
*******************************************************************************}
unit UFormZhiKaFixMoney;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  cxMCListBox, dxLayoutControl, StdCtrls;

type
  TfFormZhiKaFixMoney = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    EditZK: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditOut: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditIn: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxGroup3: TdxLayoutGroup;
    EditFreeze: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditValid: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    EditMoney: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item11: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure Check1Click(Sender: TObject);
  protected
    { Protected declarations }
    procedure LoadFormData(const nZID: string);
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
  DB, IniFiles, ULibFun, UMgrControl, UDataModule, UFormBase, USysConst,
  USysDB, USysGrid, USysBusiness;

type
  TCommonInfo = record
    FZhiKa: string;
    FCusID: string;
    FFixMoney: Double;
  end;

var
  gInfo: TCommonInfo;
  //全局使用

//------------------------------------------------------------------------------
class function TfFormZhiKaFixMoney.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormZhiKaFixMoney.Create(Application) do
  begin
    Caption := '限提金额';
    gInfo.FZhiKa := nP.FParamA;

    LoadFormData(gInfo.FZhiKa);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZhiKaFixMoney.FormID: integer;
begin
  Result := cFI_FormZhiKaFixMoney;
end;

procedure TfFormZhiKaFixMoney.FormCreate(Sender: TObject);
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

procedure TfFormZhiKaFixMoney.FormClose(Sender: TObject; var Action: TCloseAction);
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

procedure TfFormZhiKaFixMoney.Check1Click(Sender: TObject);
begin
  if Check1.Checked then ActiveControl := EditMoney; 
end;

//------------------------------------------------------------------------------
//Desc: 载入界面数据
procedure TfFormZhiKaFixMoney.LoadFormData(const nZID: string);
var nStr: string;
    nDB: TDataSet;
begin
  EditZK.Text := gInfo.FZhiKa;
  nDB := LoadZhiKaInfo(gInfo.FZhiKa, ListInfo, nStr);

  if Assigned(nDB) then
  begin
    gInfo.FCusID := nDB.FieldByName('Z_Customer').AsString;
    gInfo.FFixMoney := nDB.FieldByName('Z_FixedMoney').AsFloat;

    EditMoney.Text := Format('%.2f', [nDB.FieldByName('Z_FixedMoney').AsFloat]);
    Check1.Checked := nDB.FieldByName('Z_OnlyMoney').AsString = sFlag_Yes;
  end else
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, gInfo.FCusID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    EditIn.Text := Format('%.2f', [FieldByName('A_InMoney').AsFloat]);
    EditOut.Text := Format('%.2f', [FieldByName('A_OutMoney').AsFloat]);
    EditFreeze.Text := Format('%.2f', [FieldByName('A_FreezeMoney').AsFloat]);

    EditValid.Text := Format('%.2f', [GetCustomerValidMoney(gInfo.FCusID)]);
    //xxxxx
  end;
end;

//Date: 2011-11-30
//Parm: 纸卡编号;当前限提金额
//Desc: 验证nFixMoney是否有效.循环验证,避免操作中资金变动.
function CheckFixMoneyValid(const nZID: string; const nFixMoney: Double): Boolean;
var nStr: string;
    nVal,nTmp: Double;
begin
  nVal := 0;
  Result := True;

  while True do
  begin
    nStr := 'Select Sum( L_Value * L_Price ) From %s ' +
            'Where L_ZhiKa=''%s'' And L_OutFact Is Null';
    nStr := Format(nStr, [sTable_Bill, nZID, sFlag_Yes]);

    nTmp := FDM.QueryTemp(nStr).Fields[0].AsFloat;
    nTmp := Float2Float(nTmp, cPrecision, True);

    if FloatRelation(nVal, nTmp, rtEqual, cPrecision) then Exit;
    nVal := nTmp;

    if nFixMoney > nTmp then
         nTmp := nFixMoney - nVal
    else nTmp := 0;

    nStr := '该纸卡当前有冻结金(开单未提),限提金额需要调整: ' + #13#10#13#10 +
            '*.冻结金额: %.2f 元' + #13#10 +
            '*.限提金额: %.2f 元' + #13#10 +
            '*.可用总额: %.2f 元' + #13#10#13#10 +
            '点击[是],纸卡限提总额为[ %.2f ]元.' + #13#10 +
            '点击[否],请填写有效限提金额,建议限提[ %.2f ]元.';
    nStr := Format(nStr, [nVal, nFixMoney, nFixMoney+nVal, nFixMoney+nVal, nTmp]);
    //xxxxx

    Result := QueryDlg(nStr, sAsk);
    if not Result then Exit;
  end;
end;

//Desc: 保存
procedure TfFormZhiKaFixMoney.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if (not IsNumber(EditMoney.Text, True)) or (StrToFloat(EditMoney.Text) < 0) then
  begin
    EditMoney.SetFocus;
    ShowMsg('请输入正确的金额', sHint); Exit;
  end;

  if not CheckFixMoneyValid(gInfo.FZhiKa, StrToFloat(EditMoney.Text)) then Exit;
  //验证限提金

  nStr := 'Update %s Set Z_FixedMoney=$My,Z_OnlyMoney=$F ' +
          'Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, gInfo.FZhiKa]);

  if Check1.Checked then
  begin
    nStr := MacroValue(nStr, [MI('$My', EditMoney.Text)]);
    nStr := MacroValue(nStr, [MI('$F', '''' + sFlag_Yes + '''')]);
  end else nStr := MacroValue(nStr, [MI('$My', 'Null'), MI('$F', 'Null')]);

  FDM.ExecuteSQL(nStr);
  //xxxxx

  if Check1.Checked then
  begin
    nStr := '纸卡[ %s ]限提金额[ %.2f -> %.2f ]';
    nStr := Format(nStr, [gInfo.FZhiKa, gInfo.FFixMoney,
                          StrToFloat(EditMoney.Text)]);
  end else nStr := Format('取消限制纸卡[ %s ]的可提货金额', [gInfo.FZhiKa]);

  FDM.WriteSysLog(sFlag_ZhiKaItem, gInfo.FZhiKa, nStr, False);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZhiKaFixMoney, TfFormZhiKaFixMoney.FormID);
end.
