{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml, revicewstest, BPM2ERPService, HTTPApp, DateUtils;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
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

  THuaYan = record
    FReriNo:string;
    FValue:Double;
    FZLVal:Double;
    FCusID:string;
    FValidDate:string;
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    FHuaYan: array of THuaYan;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //获取卡片类型
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //登录注销，用于移动终端
    function GetServerNow(var nData: string): Boolean;
    //获取服务器时间
    function GetSerailID(var nData: string): Boolean;
    //获取串号
    function IsSystemExpired(var nData: string): Boolean;
    //系统是否已过期
    function CustomerMaCredLmt(var nData: string): Boolean;
    //验证客户是否强制信用额度
    function GetCustomerValidMoney(var nData: string): Boolean;
    //获取客户可用金
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //获取纸卡可用金
    function CustomerHasMoney(var nData: string): Boolean;
    //验证客户是否有钱
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //保存车辆到Truck表
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //存取车辆称重数据
    function VerifySnapTruck(var nData: string): Boolean;
    //车牌比对
    {$IFDEF QLS}
    function SyncAXCustomer(var nData: string): Boolean;//同步AX客户信息到DL
    function SyncAXProviders(var nData: string): Boolean;//同步AX供应商信息到DL
    function SyncAXINVENT(var nData: string): Boolean;//同步AX物料信息到DL
    function SyncAXCement(var nData: string): Boolean;//同步AX水泥类型到DL
    function SyncAXINVENTDIM(var nData: string): Boolean;//同步AX维度信息到DL
    function SyncAXTINVENTCENTER(var nData: string): Boolean;//同步AX生产线基础信息到DL
    function SyncAXINVENTLOCATION(var nData: string): Boolean;//同步AX仓库基础信息到DL
    function SyncAXTPRESTIGEMANAGE(var nData: string): Boolean;//同步AX信用额度（客户）信息到DL
    function SyncAXTPRESTIGEMBYCONT(var nData: string): Boolean;//同步AX信用额度（客户-合同）信息到DL
    function SyncAXEmpTable(var nData: string): Boolean;//同步AX员工信息到DL
    function SyncAXInvCenGroup(var nData :string): Boolean;//同步AX物料组生产线到DL
    function SyncAXwmsLocation(var nData :string): Boolean;//同步AX库位信息到DL
    //--------------------------------------------------------------------------
    function GetAXSalesOrder(var nData: string): Boolean;//获取销售订单
    function GetAXSalesOrdLine(var nData: string): Boolean;//获取销售订单行
    function GetAXSupAgreement(var nData: string): Boolean;//获取补充协议
    function GetAXCreLimCust(var nData: string): Boolean;//获取信用额度增减（客户）
    function GetAXCreLimCusCont(var nData: string): Boolean;//获取信用额度增减（客户-合同）
    function GetAXSalesContract(var nData: string): Boolean;//获取销售合同
    function GetAXSalesContLine(var nData: string): Boolean;//获取销售合同行
    function GetAXVehicleNo(var nData: string): Boolean;//获取车号
    function GetAXPurOrder(var nData: string): Boolean;//获取采购订单
    function GetAXPurOrdLine(var nData: string): Boolean;//获取采购订单行
    //--------------------------------------------------------------------------
    function SyncStockBillAX(var nData: string):Boolean;//同步交货单（发运计划）到AX
    function SyncDelSBillAX(var nData: string):Boolean;//同步删除交货单到AX
    function SyncPoundBillAX(var nData: string):Boolean;//同步磅单到AX
    function SyncPurPoundBillAX(var nData: string):Boolean;//同步磅单（采购）到AX
    function SyncVehicleNoAX(var nData: string):Boolean;//同步车号到AX
    function SyncEmptyOutBillAX(var nData: string):Boolean;//同步空车出厂交货单
    function GetSampleID(var nData: string):Boolean;//获取试样编号
    function GetSampleIDVIP(var nData: string):Boolean;//获取特殊试样编号
    function GetCenterID(var nData: string):Boolean;//获取生产线ID
    function GetTriangleTrade(var nData: string):Boolean;//本地订单表中获取是否三角贸易
    function GetCustNo(var nData: string):Boolean;//获取最终客户ID和公司ID
    function GetAXMaCredLmt(var nData: string): Boolean;//在线获取客户是否强制信用额度
    function GetAXContQuota(var nData: string): Boolean;//在线获取是否专款专用
    function GetAXTPRESTIGEMANAGE(var nData: string): Boolean;//在线获取AX信用额度（客户）信息到DL
    function GetAXTPRESTIGEMBYCONT(var nData: string): Boolean;//在线获取AX信用额度（客户-合同）信息到DL
    function GetAXCompanyArea(var nData: string): Boolean;//在线获取三角贸易订单的销售区域
    function GetInVentSum(var nData: string): Boolean;//在线获取生产线余量
    function GetSalesOrdValue(var nData: string): Boolean;//获取订单行余量
    function ReadZhikaInfo(var nData: string): Boolean;
    //读取销售订单信息
    function ReadStockPrice(var nData: string): Boolean;
    //读取订单物料价格
    function CheckSecurityCodeValid(var nData: string): Boolean;
    //防伪码校验
    function GetWaitingForloading(var nData: string):Boolean;
    //工厂待装查询
    function GetInOutFactoryTatol(var nData:string):Boolean;
    //进出厂量查询（采购进厂量、销售出厂量）
    function GetBillSurplusTonnage(var nData:string):boolean;
    //网上订单可下单数量查询
    function GetOrderInfo(var nData:string):Boolean;
    //获取订单信息，用于网上下单
    function GetOrderList(var nData:string):Boolean;
    //获取订单信息，用于网上下单
    function GetPurchaseContractList(var nData:string):Boolean;
    //获取采购订单列表，用于网上下单
    function getCustomerInfo(var nData:string):Boolean;
    //获取客户注册信息
    function get_Bindfunc(var nData:string):Boolean;
    //客户与微信账号绑定
    function send_event_msg(var nData:string):Boolean;
    //发送消息
    function edit_shopclients(var nData:string):Boolean;
    //新增商城用户
    function edit_shopgoods(var nData:string):Boolean;
    //添加商品
    function get_shoporders(var nData:string):Boolean;
    //获取订单信息
    function get_shoporderbyno(var nData:string):Boolean;
    //根据订单号获取订单信息-销售
    function get_shopPurchasebyNO(var nData:string):Boolean;
    //根据货单号获取货单信息-原材料
    function complete_shoporders(var nData:string):Boolean;
    //修改订单状态
    {$ENDIF}
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation
uses
  UWorkerClientWebChat,UMgrQueue,UDataModule,UHardBusiness;

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
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

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_CustomerMaCredLmt   : Result := CustomerMaCredLmt(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);
   cBC_VerifySnapTruck     : Result := VerifySnapTruck(nData);
   {$IFDEF QLS}
   cBC_SyncCustomer        : Result := SyncAXCustomer(nData);
   cBC_SyncProvider        : Result := SyncAXProviders(nData);
   cBC_SyncMaterails       : Result := SyncAXINVENT(nData);
   cBC_SyncAXCement        : Result := SyncAXCement(nData);
   cBC_SyncInvDim          : Result := SyncAXINVENTDIM(nData);
   cBC_SyncInvCenter       : Result := SyncAXTINVENTCENTER(nData);
   cBC_SyncInvLocation     : Result := SyncAXINVENTLOCATION(nData);
   cBC_SyncTprGem          : Result := SyncAXTPRESTIGEMANAGE(nData);
   cBC_SyncTprGemCont      : Result := SyncAXTPRESTIGEMBYCONT(nData);
   cBC_SyncEmpTable        : Result := SyncAXEmpTable(nData);
   cBC_SyncInvCenGroup     : Result := SyncAXInvCenGroup(nData);
   cBC_SyncFYBillAX        : Result := SyncStockBillAX(nData);
   cBC_SyncStockBill       : Result := SyncPoundBillAX(nData);
   cBC_SyncStockOrder      : Result := SyncPurPoundBillAX(nData);
   cBC_GetSalesOrder       : Result := GetAXSalesOrder(nData);
   cBC_GetSalesOrdLine     : Result := GetAXSalesOrdLine(nData);
   cBC_GetSupAgreement     : Result := GetAXSupAgreement(nData);
   cBC_GetCreLimCust       : Result := GetAXCreLimCust(nData);
   cBC_GetCreLimCusCont    : Result := GetAXCreLimCusCont(nData);
   cBC_GetSalesCont        : Result := GetAXSalesContract(nData);
   cBC_GetSalesContLine    : Result := GetAXSalesContLine(nData);
   cBC_GetVehicleNo        : Result := GetAXVehicleNo(nData);
   cBC_GetPurOrder         : Result := GetAXPurOrder(nData);
   cBC_GetPurOrdLine       : Result := GetAXPurOrdLine(nData);
   cBC_GetSampleID         : Result := GetSampleID(nData);
   cBC_GetSampleIDVIP      : Result := GetSampleIDVIP(nData);//特殊客户取试样编号
   cBC_GetCenterID         : Result := GetCenterID(nData);
   cBC_GetTprGem           : Result := GetAXTPRESTIGEMANAGE(nData);
   cBC_GetTprGemCont       : Result := GetAXTPRESTIGEMBYCONT(nData);
   cBC_SyncDelSBillAX      : Result := SyncDelSBillAX(nData);
   cBC_SyncEmpOutBillAX    : Result := SyncEmptyOutBillAX(nData);
   cBC_GetTriangleTrade    : Result := GetTriangleTrade(nData);
   cBC_GetAXMaCredLmt      : Result := GetAXMaCredLmt(nData);
   cBC_GetAXContQuota      : Result := GetAXContQuota(nData);
   cBC_GetCustNo           : Result := GetCustNo(nData);
   cBC_GetAXCompanyArea    : Result := GetAXCompanyArea(nData);
   cBC_GetAXInVentSum      : Result := GetInVentSum(nData);
   cBC_SyncAXwmsLocation   : Result := SyncAXwmsLocation(nData);
   cBC_GetSalesOrdValue    : Result := GetSalesOrdValue(nData);

   cBC_ReadZhiKaInfo       : Result := ReadZhikaInfo(nData);//读取销售订单信息
   cBC_ReadStockPrice      : Result := ReadStockPrice(nData);//读取订单物料价格
   cBC_VerifPrintCode      : Result := CheckSecurityCodeValid(nData); //验证码查询
   cBC_WaitingForloading   : Result := GetWaitingForloading(nData); //待装车辆查询

   cBC_BillSurplusTonnage  : Result := GetBillSurplusTonnage(nData); //查询商城订单可用量
   cBC_GetOrderInfo        : Result := GetOrderInfo(nData); //查询订单信息
   cBC_GetOrderList        : Result := GetOrderList(nData); //查询订单列表
   cBC_GetPurchaseContractList : Result := GetPurchaseContractList(nData); //查询采购合同列表

   cBC_WeChat_getCustomerInfo : Result := getCustomerInfo(nData);   //微信平台接口：获取客户注册信息
   cBC_WeChat_get_Bindfunc    : Result := get_Bindfunc(nData);   //微信平台接口：客户与微信账号绑定
   cBC_WeChat_send_event_msg  : Result := send_event_msg(nData);   //微信平台接口：发送消息
   cBC_WeChat_edit_shopclients : Result := edit_shopclients(nData);   //微信平台接口：新增商城用户
   cBC_WeChat_edit_shopgoods  : Result := edit_shopgoods(nData);   //微信平台接口：添加商品

   cBC_WeChat_get_shoporders  : Result := get_shoporders(nData);   //微信平台接口：获取订单信息
   cBC_WeChat_complete_shoporders  : Result := complete_shoporders(nData);   //微信平台接口：修改订单状态
   cBC_WeChat_get_shoporderbyno : Result := get_shoporderbyno(nData);   //微信平台接口：根据订单号获取订单信息(销售)
   cBC_WeChat_get_shopPurchasebyNO : Result := get_shopPurchasebyNO(nData);//微信平台接口：根据订单号获取订单信息(采购)

   cBC_WeChat_InOutFactoryTotal : Result := GetInOutFactoryTatol(nData);//进出厂量查询（采购进厂量、销售出厂量）
   {$ENDIF}
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: 获取卡片类型：销售S;采购P;其他O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名，密码；返回用户数据
//Desc: 用户登录
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //未传递用户名

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名；验证数据
//Desc: 用户注销
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: 获取服务器当前时间
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: 按规则生成序列编号
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有[ %s.%s ]的编码配置.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //按日期编码
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: 验证系统是否已过期
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := '系统已过期 %d 天,请联系管理员!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('系统在 %d 天后过期', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

{$IFDEF COMMON}
//2016-08-27
//验证客户是否强制信用额度
function TWorkerBusinessCommander.CustomerMaCredLmt(var nData: string): Boolean;
var
  nStr:string;
begin
  nStr := 'Select C_Name,C_MaCredLmt From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      if Fields[1].AsString='0' then //不限制信用额度
      begin
        FOut.FData := sFlag_No;
      end else
      begin
        FOut.FData := sFlag_Yes;
      end;
    end else
    begin
      FOut.FExtParam := '已删除';
    end;
  end;
  Result:=True;
end;

//Date: 2014-09-05
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nCredit: Double;
    nContractId: string;
    nAXMoney: Double;
    nContQuota: string;//1 专款专用
    nCusID:string;
    nFailureDate: TDateTime;
begin
  nStr := 'Select zk.Z_Customer,sc.C_ID,sc.C_ContQuota From $ZK zk,$SC sc ' +
          'Where zk.Z_ID=''$CID'' and zk.Z_CID=sc.C_ID';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
          MI('$SC', sTable_SaleContract)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    nCusID:=FieldByName('Z_Customer').AsString;
    nContQuota:= FieldByName('C_ContQuota').AsString;
    if nContQuota ='1' then
    begin
      nContractId:=FieldByName('C_ID').AsString;
      nStr := 'Select cc.* From $ZK,$CC cc ' +
              'Where Z_ID=''$CID'' and Z_Customer=C_CusID and C_ContractId=''$TID'' ';
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
              MI('$CC', sTable_CusContCredit), MI('$TID', nContractId)]);
    end else
    begin
      nStr := 'Select cc.* From $ZK,$CC cc ' +
              'Where Z_ID=''$CID'' and Z_Customer=C_CusID';
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
              MI('$CC', sTable_CusCredit)]);
    end;
  end;
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <1 then
    begin
      nAXMoney:=0;
    end else
    begin
      nFailureDate := FieldByName('C_FailureDate').AsDateTime;
      if (FieldByName('C_FailureDate').IsNull) or
        (FieldByName('C_FailureDate').AsString='') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1900-01-01') then
      begin
        nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
      end else
      begin
        nFailureDate := StrToDateTime(formatdatetime('yyyy-mm-dd',nFailureDate)+' 23:59:59');
        if nFailureDate >= Now then
        begin
          nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat+
                     FieldByName('C_TemporBalance').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
        end else
        begin
          nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
        end;
      end;
    end;
  end;


  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nCusID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;
    if nContQuota ='1' then
    begin
      nVal := nAXMoney-FieldByName('A_ConFreezeMoney').AsFloat
    end else
    begin
      nVal := nAXMoney-FieldByName('A_FreezeMoney').AsFloat;
    end;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if FIn.FExtParam = sFlag_Yes then
      nVal := nVal + nCredit;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;
{$ENDIF}

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在,或客户账户无效.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat +
            FieldByName('A_CreditLimit').AsFloat;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;
{$ENDIF}

