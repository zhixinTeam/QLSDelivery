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
  USysDB, UMITConst, UWorkerSelfRemote, NativeXml;

type
  TWebResponseBaseInfo = class(TObject)
  public
    FErrcode:Integer;
    FErrmsg:string;
    FPacker: TBusinessPackerBase;
    function ParseWebResponse(var nData:string):Boolean;virtual;
  end;

  stCustomerInfoItem = record
    Fphone:string;
    FBindcustomerid:string;
    FNamepinyin:string;
    FEmail:string;
  end;

  TWebResponse_CustomerInfo = class(TWebResponseBaseInfo)
  public
    items:array of stCustomerInfoItem;
    function ParseWebResponse(var nData:string):Boolean;override;
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
    Ffac_order_no:string;
    FOrdernumber:string;
    FGoodsID:string;
    FGoodstype:string;
    FGoodsname:string;
    Ftracknumber:string;
    FData:string;
    Fnamepinyin:string;
    Ftoaddress:string;
    Fidnumber:string;
  end;
  
  TWebResponse_get_shoporders=class(TWebResponseBaseInfo)
  public
    items:array of stShopOrderItem;
    function ParseWebResponse(var nData:string):Boolean;override;
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

    function GetInOutFactoryTatol(var nData:string):Boolean;
    //进出厂量查询（采购进厂量、销售出厂量）

    function GetBillSurplusTonnage(var nData:string):Boolean;
    //网上订单可下单数量查询

    function GetOrderInfo(var nData:string):Boolean;
    //获取订单信息

    function GetOrderList(var nData:string):Boolean;
    //获取订单列表

    function GetPurchaseContractList(var nData:string):Boolean;
    //获取采购合同列表       

    function GetCustomerInfo(var nData:string):boolean;
    //获取客户注册信息
    
    function Get_Shoporders(var nData:string):boolean;
    //获取订单信息

    function get_shoporderByNO(var nData:string):boolean;
    //根据订单号获取订单信息

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
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessWebchat, 'Web平台业务' , nEvent);
end;

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
  WriteLog(nData);
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
    cBC_GetOrderList           : Result := GetOrderList(nData);
    cBC_GetPurchaseContractList : Result := GetPurchaseContractList(nData);

    cBC_WeChat_getCustomerInfo :Result := getCustomerInfo(nData);  //微信平台接口：获取客户注册信息
    cBC_WeChat_get_Bindfunc    :Result := get_Bindfunc(nData);  //微信平台接口：客户与微信账号绑定
    cBC_WeChat_send_event_msg  :Result := send_event_msg(nData);  //微信平台接口：发送消息
    cBC_WeChat_edit_shopclients :Result := edit_shopclients(nData);  //微信平台接口：新增商城用户
    cBC_WeChat_edit_shopgoods :Result := edit_shopgoods(nData);  //微信平台接口：添加商品
    cBC_WeChat_get_shoporders :Result := get_shoporders(nData);  //微信平台接口：获取订单信息
    cBC_WeChat_complete_shoporders : Result := complete_shoporders(nData); //微信平台接口：订单完成
    cBC_WeChat_get_shoporderbyno : Result := get_shoporderbyno(nData);  //微信平台接口：根据订单号获取订单信息
    cBC_WeChat_get_shopPurchasebyNO : Result := get_shoporderbyno(nData);

    cBC_WeChat_InOutFactoryTotal : Result := GetInOutFactoryTatol(nData); //进出厂量统计
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
            @nOut, cBC_VerifPrintCode, Trim(FIn.FRemoteUL));
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
            @nOut, cBC_WaitingForloading, Trim(FIn.FRemoteUL));
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

//进出厂量查询（采购进厂量、销售出厂量） lih 2017-04-19
function TBusWorkerBusinessWebchat.GetInOutFactoryTatol(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TInOutFactListItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WeChat_InOutFactoryTotal, Trim(FIn.FRemoteUL));
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseInOutFactListItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('StockName').ValueAsString := FStockName;
          NodeNew('TruckCount').ValueAsString := IntToStr(FTruckCount);
          NodeNew('StockValue').ValueAsString := FormatFloat('0.00',FStockValue);
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
//Date: 2016-9-23
//Parm: 客户编号，产品编号
//Desc: 网上订单可下单数量查询
function TBusWorkerBusinessWebchat.GetBillSurplusTonnage(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_BillSurplusTonnage, Trim(FIn.FRemoteUL));
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
//Desc: 获取订单信息,网上下单时使用
function TBusWorkerBusinessWebchat.GetOrderInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
  nCardData:TStringList;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_GetOrderInfo, Trim(FIn.FRemoteUL));
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

