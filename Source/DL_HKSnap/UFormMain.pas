{*******************************************************************************
  作者: dmzn@163.com 2017-10-20
  描述: 海康威视抓拍及LED引导屏服务
*******************************************************************************}
unit UFormMain;

{.$DEFINE DEBUG}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdGlobal, UTrayIcon, UBase64, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, ComCtrls, StdCtrls, IdContext, ExtCtrls;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnTest: TButton;
    Label1: TLabel;
    EditCard: TComboBox;
    Label2: TLabel;
    EditText: TEdit;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    EditSnap: TComboBox;
    Button1: TButton;
    Button2: TButton;
    SnapView1: TPanel;
    BtnConn: TButton;
    SnapView2: TPanel;
    SnapView3: TPanel;
    SnapView4: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnTestClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnConnClick(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*状态栏图标*}
    FListA: TStrings;
    //文本资源
    procedure ShowLog(const nStr: string);
    //显示日志
    procedure DoExecute(const nContext: TIdContext);
    //执行动作
  public
    { Public declarations }
    procedure SaveSnapTruck(const nIP, nTruck, nPicName: String);
    //保存抓拍
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, USysLoger, UMgrVoice, UMgrRemoteSnap,
  UHKDoorLED, UHKDoorSnap, UDataModule, UFormConn, DB, USysDB;

var
  gPath: string;               //程序路径
  gCompany: string = '';       //公司名称

resourcestring
  sHint               = '提示';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'HKSnap';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '抓拍服务主单元', nEvent);
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Application.Title;
  FTrayIcon.Visible := True;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  FDM.ADOConn.Open;
  //数据库连接

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FListA := TStringList.Create;
  gHKCardManager := THKCardManager.Create;
  gHKCardManager.LoadConfig(gPath + 'HKDoorLED.XML');
  gHKCardManager.GetCardList(EditCard.Items);

  gHKDoorSnapManager := THKDoorSnapManager.Create;
  gHKDoorSnapManager.LoadConfig(gPath + 'HKDoorSnap.XML');
  gHKDoorSnapManager.GetDoorSnapList(EditSnap.Items);

end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Checked);

    if nIni.ReadString('Config', 'Port', '') = '' then
      nIni.WriteString('Config', 'Port', EditPort.Text);
    //xxxxx

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FListA.Free;
  //free obj
  Button2.Click;
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnTest.Enabled := CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

 if CheckSrv.Checked then
         gHKCardManager.StartDiaplay
    else gHKCardManager.StopDiaplay;

 if CheckSrv.Checked then
         Button1.Click
    else Button2.Click;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nInt: Integer;
    nBuf: TIdBytes;
    nBase: THKDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeHKBase, False);
    BytesToRaw(nBuf, nBase, cSizeHKBase);

    case nBase.FCommand of
     cHKCmd_Display :
      begin
        Socket.ReadBytes(nBuf, nBase.FDataLen, False);
        FListA.Text := DecodeBase64(BytesToString(nBuf));

        if IsNumber(FListA.Values['Color'], False) then
             nInt := StrToInt(FListA.Values['Color'])
        else nInt := 2;

        with FListA do
          gHKCardManager.DisplayText(Values['Card'], Values['Text'], nInt)
        //xxxxx
      end;
    end;
  end;
end;

//Desc: test
procedure TfFormMain.BtnTestClick(Sender: TObject);
begin
  if EditCard.ItemIndex < 0 then
  begin
    ShowMsg('请选择屏卡', sHint);
    Exit;
  end;

  with EditCard do
    gHKCardManager.DisplayText(Items.Names[ItemIndex], EditText.Text, 2);
  //xxxxx
end;

procedure TfFormMain.Button1Click(Sender: TObject);
begin
  gHKDoorSnapManager.StartSnap;
end;

procedure TfFormMain.Button2Click(Sender: TObject);
begin
  gHKDoorSnapManager.StopSnap;
end;

//Desc: 数据库配置
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //数据库连接
  end;
end;

procedure TfFormMain.SaveSnapTruck(const nIP, nTruck, nPicName: String);
var nStr,nID: string;
    nDel: Boolean;
begin
  nID := gHKDoorSnapManager.GetDoorID(nIP);

  nStr := 'Select R_ID From %s Where S_ID=''%s'' order by R_ID';
  nStr := Format(nStr, [sTable_SnapTruck, nID]);

  if FDM.SQLQuery(nStr, FDM.SQLQuery1).RecordCount > 5 then
    nDel := True
  else
    nDel := False;

  if nDel then
  begin
    nStr := 'Delete From %s Where S_ID=''%s'' ' +
            ' and R_ID = (Select top 1 R_ID From %s Where S_ID=''%s'')';
    nStr := Format(nStr, [sTable_SnapTruck, nID,
                          sTable_SnapTruck, nID]);
    try
      FDM.SQLExecute(nStr,FDM.SQLQuery1);
    except
    end;
  end;

  nStr := 'insert into %s(S_ID,S_Truck,S_Date,S_PicName) values(''%s'',''%s'',''%s'',''%s'')';
  nStr := Format(nStr,[sTable_SnapTruck,nID,nTruck,DateTime2Str(Now),nPicName]);
  try
    FDM.SQLExecute(nStr,FDM.SQLQuery1);
  except
  end;
end;

end.
