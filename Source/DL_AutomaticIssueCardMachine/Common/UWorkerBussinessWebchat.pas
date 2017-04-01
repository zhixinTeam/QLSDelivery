{*******************************************************************************
作者: fendou116688@163.com 2016/9/19
描述: Web平台服务查询
*******************************************************************************}
unit UWorkerBussinessWebchat;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerSelfRemote, NativeXml,USysConst;

type
  TWebResponseBaseInfo = class(TObject)
  public
    FErrcode:Integer;
    FErrmsg:string;
  end;

  TWebResponse_CustomerInfo = class(TWebResponseBaseInfo)
  public
    FFactory:string;
    Fphone:string;
    FAppid:string;
    FBindcustomerid:string;
    FNamepinyin:string;
    FEmail:string;
    FOpenid:string;
    FBinddate:string;
  end;

  TWebResponse_Bindfunc = class(TWebResponseBaseInfo)
  end;

  TWebResponse_send_event_msg=class(TWebResponseBaseInfo)
  end;

  TWebResponse_edit_shopclients=class(TWebResponseBaseInfo)
  end;

  TWebResponse_edit_shopgoods=class(TWebResponseBaseInfo)
  end;

  TWebResponse_complete_shoporders=class(TWebResponseBaseInfo)
  end;  

  stShopOrderItem = record
    FOrder_id:string;
    FOrdernumber:string;
    FGoodsID:string;
    FGoodstype:string;
    FGoodsname:string;
    FData:string;
  end;
  
  TWebResponse_get_shoporders=class(TWebResponseBaseInfo)
  public
    items:array of stShopOrderItem;
  end;
  
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TBusWorkerBusinessWebchat = class(TBusinessWorkerBase)
  private
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;

    procedure BuildDefaultXMLPack;
    //创建返回默认报文
    function UnPackIn(var nData: string): Boolean;
    //传入报文解包
    function VerifyPrintCode(var nData: string): Boolean;
    //验证喷码信息

    function GetWaitingForloading(var nData:string):Boolean;
    //工厂待装查询

    function GetBillSurplusTonnage(var nData:string):Boolean;
    //网上订单可下单数量查询

    function GetOrderInfo(var nData:string):Boolean;
    //获取订单信息    

    function GetCustomerInfo(var nData:string):boolean;
    //获取客户注册信息
    
    function Get_Shoporders(var nData:string):boolean;
    //获取订单信息

    function Get_Bindfunc(var nData:string):boolean;
    //客户与微信账号绑定

    function Send_Event_Msg(var nData:string):boolean;
    //发送消息
    
    function Edit_ShopClients(var nData:string):boolean;
    //新增商城用户
    
    function Edit_Shopgoods(var nData:string):boolean;
    //添加商品

    function complete_shoporders(var nData:string):Boolean;
    //修改订单状态
    
    function ParseWebResponse(var nData:string;nObj:TWebResponse_CustomerInfo):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponse_Bindfunc):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponse_send_event_msg):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponse_edit_shopclients):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponse_edit_shopgoods):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponse_get_shoporders):Boolean;overload;
    function ParseWebResponse(var nData:string;nObj:TWebResponseBaseInfo):Boolean;overload;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

implementation
uses
  wechat_soap;
  
class function TBusWorkerBusinessWebchat.FunctionName: string;
begin
  Result := sBus_BusinessWebchat;
end;

function TBusWorkerBusinessWebchat.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessWebchat;
  end;
end;

//Desc: 记录nEvent日志
procedure TBusWorkerBusinessWebchat.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessWebchat, 'Web平台业务' , nEvent);
end;

