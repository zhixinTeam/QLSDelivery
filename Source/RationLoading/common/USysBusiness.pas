{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 系统业务处理
*******************************************************************************}
unit USysBusiness;

interface
{$I Link.inc}
uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, UMgrCamera, UBase64, USysConst,
  USysDB, USysLoger;

type
  TLadingStockItem = record
    FID: string;         //编号
    FType: string;       //类型
    FName: string;       //名称
    FParam: string;      //扩展
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //系统可用的品种列表

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //编号
    FName     : string;      //名称
    FStock    : string;      //品名
    FWeight   : Integer;     //袋重
    FValid    : Boolean;     //是否有效
    FPrinterOK: Boolean;     //喷码机
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //车牌号
    FLine     : string;      //通道
    FBill     : string;      //提货单
    FValue    : Double;      //提货量
    FDai      : Integer;     //袋数
    FTotal    : Integer;     //总数
    FInFact   : Boolean;     //是否进厂
    FIsRun    : Boolean;     //是否运行    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  PSalePlanItem = ^TSalePlanItem;
  TSalePlanItem = record
    FOrderNo: string;        //订单号     
    FInterID: string;        //主表编号
    FEntryID: string;        //附表编号
    FStockID: string;        //物料编号
    FStockName: string;      //物料名称

    FTruck: string;          //车牌号码
    FValue: Double;          //开单量
    FSelected: Boolean;      //状态
  end;
  TSalePlanItems = array of TSalePlanItem;
  
//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//调整提示内容
function WorkPCHasPopedom: Boolean;
//验证主机是否已授权
function GetSysValidDate: Integer;
//获取系统有效期
function GetTruckEmptyValue(nTruck: string): Double;
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean = True): string;
//获取串行编号
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//可用品种列表
function GetCardUsed(const nCard: string): string;
//获取卡片类型

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//读取系统字典项
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取业务员列表
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取客户列表
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
//载入客户信息

function IsZhiKaNeedVerify: Boolean;
//纸卡是否需要审核
function IsPrintZK: Boolean;
//是否打印纸卡
function DeleteZhiKa(const nZID: string): Boolean;
//删除指定纸卡
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
//载入纸卡
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
//纸卡可用金
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
 const nCredit: PDouble = nil): Double;
//客户可用金额

function SyncRemoteCustomer: Boolean;
//同步远程用户
function SyncRemoteSaleMan: Boolean;
//同步远程业务员
function SyncRemoteProviders: Boolean;
//同步远程用户
function SyncRemoteMeterails: Boolean;
//同步远程业务员
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
//存临时客户
function IsAutoPayCredit: Boolean;
//回款时冲信用
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nCredit: Boolean = True): Boolean;
//保存回款记录
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
//保存信用记录
function IsCustomerCreditValid(const nCusID: string): Boolean;
//客户信用是否有效

function IsStockValid(const nStocks: string): Boolean;
//品种是否可以发货
function SaveBill(const nBillData: string): string;
//保存交货单
function DeleteBill(const nBill: string): Boolean;
//删除交货单
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//更改提货车辆
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//交货单调拨
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//为交货单办理磁卡
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
//办理厂内零售磁卡
function LoadSalePlan(const nCusID: string;var nPlans: TSalePlanItems): Boolean;
//读取销售计划
function SaveBillCard(const nBill, nCard: string): Boolean;
//保存交货单磁卡
function LogoutBillCard(const nCard: string): Boolean;
//注销指定磁卡
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//获取指定岗位的交货单列表
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//载入单据信息到列表
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//保存指定岗位的交货单

function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//获取指定车辆的已称皮重信息
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems): Boolean;
//保存车辆过磅记录
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
//读取指定磅站读头上的卡号
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//抓拍指定通道

procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string = '');
//获取误差范围
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom: string = sFlag_DepBangFang ;
 const nSolution: string = sFlag_Solution_YN;
 const nDepartmen: string = sFlag_DepDaTing;
 const nReset: Boolean = False; const nMemo: string = ''): Boolean;
//添加待处理事项记录
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string = sFlag_Yes): Boolean;
//检查事件是否通过处理

function IsTunnelOK(const nTunnel: string): Boolean;
//查询通道光栅是否正常
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//控制通道红绿灯开合
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
//经中间件播发语音