//Date: 2014-09-05
//Desc: 验证客户是否有钱,以及信用是否过期
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  Result:=CustomerMaCredLmt(nData);
  if not Result then Exit;
  if FOut.FData = sFlag_No then
  begin
    FOut.FData := sFlag_Yes;
    Exit;
  end;
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('客户[ %s ]的资金余额不足.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s Where C_CusID=''%s'' and C_Money>=0';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime < Date()) then
  begin
    nData := Format('客户[ %s ]的信用已过期.', [nName]);
    Result := False;
  end;
end;

//Date: 2014-10-02
//Parm: 车牌号[FIn.FData];
//Desc: 保存车辆到sTable_Truck表
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: 车牌号(Truck); 表字段名(Field);数据值(Value)
//Desc: 更新车辆信息到sTable_Truck表
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: 车牌号[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 称重数据[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //保存车牌号

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '进厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

{$IFDEF XAZL}
//Date: 2014-10-14
//Desc: 同步新安中联原材料数据到DL系统
function TWorkerBusinessCommander.SyncRemoteMaterails(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select FItemID,FName,FNumber From t_ICItem ';// +
            //'Where (FFullName like ''%%原材料_主要材料%%'') or ' +
            //'(FFullName like ''%%原材料_燃料%%'')';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('M_ID', Fields[0].AsString),
                SF('M_Name', Fields[1].AsString),
                SF('M_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('M_Memo', GetPinYinOfStr(Fields[2].AsString))
                ], sTable_Materails, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'Delete From ' + sTable_Materails;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
{$ENDIF}
{$IFDEF QLS}
//Date:2016-06-26
//同步AX客户信息到DL
function TWorkerBusinessCommander.SyncAXCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result := True;

  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select AccountNum,Name,CreditMax,MandatoryCreditLimit,' +
              'CMT_KHYH,CMT_KHZH '+
              'From %s where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_Cust, gCompanyAct]);
    end else
    begin
      nStr := 'Select AccountNum,Name,CreditMax,MandatoryCreditLimit,' +
              'CMT_KHYH,CMT_KHZH '+
              'From %s where AccountNum=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_Cust, FIn.FData, FIn.FExtParam]);
    end;
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := MakeSQLByStr([SF('C_ID', FieldByName('AccountNum').AsString),
                SF('C_Name', FieldByName('Name').AsString),
                SF('C_PY', GetPinYinOfStr(FieldByName('Name').AsString)),
                SF('C_CredMax', FieldByName('CreditMax').AsString),
                SF('C_MaCredLmt', FieldByName('MandatoryCreditLimit').AsString),
                SF('C_Bank', FieldByName('CMT_KHYH').AsString),
                SF('C_Account', FieldByName('CMT_KHZH').AsString),
                SF('C_XuNi', sFlag_No)
                ], sTable_Customer, '', True);
        FListA.Add(nStr);
        nStr := MakeSQLByStr([SF('A_CID', FieldByName('AccountNum').AsString),
                SF('A_Date', sField_SQLServer_Now, sfVal)
                ], sTable_CusAccount, '', True);
        FListB.Add(nStr);

        nStr := SF('C_ID', FieldByName('AccountNum').AsString);
        nStr := MakeSQLByStr([
                SF('C_Name', FieldByName('Name').AsString),
                SF('C_PY', GetPinYinOfStr(FieldByName('Name').AsString)),
                SF('C_CredMax', FieldByName('CreditMax').AsString),
                SF('C_MaCredLmt', FieldByName('MandatoryCreditLimit').AsString),
                SF('C_Bank', FieldByName('CMT_KHYH').AsString),
                SF('C_Account', FieldByName('CMT_KHZH').AsString)
                ], sTable_Customer, nStr, False);
        FListC.Add(nStr);

        nStr:='select * from %s where C_ID=''%s'' ';
        nStr := Format(nStr, [sTable_Customer, FieldByName('AccountNum').AsString]);
        FListD.Add(nStr);
        nStr:='select * from %s where A_CID=''%s'' ';
        nStr := Format(nStr, [sTable_CusAccount, FieldByName('AccountNum').AsString]);
        FListE.Add(nStr);
      finally
        Next;
      end;
    end else
    begin
      Result:=False;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if (FListD.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //开启事务
    for nIdx:=0 to FListD.Count - 1 do
    begin
      with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
      begin
        if RecordCount>0 then
        begin
          gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
        end else
        begin
          gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
        end;
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
  if (FListE.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //开启事务
    for nIdx:=0 to FListE.Count - 1 do
    begin
      with gDBConnManager.WorkerQuery(FDBConn,FListE[nIdx]) do
      begin
        if RecordCount<1 then
        begin
          gDBConnManager.WorkerExec(FDBConn,FListB[nIdx]);
        end;
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-6-26
//同步AX供应商信息到DL
function TWorkerBusinessCommander.SyncAXProviders(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nSaler := '待分配业务员';
    nStr := 'Select AccountNum,Name From %s where DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_VEND, gCompanyAct]);
    //未删除供应商

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('P_ID', Fields[0].AsString),
                SF('P_Name', Fields[1].AsString),
                SF('P_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('P_Saler', nSaler)
                ], sTable_Provider, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    //开启事务

    nStr := 'truncate table ' + sTable_Provider;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-06-26
//同步AX原材料信息到DL
function TWorkerBusinessCommander.SyncAXINVENT(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select ItemId,ItemName,ItemGroupId,Weighning From %s '+
            'where DataAreaID=''%s'' and Weighning=''1'' ';
    nStr := Format(nStr, [sTable_AX_INVENT, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('M_ID', Fields[0].AsString),
                SF('M_Name', Fields[1].AsString),
                SF('M_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('M_GroupID', Fields[2].AsString),
                SF('M_Weighning', Fields[3].AsString)
                ], sTable_Materails, '', True);
        //xxxxx
        FListA.Add(nStr);
        
        nStr:='select * from %s where M_ID=''%s'' ';
        nStr := Format(nStr, [sTable_Materails, Fields[0].AsString]);
        FListB.Add(nStr);

        nStr := SF('M_ID', Fields[0].AsString);
        nStr := MakeSQLByStr([SF('M_Name', Fields[1].AsString),
                SF('M_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('M_GroupID', Fields[2].AsString),
                SF('M_Weighning', Fields[3].AsString)
                ], sTable_Materails, nStr, False);
        //xxxxx
        FListC.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListB.Count - 1 do
    begin
      with gDBConnManager.WorkerQuery(FDBConn,FListB[nIdx]) do
      begin
        if RecordCount>0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end else
        begin
          gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
        end;
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
//Date:2016-06-26
//同步AX水泥信息到DL
function TWorkerBusinessCommander.SyncAXCement(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select ItemId,ItemName,ItemGroupId From %s where DataAreaID=''%s'' and ((ITEMGROUPID = ''C01'') or (ITEMGROUPID = ''C02'')) ';
    nStr := Format(nStr, [sTable_AX_INVENT, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                SF('D_ParamB', Fields[0].AsString),
                SF('D_Value', Fields[1].AsString+'袋装'),
                SF('D_Desc', Fields[2].AsString),
                SF('D_Memo', 'D')
                ], sTable_SysDict, '', True);
        //xxxxx
        FListA.Add(nStr);

        nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
                SF('D_ParamB', Fields[0].AsString),
                SF('D_Value', Fields[1].AsString+'散装'),
                SF('D_Desc', Fields[2].AsString),
                SF('D_Memo', 'S')
                ], sTable_SysDict, '', True);
        //xxxxx
        FListA.Add(nStr);

        nStr:='select * from %s where D_Name=''StockItem'' and D_Memo=''D'' and D_ParamB=''%s'' ';
        nStr := Format(nStr, [sTable_SysDict, Fields[0].AsString]);
        FListB.Add(nStr);

        nStr:='select * from %s where D_Name=''StockItem'' and D_Memo=''S'' and D_ParamB=''%s'' ';
        nStr := Format(nStr, [sTable_SysDict, Fields[0].AsString]);
        FListB.Add(nStr);

        nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'D')+' and '+SF('D_ParamB', Fields[0].AsString);
        nStr := MakeSQLByStr([SF('D_Value', Fields[1].AsString+'袋装'),
                SF('D_Desc', Fields[2].AsString)
                ], sTable_SysDict, nStr, False);
        //xxxxx
        FListC.Add(nStr);

        nStr := SF('D_Name', 'StockItem')+' and '+SF('D_Memo', 'S')+' and '+SF('D_ParamB', Fields[0].AsString);
        nStr := MakeSQLByStr([SF('D_Value', Fields[1].AsString+'散装'),
                SF('D_Desc', Fields[2].AsString)
                ], sTable_SysDict, nStr, False);
        //xxxxx
        FListC.Add(nStr);

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListB.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListB.Count - 1 do
    begin
      with gDBConnManager.WorkerQuery(FDBConn,FListB[nIdx]) do
      begin
        if RecordCount>0 then
        begin
          gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
        end else
        begin
          gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
        end;
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-06-26
//同步AX维度信息到DL
function TWorkerBusinessCommander.SyncAXINVENTDIM(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select INVENTDIMID,INVENTBATCHID,WMSLOCATIONID,INVENTSERIALID,'+
            'INVENTLOCATIONID,DATAAREAID,RECVERSION,RECID,XTINVENTCENTERID '+
            'From %s where DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_INVENTDIM, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('I_DimID', Fields[0].AsString),
                SF('I_BatchID', Fields[1].AsString),
                SF('I_WMSLocationID', Fields[2].AsString),
                SF('I_SerialID', Fields[3].AsString),
                SF('I_LocationID', Fields[4].AsString),
                SF('I_DatareaID', Fields[5].AsString),
                SF('I_RecVersion', Fields[6].AsString),
                SF('I_RECID', Fields[7].AsString),
                SF('I_CenterID', Fields[8].AsString)
                ], sTable_InventDim, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_InventDim;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-06-26
//同步AX生产线基础信息到DL
function TWorkerBusinessCommander.SyncAXTINVENTCENTER(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select InventCenterId,Name From %s where DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_INVENTCENTER, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('I_CenterID', Fields[0].AsString),
                SF('I_Name', Fields[1].AsString),
                SF('I_DataReaID', gCompanyAct)
                ], sTable_InventCenter, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_InventCenter;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-06-26
//同步AX仓库基础信息到DL
function TWorkerBusinessCommander.SyncAXINVENTLOCATION(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select INVENTLOCATIONID,Name,DataAreaID From %s where DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_INVENTLOCATION, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('I_LocationID', Fields[0].AsString),
                SF('I_Name', Fields[1].AsString),
                SF('I_DataReaID', Fields[2].AsString)
                ], sTable_InventLocation, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_InventLocation;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date:2016-06-26
//同步AX信用额度（客户）信息到DL
function TWorkerBusinessCommander.SyncAXTPRESTIGEMANAGE(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  Result := True;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select CustAccount,CustName,CashBalance,BillBalanceThreeMonths,'+
            'BillBalancesixMonths,PrestigeQuota,TemporaryBalance,TemporaryAmount,'+
            'WarningAmount,TemporaryTakeEffect,FailureDate,XTETempCreditNum,'+
            'XTFixedPrestigeStatus,YKAMOUNT From %s '+
            'where DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_TPRESTIGEMANAGE, gCompanyAct]);
    //xxxxx
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('C_CusID', Fields[0].AsString),
                SF('C_Date', sField_SQLServer_Now, sfVal),
                SF('C_CustName', Fields[1].AsString),
                SF('C_CashBalance', Fields[2].AsString),
                SF('C_BillBalance3M', Fields[3].AsString),
                SF('C_BillBalance6M', Fields[4].AsString),
                SF('C_PrestigeQuota', Fields[5].AsString),
                SF('C_TemporBalance', Fields[6].AsString),
                SF('C_TemporAmount', Fields[7].AsString),
                SF('C_WarningAmount', Fields[8].AsString),
                SF('C_TemporTakeEffect', Fields[9].AsString),
                SF('C_FailureDate', Fields[10].AsString),
                SF('C_LSCreditNum', Fields[11].AsString),
                SF('C_PrestigeStatus', Fields[12].AsString),
                SF('DataAreaID', gCompanyAct)
                ], sTable_CusCredit, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_CusCredit;
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
    //Result:=False;
  end;
  FOut.FData:=sFlag_Yes;
end;

//lih 2016-09-23
//本地订单表中获取是否三角贸易
function TWorkerBusinessCommander.GetTriangleTrade(var nData: string):Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select Z_TriangleTrade From $ZK Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的销售订单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    if FieldByName('Z_TriangleTrade').AsString='1' then
      FOut.FData := sFlag_Yes
    else
      FOut.FData := sFlag_No;
    Result:=True;
  end;
end;

//lih 2016-09-23
//获取最终客户ID和公司ID
function TWorkerBusinessCommander.GetCustNo(var nData: string):Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select Z_OrgAccountNum,Z_CompanyId,DataAreaID From $ZK Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的销售订单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    FOut.FData := FieldByName('Z_OrgAccountNum').AsString;
    if FieldByName('Z_CompanyId').AsString <> '' then
      FOut.FExtParam := FieldByName('Z_CompanyId').AsString
    else
      FOut.FExtParam := FieldByName('DataAreaID').AsString;
    Result:=True;
  end;
end;

//lih 2016-09-23
//在线获取客户是否强制信用额度
function TWorkerBusinessCommander.GetAXMaCredLmt(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  Result := False;
  nDBWorker := nil;
  try
    nStr := 'Select MandatoryCreditLimit From %s '+
            'where AccountNum=''%s'' and DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_Cust, FIn.FData, FIn.FExtParam]);
    //xxxxx
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nData := '编号为[ %s ]的客户不存在.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
      if FieldByName('MandatoryCreditLimit').AsString='1' then
        FOut.FData := sFlag_Yes
      else
        FOut.FData := sFlag_No;
      Result:=True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//lih 2016-09-23
//在线获取是否专款专用
function TWorkerBusinessCommander.GetAXContQuota(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  Result := False;
  nDBWorker := nil;
  try
    nStr := 'Select XTContactQuota,ContactId From %s a left join %s b on a.ContactId=b.CMT_ContractNo '+
            'where SalesId=''%s'' and b.DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_SalesCont, sTable_AX_Sales, FIn.FData, FIn.FExtParam]);
    //xxxxx
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount < 1 then
      begin
        nData := '编号为[ %s ]的订单无销售合同.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
      if FieldByName('XTContactQuota').AsString='1' then
        FOut.FData := sFlag_Yes
      else
        FOut.FData := sFlag_No;
      FOut.FExtParam := FieldByName('ContactId').AsString;
      Result:=True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//lih 2016-09-02
//在线获取AX信用额度（客户）信息到DL
function TWorkerBusinessCommander.GetAXTPRESTIGEMANAGE(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nBalance:Double;
    nFailureDate:TDateTime;
begin
  Result := False;
  nBalance:=0.00;
  nDBWorker := nil;
  try
    nStr := 'Select CustAccount,CustName,CashBalance,BillBalanceThreeMonths,'+
            'BillBalancesixMonths,PrestigeQuota,TemporaryBalance,TemporaryAmount,'+
            'WarningAmount,TemporaryTakeEffect,FailureDate,XTETempCreditNum,'+
            'XTFixedPrestigeStatus,YKAMOUNT From %s '+
            'where CustAccount=''%s'' and DataAreaID=''%s'' ';
    nStr := Format(nStr, [sTable_AX_TPRESTIGEMANAGE, FIn.FData, FIn.FExtParam]);
    //xxxxx
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      WriteLog('客户ID:'+Fields[0].AsString);
      nFailureDate := FieldByName('FailureDate').AsDateTime;
      if (FieldByName('FailureDate').IsNull) or
        (FieldByName('FailureDate').AsString='') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1900-01-01') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1899-01-01') then
      begin
        nBalance:=FieldByName('CashBalance').AsFloat+
                  FieldByName('BillBalanceThreeMonths').AsFloat+
                  FieldByName('BillBalancesixMonths').AsFloat-
                  FieldByName('PrestigeQuota').AsFloat;
      end else
      begin
        nFailureDate := StrToDateTime(formatdatetime('yyyy-mm-dd',nFailureDate)+' 23:59:59');
        if nFailureDate >= Now then
        begin
          nBalance:=FieldByName('CashBalance').AsFloat+
                    FieldByName('BillBalanceThreeMonths').AsFloat+
                    FieldByName('BillBalancesixMonths').AsFloat+
                    FieldByName('TemporaryBalance').AsFloat-
                    FieldByName('PrestigeQuota').AsFloat;
        end else
        begin
          nBalance:=FieldByName('CashBalance').AsFloat+
                  FieldByName('BillBalanceThreeMonths').AsFloat+
                  FieldByName('BillBalancesixMonths').AsFloat-
                  FieldByName('PrestigeQuota').AsFloat;
        end;
      end;
      if nBalance>0 then
        FOut.FData:=sFlag_Yes
      else
        FOut.FData:=sFlag_No;
      FOut.FExtParam:=FloatToStr(nBalance);
      Result:=True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date:2016-06-26
//同步AX信用额度（客户-合同）信息到DL
function TWorkerBusinessCommander.SyncAXTPRESTIGEMBYCONT(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nBalance:Double;
begin
  Result := True;
  FListA.Clear;
  nDBWorker := nil;
  try
    nStr := 'Select CustAccount,CustName,CMT_ContractId,CashBalance,'+
            'BillBalanceThreeMonths,BillBalancesixMonths,PrestigeQuota,'+
            'TemporaryBalance,TemporaryAmount,WarningAmount,TemporaryTakeEffect,'+
            'FailureDate,XTETempCreditNum,YKAMOUNT From %s where DataAreaID=''%s''';
    nStr := Format(nStr, [sTable_AX_TPRESTIGEMBYCONT, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('C_CusID', Fields[0].AsString),
                SF('C_Date', sField_SQLServer_Now, sfVal),
                SF('C_CustName', Fields[1].AsString),
                SF('C_ContractId', Fields[2].AsString),
                SF('C_CashBalance', Fields[3].AsString),
                SF('C_BillBalance3M', Fields[4].AsString),
                SF('C_BillBalance6M', Fields[5].AsString),
                SF('C_PrestigeQuota', Fields[6].AsString),
                SF('C_TemporBalance', Fields[7].AsString),
                SF('C_TemporAmount', Fields[8].AsString),
                SF('C_WarningAmount', Fields[9].AsString),
                SF('C_TemporTakeEffect', Fields[10].AsString),
                SF('C_FailureDate', Fields[11].AsString),
                SF('C_LSCreditNum', Fields[12].AsString),
                SF('DataAreaID', gCompanyAct)
                ], sTable_CusContCredit, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_CusContCredit;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);

    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
    //Result:=False;
  end;
  FOut.FData:=sFlag_Yes;
end;

//lih 2016-09-02
//在线获取AX信用额度（客户-合同）信息到DL
function TWorkerBusinessCommander.GetAXTPRESTIGEMBYCONT(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nPos: Integer;
    nCusID,nConID:string;
    nBalance: Double;
    nFailureDate: TDateTime;
begin
  Result := False;
  nDBWorker := nil;
  nBalance:=0.00;
  try
    nPos:=Pos(',', FIn.FData);
    if nPos >0 then
    begin
      nCusID:=Copy(FIn.FData,1,nPos-1);
      nConID:=Copy(FIn.FData,nPos+1,Length(FIn.FData)-nPos);
    end;
    if (nCusID='') or (nConID='') then
    begin
      Result:=False;
      WriteLog('信息不全');
      Exit;
    end;
    nStr := 'Select CustAccount,CustName,CMT_ContractId,CashBalance,'+
            'BillBalanceThreeMonths,BillBalancesixMonths,PrestigeQuota,'+
            'TemporaryBalance,TemporaryAmount,WarningAmount,TemporaryTakeEffect,'+
            'FailureDate,XTETempCreditNum,YKAMOUNT From %s '+
            'where CustAccount=''%s'' and CMT_ContractId=''%s'' and DataAreaID=''%s''';
    nStr := Format(nStr, [sTable_AX_TPRESTIGEMBYCONT, nCusID, nConID, FIn.FExtParam]);
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      WriteLog('客户ID：'+Fields[0].AsString+'  合同ID；'+Fields[2].AsString);
      nFailureDate := FieldByName('FailureDate').AsDateTime;
      if (FieldByName('FailureDate').IsNull) or
        (FieldByName('FailureDate').AsString='') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1900-01-01') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1899-01-01') then
      begin
        nBalance:=FieldByName('CashBalance').AsFloat+
                  FieldByName('BillBalanceThreeMonths').AsFloat+
                  FieldByName('BillBalancesixMonths').AsFloat-
                  FieldByName('PrestigeQuota').AsFloat;
      end else
      begin
        nFailureDate := StrToDateTime(formatdatetime('yyyy-mm-dd',nFailureDate)+' 23:59:59');
        if nFailureDate >= Now then
        begin
          nBalance:=FieldByName('CashBalance').AsFloat+
                    FieldByName('BillBalanceThreeMonths').AsFloat+
                    FieldByName('BillBalancesixMonths').AsFloat+
                    FieldByName('TemporaryBalance').AsFloat-
                    FieldByName('PrestigeQuota').AsFloat;
        end else
        begin
          nBalance:=FieldByName('CashBalance').AsFloat+
                  FieldByName('BillBalanceThreeMonths').AsFloat+
                  FieldByName('BillBalancesixMonths').AsFloat-
                  FieldByName('PrestigeQuota').AsFloat;
        end;
      end;
      if nBalance>0 then
        FOut.FData:=sFlag_Yes
      else
        FOut.FData:=sFlag_No;
      FOut.FExtParam:=FloatToStr(nBalance);
      Result:=True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//在线获取三角贸易订单客户的销售区域
function TWorkerBusinessCommander.GetAXCompanyArea(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nXSQYMC: string;
begin
  Result := False;
  nDBWorker := nil;
  try
    nStr := 'select XSQYMC from %s a '+
            'left join %s b on a.XSQYBM=b.XSQYBM '+
            'where salesid=''%s'' and dataareaid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_Sales,sTable_AX_CompArea, FIn.FData, FIn.FExtParam]);
    //xxxxx
    //WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      nXSQYMC:= FieldByName('XSQYMC').AsString;
      FOut.FData:=nXSQYMC;
    end else
    begin
      FOut.FData:='';
    end;
    Result:=True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//在线获取生产线余量
function TWorkerBusinessCommander.GetInVentSum(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  Result := False;
  nDBWorker := nil;
  try
    //nStr := 'select sum(PostedQty+Received-Deducted+Registered-Picked-ReservPhysical) as Yuliang from %s '+
    nStr := 'select sum(PostedQty+Received-Deducted+Registered-Picked) as Yuliang from %s '+
            'where itemid=''%s'' and xtInventCenterId=''%s'' and dataareaid=''%s'' ';
    nStr := Format(nStr, [sTable_AX_InventSum, FIn.FData, FIn.FExtParam, gCompanyAct]);
    //xxxxx
    WriteLog(nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      FOut.FData:=FieldByName('Yuliang').AsString;
    end else
    begin
      FOut.FData:='0';
    end;
    Result:=True;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//获取订单行余量
function TWorkerBusinessCommander.GetSalesOrdValue(var nData: string): Boolean;
var nStr: string;
    nSendValue,nTotalValue,nValue :Double;
begin
  Result := False;
  nSendValue := 0;

  nStr := 'select IsNull(SUM(L_Value),''0'') as SendValue from %s where L_LineRecID=''%s'' ';
  nStr := Format(nStr,[sTable_Bill, Fin.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nSendValue := Fields[0].AsFloat;
  end;

  nStr := 'select D_TotalValue from %s Where D_RECID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, Fin.FData]);
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nTotalValue := Fields[0].AsFloat;
    if (nTotalValue > 0) and (nTotalValue > nSendValue) then
      nValue := nTotalValue-nSendValue
    else
      nValue := 0;
    FOut.FData := FloatToStr(nValue);
    Result := True;
  end else
  begin
    FOut.FData := '0';
    Result := True;
  end;
end;

function TWorkerBusinessCommander.SyncAXEmpTable(var nData: string): Boolean;//同步AX员工信息到DL
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select EmplId,Name From %s where DataAreaID=''%s''';
    nStr := Format(nStr, [STable_AX_EMPL, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('EmplId', Fields[0].AsString),
                SF('EmplName', Fields[1].AsString),
                SF('DataAreaID', gCompanyAct)
                ], sTable_EMPL, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_EMPL;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.SyncAXInvCenGroup(var nData :string): Boolean;//同步AX物料组生产线到DL
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select ItemGroupId,InventCenterId From %s where DataAreaID=''%s''';
    nStr := Format(nStr, [sTable_AX_InvCenGroup, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('G_ItemGroupID', Fields[0].AsString),
                SF('G_InventCenterID', Fields[1].AsString),
                SF('DataAreaID', gCompanyAct)
                ], sTable_InvCenGroup, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_InvCenGroup;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//同步AX库位信息到DL
function TWorkerBusinessCommander.SyncAXwmsLocation(var nData :string): Boolean;
var nStr,nType: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select InventLocationID,WMSLocationID From %s where DataAreaID=''%s''';
    nStr := Format(nStr, [sTable_AX_WMSLocation, gCompanyAct]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        if (Pos('熟料库',Fields[1].AsString)>0) then
          nType:= '熟料'
        else if (Pos('站',Fields[1].AsString)>0) then
          nType:= '袋装'
        else if (Pos('水泥',Fields[1].AsString)>0) then
          nType:= '散装'
        else nType:= '';

        nStr := MakeSQLByStr([SF('K_Type', nType),
                SF('K_LocationID', Fields[0].AsString),
                SF('K_KuWeiNo', Fields[1].AsString)
                ], sTable_KuWei, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'truncate table ' + sTable_KuWei;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
//------------------------------------------------------------------------------

//Date: 2016-06-29
//获取AX销售订单
function TWorkerBusinessCommander.GetAXSalesOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_Sales, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where SalesId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_Sales, FIn.FData, gCompanyAct]);
    end;

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0  then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('Z_ID', FieldByName('SalesId').AsString),
                  SF('Z_Name', FieldByName('SalesName').AsString),
                  SF('Z_CID', FieldByName('CMT_ContractNo').AsString),
                  SF('Z_Customer', FieldByName('CustAccount').AsString),
                  SF('Z_ValidDays', FieldByName('FixedDueDate').AsString),
                  SF('Z_SalesStatus', FieldByName('salesstatus').AsString),
                  SF('Z_SalesType', FieldByName('SalesType').AsString),
                  SF('Z_TriangleTrade', FieldByName('CMT_TriangleTrade').AsString),
                  SF('Z_OrgAccountNum', FieldByName('CMT_OrgAccountNum').AsString),
                  SF('Z_OrgAccountName', FieldByName('CMT_OrgAccountName').AsString),
                  SF('Z_IntComOriSalesId', FieldByName('InterCompanyOriginalSalesId').AsString),
                  SF('Z_XSQYBM', FieldByName('XSQYBM').AsString),
                  SF('Z_KHSBM', FieldByName('CMT_KHSBM').AsString),
                  SF('Z_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                  SF('Z_Lading', FieldByName('XTFreightNew').AsString),
                  SF('Z_CompanyId', FieldByName('InterCompanyCompanyId').AsString),
                  SF('DataAreaID', gCompanyAct)
                  ], sTable_ZhiKa, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_ZhiKa
    else
      nStr := 'delete from ' + sTable_ZhiKa + 'where Z_ID='''+FIn.FData+'''';
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXSalesOrdLine(var nData: string): Boolean;//获取销售订单行
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nPos:Integer;
    sId,LNum:string;
    nType,nStockName: string;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    nStr:= FIn.FData;
    if nStr='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalLine, gCompanyAct]);
    end else
    begin
      nPos:=Pos(',',nStr);
      sId:=Copy(nStr,1,nPos-1);
      LNum:=Copy(nStr,nPos+1,Length(nStr)-nPos);

      nStr := 'Select * From %s Where SalesId=''%s'' and Recid=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalLine, sId, LNum, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount >0 then
      begin
        First;
        while not Eof do
        begin
          if FieldByName('CMT_PACKTYPE').AsString='1' then
            nType:='D'
          else if FieldByName('CMT_PACKTYPE').AsString='2' then
            nType:='S'
          else
            nType:=FieldByName('CMT_PACKTYPE').AsString;
          nStockName:= FieldByName('Name').AsString;
          nStockName:= StringReplace(nStockName,'"','',[rfReplaceAll]);
          nStr := MakeSQLByStr([SF('D_ZID', FieldByName('SalesId').AsString),
                    SF('D_RECID', FieldByName('Recid').AsString),
                    SF('D_Type', nType),
                    SF('D_StockNo', FieldByName('ItemId').AsString),
                    SF('D_StockName', nStockName),
                    SF('D_SalesStatus', FieldByName('SalesStatus').AsString),
                    SF('D_Price', FieldByName('SalesPrice').AsString),
                    SF('D_Value', FieldByName('RemainSalesPhysical').AsString),
                    SF('D_TotalValue', FieldByName('SalesQty').AsString),
                    SF('D_Blocked', FieldByName('Blocked').AsString),
                    SF('D_Memo', FieldByName('CMT_Notes').AsString),
                    SF('DataAreaID', gCompanyAct)
                    ], sTable_ZhiKaDtl, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_ZhiKaDtl
    else
      nStr := 'delete from ' + sTable_ZhiKaDtl + 'where D_ZID='''+sId+''' and D_RECID=''%s'' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXSupAgreement(var nData: string): Boolean;//获取补充协议
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SupAgre, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where XTEadjustBillNum=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SupAgre, FIn.FData, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('A_XTEadjustBillNum', FieldByName('XTEadjustBillNum').AsString),
                    SF('A_SalesId', FieldByName('SalesId').AsString),
                    SF('A_ItemId', FieldByName('itemid').AsString),
                    SF('A_SalesNewAmount', FieldByName('SalesNewAmount').AsString),
                    SF('A_TakeEffectDate', FieldByName('TakeEffectDate').AsString),
                    SF('A_TakeEffectTime', FieldByName('TakeEffectTime').AsString),
                    SF('RefRecid', FieldByName('RefRecid').AsString),
                    SF('Recid', FieldByName('RecId').AsString),
                    SF('DataAreaID', gCompanyAct),
                    SF('A_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now))
                    ], sTable_AddTreaty, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_AddTreaty
    else
      nStr := 'delete from ' + sTable_AddTreaty + 'where A_XTEadjustBillNum='''+FIn.FData+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXCreLimCust(var nData: string): Boolean;//获取信用额度增减（客户）
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nData:='参数无效.';
      Result:=False;
      Exit;
    end else
    begin
      nStr := 'Select * From %s Where RecId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_CreLimLog, FIn.FData, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('C_CusID', FieldByName('CustAccount').AsString),
                    SF('C_SubCash', FieldByName('XTSubCash').AsString),
                    SF('C_SubThreeBill', FieldByName('XTSubThreeBill').AsString),
                    SF('C_SubSixBil', FieldByName('XTSubSixBill').AsString),
                    SF('C_SubTmp', FieldByName('XTSubTmp').AsString),
                    SF('C_SubPrest', FieldByName('XTSubCash').AsString),
                    SF('C_Createdby', FieldByName('Createdby').AsString),
                    SF('C_Createdate', FieldByName('Createdate').AsString),
                    SF('C_Createtime', FieldByName('createtime').AsString),
                    SF('DataAreaID', FieldByName('DataReaID').AsString),
                    SF('RecID', FieldByName('RecId').AsString)
                    ], sTable_CustPresLog, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXCreLimCusCont(var nData: string): Boolean;//获取信用额度增减（客户-合同）
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nData := '参数无效.';
      Result:=False;
      Exit;
    end else
    begin
      nStr := 'Select * From %s Where RecId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_CreLimLog, FIn.FData, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('C_CusID', FieldByName('CustAccount').AsString),
                    SF('C_SubCash', FieldByName('XTSubCash').AsString),
                    SF('C_SubThreeBill', FieldByName('XTSubThreeBill').AsString),
                    SF('C_SubSixBil', FieldByName('XTSubSixBill').AsString),
                    SF('C_SubTmp', FieldByName('XTSubTmp').AsString),
                    SF('C_SubPrest', FieldByName('XTSubCash').AsString),
                    SF('C_Createdby', FieldByName('Createdby').AsString),
                    SF('C_Createdate', FieldByName('Createdate').AsString),
                    SF('C_Createtime', FieldByName('createtime').AsString),
                    SF('DataAreaID', FieldByName('DataAreaID').AsString),
                    SF('RecID', FieldByName('RecId').AsString)
                    ], sTable_CustPresLog, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXSalesContract(var nData: string): Boolean;//获取销售合同
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where companyid=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalesCont, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where ContactId=''%s'' and companyid=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalesCont, FIn.FData, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('C_ID', FieldByName('ContactId').AsString),
                    SF('C_CustName', FieldByName('custname').AsString),
                    SF('C_Customer', FieldByName('CUST').AsString),
                    SF('C_Addr', FieldByName('ContactAddress').AsString),
                    SF('C_SFSP', FieldByName('CMT_SFSP').AsString),
                    SF('C_ContType', FieldByName('xtEContractSuperType').AsString),
                    SF('C_ContQuota', FieldByName('XTContactQuota').AsString),
                    SF('C_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                    SF('DataAreaID', gCompanyAct)
                    ], sTable_SaleContract, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_SaleContract
    else
      nStr := 'delete from ' + sTable_SaleContract + 'where C_ID='''+FIn.FData+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXSalesContLine(var nData: string): Boolean;//获取销售合同行
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nType: string;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalContLine, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where ContactId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_SalContLine, FIn.FData, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          if FieldByName('packtype').AsString='1' then
            nType:='D'
          else if FieldByName('packtype').AsString='2' then
            nType:='S'
          else
            nType:=FieldByName('packtype').AsString;
          nStr := MakeSQLByStr([SF('E_CID', FieldByName('ContactId').AsString),
                    SF('E_Type', nType),
                    SF('E_StockNo', FieldByName('itemid').AsString),
                    SF('E_StockName', FieldByName('itemname').AsString),
                    SF('E_Value', FieldByName('qty').AsString),
                    SF('E_Price', FieldByName('price').AsString),
                    SF('E_Money', FieldByName('amount').AsString),
                    SF('E_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                    SF('DataAreaID', gCompanyAct)
                    ], sTable_SContractExt, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_SContractExt
    else
      nStr := 'delete from ' + sTable_SContractExt + 'where E_CID='''+FIn.FData+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXVehicleNo(var nData: string): Boolean;//获取车号
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nPreUse,nPreValue: string;
begin
  FListA.Clear;
  Result:=True;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where companyid=''%s'' ';
      nStr := Format(nStr, [sTable_AX_VehicleNo, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where VehicleId=''%s'' and companyid=''%s'' ';
      nStr := Format(nStr, [sTable_AX_VehicleNo, FIn.FData]);
    end;
    {$IFDEF DEBUG}
    WriteLog(nStr);
    {$ENDIF}
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          {if FieldByName('VehicleType').AsString='散装' then
            nPreUse:='Y'
          else}
            nPreUse:='N';
          nPreValue:= FieldByName('TAREWEIGHT').AsString;
          if not IsNumber(nPreValue,True) then nPreValue:='0.00';
          nStr := MakeSQLByStr([SF('T_Truck', FieldByName('VehicleId').AsString),
                    SF('T_Owner', FieldByName('CZ').AsString),
                    SF('T_PrePUse', nPreUse),
                    SF('T_PrePValue', nPreValue),
                    SF('T_Driver', FieldByName('DriverId').AsString),
                    SF('T_Card', FieldByName('CMT_PrivateId').AsString),
                    SF('T_CompanyID', FieldByName('companyid').AsString),
                    SF('T_XTECB', FieldByName('XTECB').AsString),
                    SF('T_VendAccount', FieldByName('VendAccount').AsString)
                    ], sTable_Truck, '', True);
            FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_Truck
    else
      nStr := 'delete from ' + sTable_Truck + 'where T_Truck='''+FIn.FData+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXPurOrder(var nData: string): Boolean;//获取采购订单
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s''';
      nStr := Format(nStr, [sTable_AX_PurOrder, gCompanyAct]);
    end else
    begin
      nStr := 'Select * From %s Where PurchId=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_PurOrder, FIn.FData, gCompanyAct]);
    end;

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStr := MakeSQLByStr([SF('M_ID', FieldByName('PurchId').AsString),
                    SF('M_ProID', FieldByName('OrderAccount').AsString),
                    SF('M_ProName', FieldByName('PURCHNAME').AsString),
                    SF('M_ProPY', GetPinYinOfStr(FieldByName('PURCHNAME').AsString)),
                    SF('M_CID', FieldByName('xtContractId').AsString),
                    SF('M_BStatus', FieldByName('PurchStatus').AsString),
                    SF('M_TriangleTrade', FieldByName('CMT_TriangleTrade').AsString),
                    SF('M_IntComOriSalesId', FieldByName('InterCompanyOriginalSalesId').AsString),
                    SF('M_PurchType', FieldByName('PurchaseType').AsString),
                    SF('M_DState', FieldByName('DocumentState').AsString),
                    SF('M_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                    SF('DataAreaID', gCompanyAct)
                    ], sTable_OrderBaseMain, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_OrderBaseMain
    else
      nStr := 'delete from ' + sTable_OrderBaseMain + 'where M_ID='''+FIn.FData+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.GetAXPurOrdLine(var nData: string): Boolean;//获取采购订单行
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
    nPos:Integer;
    fId,LNum,nStockName:string;
begin
  FListA.Clear;
  nDBWorker := nil;
  try
    if FIn.FData='' then
    begin
      nStr := 'Select * From %s Where DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_PurOrdLine, gCompanyAct]);
    end else
    begin
      nStr:= FIn.FData;
      nPos:=Pos(',',nStr);
      fId:=Copy(nStr,1,nPos-1);
      LNum:=Copy(nStr,nPos+1,Length(nStr)-nPos);
      nStr := 'Select * From %s Where PurchId=''%s'' and LineNum=''%s'' and DataAreaID=''%s'' ';
      nStr := Format(nStr, [sTable_AX_PurOrdLine, fId, LNum, gCompanyAct]);
    end;
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_AX) do
    begin
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          nStockName:= FieldByName('Name').AsString;
          nStockName:= StringReplace(nStockName,'"','',[rfReplaceAll]);
          nStr := MakeSQLByStr([SF('B_ID', FieldByName('PurchId').AsString),
                    SF('B_StockType', FieldByName('CMT_PACKTYPE').AsString),
                    SF('B_StockNo', FieldByName('ItemId').AsString),
                    SF('B_StockName', nStockName),
                    SF('B_BStatus', FieldByName('PurchStatus').AsString),
                    SF('B_Value', FieldByName('QtyOrdered').AsString),
                    SF('B_SentValue', FieldByName('PurchReceivedNow').AsString),
                    SF('B_RestValue', FieldByName('RemainPurchPhysical').AsString),
                    SF('B_Blocked', FieldByName('Blocked').AsString),
                    SF('B_Date', FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)),
                    SF('DataAreaID', FieldByName('DataAreaID').AsString),
                    SF('B_RECID', FieldByName('Recid').AsString)
                    ], sTable_OrderBase, '', True);
          FListA.Add(nStr);
          Next;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    if FIn.FData='' then
      nStr := 'delete from ' + sTable_OrderBase
    else
      nStr := 'delete from ' + sTable_OrderBase + 'where B_ID='''+fId+''' and B_RECID='''+LNum+''' ';
    gDBConnManager.WorkerExec(FDBConn, nStr);
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
    Result:=True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessCommander.SyncStockBillAX(var nData: string):Boolean;//同步交货单（发运计划）到AX
var nID,nIdx: Integer;
    nStr,nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nFYPlanStatus,nCenterId,nLocationId:string;
    nLID:string;
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,a.L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId'+
          ' From %s a where L_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的提货单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    //if (Pos('YS',FieldByName('L_ID').AsString)>0) then Exit;

    nFYPlanStatus:='0';
    if FieldByName('L_InvCenterId').AsString='' then
    begin
      nData := '编号为[ %s ]的提货单产品没有配置生产线.';
      nData := Format(nData, [FIn.FData]);
      WriteLog(nData);
      Exit;
    end;
    nLID := FieldByName('L_ID').AsString;
    nLocationId := FieldByName('L_InvLocationId').AsString;
    if nLocationId = '' then nLocationId := 'A';
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+nLID+'</TRANSPLANID>'+
             '<SALESID>'+FieldByName('L_ZhiKa').AsString+'</SALESID>'+
             '<SALESLINERECID>'+FieldByName('L_LineRecID').AsString+'</SALESLINERECID>'+
             '<COMPANYID>'+gCompanyAct+'</COMPANYID>'+
             '<Destinationcode></Destinationcode>'+
             '<WMSLocationId></WMSLocationId>'+
             '<FYPlanStatus>'+nFYPlanStatus+'</FYPlanStatus>'+
             '<InventLocationId>'+nLocationId+'</InventLocationId>'+
             '<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>'+
           '</PRIMARY>';
    {$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    {$ENDIF}
    //----------------------------------------------------------------------------
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      nMsg:=nService.WRZS2ERPInfo('WRZS_001',nStr,'000');
      if nMsg=1 then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步成功');
        nSQL:='update %s set L_FYAX=''1'',L_FYNUM=L_FYNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步失败');
        nSQL:='update %s set L_FYNUM=L_FYNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      on e:Exception do
      begin
        WriteLog('AX接口异常,发送值：'+nStr);
        nStr := FieldByName('L_ID').AsString+'提货单同步失败.';
        WriteLog('AX接口异常：'+nStr+#13#10+e.Message);
      end;
    end;
  end;
end;

//同步删除交货单到AX
function TWorkerBusinessCommander.SyncDelSBillAX(var nData: string):Boolean;
var nID,nIdx: Integer;
    nStr,nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nFYPlanStatus,nCenterId,nLocationId:string;
    s:string;
    nLID:string;
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId '+
          ' From %s a where L_ID = ''%s'' and L_FYAX=''1'' ';
  nSQL := Format(nSQL,[sTable_BillBak,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的提货单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    nFYPlanStatus:='1';
    if FieldByName('L_InvCenterId').AsString='' then
    begin
      nData := '编号为[ %s ]的提货单产品没有配置生产线.';
      nData := Format(nData, [FIn.FData]);
      WriteLog(nData);
      Exit;
    end;
    nLocationId := FieldByName('L_InvLocationId').AsString;
    if nLocationId = '' then nLocationId := 'A';
    nLID := FieldByName('L_ID').AsString;
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+nLID+'</TRANSPLANID>'+
             '<SALESID>'+FieldByName('L_ZhiKa').AsString+'</SALESID>'+
             '<SALESLINERECID>'+FieldByName('L_LineRecID').AsString+'</SALESLINERECID>'+
             '<COMPANYID>'+gCompanyAct+'</COMPANYID>'+
             '<Destinationcode></Destinationcode>'+
             '<WMSLocationId></WMSLocationId>'+
             '<FYPlanStatus>'+nFYPlanStatus+'</FYPlanStatus>'+
             '<InventLocationId>'+nLocationId+'</InventLocationId>'+
             '<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>'+
           '</PRIMARY>';
    {$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    {$ENDIF}
    //----------------------------------------------------------------------------
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      nMsg:=nService.WRZS2ERPInfo('WRZS_001',nStr,'000');
      if nMsg=1 then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步成功');
        nSQL:='update %s set L_FYDEL=''1'',L_FYDELNUM=L_FYDELNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_BillBak,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步失败');
        nSQL:='update %s set L_FYDELNUM=L_FYDELNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_BillBak,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      on e:Exception do
      begin
        nStr := FieldByName('L_ID').AsString+'删除提货单同步失败.';
        WriteLog('AX接口异常：'+nStr+#13#10+e.Message);
      end;
    end;
  end;
end;

//同步空车出厂交货单
function TWorkerBusinessCommander.SyncEmptyOutBillAX(var nData: string):Boolean;
var nID,nIdx: Integer;
    nStr,nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nFYPlanStatus,nCenterId,nLocationId:string;
    nLID,s:string;
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,a.L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId'+
          ' From %s a where L_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的提货单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    nFYPlanStatus:='1';
    if FieldByName('L_InvCenterId').AsString='' then
    begin
      nData := '编号为[ %s ]的提货单产品没有配置生产线.';
      nData := Format(nData, [FIn.FData]);
      WriteLog(nData);
      Exit;
    end;
    nLocationId := FieldByName('L_InvLocationId').AsString;
    if nLocationId = '' then nLocationId := 'A';
    nLID := FieldByName('L_ID').AsString;
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+nLID+'</TRANSPLANID>'+
             '<SALESID>'+FieldByName('L_ZhiKa').AsString+'</SALESID>'+
             '<SALESLINERECID>'+FieldByName('L_LineRecID').AsString+'</SALESLINERECID>'+
             '<COMPANYID>'+gCompanyAct+'</COMPANYID>'+
             '<Destinationcode></Destinationcode>'+
             '<WMSLocationId></WMSLocationId>'+
             '<FYPlanStatus>'+nFYPlanStatus+'</FYPlanStatus>'+
             '<InventLocationId>'+nLocationId+'</InventLocationId>'+
             '<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>'+
           '</PRIMARY>';
    {$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    {$ENDIF}
    //----------------------------------------------------------------------------
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      nMsg:=nService.WRZS2ERPInfo('WRZS_001',nStr,'000');
      if nMsg=1 then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步成功');
        nSQL:='update %s set L_EOUTAX=''1'',L_EOUTNUM=L_EOUTNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('L_ID').AsString+'同步失败');
        nSQL:='update %s set L_EOUTNUM=L_EOUTNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      on e:Exception do
      begin
        nStr := FieldByName('L_ID').AsString+'空车出厂同步失败.';
        WriteLog('AX接口异常：'+nStr+#13#10+e.Message);
      end;
    end;
  end;
end;

function TWorkerBusinessCommander.SyncPoundBillAX(var nData: string):Boolean;//同步磅单到AX
var nID,nIdx: Integer;
    nStr,nWeightMan:string;
    nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nCenterId,nLocationId:string;
    s,nHYDan:string;
    nNetValue, nYKMouney:Double;
    nsWeightTime, nCustAcc, nContQuota:string;
    nLID:string;
begin
  Result := False;

  nSQL := 'select a.L_ID,a.L_StockNo,a.L_Truck,a.L_PValue,a.L_MValue,a.L_Value,'+
          'a.L_InvCenterId,a.L_InvLocationId,a.L_CW,a.L_PlanQty,a.L_HYDan,a.L_Type,'+
          'a.L_MMan,a.L_MDate,b.P_ID,a.L_ZhiKa,a.L_LineRecID,a.L_StockName,'+
          'IsNull(L_Value*L_Price,''0'') as L_TotalMoney,L_CusID,L_ContQuota'+
          ' From %s a,%s b '+
          ' where a.L_ID = ''%s'' and a.L_ID=b.P_Bill ';
  nSQL := Format(nSQL,[sTable_Bill,sTable_PoundLog,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '交货单号为[ %s ]的磅单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    if FieldByName('L_InvCenterId').AsString='' then
    begin
      nData := '编号为[ %s ]的交货单产品没有配置生产线.';
      nData := Format(nData, [FIn.FData]);
      WriteLog(nData);
      Exit;
    end;
    nHYDan:=FieldByName('L_HYDan').AsString;
    if nHYDan='' then
    begin
      if (Pos('熟料',FieldByName('L_StockName').AsString)>0) then
      begin
        nHYDan:='I';
      end else
      begin
        nData := '交货单号为[ %s ]的化验单不存在.';
        nData := Format(nData, [FIn.FData]);
        WriteLog(nData);
        Exit;
      end;
    end;

    nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',FieldByName('L_MDate').AsDateTime);
    if nsWeightTime<>'' then
    begin
      nsWeightTime:=Copy(nsWeightTime,12,Length(nsWeightTime)-11);
    end;
    if FieldByName('L_Type').AsString='D' then
    begin
      nNetValue:=FieldByName('L_MValue').AsFloat-FieldByName('L_PValue').AsFloat;
      nNetValue := Float2Float(nNetValue, cPrecision, False);
    end else
    begin
      nNetValue := 0;
    end;

    nLID := FieldByName('L_ID').AsString;

    nStr := '<PRIMARY>';
    nStr := nStr+'<TRANSPLANID>'+nLID+'</TRANSPLANID>';
    nStr := nStr+'<ITEMID>'+FieldByName('L_StockNo').AsString+'</ITEMID>';
    nStr := nStr+'<VehicleNum>'+FieldByName('L_Truck').AsString+'</VehicleNum>';
    nStr := nStr+'<VehicleType></VehicleType>';
    nStr := nStr+'<applyvehicle></applyvehicle>';
    nStr := nStr+'<TareWeight>'+FieldByName('L_PValue').AsString+'</TareWeight>';
    nStr := nStr+'<GrossWeight>'+FieldByName('L_MValue').AsString+'</GrossWeight>';
    if FieldByName('L_Type').AsString='D' then
      nStr := nStr+'<Netweight>'+FloatToStr(nNetValue)+'</Netweight>'
    else
      nStr := nStr+'<Netweight>'+FieldByName('L_Value').AsString+'</Netweight>';
    nStr := nStr+'<REFERENCEQTY>'+FieldByName('L_PlanQty').AsString+'</REFERENCEQTY>';
    nStr := nStr+'<PackQty></PackQty>';
    nStr := nStr+'<SampleID>'+nHYDan+'</SampleID>';
    nStr := nStr+'<CMTCW>'+FieldByName('L_CW').AsString+'</CMTCW>';
    nStr := nStr+'<WeightMan>'+FieldByName('L_MMan').AsString+'</WeightMan>';
    nStr := nStr+'<WeightTime>'+nsWeightTime+'</WeightTime>';
    nStr := nStr+'<WeightDate>'+FieldByName('L_MDate').AsString+'</WeightDate>';
    nStr := nStr+'<description></description>';
    nStr := nStr+'<WeighingNum>'+copy(FieldByName('P_ID').AsString,2,10)+'</WeighingNum>';
    nStr := nStr+'<salesId>'+FieldByName('L_ZhiKa').AsString+'</salesId>';
    nStr := nStr+'<SalesLineRecid>'+FieldByName('L_LineRecID').AsString+'</SalesLineRecid>';
    nStr := nStr+'<COMPANYID>'+gCompanyAct+'</COMPANYID>';
    nStr := nStr+'<InventLocationId>'+FieldByName('L_InvLocationId').AsString+'</InventLocationId>';
    nStr := nStr+'<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>';
    nStr := nStr+'</PRIMARY>';
    //{$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    //{$ENDIF}
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      //s:=nService.test;
      //WriteLog('测试返回值：'+s);
      nMsg:=nService.WRZS2ERPInfo('WRZS_002',nStr,'000');
      if (nMsg=1) or (nMsg=2) then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('P_ID').AsString+'同步成功');
        nSQL:='update %s set L_BDAX=''%s'',L_BDNUM=L_BDNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill, IntToStr(nMsg), FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);

        if nMsg=1 then
        begin
          nYKMouney := FieldByName('L_TotalMoney').AsFloat;
          nCustAcc := FieldByName('L_CusID').AsString;
          nContQuota:= FieldByName('L_ContQuota').AsString;

          if nContQuota = '1' then
          begin
            nSQL:='Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%s) Where A_CID=''%s''';
            nSQL:= Format(nSQL, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
          end else
          begin
            nSQL:='Update %s Set A_FreezeMoney=A_FreezeMoney-(%s) Where A_CID=''%s''';
            nSQL:= Format(nSQL, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
          end;
          
          gDBConnManager.WorkerExec(FDBConn,nSQL);
          WriteLog('['+FIn.FData+']Release YKMoney: '+nSQL);
        end;
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('P_ID').AsString+'同步失败');
        nSQL:='update %s set L_BDAX=''%s'',L_BDNUM=L_BDNUM+1 where L_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_Bill, IntToStr(nMsg), FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      on e:Exception do
      begin
        nStr := FieldByName('P_ID').AsString+'销售磅单同步失败.';
        WriteLog('AX接口异常：'+#13#10+e.Message);
      end;
    end;
  end;
end;

function TWorkerBusinessCommander.SyncPurPoundBillAX(var nData: string):Boolean;//同步磅单（采购）到AX
var nID,nIdx: Integer;
    nStr,nWeightMan:string;
    nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nsWeightDate,nsWeightTime:string;
    nDtA, nDtB : TDateTime;
begin
  Result := False;
  nSQL := 'select * From %s a, %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_Order and a.D_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购单号为[ %s ]的采购磅单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    try
      nDtA := FieldByName('D_PDate').AsDateTime;
      nDtB := FieldByName('D_MDate').AsDateTime;
      nIdx := CompareDateTime(nDtA,nDtB);
      if nIdx > 0 then
      begin
        nsWeightDate:=formatdatetime('yyyy-mm-dd',nDtA);
        nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',nDtA);
      end else
      begin
        nsWeightDate:=formatdatetime('yyyy-mm-dd',nDtB);
        nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',nDtB);
      end;
    except
      nsWeightDate:=formatdatetime('yyyy-mm-dd',nDtA);
      nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',nDtA);
    end;
    if nsWeightTime<>'' then
    begin
      nsWeightTime:=Copy(nsWeightTime,12,Length(nsWeightTime)-11);
    end;
    nStr := '<PRIMARY>';
    nStr := nStr+'<PurchId>'+FieldByName('O_BID').AsString+'</PurchId>';
    nStr := nStr+'<PurchLineRecid>'+FieldByName('O_BRecID').AsString+'</PurchLineRecid>';
    nStr := nStr+'<DlvModeId></DlvModeId>';
    nStr := nStr+'<applyvehicle></applyvehicle>';
    nStr := nStr+'<TareWeight>'+FieldByName('D_PValue').AsString+'</TareWeight>';
    nStr := nStr+'<GrossWeight>'+FieldByName('D_MValue').AsString+'</GrossWeight>';
    nStr := nStr+'<Netweight>'+FieldByName('D_Value').AsString+'</Netweight>';
    nStr := nStr+'<CMTCW></CMTCW>';
    nStr := nStr+'<VehicleNum>'+FieldByName('D_Truck').AsString+'</VehicleNum>';
    nStr := nStr+'<WeightMan>'+FieldByName('D_MMan').AsString+'</WeightMan>';
    nStr := nStr+'<WeightTime>'+nsWeightTime+'</WeightTime>';
    nStr := nStr+'<WeightDate>'+nsWeightDate+'</WeightDate>';
    nStr := nStr+'<description></description>';
    nStr := nStr+'<WeighingNum>'+FieldByName('P_ID').AsString+'</WeighingNum>';
    nStr := nStr+'<tabletransporter></tabletransporter>';
    nStr := nStr+'<COMPANYID>'+gCompanyAct+'</COMPANYID>';
    nStr := nStr+'<TransportBill></TransportBill>';
    nStr := nStr+'<TransportBillQty></TransportBillQty>';
    nStr := nStr+'</PRIMARY>';
    //----------------------------------------------------------------------------
    
    {$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    {$ENDIF}
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      nMsg:=nService.WRZS2ERPInfo('WRZS_003',nStr,'000');
      if nMsg=1 then
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('P_ID').AsString+'同步成功');
        nSQL:='update %s set D_BDAX=''1'',D_BDNUM=D_BDNUM+1 where D_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_OrderDtl,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
        Result := True;
      end else
      begin
        WriteLog('返回值：'+IntToStr(nMsg)+','+FieldByName('P_ID').AsString+'同步失败');
        nSQL:='update %s set D_BDNUM=D_BDNUM+1 where D_ID = ''%s'' ';
        nSQL := Format(nSQL,[sTable_OrderDtl,FIn.FData]);
        gDBConnManager.WorkerExec(FDBConn,nSQL);
      end;
    except
      on e:Exception do
      begin
        nStr := FieldByName('P_ID').AsString+'销售磅单同步失败.';
        WriteLog('AX接口异常：'+#13#10+e.Message);
      end;
    end;
  end;
end;

function TWorkerBusinessCommander.SyncVehicleNoAX(var nData: string):Boolean;//同步车号到AX
var nID,nIdx: Integer;
    nVal,nMoney: Double;
    nK3Worker: PDBWorker;
    nStr,nSQL,nBill,nStockID: string;
begin
  Result := False;
  nK3Worker := nil;
  nStr := AdjustListStrFormat(FIn.FData , '''' , True , ',' , True);

  nSQL := 'select * From $BL where T_Truck In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BL', sTable_Truck) , MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的车号不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nK3Worker := gDBConnManager.GetConnection(sFlag_DB_K3, FErrNum);
    if not Assigned(nK3Worker) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not nK3Worker.FConn.Connected then
      nK3Worker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    First;

    while not Eof do
    begin
      nSQL := MakeSQLByStr([
        SF('VehicleId', FieldByName('T_Truck').AsString),
        SF('Name', FieldByName('').AsString),
        SF('CZ', FieldByName('T_Owner').AsString),
        SF('companyid', FieldByName('T_CompanyID').AsString),
        SF('XTECB', FieldByName('T_XTECB').AsString),
        SF('VendAccount', FieldByName('T_VendAccount').AsString),
        SF('Driver', FieldByName('T_Driver').AsString)
        ], sTable_AX_VehicleNo, '', True);
      FListA.Add(nSQL);
      Next;
      //xxxxx
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
  //----------------------------------------------------------------------------
  nK3Worker.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(nK3Worker, FListA[nIdx]);
    //xxxxx

    nK3Worker.FConn.CommitTrans;
    Result := True;
  except
    nK3Worker.FConn.RollbackTrans;
    nStr := '同步车号数据到AX系统失败.';
    raise Exception.Create(nStr);
  end;
end;

//读取销售订单信息 lih  2017-01-21
function TWorkerBusinessCommander.ReadZhikaInfo(var nData: string): Boolean;
var nStr, nRECID, nZID: string;
    nPos:Integer;
begin
  nStr := 'select D_RECID,' +                     //行ID
          '  D_ZID,' +                            //销售卡片编号
          '  D_Type,' +                           //类型(袋,散)
          '  D_StockNo,' +                        //水泥编号
          '  D_StockName,' +                      //水泥名称
          '  D_Price,' +                          //单价
          '  D_TotalValue,' +                     //订单总量
          '  D_Value,' +                          //订单剩余量
          '  D_SalesStatus,' +                    //行状态
          '  D_Blocked,' +                        //是否停止
          '  D_Memo,' +                           //备注信息
          '  Z_Man,' +                            //创建人
          '  Z_Date,' +                           //创建日期
          '  Z_Customer,' +                       //客户编号
          '  Z_Name,' +                           //客户名称
          '  Z_Lading,' +                         //提货方式
          '  Z_CID,' +                            //合同编号
          '  Z_SalesStatus,' +                    //订单状态
          '  Z_SalesType,' +                      //订单类型
          '  Z_TriangleTrade,' +                  //三角贸易
          '  Z_CompanyId,' +                      //公司ID    用来确认三角贸易的客户账套
          '  Z_XSQYBM,' +                         //销售区域编码
          '  Z_KHSBM,' +                          //客户识别码
          '  Z_OrgAccountNum,' +                  //最终客户ID
          '  Z_OrgAccountName,' +                 //最终客户名称
          '  Z_OrgXSQYBM ' +                      //最终销售区域编码
          'from S_ZhiKa a join S_ZhiKaDtl b on a.Z_ID = b.D_ZID ' +
          'where ((Z_SalesType=''0'') or (Z_SalesType=''3'')) '+
          'and Z_SalesStatus=''1'' and D_Blocked=''0'' ';

  if FIn.FData <> '' then
  begin
    nPos := Pos(';',FIn.FData);
    if nPos > 0 then
    begin
      nZID := Copy(FIn.FData,1,nPos-1);
      nRECID :=Copy(FIn.FData,nPos+1,Length(FIn.FData)-nPos);
      nStr := nStr + Format(' and D_ZID=''%s'' and D_RECID=''%s'' ', [nZID,nRECID]);
    end else
      nStr := nStr + Format(' and D_ZID=''%s'' ', [FIn.FData]);
  end;
  //按单号查询

  if FIn.FExtParam <> '' then
    nStr := nStr + Format(' and (%s)', [FIn.FExtParam]);
  //附加查询条件

  Result := False;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if FIn.FData = '' then
           nData := '系统中未找到符合条件的数据.'
      else nData := Format('单据:[ %s ]无效,或者已经丢失.', [FIn.FData]);

      Exit;
    end;

    FListA.Clear;
    FListB.Clear;

    FListB.Values['XCB_ID']         := FieldByName('D_RECID').AsString;
    FListB.Values['XCB_CardId']     := FieldByName('D_ZID').AsString;
    FListB.Values['XCB_Origin']     := '';
    FListB.Values['XCB_BillID']     := FieldByName('Z_CID').AsString;
    FListB.Values['XCB_SetDate']    := Date2Str(FieldByName('Z_Date').AsDateTime,True);
    FListB.Values['XCB_CardType']   := FieldByName('Z_SalesType').AsString;
    FListB.Values['XCB_SourceType'] := '';
    FListB.Values['XCB_Option']     := '';
    if FieldByName('Z_TriangleTrade').AsString ='1' then
    begin
      FListB.Values['XCB_Client']     := FieldByName('Z_OrgAccountNum').AsString;
      FListB.Values['XCB_ClientName'] := FieldByName('Z_OrgAccountName').AsString;
      FListB.Values['XCB_Area']       := FieldByName('Z_OrgXSQYBM').AsString;
    end else
    begin
      FListB.Values['XCB_Client']     := FieldByName('Z_Customer').AsString;
      FListB.Values['XCB_ClientName'] := FieldByName('Z_Name').AsString;
      FListB.Values['XCB_Area']       := FieldByName('Z_XSQYBM').AsString;
    end;
    FListB.Values['XCB_WorkAddr']   := '';
    FListB.Values['XCB_Alias']      := '';
    FListB.Values['XCB_OperMan']    := '';

    FListB.Values['XCB_CementType'] := UpperCase(FieldByName('D_Type').AsString);
    FListB.Values['XCB_Cement']     := FieldByName('D_StockNo').AsString+UpperCase(FieldByName('D_Type').AsString);
    if UpperCase(FieldByName('D_Type').AsString) = 'D' then
      FListB.Values['XCB_CementName'] := FieldByName('D_StockName').AsString+'袋装'
    else
      FListB.Values['XCB_CementName'] := FieldByName('D_StockName').AsString+'散装';
    FListB.Values['XCB_LadeType']   := FieldByName('Z_Lading').AsString;
    FListB.Values['XCB_Number']     := FloatToStr(FieldByName('D_TotalValue').AsFloat);
    FListB.Values['XCB_FactNum']    := '0';
    FListB.Values['XCB_PreNum']     := '0';
    FListB.Values['XCB_ReturnNum']  := '0';
    FListB.Values['XCB_OutNum']     := '0';
    FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('D_Value').AsFloat);
    FListB.Values['XCB_AuditState'] := FieldByName('D_SalesStatus').AsString;
    FListB.Values['XCB_Status']     := FieldByName('D_Blocked').AsString;
    FListB.Values['XCB_IsOnly']     := '';
    FListB.Values['XCB_Del']        := '0';
    FListB.Values['XCB_Creator']    := FieldByName('Z_Man').AsString;
    FListB.Values['XCB_CreatorNM']  := FieldByName('Z_Man').AsString;
    FListB.Values['XCB_CDate']      := DateTime2Str(FieldByName('Z_Date').AsDateTime);
    FListB.Values['XCB_Firm']       := '';
    FListB.Values['XCB_FirmName']   := '';
    FListB.Values['pcb_id']         := '';
    FListB.Values['pcb_name']       := '';
    FListB.Values['XCB_TransID']    := '';
    FListB.Values['XCB_TransName']  := '';

    FListA.Add(PackerEncodeStr(FListB.Text));
    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  end;
end;

//读取订单物料价格 lih  2017-02-07
function TWorkerBusinessCommander.ReadStockPrice(var nData: string): Boolean;
var nStr,nRecID: string;
    nPos: Integer;
begin
  if FIn.FData <> '' then
  begin
    nPos := Pos(';',FIn.FData);
    if nPos > 0 then
      nRecID := Copy(FIn.FData,nPos+1,Length(FIn.FData)-nPos)
    else
      nRecID := FIn.FData;
  end else
  begin
    Exit;
  end;
  nStr := 'Select top 1 A_SalesNewAmount From '+sTable_AddTreaty+
          ' Where RefRecid='''+nRecID+
          ''' and convert(varchar(10),A_TakeEffectDate,23)+'' ''+'+
          'CONVERT(varchar(2),A_TakeEffectTime/(60*60*1000))+'':''+'+
          'CONVERT(varchar(2),(A_TakeEffectTime%(60*60*1000))/(60*1000))+'':''+'+
          'CONVERT(varchar(2),((A_TakeEffectTime%(60*60*1000))%(60*1000))/1000)+''.''+'+
          'CONVERT(varchar(3),A_TakeEffectTime%1000)<= convert(varchar(23),GETDATE(),21) order by Recid desc';
  Result := False;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount < 1 then
  begin
    nStr := 'Select D_Price From %s Where D_Blocked=''0'' and D_RECID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nRecID]);
    with gDBConnManager.WorkerQuery(FDBConn,nStr) do
    if RecordCount < 1 then
    begin
      FOut.FData := '0.00';
      Exit;
    end else
    begin
      FOut.FData := Fields[0].AsString;
      Result := True;
    end;
  end else
  begin
    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;


//Date: 2016-09-20
//Parm: 防伪码[FIn.FData]
//Desc: 防伪码校验
function TWorkerBusinessCommander.CheckSecurityCodeValid(var nData: string): Boolean;
var
  nStr,nCode,nBill_id: string;
  nSprefix:string;
  nIdx,nIdlen:Integer;
  nDs:TDataSet;
  nBills: TLadingBillItems;
begin
  nSprefix := '';
  nidlen := 0;
  Result := True;
  nCode := FIn.FData;
  if nCode='' then
  begin
    nData := '';
    FOut.FData := nData;
    Exit;
  end;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);
  nDs :=  gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDs.RecordCount>0 then
  begin
    nSprefix := nDs.FieldByName('B_Prefix').AsString;
    nIdlen := nDs.FieldByName('B_IDLen').AsInteger;
    nIdlen := nIdlen-length(nSprefix);
  end;

  //生成提货单号
  nBill_id := nSprefix+Copy(nCode,Length(nCode)-nIdlen+1,nIdlen);

  //查询数据库
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
      'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
      'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue From $Bill b ';
  nStr := nStr + 'Where L_ID=''$CD''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount<1 then
  begin
    SetLength(nBills, 1);
    ZeroMemory(@nBills[0],0);
    FOut.FData := CombineBillItmes(nBills);
    Exit;
  end;

  SetLength(nBills, nDs.RecordCount);
  nIdx := 0;
  nDs.First;
  while not nDs.eof do
  begin
    with  nBills[nIdx] do
    begin
      FID         := nDs.FieldByName('L_ID').AsString;
      FZhiKa      := nDs.FieldByName('L_ZhiKa').AsString;
      FCusID      := nDs.FieldByName('L_CusID').AsString;
      FCusName    := nDs.FieldByName('L_CusName').AsString;
      FTruck      := nDs.FieldByName('L_Truck').AsString;

      FType       := nDs.FieldByName('L_Type').AsString;
      FStockNo    := nDs.FieldByName('L_StockNo').AsString;
      FStockName  := nDs.FieldByName('L_StockName').AsString;
      FValue      := nDs.FieldByName('L_Value').AsFloat;
      FPrice      := nDs.FieldByName('L_Price').AsFloat;

      FCard       := nDs.FieldByName('L_Card').AsString;
      FIsVIP      := nDs.FieldByName('L_IsVIP').AsString;
      FStatus     := nDs.FieldByName('L_Status').AsString;
      FNextStatus := nDs.FieldByName('L_NextStatus').AsString;
      FSelected := True;
      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := nDs.FieldByName('L_PValue').AsFloat;
      FMData.FValue := nDs.FieldByName('L_MValue').AsFloat;
    end;

    Inc(nIdx);
    nDs.Next;
  end;

  FOut.FData := CombineBillItmes(nBills);
end;

//Date: 2016-09-20
//Parm: 
//Desc: 工厂待装查询
function TWorkerBusinessCommander.GetWaitingForloading(var nData: string):Boolean;
var nFind: Boolean;
    nLine: PLineItem;
    nIdx,nInt, i: Integer;
    nQueues: TQueueListItems;
begin
  gTruckQueueManager.RefreshTrucks(True);
  Sleep(320);
  //刷新数据

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    i := 0;
    SetLength(nQueues, 0);
    //保存查询记录

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];

      nFind := False;
      for nInt:=Low(nQueues) to High(nQueues) do
      begin
        with nQueues[nInt] do
          if FStockNo = nLine.FStockNo then
          begin
            Inc(FLineCount);
            FTruckCount := FTruckCount + nLine.FRealCount;

            nFind := True;
            Break;
          end;
      end;

      if not nFind then
      begin
        SetLength(nQueues, i+1);
        with nQueues[i] do
        begin
          FStockNO    := nLine.FStockNo;
          FStockName  := nLine.FStockName;

          FLineCount  := 1;
          FTruckCount := nLine.FRealCount;
        end;

        Inc(i);
      end;
    end;

    for nIdx:=Low(nQueues) to High(nQueues) do
    begin
      with FListB, nQueues[nIdx] do
      begin
        Clear;

        Values['StockName'] := FStockName;
        Values['LineCount'] := IntToStr(FLineCount);
        Values['TruckCount']:= IntToStr(FTruckCount);
      end;

      FListC.Add(PackerEncodeStr(FListB.Text));
    end;

    FOut.FData := PackerEncodeStr(FListC.Text);
  finally
    SyncLock.Leave;
  end;
end;

//进出厂量查询（采购进厂量、销售出厂量） lih 2017-04-19
function TWorkerBusinessCommander.GetInOutFactoryTatol(var nData:string):Boolean;
var
  nStr,nExtParam:string;
  nType,nStartDate,nEndDate:string;
  nPos:Integer;
begin
  Result := False;
  nType := Trim(fin.FData);
  nExtParam := Trim(FIn.FExtParam);
  if (nType='') or (nExtParam='') then Exit;

  nPos := Pos('and',nExtParam);
  if nPos > 0 then
  begin
    nStartDate := Copy(nExtParam,1,nPos-1)+' 00:00:00';
    nEndDate := Copy(nExtParam,nPos+3,Length(nExtParam)-nPos-2)+' 23:59:59';
  end;

  {if nType='S' then
  begin
    nStr := 'select L_StockName as StockName,'+
            'Count(R_ID) as TruckCount,'+
            'SUM(L_Value) as StockValue from %s '+
            'where L_OutFact >=''%s'' and L_OutFact <=''%s'' '+
            'and L_IfNeiDao=''N'' '+
            'group by L_StockName '+
            'union '+
            'select ''内部倒运'' as StockName,'+
            'Count(R_ID) as TruckCount,'+
            'SUM(L_Value) as StockValue from %s '+
            'where L_OutFact >=''%s'' and L_OutFact <=''%s'' '+
            'and L_IfNeiDao=''N'' ';
    nStr := Format(nStr,[sTable_Bill,nStartDate,nEndDate]);
  end else
  begin
    nStr := 'select D_StockName as StockName,'+
            'Count(R_ID) as TruckCount,'+
            'SUM(D_Value) as StockValue from %s '+
            'where D_OutFact >=''%s'' and D_OutFact <=''%s'' group by D_StockName ';
    nStr := Format(nStr,[sTable_OrderDtl,nStartDate,nEndDate]);
  end;}
  nStr := 'EXEC SP_InOutFactoryTotal '''+nType+''','''+nStartDate+''','''+nEndDate+''' ';

  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '未查询到客户编号[ %s ]对应的订单信息.';
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      FListB.Values['StockName'] := FieldByName('StockName').AsString;
      FListB.Values['TruckCount'] := FieldByName('TruckCount').AsString;
      FListB.Values['StockValue'] := FieldByName('StockValue').AsString;

      FListA.Add(PackerEncodeStr(FListB.Text));
      Next;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  end;
end;

//Date: 2016-09-23
//Parm:
//Desc: 网上订单可下单数量查询
function TWorkerBusinessCommander.GetBillSurplusTonnage(var nData:string):boolean;
var nStr,nCusID: string;
    nVal,nCredit,nPrice: Double;
    nStockNo:string;
begin
  nCusID := '';
  nStockNo := '';
  nPrice := 1;
  nCredit := 0;
  nVal := 0;
  Result := False;
  nCusID := Fin.FData;
  if nCusID='' then Exit;  
  //未传递客户号

  nStockNo := Fin.FExtParam;
  if nStockNo='' then Exit;
  //未传递产品编号

  //产品销售价格表擦查询单价
  nStr := 'select p_price from %s where P_StockNo=''%s'' order by P_Date desc';
  //nStr := Format(nStr, [sTable_SPrice, nStockNo]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '未设单价，查询失败!';
      Exit;
    end;
    nPrice := FieldByName('p_price').AsFloat;
    if Float2PInt(nPrice, 100000, False)<=0 then
    begin
      nData := '单价设置不正确，查询失败!';
      Exit;    
    end;
  end;

  //调用GetCustomerValidMoney查询可用金额
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;
  nVal := StrToFloat(FOut.FData);
  if Float2PInt(nVal, cPrecision, False)<=0 then
  begin
    nData := '编号为[ %s ]的客户账户可用金额不足.';
    nData := Format(nData, [nCusID]);
    Exit;
  end;
  FOut.FData := FormatFloat('0.0000',nVal/nPrice);
  Result := True;  
end;

//获取订单信息，用于网上下单
function TWorkerBusinessCommander.GetOrderInfo(var nData:string):Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nCard,nParam:string;
    nLoginAccount,nLoginCusId,nOrderCusId:string;
    nSql:string;
    nDataSet:TDataSet;
    nOrderValid:Boolean;
begin
  nCard := fin.FData;
  nLoginAccount := FIn.FExtParam;
  nParam := sFlag_LoadExtInfo;
  Result := CallMe(cBC_ReadZhiKaInfo, nCard, '', @nOut);
  if not Result then
  begin
    nCard := nOut.FBase.FErrDesc;
    Exit;
  end;
  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nOut.FData);
    nCard := nList[0];
    //cBC_ReadZhiKaInfo读取指令允许读取多条,取第一条
  finally
    nList.Free;
  end;
  FOut.FData := nCard;

  //------防伪校验begin-------
  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nCard);
    nOrderCusId := nList.Values['XCB_Client'];
  finally
    nList.Free;
  end;

  nSql := 'select i_itemid from %s where i_group=''%s'' and i_item=''%s'' and i_info=''%s''';
  nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'手机',nLoginAccount]);

  nDataSet := gDBConnManager.WorkerQuery(FDBConn, nSql);
  //未找到注册的手机号
  if nDataSet.RecordCount<1 then
  begin
    nData := '未找到注册的手机号码';
    nout.FBase.FErrDesc := nData;  
    Result := False;
    Exit;
  end;

  nOrderValid := False;
    
  while not nDataSet.Eof do
  begin
    nLoginCusId := nDataSet.FieldByName('i_itemid').AsString;
    if nLoginCusId=nOrderCusId then
    begin
      nOrderValid := True;
      Break;
    end;
    nDataSet.Next;
  end;

  if not nOrderValid then
  begin
    nData := '请勿冒用其他客户的订单号.';
    nout.FBase.FErrDesc := nData;  
    Result := False;
    Exit;  
  end;
  //------防伪校验end-------
end;

//获取订单列表，用于网上下单
function TWorkerBusinessCommander.GetOrderList(var nData:string):Boolean;
var
  nCusId,nStr:string;
begin
  Result := False;
  nCusId := Trim(fin.FData);
  if nCusId='' then Exit;
  nStr := 'select D_RECID,' +                   //行ID
        '  D_ZID,' +                            //销售卡片编号
        '  D_Type,' +                           //类型(袋,散)
        '  D_StockNo,' +                        //水泥编号
        '  D_StockName,' +                      //水泥名称
        '  D_Price,' +                          //单价
        '  D_TotalValue,' +                     //订单总量
        '  D_Value,' +                          //订单剩余量
        '  D_SalesStatus,' +                    //行状态
        '  D_Blocked,' +                        //是否停止
        '  D_Memo,' +                           //备注信息
        '  Z_Man,' +                            //创建人
        '  Z_Date,' +                           //创建日期
        '  Z_Customer,' +                       //客户编号
        '  Z_Name,' +                           //客户名称
        '  Z_Lading,' +                         //提货方式
        '  Z_CID,' +                            //合同编号
        '  Z_SalesStatus,' +                    //订单状态
        '  Z_SalesType,' +                      //订单类型
        '  Z_TriangleTrade,' +                  //三角贸易
        '  Z_CompanyId,' +                      //公司ID    用来确认三角贸易的客户账套
        '  Z_XSQYBM,' +                         //销售区域编码
        '  Z_KHSBM,' +                          //客户识别码
        '  Z_OrgAccountNum,' +                  //最终客户ID
        '  Z_OrgAccountName,' +                 //最终客户名称
        '  Z_OrgXSQYBM ' +                      //最终销售区域编码
        'from S_ZhiKa a join S_ZhiKaDtl b on a.Z_ID = b.D_ZID ' +
        'where ((Z_SalesType=''0'') or (Z_SalesType=''3'')) '+
        'and Z_SalesStatus=''1'' and D_Blocked=''0'' '+
        'and ((Z_TriangleTrade=''1'' and Z_OrgAccountNum=''%s'') or (Z_TriangleTrade<>''1'' and Z_Customer=''%s''))';
        //订单剩余量大于0、未结订单、订单行未停止状态
  nStr := Format(nStr,[nCusId,nCusId]);
  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('未查询到客户编号[ %s ]对应的订单信息.', [nCusId]);
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      FListB.Values['XCB_ID']         := FieldByName('D_RECID').AsString;
      FListB.Values['XCB_CardId']     := FieldByName('D_ZID').AsString+';'+FieldByName('D_RECID').AsString;
      FListB.Values['XCB_Origin']     := '';
      FListB.Values['XCB_BillID']     := FieldByName('Z_CID').AsString;
      FListB.Values['XCB_SetDate']    := Date2Str(FieldByName('Z_Date').AsDateTime,True);
      FListB.Values['XCB_CardType']   := FieldByName('Z_SalesType').AsString;
      FListB.Values['XCB_SourceType'] := '';
      FListB.Values['XCB_Option']     := FieldByName('D_Memo').AsString;
      if FieldByName('Z_TriangleTrade').AsString ='1' then
      begin
        FListB.Values['XCB_Client']     := FieldByName('Z_OrgAccountNum').AsString;
        FListB.Values['XCB_ClientName'] := FieldByName('Z_OrgAccountName').AsString;
        FListB.Values['XCB_Area']       := FieldByName('Z_OrgXSQYBM').AsString;
      end else
      begin
        FListB.Values['XCB_Client']     := FieldByName('Z_Customer').AsString;
        FListB.Values['XCB_ClientName'] := FieldByName('Z_Name').AsString;
        FListB.Values['XCB_Area']       := FieldByName('Z_XSQYBM').AsString;
      end;
      FListB.Values['XCB_WorkAddr']   := '';
      FListB.Values['XCB_Alias']      := '';
      FListB.Values['XCB_OperMan']    := '';

      FListB.Values['XCB_Cement']     := FieldByName('D_StockNo').AsString+UpperCase(FieldByName('D_Type').AsString);
      if UpperCase(FieldByName('D_Type').AsString) = 'D' then
        FListB.Values['XCB_CementName'] := FieldByName('D_StockName').AsString+'袋装'
      else
        FListB.Values['XCB_CementName'] := FieldByName('D_StockName').AsString+'散装';
      FListB.Values['XCB_LadeType']   := FieldByName('Z_Lading').AsString;
      FListB.Values['XCB_Number']     := FloatToStr(FieldByName('D_TotalValue').AsFloat);
      FListB.Values['XCB_FactNum']    := '0';
      FListB.Values['XCB_PreNum']     := '0';
      FListB.Values['XCB_ReturnNum']  := '0';
      FListB.Values['XCB_OutNum']     := '0';
      FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('D_Value').AsFloat);
      FListB.Values['XCB_AuditState'] := FieldByName('D_SalesStatus').AsString;
      FListB.Values['XCB_Status']     := FieldByName('D_Blocked').AsString;
      FListB.Values['XCB_IsOnly']     := '';
      FListB.Values['XCB_Del']        := '0';
      FListB.Values['XCB_Creator']    := FieldByName('Z_Man').AsString;
      FListB.Values['XCB_CreatorNM']  := FieldByName('Z_Man').AsString;
      FListB.Values['XCB_CDate']      := DateTime2Str(FieldByName('Z_Date').AsDateTime);
      FListB.Values['XCB_Firm']       := '';
      FListB.Values['XCB_FirmName']   := '';
      FListB.Values['pcb_id']         := '';
      FListB.Values['pcb_name']       := '';
      FListB.Values['XCB_TransID']    := '';
      FListB.Values['XCB_TransName']  := '';

      FListA.Add(PackerEncodeStr(FListB.Text));
      Next;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  end;
end;

//获取采购订单列表，用于网上下单
function TWorkerBusinessCommander.GetPurchaseContractList(var nData:string):Boolean;
var nStr:string;
    nProID:string;
begin
  Result := False;
  nProID := Trim(FIn.FData);
  if nProID = '' then Exit;
  nStr := 'Select *,(B_Value-IsNull(B_SentValue,0)-IsNull(B_FreezeValue,0)) As B_MaxValue From %s a, %s b ' +
          'Where a.B_ID=b.M_ID ' +
          'And ((B_BStatus=''Y'') or (B_BStatus=''1'') or ((M_PurchType=''0'') and (B_BStatus=''0''))) '+
          'and B_Blocked=''0'' and M_ProID = ''%s'' ';
  nStr := Format(nStr , [sTable_OrderBase,sTable_OrderBaseMain, nProID]);
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('未查询到供应商[ %s ]对应的订单信息.', [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    First;
    while not Eof do
    try
      FListB.Values['pcId'] := FieldByName('M_ID').AsString+';'+FieldByName('B_RecID').AsString;
      FListB.Values['provider_code'] := FieldByName('M_ProID').AsString;
      FListB.Values['provider_name'] := FieldByName('M_ProName').AsString;
      FListB.Values['con_code'] := FieldByName('B_RecID').AsString;
      FListB.Values['con_materiel_Code'] := FieldByName('B_StockNo').AsString;
      FListB.Values['con_materiel_name'] := FieldByName('B_StockName').AsString;
      FListB.Values['con_price'] := FieldByName('B_RestValue').AsString; //订单剩余量
      FListB.Values['con_quantity'] := FieldByName('B_Value').AsString;
      FListB.Values['con_finished_quantity'] := FieldByName('B_SentValue').AsString;
      FListB.Values['con_date'] := DateTime2Str(FieldByName('B_Date').AsDateTime);
      FListB.Values['con_remark'] := FieldByName('B_Memo').AsString;
      FListA.Add(PackerEncodeStr(FListB.Text));

    finally
      Next;
    end;
  end;  

  FOut.FData := PackerEncodeStr(FListA.Text);
  Result := True;
end;

//获取客户注册信息
function TWorkerBusinessCommander.getCustomerInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_getCustomerInfo);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//客户与微信账号绑定
function TWorkerBusinessCommander.get_Bindfunc(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_Bindfunc);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//发送消息
function TWorkerBusinessCommander.send_event_msg(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_send_event_msg);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//新增商城用户
function TWorkerBusinessCommander.edit_shopclients(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_edit_shopclients);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//添加商品
function TWorkerBusinessCommander.edit_shopgoods(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_edit_shopgoods);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//获取订单信息
function TWorkerBusinessCommander.get_shoporders(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shoporders);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//根据订单号获取订单信息
function TWorkerBusinessCommander.get_shoporderbyno(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shoporderbyNO);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//根据货单号获取货单信息-原材料
function TWorkerBusinessCommander.get_shopPurchasebyNO(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_get_shopPurchasebyNO);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//修改订单状态
function TWorkerBusinessCommander.complete_shoporders(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, '', @nOut,
            cBC_WeChat_complete_shoporders);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

{//获取客户注册信息
function TWorkerBusinessCommander.getCustomerInfo(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_getCustomerInfo,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//客户与微信账号绑定
function TWorkerBusinessCommander.get_Bindfunc(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_Bindfunc,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//发送消息
function TWorkerBusinessCommander.send_event_msg(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_send_event_msg,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_send_event_msg,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//新增商城用户
function TWorkerBusinessCommander.edit_shopclients(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_edit_shopclients,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_edit_shopclients,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;

//添加商品
function TWorkerBusinessCommander.edit_shopgoods(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_edit_shopgoods,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_edit_shopgoods,fin.FData);
  finally
    frmCall.Free;
  end;
end;

//获取订单信息
function TWorkerBusinessCommander.get_shoporders(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_shoporders,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_get_shoporders,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//根据订单号获取订单信息
function TWorkerBusinessCommander.get_shoporderbyno(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_shoporderbyNO,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_get_shoporders,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//根据货单号获取货单信息-原材料
function TWorkerBusinessCommander.get_shopPurchasebyNO(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_get_shopPurchasebyNO,fin.FData);
    nData := fin.FData;
    FOut.FData := fin.FData;
  finally
    frmCall.Free;
  end;
end;

//修改订单状态
function TWorkerBusinessCommander.complete_shoporders(var nData:string):Boolean;
var
  frmCall:TFrmCallWechatWebService;
begin
  Result := False;
  frmCall := TFrmCallWechatWebService.Create(nil);
  try
    Result := frmCall.ExecuteWebAction(cBC_WeChat_complete_shoporders,fin.FData);
//    Result := gFrmCallWechatWebService.ExecuteWebAction(cBC_WeChat_get_shoporders,fin.FData);
    FOut.FData := 'Y';
  finally
    frmCall.Free;
  end;
end;}

function TWorkerBusinessCommander.GetSampleID(var nData: string):Boolean;//获取试样编号
var
  nStr:string;
  nIdx:Integer;
begin
  Result := True;
  SetLength(FHuaYan, 0);
  FOut.FData := '';

  nStr := 'select R_SerialNo,R_BatQuaStart-R_BatQuaEnd as PCL, '+
          '(select SUM(L_Value) as zl from S_Bill where L_HYDan=R_SerialNo) as ZL, R_ValidDate from %s a,%s b '+
          'where a.R_PID = b.P_ID and b.P_Stock= ''%s'' and R_CenterID=''%s'' '+
          'and R_BatValid=''%s'' order by a.R_ID';
  nStr := Format(nStr,[sTable_StockRecord, sTable_StockParam, FIn.FData, FIn.FExtParam, sFlag_Yes]);
//  {$ELSE}
//  nStr := 'select R_SerialNo,R_BatQuaStart-R_BatQuaEnd as PCL, '+
//          '(select SUM(L_Value) as zl from S_Bill where L_HYDan=R_SerialNo) as ZL from %s a,%s b '+
//          'where a.R_PID = b.P_ID and b.P_Stock= ''%s'' and R_BatValid=''%s'' order by a.R_ID';
//  nStr := Format(nStr,[sTable_StockRecord, sTable_StockParam, FIn.FData, sFlag_Yes]);
//  {$ENDIF}

  WriteLog(nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FHuaYan, RecordCount);
    nIdx:=0;
    First;

    while not eof do
    begin
      FHuaYan[nIdx].FReriNo:= Fields[0].AsString;
      FHuaYan[nIdx].FValue:= Fields[1].AsFloat;
      FHuaYan[nIdx].FZLVal:= Fields[2].AsFloat;
      FHuaYan[nIdx].FValidDate:= Fields[3].AsString;
      Inc(nIdx);
      Next;
    end;
  end;

  for nIdx := Low(FHuaYan) to High(FHuaYan) do
  begin
    {$IFDEF CXSY}
    if (StrToDateTimeDef(FHuaYan[nIdx].FValidDate,Now + 1) < Now)
       or (FHuaYan[nIdx].FValue <= FHuaYan[nIdx].FZLVal) then
    {$ELSE}
    if (FHuaYan[nIdx].FValue <= FHuaYan[nIdx].FZLVal) then
    {$ENDIF}
    begin
      nStr := 'update %s set R_BatValid=''%s'',R_TotalValue=(%.2f) where R_SerialNo=''%s'' ';
      nStr := Format(nStr,[sTable_StockRecord, sFlag_No, FHuaYan[nIdx].FZLVal, FHuaYan[nIdx].FReriNo]);
      gDBConnManager.WorkerExec(FDBConn,nStr);
    end else
    begin
      nStr := 'update %s set R_TotalValue=(%.2f) where R_SerialNo=''%s'' ';
      nStr := Format(nStr,[sTable_StockRecord, FHuaYan[nIdx].FZLVal, FHuaYan[nIdx].FReriNo]);
      gDBConnManager.WorkerExec(FDBConn,nStr);
      FOut.FData:=FHuaYan[nIdx].FReriNo;
      Result:=True;
      Exit;
    end;
  end;
end;

function TWorkerBusinessCommander.GetCenterID(var nData: string):Boolean;//获取生产线ID
var
  nStr:string;
begin
  Result:=False;
  nStr := 'Select Z_CenterID,Z_LocationID From %s Where Z_StockNo=''%s'' ';
  nStr := Format(nStr, [sTable_ZTLines, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if (RecordCount > 0) then
    begin
      FOut.FData:=Fields[0].AsString;
      FOut.FExtParam:=Fields[1].AsString;
      Result:=True;
    end;
  end;
end;

function TWorkerBusinessCommander.GetSampleIDVIP(var nData: string):Boolean;//获取特殊试样编号
var
  nStr:string;
  nIdx:Integer;
begin
  Result := True;
  SetLength(FHuaYan, 0);
  FOut.FData := '';

  nStr := 'select R_SerialNo,R_BatQuaStart-R_BatQuaEnd as PCL, '+
          '(select SUM(L_Value) as zl from S_Bill where L_HYDan=R_SerialNo) as ZL, '+
          ' R_CusID, R_ValidDate from %s a,%s b,%s c '+
          'where a.R_CusGroup = c.F_CusGroup and c.F_Stock= ''%s'' and c.F_ID = ''%s'' '+
          'and a.R_PID = b.P_ID and R_BatValid=''%s'' order by a.R_ID';
  nStr := Format(nStr,[sTable_StockRecord, sTable_StockParam, sTable_ForceCenterID,
                 FIn.FData, FIn.FExtParam, sFlag_Yes]);

  WriteLog('特殊客户试样编号SQL:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FHuaYan, RecordCount);
    nIdx:=0;
    First;

    while not eof do
    begin
      FHuaYan[nIdx].FReriNo:= Fields[0].AsString;
      FHuaYan[nIdx].FValue:= Fields[1].AsFloat;
      FHuaYan[nIdx].FZLVal:= Fields[2].AsFloat;
      FHuaYan[nIdx].FCusID:= Fields[3].AsString;
      FHuaYan[nIdx].FValidDate:= Fields[4].AsString;
      Inc(nIdx);
      Next;
    end;
  end;

  for nIdx := Low(FHuaYan) to High(FHuaYan) do
  begin
    if (StrToDateTimeDef(FHuaYan[nIdx].FValidDate,Now + 1) < Now)
       or (FHuaYan[nIdx].FValue <= FHuaYan[nIdx].FZLVal) then
    begin
      nStr := 'update %s set R_BatValid=''%s'',R_TotalValue=(%.2f) where R_SerialNo=''%s'' ';
      nStr := Format(nStr,[sTable_StockRecord, sFlag_No, FHuaYan[nIdx].FZLVal, FHuaYan[nIdx].FReriNo]);
      gDBConnManager.WorkerExec(FDBConn,nStr);
    end else
    begin
      nStr := 'update %s set R_TotalValue=(%.2f) where R_SerialNo=''%s'' ';
      nStr := Format(nStr,[sTable_StockRecord, FHuaYan[nIdx].FZLVal, FHuaYan[nIdx].FReriNo]);
      gDBConnManager.WorkerExec(FDBConn,nStr);
      FOut.FData:=FHuaYan[nIdx].FReriNo;
      Result:=True;
      Exit;
    end;
  end;
end;
{$ENDIF}

//Date: 2017-12-2
//Parm: 车牌号(Truck); 交货单号(Bill);岗位(Pos)
//Desc: 抓拍比对
function TWorkerBusinessCommander.VerifySnapTruck(var nData: string): Boolean;
var nStr: string;
    nTruck, nBill, nPos, nSnapTruck, nEvent: string;
    nUpdate, nNeedManu: Boolean;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nSnapTruck:= '';
  nEvent:= '' ;
  nNeedManu := False;

  nTruck := FListA.Values['Truck'];
  nBill  := FListA.Values['Bill'];
  nPos   := FListA.Values['Pos'];

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;
    end;
  end;

  nData := '车辆[ %s ]车牌识别失败';
  nData := Format(nData, [nTruck]);
  FOut.FData := nData;
  //default

  nStr := 'Select * From %s Where S_ID=''%s''';
  nStr := Format(nStr, [sTable_SnapTruck, nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      nData := '车辆[ %s ]抓拍异常';
      nData := Format(nData, [nTruck]);
      FOut.FData := nData;
      Exit;
    end;
    nSnapTruck := FieldByName('S_Truck').AsString;
    if Pos(nTruck,nSnapTruck) > 0 then
    begin
      Result := True;
      nData := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
      nData := Format(nData, [nTruck,nSnapTruck]);
      FOut.FData := nData;
      Exit;
    end;
    //车牌识别成功
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill+sFlag_ManualE]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nData := '车辆[ %s ]车牌识别失败,抓拍车牌号:[ %s ],管理员禁止进厂';
        nData := Format(nData, [nTruck,nSnapTruck]);
        FOut.FData := nData;
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nData := '车辆[ %s ]车牌识别失败,抓拍车牌号:[ %s ],管理员允许';
        nData := Format(nData, [nTruck,nSnapTruck]);
        FOut.FData := nData;
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nData := '车辆[ %s ]车牌识别失败,抓拍车牌号:[ %s ]';
      nData := Format(nData, [nTruck,nSnapTruck]);
      FOut.FData := nData;
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '车辆[ %s ]车牌识别失败,抓拍车牌号:[ %s ]';
  nEvent := Format(nEvent, [nTruck,nSnapTruck]);

  nStr := SF('E_ID', nBill+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill+sFlag_ManualE),
          SF('E_Key', nTruck),
          SF('E_From', sFlag_DepMenGang),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', sFlag_DepMenGang),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.
