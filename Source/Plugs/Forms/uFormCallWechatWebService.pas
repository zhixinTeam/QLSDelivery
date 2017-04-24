unit uFormCallWechatWebService;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uRORemoteService, uROClient, uROWinInetHttpChannel,
  uROSOAPMessage;

type
  TFrmCallWechatWebService = class(TForm)
    rspmsg1: TROSOAPMessage;
    rwnthtpchnl1: TROWinInetHTTPChannel;
    rmtsrvc1: TRORemoteService;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function ExecuteWebAction(const nCmdId:Integer; var nData:string):boolean;
  end;

//var
//  FrmCallWechatWebService: TFrmCallWechatWebService;

implementation
uses
  SrvWebchat_Intf,UMITConst;
{$R *.dfm}

{ TForm1 }

function TFrmCallWechatWebService.ExecuteWebAction(const nCmdId:Integer;var nData: string): boolean;
var
  nService:ISrvWebchat;
  nXmlStr,ntmp:string;
begin
  Result := False;
  nXmlStr := '<?xml version="1.0" encoding="utf-8"?>'
      +'<Head>'
      +'  <Command>%d</Command>'
      +'  <Data>%s</Data>'
      +'  <ExtParam>%s</ExtParam>'
      +'  <RemoteUL/>'
      +'</Head>';
  nXmlStr := Format(nXmlStr,[nCmdId,nData,'']);
  nService := CoSrvWebchat.Create(rspmsg1,rwnthtpchnl1);
  ntmp := nXmlStr;
  try
    try
      Result := nService.Action('Bus_BusinessWebchat',nXmlStr);
      nData := nXmlStr;
    except
      on E:Exception do
      begin
        //ShowMessage(e.Message);
        
      end;
    end;
  finally
    nService := nil;
  end;
end;

procedure TFrmCallWechatWebService.FormCreate(Sender: TObject);
begin
  rwnthtpchnl1.TargetURL := gSysParam.FGPWSURL;
end;

//initialization
//  gFrmCallWechatWebService := TFrmCallWechatWebService.Create(nil);
//
//finalization
//  gFrmCallWechatWebService.Free;
end.
