{*******************************************************************************
  作者: dmzn@163.com 2012-5-3
  描述: 用户自助查询
*******************************************************************************}
unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, ExtCtrls, CPort;

type
  TfFormMain = class(TForm)
    LabelStock: TcxLabel;
    LabelTruck: TcxLabel;
    LabelHint: TcxLabel;
    ComPort1: TComPort;
    Timer1: TTimer;
    Panel1: TPanel;
    LabelNum: TcxLabel;
    LabelDec: TcxLabel;
    LabelTon: TcxLabel;
    LabelBill: TcxLabel;
    LabelOrder: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure LabelTruckDblClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FLastCard: string;
    FLastQuery: Int64;
    //上次查询
    FTimeCounter: Integer;
    //计时
    procedure ActionComPort(const nStop: Boolean);
    //串口处理
    procedure QueryCard(const nCard: string);
    //查询卡信息
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, CPortTypes, USysLoger, USysDB, USmallFunc, UDataModule,
  UFormConn;

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

var
  gPath: string;
  gReaderItem: TReaderItem;
  //全局使用

resourcestring
  sHint       = '提示';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '自助主窗体', nEvent);
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogSync := False;

  ShowConnectDBSetupForm(ConnCallBack);
  ShowCursor(False);
  
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //数据库连接

  FLastQuery := 0;
  FLastCard := '';
  FTimeCounter := 0;
  ActionComPort(False);
  //启动读头
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

procedure TfFormMain.LabelTruckDblClick(Sender: TObject);
begin
  ShowCursor(True);
  if QueryDlg('确定要退出系统吗?', sHint) then
       Close
  else ShowCursor(False);
end;

//Desc: 串口操作
procedure TfFormMain.ActionComPort(const nStop: Boolean);
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

    ComPort1.Open;
  end;
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  if FTimeCounter <= 0 then
  begin
    Timer1.Enabled := False;
    LabelDec.Caption := '';

    LabelBill.Caption := '交货单号:';
    LabelTruck.Caption := '车牌号码:';
    LabelOrder.Caption := '销售订单:';
    LabelStock.Caption := '品种名称:';
    LabelNum.Caption := '客户名称:';
    LabelTon.Caption := '提货数量:';
    LabelHint.Caption := '请您刷卡';
  end else
  begin
    LabelDec.Caption := IntToStr(FTimeCounter) + ' ';
  end;

  Dec(FTimeCounter);
end;

procedure TfFormMain.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
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
    FBuffer := '';
    QueryCard(ParseCardNO(nStr, True));
    Exit;
  end;
end;

//Date: 2012-5-3
//Parm: 卡号
//Desc: 查询nCard信息
procedure TfFormMain.QueryCard(const nCard: string);
var nVal: Double;
    nStr,nStock,nBill,nVip,nLine,nPoundQueue: string;
    nDate: TDateTime;
begin
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  //close screen saver

  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    LabelDec.Caption := '请不要频繁刷卡';
    Exit;
  end;
  
  try
    FTimeCounter := 10;
    Timer1.Enabled := True;

    nStr := 'Select * From %s Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelDec.Caption := '磁卡号无效';
        Exit;
      end;

      nVal := 0;
      First;

      while not Eof do
      begin
        if FieldByName('L_Value').AsFloat > nVal then
        begin
          nBill := FieldByName('L_ID').AsString;
          nVal := FieldByName('L_Value').AsFloat;
        end;

        Next;
      end;

      First;
      while not Eof do
      begin
        if FieldByName('L_ID').AsString = nBill then
          Break;
        Next;
      end;

      nBill :=  FieldByName('L_ID').AsString;
      nStock := FieldByName('L_StockNo').AsString;
      nVip := FieldByName('L_IsVip').AsString;

      LabelBill.Caption := '交货单号: ' + FieldByName('L_ID').AsString;
      LabelOrder.Caption := '销售订单: ' + FieldByName('L_ZhiKa').AsString;
      LabelTruck.Caption := '车牌号码: ' + FieldByName('L_Truck').AsString;
      LabelStock.Caption := '品种名称: ' + FieldByName('L_StockName').AsString;
      LabelTon.Caption := '提货数量: ' + FieldByName('L_Value').AsString + '吨';
      LabelNum.Caption := '客户名称：' + FieldByName('L_CusName').AsString;
    end;

    //--------------------------------------------------------------------------
    {nStr := 'Select Count(*) From %s ' +
            'Where Z_StockNo=''%s'' And Z_Valid=''%s'' And Z_VipLine=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nStock, sFlag_Yes,nVip]);

    with FDM.SQLQuery(nStr) do
    begin
      LabelNum.Caption := '开放道数: ' + Fields[0].AsString + '个';
    end; }

    //--------------------------------------------------------------------------
    nStr := 'Select T_line,T_InTime,T_Valid From %s ZT ' +
             'Where T_Bill=''%s'' ';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '您的车辆已无效.';
        Exit;
      end;

      if FieldByName('T_Valid').AsString <> sFlag_Yes then
      begin
        LabelHint.Caption := '您已超时出队,请到服务大厅办理入队手续.';
        Exit;
      end;

      nDate := FieldByName('T_InTime').AsDateTime;
      //进队时间

      nLine := FieldByName('T_Line').AsString;
      //通道号
    end;

    if nLine <> '' then
    begin
      nStr := 'Select Z_Valid,Z_Name From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
        LabelHint.Caption := '您所在的通道已关闭，请联系调度人员.';
        Exit;
        end else
        begin
        LabelHint.Caption := '系统内您的车辆已入厂,请到' + FieldByName('Z_Name').AsString + '提货.';
        Exit;
        end;
      end;
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$PQ', sFlag_PoundQueue)]);

    with FDM.SQLQuery(nStr) do
    begin
      if FieldByName('D_Value').AsString = 'Y' then
      nPoundQueue := 'Y';
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$DQ', sFlag_DelayQueue)]);

    with FDM.SQLQuery(nStr) do
    begin
    if  FieldByName('D_Value').AsString = 'Y' then
      begin
        if nPoundQueue <> 'Y' then
        begin
          nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                  'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
        end else
        begin
          nStr := ' Select Count(*) From $TB left join S_PoundLog on S_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                  ' Where T_InQueue Is Null And ' +
                  ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
        end;
      end else
      begin
        nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
      end;

      nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
            MI('$Yes', sFlag_Yes), MI('$SN', nStock),
            MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
    end;
    //xxxxx

    with FDM.SQLQuery(nStr) do
    begin
      if Fields[0].AsInteger < 1 then
      begin
        nStr := '您已排到队首,请关注大屏调度准备进厂.';
        LabelHint.Caption := nStr;
      end else
      begin
        nStr := '您前面还有【 %d 】辆车等待进厂';
        LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
      end;
    end;

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //已成功卡号
  except
    on E: Exception do
    begin
      ShowMsg('查询失败', sHint);
      WriteLog(E.Message);
    end;
  end;

  FDM.ADOConn.Connected := False;
end;


end.
