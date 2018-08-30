{*******************************************************************************
  作者: juner11212436@163.com 2018-07-04
  描述: OPC通道管理器
*******************************************************************************}
unit UMgrdOPCTunnels;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, CPort, CPortTypes, IdComponent,
  IdTCPConnection, IdTCPClient, IdGlobal, IdSocketHandle, NativeXml, ULibFun,
  UWaitItem, USysLoger;

type

  PPTOPCItem = ^TPTOPCItem;

  TPTOPCItem = record
    FID: string;                     //标识
    FName: string;                   //名称
    FEnable: string;                 //是否启用
    FServer: string;                 //服务器
    FComputer: string;               //服务器所在计算机
    FStartTag: string;               //启动标记
    FStartOrder: string;             //启动命令
    FSetValTag: string;              //预设值标记
    FImpDataTag: string;             //实时数据标记
    FStopTag: string;                //停止标记
    FStopOrder: string;              //停止命令
    FOptions: TStrings;              //附加参数
  end;

  TOPCTunnelManager = class(TObject)
  private
    FTunnels: TList;
    //通道列表
  protected
    procedure ClearList(const nFree: Boolean);
    //清理资源
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    function GetTunnel(const nID: string): PPTOPCItem;
    //检索数据
    property Tunnels: TList read FTunnels;
    //属性相关
  end;

var
  gOPCTunnelManager: TOPCTunnelManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TOPCTunnelManager, 'OPC通道管理', nEvent);
end;

constructor TOPCTunnelManager.Create;
begin
  FTunnels := TList.Create;
end;

destructor TOPCTunnelManager.Destroy;
begin
  ClearList(True);
  inherited;
end;

//Date: 2014-06-12
//Parm: 是否释放
//Desc: 清理列表资源
procedure TOPCTunnelManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nTunnel: PPTOPCItem;
begin
  for nIdx:=FTunnels.Count - 1 downto 0 do
  begin
    nTunnel := FTunnels[nIdx];
    FreeAndNil(nTunnel.FOptions);

    Dispose(nTunnel);
    FTunnels.Delete(nIdx);
  end;

  if nFree then
  begin
    FTunnels.Free;
  end;
end;

//Date: 2014-06-12
//Parm: 配置文件
//Desc: 载入nFile配置
procedure TOPCTunnelManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nTunnel: PPTOPCItem;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.FindNode('tunnels');
    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nTunnel);
      FTunnels.Add(nTunnel);
      FillChar(nTunnel^, SizeOf(TPTOPCItem), #0);

      nStr := NodeByName('server').ValueAsString;
      if nStr = '' then
        raise Exception.Create(Format('通道[ %s.server ]无效.', [nTunnel.FName]));
      //xxxxxx
      nTunnel.FServer := nStr;

      with nTunnel^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FEnable := NodeByName('enable').ValueAsString;
        FComputer := NodeByName('computer').ValueAsString;
        FStartTag := NodeByName('starttag').ValueAsString;
        FStartOrder := NodeByName('startorder').ValueAsString;
        FSetValTag := NodeByName('setvaltag').ValueAsString;
        FImpDataTag := NodeByName('impdatatag').ValueAsString;
        FStopTag := NodeByName('stoptag').ValueAsString;
        FStopOrder := NodeByName('stoporder').ValueAsString;

        nTmp := FindNode('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//Desc: 检索标识为nID的通道
function TOPCTunnelManager.GetTunnel(const nID: string): PPTOPCItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  if CompareText(nID, PPTOPCItem(FTunnels[nIdx]).FID) = 0 then
  begin
    Result := FTunnels[nIdx];
    Exit;
  end;
end;

initialization
  gOPCTunnelManager := nil;
finalization
  FreeAndNil(gOPCTunnelManager);
end.
