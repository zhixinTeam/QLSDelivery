{*******************************************************************************
作者: juner11212436@163.com 2017/9/14
描述: AX消息处理服务端
*******************************************************************************}
unit UWorkerBussinessMessage;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml, UWorkerBusiness;

type

  TBusWorkerBusinessMessage = class(TMITDBWorker)
  private
    FIn: TWorkerMessageData;
    FOut: TWorkerMessageData;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    procedure BuildDefaultXMLPack;
    //创建返回默认报文
    function UnPackIn(var nData: string): Boolean;
    //传入报文解包
    function SaveMessage(var nData:string):boolean;
  public
    constructor Create; override;
    destructor destroy; override;
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoDBWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessMessage, 'SA消息业务' , nEvent);
end;

class function TBusWorkerBusinessMessage.FunctionName: string;
begin
  Result := sBus_BusinessMessage;
end;

function TBusWorkerBusinessMessage.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessMessage;
  end;
end;

//Desc: 记录nEvent日志
procedure TBusWorkerBusinessMessage.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessMessage, 'SA消息业务' , nEvent);
end;


function TBusWorkerBusinessMessage.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
    nListA, nListB: TStrings;
    nInt : Integer;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(FIn.FData);
  WriteLog(FIn.FData);
  nNode := FPacker.XMLBuilder.Root;
  if not (Assigned(nNode)) then
  begin
    nData := '无效参数节点(Head.Data Null).';
    Exit;
  end;
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    for nInt := 0 to nNode.NodeCount - 1 do
    begin
      nTmp := nNode.Nodes[nInt];
      if not (Assigned(nTmp)) then
        Continue;
      nListB.Clear;
      nListB.Values['XTProcessId'] := nTmp.NodeByName('XTProcessId').ValueAsString;
//      nListB.Values['XTIndexXML']       := PackerDecodeStr(nTmp.NodeByName('XTIndexXML').ValueAsString);
      nListB.Values['RefRecId']    := nTmp.NodeByName('RefRecId').ValueAsString;
      nListB.Values['RecId']       := nTmp.NodeByName('RecId').ValueAsString;
      nListB.Values['CompanyId']   := nTmp.NodeByName('CompanyId').ValueAsString;
      nListB.Values['Processflag'] := nTmp.NodeByName('Processflag').ValueAsString;
      nListA.Add(nListB.Text);
    end;
    WriteLog('消息参数解析后：' + nListA.Text);
    FIn.FData := nListA.Text;
    Result := True;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

procedure TBusWorkerBusinessMessage.BuildDefaultXMLPack;
begin
  with FPacker.XMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
  end;
end;

function TBusWorkerBusinessMessage.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  Result := SaveMessage(nData);
end;

function TBusWorkerBusinessMessage.SaveMessage(var nData: string): boolean;
var nStr, nXTProcessId, nRefRecId, nRecId, nCompanyId, nXTIndexXML: string;
    nIdx, nInt: Integer;
    nXml: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  Result := False;

  nXml := nil ;
  try
    nXml := TNativeXml.Create;
    nXml.ReadFromString(FIn.FData);
    WriteLog('消息参数接收:'+FIn.FData);

    nNode := nXml.Root;
    if not (Assigned(nNode)) then
    begin
      nData := '无效参数节点(Head.Data Null).';
      Exit;
    end;

    BuildDefaultXMLPack;
    //创建回传

    try
      FDBConn.FConn.BeginTrans;

      for nInt := 0 to nNode.NodeCount - 1 do
      begin
        nTmp := nNode.Nodes[nInt];

        if not (Assigned(nTmp)) then
          Continue;

        if Assigned(nTmp.NodeByName('XTProcessId')) then
          nXTProcessId := nTmp.NodeByName('XTProcessId').ValueAsString;

        if Assigned(nTmp.NodeByName('RefRecId')) then
          nRefRecId    := nTmp.NodeByName('RefRecId').ValueAsString;

        if Assigned(nTmp.NodeByName('RecId')) then
          nRecId       := nTmp.NodeByName('RecId').ValueAsString;

        if Assigned(nTmp.NodeByName('CompanyId')) then
          nCompanyId   := nTmp.NodeByName('CompanyId').ValueAsString;

        if Assigned(nTmp.NodeByName('XTIndexXML')) then
          nXTIndexXML   := nTmp.NodeByName('XTIndexXML').ValueAsString;

        nStr := MakeSQLByStr([SF('AX_ProcessId', nXTProcessId),
                SF('AX_Recid',nRefRecId),//本地消息表里AX_Recid对应值为XML里的RefRecId
                SF('AX_CompanyId', nCompanyId),
                SF('AX_XtIndexXml', nXTIndexXML)
                ], sTable_AxMsgList, '', True);
        nIdx := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nIdx > 0 then
          nStr := '1'
        else
          nStr := '0';

        with FPacker.XMLBuilder do
        begin
          with Root.NodeNew('Item') do
          begin
            NodeNew('RecId').ValueAsString      := nRecId;
            NodeNew('MsgResult').ValueAsString  := nStr;
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;

      nData := FPacker.XMLBuilder.WriteToString;
      Fout.FData := nData;
      WriteLog('消息参数应答:'+ nData);

      Result := True;
    except
      FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    nXml.Free;
  end;
end;

procedure TBusWorkerBusinessMessage.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

constructor TBusWorkerBusinessMessage.Create;
begin
  inherited;

end;

destructor TBusWorkerBusinessMessage.destroy;
begin

  inherited;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessMessage, sPlug_ModuleBus);
end.