//------------------------------------------------------------------------------
//Date: 2016-12-18
//Parm: 客户编号
//Desc: 获取订单列表,或网上下单时使用
function TBusWorkerBusinessWebchat.GetOrderList(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
  nCardData,nCardItem:TStringList;
  i:Integer;
  nRequest,nResponse:string;
begin
   Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_GetOrderList, Trim(FIn.FRemoteUL));
  nCardData := TStringList.Create;
  nCardItem := TStringList.Create;
  try
    BuildDefaultXMLPack;
    if Result then
    begin
      nCardData.Text := PackerDecodeStr(nOut.FData);
      nCardItem.Text := PackerDecodeStr(nCardData.Strings[0]);
      with FPacker.XMLBuilder do
      begin
        with Root.NodeNew('head') do
        begin
          NodeNew('CusId').ValueAsString := nCardItem.Values['XCB_Client'];
          NodeNew('CusName').ValueAsString := nCardItem.Values['XCB_ClientName'];
        end;

        with Root.NodeNew('Items') do
        begin
          for i := 0 to nCardData.Count-1 do
          begin
            nCardItem.Text := PackerDecodeStr(nCardData.Strings[i]);
            with NodeNew('Item') do
            begin
              NodeNew('SetDate').ValueAsString := nCardItem.Values['XCB_SetDate'];
              NodeNew('BillNumber').ValueAsString := nCardItem.Values['XCB_CardId'];
              NodeNew('StockNo').ValueAsString := nCardItem.Values['XCB_Cement'];
              NodeNew('StockName').ValueAsString := nCardItem.Values['XCB_CementName'];
              NodeNew('MaxNumber').ValueAsString := nCardItem.Values['XCB_RemainNum'];
              NodeNew('Remark').ValueAsString := nCardItem.Values['XCB_Option'];
            end;
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
    nCardItem.Free;
    nCardData.Free;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
end;

//获取采购合同列表
function TBusWorkerBusinessWebchat.GetPurchaseContractList(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
  nCardData,nCardItem:TStringList;
  i:Integer;
  nRequest,nResponse:string;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_GetPurchaseContractList, Trim(FIn.FRemoteUL));
              
  nCardData := TStringList.Create;
  nCardItem := TStringList.Create;
  nRequest := fin.FData;
  WriteLog('TBusWorkerBusinessWebchat.GetPurchaseContractList request='+nRequest);
  try
    BuildDefaultXMLPack;
    if Result then
    begin
      nCardData.Text := PackerDecodeStr(nOut.FData);
      nCardItem.Text := PackerDecodeStr(nCardData.Strings[0]);
      WriteLog('TBusWorkerBusinessWebchat.GetPurchaseContractList nCardItem='+nCardItem.Text);
      with FPacker.XMLBuilder do
      begin
        with Root.NodeNew('head') do
        begin
          NodeNew('ProvId').ValueAsString := nCardItem.Values['provider_code'];
          NodeNew('ProvName').ValueAsString := nCardItem.Values['provider_name'];
        end;
        with Root.NodeNew('Items') do
        begin
          for i := 0 to nCardData.Count-1 do
          begin
            nCardItem.Text := PackerDecodeStr(nCardData.Strings[i]);
            with NodeNew('Item') do
            begin
              NodeNew('SetDate').ValueAsString := nCardItem.Values['con_date'];
              NodeNew('BillNumber').ValueAsString := nCardItem.Values['pcId'];
              NodeNew('StockNo').ValueAsString := nCardItem.Values['con_materiel_Code'];
              NodeNew('StockName').ValueAsString := nCardItem.Values['con_materiel_name'];
              NodeNew('MaxNumber').ValueAsString := nCardItem.Values['con_price'];//订单剩余量
            end;
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
    nCardItem.Free;
    nCardData.Free;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  nResponse := FPacker.XMLBuilder.WriteToString;
  WriteLog('TBusWorkerBusinessWebchat.GetPurchaseContractList request='+nResponse);
end;


