{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务常量定义

  备注:
  *.所有In/Out数据,最好带有TBWDataBase基数据,且位于第一个元素.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  System.JSON, Classes, SysUtils, UBusinessPacker, FMX.Dialogs, UBase64,
  UWifiManager,
  System.IniFiles,                       //Ini
  System.IOUtils;                        //TPath;

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
  cBC_GetCardUsed             = $0004;   //获取卡片类型
  cBC_UserLogin               = $0005;   //用户登录
  cBC_UserLogOut              = $0006;   //用户注销

  cBC_GetCustomerMoney        = $0010;   //获取客户可用金
  cBC_GetZhiKaMoney           = $0011;   //获取纸卡可用金
  cBC_CustomerHasMoney        = $0012;   //客户是否有余额

  cBC_SaveTruckInfo           = $0013;   //保存车辆信息
  cBC_GetTruckPoundData       = $0015;   //获取车辆称重数据
  cBC_SaveTruckPoundData      = $0016;   //保存车辆称重数据

  cBC_SaveBills               = $0020;   //保存交货单列表
  cBC_DeleteBill              = $0021;   //删除交货单
  cBC_ModifyBillTruck         = $0022;   //修改车牌号
  cBC_SaleAdjust              = $0023;   //销售调拨
  cBC_SaveBillCard            = $0024;   //绑定交货单磁卡
  cBC_LogoffCard              = $0025;   //注销磁卡

  cBC_SaveOrder               = $0040;
  cBC_DeleteOrder             = $0041;
  cBC_SaveOrderCard           = $0042;
  cBC_LogOffOrderCard         = $0043;
  cBC_GetPostOrders           = $0044;   //获取岗位采购单
  cBC_SavePostOrders          = $0045;   //保存岗位采购单

  cBC_GetPostBills            = $0030;   //获取岗位交货单
  cBC_SavePostBills           = $0031;   //保存岗位交货单

  cBC_ChangeDispatchMode      = $0053;   //切换调度模式
  cBC_GetPoundCard            = $0054;   //获取磅站卡号
  cBC_GetQueueData            = $0055;   //获取队列数据
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //喷码
  cBC_PrinterEnable           = $0058;   //喷码机启停

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //保存计数结果
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;
  cBC_TunnelOC                = $0076;

  cBC_SyncCustomer            = $0080;   //远程同步客户
  cBC_SyncSaleMan             = $0081;   //远程同步业务员
  cBC_SyncStockBill           = $0082;   //同步单据到远程
  cBC_CheckStockValid         = $0083;   //验证是否允许发货

type
  PSystemParam = ^TSystemParam;
  TSystemParam = record
    FOperator :string;
    FPassword :string;

    FHostIP   :string;
    FHostMAC  :string;

    FServIP   :string;
    FServPort :Integer;

    FHasLogin :Boolean;
    FSavePswd :Boolean;
    FAutoLogin:Boolean;

    FSvrService:string;
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

    FPData      : TPoundStationData; //称皮
    FMData      : TPoundStationData; //称毛
    FFactory    : string;          //工厂编号
    FPModel     : string;          //称重模式
    FPType      : string;          //业务类型
    FPoundID    : string;          //称重记录
    FSelected   : Boolean;         //选中状态

    FKZValue    : Double;          //供应扣除
    FMemo       : string;          //动作备注
  end;

  TLadingBillItems = array of TLadingBillItem;
  //交货单列表

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//解析由业务对象返回的交货单数据
function CombineBillItmes(const nItems: TLadingBillItems): string;
//合并交货单数据为业务对象能处理的字符串
procedure LoadParamFromIni;
procedure SaveParamToIni;

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //不提示错误

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //业务模块
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //硬件守护
                                                                                                   
  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //基本封包器

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //服务状态
  sBus_GetQueryField          = 'Bus_GetQueryField';    //查询的字段

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //交货单相关
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //业务指令
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //硬件指令
  sBus_BusinessPurchaseOrder  = 'Bus_BusinessPurchaseOrder'; //采购单相关

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //服务状态
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //查询的字段

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //交货单业务
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //业务指令
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //硬件指令
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //采购单相关

var gSysParam: TSystemParam;

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
        FSelected   := Values['Selected'] = 'Y';

        with FPData do
        begin
          FStation  := Values['PStation'];
          //FDate     := StrToDateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') then
               FPData.FValue := StrToFloatDef(nStr, 0)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          //FDate     := StrToDateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') then
               FMData.FValue := StrToFloatDef(nStr, 0)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') then
             FValue := StrToFloatDef(nStr, 0)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') then
             FPrice := StrToFloatDef(nStr, 0)
        else FPrice := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') then
             FKZValue := StrToFloatDef(nStr, 0)
        else FKZValue := 0;

        FMemo := Values['Memo'];
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
          Values['PDate']    := DateTimeToStr(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTimeToStr(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := 'Y'
        else Values['Selected'] := 'N';

        Values['KZValue']    := FloatToStr(FKZValue);
        Values['Memo']       := FMemo;
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


procedure LoadParamFromIni;
var nIniFile:TIniFile;
begin
  try
    nIniFile:=TIniFile.Create(TPath.GetHomePath + '/ReadFile.ini');

    with gSysParam,nIniFile do
    begin
      FHostIP   := GetWiFiLocalIP;
      FHostMAC  := GetWiFiLocalMAC;

      FOperator := DecodeBase64(ReadString('ActivityConfig' ,'User', ''));
      FPassword := DecodeBase64(ReadString('ActivityConfig' ,'Password', ''));

      FServIP   := DecodeBase64(ReadString('ActivityConfig' ,'ServIP', ''));
      FServPort := ReadInteger('ActivityConfig' ,'ServPort', 8082);

      FSavePswd := ReadBool('ActivityConfig', 'SavePsd', False);
      FHasLogin := ReadBool('ActivityConfig', 'HasLogin', False);
      FAutoLogin:= ReadBool('ActivityConfig', 'AutoLogin', False);

      FSvrService:= DecodeBase64(ReadString('ActivityConfig' ,'SvrService', ''));
    end;
  finally
    FreeAndNil(nIniFile);
  end;
end;

procedure SaveParamToIni;
var nIniFile:TIniFile;
begin
  try
    nIniFile:=TIniFile.Create(TPath.GetHomePath + '/ReadFile.ini');

    with gSysParam, nIniFile do
    begin
      WriteString('ActivityConfig' ,'User', EncodeBase64(FOperator));
      WriteString('ActivityConfig' ,'Password', EncodeBase64(FPassword));

      WriteBool('ActivityConfig', 'SavePsd', FSavePswd);
      WriteBool('ActivityConfig', 'AutoLogin', FSavePswd and FAutoLogin);
      WriteBool('ActivityConfig', 'HasLogin', FSavePswd and FAutoLogin and FHasLogin );

      if not FSavePswd then
        WriteString('ActivityConfig' ,'Password', '');

      WriteString('ActivityConfig' ,'ServIP', EncodeBase64(FServIP));
      WriteInteger('ActivityConfig' ,'ServPort', FServPort);
      WriteString('ActivityConfig' ,'SvrService', EncodeBase64(FSvrService));
    end;
  finally
    FreeAndNil(nIniFile);
  end;
end;

function CombineBillItmesToJSON(const nItems: TLadingBillItems): string;
var nJsonAll, nJsonOne, nJsonObject: TJSONObject;
    nArrAll,nArrOne: TJSONArray;
    nIdx: Integer;
begin
  nJsonObject := TJSONObject.Create;

  try
    nArrAll := TJSONArray.Create;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      nJsonAll   := TJSONObject.Create;
      if not Assigned(nJsonAll) then Continue;
      with nJsonAll do
      begin
        AddPair(TJSONPair.Create('ID', FID));
        AddPair(TJSONPair.Create('ZhiKa', FZhiKa));
        AddPair(TJSONPair.Create('CusID', FID));
        AddPair(TJSONPair.Create('CusName', FZhiKa));
        AddPair(TJSONPair.Create('Truck', FID));

        AddPair(TJSONPair.Create('Type', FZhiKa));
        AddPair(TJSONPair.Create('StockNo', FID));
        AddPair(TJSONPair.Create('StockName', FZhiKa));
        AddPair(TJSONPair.Create('Value', FloatToStr(FValue)));
        AddPair(TJSONPair.Create('Price', FloatToStr(FPrice)));


        AddPair(TJSONPair.Create('Card', FID));
        AddPair(TJSONPair.Create('IsVIP', FZhiKa));
        AddPair(TJSONPair.Create('Status', FID));
        AddPair(TJSONPair.Create('ZhiKa', FZhiKa));
        AddPair(TJSONPair.Create('NextStatus', FID));


        AddPair(TJSONPair.Create('Factory', FZhiKa));
        AddPair(TJSONPair.Create('PModel', FID));
        AddPair(TJSONPair.Create('PType', FZhiKa));
        AddPair(TJSONPair.Create('PoundID', FID));

        if FSelected then
             AddPair(TJSONPair.Create('Selected', 'Y'))
        else AddPair(TJSONPair.Create('Selected', 'N'));


        AddPair(TJSONPair.Create('KZValue', FloatToStr(FKZValue)));
        AddPair(TJSONPair.Create('Memo', FMemo));

        nArrOne := TJSONArray.Create;
        with FPData do
        begin
          nJsonOne   := TJSONObject.Create;

          nJsonOne.AddPair(TJSONPair.Create('PStation', FStation));
          nJsonOne.AddPair(TJSONPair.Create('PValue', FloatToStr(FPData.FValue)));
          nJsonOne.AddPair(TJSONPair.Create('PDate', DateTimeToStr(FDate)));
          nJsonOne.AddPair(TJSONPair.Create('PMan', FOperator));

          nArrOne.Add(nJsonOne);
        end;


        with FMData do
        begin
          nJsonOne   := TJSONObject.Create;

          nJsonOne.AddPair(TJSONPair.Create('MStation', FStation));
          nJsonOne.AddPair(TJSONPair.Create('MValue', FloatToStr(FMData.FValue)));
          nJsonOne.AddPair(TJSONPair.Create('MDate', DateTimeToStr(FDate)));
          nJsonOne.AddPair(TJSONPair.Create('MMan', FOperator));

          nArrOne.Add(nJsonOne);
        end;

        AddPair(TJSONPair.Create('BFStations', nArrOne));
      end;

      nArrAll.Add(nJsonAll);
    end;

    Result := nJsonObject.ToString;
  finally
    nJsonObject.Free;
  end;
end;

procedure AnalyseBillItemsFromJSON(const nData: string;
  var nItems: TLadingBillItems);
begin
  //
end;

end.