function SaveOrderBase(const nOrderData: string): string;
//保存采购申请单
function DeleteOrderBase(const nOrder: string): Boolean;
//删除采购申请单
function SaveOrder(const nOrderData: string): string;
//保存采购单
function DeleteOrder(const nOrder: string): Boolean;
//删除采购单
//function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
////更改提货车辆
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
//为采购单办理磁卡
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//保存采购单磁卡
function LogoutOrderCard(const nCard: string): Boolean;
//注销指定磁卡
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
//修改车牌号

function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//获取指定岗位的采购单列表
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//保存指定岗位的采购单
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//读取车辆队列
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//启停喷码机
function ChangeDispatchMode(const nMode: Byte): Boolean;
//切换调度模式
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//读卡器打开道闸

function GetHYMaxValue: Double;
function GetHYValueByStockNo(const nNo: string): Double;
//获取化验单已开量

function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
//周期是否有效
function IsWeekHasEnable(const nWeek: string): Boolean;
//周期是否启用
function IsNextWeekEnable(const nWeek: string): Boolean;
//下一周期是否启用
function IsPreWeekOver(const nWeek: string): Integer;
//上一周期是否结束
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
//保存用户补偿金

//------------------------------------------------------------------------------
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
//打印合同
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
//打印纸卡
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
//打印收据
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//打印提货单
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean): Boolean;
//打印采购单
function PrintRCOrderReport(const nID: string;  const nAsk: Boolean): Boolean;
//打印采购单
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
//打印榜单
function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
//化验单,合格证
function PrintBillFYDReport(const nBill: string;  const nAsk: Boolean): Boolean;
function PrintBillLoadReport(nBill: string; const nAsk: Boolean): Boolean;
//打印发运单，过路费

function GetTruckLastTime(const nTruck: string): Integer;
//最后一次过磅时间
function IsStrictSanValue: Boolean;
//判断是否严格执行散装禁止超发

function GetFQValueByStockNo(const nStock: string): Double;
//获取封签号已发量
function VerifyFQSumValue: Boolean;
//是否校验封签号

//获取客户注册信息
function getCustomerInfo(const nXmlStr: string): string;

//客户与微信账号绑定
function get_Bindfunc(const nXmlStr: string): string;

//发送消息
function send_event_msg(const nXmlStr: string): string;

//新增商城用户
function edit_shopclients(const nXmlStr: string): string;

//添加商品
function edit_shopgoods(const nXmlStr: string): string;

//获取订单信息
function get_shoporders(const nXmlStr: string): string;

//更新订单状态
function complete_shoporders(const nXmlStr: string): string;
implementation

//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//------------------------------------------------------------------------------
//Desc: 调整nHint为易读的格式
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '※.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Desc: 验证主机是否已授权接入系统
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('该功能需要更高权限,请向管理员申请.', sHint);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 车辆有效皮重
function GetTruckEmptyValue(nTruck: string): Double;
var nStr: string;
begin
  Result := 0;
  //init

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyTruckP]);
  with FDM.QueryTemp(nStr) do
  if Recordcount > 0 then
   nStr := Fields[0].AsString;

  if nStr <> sFlag_Yes then Exit;
  //不校验皮重

  nStr := 'Select T_PValue From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的业务命令对象
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessPurchaseOrder(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessPurchaseOrder);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-01
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-04
//Parm: 分组;对象;使用日期编码模式
//Desc: 依据nGroup.nObject生成串行编号
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Desc: 获取系统有效期
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

