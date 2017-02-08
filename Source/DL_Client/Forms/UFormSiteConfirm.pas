unit UFormSiteConfirm;

{$I Link.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, CPort, CPortTypes,
  dxLayoutcxEditAdapters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel;

type
  TfFormSiteConfirm = class(TfFormNormal)
    ComPort1: TComPort;
    EditCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditLID: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditPlanWeight: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cbxSampleID: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item11: TdxLayoutItem;
    EditType: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    cbxWorkSet: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    cbxKw: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditCustomer: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FStockType:Integer;
    //类型：1：袋装 2：散装
    FBuffer: string;
    //接收缓冲
    FSumTon:Double;
    //已装吨数
    FWorkOrder:string;
    //班别
    procedure ActionComPort(const nStop: Boolean);
    procedure GetBillsInfo(const nCardNo: string); //获取交货单信息
    function GetNotOutBill(const nFID: string):Boolean; //获取未出厂交货单
    procedure ShowFormData;  //显示数据
    procedure ClearFormData; //清空数据
    procedure GetSampleID(const nStockName,nType,nCenterID: string); //获取试样编号
    function GetSumTonnage(const nSampleID: string):Double;//获取此试样编号已装吨数
    function GetSampleTonnage(const nSampleID: string; var nBatQuaS,nBatQuaE:Double):Boolean; //获取批次量
    function UpdateSampleValid(const nSampleID: string):Boolean;//更新试样编号有效性
    function GetWorkOrder:string;//获取班别
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormSiteConfirm: TfFormSiteConfirm;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, UBusinessConst, USysConst ,USysLoger, USmallFunc, USysBusiness;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;
  //提货数据记录
  TBatQua = record
    FID   : string;
    FCustomer: string;
    FTruck : string;
    FStockName: string;
    FValue : Double;
    FType  : string;
    FCenterID: string;
    FLocationID: string;
    FSampleID: string;
  end;
var
  gReaderItem: TReaderItem;
  //全局使用
  gBills: TLadingBillItems;
  //提货记录列表
  gTiHuo: array of TBatQua;
  
class function TfFormSiteConfirm.FormID: integer;
begin
  Result := cFI_FormSiteConfirm;
end;

class function TfFormSiteConfirm.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result:=nil;
  with TfFormSiteConfirm.Create(Application) do
  begin
    Caption := '现场装车确认';
    ActionComPort(False);
    FStockType:=0;
    ShowModal;
    Free;
  end;
end;

procedure TfFormSiteConfirm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ActionComPort(True);
end;

procedure TfFormSiteConfirm.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;


procedure TfFormSiteConfirm.ComPort1RxChar(Sender: TObject;
  Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    nCard:string;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    nCard:= ParseCardNO(nStr, True);
    if nCard <> EditCard.Text then
    begin
      EditCard.Text := nCard;
      cxLabel1.Caption:='已装吨数：';
      FSumTon:=0;
      GetBillsInfo(Trim(EditCard.Text));
    end;
    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormSiteConfirm.GetBillsInfo(const nCardNo: string);
var nStr,nHint: string;
    nIdx,nInt: Integer;
    nFID, nTruck:string;
begin
  nFID:='';
  if GetLadingBills(nCardNo, sFlag_TruckFH, gBills) then
  begin
    nInt := 0 ;
    nHint := '';
    FStockType := 2;
    for nIdx:=Low(gBills) to High(gBills) do
    with gBills[nIdx] do
    begin
      FSelected := FNextStatus = sFlag_TruckFH;
      if FSelected then
      begin
        Inc(nInt);
        Continue;
      end;

      nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
      if nIdx < High(gBills) then nStr := nStr + #13#10;

      nStr := Format(nStr, [FID,
              TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
      nHint := nHint + nStr;
      nFID:=FID;
      nTruck:=FTruck;
    end;

    if (nHint <> '') and (nInt = 0) then
    begin
      if GetLadingBills(nCardNo, sFlag_TruckZT, gBills) then
      begin
        nInt := 0;
        nHint := '';
        FStockType := 1;
        for nIdx:=Low(gBills) to High(gBills) do
        with gBills[nIdx] do
        begin
          FSelected := FNextStatus = sFlag_TruckZT;
          if FSelected then
          begin
            Inc(nInt);
            Continue;
          end;

          nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
          if nIdx < High(gBills) then nStr := nStr + #13#10;

          nStr := Format(nStr, [FID,
                  TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
          nHint := nHint + nStr;
          nFID:=FID;
          nTruck:=FTruck;
        end;

        if (nHint <> '') and (nInt = 0) then
        begin
          nHint := '车辆['+nTruck+']当前不能装车,详情如下: ' + #13#10#13#10 +
                   nHint + #13#10#13#10 + '是否修改试样编号？';
          if not QueryDlg(nHint, sAsk) then
          begin
            EditCard.Text:='请刷卡';
            Exit;
          end;
          if GetNotOutBill(nFID) then
          begin
            BtnOK.Caption:='修改';
            BtnOK.Enabled:=True;
          end else
          begin
            nHint := '车辆['+nTruck+']禁止修改,详情如下：'+ #13#10#13#10 + nStr;
            ShowDlg(nHint, sHint);
          end;
          Exit;
        end;
        ShowFormData;
      end else
      begin
        nHint := '车辆['+nTruck+']当前不能装车,详情如下: ' + #13#10#13#10 +
                 nHint + #13#10#13#10 + '是否修改试样编号？';
        if not QueryDlg(nHint, sAsk) then
        begin
          EditCard.Text:='请刷卡';
          Exit;
        end;
        if GetNotOutBill(nFID) then
        begin
          BtnOK.Caption:='修改';
          BtnOK.Enabled:=True;
        end else
        begin
          nHint := '车辆['+nTruck+']禁止修改,详情如下：'+ #13#10#13#10 + nStr;
          ShowDlg(nHint, sHint);
        end;
        Exit;
      end;
    end;
    ShowFormData;
    cbxWorkSet.Text:=GetWorkOrder;
    if pos('熟',EditStockName.Text)>0 then
    begin
      InitKuWei('熟料',cbxKw);
    end else
    if pos('袋',EditStockName.Text)>0 then
    begin
      InitKuWei('袋装',cbxKw);
    end else
    begin
      InitKuWei('散装',cbxKw);
    end;
  end else
  begin
    nHint := '无交货单数据';
    ShowDlg(nHint, sHint);
  end;
end;

//获取未出厂交货单
function TfFormSiteConfirm.GetNotOutBill(const nFID: string):Boolean;
var
  nSQL,nType:string;
  nLocationID:string;
  i:Integer;
begin
  Result:=False;
  SetLength(gTiHuo,0);
  nSQL := 'select * from %s '+
          'where ((L_Status=''%s'') or (L_Status=''%s'') or (L_Status=''%s'')) '+
          'and L_ID=''%s'' ';
  nSQL := Format(nSQL,[sTable_Bill, sFlag_TruckZT, sFlag_TruckFH, sFlag_TruckBFM, nFID]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      SetLength(gTiHuo,RecordCount);
      with gTiHuo[0] do
      begin
        FID:= FieldByName('L_ID').AsString;
        FCustomer:= FieldByName('L_CusName').AsString;
        FTruck:= FieldByName('L_Truck').AsString;
        FStockName:= FieldByName('L_StockName').AsString;
        FValue:= FieldByName('L_Value').AsFloat;
        if FieldByName('L_Type').AsString='0' then
          nType:='S'
        else
          nType:= FieldByName('L_Type').AsString;
        FType:= nType;
        FCenterID:= FieldByName('L_InvCenterId').AsString;
        FLocationID:= FieldByName('L_InvLocationId').AsString;
        FSampleID:= FieldByName('L_HYDan').AsString;
      end;
    end;
  end;
  with gTiHuo[0] do
  begin
    EditLID.Text:= FID;
    EditCustomer.Text:= FCustomer;
    EditTruck.Text:= FTruck;
    EditStockName.Text:= FStockName;
    EditPlanWeight.Text:= FloatToStr(FValue);
    EditType.Text:= FType;
    GetSampleID(FStockName,nType,FCenterID);
    cbxSampleID.Text:= FSampleID;
  end;
  Result:=True;
end;

procedure TfFormSiteConfirm.ShowFormData;
var
  nIdx: Integer;
  nLocationID:string;
  nType:string;
begin
  with gBills[0] do
  begin
    EditLID.Text:= gBills[0].FID;
    EditCustomer.Text:= FCusName;
    EditTruck.Text:= gBills[0].FTruck;
    EditStockName.Text:= gBills[0].FStockName;
    EditPlanWeight.Text:= FloatToStr(gBills[0].FValue);
    if FType='0' then nType:='S' else nType:=FType;
    EditType.Text:= nType;
    GetSampleID(FStockName,nType,FCenterID);
  end;
  BtnOK.Enabled:=True;
end;

procedure TfFormSiteConfirm.GetSampleID(const nStockName,nType,nCenterID: string);
var nSQL:string;
    nIdx:Integer;
begin
  cbxSampleID.Properties.Items.Clear;
  nSQL := 'select IsNull(R_SerialNo,'''') as R_SerialNo,R_BatQuaStart,R_Date from %s a,%s b '+
          'where a.R_PID = b.P_ID and b.P_Stock= ''%s'' and b.P_Type=''%s'' '+
          'and ((R_CenterID=''%s'') or (R_CenterID='''') or (R_CenterID is null)) and R_BatValid=''%s'' ';
  nSQL := Format(nSQL,[sTable_StockRecord, sTable_StockParam, nStockName, nType, nCenterID, sFlag_Yes]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        cbxSampleID.Properties.Items.Add(Fields[0].AsString);
        Next;
      end;
      cbxSampleID.ItemIndex:=0;
    end;
  end;
end;

//获取批次量
function TfFormSiteConfirm.GetSampleTonnage(const nSampleID: string; var nBatQuaS,nBatQuaE:Double):Boolean;
var nSQL: string;
begin
  Result:=False;  
  nSQL := 'select R_BatQuaStart,R_BatQuaEnd,R_Date from %s where R_SerialNo= ''%s'' ';
  nSQL := Format(nSQL,[sTable_StockRecord, nSampleID]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      nBatQuaS:=Fields[0].AsFloat;
      nBatQuaE:=Fields[1].AsFloat;
      Result:=True;
    end;
  end;
end;

//更新试样编号有效性
function TfFormSiteConfirm.UpdateSampleValid(const nSampleID: string):Boolean;
var nSQL: string;
begin
  Result:=False;  
  nSQL := 'Update %s set R_BatValid=''%s'' where R_SerialNo= ''%s'' ';
  nSQL := Format(nSQL,[sTable_StockRecord, sFlag_No, nSampleID]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nSQL);
    FDM.ADOConn.CommitTrans;
    Result:=True;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('更新'+nSampleID+'有效性失败', '提示');
  end;
end;


function TfFormSiteConfirm.GetSumTonnage(const nSampleID: string):Double;//获取此试样编号已装吨数
var nStr:string;
begin
  nStr := 'Select sum(L_Value) From %s Where L_HYDan=''%s''';
  nStr := Format(nStr, [sTable_Bill, nSampleID]);
  with FDM.QueryTemp(nStr) do
  begin
    Result:=Fields[0].AsFloat;
  end;
end;

procedure TfFormSiteConfirm.ClearFormData;
var i:Integer;
begin
  for i:= 0 to ComponentCount-1 do
  begin
    if Components[i] is TcxTextEdit then
      (Components[i] as TcxTextEdit).Text:='';
    if Components[i] is TcxComboBox then
      (Components[i] as TcxComboBox).Text:='';
  end;
end;

//获取班别
function TfFormSiteConfirm.GetWorkOrder:string;
var
  nNow,nStr:string;
begin
  nNow := FormatDateTime('hh:mm:ss',Now);
  nStr := 'Select Z_WorkOrder From %s Where Z_StartTime < ''%s'' and Z_EndTime >= ''%s'' ';
  nStr := Format(nStr, [sTable_ZTWorkSet, nNow, nNow]);
  with FDM.QueryTemp(nStr) do
  begin
    Result:=Fields[0].AsString;
  end;
end;

procedure TfFormSiteConfirm.BtnOKClick(Sender: TObject);
var nFoutData,nStr:string;
    nPos:Integer;
    nPlanW,nBatQuaS,nBatQuaE:Double;
    nSQL:string;
begin
  FSumTon:=0.00;
  if Pos('孰料',EditStockName.Text)>0 then
  begin
    cbxSampleID.Text:='无';
  end else
  begin
    if cbxSampleID.ItemIndex<0 then
    begin
      ShowMsg('请选择试样编号', sHint);
      Exit;
    end;
    FSumTon:=GetSumTonnage(cbxSampleID.Text);
    cxLabel1.Caption:='已装吨数：'+Floattostr(FSumTon);
    if GetSampleTonnage(cbxSampleID.Text, nBatQuaS, nBatQuaE) then
    begin
      if FSumTon-nBatQuaS>0 then
      begin
        ShowMsg('试样编号['+cbxSampleID.Text+']已超量',sHint);
        if UpdateSampleValid(cbxSampleID.Text) then
          GetSampleID(EditStockName.Text,EditType.Text,gBills[0].FCenterID);
        Exit;
      end;

      nPlanW:=StrToFloat(EditPlanWeight.Text);
      FSumTon:=FSumTon+nPlanW;
      if nBatQuaS-FSumTon<=nBatQuaE then    //到预警量
      begin
        nStr:='试样编号['+cbxSampleID.Text+']已到预警量,是否继续保存？';
        if not QueryDlg(nStr, sAsk) then
        begin
          if UpdateSampleValid(cbxSampleID.Text) then
            GetSampleID(EditStockName.Text,EditType.Text,gBills[0].FCenterID);
          Exit;
        end;
      end;
      if FSumTon-nBatQuaS>0 then
      begin
        ShowMsg('试样编号['+cbxSampleID.Text+']已超量',sHint);
        Exit;
      end;
    end else
    begin
      ShowMsg('试样编号['+cbxSampleID.Text+']已失效',sHint);
      Exit;
    end;
  end;
  if BtnOK.Caption='修改' then
  begin
    nSQL := 'Update %s set L_HYDan=''%s'' where L_ID= ''%s'' ';
    nSQL := Format(nSQL,[sTable_Bill, cbxSampleID.Text, EditLID.Text]);
    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nSQL);
      FDM.ADOConn.CommitTrans;
      ShowMsg('修改'+EditLID.Text+'试样编号成功', sHint);
      PrintDaiBill(EditLID.Text, False);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('修改'+EditLID.Text+'信息失败', '提示');
      Exit;
    end;
  end else
  begin
    if cbxWorkSet.Text='' then
    begin
      cbxWorkSet.Focused;
      ShowMsg('请选择班别',sHint);
      Exit;
    end;
    if cbxKw.ItemIndex<0 then
    begin
      cbxKw.Focused;
      ShowMsg('请选择库位',sHint);
      Exit;
    end;
    with gBills[0] do
    begin
      FSampleID:= cbxSampleID.Text;
      FYSValid:= sFlag_No;
      FWorkOrder:= cbxWorkSet.Text;
      nPos:=Pos('.',cbxKw.Text);
      if (nPos>0) and (nPos<Length(cbxKw.Text)) then
      begin
        FKw:= Copy(cbxKw.Text,1,nPos-1);
        FLocationID:= Copy(cbxKw.Text,nPos+1,Length(cbxKw.Text)-nPos);
      end else
      begin
        ShowMsg('库位格式非法', sHint); Exit;
      end;
    end;
    if FStockType=1 then
    begin
      if SaveLadingBills(nFoutData,sFlag_TruckZT, gBills) then
      begin
        ShowMsg('袋装提货成功', sHint);
        PrintDaiBill(EditLID.Text, False);
      end;
    end else
    if FStockType=2 then
    begin
      if SaveLadingBills(nFoutData,sFlag_TruckFH, gBills) then
      begin
        ShowMsg('散装提货成功', sHint);
        PrintDaiBill(EditLID.Text, False);
      end;
    end else
    begin
      ShowMsg('提货失败，请重新刷卡',sHint);
      Exit;
    end;
  end;
  FStockType:=0;
  ClearFormData;
  EditCard.Text:='请刷卡';
  BtnOK.Caption:='提交';
  BtnOK.Enabled:=False;
end;

initialization
  gControlManager.RegCtrl(TfFormSiteConfirm, TfFormSiteConfirm.FormID);

end.
