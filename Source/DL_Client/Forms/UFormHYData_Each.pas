{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 随车开化验单
*******************************************************************************}
unit UFormHYData_Each;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, ComCtrls, cxListView, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, cxMCListBox;

type
  THYTruckItem = record
    FBill: string;              //交货单
    FTruck: string;             //车牌号
    FStockNO: string;           //水泥编号
    FStockName: string;         //水泥名称
    FCusID: string;             //客户编号
    FCusName: string;           //客户名称
    FValue: Double;             //提货量
    FTime: TDateTime;           //提货时间
  end;

  TfFormHYData_Each = class(TfFormNormal)
    dxLayout1Item4: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    TruckList1: TcxMCListBox;
    dxLayout1Item9: TdxLayoutItem;
    ParamList1: TcxMCListBox;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item10: TdxLayoutItem;
    EditLading: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditLDate: TcxDateEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditRDate: TcxDateEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditReporter: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditStockNo: TcxButtonEdit;
    dxLayout1Item15: TdxLayoutItem;
    EditItem: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    EditValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TruckList1Click(Sender: TObject);
    procedure ParamList1Click(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditStockNoPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FTrucks: array of THYTruckItem;
    //提货车辆
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //验证数据
    procedure InitFormData(const nCard,nTruck: string);
    //载入数据
    procedure LoadBillData(const nCard,nTruck: string);
    //读取交货单
    function LoadStockRecord(const nID: string): Boolean;
    //检验记录
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, UFormBase, UMgrControl, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule, UFormInputbox;

class function TfFormHYData_Each.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
  begin
    nP := nParam;
    if nP.FCommand <> cCmd_AddData then Exit;
  end else nP := nil;

  with TfFormHYData_Each.Create(Application) do
  try
    Caption := '开化验单';
    if Assigned(nP) then
    begin
      InitFormData(nP.FParamA, nP.FParamB);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else
    begin
      InitFormData('', '');
      ShowModal;
    end;
  finally
    Free;
  end;
end;

class function TfFormHYData_Each.FormID: integer;
begin
  Result := cFI_FormStockHY_Each;
end;

procedure TfFormHYData_Each.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, TruckList1, nIni);
    LoadMCListBoxConfig(Name, ParamList1, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormHYData_Each.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, TruckList1, nIni);
    SaveMCListBoxConfig(Name, ParamList1, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化界面
procedure TfFormHYData_Each.InitFormData(const nCard,nTruck: string);
begin
  EditLDate.Date := FDM.ServerNow;
  EditRDate.Date := EditLDate.Date + Str2Time('0:00:02');
  
  dxGroup1.AlignHorz := ahClient;
  EditReporter.Text := gSysParam.FUserID;

  if (nCard = '') and (nTruck = '') then
       ActiveControl := EditCard
  else LoadBillData(nCard, nTruck);
end;

//Date: 2011-1-16
//Parm: 纸卡号;车辆记录
//Desc: 载入标识为nZK的纸卡信息
procedure TfFormHYData_Each.LoadBillData(const nCard,nTruck: string);
var nStr: string;
    nIdx: Integer;
begin
  EditCard.Text := nCard;
  EditTruck.Text := nTruck;

  TruckList1.Clear;
  SetLength(FTrucks, 0);

  nStr := 'Select L_ID,L_CusID,H_CusName,L_Truck,L_StockNo,L_StockName,' +
          'L_Value,L_Date From $Bill ';
  //xxxxx

  if nTruck <> '' then
     nStr := nStr + ' Where L_Truck=''$TK'' And L_HYDan Is Null';
  //xxxxx

  if nCard <> '' then
     nStr := nStr + ' Where L_Card=''$CD'' And L_HYDan Is Null';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
          MI('$TK', nTruck), MI('$CD', nCard)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nCard <> '' then
        ShowMsg('无效的磁卡号', sHint);
      //xxxxx

      if nTruck <> '' then
        ShowMsg('该车不需要开单', sHint);
      Exit;
    end;

    SetLength(FTrucks, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FTrucks[nIdx] do
      begin
        FBill      := FieldByName('L_ID').AsString;
        FTruck     := FieldByName('L_Truck').AsString;
        FStockNO   := FieldByName('L_StockNo').AsString;
        FStockName := FieldByName('L_StockName').AsString;
        FCusID     := FieldByName('L_CusID').AsString;
        FCusName   := FieldByName('H_CusName').AsString;
        FValue     := FieldByName('L_Value').AsFloat;
        FTime      := FieldByName('L_Date').AsDateTime;
      end;

      Inc(nIdx);
      Next;
    end;

    for nIdx:=Low(FTrucks) to High(FTrucks) do
    with FTrucks[nIdx] do
    begin
      nStr := CombinStr([FTruck, FStockName + ' ',
              Format('%.2f', [FValue]),
              DateTime2Str(FTime)], TruckList1.Delimiter);
      TruckList1.Items.Add(nStr);
    end;
  end;
end;

procedure TfFormHYData_Each.EditCardPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    EditCard.SetFocus;
    ShowMsg('请填写磁卡号', sHint); Exit;
  end;

  TruckList1.Clear;
  LoadBillData(EditCard.Text, '');
end;

procedure TfFormHYData_Each.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then
  begin
    EditTruck.SetFocus;
    ShowMsg('请输入车牌号', sHint); Exit;
  end;

  TruckList1.Clear;
  LoadBillData('', EditTruck.Text);
end;

//Desc: 选择记录
procedure TfFormHYData_Each.TruckList1Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  EditStockNo.Clear;
  ParamList1.Clear;

  if TruckList1.ItemIndex > -1 then
  with FTrucks[TruckList1.ItemIndex] do
  begin
    EditStockNo.Text := FStockNo;
    EditStockNo.Properties.ReadOnly := True;

    nStr := '';
    for nIdx:=Low(FLadingID) to High(FLadingID) do
     if nStr = '' then
          nStr := FLadingID[nIdx]
     else nStr := nStr + ',' + FLadingID[nIdx];
    EditLading.Text := nStr;
    EditLDate.Date := FLadTime;
  end;
end;

procedure TfFormHYData_Each.EditStockNoPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_ViewData;
  nP.FParamA := Trim(EditNo.Text);
  CreateBaseFormItem(cFI_FormGetStockNo, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    EditNo.Text := nP.FParamB;
    LoadStockRecord(EditNo.Text);
  end;
end;

//Desc: 载入水泥编号为nID的检验记录
function TfFormHYData_Each.LoadStockRecord(const nID: string): Boolean;
var nStr: string;
begin
  Result := False;
  ParamList1.Clear;

  nStr := 'Select Top 1 * From %s Where R_serialNo=''%s'' Order By R_ID DESC';
  nStr := Format(nStr, [sTable_StockRecord, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
    First;

    nStr := '氧化镁' + ParamList1.Delimiter + FieldByName('R_MgO').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '三氧化硫' + ParamList1.Delimiter + FieldByName('R_SO3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '烧失量' + ParamList1.Delimiter + FieldByName('R_ShaoShi').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '氯离子' + ParamList1.Delimiter + FieldByName('R_CL').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '细度' + ParamList1.Delimiter + FieldByName('R_XiDu').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '稠度' + ParamList1.Delimiter + FieldByName('R_ChouDu').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '碱含量' + ParamList1.Delimiter + FieldByName('R_Jian').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '不溶物' + ParamList1.Delimiter + FieldByName('R_BuRong').AsString + ' ';
    ParamList1.Items.Add(nStr);
    
    nStr := '比表面积' + ParamList1.Delimiter + FieldByName('R_BiBiao').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '初凝时间' + ParamList1.Delimiter + FieldByName('R_ChuNing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '终凝时间' + ParamList1.Delimiter + FieldByName('R_ZhongNing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '安定性' + ParamList1.Delimiter + FieldByName('R_AnDing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);

    nStr := '抗折1(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗折2(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗折3(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);
    
    nStr := '抗折1(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗折2(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗折3(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);

    nStr := '抗压1(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压2(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压3(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa3').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压4(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa4').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压5(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa5').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压6(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa6').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);
    
    nStr := '抗压1(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压2(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压3(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya3').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压4(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya4').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压5(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya5').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '抗压6(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya6').AsString + ' ';
    ParamList1.Items.Add(nStr);
  end;
end;

//Desc: 检测项目
procedure TfFormHYData_Each.ParamList1Click(Sender: TObject);
var nStr: string;
    nPos: integer;
begin
  if ParamList1.ItemIndex > -1 then
  begin
    nStr := ParamList1.Items[ParamList1.ItemIndex];
    nPos := Pos(ParamList1.Delimiter, nStr);

    EditItem.Text := Copy(nStr, 1, nPos - 1);
    System.Delete(nStr, 1, nPos);
    EditValue.Text := nStr;
  end;
end;

function TfFormHYData_Each.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = TruckList1 then
  begin
    Result := TruckList1.ItemIndex > -1;
    nHint := '请选择提货车辆';
  end else

  if Sender = EditRDate then
  begin
    Result := EditRDate.Date >= EditLDate.Date;
    nHint := '报告日期应大于提货日期';
  end else

  if Sender = EditReporter then
  begin
    EditReporter.Text := Trim(EditReporter.Text);
    Result := EditReporter.Text <> '';
    nHint := '请填写有效的报告人';
  end else

  if Sender = EditStockNo then
  begin
    nStr := 'Select Count(*) From %s Where R_serialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord, EditStockNo.Text]);

    with FDM.QueryTemp(nStr) do
    begin
      Result := (RecordCount > 0) and (Fields[0].AsInteger > 0);
      nHint := '无效的水泥编号';
    end;
  end;
end;

//Desc: 开单
procedure TfFormHYData_Each.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nIdx: Integer;
begin
  if not IsDataValid then Exit;
  nID := GetSerialNo(sFlag_BusGroup, sFlag_HYDan, True);
  if nID = '' then Exit;

  FDM.ADOConn.BeginTrans;
  try
    with FTrucks[TruckList1.ItemIndex] do
    begin
      nStr := MakeSQLByStr([SF('H_No', nID);
              SF('H_SerialNo'), EditStockNo.Text],
              SF('H_Truck', FTruck),
              SF('H_Value', FValue, sfVal),
              SF('H_BillDate', DateTime2Str(EditLDate.Date)),
              SF('H_ReportDate', DateTime2Str(EditRDate.Date)),
              SF('H_Reporter', EditReporter.Text),
              SF('H_EachTruck', sFlag_Yes)]
              sTable_StockHuaYan, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set L_HYDan=''%s'' Where L_ID=%d';
      nStr := Format(nStr, [stable, nID, nIdx]);
      FDM.ExecuteSQL(nStr);
    end;

    FDM.ADOConn.CommitTrans;
    //xxxxx
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('化验单保存失败', sHint); Exit;
  end;

  nStr := Format('''%s''', [nID]);
  PrintHuaYanReport_Each(nStr, True);
  PrintHeGeReport_Each(nStr, True);

  ModalResult := mrOk;
  ShowMsg('化验单已成功保存', sHint);   
end;

initialization
  gControlManager.RegCtrl(TfFormHYData_Each, TfFormHYData_Each.FormID);
end.