//获取客户注册信息
function TBusWorkerBusinessWebchat.GetCustomerInfo(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_CustomerInfo;
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
        nStr := 'phone=%s,Bindcustomerid=%s,Namepinyin=%s,Email=%s';
        nStr := Format(nStr,[nObj.items[i].Fphone, nObj.items[i].FBindcustomerid,
          nObj.items[i].FNamepinyin, nObj.items[i].FEmail]);
        //nStr := StringReplace(nStr, '\n', #13#10, [rfReplaceAll]);
        nlist.Add(nStr);
      end;
      Result := PackerEncodeStr(nlist.Text);
    finally
      nList.Free;
    end;
  end;
begin
  Result := False;
  nXmlStr := PackerDecodeStr(FIn.FData);
  nObj := TWebResponse_CustomerInfo.Create;
  nService := GetReviceWS(True);
  try
    WriteLog('TBusWorkerBusinessWebchat.GetCustomerInfo request='+nXmlStr);
    nResponse := nService.mainfuncs('getCustomerInfo',nXmlStr);
    WriteLog('TBusWorkerBusinessWebchat.GetCustomerInfo response='+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
        nStr := 'order_id=%s,fac_order_no=%s,ordernumber=%s,goodsID=%s,goodstype=%s,goodsname=%s,tracknumber=%s,data=%s,namepinyin=%s,toaddress=%s,idnumber=%s\n';
        nStr := Format(nStr,[nObj.items[i].FOrder_id,
          nObj.items[i].Ffac_order_no,
          nObj.items[i].FOrdernumber,
          nObj.items[i].FGoodsID,
          nobj.items[i].FGoodstype,
          nObj.items[i].FGoodsname,
          nObj.items[i].Ftracknumber,
          nobj.items[i].FData,
          nobj.items[i].Fnamepinyin,
          nObj.items[i].Ftoaddress,
          nObj.items[i].Fidnumber]);
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
  nService := GetReviceWS(True);
  try
    nResponse := nService.mainfuncs('get_shoporders',nXmlStr);
    writelog('TBusWorkerBusinessWebchat.Get_Shoporders response:'+#13+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    writelog('TBusWorkerBusinessWebchat.Get_Shoporders Response:'+#13+nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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

//根据订单号获取订单信息
function TBusWorkerBusinessWebchat.get_shoporderByNO(var nData:string):boolean;
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
        nStr := 'order_id=%s,fac_order_no=%s,ordernumber=%s,goodsID=%s,goodstype=%s,goodsname=%s,tracknumber=%s,data=%s,namepinyin=%s,toaddress=%s,idnumber=%s\n';
        nStr := Format(nStr,[nObj.items[i].FOrder_id,
          nObj.items[i].Ffac_order_no,
          nObj.items[i].FOrdernumber,
          nObj.items[i].FGoodsID,
          nobj.items[i].FGoodstype,
          nObj.items[i].FGoodsname,
          nObj.items[i].Ftracknumber,
          nobj.items[i].FData,
          nobj.items[i].Fnamepinyin,
          nObj.items[i].Ftoaddress,
          nObj.items[i].Fidnumber]);
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
  nService := GetReviceWS(True);
  try
    nResponse := nService.mainfuncs('get_shoporderByNO',nXmlStr);
    writelog('TBusWorkerBusinessWebchat.get_shoporderByNO response:'+#13+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    writelog('TBusWorkerBusinessWebchat.get_shoporderByNO Response:'+#13+nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
  nService := GetReviceWS(True);
  try
    WriteLog('TBusWorkerBusinessWebchat.et_Bindfunc request:'+nXmlStr);
    nResponse := nService.mainfuncs('get_Bindfunc',nXmlStr);
    WriteLog('TBusWorkerBusinessWebchat.t_Bindfunc response:'+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
  nService := GetReviceWS(True);
  try
    WriteLog('TBusWorkerBusinessWebchat.Send_Event_Msg request:'+#13+nXmlStr);
    nResponse := nService.mainfuncs('send_event_msg',nXmlStr);
    WriteLog('TBusWorkerBusinessWebchat.Send_Event_Msg Response:'+#13+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
  try
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_edit_shopclients.Create;
  nService := GetReviceWS(True);
  try
    WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients request='+nXmlStr);
    nResponse := nService.mainfuncs('edit_shopclients',nXmlStr);
    WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients Response='+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
  except
    on E:Exception do
    begin
      WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients exception='+e.Message);
    end;
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
  nService := GetReviceWS(True);
  try
    WriteLog('TBusWorkerBusinessWebchat.Edit_Shopgoods request='+nXmlStr);
    nResponse := nService.mainfuncs('edit_shopgoods',nXmlStr);
    WriteLog('TBusWorkerBusinessWebchat.Edit_Shopgoods Response='+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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
  nService := GetReviceWS(True);
  try
    writelog('TBusWorkerBusinessWebchat.complete_shoporders request'+#13+nXmlStr);
    nResponse := nService.mainfuncs('complete_shoporders',nXmlStr);
    writelog('TBusWorkerBusinessWebchat.complete_shoporders Response'+#13+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
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


{ TWebResponseBaseInfo }

function TWebResponseBaseInfo.ParseWebResponse(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(nData);
  nNode := FPacker.XMLBuilder.Root.FindNode('Head');
  if not (Assigned(nNode) and Assigned(nNode.FindNode('errcode'))) then
  begin
    FErrmsg := '无效参数节点(Head.errcode Null).';
    Exit;
  end;
  if not Assigned(nNode.FindNode('errmsg')) then
  begin
    FErrmsg := '无效参数节点(Head.errmsg Null).';
    Exit;
  end;
  nTmp := nNode.FindNode('errcode');
  FErrcode := StrToIntDef(nTmp.ValueAsString, 0);

  nTmp := nNode.FindNode('errmsg');
  FErrmsg:= nTmp.ValueAsString;
  Result := FErrcode=0;  
end;

{ TWebResponse_CustomerInfo }

function TWebResponse_CustomerInfo.ParseWebResponse(
  var nData: string): Boolean;
var nNode, nTmp,nNodeTmp: TXmlNode;
    nIdx,nNodeCount:Integer;  
begin
  Result := inherited ParseWebResponse(nData);
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      FErrmsg := '无效参数节点(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      FErrmsg := '无效参数节点(Items.Item Null).';
      Result := False;
      Exit;
    end;
    
    nNodeCount :=nNode.NodeCount;
    SetLength(items,nNodeCount);

    for nIdx := 0 to nNodeCount-1 do
    begin
      nNodeTmp := nNode.Nodes[nIdx];

      nTmp := nNodeTmp.FindNode('phone');
      items[nIdx].Fphone := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Bindcustomerid');
      items[nIdx].FBindcustomerid := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Namepinyin');
      items[nIdx].FNamepinyin := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Email');
      if Assigned(nTmp) then
      begin
        items[nIdx].FEmail := nTmp.ValueAsString;
      end;
    end;
  end;  
end;

{ TWebResponse_get_shoporders }

function TWebResponse_get_shoporders.ParseWebResponse(
  var nData: string): Boolean;
var nNode, nTmp,nNodeTmp: TXmlNode;
  nIdx,nNodeCount:Integer;
begin
  Result := inherited ParseWebResponse(nData);
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      FErrmsg := '无效参数节点(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      FErrmsg := '无效参数节点(Items.Item Null).';
      Result := False;
      Exit;
    end;

    nNodeCount :=nNode.NodeCount;
    SetLength(items,nNodeCount);

    for nIdx := 0 to nNodeCount-1 do
    begin
      nNodeTmp := nNode.Nodes[nIdx];

      nTmp := nNodeTmp.FindNode('order_id');
      items[nIdx].FOrder_id := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('fac_order_no');
      items[nIdx].Ffac_order_no := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('ordernumber');
      items[nIdx].FOrdernumber := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('goodsID');
      items[nIdx].FGoodsID := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('goodsname');
      items[nIdx].FGoodsname := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('tracknumber');
      items[nIdx].Ftracknumber := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('data');
      items[nIdx].FData := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('namepinyin');
      if Assigned(nTmp) then
        items[nIdx].Fnamepinyin := nTmp.ValueAsString
      else
        items[nIdx].Fnamepinyin := '';

      nTmp := nNodeTmp.FindNode('toaddress');
      if Assigned(nTmp) then
        items[nIdx].Ftoaddress := nTmp.ValueAsString
      else
        items[nIdx].Ftoaddress := '';

      nTmp := nNodeTmp.FindNode('idnumber');
      if Assigned(nTmp) then
        items[nIdx].Fidnumber := nTmp.ValueAsString
      else
        items[nIdx].Fidnumber := '';
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchat, sPlug_ModuleBus);
end.
