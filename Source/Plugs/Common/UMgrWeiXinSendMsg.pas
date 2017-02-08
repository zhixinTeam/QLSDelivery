{
   by lih 2016-06-02
   功能：微信发送消息
}
unit UMgrWeiXinSendMsg;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, revicewstest;

type
  TWeiXinSender = class;
  TWeiXinSendThread = class(TThread)
  private
    FOwner: TWeiXinSender;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FNumWeiXinSendMsg: Integer;
    //计时计数
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    procedure DoNewSendMsg(setTime:string); //
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TWeiXinSender);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TWeiXinSender = class(TObject)
  private
    FThread: TWeiXinSendThread;
    //扫描线程
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
  end;

var
  gWeiXinSender: TWeiXinSender = nil;
  //全局使用

implementation
procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TWeiXinSender, '微信消息推送', nMsg);
end;

constructor TWeiXinSender.Create;
begin
  FThread := nil;
end;

destructor TWeiXinSender.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWeiXinSender.Start;
begin
  if not Assigned(FThread) then
    FThread := TWeiXinSendThread.Create(Self);
  FThread.Wakeup;
end;

procedure TWeiXinSender.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//------------------------------------------------------------------------------
constructor TWeiXinSendThread.Create(AOwner: TWeiXinSender);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60*1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_WeiXinSend_Sync');
  //process sync
end;

destructor TWeiXinSendThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;
  
  FSyncLock.Free;
  inherited;
end;

procedure TWeiXinSendThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TWeiXinSendThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWeiXinSendThread.Execute;
var nErr: Integer;
    nInit: Int64;
    nSQL:string;
begin
  FNumWeiXinSendMsg    := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumWeiXinSendMsg);
    //inc counter

    if FNumWeiXinSendMsg >= 60 then
      FNumWeiXinSendMsg := 0;
    //微信消息推送: 1次/小时

    if (FNumWeiXinSendMsg <> 0) then Continue;
    //无业务可做

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行                                                          
    
    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;
      
      if FNumWeiXinSendMsg = 0 then
      begin
        nSQL:='select D_Value from Sys_Dict where D_Name=''ReportSendTime'' ';
        with gDBConnManager.WorkerQuery(FDBConn,nSQL) do
        if RecordCount>0 then
        begin
          if (FormatDateTime('hh',Now)=Copy(Fields[0].AsString,1,2)) then
          begin
            WriteLog('微信消息推送数据...');
            nInit := GetTickCount;
            DoNewSendMsg(Fields[0].AsString);
            WriteLog('微信消息推送完毕,耗时: ' + IntToStr(GetTickCount - nInit));
          end;
        end;
      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2016-06-03
//lih: 读取数据发送微信消息
procedure TWeiXinSendThread.DoNewSendMsg(setTime:string);
var
  nSql,nStr: string;
  nRID:string;
  StartDate,EndDate:TDateTime;
  nStartDate,nEndDate:string;
  Factory,ToUser:string;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  errcode,errmsg:string;
  i:Integer;
begin
  try
    nStartDate:=FormatDateTime('yyyy-mm-dd',IncDay(Now,-1))+' '+copy(setTime,1,2)+':00:00';
    nEndDate:=FormatDateTime('yyyy-mm-dd',Now)+' '+copy(setTime,1,2)+'00:00';
    nSql:='select C_ID from S_Customer where C_IsBind=''1'' ';
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    if RecordCount>0 then
    begin
      First;
      while not Eof do
      begin
        FListA.Add(Fields[0].AsString);
        Next;
      end;
    end;
    for i:=0 to FListA.Count-1 do
    begin
      nSql := 'Select b.C_Factory,b.C_ToUser,a.L_StockNo,' +
              'a.L_StockName,a.L_Value,a.L_Price From %s a %s b' +
              'Where a.L_CusID=b.C_ID and a.L_CusID= %s '+
              'and a.L_Status=''O'' and L_OutFact>''%s'' and L_OutFact<=''%s'' ';
      nSql := Format(nSql, [sTable_Bill,sTable_Customer,FListA[i],nStartDate,nEndDate]);
      {$IFDEF DEBUG}
      WriteLog(nSql);
      {$ENDIF}
      nStr:='';
      with gDBConnManager.WorkerQuery(FDBConn, nSql) do
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          Factory:=Fields[0].AsString;
          ToUser:=Fields[1].AsString;
          nStr:=nStr+'<Item>'+
                '<StockNo>'+Fields[2].AsString+'</StockNo>'+
                '<StockName>'+Fields[3].AsString+'</StockName>'+
                '<Count>'+Fields[4].AsString+'</Count>'+
                '<Qty>'+Fields[5].AsString+'</Qty>'+
                '</Item>';
          Next;
        end;
      end;
      nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
            '<DATA>'+
            '<head>'+
            '<Factory>'+Factory+'</Factory>'+
            '<ToUser>'+ToUser+'</ToUser>'+
            '<MsgType>3</MsgType>'+
            '</head>'+
            '<Items>'+
            nStr+
            '</Items>'+
             '<remark>'+
                 '<StartDate>'+nStartDate+'</StartDate>'+
                 '<EndDate>'+nEndDate+'</EndDate>'+
             '</remark>'+
            '</DATA>';
      {$IFDEF DEBUG}
      WriteLog(nStr);
      {$ENDIF}
      wxservice:=GetReviceWS(true,'',nil);
      nMsg:=wxservice.mainfuncs('send_event_msg',nStr);
      {$IFDEF DEBUG}
      WriteLog(nMsg);
      {$ENDIF}
      FXMLBuilder.ReadFromString(nMsg);
      with FXMLBuilder do
      begin
        nhead:=Root.FindNode('head');
        if Assigned(nhead) then
        begin
          errcode:=nhead.NodebyName('errcode').ValueAsString;
          errmsg:=nhead.NodebyName('errmsg').ValueAsString;
          if errcode='0' then
          begin
            {$IFDEF DEBUG}
            WriteLog(FListA[i]+'推送微信消息成功');
            {$ENDIF}
          end;
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

initialization
  gWeiXinSender := nil;
finalization
  FreeAndNil(gWeiXinSender);
end.
 