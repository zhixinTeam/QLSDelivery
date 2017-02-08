{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 纸卡调整

  备注:
  *.某客户原来有旧的纸卡,当办理新纸卡时,需要对旧纸卡做适当调整.
  *.调整方案分三种:1.将旧纸卡作废,启用新的纸卡,原纸卡的所有磁卡自动过继到新纸卡
    名下;2.原纸卡保留,将现有可用金额划转到旧纸卡中,限制旧纸卡的可提货量;3.新旧
    纸卡同时使用.
*******************************************************************************}
unit UFormZhiKaAdjust;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxListView,
  cxLabel, StdCtrls, cxRadioGroup, dxLayoutControl;

type
  TfFormZhiKaAdjust = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    Radio3: TcxRadioButton;
    dxLayout1Item3: TdxLayoutItem;
    Radio1: TcxRadioButton;
    dxLayout1Item4: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel4: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    ListZK: TcxListView;
    dxLayout1Item10: TdxLayoutItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListZKDblClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    procedure InitFormData;
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    class function LoadZhiKaList(const nCusID: string): Boolean;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, UFrameBase,
  USysGrid, USysDB, USysConst, USysBusiness, UDataModule;

type
  TCommonInfo = record
    FCusID: string;
    FSQLRes: string;
  end;

  TZhiKaItem = record
    FZhiKa: string;
    FLading: string;
    FMan: string;
    FDate: string;
  end;

var
  gInfo: TCommonInfo;
  gZKItems: array of TZhiKaItem;
  //全局使用

//------------------------------------------------------------------------------
class function TfFormZhiKaAdjust.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nP.FCommand := cCmd_ModalResult;
  gInfo.FCusID := nP.FParamA;

  if not TfFormZhiKaAdjust.LoadZhiKaList(gInfo.FCusID) then
  begin
    nP.FParamA := mrOk;
    nP.FParamB := ''; Exit;
  end;

  with TfFormZhiKaAdjust.Create(Application) do
  begin
    Caption := '旧卡调整';
    InitFormData;
    nP.FParamA := ShowModal;
    nP.FParamB := gInfo.FSQLRes;
    Free;
  end;
end;

class function TfFormZhiKaAdjust.FormID: integer;
begin
  Result := cFI_FormZhiKaAdjust;
end;

procedure TfFormZhiKaAdjust.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListZK, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZhiKaAdjust.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListZK, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化界面数据
procedure TfFormZhiKaAdjust.InitFormData;
var nIdx: Integer;
begin
  ListZK.Clear;
  ListZK.SmallImages := FDM.ImageBar;

  for nIdx:=Low(gZKItems) to High(gZKItems) do
  with ListZK.Items.Add,gZKItems[nIdx] do
  begin
    Caption := FZhiKa;
    if FLading = sFlag_SongH then
         SubItems.Add('送货')
    else SubItems.Add('自提');
    
    SubItems.Add(FMan);
    SubItems.Add(FDate);
    ImageIndex := cItemIconIndex;
  end;

  if ListZK.Items.Count > 1 then
       ListZK.ItemIndex := -1
  else ListZK.ItemIndex := 0; //多于一个时由用户选择
end;

//Desc: 载入nCusID客户使用公用账户资金的纸卡
class function TfFormZhiKaAdjust.LoadZhiKaList(const nCusID: string): Boolean;
var nStr: string;
    nIdx: integer;
begin
  Result := False;
  gInfo.FSQLRes := '';
  SetLength(gZKItems, 0);

  nStr := 'Select * From %s Where Z_Customer=''%s'' and ' +
          '(Z_OnlyMoney Is Null and Z_InValid Is Null) and ' +
          'Z_ValidDays>%s Order By Z_ID';
  nStr := Format(nStr, [sTable_ZhiKa, nCusID, FDM.SQLServerNow]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    SetLength(gZKItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with gZKItems[nIdx] do
    begin
      FZhiKa := FieldByName('Z_ID').AsString;
      FLading := FieldByName('Z_Lading').AsString;
      FMan := FieldByName('Z_Man').AsString;
      FDate := DateTime2Str(FieldByName('Z_Date').AsDateTime);

      Inc(nIdx);
      Next;
    end;

    Result := True;
  end;
end;

//Desc: 查看选中磁卡
procedure TfFormZhiKaAdjust.ListZKDblClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if ListZK.ItemIndex > -1 then
  begin
    nP.FCommand := cCmd_ViewData;
    nP.FParamA := gZKItems[ListZK.ItemIndex].FZhiKa;
    CreateBaseFormItem(cFI_FormZhiKa, '', @nP);
  end;
end;

//Desc: 确认调整模式
procedure TfFormZhiKaAdjust.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if (Radio2.Checked or Radio3.Checked) and (ListZK.Items.Count > 0) and
     (ListZK.ItemIndex < 0) then
  begin
    ListZK.SetFocus;
    ShowMsg('请选择要调整的纸卡', sHint); Exit;
  end;

  nStr := '注意: 该操作不可以撤销,请您慎重!' + #13#10 + '要继续吗?';
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  if Radio1.Checked then
  begin
    gInfo.FSQLRes := '';
  end else
  
  if Radio2.Checked then
  begin
    nStr := 'Update $ZK Set Z_FixedMoney=$Money,Z_OnlyMoney=''$Yes'' ' +
            'Where Z_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
            MI('$ID', gZKItems[ListZK.ItemIndex].FZhiKa)]);
    gInfo.FSQLRes := nStr;
  end else

  if Radio3.Checked then
  begin
    nStr := 'Update $ZK Set Z_InValid=''$Yes'' Where Z_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
            MI('$ID', gZKItems[ListZK.ItemIndex].FZhiKa)]);
    gInfo.FSQLRes := nStr;
  end;

  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZhiKaAdjust, TfFormZhiKaAdjust.FormID);
end.
