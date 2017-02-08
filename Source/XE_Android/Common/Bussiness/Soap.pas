// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://127.0.0.1:8082/Soap?service=SrvBusiness
//  >Import : http://127.0.0.1:8082/Soap?service=SrvBusiness>0
// Encoding : UTF-8
// Version  : 1.0
// (2015/8/11 18:09:27 - - $Rev: 56641 $)
// ************************************************************************ //

unit Soap;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns,
     Xml.adomxmldom;         //缺少这个引用，会导致No selected DOM Vendor

const
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  SrvBusiness___Action = class;                 { "http://tempuri.org/"[Lit][GblElm] }
  SrvBusiness___ActionResponse = class;         { "http://tempuri.org/"[Lit][GblElm] }



  // ************************************************************************ //
  // XML       : SrvBusiness___Action, global, <element>
  // Namespace : http://tempuri.org/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SrvBusiness___Action = class(TRemotable)
  private
    FnFunName: string;
    FnData: string;
  public
    constructor Create; override;
  published
    property nFunName: string  read FnFunName write FnFunName;
    property nData:    string  read FnData write FnData;
  end;



  // ************************************************************************ //
  // XML       : SrvBusiness___ActionResponse, global, <element>
  // Namespace : http://tempuri.org/
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SrvBusiness___ActionResponse = class(TRemotable)
  private
    FResult: Boolean;
    FnData: string;
  public
    constructor Create; override;
  published
    property Result: Boolean  read FResult write FResult;
    property nData:  string   read FnData write FnData;
  end;


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: urn:MIT_Service-SrvBusiness#Action
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : SrvBusinessBinding
  // service   : SrvBusiness
  // port      : SrvBusinessPort
  // URL       : http://127.0.0.1:8082/Soap?service=SrvBusiness
  // ************************************************************************ //
  SrvBusiness = interface(IInvokable)
  ['{BEA8F060-CF26-6E14-8D77-F4AFC429C6C3}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  Action(const parameters: SrvBusiness___Action): SrvBusiness___ActionResponse; stdcall;
  end;

function GetSrvBusiness(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SrvBusiness;


implementation
  uses SysUtils;

function GetSrvBusiness(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SrvBusiness;
const
  defWSDL = 'http://127.0.0.1:8082/Soap?service=SrvBusiness';
  defURL  = 'http://127.0.0.1:8082/Soap?service=SrvBusiness';
  defSvc  = 'SrvBusiness';
  defPrt  = 'SrvBusinessPort';
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
  try
    Result := (RIO as SrvBusiness);
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


constructor SrvBusiness___Action.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

constructor SrvBusiness___ActionResponse.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

initialization
  { SrvBusiness }
  InvRegistry.RegisterInterface(TypeInfo(SrvBusiness), 'http://tempuri.org/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SrvBusiness), 'urn:MIT_Service-SrvBusiness#Action');
  InvRegistry.RegisterInvokeOptions(TypeInfo(SrvBusiness), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(SrvBusiness), ioLiteral);
  RemClassRegistry.RegisterXSClass(SrvBusiness___Action, 'http://tempuri.org/', 'SrvBusiness___Action');
  RemClassRegistry.RegisterSerializeOptions(SrvBusiness___Action, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SrvBusiness___ActionResponse, 'http://tempuri.org/', 'SrvBusiness___ActionResponse');
  RemClassRegistry.RegisterSerializeOptions(SrvBusiness___ActionResponse, [xoLiteralParam]);

end.