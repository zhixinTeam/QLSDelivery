unit fServerForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  uROClient, uROPoweredByRemObjectsButton, uROClientIntf, uROServer,
  uROSOAPMessage, uROIndyHTTPServer, uROIndyTCPServer, IniFiles, USysLoger,
  ExtCtrls, AppEvnts, ComObj;

type
  TServerForm = class(TForm)
    ROMessage: TROSOAPMessage;
    ROServer: TROIndyHTTPServer;
    lblport: TLabel;
    mmo1: TMemo;
    chkShowLog: TCheckBox;
    ChkModel: TCheckBox;
    ApplicationEvents1: TApplicationEvents;
    BtnConn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChkModelClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;

implementation
uses
  USysBusiness, uDM;

{$R *.dfm}
procedure WriteLog(const nEvent: string);
begin
  with ServerForm do
  begin
    if chkShowLog.Checked then
    begin
      if mmo1.Lines.Count > 50 then mmo1.Lines.Clear;
      mmo1.Lines.Add('['+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+']'+nEvent);
    end;
  end;
  gSysLoger.AddLog(TServerForm, 'WebService', nEvent);
end;

procedure TServerForm.FormCreate(Sender: TObject);
var
  myini:TIniFile;
  nPort:Integer;
begin
  myini:=TIniFile.Create('.\SetParam.ini');
  try
    nPort:=myini.ReadInteger('Param','Port',8099);
  finally
    myini.Free;
  end;
  ROServer.Port:= nPort;
  ROServer.Active := true;
  lblport.Caption:='运行端口：'+inttostr(nPort);
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create('.\Logs\');
  WriteLog('系统启动');
  if GetOnLineModel then ChkModel.Checked:=True else ChkModel.Checked:=False;
  
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(gSysLoger);
end;

procedure TServerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteLog('系统关闭');
end;


procedure TServerForm.ChkModelClick(Sender: TObject);
begin
  if ChkModel.Checked then
    SetOnLineModel(True)
  else
    SetOnLineModel(False);
end;

procedure TServerForm.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
var
  I: integer;
begin
  //请执行如下命令或者其他方法强制产生数据库连接断开情况，以触发如下异常。
  //net stop MsSqlServer
  //net start MsSqlServer
  if (E is EOleException) and ((E as EOleException).ErrorCode= -2147467259) then
  begin
    with DM do
    begin
      ADOCRem.Connected := False;
      try
        ADOCRem.Connected := True;
      except
        On E2: Exception do
        begin
          WriteLog('重连远程数据库发生错误：'#13 + E2.Message);
        end;
      end;
    end;

    with DM do
    begin
      ADOCLoc.Connected := False;
      try
        ADOCLoc.Connected := True;
      except
        On E2: Exception do
        begin
          WriteLog('重连本地数据库发生错误：'#13 + E2.Message);
        end;
      end;
    end;
  end;
end;

end.