//Desc: 获取当前系统可用的水泥品种列表
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//------------------------------------------------------------------------------
//Date: 2014-06-19
//Parm: 记录标识;车牌号;图片文件
//Desc: 将nFile存入数据库
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 构建图片路径
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2014-06-19
//Parm: 通道;列表
//Desc: 抓拍nTunnel的图像
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  nLogin := -1;
  gCameraNetSDKMgr.NET_DVR_SetDevType(nTunnel.FCamera.FType);
  //xxxxx

  gCameraNetSDKMgr.NET_DVR_Init;
  //xxxxx

  try
    for nIdx:=1 to cRetry do
    begin
      nLogin := gCameraNetSDKMgr.NET_DVR_Login(nTunnel.FCamera.FHost,
                   nTunnel.FCamera.FPort,
                   nTunnel.FCamera.FUser,
                   nTunnel.FCamera.FPwd, nInfo);
      //to login

      nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        gCameraNetSDKMgr.NET_DVR_CaptureJPEGPicture(nLogin,
                                   nTunnel.FCameraTunnels[nIdx],
                                   nPic, nStr);
        //capture pic

        nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;

        if nErr = 0 then
        begin
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := '抓拍图像[ %s.%d ]失败,错误码: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
     gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
    gCameraNetSDKMgr.NET_DVR_Cleanup();
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-07-09
//Parm: 包装正负误差;票重;磅站号
//Desc: 计算nVal的误差范围
procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string);
var nStr: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  if nVal <= 0 then Exit;

  nStr := 'Select * From %s Where P_Start<=%.2f and P_End>%.2f';
  nStr := Format(nStr, [sTable_PoundDaiWC, nVal, nVal]);

  if Length(nStation) > 0 then
    nStr := nStr + ' And P_Station=''' + nStation + '''';
  //xxxxx

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then 
    begin
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
      //按比例计算误差
    end else
    begin     
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
      //按固定值计算误差
    end;
  end;
end;

//Date: 2017-07-09
//Parm: 参数描述
//Desc: 添加异常事件处理
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('请选择处理方案.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);
  
  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '事件记录:[ %s ]已存在';
    WriteLog(Format(nStr, [nEID]));

    if not nReset then Exit;
    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          SF('E_Result', 'Null', sfVal),
          
          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx

  FDM.ExecuteSQL(nStr);
  Result := True;
end;

//Date: 2017-07-09
//Parm: 事件ID;预期结果;错误返回
//Desc: 判断事件是否处理
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select E_Result, E_Event From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      nHint := FieldByName('E_Event').AsString;
      Exit;
    end;

    if nStr <> nWant then
    begin
      nHint := '请联系管理员，做换票处理';
      Exit;
    end;

    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-07-03
//Parm: 通道号
//Desc: 查询nTunnel的光栅状态是否正常
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

//Date: 2016-01-06
//Parm: 文本;语音卡;内容
//Desc: 用nCard播发nContent模式的nText文本.
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Card=' + nCard + #13#10 +
          'Content=' + nContent + #13#10 + 'Truck=' + nText;
  //xxxxxx

  Result := CallBusinessHardware(cBC_PlayVoice, nStr, '', @nOut);
  if not Result then
    WriteLog(nOut.FBase.FErrDesc);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2010-4-13
//Parm: 字典项;列表
//Desc: 从SysDict中读取nItem项的内容,存入nList中
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

//Desc: 读取业务员列表到nList中,包含附加数据
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
          'Where IsNull(S_InValid, '''')<>''%s'' %s Order By S_PY';
  nStr := Format(nStr, [sTable_Salesman, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['S_ID']));
  
  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 读取客户列表到nList中,包含附加数据
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'C_ID=Select C_ID,C_Name From %s ' +
          'Where IsNull(C_XuNi, '''')<>''%s'' %s Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.');

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 载入nCID客户的信息到nList中,并返回数据集
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
var nStr: string;
begin
  nStr := 'Select cus.*,S_Name as C_SaleName From $Cus cus ' +
          ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ' +
          'Where C_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer), MI('$ID', nCID),
          MI('$SM', sTable_Salesman)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with nList.Items,Result do
  begin
    Add('客户编号:' + nList.Delimiter + FieldByName('C_ID').AsString);
    Add('客户名称:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('企业法人:' + nList.Delimiter + FieldByName('C_FaRen').AsString + ' ');
    Add('联系方式:' + nList.Delimiter + FieldByName('C_Phone').AsString + ' ');
    Add('所属业务员:' + nList.Delimiter + FieldByName('C_SaleName').AsString);
  end else
  begin
    Result := nil;
    nHint := '客户信息已丢失';
  end;
end;

//Desc: 保存nSaleMan名下的nName为临时客户,返回客户号
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
var nID: Integer;
    nStr: string;
    nBool: Boolean;
begin
  nStr := 'Select C_ID From %s ' +
          'Where C_XuNi=''%s'' And C_SaleMan=''%s'' And C_Name=''%s''';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nSaleMan, nName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    Exit;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into %s(C_Name,C_PY,C_SaleMan,C_XuNi) ' +
            'Values(''%s'',''%s'',''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Customer, nName, GetPinYinOfStr(nName),
            nSaleMan, sFlag_Yes]);
    FDM.ExecuteSQL(nStr);

    nID := FDM.GetFieldMax(sTable_Customer, 'R_ID');
    Result := FDM.GetSerialID2('KH', sTable_Customer, 'R_ID', 'C_ID', nID);

    nStr := 'Update %s Set C_ID=''%s'' Where R_ID=%d';
    nStr := Format(nStr, [sTable_Customer, Result, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(A_CID,A_Date) Values(''%s'', %s)';
    nStr := Format(nStr, [sTable_CusAccount, Result, FDM.SQLServerNow]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := '';
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 汇款时冲信用额度
function IsAutoPayCredit: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PayCredit)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 保存nCusID的一次回款记录
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nCredit: Boolean): Boolean;
var nStr: string;
    nBool: Boolean;
    nVal,nLimit: Double;
begin
  Result := False;
  nVal := Float2Float(nMoney, cPrecision, False);
  //adjust float value

  {$IFNDEF NoCheckOnPayment}
  if nVal < 0 then
  begin
    nLimit := GetCustomerValidMoney(nCusID, False);
    //get money value
    
    if (nLimit <= 0) or (nLimit < -nVal) then
    begin
      nStr := '客户: %s ' + #13#10#13#10 +
              '当前余额为[ %.2f ]元,无法支出[ %.2f ]元.';
      nStr := Format(nStr, [nCusName, nLimit, -nVal]);
      
      ShowDlg(nStr, sHint);
      Exit;
    end;
  end;
  {$ENDIF}

  nLimit := 0;
  //no limit

  if nCredit and (nVal > 0) and IsAutoPayCredit then
  begin
    nStr := 'Select A_CreditLimit From %s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nCusID]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) and (Fields[0].AsFloat > 0) then
    begin
      if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
           nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False)
      else nLimit := nVal;

      nStr := '客户[ %s ]当前信用额度为[ %.2f ]元,是否冲减?' +
              #32#32#13#10#13#10 + '点击"是"将降低[ %.2f ]元的额度.';
      nStr := Format(nStr, [nCusName, Fields[0].AsFloat, nLimit]);

      if not QueryDlg(nStr, sAsk) then
        nLimit := 0;
      //xxxxx
    end;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_InMoney=A_InMoney+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,' +
            'M_Type,M_Payment,M_Money,M_Date,M_Man,M_Memo) ' +
            'Values(''%s'',''%s'',''%s'',''%s'',''%s'',%.2f,%s,''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName, nType,
            nPayment, nVal, FDM.SQLServerNow, gSysParam.FUserID, nMemo]);
    FDM.ExecuteSQL(nStr);

    if (nLimit > 0) and (
       not SaveCustomerCredit(nCusID, '回款时冲减', -nLimit, Now)) then
    begin
      nStr := '发生未知错误,导致冲减客户[ %s ]信用操作失败.' + #13#10 +
              '请手动调整该客户信用额度.';
      nStr := Format(nStr, [nCusName]);
      ShowDlg(nStr, sHint);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 保存nCusID的一次授信记录
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
var nStr: string;
    nVal: Double;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nVal := Float2Float(nCredit, cPrecision, False);
    //adjust float value

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_CreditVerify]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
         nStr := Fields[0].AsString
    else nStr := sFlag_No; 

    if nStr = sFlag_Yes then //需审核
    begin
      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', FDM.SQLServerNow, sfVal),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Memo',nMemo)
              ], sTable_CusCredit, '', True);
      FDM.ExecuteSQL(nStr);
    end else
    begin
      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', FDM.SQLServerNow, sfVal),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Verify', sFlag_Yes),
              SF('C_VerMan', gSysParam.FUserID),
              SF('C_VerDate', FDM.SQLServerNow, sfVal),
              SF('C_Memo',nMemo)
              ], sTable_CusCredit, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f ' +
              'Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
      FDM.ExecuteSQL(nStr);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Date: 2014-09-14
