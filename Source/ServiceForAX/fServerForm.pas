unit fServerForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  uROClient, uROPoweredByRemObjectsButton, uROClientIntf, uROServer,
  uROSOAPMessage, uROIndyHTTPServer, uROIndyTCPServer, IniFiles, USysLoger,
  ExtCtrls, AppEvnts, ComObj, ShellAPI;

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
    tmrRestart: TTimer;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChkModelClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure tmrRestartTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateAxData;
  public
    { Public declarations }
    gTime:string;
  end;

var
  ServerForm: TServerForm;
  ReStart:Boolean;

implementation
uses
  USysBusiness, uDM, UMITConst, UMgrParam, UMgrDBConn, USysDB;

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

//填充数据库参数
procedure FillAllDBParam;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    gParamManager.LoadParam(nList, ptDB);
    for nIdx:=0 to nList.Count - 1 do
      gDBConnManager.AddParam(gParamManager.GetDB(nList[nIdx])^);
    //xxxxx
  finally
    nList.Free;
  end;
end;

procedure TServerForm.FormCreate(Sender: TObject);
var
  myini:TIniFile;
  nPort:Integer;
begin
  myini:=TIniFile.Create('.\SetParam.ini');
  try
    nPort:=myini.ReadInteger('Param','Port',8099);
    gTime:=myini.ReadString('Param','Time','23:59');
  finally
    myini.Free;
  end;
  ROServer.Port:= nPort;
  ROServer.Active := true;
  lblport.Caption:='运行端口：'+inttostr(nPort);
  chkShowLog.Checked := True;
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create('.\Logs\');
  WriteLog('系统启动');
  if GetOnLineModel then ChkModel.Checked:=True else ChkModel.Checked:=False;
  tmrRestart.Interval := 60*1000;
  tmrRestart.Enabled := True;
  ReStart := False;

  Timer1.Interval := 10*1000;
  Timer1.Enabled := True;
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(gSysLoger);
end;

procedure TServerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //gDBConnManager.Disconnection();
  Application.Terminate;
  if ReStart then
    ShellExecute(Self.Handle, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
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

procedure TServerForm.tmrRestartTimer(Sender: TObject);
begin
  if FormatDateTime('hh:mm',Now)=gTime then
  begin
    ReStart := True;
    Close;
  end;
end;

procedure TServerForm.UpdateAxData;
var
  nStr: string;
  nXTProcessId,nRecid,nCompanyId:string;
  nResult:Boolean;
begin
  with DM do
  begin
    ADOCLoc.Close;
    ADOCLoc.ConnectionString:=LocalDBConn;
    ADOCLoc.Connected:=True;
    nStr:= 'select top 1 * from %s';
    nStr:= Format(nStr,[sTable_AxMsgList]);
    with qryExec do
    begin
      Close;
      sql.Text:=nStr;
      Open;
      if RecordCount < 1 then
      begin
        //WriteLog('UpdateAxData Result: No AxMsg');
        Exit;
      end;
      nXTProcessId:= FieldByName('AX_ProcessId').AsString;
      nRecid:= FieldByName('AX_Recid').AsString;
      nCompanyId:= FieldByName('AX_CompanyId').AsString;
    end;
  end;
  if nXTProcessId='EDS_0001' then
  begin
    nResult:= GetAXSalesOrder(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0002' then
  begin
    nResult:=  GetAXSalesOrdLine(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0003' then
  begin
    nResult:= GetAXSupAgreement(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0004' then
  begin
    nResult:= GetAXCreLimCust(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0005' then
  begin
    nResult:= GetAXCreLimCusCont(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0008' then
  begin
    nResult:= GetAXSalesContract(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0009' then
  begin
    nResult:= GetAXVehicleNo(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDS_0010' then
  begin
    nResult:= GetAXSalesContLine(nRecid,nCompanyId);
  end else
  if nXTProcessId='EPS_0001' then
  begin
    nResult:= GetAXPurOrder(nRecid,nCompanyId);
  end else
  if nXTProcessId='EPS_0002' then
  begin
    nResult:= GetAXPurOrdLine(nRecid,nCompanyId);
  end else
  {if nXTProcessId='EDP_0004' then
  begin
      nResult:=0;
  end else
  if nXTProcessId='EDP_0005' then
  begin
      nResult:=0;
  end else
  if nXTProcessId='EDB_0003' then
  begin
      nResult:=0;
  end else
  if nXTProcessId='EDB_0004' then
  begin
      nResult:=0;
  end else
  if nXTProcessId='EDB_0005' then
  begin
      nResult:=0;
  end else}
  if nXTProcessId='EDB_0006' then
  begin
    nResult:= GetAXCustomer(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDB_0007' then
  begin
    nResult:= GetAXProviders(nRecid,nCompanyId);
  end else
  if nXTProcessId='EDB_0008' then
  begin
    nResult:= GetAXMaterails(nRecid,nCompanyId);
  end;{ else
  if nXTProcessId='EWS_0001' then
  begin
    if UpdateYKAmount(nRecid,nCompanyId) then
      Result:=0
    else
      Result:=-1;
  end else
  if nXTProcessId='EDS_0011' then
  begin
    if GetThInfo(nRecid,nCompanyId) then
      Result:=0
    else
      Result:=-1;
  end else
  if nXTProcessId='EPS_0003' then
  begin
    if GetPurchInfo(nRecid,nCompanyId) then
      Result:=0
    else
      Result:=-1;
  end; }
  if nResult then
  with DM do
  try
    ADOCLoc.Close;
    ADOCLoc.ConnectionString:=LocalDBConn;
    ADOCLoc.Connected:=True;
    ADOCLoc.BeginTrans;
    nStr := 'delete from %s where AX_Recid=''%s'' and AX_ProcessId = ''%s'' ';
    nStr := Format(nStr,[sTable_AxMsgList,nRecid,nXTProcessId]);
    qryExec.SQL.Text:=nStr;
    qryExec.ExecSQL;
    qryExec.Close;
    ADOCLoc.CommitTrans;
  except
    if ADOCLoc.InTransaction then
      ADOCLoc.RollbackTrans;
    WriteLog('UpdateAxData Delete Error: RollbackTrans');
  end;
end;


procedure TServerForm.Timer1Timer(Sender: TObject);
var
  nInit:Integer;
begin
  Timer1.Enabled:=False;
  nInit:=GetTickCount;
  try
    UpdateAxData;
  finally
    Timer1.Enabled:=True;
    WriteLog('UpdateAxData: '+IntToStr(GetTickCount-nInit)+'ms');
  end;
end;

end.
