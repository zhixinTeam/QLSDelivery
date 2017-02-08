{*******************************************************************************
  作者: dmzn@163.com 2012-9-1
  描述: 桌面刷卡器模拟各道刷卡
*******************************************************************************}
unit UFormCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient,
  StdCtrls;

type
  TfFormCard = class(TForm)
    IdClient1: TIdUDPClient;
    Label1: TLabel;
    BtnOK: TButton;
    BtnExit: TButton;
    ComPort1: TComPort;
    EditCard: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FHost: string;
    FPort: Integer;
    //服务端
    procedure ActionComPort(const nStop: Boolean);
    //串口处理
    function SendCard: Boolean;
    //发送卡号
  public
    { Public declarations }
  end;

function ShowCardForm: Boolean;
//入口函数

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UFormWait, USysConst, USysLoger, USmallFunc;

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
  gReaderItem: TReaderItem;
  //全局使用

//------------------------------------------------------------------------------
function ShowCardForm: Boolean;
begin
  with TfFormCard.Create(Application) do
  begin
    ActionComPort(False);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormCard, '桌面读卡器', nEvent);
end;

procedure TfFormCard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

//------------------------------------------------------------------------------
//Desc: 串口操作
procedure TfFormCard.ActionComPort(const nStop: Boolean);
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

    nIni := TIniFile.Create(gPath + sConfigFile);
    FHost := nIni.ReadString('Server', 'Host', '');
    FPort := nIni.ReadInteger('Server', 'Port', 1234);

    FreeAndNil(nIni);
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

    if gReaderItem.FPort <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;

procedure TfFormCard.ComPort1RxChar(Sender: TObject; Count: Integer);
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
    EditCard.Text := ParseCardNO(nStr, True); 

    FBuffer := '';
    BtnOKClick(nil);
    Exit;
  end;
end;

procedure TfFormCard.BtnOKClick(Sender: TObject);
begin
  if SendCard then ModalResult := mrOk;
end;

function TfFormCard.SendCard: Boolean;
begin
  Result := False;
  EditCard.Text := Trim(EditCard.Text);

  if EditCard.Text = '' then
  begin
    ShowMsg('请填写卡号', sHint);
  end;

  Visible := False;
  Application.MainForm.BringToFront;
  ShowWaitForm(Application.MainForm, '正在读卡', True);

  try
    IdClient1.Send(FHost, FPort, '+' + EditCard.Text);
    Result := IdClient1.ReceiveString(5 * 1000) = 'Y';
  except
    on E:Exception do
    begin
      WriteLog(E.Message);       
    end;
  end;

  if not Result then
  begin
    Visible := True;
    CloseWaitForm;
    ShowMsg('发送磁卡号失败', sHint);
  end;
end;

end.