//Parm: 客户编号
//Desc: 验证nCusID是否有足够的钱,或信用没有过期
function IsCustomerCreditValid(const nCusID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_CustomerHasMoney, nCusID, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

//Date: 2014-10-13
//Desc: 同步业务员到DL系统
function SyncRemoteSaleMan: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncSaleMan, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: 同步用户到DL系统
function SyncRemoteCustomer: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncCustomer, '', '', @nOut);
end;

//Desc: 同步供应商到DL系统
function SyncRemoteProviders: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncProvider, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: 同步原材料到DL系统
function SyncRemoteMeterails: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncMaterails, '', '', @nOut);
end;

//Date: 2014-09-25
//Parm: 车牌号
//Desc: 获取nTruck的称皮记录
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: 称重数据
//Desc: 保存nData称重数据
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  nList := TStringList.Create;
  try
    CapturePicture(nTunnel, nList);
    //capture file

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2014-10-02
//Parm: 通道号
//Desc: 读取nTunnel读头上的卡号
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //卡号

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, '', @nOut) then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: 通道;车辆
//Desc: 读取车辆队列数据
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-10-01
//Parm: 通道号;启停标识
//Desc: 启停nTunnel通道的喷码机
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2014-10-07
//Parm: 调度模式
//Desc: 切换系统调度模式为nMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 纸卡是否需要审核
function IsZhiKaNeedVerify: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_ZhiKaVerify)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 是否打印纸卡
function IsPrintZK: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PrintZK)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 删除编号为nZID的纸卡
function DeleteZhiKa(const nZID: string): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Delete From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nZID]);
    Result := FDM.ExecuteSQL(nStr) > 0;

    nStr := 'Delete From %s Where D_ZID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set M_ZID=M_ZID+''_d'' Where M_ZID=''%s''';
    nStr := Format(nStr, [sTable_InOutMoney, nZID]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 载入nZID的信息到nList中,并返回查询数据集
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
var nStr: string;
begin
  nStr := 'Select zk.*,sm.S_Name,cus.C_Name From $ZK zk ' +
          ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), MI('$SM', sTable_Salesman),
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount = 1 then
  with nList.Items,Result do
  begin
    Add('纸卡编号:' + nList.Delimiter + FieldByName('Z_ID').AsString);
    Add('业务人员:' + nList.Delimiter + FieldByName('S_Name').AsString+ ' ');
    Add('客户名称:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('项目名称:' + nList.Delimiter + FieldByName('Z_Project').AsString + ' ');
    
    nStr := DateTime2Str(FieldByName('Z_Date').AsDateTime);
    Add('办卡时间:' + nList.Delimiter + nStr);
  end else
  begin
    Result := nil;
    nHint := '纸卡已无效';
  end;
end;

//Date: 2014-09-14
//Parm: 纸卡号;是否限提
//Desc: 获取nZhiKa的可用金哦
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetZhiKaMoney, nZhiKa, '', @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    nFixMoney := nOut.FExtParam = sFlag_Yes;
  end else Result := 0;
end;

//Desc: 获取nCID用户的可用金额,包含信用额或净额
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nCredit: PDouble): Double;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
end;