{
//传入参数
<?xml version="1.0" encoding="utf-8"?>
<Head>
  <Command>1</Command>
  <Data>参数</Data>
  <ExtParam>附加参数</ExtParam>
  <RemoteUL>工厂服务UL</RemoteUL>
</Head>

//传出参数
<?xml version="1.0" encoding="utf-8"?>
<DATA>
  <Items>
    <Item>
      .....
    </Item>
  </Items>
  <EXMG> ---错误描述，可多条
     < Item>
         < MsgResult> Y</ MsgResult > ---消息类型，Y成功，N失败等
         < MsgCommand> 1</ MsgCommand >----消息代码
		     < MsgTxt>减配失败，指定订单已无效</ MsgTxt > ---错误描述
     < / Item >
  </EXMG>
</DATA>
}

function TBusWorkerBusinessWebchat.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(nData);

  //nNode := FPacker.XMLBuilder.Root.FindNode('Head');
  nNode := FPacker.XMLBuilder.Root;
  if not (Assigned(nNode) and Assigned(nNode.FindNode('Command'))) then
  begin
    nData := '无效参数节点(Head.Command Null).';
    Exit;
  end;

  if not Assigned(nNode.FindNode('RemoteUL')) then
  begin
    nData := '无效参数节点(Head.RemoteUL Null).';
    Exit;
  end;

  nTmp := nNode.FindNode('Command');
  FIn.FCommand := StrToIntDef(nTmp.ValueAsString, 0);

  nTmp := nNode.FindNode('RemoteUL');
  FIn.FRemoteUL:= nTmp.ValueAsString;

  nTmp := nNode.FindNode('Data');
  if Assigned(nTmp) then FIn.FData := nTmp.ValueAsString;

  nTmp := nNode.FindNode('ExtParam');
  if Assigned(nTmp) then FIn.FExtParam := nTmp.ValueAsString;
end;

procedure TBusWorkerBusinessWebchat.BuildDefaultXMLPack;
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

function TBusWorkerBusinessWebchat.DoWork(var nData: string): Boolean;
begin
  UnPackIn(nData);

  case FIn.FCommand of
    cBC_VerifPrintCode         : Result := VerifyPrintCode(nData);
    cBC_WaitingForloading      : Result := GetWaitingForloading(nData);
    cBC_BillSurplusTonnage     : Result := GetBillSurplusTonnage(nData);
    cBC_GetOrderInfo           : Result := GetOrderInfo(nData);

    cBC_WeChat_getCustomerInfo :Result := getCustomerInfo(nData);  //微信平台接口：获取客户注册信息
    cBC_WeChat_get_Bindfunc    :Result := get_Bindfunc(nData);  //微信平台接口：客户与微信账号绑定
    cBC_WeChat_send_event_msg  :Result := send_event_msg(nData);  //微信平台接口：发送消息
    cBC_WeChat_edit_shopclients :Result := edit_shopclients(nData);  //微信平台接口：新增商城用户
    cBC_WeChat_edit_shopgoods :Result := edit_shopgoods(nData);  //微信平台接口：添加商品
    cBC_WeChat_get_shoporders :Result := get_shoporders(nData);  //微信平台接口：获取订单信息
   else
    begin
      Result := False;
      nData := '无效的指令代码(Invalid Command).';
    end;
  end;

  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: 防伪码
//Desc: 防伪码查询
function TBusWorkerBusinessWebchat.VerifyPrintCode(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TLadingBillItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_VerifPrintCode, FIn.FRemoteUL);
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseBillItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('ID').ValueAsString := FID;

          NodeNew('CusID').ValueAsString := FCusID;
          NodeNew('CusName').ValueAsString := FCusName;

          NodeNew('Truck').ValueAsString := FTruck;
          NodeNew('StockNo').ValueAsString := FStockNo;
          NodeNew('StockName').ValueAsString := FStockName;
        end;  
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := '业务执行成功';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end  else

  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  

  nData := FPacker.XMLBuilder.WriteToString;
end;  

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: 无用
//Desc: 工厂待装查询
function TBusWorkerBusinessWebchat.GetWaitingForloading(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TQueueListItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WaitingForloading, FIn.FRemoteUL);
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseQueueListItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('StockName').ValueAsString := FStockName;
          NodeNew('LineCount').ValueAsString := IntToStr(FLineCount);
          NodeNew('TruckCount').ValueAsString := IntToStr(FTruckCount);
        end;  
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := '????3?|';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end
  else begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  
  nData := FPacker.XMLBuilder.WriteToString;
