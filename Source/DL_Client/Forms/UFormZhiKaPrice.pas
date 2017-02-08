{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 纸卡调价
*******************************************************************************}
unit UFormZhiKaPrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormZKPrice = class(TfFormNormal)
    EditStock: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditNew: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item6: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FZKList: TStrings;
    //纸卡列表
    procedure InitFormData;
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
  IniFiles, ULibFun, UFormBase, UMgrControl, USysDB, USysConst, USysBusiness,
  UFormWait, UDataModule;

class function TfFormZKPrice.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormZKPrice.Create(Application) do
  begin
    Caption := '纸卡调价';
    FZKList.Text := nP.FParamB;
    InitFormData;
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZKPrice.FormID: integer;
begin
  Result := cFI_FormAdjustPrice;
end;

procedure TfFormZKPrice.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FZKList := TStringList.Create;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    Check1.Checked := nIni.ReadBool(Name, 'AutoUnfreeze', True);
    Check2.Checked := nIni.ReadBool(Name, 'NewPriceType', False);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZKPrice.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    nIni.WriteBool(Name, 'AutoUnfreeze', Check1.Checked);
    nIni.WriteBool(Name, 'NewPriceType', Check2.Checked);
  finally
    nIni.Free;
  end;

  FZKList.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormZKPrice.InitFormData;
var nIdx: Integer; 
    nStock: string;
    nList: TStrings;
    nMin,nMax,nVal: Double;
begin
  nList := TStringList.Create;
  try
    nMin := MaxInt;
    nMax := 0;
    nStock := '';

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //明细记录号;单价;纸卡;品种名称
      if not IsNumber(nList[1], True) then Continue;

      nVal := StrToFloat(nList[1]);
      if nVal < nMin then nMin := nVal;
      if nVal > nMax then nMax := nVal;
      if nStock = '' then nStock := nList[4];
    end;

    ActiveControl := EditNew;
    EditStock.Text := nStock;
    
    if nMin = nMax then
         EditPrice.Text := Format('%.2f 元/吨', [nMax])
    else EditPrice.Text := Format('%.2f - %.2f 元/吨', [nMin, nMax]);
  finally
    nList.Free;
  end;
end;

procedure TfFormZKPrice.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal: Double;
    nIdx: Integer;
    nList: TStrings;
begin
  if not (IsNumber(EditNew.Text, True) and ((StrToFloat(EditNew.Text) > 0) or
     Check2.Checked)) then
  begin
    EditNew.SetFocus;
    ShowMsg('请输入正确的单价', sHint); Exit;
  end;

  nStr := '注意: 该操作不可以撤销,请您慎重!' + #13#10#13#10 +
          '价格调整后,新单价会立刻生效,要继续吗?  ';
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  nList := nil;
  FDM.ADOConn.BeginTrans;
  try
    if FZKList.Count > 20 then
      ShowWaitForm(Self, '调价中,请稍候');
    nList := TStringList.Create;

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //明细记录号;单价;纸卡;品种名称

      nVal := StrToFloat(EditNew.Text);
      if Check2.Checked then
        nVal := StrToFloat(nList[1]) + nVal;
      nVal := Float2Float(nVal, cPrecision, True);

      nStr := 'Update %s Set D_Price=%.2f,D_PPrice=%s ' +
              'Where R_ID=%s And D_TPrice<>''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nVal, nList[1], nList[0], sFlag_No]);
      FDM.ExecuteSQL(nStr);

      nStr := '水泥品种[ %s ]单价调整[ %s -> %.2f ]';
      nStr := Format(nStr, [nList[4], nList[1], nVal]);
      FDM.WriteSysLog(sFlag_ZhiKaItem, nList[2], nStr, False);

      if not Check1.Checked then Continue;
      nStr := 'Update %s Set Z_TJStatus=''%s'' Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, sFlag_TJOver, nList[2]]);
      FDM.ExecuteSQL(nStr);
    end;

    FDM.ADOConn.CommitTrans;
    nIdx := MaxInt;
  except
    nIdx := -1;
    FDM.ADOConn.RollbackTrans;
    ShowMsg('调价失败', sError);
  end;

  nList.Free;
  if FZKList.Count > 20 then CloseWaitForm;
  if nIdx = MaxInt then ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZKPrice, TfFormZKPrice.FormID);
end.