//Date: 2014-10-16
//Parm: 品种列表(s1,s2..)
//Desc: 验证nStocks是否可以发货
function IsStockValid(const nStocks: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_CheckStockValid, nStocks, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存交货单,返回交货单号列表
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nBillID单据
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单;新车牌
//Desc: 修改nBill的车牌为nTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2014-09-30
//Parm: 交货单;纸卡
//Desc: 将nBill调拨给nNewZK的客户
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Sale;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2016-12-30
//Parm: 磁卡号;车牌号
//Desc: 为nTruck办理厂内零售磁卡
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillLSCard, nCard, nTruck, @nOut);
end;

//Date: 2017-01-03
//Parm: 客户编号;计划列表
//Desc: 读取nCusID的销售计划
function LoadSalePlan(const nCusID: string;var nPlans: TSalePlanItems): Boolean;
var nIdx: Integer;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_LoadSalePlan, nCusID, '', @nOut);
  if not Result then Exit;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := DecodeBase64(nOut.FData);
    SetLength(nPlans, nListA.Count);

    for nIdx:=0 to nListA.Count-1 do
    begin
      nListB.Text := DecodeBase64(nListA[nIdx]);
      with nPlans[nIdx] do
      begin
        FSelected := False;
        FOrderNo := nListB.Values['billno'];
        FInterID := nListB.Values['inter'];
        FEntryID := nListB.Values['entry'];
        
        FStockID := nListB.Values['id'];
        FStockName := nListB.Values['name'];
        FTruck := nListB.Values['truck'];
        FValue := StrToFloat(nListB.Values['value']);
      end;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;   
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表;磅站通道
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm: 
//Desc: 保存采购申请单
function SaveOrderBase(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrderBase, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

function DeleteOrderBase(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrderBase, nOrder, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存采购单,返回采购单号列表
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nBillID单据
function DeleteOrder(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Provide;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutOrderCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_LogOffOrderCard, nCard, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单;新车牌
//Desc: 修改nOrder的车牌为nTruck.
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_ModifyBillTruck, nOrder, nTruck, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表;磅站通道
//Desc: 保存nPost岗位上的交货单数据
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;


//Date: 2014-09-17
//Parm: 交货单项; MCListBox;分隔符
//Desc: 将nItem载入nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('车牌号码:%s %s', [nDelimiter, FTruck]));
    Add(Format('当前状态:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('交货单号:%s %s', [nDelimiter, FId]));
    Add(Format('交货数量:%s %.3f 吨', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '袋装' else nStr := '散装';

    Add(Format('品种类型:%s %s', [nDelimiter, nStr]));
    Add(Format('品种名称:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('提货磁卡:%s %s', [nDelimiter, FCard]));
    Add(Format('单据类型:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('客户名称:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2014-09-17
//Parm: 交货单项; MCListBox;分隔符
//Desc: 将nItem载入nMC
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('车牌号码:%s %s', [nDelimiter, FTruck]));
    Add(Format('当前状态:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('采购单号:%s %s', [nDelimiter, FZhiKa]));
//    Add(Format('交货数量:%s %.3f 吨', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '袋装' else nStr := '散装';

    Add(Format('品种类型:%s %s', [nDelimiter, nStr]));
    Add(Format('品种名称:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('送货磁卡:%s %s', [nDelimiter, FCard]));
    Add(Format('单据类型:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('供 应 商:%s %s', [nDelimiter, FCusName]));
  end;
end;

//------------------------------------------------------------------------------
//Desc: 每批次最大量
function GetHYMaxValue: Double;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: 获取nNo水泥编号的已开量
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
end;

//Desc: 检测nWeek是否存在或过期
function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
var nStr: string;
begin
  nStr := 'Select W_End,$Now From $W Where W_NO=''$NO''';
  nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
          MI('$Now', FDM.SQLServerNow), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsDateTime + 1 > Fields[1].AsDateTime;
    if not Result then
      nHint := '该结算周期已结束';
    //xxxxx
  end else
  begin
    Result := False;
    nHint := '该结算周期已无效';
  end;
end;

//Desc: 检查nWeek是否已扎账
function IsWeekHasEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week=''$NO''';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: 检测nWeek后面的周期是否已扎账
function IsNextWeekEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week In ' +
          '( Select W_NO From $W Where W_Begin > (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: 检测nWee前面的周期是否已结算完成
function IsPreWeekOver(const nWeek: string): Integer;
var nStr: string;
begin
  nStr := 'Select Count(*) From $Req Where (R_ReqValue<>R_KValue) And ' +
          '(R_Week In ( Select W_NO From $W Where W_Begin < (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO'')))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsInteger
  else Result := 0;
end;

//Desc: 保存用户补偿金
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_Compensation=A_Compensation+%s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nMoney), nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,M_Type,M_Payment,' +
            'M_Money,M_Date,M_Man,M_Memo) Values(''%s'',''%s'',''%s'',' +
            '''%s'',''%s'',%s,%s,''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName,
            sFlag_MoneyFanHuan, nPayment, FloatToStr(nMoney),
            FDM.SQLServerNow, gSysParam.FUserID, nMemo]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 打印标识为nID的销售合同
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
var nStr: string;
    nParam: TReportParamItem;
begin
  if nAsk then
  begin
    nStr := '是否要打印销售合同?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select sc.*,S_Name,C_Name From $SC sc ' +
          '  Left Join $SM sm On sm.S_ID=sc.C_SaleMan ' +
          '  Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
          'Where sc.C_ID=''$ID''';

  nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$ID', nID)]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s] 的销售合同已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where E_CID=''%s''';
  nStr := Format(nStr, [sTable_SContractExt, nID]);
  FDM.QuerySQL(nStr);

  nStr := gPath + sReportDir + 'SaleContract.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
end;

//Desc: 打印纸卡
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印纸卡?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select zk.*,C_Name,S_Name From %s zk ' +
          ' Left Join %s cus on cus.C_ID=zk.Z_Customer' +
          ' Left Join %s sm on sm.S_ID=zk.Z_SaleMan ' +
          'Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, sTable_Salesman, nZID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '纸卡号为[ %s ] 的记录已无效';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
  if FDM.QuerySQL(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的纸卡无明细';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ZhiKa.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印收据
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印收据?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_SysShouJu, nSID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '凭单号为[ %s ] 的收据已无效!!';
    nStr := Format(nStr, [nSID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ShouJu.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印提货单
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印提货单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //添加引号
  
  nStr := 'Select * From %s b Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;


//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印采购单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '采购单[ %s ] 已无效!!';
    nStr := Format(nStr, [nOrder]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: 过磅单号;是否询问
//Desc: 打印nPound过磅记录
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '称重记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2017-01-11
//Parm: 采购单号;是否弹出询问
//Desc: 打印采购验收单
function PrintRCOrderReport(const nID: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印入厂单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where O_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, nID]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '入厂单[ %s ] 已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\ProvideRC.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else Result := '';
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印化验单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印合格证?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  {$IFDEF HeGeZhengSimpleData}
  nSR := 'Select * From %s hy ' +
         '  Left Join %s b On b.L_ID=hy.H_Reporter ' +
         '  Left Join %s sp On sp.P_Stock=b.L_StockName ' +
         'Where hy.H_ID in (%s)';
  nStr := Format(nSR, [sTable_StockHuaYan, sTable_Bill, sTable_StockParam, nHID]);
  {$ELSE}
  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx
  {$ENDIF}

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2016-8-10
//Parm: 交货单号;提示
//Desc: 打印nBill单号的发运单
function PrintBillFYDReport(const nBill: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印现场发运单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s  Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '交货单[ %s ] 已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\BillFYD.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印过路单
function PrintBillLoadReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string; 
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过路单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s  Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '交货单[ %s ] 已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\BillLoad.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;                                                 

//Date: 2015/1/18
//Parm: 车牌号；电子标签；是否启用；旧电子标签
//Desc: 读标签是否成功；新的电子标签
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2016/8/7
//Parm: 车牌号
//Desc: 查看车辆上次过磅时间间隔
function GetTruckLastTime(const nTruck: string): Integer;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := -1;
  //默认允许

  nStr := 'Select Top 1 %s as T_Now,P_PDate,P_MDate ' +
          'From %s Where P_Truck=''%s'' Order By P_ID Desc';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_PoundLog, nTruck]);
  //选择最后一次过磅

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nNow   := FieldByName('T_Now').AsDateTime;
    nPDate := FieldByName('P_PDate').AsDateTime;
    nMDate := FieldByName('P_MDate').AsDateTime;

    if nPDate > nMDate then
         Result := Trunc((nNow - nPDate) * 24 * 60 * 60)
    else Result := Trunc((nNow - nMDate) * 24 * 60 * 60);
  end;
end;

function IsStrictSanValue: Boolean;
var nSQL: string;
begin
  Result := False;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_StrictSanVal]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
end;

function GetFQValueByStockNo(const nStock: string): Double;
var nSQL: string;
begin
  Result := 0;
  if nStock = '' then Exit;

  nSQL := 'Select Sum(L_Value) From %s Where L_Seal=''%s'' ' +
          'and L_Date > GetDate() - 30';   //一个月内的总计
  nSQL := Format(nSQL, [sTable_Bill, nStock]);
  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

function VerifyFQSumValue: Boolean;
var nStr: string;
begin
  Result := False;
  //默认不判断

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyFQValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
end;

function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
end;  

//获取客户注册信息
function getCustomerInfo(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_getCustomerInfo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//客户与微信账号绑定
function get_Bindfunc(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_get_Bindfunc, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//发送消息
function send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut,false) then
    Result := nOut.FData;
end;

//新增商城用户
function edit_shopclients(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_edit_shopclients, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//添加商品
function edit_shopgoods(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_edit_shopgoods, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//获取订单信息
function get_shoporders(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_get_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//更新订单状态
function complete_shoporders(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;  
end;
end.