end;

//------------------------------------------------------------------------------
//Date: 2016-9-23
//Parm: 客户编号，产品编号
//Desc: 网上订单可下单数量查询
function TBusWorkerBusinessWebchat.GetBillSurplusTonnage(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_BillSurplusTonnage, FIn.FRemoteUL);
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        with NodeNew('Item') do
        begin
          NodeNew('MaxTonnage').ValueAsString := nOut.FData;
        end;
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := '业务执行成功';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end
  else begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  
  nData := FPacker.XMLBuilder.WriteToString;
end;

//------------------------------------------------------------------------------
//Date: 2016-10-20
//Parm: 提货单号（云天系统大票号）
//Desc: 获取订单信息,或网上下单时使用
function TBusWorkerBusinessWebchat.GetOrderInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
  nCardData:TStringList;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_GetOrderInfo, FIn.FRemoteUL);
  nCardData := TStringList.Create;
  try
    BuildDefaultXMLPack;
    if Result then
    begin
      nCardData.Text := PackerDecodeStr(nOut.FData);
      with FPacker.XMLBuilder do
      begin
        with Root.NodeNew('head') do
        begin
          NodeNew('CusId').ValueAsString := nCardData.Values['XCB_Client'];
          NodeNew('CusName').ValueAsString := nCardData.Values['XCB_ClientName'];
        end;

        with Root.NodeNew('Items') do
        begin
          with NodeNew('Item') do
          begin
            NodeNew('StockNo').ValueAsString := nCardData.Values['XCB_Cement'];
            NodeNew('StockName').ValueAsString := nCardData.Values['XCB_CementName'];
            NodeNew('MaxNumber').ValueAsString := nCardData.Values['XCB_RemainNum'];
          end;
        end;

        with Root.NodeNew('EXMG') do
        begin
          NodeNew('MsgTxt').ValueAsString     := '业务执行成功';
          NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
          NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
        end;
      end;
    end;
  finally
    nCardData.Free;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
end;

