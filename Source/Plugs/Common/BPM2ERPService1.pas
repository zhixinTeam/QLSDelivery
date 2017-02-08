// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://192.168.252.50/BPMToERP/BPM2ERPService.asmx?wsdl
// Encoding : utf-8
// Version  : 1.0
// (2016-07-13 12:10:12 - 1.33.2.5)
// ************************************************************************ //

unit BPM2ERPService1;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:int             - "http://www.w3.org/2001/XMLSchema"



  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // binding   : BPM2ERPServiceSoap
  // service   : BPM2ERPService
  // port      : BPM2ERPServiceSoap
  // URL       : http://192.168.0.51/QLSWEB/BPM2ERPService.asmx
  // ************************************************************************ //
  BPM2ERPServiceSoap = interface(IInvokable)
  ['{C98A3AEE-E399-3AF2-7C7B-1E48BBB664CF}']
    function  BPM2ERPInfo(const BusinessType: WideString; const XMlPrimaryKey: WideString; const XmlInfo: WideString): Integer; stdcall;
    function  EPS2ERPInfo(const BusinessType: WideString; const XMlPrimaryKey: WideString; const XmlInfo: WideString): Integer; stdcall;
    function  test: WideString; stdcall;
    function  WRZS2ERPInfo(const BusinessType: WideString; const XMlPrimaryKey: WideString; const XmlInfo: WideString): Integer; stdcall;
    function  WRZS2ERPInfoTEST(const BusinessType: WideString; const XMlPrimaryKey: WideString; const XmlInfo: WideString): WideString; stdcall;
  end;

function GetBPM2ERPServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): BPM2ERPServiceSoap;


implementation

function GetBPM2ERPServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): BPM2ERPServiceSoap;
const
  defWSDL = 'http://192.168.0.51/QLSWEB/BPM2ERPService.asmx?wsdl';
  defURL  = 'http://192.168.0.51/QLSWEB/BPM2ERPService.asmx';
  defSvc  = 'BPM2ERPService';
  defPrt  = 'BPM2ERPServiceSoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  RIO.HTTPWebNode.UseUTF8InHeader:=True;
  try
    Result := (RIO as BPM2ERPServiceSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(BPM2ERPServiceSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(BPM2ERPServiceSoap), 'http://tempuri.org/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(BPM2ERPServiceSoap), ioDocument);
end. 