unit UWifiManager;

interface

uses
  FMX.Helpers.Android, Androidapi.Helpers,

  System.SysUtils,
  AndroidApi.JNI.App,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText;

type
  JWifiManagerClass = interface(JObjectClass)
  ['{69F35EA7-3EB9-48AA-B7FC-4FFD0E7D712F}']
    function _GetACTION_PICK_WIFI_NETWORK: JString;
    function _GetEXTRA_WIFI_INFO: JString;
    function _GetWIFI_STATE_CHANGED_ACTION: JString;
    property ACTION_PICK_WIFI_NETWORK: JString read _GetACTION_PICK_WIFI_NETWORK;
    property EXTRA_WIFI_INFO: JString read _GetEXTRA_WIFI_INFO;
    property WIFI_STATE_CHANGED_ACTION: JString read _GetWIFI_STATE_CHANGED_ACTION;
  end;

  [JavaSignature('android/net/wifi/WifiInfo')]
  JWifiInfo = interface(JObject)
  ['{4F09E865-DB04-4E64-8C81-AEFB36DABC45}']
    function getBSSID:jString; cdecl;
    function getHiddenSSID:Boolean; cdecl;
    function getIpAddress:Integer; cdecl;
    function getLinkSpeed:integer; cdecl;
    function getMacAddress:JString; cdecl;
    function getNetworkId:integer; cdecl;
    function getRssi:integer; cdecl;
    function GetSSID:jString; cdecl;
  end;

  JWifiInfoClass = interface(JObjectClass)
  ['{2B1CE79F-DE4A-40D9-BB2E-7F9F118D8C08}']
    function _GetLINK_SPEED_UNITS:JString;
    property LINK_SPEED_UNITS: JString read _GetLINK_SPEED_UNITS;
  end;

  TJWifiInfo= class(TJavaGenericImport<JWifiInfoClass, JWifiInfo>) end;

  [JavaSignature('android/net/wifi/WifiManager')]
  JWifiManager = interface(JObject)
  ['{DA7107B9-1FAD-4A9E-AA09-8D5B84614E60}']
    function isWifiEnabled:Boolean;cdecl;
    function setWifiEnabled(enabled:Boolean):Boolean; cdecl;
    function getConnectionInfo :JWifiInfo; cdecl;
    function getWifiState :Integer; cdecl;
    function disconnect :Boolean; cdecl;
  end;

  TJWifiManager = class(TJavaGenericImport<JWifiManagerClass, JWifiManager>) end;

  function GetWiFiLocalIP: string;
  function GetWiFiLocalMAC: string;
implementation

function GetWiFiManager: JWifiManager;
var ConnectivityServiceNative: JObject;
begin
  ConnectivityServiceNative := SharedActivityContext.getSystemService(TJContext.JavaClass.WIFI_SERVICE);
  if not Assigned(ConnectivityServiceNative) then
    raise Exception.Create('Could not locate Connectivity Service');
  Result := TJWifiManager.Wrap(
    (ConnectivityServiceNative as ILocalObject).GetObjectID);
  if not Assigned(Result) then
    raise Exception.Create('Could not access Connectivity Manager');
end;

function IntToIp(nInt: Integer) :String;
begin
  Result := IntToStr(nInt and $FF) + '.' + IntToStr((nInt shr 8) and $FF)
            + '.' + IntToStr((nInt shr 16) and $FF) + '.'
            + IntToStr((nInt shr 24) and $FF);
end;

function GetWiFiLocalIP: string;
var WiFiManager: JWifiManager;
    info: JWiFiInfo;
    ip: Integer;
begin
  WifiManager := GetWiFiManager;
  info := WifiManager.getConnectionInfo;  // <- Crash without exception
  ip := info.getIpAddress;
  Result := IntToIp(ip)
end;

function GetWiFiLocalMAC: string;
var WiFiManager: JWifiManager;
    info: JWiFiInfo;
    mac: JString;
begin
  WifiManager := GetWiFiManager;
  info := WifiManager.getConnectionInfo;  // <- Crash without exception
  mac := info.getMacAddress;
  Result := JStringToString(mac);
end;

end.
