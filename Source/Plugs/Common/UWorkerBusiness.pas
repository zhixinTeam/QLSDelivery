{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF}
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml, revicewstest, BPM2ERPService1, HTTPApp;

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

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
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
    {$IFDEF XAZL}
    function SyncRemoteSaleMan(var nData: string): Boolean;
    function SyncRemoteCustomer(var nData: string): Boolean;
    function SyncRemoteProviders(var nData: string): Boolean;
    function SyncRemoteMaterails(var nData: string): Boolean;
    //同步新安中联K3系统数据
    function SyncRemoteStockBill(var nData: string): Boolean;
    //同步交货单到K3系统
    function SyncRemoteStockOrder(var nData: string): Boolean;
    //同步交货单到K3系统
    function IsStockValid(var nData: string): Boolean;
    //验证物料是否允许发货
    {$ENDIF}
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

  TStockMatchItem = record
    FStock: string;         //品种
    FGroup: string;         //分组
    FRecord: string;        //记录
  end;

  TBillLadingLine = record
    FBill: string;          //交货单
    FLine: string;          //装车线
    FName: string;          //线名称
    FPerW: Integer;         //袋重
    FTotal: Integer;        //总袋数
    FNormal: Integer;       //正常
    FBuCha: Integer;        //补差
    FHKBills: string;       //合卡单
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //散装多单
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //分组匹配
    FBillLines: array of TBillLadingLine;
    //装车线
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //物料分组
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    //
    function GetOnLineModel: string;
    //获取在线模式
    function LoadZhiKaInfo(const nZID: string; var nHint: string): TDataset;
    //载入纸卡
    function GetRemCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
    //在线远程获取客户信用和资金
    function GetRemTriCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
    //在线远程获取三角贸易客户信用和资金
    function SaveBills(var nData: string): Boolean;
    //保存交货单
    function DeleteBill(var nData: string): Boolean;
    //删除交货单
    function ChangeBillTruck(var nData: string): Boolean;
    //修改车牌号
    function BillSaleAdjust(var nData: string): Boolean;
    //销售调拨
    function SaveBillCard(var nData: string): Boolean;
    //绑定磁卡
    function LogoffCard(var nData: string): Boolean;
    //注销磁卡
    function GetPostBillItems(var nData: string): Boolean;
    //获取岗位交货单
    function SavePostBillItems(var nData: string): Boolean;
    //保存岗位交货单
    function SaveBillSendMsgWx(LID:string):Boolean;
    //开单发送微信消息
    function DelBillSendMsgWx(LID:string):Boolean;
    //删单发送微信消息
    function TruckOutSendMsgWx(nList:TStrings):Boolean;
    //出厂发送微信消息
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //验证车牌是否有效
  end;

  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveOrderBase(var nData: string):Boolean;
    function DeleteOrderBase(var nData: string):Boolean;
    function SaveOrder(var nData: string):Boolean;
    function DeleteOrder(var nData: string): Boolean;
    function SaveOrderCard(var nData: string): Boolean;
    function LogoffOrderCard(var nData: string): Boolean;
    function ChangeOrderTruck(var nData: string): Boolean;
    //修改车牌号
    function GetGYOrderValue(var nData: string): Boolean;
    //获取供应可收货量

    function GetPostOrderItems(var nData: string): Boolean;
    //获取岗位采购单
    function SavePostOrderItems(var nData: string): Boolean;
    //保存岗位采购单
    function GetOnLineModel: string;
    //获取在线模式
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

  TWorkerBusinessRegWeiXin = class(TMITDBWorker)   //by lih 2016-05-26
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCustomerInfo(var nData: string): Boolean;
    //获取微信公众号客户信息
    function GetBindfunc(var nData: string):Boolean;
    //去工厂绑定用户
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
  end;

implementation

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

   {$IFDEF XAZL}
   cBC_SyncCustomer        : Result := SyncRemoteCustomer(nData);
   cBC_SyncSaleMan         : Result := SyncRemoteSaleMan(nData);
   cBC_SyncProvider        : Result := SyncRemoteProviders(nData);
   cBC_SyncMaterails       : Result := SyncRemoteMaterails(nData);
   cBC_SyncStockBill       : Result := SyncRemoteStockBill(nData);
   cBC_CheckStockValid     : Result := IsStockValid(nData);

   cBC_SyncStockOrder      : Result := SyncRemoteStockOrder(nData);
   {$ENDIF}
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
    nFailureDate:TDateTime;
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
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1900-01-01') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1899-01-01') then
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
      nVal := nAXMoney-FieldByName('A_ConFreezeMoney').AsFloat;
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
//Desc: 同步新安中联客户数据到DL系统
function TWorkerBusinessCommander.SyncRemoteCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select S_Table,S_Action,S_Record,S_Param1,S_Param2,FItemID,' +
            'FName,FNumber,FEmployee From %s' +
            '  Left Join %s On FItemID=S_Record';
    nStr := Format(nStr, [sTable_K3_SyncItem, sTable_K3_Customer]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := FieldByName('S_Action').AsString;
        //action

        if nStr = 'A' then //Add
        begin
          if FieldByName('FItemID').AsString = '' then Continue;
          //invalid

          nStr := MakeSQLByStr([SF('C_ID', FieldByName('FItemID').AsString),
                  SF('C_Name', FieldByName('FName').AsString),
                  SF('C_PY', GetPinYinOfStr(FieldByName('FName').AsString)),
                  SF('C_SaleMan', FieldByName('FEmployee').AsString),
                  SF('C_Memo', FieldByName('FNumber').AsString),
                  SF('C_Param', FieldByName('FNumber').AsString),
                  SF('C_XuNi', sFlag_No)
                  ], sTable_Customer, '', True);
          FListA.Add(nStr);

          nStr := MakeSQLByStr([SF('A_CID', FieldByName('FItemID').AsString),
                  SF('A_Date', sField_SQLServer_Now, sfVal)
                  ], sTable_CusAccount, '', True);
          FListA.Add(nStr);
        end else

        if nStr = 'E' then //edit
        begin
          if FieldByName('FItemID').AsString = '' then Continue;
          //invalid

          nStr := SF('C_ID', FieldByName('FItemID').AsString);
          nStr := MakeSQLByStr([
                  SF('C_Name', FieldByName('FName').AsString),
                  SF('C_PY', GetPinYinOfStr(FieldByName('FName').AsString)),
                  SF('C_SaleMan', FieldByName('FEmployee').AsString),
                  SF('C_Memo', FieldByName('FNumber').AsString)
                  ], sTable_Customer, nStr, False);
          FListA.Add(nStr);
        end else

        if nStr = 'D' then //delete
        begin
          nStr := 'Delete From %s Where C_ID=''%s''';
          nStr := Format(nStr, [sTable_Customer, FieldByName('S_Record').AsString]);
          FListA.Add(nStr);
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务
    
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;

      nStr := 'Delete From ' + sTable_K3_SyncItem;
      gDBConnManager.WorkerExec(nDBWorker, nStr);
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2014-10-14
//Desc: 同步新安中联业务员数据到DL系统
function TWorkerBusinessCommander.SyncRemoteSaleMan(var nData: string): Boolean;
var nStr,nDept: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nDept := '1356';
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SaleManDept]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nDept := Fields[0].AsString;
      //销售部门编号
    end;

    nStr := 'Select FItemID,FName,FDepartmentID From t_EMP';
    //FDepartmentID='1356'为销售部门

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        if Fields[2].AsString = nDept then
             nStr := sFlag_No
        else nStr := sFlag_Yes;
        
        nStr := MakeSQLByStr([SF('S_ID', Fields[0].AsString),
                SF('S_Name', Fields[1].AsString),
                SF('S_InValid', nStr)
                ], sTable_Salesman, '', True);
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
    nStr := 'Delete From ' + sTable_Salesman;
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

