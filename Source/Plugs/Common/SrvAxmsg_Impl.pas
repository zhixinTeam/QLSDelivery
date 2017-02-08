unit SrvAxmsg_Impl;

{$I Link.Inc}

interface

uses
  Classes, SysUtils, uROServer, MIT_Service_Intf;

type
  { TSrvAxmsg }
  TSrvAxmsg = class(TRORemotable, ISrvAxmsg)
  private
    FEvent: string;
    FTaskID: Int64;
    procedure WriteLog(const nLog: string);
  protected
    { ISrvAxmsg methods }
    function DL2WRZSINFO(const BusinessType: Utf8String; const XMLPrimaryKey: Utf8String): Boolean;
  end;

implementation

uses
  UROModule, UBusinessWorker, UTaskMonitor, USysLoger, UMITConst;

procedure TSrvAxmsg.WriteLog(const nLog: string);
begin
  gSysLoger.AddLog(TSrvAxmsg, 'AX消息服务对象', nLog);
end;

{ SrvAxmsg }
function TSrvAxmsg.DL2WRZSINFO(const BusinessType: Utf8String; const XMLPrimaryKey: Utf8String): Boolean;
begin
  result:=True;
end;

end.