//获取客户注册信息
function TBusWorkerBusinessWebchat.GetCustomerInfo(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_CustomerInfo;
  function BuildResData:string;
  begin
    Result := 'Appid=%s\nBindcustomerid=%s\nNamepinyin=%s\nEmail=%s\nOpenid=%s\nBinddate=%s';
    Result := Format(Result,[nObj.FAppid, nObj.FBindcustomerid, nObj.FNamepinyin, nobj.FEmail, nObj.FOpenid, nobj.FBinddate]);
    Result := StringReplace(Result, '\n', #13#10, [rfReplaceAll]);
    Result := PackerEncodeStr(Result);
  end;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_CustomerInfo.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('getCustomerInfo',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
    nData := BuildResData;
    FOut.FData := nData;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//获取订单信息
function TBusWorkerBusinessWebchat.Get_Shoporders(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_get_shoporders;
  function BuildResData:string;
  var
    i:Integer;
    nStr:string;
    nList:TStringList;
  begin
    nList := TStringList.Create;
    try
      for i := Low(nObj.items) to High(nObj.items) do
      begin
        nStr := 'order_id=%s\nordernumber=%s\ngoodsID=%s\ngoodstype=%s\ngoodsname=%s\ndata=%s';
        nStr := Format(nStr,[nObj.items[i].FOrder_id, nObj.items[i].FOrdernumber, nObj.items[i].FGoodsID, nobj.items[i].FGoodstype, nObj.items[i].FGoodsname, nobj.items[i].FData]);
        nStr := StringReplace(nStr, '\n', #13#10, [rfReplaceAll]);
        nlist.Add(nStr);
      end;
      Result := PackerEncodeStr(nlist.Text);
    finally
      nList.Free;
    end;
  end;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_get_shoporders.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('get_shoporders',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
    nData := BuildResData;
    FOut.FData := nData;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//客户与微信账号绑定
function TBusWorkerBusinessWebchat.Get_Bindfunc(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_Bindfunc;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_Bindfunc.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('get_Bindfunc',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nService := nil;
    nObj.Free;
  end;  
end;

//发送消息
function TBusWorkerBusinessWebchat.Send_Event_Msg(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_send_event_msg;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_send_event_msg.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('send_event_msg',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//新增商城用户
function TBusWorkerBusinessWebchat.Edit_ShopClients(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_edit_shopclients;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_edit_shopclients.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('edit_shopclients',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//添加商品
function TBusWorkerBusinessWebchat.Edit_Shopgoods(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_edit_shopgoods;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_edit_shopgoods.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('edit_shopgoods',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//修改订单状态
function TBusWorkerBusinessWebchat.complete_shoporders(var nData:string):Boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_complete_shoporders;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_complete_shoporders.Create;
  nService := GetReviceWS;
  try
    nResponse := nService.mainfuncs('complete_shoporders',nXmlStr);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    Result := ParseWebResponse(nResponse,nObj);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      fout.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_CustomerInfo):Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      nObj.FErrmsg := '无效参数节点(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      nObj.FErrmsg := '无效参数节点(Items.Item Null).';
      Result := False;
      Exit;
    end;

    nNode := nNode.FindNode('Item');

    nTmp := nNode.FindNode('Appid');
    nObj.FAppid := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Bindcustomerid');
    nObj.FBindcustomerid := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Namepinyin');
    nObj.FNamepinyin := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Email');
    nObj.FEmail := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Openid');
    nObj.FOpenid := nTmp.ValueAsString;

    nTmp := nNode.FindNode('Binddate');
    nObj.FBinddate := nTmp.ValueAsString;
  end;
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_Bindfunc):Boolean;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_send_event_msg):Boolean;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_edit_shopclients):Boolean;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_edit_shopgoods):Boolean;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponse_get_shoporders):Boolean;
var nNode, nTmp,nNodeTmp: TXmlNode;
  nIdx,nNodeCount:Integer;
begin
  Result := ParseWebResponse(nData,TWebResponseBaseInfo(nObj));
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      nObj.FErrmsg := '无效参数节点(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      nObj.FErrmsg := '无效参数节点(Items.Item Null).';
      Result := False;
      Exit;
    end;

    nNodeCount :=nNode.NodeCount;
    SetLength(nObj.items,nNodeCount);

    for nIdx := 0 to nNodeCount-1 do
    begin
      nNodeTmp := nNode.Nodes[nIdx];

      nTmp := nNodeTmp.FindNode('order_id');
      nObj.items[nIdx].FOrder_id := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('ordernumber');
      nObj.items[nIdx].FOrdernumber := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('goodsID');
      nObj.items[nIdx].FGoodsID := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('goodstype');
      nObj.items[nIdx].FGoodstype := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('goodsname');
      nObj.items[nIdx].FGoodsname := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('data');
      nObj.items[nIdx].FData := nTmp.ValueAsString;
    end;
  end;
end;

function TBusWorkerBusinessWebchat.ParseWebResponse(var nData:string;nObj:TWebResponseBaseInfo):Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(nData);
  nNode := FPacker.XMLBuilder.Root.FindNode('Head');
  if not (Assigned(nNode) and Assigned(nNode.FindNode('errcode'))) then
  begin
    nObj.FErrmsg := '无效参数节点(Head.errcode Null).';
    Exit;
  end;
  if not Assigned(nNode.FindNode('errmsg')) then
  begin
    nObj.FErrmsg := '无效参数节点(Head.errmsg Null).';
    Exit;
  end;
  nTmp := nNode.FindNode('errcode');
  nObj.FErrcode := StrToIntDef(nTmp.ValueAsString, 0);

  nTmp := nNode.FindNode('errmsg');
  nObj.FErrmsg:= nTmp.ValueAsString;
  Result := nObj.FErrcode=0;  
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchat, sPlug_ModuleBus);
end.