//Date: 2014-10-14
//Desc: 同步新安中联供应商数据到DL系统
function TWorkerBusinessCommander.SyncRemoteProviders(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nSaler := '待分配业务员';
    nStr := 'Select FItemID,FName,FNumber From t_Supplier Where FDeleted=0';
    //未删除供应商

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('P_ID', Fields[0].AsString),
                SF('P_Name', Fields[1].AsString),
                SF('P_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('P_Memo', Fields[2].AsString),
                SF('P_Saler', nSaler)
                ], sTable_Provider, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务

      nStr := 'Delete From ' + sTable_Provider;
      gDBConnManager.WorkerExec(FDBConn, nStr);

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

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


//Date: 2014-10-14
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr,nCusID: string;
    nVal,nCredit: Double;
    nDBWorker: PDBWorker;
begin
  Result := False; 
  nStr := 'Select A_FreezeMoney,A_CreditLimit,C_Param From %s,%s ' +
          'Where A_CID=''%s'' And A_CID=C_ID';
  nStr := Format(nStr, [sTable_Customer, sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nCusID := FieldByName('C_Param').AsString;
    nVal := FieldByName('A_FreezeMoney').AsFloat;
    nCredit := FieldByName('A_CreditLimit').AsFloat;
    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;

  {nDBWorker := nil;
  try
    nStr := 'DECLARE @return_value int, @Credit decimal(28, 10),' +
            '@Balance decimal(28, 10)' +
            'Execute GetCredit ''%s'' , @Credit output , @Balance output ' +
            'select @Credit as Credit , @Balance as Balance , ' +
            '''Return Value'' = @return_value';
    nStr := Format(nStr, [nCusID]);
    
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'K3数据库上编号为[ %s ]的客户账户不存在.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      nVal := -(FieldByName('Balance').AsFloat) - nVal;
      nCredit := FieldByName('Credit').AsFloat + nCredit;
      nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

      if FIn.FExtParam = sFlag_Yes then
        nVal := nVal + nCredit;
      nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

      FOut.FData := FloatToStr(nVal);
      FOut.FExtParam := FloatToStr(nCredit);
      Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;}
end;

//Date: 2014-10-14
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select Z_Customer,Z_OnlyMoney,Z_FixedMoney From $ZK ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nStr := FieldByName('Z_Customer').AsString;
    if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney, nStr,
       sFlag_Yes, @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    nVal := StrToFloat(nOut.FData);
    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;
                                
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

//Date: 2014-10-15
//Parm: 交货单列表[FIn.FData]
//Desc: 同步交货单数据到K3系统
function TWorkerBusinessCommander.SyncRemoteStockBill(var nData: string): Boolean;
var nID,nIdx: Integer;
    nVal,nMoney: Double;
    nK3Worker: PDBWorker;
    nStr,nSQL,nBill,nStockID: string;
begin
  Result := False;
  nK3Worker := nil;
  nStr := AdjustListStrFormat(FIn.FData , '''' , True , ',' , True);

  nSQL := 'select L_ID,L_Truck,L_SaleID,L_CusID,L_StockNo,L_Value,' +
          'L_Price,L_OutFact From $BL ' +
          'where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BL', sTable_Bill) , MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的交货单不存在.';
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
      nSQL :='DECLARE @ret1 int, @FInterID int, @BillNo varchar(200) '+
            'Exec @ret1=GetICMaxNum @TableName=''%s'',@FInterID=@FInterID output '+
            'EXEC p_BM_GetBillNo @ClassType =21,@BillNo=@BillNo OUTPUT ' +
            'select @FInterID as FInterID , @BillNo as BillNo , ' +
            '''RetGetICMaxNum'' = @ret1';
      nSQL := Format(nSQL, ['ICStockBill']);
      //get FInterID, BillNo

      with gDBConnManager.WorkerQuery(nK3Worker, nSQL) do
      begin
        nBill := FieldByName('BillNo').AsString;
        nID := FieldByName('FInterID').AsInteger;
      end;

      {$IFDEF JYZL}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Fpoordbillno', ''),
          SF('Fstatus', 0, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Ftrantype', 21, sfVal),
          SF('Fdeptid', 177, sfVal),
          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fmanagetype', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          SF('Fsalestyle', 101, sfVal),
          SF('Fseltrantype', 0, sfVal),
          SF('Fsettledate', Date2Str(Now)),

          SF('Fbillerid', 16442, sfVal),
          SF('Ffmanagerid', 293, sfVal),
          SF('Fsmanagerid', 261, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fempid', FieldByName('L_SaleID').AsString, sfVal),
          SF('Fsupplyid', FieldByName('L_CusID').AsString, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Fpoordbillno', ''),
          SF('Fstatus', 0, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Ftrantype', 21, sfVal),
          SF('Fdeptid', 1356, sfVal),
          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fmanagetype', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          SF('Fsalestyle', 101, sfVal),
          SF('Fseltrantype', 83, sfVal),
          SF('Fsettledate', Date2Str(Now)),

          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1278, sfVal),
          SF('Fsmanagerid', 1279, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fempid', FieldByName('L_SaleID').AsString, sfVal),
          SF('Fsupplyid', FieldByName('L_CusID').AsString, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
      {$ENDIF}

      //------------------------------------------------------------------------
      nVal := FieldByName('L_Value').AsFloat;
      nMoney := nVal * FieldByName('L_Price').AsFloat;
      nMoney := Float2Float(nMoney, cPrecision, True);

      {$IFDEF JYZL}
        nStr := FieldByName('L_StockNo').AsString;
        if nStr = '6053' then  //熟料
             nStockID := '322'
        else nStockID := '326';

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', FieldByName('L_StockNo').AsString),
                                              
          SF('Fentryid', 1, sfVal),
          SF('Funitid', 132, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 1, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fseoutbillno', FieldByName('L_ID').AsString),
          SF('Fseoutinterid', '0', sfVal),
          SF('Fseoutentryid', '0', sfVal),

          SF('Fsourcebillno', '0'),
          SF('Fsourcetrantype', 83, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', nVal, sfVal),
          SF('Fauxqtymust', nVal, sfVal),

          SF('Fconsignprice', FieldByName('L_Price').AsFloat , sfVal),
          SF('Fconsignamount', nMoney, sfVal),
          SF('fdcstockid', nStockID, sfVal)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        nStr := FieldByName('L_StockNo').AsString;
        if (nStr = '444') or (nStr = '1388') then  //熟料
             nStockID := '1731'
        else nStockID := '1730';

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', FieldByName('L_StockNo').AsString),
                                              
          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 1, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fseoutbillno', '0'),
          SF('Fseoutinterid', '0', sfVal),
          SF('Fseoutentryid', '0', sfVal),

          SF('Fsourcebillno', '0'),
          SF('Fsourcetrantype', 83, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('Fentryselfb0166', FieldByName('L_ID').AsString),
          SF('Fentryselfb0167', FieldByName('L_Truck').AsString),
          SF('Fentryselfb0168', DateTime2Str(Now)),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', nVal, sfVal),
          SF('Fauxqtymust', nVal, sfVal),

          SF('Fconsignprice', FieldByName('L_Price').AsFloat , sfVal),
          SF('Fconsignamount', nMoney, sfVal),
          SF('fdcstockid', nStockID, sfVal)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ENDIF}

      Next;
      //xxxxx
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
      nStr := '同步交货单数据到K3系统失败.';
      raise Exception.Create(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;

//Date: 2014-10-15
//Parm: 采购单列表[FIn.FData]
//Desc: 同步采购单数据到K3系统
function TWorkerBusinessCommander.SyncRemoteStockOrder(var nData: string): Boolean;
var nID,nIdx: Integer;
    nVal: Double;
    nK3Worker: PDBWorker;
    nStr,nSQL,nBill,nStockID: string;
begin
  Result := False;
  nK3Worker := nil;

  nSQL := 'select O_ID,O_Truck,O_SaleID,O_ProID,O_StockNo,' +
          'D_ID, (D_MValue-D_PValue-D_KZValue) as D_Value,D_OutFact, ' +
          'D_PValue, D_MValue, D_YSResult, D_KZValue ' +
          'From $OD od left join $OO oo on od.D_OID=oo.O_ID ' +
          'where D_ID=''$IN''';
  nSQL := MacroValue(nSQL, [MI('$OD', sTable_OrderDtl) ,
                            MI('$OO', sTable_Order),
                            MI('$IN', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的采购单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if FieldByName('D_YSResult').AsString=sFlag_No then
    begin          //拒收
      Result := True;
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
      nSQL :='DECLARE @ret1 int, @FInterID int, @BillNo varchar(200) '+
            'Exec @ret1=GetICMaxNum @TableName=''%s'',@FInterID=@FInterID output '+
            'EXEC p_BM_GetBillNo @ClassType =1,@BillNo=@BillNo OUTPUT ' +
            'select @FInterID as FInterID , @BillNo as BillNo , ' +
            '''RetGetICMaxNum'' = @ret1';
      nSQL := Format(nSQL, ['ICStockBill']);
      //get FInterID, BillNo

      with gDBConnManager.WorkerQuery(nK3Worker, nSQL) do
      begin
        nBill := FieldByName('BillNo').AsString;
        nID := FieldByName('FInterID').AsInteger;
      end;

      {$IFDEF JYZL}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Ftrantype', 1, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fdeptid', 0, sfVal),
          SF('FEmpid', 0, sfVal),
          SF('Fsupplyid', FieldByName('O_ProID').AsString, sfVal),
          //SF('FPosterid', FieldByName('O_SaleID').AsString, sfVal),
          //SF('FCheckerid', FieldByName('O_SaleID').AsString, sfVal),


          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1789, sfVal),
          SF('Fsmanagerid', 1789, sfVal),

          SF('Fstatus', 0, sfVal),
          SF('Fvchinterid', 9662, sfVal),

          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Ftrantype', 1, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fdeptid', 0, sfVal),
          SF('FEmpid', 0, sfVal),
          SF('Fsupplyid', FieldByName('O_ProID').AsString, sfVal),
          //SF('FPosterid', FieldByName('O_SaleID').AsString, sfVal),
          //SF('FCheckerid', FieldByName('O_SaleID').AsString, sfVal),


          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1789, sfVal),
          SF('Fsmanagerid', 1789, sfVal),

          SF('Fstatus', 0, sfVal),
          SF('Fvchinterid', 9662, sfVal),

          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
      {$ENDIF}

      //------------------------------------------------------------------------
      nVal := FieldByName('D_Value').AsFloat;

      {$IFDEF JYZL}
        nStockID := FieldByName('O_StockNo').AsString;

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', nStockID),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', 0, sfVal),
          SF('Fauxqtymust', 0, sfVal),

          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 0, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('finstockid', '0', sfVal),
          SF('fdcstockid', '2071', sfVal),

          SF('FEntrySelfA0158', FieldByName('D_MValue').AsFloat, sfVal),
          SF('FEntrySelfA0159', FieldByName('D_PValue').AsFloat, sfVal),
          SF('FEntrySelfA0160', FieldByName('D_KZValue').AsFloat, sfVal),
          SF('FEntrySelfA0161', FieldByName('O_Truck').AsString),
          SF('FEntrySelfA0162', FieldByName('D_ID').AsString)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        nStockID := FieldByName('O_StockNo').AsString;

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', nStockID),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', 0, sfVal),
          SF('Fauxqtymust', 0, sfVal),

          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 0, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('finstockid', '0', sfVal),
          SF('fdcstockid', '2071', sfVal),

          SF('FEntrySelfA0158', FieldByName('D_MValue').AsFloat, sfVal),
          SF('FEntrySelfA0159', FieldByName('D_PValue').AsFloat, sfVal),
          SF('FEntrySelfA0160', FieldByName('D_KZValue').AsFloat, sfVal),
          SF('FEntrySelfA0161', FieldByName('O_Truck').AsString),
          SF('FEntrySelfA0162', FieldByName('D_ID').AsString)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ENDIF}

      Next;
      //xxxxx
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
      nStr := '同步采购单数据到K3系统失败.';
      raise Exception.Create(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;

//Date: 2014-10-16
//Parm: 物料列表[FIn.FData]
//Desc: 验证物料是否允许发货.
function TWorkerBusinessCommander.IsStockValid(var nData: string): Boolean;
var nStr: string;
    nK3Worker: PDBWorker;
begin
  Result := True;
  nK3Worker := nil;
  try
    nStr := 'Select FItemID,FName from T_ICItem Where FDeleted=1';
    //sql
    
    with gDBConnManager.SQLQuery(nStr, nK3Worker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then Exit;
      //not forbid

      SplitStr(FIn.FData, FListA, 0, ',');
      First;

      while not Eof do
      begin
        nStr := Fields[0].AsString;
        if FListA.IndexOf(nStr) >= 0 then
        begin
          nData := '品种[ %s.%s ]已禁用,不能发货.';
          nData := Format(nData, [nStr, Fields[1].AsString]);

          Result := False;
          Exit;
        end;

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
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
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
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
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
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
  nStr := 'Select Z_OrgAccountNum,Z_CompanyId From $ZK Where Z_ID=''$ZID''';
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
    FOut.FExtParam := FieldByName('Z_CompanyId').AsString;
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
    nStr := 'select sum(PostedQty+Received-Deducted+Registered-Picked-ReservPhysical) as Yuliang from %s a '+
            'where itemid=''%s'' and xtinventventerid=''%s'' and dataareaid=''%s'' ';
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
  WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nSendValue := Fields[0].AsFloat;
  end;

  nStr := 'select D_TotalValue from %s Where D_RECID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, Fin.FData]);
  WriteLog(nStr);
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
    s:string;
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,a.L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId'+
          ' From %s a where L_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的提货单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    nFYPlanStatus:='0';
    if FieldByName('L_InvCenterId').AsString='' then
    begin
      nData := '编号为[ %s ]的提货单产品没有配置生产线.';
      nData := Format(nData, [FIn.FData]);
      WriteLog(nData);
      Exit;
    end;   
    nLocationId := FieldByName('L_InvLocationId').AsString;
    if nLocationId = '' then nLocationId := 'A';
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+copy(FieldByName('L_ID').AsString,2,10)+'</TRANSPLANID>'+
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
      //s:=nService.test;
      //WriteLog('测试返回值：'+s);
      //s:=nService.WRZS2ERPInfoTEST('WRZS_001',nStr,'000');
      //WriteLog('返回值：'+s);
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
        nStr := FieldByName('L_ID').AsString+'提货单同步失败.';
        WriteLog('AX接口异常：'+nStr+#13#10+e.Message);
      end;
    end;
  finally

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
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId '+
          ' From %s a where L_ID = ''%s'' and L_FYAX=''1'' ';
  nSQL := Format(nSQL,[sTable_BillBak,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  try
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
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+copy(FieldByName('L_ID').AsString,2,10)+'</TRANSPLANID>'+
             '<SALESID>'+FieldByName('L_ZhiKa').AsString+'</SALESID>'+
             '<SALESLINERECID>'+FieldByName('L_LineRecID').AsString+'</SALESLINERECID>'+
             '<COMPANYID>'+gCompanyAct+'</COMPANYID>'+
             '<Destinationcode></Destinationcode>'+
             '<WMSLocationId></WMSLocationId>'+
             '<FYPlanStatus>'+nFYPlanStatus+'</FYPlanStatus>'+
             '<InventLocationId>'+nLocationId+'</InventLocationId>'+
             '<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>'+
           '</PRIMARY>';
    //WriteLog('发送值：'+nStr);
    //----------------------------------------------------------------------------
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
      //s:=nService.test;
      //WriteLog('测试返回值：'+s);
      //s:=nService.WRZS2ERPInfoTEST('WRZS_001',nStr,'000');
      //WriteLog('返回值：'+s);
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
  finally

  end;
end;

//同步空车出厂交货单
function TWorkerBusinessCommander.SyncEmptyOutBillAX(var nData: string):Boolean;
var nID,nIdx: Integer;
    nStr,nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nFYPlanStatus,nCenterId,nLocationId:string;
    s:string;
begin
  Result := False;

  nSQL := 'select a.L_PlanQty,a.L_Truck,a.L_ID,a.L_ZhiKa,a.L_LineRecID,'+
          'a.L_InvCenterId,a.L_InvLocationId'+
          ' From %s a where L_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_Bill,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  try
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
    nStr:='<PRIMARY>'+
             '<PLANQTY>'+FieldByName('L_PlanQty').AsString+'</PLANQTY>'+
             '<VEHICLEId>'+FieldByName('L_Truck').AsString+'</VEHICLEId>'+
             '<VENDPICKINGLISTID>S</VENDPICKINGLISTID>'+
             '<TRANSPORTER></TRANSPORTER>'+
             '<TRANSPLANID>'+copy(FieldByName('L_ID').AsString,2,10)+'</TRANSPLANID>'+
             '<SALESID>'+FieldByName('L_ZhiKa').AsString+'</SALESID>'+
             '<SALESLINERECID>'+FieldByName('L_LineRecID').AsString+'</SALESLINERECID>'+
             '<COMPANYID>'+gCompanyAct+'</COMPANYID>'+
             '<Destinationcode></Destinationcode>'+
             '<WMSLocationId></WMSLocationId>'+
             '<FYPlanStatus>'+nFYPlanStatus+'</FYPlanStatus>'+
             '<InventLocationId>'+nLocationId+'</InventLocationId>'+
             '<xtDInventCenterId>'+FieldByName('L_InvCenterId').AsString+'</xtDInventCenterId>'+
           '</PRIMARY>';
    //WriteLog('发送值：'+nStr);
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
  finally

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
begin
  Result := False;

  nSQL := 'select a.L_ID,a.L_StockNo,a.L_Truck,a.L_PValue,a.L_MValue,a.L_Value,'+
          'a.L_InvCenterId,a.L_InvLocationId,a.L_CW,a.L_PlanQty,a.L_HYDan,a.L_Type,'+
          'a.L_MMan,a.L_MDate,b.P_ID,a.L_ZhiKa,a.L_LineRecID,a.L_StockName,'+
          'L_Value*L_Price as L_TotalMoney,L_CusID,L_ContQuota'+
          ' From %s a,%s b '+
          ' where a.L_ID = ''%s'' and a.L_ID=b.P_Bill ';
  nSQL := Format(nSQL,[sTable_Bill,sTable_PoundLog,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
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
      nNetValue:=FieldByName('L_MValue').AsFloat-FieldByName('L_PValue').AsFloat;
    nStr := '<PRIMARY>';
    nStr := nStr+'<TRANSPLANID>'+copy(FieldByName('L_ID').AsString,2,10)+'</TRANSPLANID>';
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
    {$IFDEF DEBUG}
    WriteLog('发送值：'+nStr);
    {$ENDIF}
    try
      nService:=GetBPM2ERPServiceSoap(True,gURLAddr,nil);
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
  finally

  end;
end;

function TWorkerBusinessCommander.SyncPurPoundBillAX(var nData: string):Boolean;//同步磅单（采购）到AX
var nID,nIdx: Integer;
    nStr,nWeightMan:string;
    nSQL: string;
    nService: BPM2ERPServiceSoap;
    nMsg:Integer;
    nsWeightTime:string;
begin
  Result := False;
  nSQL := 'select * From %s a, %s b, %s c where a.D_OID=b.O_ID and a.D_ID=c.P_Order and a.D_ID = ''%s'' ';
  nSQL := Format(nSQL,[sTable_OrderDtl,sTable_Order,sTable_PoundLog,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '采购单号为[ %s ]的采购磅单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    nsWeightTime:=formatdatetime('yyyy-mm-dd hh:mm:ss',FieldByName('D_MDate').AsDateTime);
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
    nStr := nStr+'<WeightDate>'+FieldByName('D_MDate').AsString+'</WeightDate>';
    nStr := nStr+'<description></description>';
    nStr := nStr+'<WeighingNum>'+copy(FieldByName('P_ID').AsString,2,10)+'</WeighingNum>';
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
  finally

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
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;

function TWorkerBusinessCommander.GetSampleID(var nData: string):Boolean;//获取试样编号
var
  nStr:string;
begin
  result:=False;
  nStr := 'select top 1 IsNull(R_SerialNo,'''') as R_SerialNo,R_Date from %s a,%s b '+
          'where a.R_PID = b.P_ID and b.P_Stock= ''%s'' order by R_ID desc';
  nStr := Format(nStr,[sTable_StockRecord, sTable_StockParam, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if (RecordCount > 0) then
    begin
      FOut.FData:=Fields[0].AsString;
      FOut.FExtParam:=FormatDateTime('yyyy-mm-dd hh:mm:ss',Fields[1].AsDateTime);
      Result:=True;
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

{$ENDIF}

//------------------------------------------------------------------------------
class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaleAdjust          : Result := BillSaleAdjust(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索nStock对应的物料分组
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索车辆队列中与nStock同品种,或同组的记录
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '有效的车牌号长度为3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('车牌号[ %s ]无效.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: 允许散装多单
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Lih  2016-09-01
//载入nZID的信息返回查询数据集
function TWorkerBusinessBills.LoadZhiKaInfo(const nZID: string; var nHint: string): TDataset;
var nStr: string;
begin
  nStr := 'Select zk.*,con.C_ContQuota,cus.C_Name,cus.C_PY,con.C_Area From $ZK zk ' +
          ' Left Join $Con con On con.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract),
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  Result := gDBConnManager.WorkerQuery(FDBConn, nStr);
end;

//Date: 2014-09-15
//Desc: 验证能否开单
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
    nDBZhiKa: TDataSet;
    nOut: TWorkerBusinessCommand;
    nHint: string;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  FSanMultiBill := AllowedSanMultiBill;
  //散装允许开多单

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select a.R_ID,a.T_Bill,a.T_StockNo,a.T_Type,'+
          'a.T_InFact,a.T_Valid,b.L_Status From %s a ' +
          'left join %s b on a.T_Bill = b.L_ID '+
          'Where a.T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, sTable_Bill, nTruck]);
  //还在队列中车辆

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) and
        (FieldByName('L_Status').AsString <> sFlag_TruckOut) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') and
         (FieldByName('L_Status').AsString <> sFlag_TruckOut) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; {else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '车辆[ %s ]有已出队的交货单[ %s ],需先处理.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; }

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end; 

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  //----------------------------------------------------------------------------
  {nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$ZID', FListA.Values['ZhiKa'])]);  }
  nDBZhiKa:=LoadZhiKaInfo(FListA.Values['ZhiKa'], nHint);
  //纸卡信息
  with nDBZhiKa,FListA do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [Values['ZhiKa']]);
      Exit;
    end;

    nStr := FieldByName('Z_TJStatus').AsString;
    if nStr  <> '' then
    begin
      if nStr = sFlag_TJOver then
           nData := '纸卡[ %s ]已调价,请重新开单.'
      else nData := '纸卡[ %s ]正在调价,请稍后.';

      nData := Format(nData, [Values['ZhiKa']]);
      Exit;
    end;

    {if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [Values['ZhiKa'],
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;   }
    Values['TriaTrade'] := FieldByName('Z_TriangleTrade').AsString;  //1：是三角贸易 0：否
    if Values['TriaTrade']='1' then
    begin
      Values['CusID'] := FieldByName('Z_OrgAccountNum').AsString;
      Values['CusName'] := FieldByName('Z_OrgAccountName').AsString;
      Values['CusPY'] := '';
    end else
    begin
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
    end;

    Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    Values['CompanyId'] := FieldByName('Z_CompanyId').AsString;
    Values['ContQuota'] := FieldByName('C_ContQuota').AsString;

    Values['ContractID'] := FieldByName('Z_CID').AsString;
    Values['Area'] := FieldByName('Z_XSQYBM').AsString;
    Values['KHSBM'] := FieldByName('Z_KHSBM').AsString;
    
    Values['OrgXSQYMC'] := FieldByName('Z_OrgXSQYMC').AsString;
  end;

  Result := True;
  //verify done
end;

//获取在线模式
function TWorkerBusinessBills.GetOnLineModel: string;
var
  nStr: string;
begin
  Result:=sFlag_Yes;
  nStr := 'select D_Value from %s where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_OnLineModel]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result:=Fields[0].AsString;
  end;
end;

//在线远程获取客户信用和资金
function TWorkerBusinessBills.GetRemCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
var
  nStr:string;
  nCusID,nZcid,nContQuota: string;
  nOut: TWorkerBusinessCommand;
  nDBZhiKa:TDataSet;
  nHint: string;
begin
  nRemMoney:= 0.00;

  nStr := 'Select zk.*,con.C_ContQuota From $ZK zk ' +
          ' Left Join $Con con On con.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), 
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  //纸卡信息
  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    nCusID := FieldByName('Z_Customer').AsString;
    nContQuota := FieldByName('C_ContQuota').AsString;
    nZcid:= FieldByName('Z_CID').AsString;
    if nContQuota='1' then
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_GetTprGemCont, nCusID+','+nZcid, gCompanyAct, @nOut) then
      begin
        nMsg := Format('在线获取[ %s ]合同信用额度信息失败,已终止.', [nCusID+','+nZcid]);
        Result := False;
        Exit;
      end;
      Result:=True;
      nRemMoney := StrToFloat(nOut.FExtParam);
      WriteLog('ZAX Money: '+nOut.FExtParam);
      
      if nOut.FData=sFlag_No then nMsg:='['+nCusID+']资金余额不足.';
    end else
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_GetTprGem, nCusID, gCompanyAct, @nOut) then
      begin
        nMsg := Format('在线获取[ %s ]客户信用额度信息失败,已终止.', [nCusID]);
        Result := False;
        Exit;
      end;
      Result:=True;
      nRemMoney := StrToFloat(nOut.FExtParam);
      WriteLog('ZAX Money: '+nOut.FExtParam);

      if nOut.FData=sFlag_No then nMsg:='['+nCusID+']资金余额不足.';
    end;
  end;
end;

//在线远程获取三角贸易客户信用和资金
function TWorkerBusinessBills.GetRemTriCustomerMoney(const nZID:string; var nRemMoney:Double; var nMsg:string): Boolean;
var
  nStr:string;
  nOrgCusID,nOriSalesId,nCompanyId,nZcid,nContQuota: string;
  nOut: TWorkerBusinessCommand;
  nDBZhiKa:TDataSet;
  nHint: string;
begin
  nRemMoney:= 0.00;
  nStr := 'Select Z_CompanyId,Z_OrgAccountNum,Z_IntComOriSalesId From $ZK Where Z_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ID', nZID)]);
  //纸卡信息
  //WriteLog(nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nMsg := Format('[ %s ]销售订单不存在,已终止.', [nZID]);
      Result:=False;
      Exit;
    end;
    nOrgCusID := FieldByName('Z_OrgAccountNum').AsString;
    nOriSalesId := FieldByName('Z_IntComOriSalesId').AsString;
    nCompanyId := FieldByName('Z_CompanyId').AsString;
  end;
  
  if not TWorkerBusinessCommander.CallMe(cBC_GetAXContQuota, nOriSalesId, nCompanyId, @nOut) then
  begin
    nMsg := Format('三角贸易订单[ %s ]在线获取合同信息失败,已终止.', [nZID]);
    Result := False;
    Exit;
  end;
  nContQuota := nOut.FData;
  nZcid:= nOut.FExtParam;
  if nContQuota = sFlag_Yes then
  begin
    if not TWorkerBusinessCommander.CallMe(cBC_GetTprGemCont, nOrgCusID+','+nZcid, nCompanyId, @nOut) then
    begin
      nMsg := Format('在线获取[ %s ]合同信用额度信息失败,已终止.', [nOrgCusID+','+nZcid]);
      Result := False;
      Exit;
    end;
    Result:=True;
    nRemMoney := StrToFloat(nOut.FExtParam);
    WriteLog('SAX Money: '+nOut.FExtParam);

    if nOut.FData=sFlag_No then nMsg:='['+nOrgCusID+']资金余额不足.';
  end else
  begin
    if not TWorkerBusinessCommander.CallMe(cBC_GetTprGem, nOrgCusID, nCompanyId, @nOut) then
    begin
      nMsg := Format('在线获取[ %s ]客户信用额度信息失败,已终止.', [nOrgCusID]);
      Result := False;
      Exit;
    end;
    Result:=True;
    nRemMoney := StrToFloat(nOut.FExtParam);
    WriteLog('SAX Money: '+nOut.FExtParam);
    
    if nOut.FData=sFlag_No then nMsg:='['+nOrgCusID+']资金余额不足.';
  end;
end;

//by lih 2016-06-06
//开单发送微信消息
function TWorkerBusinessBills.SaveBillSendMsgWx(LID:string):Boolean;
var
  nSql,nStr: string;
  nRID:string;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  errcode,errmsg:string;
begin
  Result:=False;
  try
    nSql := 'Select a.R_ID,b.C_Factory,b.C_ToUser,a.L_ID,a.L_Card,a.L_Truck,a.L_StockNo,' +
            'a.L_StockName,a.L_CusID,a.L_CusName,a.L_CusAccount,a.L_MDate,a.L_MMan,' +
            'a.L_TransID,a.L_TransName,a.L_Searial,a.L_OutFact,a.L_OutMan From '+sTable_Bill+' a,'+sTable_Customer+' b ' +
            'Where a.L_CusID=b.C_ID and b.C_IsBind=''1'' and '''+LID+''' like ''%''+a.L_ID+''%'' ';
    //nSql := Format(nSql, [sTable_Bill,sTable_Customer,LID]);
    {$IFDEF DEBUG}
    WriteLog(nSql);
    {$ENDIF}
    with gDBConnManager.WorkerQuery(FDBConn, nSql) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
              '<DATA>'+
              '<head>'+
              '<Factory>'+Fields[1].AsString+'</Factory>'+
              '<ToUser>'+Fields[2].AsString+'</ToUser>'+
              '<MsgType>1</MsgType>'+
              '</head>'+
              '<Items>'+
                '<Item>'+
                '<BillID>'+Fields[3].AsString+'</BillID>'+
                '<Card>'+Fields[4].AsString+'</Card>'+
                '<Truck>'+Fields[5].AsString+'</Truck>'+
                '<StockNo>'+Fields[6].AsString+'</StockNo>'+
                '<StockName>'+Fields[7].AsString+'</StockName>'+
                '<CusID>'+Fields[8].AsString+'</CusID>'+
                '<CusName>'+Fields[9].AsString+'</CusName>'+
                '<CusAccount>'+Fields[10].AsString+'</CusAccount>'+
                '<MakeDate>'+Fields[11].AsString+'</MakeDate>'+
                '<MakeMan>'+Fields[12].AsString+'</MakeMan>'+
                '<TransID>'+Fields[13].AsString+'</TransID>'+
                '<TransName>'+Fields[14].AsString+'</TransName>'+
                '<Searial>'+Fields[15].AsString+'</Searial>'+
                '<OutFact>'+Fields[16].AsString+'</OutFact>'+
                '<OutMan>'+Fields[17].AsString+'</OutMan>'+
                '</Item>'+
              '</Items>'+
               '<remark/>'+
              '</DATA>';
        {$IFDEF DEBUG}
        WriteLog(nStr);
        {$ENDIF}
        wxservice:=GetReviceWS(true,'',nil);
        nMsg:=wxservice.mainfuncs('send_event_msg',nStr);
        {$IFDEF DEBUG}
        WriteLog(nMsg);
        {$ENDIF}
        FPacker.XMLBuilder.ReadFromString(nMsg);
        with FPacker.XMLBuilder do
        begin
          nhead:=Root.FindNode('head');
          if Assigned(nhead) then
          begin
            errcode:=nhead.NodebyName('errcode').ValueAsString;
            errmsg:=nhead.NodebyName('errmsg').ValueAsString;
            if errcode='0' then nRID:=nRID+'R_ID='+Fields[0].AsString+' or ';
          end;
        end;
        Next;
      end;
    end;
    nRID:=Trim(nRID);
    nRID:=Copy(nRID,1,length(nRID)-2);
    nSql:='update %s set L_NewSendWx=''Y'' where %s';
    nSql:=Format(nSql,[sTable_Bill,nRID]);
    gDBConnManager.WorkerExec(FDBConn,nSql);
    Result:=True;
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

//Date: 2014-09-15
//Desc: 保存交货单
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nStr,nSQL,nFixMoney: string;
    nIdx: Integer;
    nVal,nMoney: Double;
    nOut: TWorkerBusinessCommand;
    nBxz: Boolean;
    nAxMoney, nSendValue: Double;
    nAxMsg,nOnLineModel: string;
begin
  Result := False;
  nBxz:= True; //默认强制信用额度
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;
  nOnLineModel:=GetOnLineModel; //获取是否在线模式
  if FListA.Values['SalesType'] = '0' then
  begin
    nBxz:=False;
  end else
  begin
    if FListA.Values['TriaTrade']='1' then
    begin
      if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_GetAXMaCredLmt, //是否强制信用额度
                FListA.Values['CusID'], FListA.Values['CompanyId'], @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        if nOut.FData = sFlag_No then
        begin
          nBxz:=False;
        end;
        if nBxz then
        begin
          if not GetRemTriCustomerMoney(FListA.Values['ZhiKa'],nAxMoney,nAxMsg) then
          begin
            nData:=nAxMsg;
            Exit;
          end;
        end;
      end else
      begin
        nData := '离线模式，获取三角贸易客户信息失败';
        Exit;
      end;
    end else
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_CustomerMaCredLmt, //是否强制信用额度
                FListA.Values['CusID'], '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
      if nOut.FData = sFlag_No then
      begin
        nBxz:=False;
      end;
      if nBxz then
      begin
        if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
        begin
          if not GetRemCustomerMoney(FListA.Values['ZhiKa'],nAxMoney,nAxMsg) then
          begin
            nData:=nAxMsg;
            Exit;
          end;
        end;
        if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney,  //获取本地资金额度
               FListA.Values['ZhiKa'], '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        nMoney := StrToFloat(nOut.FData);
        //nFixMoney := nOut.FExtParam;
        nFixMoney := sFlag_No;
        //Customer money
      end;
    end;
    if nBxz and (nOnLineModel=sFlag_Yes) then
    begin
      nStr := 'select IsNull(SUM(L_Value*L_Price),''0'') as L_TotalMoney from %s where L_BDAX = ''2'' and L_CusID=''%s'' ';
      nStr := Format(nStr,[sTable_Bill, FListA.Values['CusID']]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        nAxMoney := nAxMoney - Fields[0].AsFloat;
        WriteLog(FListA.Values['CusID']+': '+FloatToStr(nAxMoney));
      end;
    end;
  end;

  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);
  //unpack bill list
  nVal := 0;
  for nIdx:=0 to FListB.Count - 1 do
  begin
    FListC.Text := PackerDecodeStr(FListB[nIdx]);
    //get bill info

    with FListC do
      nVal := nVal + Float2Float(StrToFloat(Values['Price']) *
                     StrToFloat(Values['Value']), cPrecision, True);
    //xxxx
  end;
  
  if nBxz then
  begin
    if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
    begin
      if (FloatRelation(nVal, nAxMoney, rtGreater)) then
      begin
        nData := '客户[ %s ]没有足够的金额,详情如下:' + #13#10#13#10 +
                 '可用金额: %.2f' + #13#10 +
                 '开单金额: %.2f' + #13#10#13#10 +
                 '请减小提货量后再开单.';
        nData := Format(nData, [FListA.Values['CusID'], nAxMoney, nVal]);
        Exit;
      end;
    end;
    if FListA.Values['TriaTrade'] <> '1' then
    begin
      if (FloatRelation(nVal, nMoney, rtGreater)) then
      begin
        nData := '客户[ %s ]没有足够的金额,详情如下:' + #13#10#13#10 +
                 '可用金额: %.2f' + #13#10 +
                 '开单金额: %.2f' + #13#10#13#10 +
                 '请减小提货量后再开单.';
        nData := Format(nData, [FListA.Values['CusID'], nMoney, nVal]);
        Exit;
      end;
    end;
  end;
  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    for nIdx:=0 to FListB.Count - 1 do
    begin
      FListC.Values['Group'] :=sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_BillNo;
      //to get serial no

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill
      FListC.Text := PackerDecodeStr(FListB[nIdx]);
      //get bill info
      if FListA.Values['LocationID']='' then FListA.Values['LocationID'] := 'A';
      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FListA.Values['ZhiKa']),
              SF('L_Project', FListA.Values['Project']),

              SF('L_CusID', FListA.Values['CusID']),
              SF('L_CusName', FListA.Values['CusName']),
              SF('L_CusPY', FListA.Values['CusPY']),

              SF('L_Type', FListC.Values['Type']),
              SF('L_StockNo', FListC.Values['StockNO']),
              SF('L_StockName', FListC.Values['StockName']),

              SF('L_Value', FListC.Values['Value'], sfVal),
              SF('L_PlanQty', FListC.Values['Value'], sfVal),
              SF('L_Price', FListC.Values['Price'], sfVal),
              SF('L_LineRecID', FListC.Values['RECID']),
              
              SF('L_ZKMoney', nFixMoney),
              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Status', sFlag_BillNew),

              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListA.Values['Seal']),

              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal),
              SF('L_IfHYPrint', FListA.Values['IfHYprt']),

              SF('L_HYDan', FListC.Values['SampleID']),
              SF('L_SalesType', FListA.Values['SalesType']),
              SF('L_InvCenterId', FListA.Values['CenterID']),

              SF('L_InvLocationId', FListA.Values['LocationID']),
              SF('L_Area', FListA.Values['Area']),
              SF('L_KHSBM', FListA.Values['KHSBM']),
              SF('L_JXSTHD', FListA.Values['JXSTHD']),

              SF('L_OrgXSQYMC', FListA.Values['OrgXSQYMC']),
              SF('L_CW', FListA.Values['KuWei']),
              SF('L_TriaTrade', FListA.Values['TriaTrade']),

              SF('L_ContQuota', FListA.Values['ContQuota'])
              ], sTable_Bill, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      if FListA.Values['BuDan'] = sFlag_Yes then //补单
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        if FListC.Values['Type'] = sFlag_San then
        begin
          nStr := '';
          //散装不予合单
        end else
        begin
          nStr := FListC.Values['StockNO'];
          nStr := GetMatchRecord(nStr);
          //该品种在装车队列中的记录号
        end;

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr), MI('$Val', FListC.Values['Value']),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          nSQL := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListC.Values['StockNO']),
            SF('T_Stock'   , FListC.Values['StockName']),
            SF('T_Type'    , FListC.Values['Type']),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListC.Values['Value'], sfVal),
            SF('T_VIP'     , FListA.Values['IsVIP']),
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
      end;
    end;

    if FListA.Values['BuDan'] = sFlag_Yes then //补单
    begin
      {if FListA.Values['ContQuota'] = '1' then
      begin
        nStr := 'Update %s Set A_ConOutMoney=A_ConOutMoney+%s Where A_CID=''%s''';
        nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                FListA.Values['CusID']]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        nStr := 'Update %s Set A_OutMoney=A_OutMoney+%s Where A_CID=''%s''';
        nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                FListA.Values['CusID']]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;  }
      //freeze money from account
    end else
    begin
      if FListA.Values['TriaTrade'] <> '1' then
      begin
        if FListA.Values['ContQuota'] = '1' then
        begin
          nStr := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney+%s Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                  FListA.Values['CusID']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end else
        begin
          nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney+%s Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
                  FListA.Values['CusID']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
        //freeze money from account
        WriteLog('['+nOut.FData+']Add YKMoney: '+nStr);
      end;
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    FDBConn.FConn.CommitTrans;

    nStr := 'select IsNull(SUM(L_Value),''0'') as SendValue from %s where L_LineRecID=''%s'' ';
    nStr := Format(nStr,[sTable_Bill, FListC.Values['RECID']]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nSendValue := Fields[0].AsFloat;
    end;

    nStr := 'Update %s Set D_Value=D_TotalValue-(%.2f) Where D_RECID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nSendValue, FListC.Values['RECID']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  //if SaveBillSendMsgWx(FOut.FData) then nData:=FOut.FData+'开单发送微信消息成功！';
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: 交货单[FIn.FData];车牌号[FIn.FExtParam]
//Desc: 修改指定交货单的车牌号
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if Fields[1].AsString <> '' then
    begin
      nData := '交货单[ %s ]已提货,无法修改车牌号.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;


    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-30
//Parm: 交货单号[FIn.FData];新纸卡[FIn.FExtParam]
//Desc: 将交货单调拨给新纸卡的客户
function TWorkerBusinessBills.BillSaleAdjust(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal,nMon: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  //----------------------------------------------------------------------------
  nStr := 'Select L_CusID,L_StockNo,L_StockName,L_Value,L_Price,L_ZhiKa,' +
          'L_ZKMoney,L_OutFact From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    if FieldByName('L_OutFact').AsString = '' then
    begin
      nData := '车辆出厂后(提货完毕)才能调拨.';
      Exit;
    end;

    FListB.Clear;
    with FListB do
    begin
      Values['CusID'] := FieldByName('L_CusID').AsString;
      Values['StockNo'] := FieldByName('L_StockNo').AsString;
      Values['StockName'] := FieldByName('L_StockName').AsString;
      Values['ZhiKa'] := FieldByName('L_ZhiKa').AsString;
      Values['ZKMoney'] := FieldByName('L_ZKMoney').AsString;
    end;
    
    nVal := FieldByName('L_Value').AsFloat;
    nMon := nVal * FieldByName('L_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FIn.FExtParam)]);
  //纸卡信息

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [FIn.FExtParam,
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    FListA.Clear;
    with FListA do
    begin
      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Price From %s Where D_ZID=''%s'' And D_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FIn.FExtParam, FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '纸卡[ %s ]上没有名称为[ %s ]的品种.';
      nData := Format(nData, [FIn.FExtParam, FListB.Values['StockName']]);
      Exit;
    end;

    FListC.Clear;
    nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListB.Values['CusID']]);
    FListC.Add(nStr); //还原提货方出金

    if FListB.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) ' +
              'Where Z_ID=''%s'' And Z_OnlyMoney=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon,
              FListB.Values['ZhiKa'], sFlag_Yes]);
      FListC.Add(nStr); //还原提货方限提金额
    end;

    nMon := nVal * FieldByName('D_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);

    if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FIn.FExtParam, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    if FloatRelation(nMon, StrToFloat(nOut.FData), rtGreater, cPrecision) then
    begin
      nData := '客户[ %s.%s ]余额不足,详情如下:' + #13#10#13#10 +
               '※.可用余额: %.2f元' + #13#10 +
               '※.调拨所需: %.2f元' + #13#10 +
               '※.需 补 交: %.2f元' + #13#10#13#10 +
               '请到财务室办理"补交货款"手续,然后再次调拨.';
      nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
               StrToFloat(nOut.FData), nMon,
               Float2Float(nMon - StrToFloat(nOut.FData), cPrecision, True)]);
      Exit;
    end;

    nStr := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListA.Values['CusID']]);
    FListC.Add(nStr); //增加调拨方出金

    if FListA.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon, FIn.FExtParam]);
      FListC.Add(nStr); //扣减调拨方限提金额
    end;

    nStr := MakeSQLByStr([SF('L_ZhiKa', FIn.FExtParam),
            SF('L_Project', FListA.Values['Project']),
            SF('L_Area', FListA.Values['Area']),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', FListA.Values['CusPY']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),
            SF('L_Price', FieldByName('D_Price').AsFloat, sfVal),
            SF('L_ZKMoney', FListA.Values['ZKMoney'])
            ], sTable_Bill, SF('L_ID', FIn.FData), False);
    FListC.Add(nStr); //增加调拨方出金
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//by lih 2016-06-06
//开单发送微信消息
function TWorkerBusinessBills.DelBillSendMsgWx(LID:string):Boolean;
var
  nSql,nStr: string;
  nRID:string;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  errcode,errmsg:string;
begin
  Result:=False;
  try
    nSql := 'Select a.R_ID,b.C_Factory,b.C_ToUser,a.L_ID,a.L_Card,a.L_Truck,a.L_StockNo,' +
            'a.L_StockName,a.L_CusID,a.L_CusName,a.L_CusAccount,a.L_MDate,a.L_MMan,' +
            'a.L_TransID,a.L_TransName,a.L_Searial,a.L_OutFact,a.L_OutMan From %s a,%s b ' +
            'Where a.L_CusID=b.C_ID and b.C_IsBind=''1'' and a.L_ID =''%s'' ';
    nSql := Format(nSql, [sTable_BillBak,sTable_Customer,LID]);
    {$IFDEF DEBUG}
    WriteLog(nSql);
    {$ENDIF}
    with gDBConnManager.WorkerQuery(FDBConn, nSql) do
    if RecordCount > 0 then
    begin
      nRID:=Fields[0].AsString;
      nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
            '<DATA>'+
            '<head>'+
            '<Factory>'+Fields[1].AsString+'</Factory>'+
            '<ToUser>'+Fields[2].AsString+'</ToUser>'+
            '<MsgType>4</MsgType>'+
            '</head>'+
            '<Items>'+
              '<Item>'+
              '<BillID>'+Fields[3].AsString+'</BillID>'+
              '<Card>'+Fields[4].AsString+'</Card>'+
              '<Truck>'+Fields[5].AsString+'</Truck>'+
              '<StockNo>'+Fields[6].AsString+'</StockNo>'+
              '<StockName>'+Fields[7].AsString+'</StockName>'+
              '<CusID>'+Fields[8].AsString+'</CusID>'+
              '<CusName>'+Fields[9].AsString+'</CusName>'+
              '<CusAccount>'+Fields[10].AsString+'</CusAccount>'+
              '<MakeDate>'+Fields[11].AsString+'</MakeDate>'+
              '<MakeMan>'+Fields[12].AsString+'</MakeMan>'+
              '<TransID>'+Fields[13].AsString+'</TransID>'+
              '<TransName>'+Fields[14].AsString+'</TransName>'+
              '<Searial>'+Fields[15].AsString+'</Searial>'+
              '<OutFact>'+Fields[16].AsString+'</OutFact>'+
              '<OutMan>'+Fields[17].AsString+'</OutMan>'+
              '</Item>'+
            '</Items>'+
             '<remark/>'+
            '</DATA>';
      {$IFDEF DEBUG}
      WriteLog(nStr);
      {$ENDIF}
      wxservice:=GetReviceWS(true,'',nil);
      nMsg:=wxservice.mainfuncs('send_event_msg',nStr);
      {$IFDEF DEBUG}
      WriteLog(nMsg);
      {$ENDIF}
      FPacker.XMLBuilder.ReadFromString(nMsg);
      with FPacker.XMLBuilder do
      begin
        nhead:=Root.FindNode('head');
        if Assigned(nhead) then
        begin
          errcode:=nhead.NodebyName('errcode').ValueAsString;
          errmsg:=nhead.NodebyName('errmsg').ValueAsString;
          if errcode='0' then
          begin
            nSql:='update %s set L_DelSendWx=''Y'' where R_ID=%s';
            nSql:=Format(nSql,[sTable_BillBak,nRID]);
            gDBConnManager.WorkerExec(FDBConn,nSql);
            Result:=True;
          end;
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

//Date: 2014-09-16
//Parm: 交货单号[FIn.FData]
//Desc: 删除指定交货单
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nHasOut: Boolean;
    nVal,nMoney: Double;
    nStr,nP,nFix,nRID,nCus,nBill,nZK: string;
    nOut:TWorkerBusinessCommand;
    nDBZhiKa:TDataSet;
    nHint,nLineRecID:string;
    nSendValue:Double;
begin
  Result := False;
  //init

  nStr := 'Select L_ZhiKa,L_Value,L_Price,L_CusID,L_OutFact,L_ZKMoney,L_LineRecID From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    //已出厂

    if nHasOut then
    begin
      nData := '交货单[ %s ]已出厂,不允许删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    
    nCus := FieldByName('L_CusID').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nFix := FieldByName('L_ZKMoney').AsString;

    nVal := FieldByName('L_Value').AsFloat;
    nMoney := Float2Float(nVal*FieldByName('L_Price').AsFloat, cPrecision, True);
    nLineRecID := FieldByName('L_LineRecID').AsString;
  end;
                   
  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]出现在多条记录上,异常终止!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //移出合单列表

      if nBill = FIn.FData then
        nBill := FListA[0];
      //更换交货单

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新合单信息
    end;

    //--------------------------------------------------------------------------
    {if nHasOut then
    begin
      nDBZhiKa:=LoadZhiKaInfo(nZK,nHint);
      with nDBZhiKa do
      begin
        if FieldByName('C_ContQuota').AsString='1' then
        begin
          nStr := 'Update %s Set A_ConOutMoney=A_ConOutMoney-(%.2f) Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
        end else
        begin
          nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
        end;
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      //释放出金
    end else}
    //if (GetOnLineModel <> sFlag_Yes) then
    begin
      nDBZhiKa:=LoadZhiKaInfo(nZK,nHint);
      if Assigned(nDBZhiKa) then
      with nDBZhiKa do
      begin
        if FieldByName('Z_TriangleTrade').AsString <> '1' then
        begin
          if FieldByName('C_ContQuota').AsString='1' then
          begin
            nStr := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%.2f) Where A_CID=''%s''';
            nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
          end else
          begin
            nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
            nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
          end;
          gDBConnManager.WorkerExec(FDBConn, nStr);
          WriteLog('['+FIn.FData+']Release YKMoney: '+nStr);
        end;
      end;
      //释放冻结金
    end;

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    FDBConn.FConn.CommitTrans;

    nStr := 'select IsNull(SUM(L_Value),''0'') as SendValue from %s where L_LineRecID=''%s'' ';
    nStr := Format(nStr,[sTable_Bill, nLineRecID]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nSendValue := Fields[0].AsFloat;
    end;

    nStr := 'Update %s Set D_Value=D_TotalValue-(%.2f) Where D_RECID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nSendValue, nLineRecID]);
    //xxxxx
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
  {if Result then
  begin
    if DelBillSendMsgWx(FIn.FData) then nData:=FIn.FData+'删单发送微信消息成功！';
  end;}
end;

//Date: 2014-09-17
//Parm: 交货单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为交货单绑定磁卡
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin  
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //交货单列表

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '交货单[ %s ]已出厂,禁止办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '交货单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '交货单[ %s ]同为散装,不能并单.'
        else nData := '交货单[ %s ]的水泥类型不一致,不能并单.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //交货单列表
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '车辆[ %s ]正在使用该卡,无法并单.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '车辆[ %s ]正在使用该卡,相同牌号才能并单.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

  //还在队列中车辆
  nStr := '';
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    try
      nStr := nStr + Fields[0].AsString;
    finally
      Next;
    end;

    nStr := Copy(nStr, 1, Length(nStr)-1);
    nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
  end; 

  nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
  //队列中交货单列表

  nSQL := 'Select L_Card From %s Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if (Fields[0].AsString <> '') and
         (Fields[0].AsString <> FIn.FExtParam) then
      begin
        nData := '车辆[ %s ]的磁卡号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单磁卡: [%s]' + #13#10 +
                 '*.其它磁卡: [%s]' + #13#10#13#10 +
                 '相同磁卡号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
        Exit;
      end;

      Next;
    end;  
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData]
//Desc: 注销磁卡
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足交货单编码规则,则视为交货单号
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,L_SalesType,'+
          'L_EmptyOut,L_LineRecID,L_InvLocationId,L_InvCenterId,'+
          'L_TriaTrade From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '交货单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]没有交货单.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

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

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FSalesType    := FieldByName('L_SalesType').AsString;

      FYSValid      := FieldByName('L_EmptyOut').AsString;
      FRecID        := FieldByName('L_LineRecID').AsString;
      FLocationID   := FieldByName('L_InvLocationId').AsString;
      
      FCenterID     := FieldByName('L_InvCenterId').AsString;
      FTriaTrade    := FieldByName('L_TriaTrade').AsString;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//by lih 2016-06-07
//出厂发送微信消息
function TWorkerBusinessBills.TruckOutSendMsgWx(nList:TStrings):Boolean;
var
  nSql,nStr: string;
  nRID:string;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  errcode,errmsg:string;
  i:Integer;
begin
  Result:=False;
  try
    for i:= 0 to nList.Count-1 do
    begin
      nSql := 'Select a.R_ID,b.C_Factory,b.C_ToUser,a.L_ID,a.L_Card,a.L_Truck,a.L_StockNo,' +
              'a.L_StockName,a.L_CusID,a.L_CusName,a.L_CusAccount,a.L_MDate,a.L_MMan,' +
              'a.L_TransID,a.L_TransName,a.L_Searial,a.L_OutFact,a.L_OutMan From %s a,%s b ' +
              'Where a.L_CusID=b.C_ID and b.C_IsBind=''1'' and a.L_ID =%s ';
      nSql := Format(nSql, [sTable_Bill,sTable_Customer,nList[i]]);
      {$IFDEF DEBUG}
      WriteLog(nSql);
      {$ENDIF}
      with gDBConnManager.WorkerQuery(FDBConn, nSql) do
      if RecordCount > 0 then
      begin
        nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
              '<DATA>'+
              '<head>'+
              '<Factory>'+Fields[1].AsString+'</Factory>'+
              '<ToUser>'+Fields[2].AsString+'</ToUser>'+
              '<MsgType>2</MsgType>'+
              '</head>'+
              '<Items>'+
                '<Item>'+
                '<BillID>'+Fields[3].AsString+'</BillID>'+
                '<Card>'+Fields[4].AsString+'</Card>'+
                '<Truck>'+Fields[5].AsString+'</Truck>'+
                '<StockNo>'+Fields[6].AsString+'</StockNo>'+
                '<StockName>'+Fields[7].AsString+'</StockName>'+
                '<CusID>'+Fields[8].AsString+'</CusID>'+
                '<CusName>'+Fields[9].AsString+'</CusName>'+
                '<CusAccount>'+Fields[10].AsString+'</CusAccount>'+
                '<MakeDate>'+Fields[11].AsString+'</MakeDate>'+
                '<MakeMan>'+Fields[12].AsString+'</MakeMan>'+
                '<TransID>'+Fields[13].AsString+'</TransID>'+
                '<TransName>'+Fields[14].AsString+'</TransName>'+
                '<Searial>'+Fields[15].AsString+'</Searial>'+
                '<OutFact>'+Fields[16].AsString+'</OutFact>'+
                '<OutMan>'+Fields[17].AsString+'</OutMan>'+
                '</Item>'+
              '</Items>'+
               '<remark/>'+
              '</DATA>';
        {$IFDEF DEBUG}
        WriteLog(nStr);
        {$ENDIF}
        wxservice:=GetReviceWS(true,'',nil);
        nMsg:=wxservice.mainfuncs('send_event_msg',nStr);
        {$IFDEF DEBUG}
        WriteLog(nMsg);
        {$ENDIF}
        FPacker.XMLBuilder.ReadFromString(nMsg);
        with FPacker.XMLBuilder do
        begin
          nhead:=Root.FindNode('head');
          if Assigned(nhead) then
          begin
            errcode:=nhead.NodebyName('errcode').ValueAsString;
            errmsg:=nhead.NodebyName('errmsg').ValueAsString;
            if errcode='0' then
            begin
              nRID:=nRID+'R_ID='+Fields[0].AsString+' or ';
            end;
          end;
        end;
      end;
    end;
    nRID:=Trim(nRID);
    nRID:=Copy(nRID,1,length(nRID)-2);
    nSql:='update %s set L_OutSendWx=''Y'' where %s';
    nSql:=Format(nSql,[sTable_Bill,nRID]);
    gDBConnManager.WorkerExec(FDBConn,nSql);
    Result:=True;
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp: string;
    f,m,nVal,nMVal: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nUpdateVal: Double;
    nBxz:Boolean;
    nAxMoney: Double;
    nAxMsg,nOnLineModel: string;
    nDBZhiKa:TDataSet;
    nHint: string;
    nTriaTrade: string;
    nTriCusID, nCompanyId: string;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '岗位[ %s ]提交了散装合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //袋装不过磅
    end; 

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //更新队列车辆进厂状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的皮重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //保存车辆有效皮重

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //返回榜单号,用于拍照绑定

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //栈台现场
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //已称皮
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;
      {$IFDEF ZXKP}
      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_HYDan', FSampleID),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ELSE}
      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_HYDan', FSampleID),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              //SF('L_InvLocationId', FLocationID),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ENDIF}
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //放灰现场
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      {$IFDEF ZXKP}
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_HYDan', FSampleID),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ELSE}
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser),
              SF('L_HYDan', FSampleID),
              SF('L_EmptyOut', FYSValid),
              SF('L_WorkOrder', FWorkOrder),
              //SF('L_InvLocationId', FLocationID),
              SF('L_CW', FKw)
              ], sTable_Bill, SF('L_ID', FID), False);
      {$ENDIF}
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    nBxz := True;
    nInt := -1;
    nMVal := 0;
    
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的毛重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    with nBills[0] do//散装袋装均需校验资金额
    begin
      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        nOnLineModel:=GetOnLineModel; //获取是否在线模式
        if FSalesType='0' then
        begin
          nBxz:=False;
        end else
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetTriangleTrade,    //获取是否三角贸易
                nBills[0].FZhiKa, '', @nOut) then
          begin
            nData := nOut.FData;
            Exit;
          end;
          nTriaTrade:=nOut.FData;
          if nTriaTrade = sFlag_Yes then FTriaTrade := '1';   // 三角贸易
          WriteLog('贸易类型：'+FTriaTrade);
          if FTriaTrade = '1' then    // 三角贸易
          begin
            if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
            begin
              if not TWorkerBusinessCommander.CallMe(cBC_GetCustNo,    //获取最终客户
                    nBills[0].FZhiKa, '', @nOut) then
              begin
                nData := nOut.FData;
                Exit;
              end;
              nTriCusID:= nOut.FData;
              nCompanyId:= nOut.FExtParam;
              if not TWorkerBusinessCommander.CallMe(cBC_GetAXMaCredLmt, //是否强制信用额度
                      nTriCusID, nCompanyId, @nOut) then
              begin
                nData := nOut.FData;
                Result:= True;
                Exit;
              end;
              if nOut.FData = sFlag_No then
              begin
                nBxz:=False;
              end;
              if nBxz then
              begin
                if not GetRemTriCustomerMoney(nBills[0].FZhiKa,nAxMoney,nAxMsg) then
                begin
                  nData:=nAxMsg;
                  Result:=True;
                  Exit;
                end;
              end;
            end else
            begin
              nData:='离线模式，获取三角贸易客户信息失败';
              FOut.FData:=nData;
              Result:=True;
              Exit;
            end;
          end else
          begin
            if not TWorkerBusinessCommander.CallMe(cBC_CustomerMaCredLmt,
                  nBills[0].FCusID, '', @nOut) then
            begin
              nData := nOut.FData;
              Exit;
            end;
            if nOut.FData= sFlag_No then
            begin
              nBxz:=False;
            end;
            if nBxz then
            begin
              if nOnLineModel=sFlag_Yes then   //在线模式，远程获取客户资金额度
              begin
                if not GetRemCustomerMoney(nBills[0].FZhiKa,nAxMoney,nAxMsg) then
                begin
                  nData:=nAxMsg;
                  Result:=True;
                  Exit;
                end;
              end;
              if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney,  //本地获取客户资金额度
               nBills[0].FZhiKa, '', @nOut) then
              begin
                nData := nOut.FData;
                Result:=True;
                Exit;
              end;
              m := StrToFloat(nOut.FData);
              WriteLog(nBills[0].FID+'本地资金：'+Floattostr(m));
              m := m + Float2Float(FPrice * FValue, cPrecision, False);
              WriteLog(nBills[0].FCusID+'冻结资金：'+Floattostr(Float2Float(FPrice * FValue, cPrecision, False)));
              //客户可用金
            end;
          end;
          if nBxz and (nOnLineModel=sFlag_Yes) then
          begin
            nStr := 'select IsNull(SUM(L_Value*L_Price),''0'') as L_TotalMoney from %s where L_BDAX=''2'' and L_CusID=''%s'' ';
            nStr := Format(nStr,[sTable_Bill, FCusID]);
            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            if RecordCount > 0 then
            begin
              nAxMoney := nAxMoney - Fields[0].AsFloat;
            end;
            WriteLog(nBills[0].FID+'在线资金：'+Floattostr(nAxMoney));
          end;
        end;

        if FType = sFlag_Dai then
        begin
          if nBxz then
          begin
            if nOnLineModel=sFlag_Yes then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - nAxMoney;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, nAxMoney, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
            //if nTriaTrade <> sFlag_Yes then
            if FTriaTrade <> '1' then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - m;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, m, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
          end;
        end else
        begin
          nVal := FValue;
          FValue := nMVal - FPData.FValue;
            //新净重,实际提货量
          if nBxz then
          begin
            if nOnLineModel=sFlag_Yes then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - nAxMoney;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, nAxMoney, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
            //if nTriaTrade <> sFlag_Yes then
            if FTriaTrade <> '1' then
            begin
              f := Float2Float(FPrice * FValue, cPrecision, True) - m;
              //实际所需金额与可用金差额
              if (f > 0) then
              begin
                nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                         '可用金额: %.2f元' + #13#10 +
                         '提货金额: %.2f元' + #13#10 +
                         '需 补 交: %.2f元' + #13#10+#13#10 +
                         '请到财务室办理"补交货款"手续,然后再次称重.';
                nData := Format(nData, [FCusID, FCusName, m, FPrice * FValue, f]);
                nStr := '客户资金余额不足,需补交: %.2f元';
                nStr := Format(nStr, [f]);
                FOut.FData:= nStr;
                Result:=True;
                Exit;
              end;
            end;
          end;

          //if nTriaTrade <> sFlag_Yes then
          if FTriaTrade <> '1' then
          begin
            m := Float2Float(FPrice * FValue, cPrecision, True);
            m := m - Float2Float(FPrice * nVal, cPrecision, True);
            //新增冻结金额
            nDBZhiKa:=LoadZhiKaInfo(nBills[0].FZhiKa,nHint);
            with nDBZhiKa do
            begin
              if FieldByName('C_ContQuota').AsString='1' then
              begin
                nSQL := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney+(%.2f) ' +
                        'Where A_CID=''%s''';
                nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
              end else
              begin
                nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney+(%.2f) ' +
                        'Where A_CID=''%s''';
                nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
              end;
              FListA.Add(nSQL); //更新账户
              WriteLog('['+FID+']Update YKMoney: '+nStr);
            end;
          end;
          
          nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
                  ], sTable_Bill, SF('L_ID', FID), False);
          FListA.Add(nSQL); //更新提货量

          nUpdateVal := FValue-nVal;
          nSQL := 'Update %s Set D_Value=D_Value-(%.2f) ' +
                  'Where D_RECID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKaDtl, nUpdateVal, FRecID]);
          FListA.Add(nSQL); //更新纸卡余量
        end;
      end else
      begin
        nSQL := 'Update %s Set D_Value=D_Value+(%.2f) ' +
                'Where D_RECID=''%s''';
        nSQL := Format(nSQL, [sTable_ZhiKaDtl, FValue, FRecID]);
        FListA.Add(nSQL); //更新纸卡余量

        m := Float2Float(FPrice * FValue, cPrecision, True);
        WriteLog('空车出厂：'+FYSValid);
        nDBZhiKa:=LoadZhiKaInfo(FZhiKa,nHint);

        with nDBZhiKa do
        begin
          if FieldByName('Z_TriangleTrade').AsString <> '1' then
          begin
            if FieldByName('C_ContQuota').AsString='1' then
            begin
              nSQL := 'Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%.2f) Where A_CID=''%s''';
              nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
            end else
            begin
              nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
              nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
            end;
            FListA.Add(nSQL); //更新客户资金(可能不同客户)
            WriteLog('['+FID+']Relese YKMoney: '+nSQL);
          end;
        end;
      end;
    end;
    
    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
        //累计净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //扣减已累计的净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //出厂模式,毛重不生效
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //未称毛重记录

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //出厂模式,不更新状态

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //排除本次称重
      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        nSQL := MakeSQLByStr([SF('L_Value', 0.00, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //未过重交货单列表

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的提货记录的皮重,等于本次的毛重

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的过磅记录的皮重,等于本次的毛重
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
      
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //更新交货单
    end;

    nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //更新磁卡状态

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //交货单列表

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //合卡,但非主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //袋重无效

        i := Trunc(FValue * 1000 / FPerW);
        //袋数

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //扣减合卡副单的装车量
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //合卡主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    //WriteLog('Clear Trucks: '+nSQL);
    FListA.Add(nSQL); //清理装车队列
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    {$IFDEF ZXKP}

    {$ELSE}
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nBills[0].FCard);
    //磅房处理自动出厂
    {$ENDIF}
  end;

  {$IFDEF MicroMsg}
  nStr := '';
  for nIdx:=Low(nBills) to High(nBills) do
    nStr := nStr + nBills[nIdx].FID + ',';
  //xxxxx

  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with FListA do
    begin
      Clear;
      Values['bill'] := nStr;
      Values['company'] := gSysParam.FHintText;
    end;

    gWXPlatFormHelper.WXSendMsg(cWXBus_OutFact, FListA.Text);
  end;
  {$ENDIF}
  {$IFDEF QLS}
  {if (FIn.FExtParam = sFlag_TruckOut) and
    (GetOnLineModel=sFlag_Yes) then
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        try
          if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill,FID,'',@nOut) then
          begin
            WriteLog(FID+'销售磅单上传失败');
          end;
        except
          on e:Exception do
          begin
            WriteLog(FID+'销售磅单上传失败'+e.Message);
          end;
        end;
      end else
      begin
        nSQL := 'Select L_FYAX From %s Where L_ID = ''%s'' ';
        nSQL := Format(nSQL, [sTable_Bill, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if FieldByName('L_FYAX').AsString='1' then
          begin
            try
              if not TWorkerBusinessCommander.CallMe(cBC_SyncEmpOutBillAX,FID,'',@nOut) then
              begin
                WriteLog(FID+'空车出厂提货单上传失败');
              end;
            except

            end;
          end;
        end;
      end;
    end;
  end;}
  {$ENDIF}
  {if FIn.FExtParam = sFlag_TruckOut then
  begin
    if TruckOutSendMsgWx(FListB) then nData:='出厂发送微信成功！';
  end; }
end;
//------------------------------------------------------------------------------
class function TWorkerBusinessOrders.FunctionName: string;
begin
  Result := sBus_BusinessPurchaseOrder;
end;

constructor TWorkerBusinessOrders.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessOrders.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessOrders.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveOrder            : Result := SaveOrder(nData);
   cBC_DeleteOrder          : Result := DeleteOrder(nData);
   cBC_SaveOrderBase        : Result := SaveOrderBase(nData);
   cBC_DeleteOrderBase      : Result := DeleteOrderBase(nData);
   cBC_SaveOrderCard        : Result := SaveOrderCard(nData);
   cBC_LogoffOrderCard      : Result := LogoffOrderCard(nData);
   cBC_ModifyBillTruck      : Result := ChangeOrderTruck(nData);
   cBC_GetPostOrders        : Result := GetPostOrderItems(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;


function TWorkerBusinessOrders.SaveOrderBase(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('B_ID', nOut.FData),
            SF('B_BStatus', FListA.Values['IsValid']),

            SF('B_Project', FListA.Values['Project']),
            SF('B_Area', FListA.Values['Area']),

            SF('B_Value', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_RestValue', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_LimValue', StrToFloat(FListA.Values['LimValue']),sfVal),
            SF('B_WarnValue', StrToFloat(FListA.Values['WarnValue']),sfVal),

            SF('B_SentValue', 0,sfVal),
            SF('B_FreezeValue', 0,sfVal),

            SF('B_ProID', FListA.Values['ProviderID']),
            SF('B_ProName', FListA.Values['ProviderName']),
            SF('B_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('B_SaleID', FListA.Values['SaleID']),
            SF('B_SaleMan', FListA.Values['SaleMan']),
            SF('B_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('B_StockType', sFlag_San),
            SF('B_StockNo', FListA.Values['StockNO']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal),
            SF('B_RecID', FListA.Values['RecID'])
            ], sTable_OrderBase, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := MakeSQLByStr([SF('M_ID', nOut.FData),
            SF('M_BStatus', FListA.Values['IsValid']),

            SF('M_ProID', FListA.Values['ProviderID']),
            SF('M_ProName', FListA.Values['ProviderName']),
            SF('M_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('M_Man', FIn.FBase.FFrom.FUser),
            SF('M_Date', sField_SQLServer_Now, sfVal)
            ], sTable_OrderBaseMain, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm: 
//Desc: 删除采购申请单
function TWorkerBusinessOrders.DeleteOrderBase(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where O_BID=''%s''';
  nStr := Format(nStr, [sTable_Order, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购申请单[ %s ]已使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_OrderBase]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('B_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,B_DelMan,B_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where B_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_OrderBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm: 
//Desc: 获取供应可收货量
function TWorkerBusinessOrders.GetGYOrderValue(var nData: string): Boolean;
var nSQL: string;
    nVal, nSent, nLim, nWarn, nFreeze,nMax: Double;
begin
  Result := False;
  //init

  nSQL := 'Select B_Value,B_SentValue,B_RestValue, ' +
          'B_LimValue,B_WarnValue,B_FreezeValue ' +
          'From $OrderBase b1 inner join $Order o1 on b1.B_ID=o1.O_BID ' +
          'Where O_ID=''$ID''';
  nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
          MI('$Order', sTable_Order), MI('$ID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount<1 then
    begin
      nData := '采购申请单[%s]信息已丢失';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nVal    := FieldByName('B_Value').AsFloat;
    nSent   := FieldByName('B_SentValue').AsFloat;
    nLim    := FieldByName('B_LimValue').AsFloat;
    nWarn   := FieldByName('B_WarnValue').AsFloat;
    nFreeze := FieldByName('B_FreezeValue').AsFloat;

    nMax := nVal - nSent - nFreeze;
  end;  

  with FListB do
  begin
    Clear;

    if nVal>0 then
         Values['NOLimite'] := sFlag_No
    else Values['NOLimite'] := sFlag_Yes;

    Values['MaxValue']    := FloatToStr(nMax);
    Values['LimValue']    := FloatToStr(nLim);
    Values['WarnValue']   := FloatToStr(nWarn);
    Values['FreezeValue'] := FloatToStr(nFreeze);
  end;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Order;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('O_ID', nOut.FData),

            SF('O_CType', FListA.Values['CardType']),
            SF('O_Project', FListA.Values['Project']),
            SF('O_Area', FListA.Values['Area']),

            SF('O_BID', FListA.Values['SQID']),
            SF('O_Value', nVal,sfVal),

            SF('O_ProID', FListA.Values['ProviderID']),
            SF('O_ProName', FListA.Values['ProviderName']),
            SF('O_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('O_SaleID', FListA.Values['SaleID']),
            SF('O_SaleMan', FListA.Values['SaleMan']),
            SF('O_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('O_Type', sFlag_San),
            SF('O_StockNo', FListA.Values['StockNO']),
            SF('O_StockName', FListA.Values['StockName']),

            SF('O_Truck', FListA.Values['Truck']),
            SF('O_Man', FIn.FBase.FFrom.FUser),
            SF('O_Date', sField_SQLServer_Now, sfVal),
            SF('O_BRecID', FListA.Values['RecID']),
            SF('O_IfNeiDao', FListA.Values['NeiDao'])
            ], sTable_Order, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if FListA.Values['CardType'] = sFlag_OrderCardL then
    begin
      nStr := 'Update %s Set B_FreezeValue=B_FreezeValue+%.2f ' +
              'Where B_ID = ''%s'' and B_Value>0';
      nStr := Format(nStr, [sTable_OrderBase, nVal,FListA.Values['SQID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where ((D_Status<>''%s'') and (D_Status<>''%s'')) and D_OID=''%s''';
  nStr := Format(nStr, [sTable_OrderDtl, sFlag_TruckNone, sFlag_TruckIn, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购单[ %s ]已使用，禁止删除。';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Order]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('O_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,O_DelMan,O_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where O_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Order), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 采购订单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为采购单绑定磁卡
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //采购单列表

  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('采购订单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '采购单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('O_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select O_ID,O_Truck From %s Where O_Card In (''%s'')';
  nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]正在使用该卡,无法并单.';
    nData := Format(nData, [FieldByName('O_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set O_Card=''%s'' Where O_ID In (%s)';
      nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set D_Card=''%s'' Where D_OID In(%s) and D_OutFact Is NULL';
      nSQL := Format(nSQL, [sTable_OrderDtl, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Card=Null Where O_Card=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set D_Card=Null Where D_Card=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessOrders.ChangeOrderTruck(var nData: string): Boolean;
var nStr: string;
begin
  //Result := False;
  //Init

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Truck=''%s'' Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_Order]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足采购单编码规则,则视为采购单号
  end;

  if not nIsOrder then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo,' +
          'O_StockName,O_Truck,O_Value,O_BRecID,O_IfNeiDao ' +
          'From $OO oo ';
  //xxxxx

  if nIsOrder then
       nStr := nStr + 'Where O_ID=''$CD'''
  else nStr := nStr + 'Where O_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsOrder then
           nData := '采购单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]无订单';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;

      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
      Values['O_BRecID']     := FieldByName('O_BRecID').AsString;

      Values['NeiDao']       := FieldByName('O_IfNeiDao').AsString;
    end;
  end;

  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan,' +
          'P_MStation,P_MValue,P_MDate,P_MMan ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
                            MI('$PD', sTable_PoundLog),
                            MI('$OID', FListA.Values['O_ID'])]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      SetLength(nBills, 1);

      with nBills[0], FListA do
      begin
        FZhiKa      := Values['O_ID'];
        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;

        FRecID      := Values['O_BRecID'];
        FNeiDao     := Values['NeiDao'];
        FSelected   := True;
      end;  
    end else
    begin
      SetLength(nBills, RecordCount);

      nIdx := 0;

      First; 
      while not Eof do
      with nBills[nIdx], FListA do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;
        FPoundID    := FieldByName('D_PID').AsString;

        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := FieldByName('D_Status').AsString;
        FNextStatus := FieldByName('D_NextStatus').AsString;

        if (FStatus = '') or (FStatus = sFlag_BillNew) then
        begin
          FStatus     := sFlag_TruckNone;
          FNextStatus := sFlag_TruckNone;
        end;

        with FPData do
        begin
          FStation  := FieldByName('P_PStation').AsString;
          FValue    := FieldByName('P_PValue').AsFloat;
          FDate     := FieldByName('P_PDate').AsDateTime;
          FOperator := FieldByName('P_PMan').AsString;
        end;

        with FMData do
        begin
          FStation  := FieldByName('P_MStation').AsString;
          FValue    := FieldByName('P_MValue').AsFloat;
          FDate     := FieldByName('P_MDate').AsDateTime;
          FOperator := FieldByName('P_MMan').AsString;
        end;

        FKZValue  := FieldByName('D_KZValue').AsFloat;
        FMemo     := FieldByName('D_Memo').AsString;
        FYSValid  := FieldByName('D_YSResult').AsString;

        FRecID      := Values['O_BRecID'];
        FNeiDao     := Values['NeiDao'];
        FSelected := True;

        Inc(nIdx);
        Next;
      end;
    end;    
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//获取在线模式
function TWorkerBusinessOrders.GetOnLineModel: string;
var
  nStr: string;
begin
  Result:=sFlag_Yes;
  nStr := 'select D_Value from %s where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_OnLineModel]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result:=Fields[0].AsString;
  end;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal, nNet, nAKVal: Double;
    nIdx: Integer;
    nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
            SF('D_ID', nOut.FData),
            SF('D_Card', FCard),
            SF('D_OID', FZhiKa),
            SF('D_Truck', FTruck),
            SF('D_ProID', FCusID),
            SF('D_ProName', FCusName),
            SF('D_ProPY', GetPinYinOfStr(FCusName)),

            SF('D_Type', FType),
            SF('D_StockNo', FStockNo),
            SF('D_StockName', FStockName),

            SF('D_Status', sFlag_TruckIn),
            SF('D_NextStatus', sFlag_TruckBFP),
            SF('D_InMan', FIn.FBase.FFrom.FUser),
            SF('D_InTime', sField_SQLServer_Now, sfVal),
            SF('D_RecID', FRecID)
            ], sTable_OrderDtl, '', True);
      FListA.Add(nSQL);
    end;  
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      {if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM; }
      nStr := 'Select D_Value From %s Where ((D_Name=''%s'') or (D_Name=''%s'')) and D_Value=''%s'' ';
      nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock, sFlag_NFPurch, FStockNo]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        FNextStatus := sFlag_TruckBFM;
      end;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
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
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //验收现场
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FID);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //验收扣杂
       FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_Memo', FMemo)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nPound[0] do
    begin
      nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
              'Where D_Stock=''%s'' And D_Valid=''%s''';
      nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);
      //WriteLog(nStr);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          if FieldByName('D_CusID').AsString = FCusID then
            Break;
          //客户+物料参数优先

          Next;
        end;

        if Eof then First;
        //使用第一条规则

        if FMData.FValue > FPData.FValue then
             nNet := FMData.FValue - FPData.FValue
        else nNet := FPData.FValue - FMData.FValue;

        nVal := 0;
        //待扣减量
        nStr := FieldByName('D_Type').AsString;

        if nStr = sFlag_DeductFix then
          nVal := FieldByName('D_Value').AsFloat;
        //定值扣减

        if nStr = sFlag_DeductPer then
        begin
          nVal := FieldByName('D_Value').AsFloat;
          nVal := nNet * nVal;
          //WriteLog('扣减计算：'+FloatToStr(nVal));
        end; //比例扣减

        if (nVal > 0) and (nNet > nVal) then
        begin
          nVal := Float2Float(nVal, cPrecision, False);
          //将暗扣量扣减为2位小数;
          nAKVal := nVal;
          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;
        end;
      end;
      
      nStr := SF('P_Order', FID);
      //where

      nVal := FMData.FValue - FPData.FValue -FKZValue;
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
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_AKValue', nAKVal, sfVal),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;

      //if FYSValid <> sFlag_NO then  //验收成功，调整已收货量
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val, ' +
                'B_RestValue=B_Value-B_SentValue-$Val '+
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', FZhiKa),
                MI('$Val', FloatToStr(nVal))]);
        FListA.Add(nSQL);
        //调整已收货；
      end;

      nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$KDVal ' +
              'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'''+
              ' And O_CType= ''L'') and B_Value>0';
      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
              MI('$Order', sTable_Order),MI('$ID', FZhiKa),
              MI('$KDVal', FloatToStr(FValue))]);
      FListA.Add(nSQL);
      //调整冻结量
      
      nSQL := 'Select P_ID From %s Where P_Order=''%s'' ';
      nSQL := Format(nSQL, [sTable_PoundLog, FID]);
      //未称毛重记录
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        FOut.FData := Fields[0].AsString;
      end;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
              SF('D_NextStatus', ''),
              SF('D_Card', ''),
              SF('D_OutFact', sField_SQLServer_Now, sfVal),
              SF('D_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL); //更新采购单
    end;

    nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nPound[0].FZhiKa]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('O_Card').AsString;
      if FieldByName('O_CType').AsString = sFlag_OrderCardL then
      if not CallMe(cBC_LogOffOrderCard, nStr, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
    end;
    //如果是临时卡片，则注销卡片
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    if Assigned(gHardShareData) then
    begin
      {$IFDEF GGJC}
      gHardShareData('TruckOut:' + nPound[0].FCard);
        //磅房处理自动出厂
        WriteLog('磅房处理自动出厂');
      {$ELSE}
      nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
      nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        gHardShareData('TruckOut:' + nPound[0].FCard);
        //磅房处理自动出厂
        WriteLog('磅房处理自动出厂');
      end;
      {$ENDIF}
    end;
  end;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessOrders.CallMe(const nCmd: Integer;
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

//------------------------------------------------------------------------------
//by lih 2016-05-26
class function TWorkerBusinessRegWeiXin.FunctionName: string;
begin
  Result := sBus_BusinessRegWeiXin;
end;

constructor TWorkerBusinessRegWeiXin.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessRegWeiXin.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessRegWeiXin.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessRegWeiXin.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2016-05-26
//Parm: 输入数据
//lih: 执行nData业务指令
function TWorkerBusinessRegWeiXin.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
    cBC_RegWeiXin: Result := GetCustomerInfo(nData);
    cBC_BindUserWeiXin: Result := GetBindfunc(nData);
  else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2016-05-26
//Parm:
//lih: 获取微信公众号客户信息并保存到DB
function TWorkerBusinessRegWeiXin.GetCustomerInfo(var nData: string): Boolean;
var
  sSQL,nStr:string;
  nTime:Int64;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead,nItems,nItem:TXmlNode;
  errcode,errmsg:string;
  Factory,phone,Appid,Bindcustomerid,Namepinyin,Email,Openid,Binddate:string;
begin
  Result:=False;
  nTime:=GetTickCount;
  sSQL:='select D_Value from Sys_Dict where D_Name=''FactoryID''';
  with gDBConnManager.WorkerQuery(FDBConn,sSQL) do
  begin
    if RecordCount<1 then
    begin
      nData:=PackerDecodeStr(FIn.FData)+#13#10+'[缺少工厂序列号]'+#13#10+'获取微信公众号客户信息失败！';
      Exit;
    end;
    nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
          '<DATA>'+
          '<head>'+
          '<Factory>'+Fields[0].AsString+'</Factory>'+
          '<Phone>'+PackerDecodeStr(FIn.FData)+'</Phone>'+
          '</head></DATA>';
    {$IFDEF DEBUG}
    WriteLog(nStr);
    {$ENDIF}
  end;
  wxservice:=GetReviceWS(true,'',nil);
  nMsg:=wxservice.mainfuncs('getCustomerInfo',nStr);
  {$IFDEF DEBUG}
  WriteLog(nMsg);
  {$ENDIF}
  FPacker.XMLBuilder.ReadFromString(nMsg);
  with FPacker.XMLBuilder do
  begin
    nhead:=Root.FindNode('head');
    nItems:=Root.FindNode('Items');
    if not Assigned(nhead) then
    begin
      nData:=PackerDecodeStr(FIn.FData)+'获取微信公众号客户信息失败！';
      Exit;
    end;

    errcode:=nhead.NodebyName('errcode').ValueAsString;
    errmsg:=nhead.NodebyName('errmsg').ValueAsString;

    nItem:=nItems.FindNode('Item');
    Factory:=nItem.NodebyName('Factory').ValueAsString;
    phone:=nItem.NodebyName('phone').ValueAsString;
    Appid:=nItem.NodebyName('Appid').ValueAsString;
    Bindcustomerid:=nItem.NodebyName('Bindcustomerid').ValueAsString;
    Namepinyin:=nItem.NodebyName('Namepinyin').ValueAsString;
    Email:=nItem.NodebyName('Email').ValueAsString;
    Openid:=nItem.NodebyName('Openid').ValueAsString;
    Binddate:=nItem.NodebyName('Binddate').ValueAsString;
  end;
  sSQL:='select * from W_CustomerInfo '+
        'where ErrCode=''0'' and Factory='''+Factory+
        ''' and Phone='''+phone+
        ''' and BindCustomerId='''+Bindcustomerid+
        ''' and BindDate='''+Binddate+'''';
  {$IFDEF DEBUG}
  WriteLog(sSQL);
  {$ENDIF}
  with gDBConnManager.WorkerQuery(FDBConn,sSQL) do
  begin
    if RecordCount>1 then
    begin
      FOut.FData:=PackerDecodeStr(FIn.FData)+#13#10+'['+Binddate+']'+#13#10+'已获取微信公众号客户信息！';
      nData:=FOut.FData;
      Result:=True;
      Exit;
    end;
  end;
  sSQL:='insert into W_CustomerInfo '+
        '(ErrCode,ErrMsg,Factory,Phone,AppId,BindCustomerId,NamePinYin,Email,OpenId,BindDate) '+
        'values ('''+
        errcode+''','''+errmsg+''','''+Factory+''','''+phone+''','''+Appid+''','''+Bindcustomerid+''','''+
        Namepinyin+''','''+Email+''','''+Openid+''','''+Binddate+''')';
  gDBConnManager.WorkerExec(FDBConn,sSQL);
  FOut.FData:=PackerDecodeStr(FIn.FData)+#13#10+'获取微信公众号客户信息成功！';
  nData:=FOut.FData;
  Result:=True;
end;

//Date: 2016-05-30
//Parm:
//lih: 去工厂绑定用户并保存到DB
function TWorkerBusinessRegWeiXin.GetBindfunc(var nData: string):Boolean;
var
  sSQL,nStr:string;
  nTime:Int64;
  wxservice:ReviceWS;
  nMsg:WideString;
  nhead:TXmlNode;
  Phone,Factory,ToUser,IsBind,errcode,errmsg:string;
  nBindStatus:string;
begin
  Result:=False;
  nTime:=GetTickCount;
  FListA.Text:=PackerDecodeStr(FIn.FData);
  Phone:=FListA.Values['Phone'];
  IsBind:=FListA.Values['IsBind'];
  if IsBind='0' then nBindStatus:='解绑' else nBindStatus:='绑定';
  sSQL:='select top 1 Factory,BindCustomerId from W_CustomerInfo a,Sys_Dict b '+
        'where a.Factory=b.D_Value and b.D_Name=''FactoryID'' and a.Phone='''+Phone+
        ''' order by ID desc';
  with gDBConnManager.WorkerQuery(FDBConn,sSQL) do
  begin
    if RecordCount<1 then
    begin
      nData:=Phone+#13#10+'[缺少工厂序列号或绑定用户ID]'+#13#10+'用户'+nBindStatus+'失败！';
      Exit;
    end;
    Factory:=Fields[0].AsString;
    ToUser:=Fields[1].AsString;
    nStr:='<?xml version="1.0" encoding="UTF-8"?>'+
          '<DATA>'+
          '<head>'+
          '<Factory>'+Factory+'</Factory>'+
          '<ToUser>'+ToUser+'</ToUser>'+
          '<IsBind>'+IsBind+'</IsBind>'+
          '</head>'+
          '</DATA>';
    {$IFDEF DEBUG}
    WriteLog(nStr);
    {$ENDIF}
  end;
  wxservice:=GetReviceWS(true,'',nil);
  nMsg:=wxservice.mainfuncs('get_Bindfunc',nStr);
  {$IFDEF DEBUG}
  WriteLog(nMsg);
  {$ENDIF}
  FPacker.XMLBuilder.ReadFromString(nMsg);
  with FPacker.XMLBuilder do
  begin
    nhead:=Root.FindNode('head');
    if not Assigned(nhead) then
    begin
      nData:=Phone+'用户'+nBindStatus+'失败！';
      Exit;
    end;

    errcode:=nhead.NodebyName('errcode').ValueAsString;
    errmsg:=nhead.NodebyName('errmsg').ValueAsString;
  end;

  sSQL:='update S_Customer set C_Factory='''+Factory+''',C_ToUser='''+ToUser+
        ''',C_IsBind='''+IsBind+''' where C_Phone='''+Phone+'''';
  gDBConnManager.WorkerExec(FDBConn,sSQL);
  sSQL:='insert into W_BindInfo (Phone,Factory,ToUser,IsBind,ErrCode,ErrMsg,BindDate) '+
        'values ('''+Phone+''','''+Factory+''','''+ToUser+''','''+IsBind+''','''
        +errcode+''','''+errmsg+''','''+formatdatetime('yyyy-mm-dd hh:mm:ss',Now)+''')';
  gDBConnManager.WorkerExec(FDBConn,sSQL);
  FOut.FData:=Phone+#13#10+'用户'+nBindStatus+'成功！';
  nData:=FOut.FData;
  Result:=True;
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessRegWeiXin, sPlug_ModuleBus);  //by lih 2016-05-26
end.
