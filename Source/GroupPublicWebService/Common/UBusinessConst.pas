{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务常量定义

  备注:
  *.所有In/Out数据,最好带有TBWDataBase基数据,且位于第一个元素.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  Classes, SysUtils, UBusinessPacker, ULibFun, USysDB;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;

  {*business command*}
  cBC_GetSerialNO             = $0001;   //获取串行编号
  cBC_ServerNow               = $0002;   //服务器当前时间
  cBC_IsSystemExpired         = $0003;   //系统是否已过期

  cBC_VerifPrintCode          = $0091;   //验证喷码信息
  cBC_WaitingForloading       = $0092;   //工厂待装查询
  cBC_BillSurplusTonnage      = $0093;   //网上订单可下单数量查询
  cBC_GetOrderInfo            = $0094;   //获取订单信息，用于网上商城下单
  cBC_GetOrderList            = $0103;   //获取订单列表，用于网上商城下单
  cBC_GetPurchaseContractList = $0107;   //获取采购合同列表，用于网上商城下单

  cBC_WeChat_getCustomerInfo  = $0095;   //微信平台接口：获取客户注册信息
  cBC_WeChat_get_Bindfunc     = $0096;   //微信平台接口：客户与微信账号绑定
  cBC_WeChat_send_event_msg   = $0097;   //微信平台接口：发送消息
  cBC_WeChat_edit_shopclients = $0098;   //微信平台接口：新增商城用户
  cBC_WeChat_edit_shopgoods   = $0099;   //微信平台接口：添加商品
  cBC_WeChat_get_shoporders   = $0100;   //微信平台接口：获取订单信息
  cBC_WeChat_complete_shoporders   = $0101;   //微信平台接口：修改订单状态
  cBC_WeChat_get_shoporderbyNO   = $0102;   //微信平台接口：根据订单号获取订单信息
  cBC_WeChat_get_shopPurchasebyNO   = $0108;   //微信平台接口：根据订单号获取订单信息
  cBC_WeChat_InOutFactoryTotal  = $0200;   //进出厂量查询（采购进厂量、销售出厂量）

type
  PWorkerWebChatData = ^TWorkerWebChatData;
  TWorkerWebChatData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //类型
    FData     : string;            //数据
    FExtParam : string;            //参数
    FRemoteUL : string;            //工厂服务器UL
  end;

  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //类型
    FData     : string;            //数据
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //命令
    FData     : string;            //数据
    FExtParam : string;            //参数
  end;

  TPoundStationData = record
    FStation  : string;            //磅站标识
    FValue    : Double;           //皮重
    FDate     : TDateTime;        //称重日期
    FOperator : string;           //操作员
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //交货单号
    FZhiKa      : string;          //纸卡编号
    FProject    : string;          //项目编号
    FCusID      : string;          //客户编号
    FCusName    : string;          //客户名称
    FTruck      : string;          //车牌号码

    FType       : string;          //品种类型
    FStockNo    : string;          //品种编号
    FStockName  : string;          //品种名称
    FValue      : Double;          //提货量
    FPrice      : Double;          //提货单价

    FCard       : string;          //磁卡号
    FIsVIP      : string;          //通道类型
    FStatus     : string;          //当前状态
    FNextStatus : string;          //下一状态
    FLineGroup  : string;          //车间分组

    FPData      : TPoundStationData; //称皮
    FMData      : TPoundStationData; //称毛
    FFactory    : string;          //工厂编号
    FPModel     : string;          //称重模式
    FPType      : string;          //业务类型
    FPoundID    : string;          //称重记录
    FHKRecord   : string;          //合单记录
    FSelected   : Boolean;         //选中状态

    FSeal       : string;          //编号ID
    FHYDan      : string;          //水泥编号
    FMemo       : string;          //动作备注
  end;

  TLadingBillItems = array of TLadingBillItem;
  //交货单列表

  TQueueListItem = record
    FStockNO   : string;
    FStockName : string;

    FLineCount : Integer;
    FTruckCount: Integer;
  end;
  TQueueListItems = array of TQueueListItem;
  //待装排队列表

  TInOutFactListItem = record
    FStockNO   : string;
    FStockName : string;

    FTruckCount : Integer;
    FStockValue: Double;
  end;
  TInOutFactListItems = array of TInOutFactListItem;
  //出厂量列表


procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//解析由业务对象返回的交货单数据
function CombineBillItmes(const nItems: TLadingBillItems): string;
//合并交货单数据为业务对象能处理的字符串

procedure AnalyseQueueListItems(const nData: string; var nItems: TQueueListItems);
//解析由业务对象返回的待装排队数据

procedure AnalyseInOutFactListItems(const nData: string; var nItems: TInOutFactListItems);
//解析由业务对象返回的出厂车辆数据

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //不提示错误

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //业务模块
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //硬件守护
  sPlug_ModuleRemote          = '{B584DCD7-40E5-413C-B9F3-6DD75AEF1C63}';
                                                        //MIT互相访问                                                      
                                                                                                   
  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //基本封包器

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //服务状态
  sBus_GetQueryField          = 'Bus_GetQueryField';    //查询的字段
  sBus_BusinessWebchat        = 'Bus_BusinessWebchat';  //Web平台服务

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //交货单相关
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //业务指令
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //硬件指令
  sBus_BusinessDuanDao        = 'Bus_BusinessDuanDao';  //短倒业务相关
  sBus_BusinessPurchaseOrder  = 'Bus_BusinessPurchaseOrder'; //采购单相关

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //服务状态
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //查询的字段

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //交货单业务
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //业务指令
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //硬件指令
  sCLI_BusinessDuanDao        = 'CLI_BusinessDuanDao';  //短倒业务相关
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //采购单相关

implementation

//Date: 2014-09-17
//Parm: 交货单数据;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FZhiKa      := Values['ZhiKa'];
        FProject    := Values['Project'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = sFlag_Yes;

        with FPData do
        begin
          FStation  := Values['PStation'];
          FDate     := Str2DateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FPData.FValue := StrToFloat(nStr)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          FDate     := Str2DateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FMData.FValue := StrToFloat(nStr)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FValue := StrToFloat(nStr)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FPrice := StrToFloat(nStr)
        else FPrice := 0;

        FSeal   := Values['Seal'];
        FHYDan  := Values['HYDan'];
        FMemo   := Values['Memo']; 
        FHKRecord:= Values['HKRecord'];
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

//Date: 2014-09-18
//Parm: 交货单列表
//Desc: 将nItems合并为业务对象能处理的
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['ZhiKa']      := FZhiKa;
        Values['Project']    := FProject;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTime2Str(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTime2Str(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := sFlag_Yes
        else Values['Selected'] := sFlag_No;

        Values['Seal']       := FSeal;
        Values['HYDan']      := FHYDan;
        Values['Memo']       := FMemo;
        Values['HKRecord']   := FHKRecord;
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

//Date: 2016-09-20
//Parm: 待装队列数据;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseQueueListItems(const nData: string; var nItems: TQueueListItems);
var nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FStockName := Values['StockName'];
        FLineCount := StrToIntDef(Values['LineCount'],0);
        FTruckCount := StrToIntDef(Values['TruckCount'],0);
      end;
      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

//解析由业务对象返回的出厂车辆数据  lih 2017-04-19
procedure AnalyseInOutFactListItems(const nData: string; var nItems: TInOutFactListItems);
var nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FStockName := Values['StockName'];
        FTruckCount := StrToIntDef(Values['TruckCount'],0);
        FStockValue := StrToFloatDef(Values['StockValue'],0);
      end;
      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

end.




