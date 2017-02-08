{*******************************************************************************
  作者: dmzn@163.com 2008-08-07
  描述: 系统数据库常量定义

  备注:
  *.自动创建SQL语句,支持变量:$Inc,自增;$Float,浮点;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,二进制流
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

  cPrecision            = 100;
  {-----------------------------------------------------------------------------
   描述: 计算精度
   *.重量为吨的计算中,小数值比较或者相减运算时会有误差,所以会先放大,去掉
     小数位后按照整数计算.放大倍数由精度值确定.
  -----------------------------------------------------------------------------}

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //系统表项

var
  gSysTableList: TList = nil;                        //系统表数组
  gSysDBType: TSysDatabaseType = dtSQLServer;        //系统数据类型

//------------------------------------------------------------------------------
const
  //自增字段
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //小数字段
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //图片字段
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //日期相关
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*权限项*}
  sPopedom_Read       = 'A';                         //浏览
  sPopedom_Add        = 'B';                         //添加
  sPopedom_Edit       = 'C';                         //修改
  sPopedom_Delete     = 'D';                         //删除
  sPopedom_Preview    = 'E';                         //预览
  sPopedom_Print      = 'F';                         //打印
  sPopedom_Export     = 'G';                         //导出
  sPopedom_ViewPrice  = 'H';                         //查看单价

  {*数据库标识*}
  sFlag_DB_K3         = 'King_K3';                   //金蝶数据库
  sFlag_DB_NC         = 'YonYou_NC';                 //用友数据库
  sFlag_DB_AX         = 'AX_DB';                     //AX数据库

  {*相关标记*}
  sFlag_Yes           = 'Y';                         //是
  sFlag_No            = 'N';                         //否
  sFlag_Unknow        = 'U';                         //未知 
  sFlag_Enabled       = 'Y';                         //启用
  sFlag_Disabled      = 'N';                         //禁用

  sFlag_Integer       = 'I';                         //整数
  sFlag_Decimal       = 'D';                         //小数

  sFlag_ManualNo      = '%';                         //手动指定(非系统自动)
  sFlag_NotMatter     = '@';                         //无关编号(任意编号都可)
  sFlag_ForceDone     = '#';                         //强制完成(未完成前不换)
  sFlag_FixedNo       = '$';                         //指定编号(使用相同编号)

  sFlag_Provide       = 'P';                         //供应
  sFlag_Sale          = 'S';                         //销售
  sFlag_Returns       = 'R';                         //退货
  sFlag_Other         = 'O';                         //其它
  sFlag_DuanDao       = 'D';                         //短倒(预制皮重,单次称重)
  
  sFlag_TiHuo         = 'T';                         //自提
  sFlag_SongH         = 'S';                         //送货
  sFlag_XieH          = 'X';                         //运卸

  sFlag_Dai           = 'D';                         //袋装水泥
  sFlag_San           = 'S';                         //散装水泥

  sFlag_BillNew       = 'N';                         //新单
  sFlag_BillEdit      = 'E';                         //修改
  sFlag_BillDel       = 'D';                         //删除
  sFlag_BillLading    = 'L';                         //提货中
  sFlag_BillPick      = 'P';                         //拣配
  sFlag_BillPost      = 'G';                         //过账
  sFlag_BillDone      = 'O';                         //完成

  sFlag_OrderNew       = 'N';                        //新单
  sFlag_OrderEdit      = 'E';                        //修改
  sFlag_OrderDel       = 'D';                        //删除
  sFlag_OrderPuring    = 'L';                        //送货中
  sFlag_OrderDone      = 'O';                        //完成
  sFlag_OrderAbort     = 'A';                        //废弃
  sFlag_OrderStop      = 'S';                        //终止

  sFlag_OrderCardL     = 'L';                        //临时
  sFlag_OrderCardG     = 'G';                        //固定

  sFlag_TypeShip      = 'S';                         //船运
  sFlag_TypeZT        = 'Z';                         //栈台
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //普通,订单类型

  sFlag_CardIdle      = 'I';                         //空闲卡
  sFlag_CardUsed      = 'U';                         //使用中
  sFlag_CardLoss      = 'L';                         //挂失卡
  sFlag_CardInvalid   = 'N';                         //注销卡

  sFlag_TruckNone     = 'N';                         //无状态车辆
  sFlag_TruckIn       = 'I';                         //进厂车辆
  sFlag_TruckOut      = 'O';                         //出厂车辆
  sFlag_TruckBFP      = 'P';                         //磅房皮重车辆
  sFlag_TruckBFM      = 'M';                         //磅房毛重车辆
  sFlag_TruckSH       = 'S';                         //送货车辆
  sFlag_TruckFH       = 'F';                         //放灰车辆
  sFlag_TruckZT       = 'Z';                         //栈台车辆
  sFlag_TruckXH       = 'X';                         //验收车辆

  sFlag_TJNone        = 'N';                         //未调价
  sFlag_TJing         = 'T';                         //调价中
  sFlag_TJOver        = 'O';                         //调价完成
  
  sFlag_PoundBZ       = 'B';                         //标准
  sFlag_PoundPZ       = 'Z';                         //皮重
  sFlag_PoundPD       = 'P';                         //配对
  sFlag_PoundCC       = 'C';                         //出厂(过磅模式)
  sFlag_PoundLS       = 'L';                         //临时
  
  sFlag_MoneyHuiKuan  = 'R';                         //回款入金
  sFlag_MoneyJiaCha   = 'C';                         //补缴价差
  sFlag_MoneyZhiKa    = 'Z';                         //纸卡回款
  sFlag_MoneyFanHuan  = 'H';                         //返还用户

  sFlag_InvNormal     = 'N';                         //正常发票
  sFlag_InvHasUsed    = 'U';                         //已用发票
  sFlag_InvInvalid    = 'V';                         //作废发票
  sFlag_InvRequst     = 'R';                         //申请开出
  sFlag_InvDaily      = 'D';                         //日常开出

  sFlag_DeductFix     = 'F';                         //固定值扣减
  sFlag_DeductPer     = 'P';                         //百分比扣减

  sFlag_SysParam      = 'SysParam';                  //系统参数
  sFlag_EnableBakdb   = 'Uses_BackDB';               //备用库
  sFlag_ValidDate     = 'SysValidDate';              //有效期
  sFlag_ZhiKaVerify   = 'ZhiKaVerify';               //纸卡审核
  sFlag_PrintZK       = 'PrintZK';                   //打印纸卡
  sFlag_PrintBill     = 'PrintStockBill';            //需打印订单
  sFlag_ViaBillCard   = 'ViaBillCard';               //直接制卡
  sFlag_PayCredit     = 'Pay_Credit';                //回款冲信用
  sFlag_HYValue       = 'HYMaxValue';                //化验批次量
  sFlag_SaleManDept   = 'SaleManDepartment';         //业务员部门编号
  
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //袋装正误差 10t-150t
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //袋装负误差 10t-150t
  sFlag_PDaiPercent   = 'PoundDaiPercent';           //按比例计算误差
  sFlag_PDaiWuChaStop = 'PoundDaiWuChaStop';         //误差时停止业务
  sFlag_PSanWuChaF    = 'PoundSanWuChaF';            //散装负误差
  sFlag_PoundWuCha    = 'PoundWuCha';                //过磅误差分组
  sFlag_PoundIfDai    = 'PoundIFDai';                //袋装是否过磅
  sFlag_NFStock       = 'NoFaHuoStock';              //现场无需发货
  sFlag_NFPurch       = 'NoFaHuoPurch';              //现场无需发货（原材料）
  sFlag_PEmpTWuCha    = 'EmpTruckWuCha';             //空车出厂误差

  sFlag_CommonItem    = 'CommonItem';                //公共信息
  sFlag_CardItem      = 'CardItem';                  //磁卡信息项
  sFlag_AreaItem      = 'AreaItem';                  //区域信息项
  sFlag_TruckItem     = 'TruckItem';                 //车辆信息项
  sFlag_CustomerItem  = 'CustomerItem';              //客户信息项
  sFlag_BankItem      = 'BankItem';                  //银行信息项
  sFlag_UserLogItem   = 'UserLogItem';               //用户登录项

  sFlag_StockItem     = 'StockItem';                 //水泥信息项
  sFlag_ContractItem  = 'ContractItem';              //合同信息项
  sFlag_SalesmanItem  = 'SalesmanItem';              //业务员信息项
  sFlag_ZhiKaItem     = 'ZhiKaItem';                 //纸卡信息项
  sFlag_BillItem      = 'BillItem';                  //提单信息项
  sFlag_TruckQueue    = 'TruckQueue';                //车辆队列
                                                               
  sFlag_PaymentItem   = 'PaymentItem';               //付款方式信息项
  sFlag_PaymentItem2  = 'PaymentItem2';              //销售回款信息项
  sFlag_LadingItem    = 'LadingItem';                //提货方式信息项

  sFlag_ProviderItem  = 'ProviderItem';              //供应商信息项
  sFlag_MaterailsItem = 'MaterailsItem';             //原材料信息项

  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_MITSrvURL     = 'MITServiceURL';             //服务地址

  sFlag_AutoIn        = 'Truck_AutoIn';              //自动进厂
  sFlag_AutoOut       = 'Truck_AutoOut';             //自动出厂
  sFlag_InTimeout     = 'InFactTimeOut';             //进厂超时(队列)
  sFlag_SanMultiBill  = 'SanMultiBill';              //散装预开多单
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //袋装禁用队列
  sFlag_NoSanQueue    = 'NoSanQueue';                //散装禁用队列
  sFlag_DelayQueue    = 'DelayQueue';                //延迟排队(厂内)
  sFlag_PoundQueue    = 'PoundQueue';                //延迟排队(厂内依据过皮时间)
  sFlag_NetPlayVoice  = 'NetPlayVoice';              //使用网络语音播发

  sFlag_BusGroup      = 'BusFunction';               //业务编码组
  sFlag_BillNo        = 'Bus_Bill';                  //交货单号
  sFlag_PoundID       = 'Bus_Pound';                 //称重记录
  sFlag_Customer      = 'Bus_Customer';              //客户编号
  sFlag_SaleMan       = 'Bus_SaleMan';               //业务员编号
  sFlag_ZhiKa         = 'Bus_ZhiKa';                 //纸卡编号
  sFlag_WeiXin        = 'Bus_WeiXin';                //微信映射编号
  sFlag_HYDan         = 'Bus_HYDan';                 //化验单号
  sFlag_ForceHint     = 'Bus_HintMsg';               //强制提示
  sFlag_Order         = 'Bus_Order';                 //采购单号
  sFlag_OrderDtl      = 'Bus_OrderDtl';              //采购单号
  sFlag_OrderBase     = 'Bus_OrderBase';             //采购申请单号
  sFlag_Transfer      = 'Bus_Transfer';              //短倒单号
  sFlag_Hhcl          = 'HuYanHhcl';                 //混合材类
  sFlag_OnLineModel   = 'OnLineModel';               //在线模式
  sFlag_NoSampleID    = 'NoSampleID';                //无试样编号

  {*数据表*}
  sTable_Group        = 'Sys_Group';                 //用户组
  sTable_User         = 'Sys_User';                  //用户表
  sTable_Menu         = 'Sys_Menu';                  //菜单表
  sTable_Popedom      = 'Sys_Popedom';               //权限表
  sTable_PopItem      = 'Sys_PopItem';               //权限项
  sTable_Entity       = 'Sys_Entity';                //字典实体
  sTable_DictItem     = 'Sys_DataDict';              //字典明细

  sTable_SysDict      = 'Sys_Dict';                  //系统字典
  sTable_ExtInfo      = 'Sys_ExtInfo';               //附加信息
  sTable_SysLog       = 'Sys_EventLog';              //系统日志
  sTable_BaseInfo     = 'Sys_BaseInfo';              //基础信息
  sTable_SerialBase   = 'Sys_SerialBase';            //编码种子
  sTable_SerialStatus = 'Sys_SerialStatus';          //编号状态
  sTable_WorkePC      = 'Sys_WorkePC';               //验证授权
  
  sTable_Customer     = 'S_Customer';                //客户信息
  sTable_Salesman     = 'S_Salesman';                //业务人员
  sTable_SaleContract = 'S_Contract';                //销售合同
  sTable_SContractExt = 'S_ContractExt';             //合同扩展

  sTable_ZhiKa        = 'S_ZhiKa';                   //纸卡数据
  sTable_ZhiKaDtl     = 'S_ZhiKaDtl';                //纸卡明细
  sTable_Card         = 'S_Card';                    //销售磁卡
  sTable_Bill         = 'S_Bill';                    //提货单
  sTable_BillBak      = 'S_BillBak';                 //已删交货单

  sTable_StockMatch   = 'S_StockMatch';              //品种映射
  sTable_StockParam   = 'S_StockParam';              //品种参数
  sTable_StockParamExt= 'S_StockParamExt';           //参数扩展
  sTable_StockRecord  = 'S_StockRecord';             //检验记录
  sTable_StockHuaYan  = 'S_StockHuaYan';             //开化验单

  sTable_Truck        = 'S_Truck';                   //车辆表
  sTable_ZTLines      = 'S_ZTLines';                 //装车道
  sTable_ZTTrucks     = 'S_ZTTrucks';                //车辆队列

  sTable_Provider     = 'P_Provider';                //客户表
  sTable_Materails    = 'P_Materails';               //物料表
  sTable_Order        = 'P_Order';                   //采购订单
  sTable_OrderBak     = 'P_OrderBak';                //已删除采购订单
  sTable_OrderBaseMain= 'P_OrderBaseMain';           //采购申请订单主表
  sTable_OrderBase    = 'P_OrderBase';               //采购申请订单
  sTable_OrderBaseBak = 'P_OrderBaseBak';            //已删除采购申请订单
  sTable_OrderDtl     = 'P_OrderDtl';                //采购订单明细
  sTable_OrderDtlBak  = 'P_OrderDtlBak';             //采购订单明细
  sTable_Deduct       = 'S_PoundDeduct';             //过磅暗扣

  sTable_Transfer     = 'P_Transfer';                //短倒明细单
  sTable_TransferBak  = 'P_TransferBak';             //短倒明细单
  
  sTable_CusAccount   = 'Sys_CustomerAccount';       //客户账户
  sTable_InOutMoney   = 'Sys_CustomerInOutMoney';    //资金明细
  sTable_CusCredit    = 'Sys_CustomerCredit';        //客户信用（客户）
  sTable_SysShouJu    = 'Sys_ShouJu';                //收据记录

  sTable_Invoice      = 'Sys_Invoice';               //发票列表
  sTable_InvoiceDtl   = 'Sys_InvoiceDetail';         //发票明细
  sTable_InvoiceWeek  = 'Sys_InvoiceWeek';           //结算周期
  sTable_InvoiceReq   = 'Sys_InvoiceRequst';         //结算申请
  sTable_InvReqtemp   = 'Sys_InvoiceReqtemp';        //临时申请
  sTable_DataTemp     = 'Sys_DataTemp';              //临时数据

  sTable_WeixinLog    = 'Sys_WeixinLog';             //微信日志
  sTable_WeixinMatch  = 'Sys_WeixinMatch';           //账号匹配
  sTable_WeixinTemp   = 'Sys_WeixinTemplate';        //信息模板

  sTable_PoundLog     = 'Sys_PoundLog';              //过磅数据
  sTable_PoundBak     = 'Sys_PoundBak';              //过磅作废
  sTable_Picture      = 'Sys_Picture';               //存放图片

  sTable_BindInfo     = 'W_BindInfo';                //用户绑定（微信）
  sTable_CustomerInfo = 'W_CustomerInfo';            //客户信息（微信）

  sTable_InventDim       = 'Sys_InventDim';          //维度信息
  sTable_InventCenter    = 'Sys_InventCenter';       //生产线基础表
  sTable_InventLocation  = 'Sys_InventLocation';     //仓库基础表
  sTable_CusContCredit   = 'Sys_CustContCredit';     //客户信用（客户-合同）
  sTable_CustPresLog     = 'Sys_CustPresLog';        //信用额度增减(客户)
  sTable_ContPresLog     = 'Sys_ContPresLog';        //信用额度增减(客户-合同)
  sTable_AddTreaty       = 'Sys_AddTreaty';          //补充协议
  sTable_InvCenGroup     = 'Sys_InvCenGroup';        //物料组生产线
  sTable_EMPL            = 'Sys_EMPLOYEES';          //员工表
  sTable_PoundWucha      = 'Sys_PoundWuCha';         //称重误差参数表
  sTable_PoundDevia      = 'Sys_PoundDevia';         //称重误差值
  sTable_ZTWorkSet       = 'S_ZTWorkSet';            //班别设置表
  sTable_InOutFatory     = 'L_InOutFactory';         //临时进厂出厂表
  sTable_KuWei           = 'Sys_KuWei';              //库位设置表
  sTable_CompanyArea     = 'Sys_CompanyArea';        //销售区域

  sTable_K3_SyncItem  = 'DL_SyncItem';               //数据同步项
  sTable_K3_Customer  = 'T_Organization';            //组织结构(客户)

  sTable_AX_Cust      = 'ERP_CustTable';             //客户信息
  sTable_AX_VEND      = 'ERP_VVendTable';            //供应商信息
  sTable_AX_INVENT    = 'ERP_InventTable';           //物料信息
  sTable_AX_COMPANY   = 'COMPANYDOMAINLIST';         //公司信息
  sTable_AX_INVENTDIM = 'INVENTDIM';                 //维度基础表
  sTable_AX_INVENTCENTER  = 'XTTINVENTCENTERTABLE';  //生产线基础表
  sTable_AX_INVENTLOCATION  = 'INVENTLOCATION';      //仓库基础表
  sTable_AX_TPRESTIGEMANAGE  = 'XT_TPRESTIGEMANAGE'; //信用额度（客户）
  sTable_AX_TPRESTIGEMBYCONT  = 'XT_TPRESTIGEMANAGEBYCONTRACT';  //信用额度（客户-合同）
  STable_AX_EMPL      = 'EMPLTABLE';                 //员工信息表
  sTable_AX_InvCenGroup = 'xtTInventCenterItemGroup';//物料组生产线
  sTable_AX_WMSLocation = 'WMSLocation';//库位信息表
  //----------------------------------------------------------------------------
  sTable_AX_Sales     = 'SALESTABLE';                //销售订单
  sTable_AX_SalLine   = 'SALESLINE';                 //销售订单行
  sTable_AX_SupAgre   = 'XTADDTreatyRefSL';          //补充协议
  sTable_AX_CreLimLog = 'XT_CUSTPRESTIGEQUOTALOG';   //信用额度增减(客户)
  sTable_AX_ContCreLimLog = 'XT_CustPQLogContractId';//信用额度增减(客户-合同)
  sTable_AX_SalesCont = 'CMT_ContractTable';         //销售合同
  sTable_AX_SalContLine = 'CMT_ContractTrans';       //销售合同行
  sTable_AX_VehicleNo = 'CMT_Vehicle';               //车辆信息
  sTable_AX_PurOrder  = 'purchtable';                //采购订单
  sTable_AX_PurOrdLine= 'Purchline';                 //采购订单行
  sTable_AX_CompArea  = 'XT_COMPACTAREA';            //销售区域
  sTable_AX_InventSum = 'XTInventSUM';               //生产线余量



  {*新建表*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   系统字典: SysDict
   *.D_ID: 编号
   *.D_Name: 名称
   *.D_Desc: 描述
   *.D_Value: 取值
   *.D_Memo: 相关信息
   *.D_ParamA: 浮点参数
   *.D_ParamB: 字符参数
   *.D_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   扩展信息表: ExtInfo
   *.I_ID: 编号
   *.I_Group: 信息分组
   *.I_ItemID: 信息标识
   *.I_Item: 信息项
   *.I_Info: 信息内容
   *.I_ParamA: 浮点参数
   *.I_ParamB: 字符参数
   *.I_Memo: 备注信息
   *.I_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   系统日志: SysLog
   *.L_ID: 编号
   *.L_Date: 操作日期
   *.L_Man: 操作人
   *.L_Group: 信息分组
   *.L_ItemID: 信息标识
   *.L_KeyID: 辅助标识
   *.L_Event: 事件
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   基本信息表: BaseInfo
   *.B_ID: 编号
   *.B_Group: 分组
   *.B_Text: 内容
   *.B_Py: 拼音简写
   *.B_Memo: 备注信息
   *.B_PID: 上级节点
   *.B_Index: 创建顺序
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行编号基数表: SerialBase
   *.R_ID: 编号
   *.B_Group: 分组
   *.B_Object: 对象
   *.B_Prefix: 前缀
   *.B_IDLen: 编号长
   *.B_Base: 基数
   *.B_Date: 参考日期
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行状态表: SerialStatus
   *.R_ID: 编号
   *.S_Object: 对象
   *.S_SerailID: 串行编号
   *.S_PairID: 配对编号
   *.S_Status: 状态(Y,N)
   *.S_Date: 创建时间
  -----------------------------------------------------------------------------}

  sSQL_NewWorkePC = 'Create Table $Table(R_ID $Inc, W_Name varChar(100),' +
       'W_MAC varChar(32), W_Factory varChar(32), W_Serial varChar(32),' +
       'W_Departmen varChar(32), W_ReqMan varChar(32), W_ReqTime DateTime,' +
       'W_RatifyMan varChar(32), W_RatifyTime DateTime, W_Valid Char(1))';
  {-----------------------------------------------------------------------------
   工作授权: WorkPC
   *.R_ID: 编号
   *.W_Name: 电脑名称
   *.W_MAC: MAC地址
   *.W_Factory: 工厂编号
   *.W_Departmen: 部门
   *.W_Serial: 编号
   *.W_ReqMan,W_ReqTime: 接入申请
   *.W_RatifyMan,W_RatifyTime: 批准
   *.W_Valid: 有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewSyncItem = 'Create Table $Table(R_ID $Inc, S_Table varChar(100),' +
       'S_Action Char(1), S_Record varChar(32), S_Param1 varChar(100),' +
       'S_Param2 $Float, S_Time DateTime)';
  {-----------------------------------------------------------------------------
   同步数据项: SyncItem
   *.R_ID: 编号
   *.S_Table: 表名称
   *.S_Action: 增删改(A,E,D)
   *.S_Record: 记录编号
   *.S_Param1,S_Param2: 参数
   *.S_Time: 时间
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1))';
  {-----------------------------------------------------------------------------
   相似品种映射: StockMatch
   *.R_ID: 记录编号
   *.M_Group: 分组
   *.M_ID: 物料号
   *.M_Name: 物料名称
   *.M_Status: 状态
  -----------------------------------------------------------------------------}
  
  sSQL_NewSalesMan = 'Create Table $Table(R_ID $Inc, S_ID varChar(15),' +
       'S_Name varChar(30), S_PY varChar(30), S_Phone varChar(20),' +
       'S_Area varChar(50), S_InValid Char(1), S_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   业务员表: SalesMan
   *.R_ID: 记录号
   *.S_ID: 编号
   *.S_Name: 名称
   *.S_PY: 简拼
   *.S_Phone: 联系方式
   *.S_Area:所在区域
   *.S_InValid: 已无效
   *.S_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(R_ID $Inc, C_ID varChar(15), ' +
       'C_Name varChar(80), C_PY varChar(80), C_Addr varChar(100), ' +
       'C_FaRen varChar(50), C_LiXiRen varChar(50), C_WeiXin varChar(15),' +
       'C_Phone varChar(15), C_Fax varChar(15), C_Tax varChar(32),' +
       'C_Bank varChar(35), C_Account varChar(18), C_SaleMan varChar(15),' +
       'C_Param varChar(32), C_Memo varChar(50), C_XuNi Char(1),' +
       'C_Factory varChar(50), C_ToUser varChar(50), C_IsBind Char(1),'+
       'C_CredMax Decimal(15,5) Default 0,C_MaCredLmt varChar(32),'+
       'C_CelPhone varChar(32))';
  {-----------------------------------------------------------------------------
   客户信息表: Customer
   *.R_ID: 记录号
   *.C_ID: 编号
   *.C_Name: 名称
   *.C_PY: 拼音简写
   *.C_Addr: 地址
   *.C_FaRen: 法人
   *.C_LiXiRen: 联系人
   *.C_Phone: 电话
   *.C_WeiXin: 微信
   *.C_Fax: 传真
   *.C_Tax: 税号
   *.C_Bank: 开户行
   *.C_Account: 帐号
   *.C_SaleMan: 业务员
   *.C_Param: 备用参数
   *.C_Memo: 备注信息
   *.C_XuNi: 虚拟(临时)客户
   *.C_Factory：工厂序列号
   *.C_ToUser：绑定用户ID
   *.C_IsBind：绑定状态（0：解绑 1：绑定）
   --祁连山新增字段
   *.C_CredMax：信用额度
   *.C_MaCredLmt：强制信用额度[校验是否强制]
   *.C_CelPhone：移动电话
  -----------------------------------------------------------------------------}
  
  sSQL_NewCusAccount = 'Create Table $Table(R_ID $Inc, A_CID varChar(15),' +
       'A_Used Char(1), A_InMoney Decimal(15,5) Default 0,' +
       'A_OutMoney Decimal(15,5) Default 0, A_DebtMoney Decimal(15,5) Default 0,' +
       'A_Compensation Decimal(15,5) Default 0,' +
       'A_FreezeMoney Decimal(15,5) Default 0,' +
       'A_CreditLimit Decimal(15,5) Default 0, A_Date DateTime,'+
       'A_ConFreezeMoney Decimal(15,5) not null Default 0,'+
       'A_ConOutMoney Decimal(15,5) not null Default 0)';
  {-----------------------------------------------------------------------------
   客户账户:CustomerAccount
   *.R_ID:记录编号
   *.A_CID:客户号
   *.A_Used:用途(供应,销售)
   *.A_InMoney:入金
   *.A_OutMoney:出金
   *.A_DebtMoney:欠款
   *.A_Compensation:补偿金
   *.A_FreezeMoney:冻结资金
   *.A_CreditLimit:信用额度
   *.A_Date:创建日期
   *.A_ConFreezeMoney:合同专款专用冻结资金
   *.A_ConOutMoney:合同专款专用出金

   *.水泥销售账中
     A_InMoney:客户存入账户的金额
     A_OutMoney:客户实际花费的金额
     A_DebtMoney:还未支付的金额
     A_Compensation:由于差价退还给客户的金额
     A_FreezeMoney:已办纸卡但未进厂提货的金额
     A_CreditLimit:授信给用户的最高可欠款金额

     可用余额 = 入金 + 信用额 - 出金 - 补偿金 - 已冻结
     消费总额 = 出金 + 欠款 + 已冻结
  -----------------------------------------------------------------------------}

  sSQL_NewInOutMoney = 'Create Table $Table(R_ID $Inc, M_SaleMan varChar(15),' +
       'M_CusID varChar(15), M_CusName varChar(80), ' +
       'M_Type Char(1), M_Payment varChar(20),' +
       'M_Money Decimal(15,5), M_ZID varChar(15), M_Date DateTime,' +
       'M_Man varChar(32), M_Memo varChar(200))';
  {-----------------------------------------------------------------------------
   出入金明细:CustomerInOutMoney
   *.M_ID:记录编号
   *.M_SaleMan:业务员
   *.M_CusID:客户号
   *.M_CusName:客户名
   *.M_Type:类型(补差,回款等)
   *.M_Payment:付款方式
   *.M_Money:缴纳金额
   *.M_ZID:纸卡号
   *.M_Date:操作日期
   *.M_Man:操作人
   *.M_Memo:描述

   *.水泥销售入金中
     金额 = 单价 x 数量 + 其它
  -----------------------------------------------------------------------------}

  sSQL_NewSysShouJu = 'Create Table $Table(R_ID $Inc ,S_Code varChar(15),' +
       'S_Sender varChar(100), S_Reason varChar(100), S_Money Decimal(15,5),' +
       'S_BigMoney varChar(50), S_Bank varChar(35), S_Man varChar(32),' +
       'S_Date DateTime, S_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   收据明细:ShouJu
   *.R_ID:编号
   *.S_Code:记账凭单号码
   *.S_Sender:兹由(来源)
   *.S_Reason:交来(事务)
   *.S_Money:金额
   *.S_Bank:银行
   *.S_Man:出纳员
   *.S_Date:日期
   *.S_Memo:备注
  -----------------------------------------------------------------------------}

  sSQL_NewCusCredit = 'Create Table $Table(R_ID $Inc ,C_CusID varChar(15),' +
       'C_Money Decimal(15,5), C_Man varChar(32), C_Date DateTime, ' +
       'C_End DateTime, C_Memo varChar(50), C_CustName varChar(50), '+
       'C_CashBalance numeric(28, 12), C_BillBalance3M numeric(28, 12), '+
       'C_BillBalance6M numeric(28, 12), C_PrestigeQuota numeric(28, 12), '+
       'C_TemporBalance numeric(28, 12), C_TemporAmount numeric(28, 12), '+
       'C_WarningAmount numeric(28, 12), C_TemporTakeEffect char(1), '+
       'C_FailureDate DateTime, DataAreaID varChar(3),'+
       'C_LSCreditNum varChar(20), C_PrestigeStatus char(1))';
  {-----------------------------------------------------------------------------
   信用明细（客户）:CustomerCredit
   *.R_ID:编号
   *.C_CusID:客户编号
   *.C_Money:授信额
   *.C_Man:操作人
   *.C_Date:日期
   *.C_End: 有效期
   *.C_Memo:备注
   祁连山新增
   *.C_CustName：客户名称
   *.C_CashBalance：现金余额
   *.C_BillBalance3M：三个月票据余额
   *.C_BillBalance6M：六个月票据余额
   *.C_PrestigeQuota：固定信用余额
   *.C_TemporBalance：临时余额
   *.C_TemporAmount： 临时授信金额
   *.C_WarningAmount：预警金额
   *.C_TemporTakeEffect：是否失效(0：否/1：是)
   *.C_FailureDate：失效日期
   *.DataAreaID：公司账套
   *.C_LSCreditNum: 临时授信单号
   *.C_PrestigeStatus: 固定信用标示（0：启用/1：停用）
  -----------------------------------------------------------------------------}

  sSQL_NewCusConCredit = 'Create Table $Table(R_ID $Inc ,C_CusID varChar(15),' +
       'C_Money Decimal(15,5), C_CustName varChar(50), C_ContractId varChar(60),'+
       'C_CashBalance Decimal(15,5), C_BillBalance3M Decimal(15,5), '+
       'C_BillBalance6M Decimal(15,5), C_PrestigeQuota Decimal(15,5), '+
       'C_TemporBalance Decimal(15,5), C_TemporAmount Decimal(15,5), '+
       'C_WarningAmount Decimal(15,5), C_TemporTakeEffect char(1), '+
       'C_FailureDate DateTime, DataAreaID varChar(3),'+
       'C_LSCreditNum varChar(20), C_Date DateTime)';
  {-----------------------------------------------------------------------------
   信用明细（客户-合同）:CustContCredit
   *.R_ID:编号
   *.C_CusID:客户编号
   *.C_Money:授信额
   *.C_CustName：客户名称
   *.C_ContractId：合同编号
   *.C_CashBalance：现金余额
   *.C_BillBalance3M：三个月票据余额
   *.C_BillBalance6M：六个月票据余额
   *.C_PrestigeQuota：固定信用余额
   *.C_TemporBalance：临时余额
   *.C_TemporAmount：临时授信金额
   *.C_WarningAmount：预警金额
   *.C_TemporTakeEffect：是否失效
   *.C_FailureDate：失效日期
   *.DataAreaID：公司账套
   *.C_LSCreditNum: 临时授信单号
  -----------------------------------------------------------------------------}
  sSQL_NewCustPresLog = 'Create Table $Table(R_ID $Inc ,C_CusID varChar(15),' +
       'C_SubCash Decimal(15,5), C_SubThreeBill Decimal(15,5), '+
       'C_SubSixBil Decimal(15,5), C_SubTmp Decimal(15,5), '+
       'C_SubPrest Decimal(15,5), C_Subdate DateTime, '+
       'C_Createdby varChar(30), C_Createdate int not null default ((0)), '+
       'C_Createtime DateTime, DataAreaID varChar(3),'+
       'RecID bigint not null default ((0)),'+
       'C_YKAmount Decimal(15,5), C_TransPlanID varchar(20))';
  {-----------------------------------------------------------------------------
   信用额度增减表:Sys_CustPresLog    祁连山新增
   *.R_ID:编号
   *.C_CusID:客户编号
   *.C_SubCash：现金增减
   *.C_SubThreeBill：三个月票据增减
   *.C_SubSixBil：六个月票据增减
   *.C_SubTmp：临时增减
   *.C_SubPrest：固定增减
   *.C_Subdate：增减时间
   *.C_Createdby：操作人
   *.C_Createdate：操作日期
   *.C_Createtime：操作时间
   *.DataAreaID：公司账套
   *.RecID: 行编码
   *.C_YKAmount 预扣金额
   *.C_TransPlanID 发运计划号
  -----------------------------------------------------------------------------}
  sSQL_NewContPresLog = 'Create Table $Table(R_ID $Inc ,C_CusID varChar(15),' +
       'C_ContractId varChar(20),'+
       'C_SubCash Decimal(15,5), C_SubThreeBill Decimal(15,5), '+
       'C_SubSixBil Decimal(15,5), C_SubTmp Decimal(15,5), '+
       'C_SubPrest Decimal(15,5), C_Subdate DateTime, '+
       'C_Createdby varChar(30), C_Createdate int not null default((0)), '+
       'C_Createtime DateTime, DataAreaID varChar(3),'+
       'RecID bigint not null default ((0)),'+
       'C_YKAmount Decimal(15,5), C_TransPlanID varchar(20))';
  {-----------------------------------------------------------------------------
   信用额度增减表(客户-合同):Sys_CustPresLog    祁连山新增
   *.R_ID:编号
   *.C_CusID:客户编号
   *.C_ContractId:合同编号
   *.C_SubCash：现金增减
   *.C_SubThreeBill：三个月票据增减
   *.C_SubSixBil：六个月票据增减
   *.C_SubTmp：临时增减
   *.C_SubPrest：固定增减
   *.C_Subdate：增减时间
   *.C_Createdby：操作人
   *.C_Createdate：操作日期
   *.C_Createtime：操作时间
   *.DataAreaID：公司账套
   *.RecID；行编码
   *.C_YKAmount 预扣金额
   *.C_TransPlanID 发运计划号
  -----------------------------------------------------------------------------}
  sSQL_NewSaleContract = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Project varChar(100),C_SaleMan varChar(15), C_Customer varChar(20), '+
       'C_CustName varChar(60),' +
       'C_Date varChar(20), C_Area varChar(50), C_Addr varChar(50),' +
       'C_Delivery varChar(50), C_Payment varChar(20), C_Approval varChar(30),' +
       'C_ZKDays Integer, C_XuNi Char(1), C_Freeze Char(1), C_Memo varChar(50),'+
       'C_SFSP int not null default((0)),C_ContType int not null default((0)),'+
       'C_ContQuota int not null default((0)), DataAreaID varChar(3) not null default(''dat''))';
  {-----------------------------------------------------------------------------
   销售合同: SalesContract
   *.R_ID: 编号
   *.C_ID: 合同编号
   *.C_Project: 项目名称
   *.C_SaleMan: 销售人员
   *.C_CustName: 客户名称
   *.C_Customer: 客户ID
   *.C_Date: 签订时间
   *.C_Area: 所属区域
   *.C_Addr: 签订地点
   *.C_Delivery: 交货地
   *.C_Payment: 付款方式
   *.C_Approval: 批准人
   *.C_ZKDays: 纸卡有效期
   *.C_XuNi: 虚拟合同
   *.C_Freeze: 是否冻结
   *.C_Memo: 备注信息
   祁连山新增
   *.C_SFSP: 合同状态
   *.C_ContType: 合同类型
   *.C_ContQuota: 是否专款专用合同
   *.DataAreaID: 账套
  -----------------------------------------------------------------------------}

  sSQL_NewSContractExt = 'Create Table $Table(R_ID $Inc,' +
       'E_CID varChar(15), E_Type Char(1), ' +
       'E_StockNo varChar(20), E_StockName varChar(80),' +
       'E_Value Decimal(15,5), E_Price Decimal(15,5), E_Money Decimal(15,5),'+
       'DataAreaID varChar(3) not null default (''dat''),'+
       'E_RecID bigint not null default ((0)))';
  {-----------------------------------------------------------------------------
   销售合同明细: SalesContract
   *.R_ID: 记录编号
   *.E_CID: 销售合同
   *.E_Type: 类型(袋,散)
   *.E_StockNo,E_StockName: 水泥类型
   *.E_Value: 数量
   *.E_Price: 单价
   *.E_Money: 金额
   *.DataAreaID: 账套
   *.E_RecID: 行编码
  -----------------------------------------------------------------------------}

  sSQL_NewZhiKa = 'Create Table $Table(R_ID $Inc,Z_ID varChar(15),' +
       'Z_Name varChar(100),Z_Card varChar(16),' +
       'Z_CID varChar(50), Z_Project varChar(100), Z_Customer varChar(15),' +
       'Z_SaleMan varChar(15), Z_Payment varChar(20), Z_Lading Char(1),' +
       'Z_ValidDays DateTime, Z_Password varChar(16), Z_OnlyPwd Char(1),' +
       'Z_Verified Char(1), Z_InValid Char(1), Z_Freeze Char(1),' +
       'Z_YFMoney $Float, Z_FixedMoney $Float, Z_OnlyMoney Char(1),' +
       'Z_TJStatus Char(1), Z_Memo varChar(200), Z_Man varChar(32),' +
       'Z_Date DateTime, Z_SalesStatus int Default 0, Z_SalesType int Default 0, '+
       'Z_TriangleTrade int Default 0, Z_OrgAccountNum varChar(40),'+
       'Z_XSQYBM varChar(10), Z_KHSBM varChar(20), DataAreaID varChar(3),'+
       'Z_IntComOriSalesId varChar(40),Z_PurchType int, Z_CompanyId varchar(3),'+
       'Z_OrgAccountName varChar(120), Z_OrgXSQYMC varChar(20),'+
       'Z_OrgXSQYBM varChar(20))';
  {-----------------------------------------------------------------------------
   纸卡办理: ZhiKa
   *.R_ID:记录编号
   *.Z_ID:纸卡号
   *.Z_Card:磁卡号
   *.Z_Name:纸卡名称
   *.Z_CID:销售合同
   *.Z_Project:项目名称
   *.Z_Customer:客户编号
   *.Z_SaleMan:业务员
   *.Z_Payment:付款方式
   *.Z_Lading:提货方式(自提,送货)  0：自提
   *.Z_ValidDays:有效期
   *.Z_Password: 密码
   *.Z_OnlyPwd: 统一密码
   *.Z_Verified:已审核
   *.Z_InValid:已无效
   *.Z_Freeze:已冻结
   *.Z_YFMoney:预付金额
   *.Z_FixedMoney:可用金
   *.Z_OnlyMoney:只使用可用金
   *.Z_TJStatus:调价状态
   *.Z_Man:操作人
   *.Z_Date:创建时间
   *.Z_SalesStatus: 状态
   *.Z_SalesType:订单类型
   *.Z_TriangleTrade: 三角贸易
   *.Z_CompanyId: 公司ID    用来确认三角贸易的客户账套
   *.Z_XSQYBM: 销售区域编号
   *.Z_KHSBM: 客户识别码
   *.DataAreaID: 账套
   *.Z_IntComOriSalesId: 销售订单ID（内部采购或三角贸易使用）
   *.Z_PurchType: 采购类型
   *.Z_OrgAccountNum: 最终账户
   *.Z_OrgAccountName: 最终账户名称
   *.Z_OrgXSQYMC: 最终销售区域名称
   *.Z_OrgXSQYBM: 最终销售区域编码
  -----------------------------------------------------------------------------}

  sSQL_NewZhiKaDtl = 'Create Table $Table(R_ID $Inc, D_ZID varChar(15),' +
       'D_Type Char(1), D_StockNo varChar(20), D_StockName varChar(80),' +
       'D_Price $Float, D_Value $Float, D_PPrice $Float, D_TotalValue $Float,' +
       'D_TPrice Char(1) Default ''Y'', D_LineNum numeric(28, 12) Default 0,'+
       'D_SalesStatus int Default(0), DATAAREAID varChar(3),'+
       'D_RECID bigint not null default ((0)),D_Blocked int not null default((0)),'+
       'D_Memo varChar(200))';
  {-----------------------------------------------------------------------------
   纸卡明细:ZhiKaDtl
   *.R_ID:记录编号
   *.D_ZID:纸卡号
   *.D_Type:类型(袋,散)
   *.D_StockNo,D_StockName:水泥名称
   *.D_Price:单价
   *.D_Value:办理量
   *.D_PPrice:调价前单价
   *.D_TotalValue: 订单总量
   *.D_TPrice:允许调价
   *.D_LineNum:行号
   *.D_RECID:行编码
   *.D_SalesStatus:行状态
   *.DATAAREAID: 账套
   *.D_Blocked：已停止
   *.D_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16), L_ZhiKa varChar(15), L_Project varChar(100),' +
       'L_Area varChar(50),' +
       'L_CusID varChar(15), L_CusName varChar(80), L_CusPY varChar(80),' +
       'L_CusAccount varChar(30),'+
       'L_SaleID varChar(15), L_SaleMan varChar(32),' +
       'L_Type Char(1), L_StockNo varChar(20), L_StockName varChar(80),' +
       'L_Value $Float, L_Price $Float, L_ZKMoney Char(1),' +
       'L_Truck varChar(15), L_Status Char(1), L_NextStatus Char(1),' +
       'L_InTime DateTime, L_InMan varChar(32),' +
       'L_PValue $Float, L_PDate DateTime, L_PMan varChar(32),' +
       'L_MValue $Float, L_MDate DateTime, L_MMan varChar(32),' +
       'L_LadeTime DateTime, L_LadeMan varChar(32), ' +
       'L_LadeLine varChar(15), L_LineName varChar(32), ' +
       'L_DaiTotal Integer , L_DaiNormal Integer, L_DaiBuCha Integer,' +
       'L_TransID varChar(32),L_TransName varChar(32),L_Searial varChar(32),'+
       'L_OutFact DateTime, L_OutMan varChar(32),' +
       'L_Lading Char(1), L_IsVIP varChar(1), L_Seal varChar(100),' +
       'L_HYDan varChar(15), L_Man varChar(32), L_Date DateTime,' +
       'L_DelMan varChar(32), L_DelDate DateTime,';
  sSQL_NewBill1 ='L_NewSendWx Char(1), L_DelSendWx Char(1), L_OutSendWx Char(1), '+
       'P_PStation varChar(10), P_MStation varChar(10), L_PID varChar(15),'+
       'L_LineRecID bigint,'+
       'L_InvLocationId varChar(20),L_InvCenterId varChar(20),'+
       'L_PlanQty numeric(28, 12) not null Default ((0)),L_CW varChar(10),'+
       'L_Transporter varChar(20),L_vendpicklistid varChar(60),'+
       'L_FYAX Char(1) not null default((0)),L_BDAX Char(1) not null default((0)),'+
       'L_FYNUM int not null default((0)),L_BDNUM int not null default((0)),'+
       'L_SalesType Char(1),L_FYDEL Char(1) not null default((0)),'+
       'L_FYDELNUM int not null default((0)),L_EmptyOut char(1) not null default(''N''),'+
       'L_EOUTAX Char(1) not null default((0)),L_EOUTNUM int not null default((0)),'+
       'L_WorkOrder varchar(10), L_KHSBM varchar(20), L_OrgXSQYMC varChar(20),'+
       'L_TriaTrade Char(1), L_ContQuota Char(1))';
  {-----------------------------------------------------------------------------
   交货单表: Bill
   *.R_ID: 编号
   *.L_ID: 提单号   (AX必须)
   *.L_Card: 磁卡号
   *.L_ZhiKa: 纸卡号/销售、采购订单号  (AX必须)
   *.L_Area: 区域
   *.L_CusID,L_CusName,L_CusPY:客户
   *.L_SaleID,L_SaleMan:业务员
   *.L_Type: 类型(袋,散)
   *.L_StockNo: 物料编号
   *.L_StockName: 物料描述
   *.L_Value: 提货量
   *.L_Price: 提货单价
   *.L_ZKMoney: 占用纸卡限提(Y/N)
   *.L_Truck: 车船号
   *.L_Status,L_NextStatus:状态控制
   *.L_InTime,L_InMan: 进厂放行
   *.L_PValue,L_PDate,L_PMan: 称皮重
   *.L_MValue,L_MDate,L_MMan: 称毛重
   *.L_LadeTime,L_LadeMan: 发货时间,发货人
   *.L_LadeLine,L_LineName: 发货通道
   *.L_DaiTotal,L_DaiNormal,L_DaiBuCha:总装,正常,补差
   *.L_OutFact,L_OutMan: 出厂放行
   *.L_Lading: 提货方式(自提,送货)
   *.L_IsVIP:VIP单
   *.L_Seal: 封签号
   *.L_HYDan: 化验单
   *.L_Man:操作人
   *.L_Date:创建时间
   *.L_DelMan: 交货单删除人员
   *.L_DelDate: 交货单删除时间
   *.L_NewSendWx: 开单发微信消息标识
   *.L_DelSendWx：删单发微信消息标识
   *.L_OutSendWx：出厂发微信消息标识
   *.L_Memo: 动作备注
   *.P_PStation,P_MStation: （皮/毛）地磅编号
   *.L_PID: 磅单号
   祁连山新增
   *.L_LineRecID: 订单行编码  (AX必须)
   *.L_InvLocationId:仓库 (AX必须)
   *.L_InvCenterId:生产线 (AX必须)
   *.L_PlanQty:计划发货数量  (AX必须)
   *.L_CW:库位
   *.L_Transporter:供应商账户
   *.L_vendpicklistid:经销商提货单号码
   *. 账套   (AX必须) --此字段不在表中创建，读取全局变量
   *.L_FYAX: 上传提货单标识
   *.L_BDAX: 上传磅单标识
   *.L_FYNUM: 上传提货单次数
   *.L_BDNUM：上传磅单次数
   *.L_SalesType: 订单类型（0：记账日志）
   *.L_FYDEL: 上传删除提货单标识
   *.L_FYDELNUM: 上传删除提货单次数
   *.L_EmptyOut: 空车出厂标记
   *.L_EOUTAX: 空车出厂上传标记
   *.L_EOUTNUM：空车出厂上传次数
   *.L_WorkOrder: 班次
   *.L_KHSBM: 区域码
   *.L_OrgXSQYMC: 最终销售区域
   *.L_TriaTrade: 是否三角贸易
   *.L_ContQuota: 是否专款专用（0：否 1：是）
  -----------------------------------------------------------------------------}
  sSQL_NewOrdBaseMain = 'Create Table $Table(R_ID $Inc, M_ID varChar(20),' +
       'M_CID varChar(50), M_BStatus Char(1), ' +
       'M_ProID varChar(32), M_ProName varChar(80), M_ProPY varChar(80),' +
       'M_TriangleTrade Char(1), M_IntComOriSalesId varChar(20), M_PurchType Char(1),' +
       'M_Man varChar(32), M_Date DateTime, ' +
       'M_DelMan varChar(32), M_DelDate DateTime, M_Memo varChar(500),'+
       'DATAAREAID varChar(3))';
  {-----------------------------------------------------------------------------
   采购申请单主表: OrderBaseMain
   *.R_ID: 编号
   *.M_ID: 申请单号
   *.M_CID: 合同号
   *.M_BStatus: 订单状态
   *.M_ProID,M_ProName,M_ProPY:供应商
   *.M_TriangleTrade: 三角贸易
   *.M_IntComOriSalesId：销售订单号（内部采购或三角贸易使用）
   *.M_PurchType: 采购类型
   *.M_Man:操作人
   *.M_Date:创建时间
   *.M_DelMan: 采购申请单删除人员
   *.M_DelDate: 采购申请单删除时间
   *.M_Memo: 动作备注
   *.DATAAREAID：账套
  -----------------------------------------------------------------------------}

  sSQL_NewOrderBase = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Value $Float, B_SentValue $Float,B_RestValue $Float,' +
       'B_LimValue $Float, B_WarnValue $Float,B_FreezeValue $Float,' +
       'B_BStatus Char(1),B_Area varChar(50), B_Project varChar(100),' +
       'B_ProID varChar(32), B_ProName varChar(80), B_ProPY varChar(80),' +
       'B_SaleID varChar(32), B_SaleMan varChar(80), B_SalePY varChar(80),' +
       'B_StockType Char(1), B_StockNo varChar(32), B_StockName varChar(80),' +
       'B_Man varChar(32), B_Date DateTime, DATAAREAID varChar(3),' +
       'B_DelMan varChar(32), B_DelDate DateTime, B_Memo varChar(500),'+
       'B_RecID bigint not null default ((0)), B_Blocked int not null default((0)))';
  {-----------------------------------------------------------------------------
   采购申请单表: Order
   *.R_ID: 编号
   *.B_ID: 提单号
   *.B_Value,B_SentValue,B_RestValue:订单量，已发量，剩余量
   *.B_LimValue,B_WarnValue,B_FreezeValue:订单超发上限;订单预警量,订单冻结量
   *.B_BStatus: 订单状态
   *.B_Area,B_Project: 区域,项目
   *.B_ProID,B_ProName,B_ProPY:供应商
   *.B_SaleID,B_SaleMan,B_SalePY:业务员
   *.B_StockType: 类型(袋,散)
   *.B_StockNo: 原材料编号
   *.B_StockName: 原材料名称
   *.B_Man:操作人
   *.B_Date:创建时间
   *.B_DelMan: 采购申请单删除人员
   *.B_DelDate: 采购申请单删除时间
   *.B_Memo: 动作备注
   *.B_RecID: 行编码
   *.B_Blocked: 已停止
   *.DATAAREAID：账套
  -----------------------------------------------------------------------------}
  sSQL_NewDeduct = 'Create Table $Table(R_ID $Inc, D_Stock varChar(32),' +
       'D_Name varChar(80), D_CusID varChar(32), D_CusName varChar(80),' +
       'D_Value $Float, D_Type Char(1), D_Valid Char(1))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.D_Stock: 物料号
   *.D_Name: 物料名
   *.D_CusID: 客户号
   *.D_CusName: 客户名
   *.D_Value: 取值
   *.D_Type: 类型(F,固定值;P,百分比)
   *.D_Valid: 是否有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewOrder = 'Create Table $Table(R_ID $Inc, O_ID varChar(20),' +
       'O_BID varChar(20),O_Card varChar(16), O_CType varChar(1),' +
       'O_Value $Float,O_Area varChar(50), O_Project varChar(100),' +
       'O_ProID varChar(32), O_ProName varChar(80), O_ProPY varChar(80),' +
       'O_SaleID varChar(32), O_SaleMan varChar(80), O_SalePY varChar(80),' +
       'O_Type Char(1), O_StockNo varChar(32), O_StockName varChar(80),' +
       'O_Truck varChar(15), O_OStatus Char(1),' +
       'O_Man varChar(32), O_Date DateTime,' +
       'O_DelMan varChar(32), O_DelDate DateTime, O_Memo varChar(500),'+
       'O_BRecID bigint not null default ((0)))';
  {-----------------------------------------------------------------------------
   采购订单表: Order
   *.R_ID: 编号
   *.O_ID: 提单号
   *.O_BID: 采购申请单据号
   *.O_Card,O_CType: 磁卡号,磁卡类型(L、临时卡;G、固定卡)
   *.O_Value:订单量，
   *.O_OStatus: 订单状态
   *.O_Area,O_Project: 区域,项目
   *.O_ProID,O_ProName,O_ProPY:供应商
   *.O_SaleID,O_SaleMan:业务员
   *.O_Type: 类型(袋,散)
   *.O_StockNo: 原材料编号
   *.O_StockName: 原材料名称
   *.O_Truck: 车船号
   *.O_Man:操作人
   *.O_Date:创建时间
   *.O_DelMan: 采购单删除人员
   *.O_DelDate: 采购单删除时间
   *.O_Memo: 动作备注
   *.O_BRecID: 行编码
  -----------------------------------------------------------------------------}

  sSQL_NewOrderDtl = 'Create Table $Table(R_ID $Inc, D_ID varChar(20),' +
       'D_OID varChar(20), D_PID varChar(20), D_Card varChar(16), ' +
       'D_Area varChar(50), D_Project varChar(100),D_Truck varChar(15), ' +
       'D_ProID varChar(32), D_ProName varChar(80), D_ProPY varChar(80),' +
       'D_SaleID varChar(32), D_SaleMan varChar(80), D_SalePY varChar(80),' +
       'D_Type Char(1), D_StockNo varChar(32), D_StockName varChar(80),' +
       'D_DStatus Char(1), D_Status Char(1), D_NextStatus Char(1),' +
       'D_InTime DateTime, D_InMan varChar(32),' +
       'D_PValue $Float, D_PDate DateTime, D_PMan varChar(32),' +
       'D_MValue $Float, D_MDate DateTime, D_MMan varChar(32),' +
       'D_YTime DateTime, D_YMan varChar(32), ' +
       'D_Value $Float,D_KZValue $Float, D_AKValue $Float,' +
       'D_YLine varChar(15), D_YLineName varChar(32), ' +
       'D_DelMan varChar(32), D_DelDate DateTime, D_YSResult Char(1), ' +
       'D_OutFact DateTime, D_OutMan varChar(32), D_Memo varChar(500),'+
       'D_BDAX Char(1) not null default((0)),D_BDNUM int not null default((0)),'+
       'D_RecID bigint not null default ((0)))';
  {-----------------------------------------------------------------------------
   采购订单明细表: OrderDetail
   *.R_ID: 编号
   *.D_ID: 采购明细号
   *.D_OID: 采购单号
   *.D_PID: 磅单号
   *.D_Card: 采购磁卡号
   *.D_DStatus: 订单状态
   *.D_Area,D_Project: 区域,项目
   *.D_ProID,D_ProName,D_ProPY:供应商
   *.D_SaleID,D_SaleMan:业务员
   *.D_Type: 类型(袋,散)
   *.D_StockNo: 原材料编号
   *.D_StockName: 原材料名称
   *.D_Truck: 车船号
   *.D_Status,D_NextStatus: 状态
   *.D_InTime,D_InMan: 进厂放行
   *.D_PValue,D_PDate,D_PMan: 称皮重
   *.D_MValue,D_MDate,D_MMan: 称毛重
   *.D_YTime,D_YMan: 收货时间,验收人,
   *.D_Value,D_KZValue,D_AKValue: 收货量,验收扣除(明扣),暗扣
   *.D_YLine,D_YLineName: 收货通道
   *.D_YSResult: 验收结果
   *.D_OutFact,D_OutMan: 出厂放行
   *.D_BDAX: 是否上传
   *.D_BDNUM: 上传次数
   *.D_RecID: 订单行编码
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32),' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   磁卡表:Card
   *.R_ID:记录编号
   *.C_Card:主卡号
   *.C_Card2,C_Card3:副卡号
   *.C_Owner:持有人标识
   *.C_TruckNo:提货车牌
   *.C_Used:用途(供应,销售,临时)
   *.C_UseTime:使用次数
   *.C_Status:状态(空闲,使用,注销,挂失)
   *.C_Freeze:是否冻结
   *.C_Man:办理人
   *.C_Date:办理时间
   *.C_Memo:备注信息
  -----------------------------------------------------------------------------}

    sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), T_Used Char(1), ' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1),'+
       'T_CompanyID varChar(10),T_XTECB varChar(10),T_VendAccount varChar(20),'+
       'T_Driver varChar(10), T_SaleID varChar(20), T_RecID bigint not null default ((0)),'+
       'T_MatePID varChar(15), T_MateID varChar(15), T_MateName varChar(80),' +
       'T_SrcAddr varChar(150), T_DestAddr varChar(150)' +
       ')';
  {-----------------------------------------------------------------------------
   车辆信息:Truck
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_PY: 车牌拼音
   *.T_Owner: 车主
   *.T_Phone: 联系方式
   *.T_Used: 用途(供应,销售)
   *.T_PrePValue: 预置皮重
   *.T_PrePMan: 预置司磅
   *.T_PrePTime: 预置时间
   *.T_PrePUse: 使用预置
   *.T_MinPVal: 历史最小皮重
   *.T_MaxPVal: 历史最大皮重
   *.T_PValue: 有效皮重
   *.T_PTime: 过皮次数
   *.T_PlateColor: 车牌颜色
   *.T_Type: 车型
   *.T_LastTime: 上次活动
   *.T_Card: 电子标签
   *.T_CardUse: 使用电子签(Y/N)
   *.T_NoVerify: 不校验时间
   *.T_Valid: 是否有效
   *.T_VIPTruck:是否VIP
   *.T_HasGPS:安装GPS(Y/N)
   *.T_CompanyID:公司帐户ID
   *.T_XTECB:车别（自有，外车）
   *.T_VendAccount:供应商账户（填写默认承运商）
   *.T_Driver:司机

   有效平均皮重算法:
   T_PValue = (T_PValue * T_PTime + 新皮重) / (T_PTime + 1)
   //---------------------------短倒业务数据信息--------------------------------
   *.T_MatePID:上个物料编号
   *.T_MateID:物料编号
   *.T_MateName: 物料名称
   *.T_SrcAddr:倒出地址
   *.T_DestAddr:倒入地址
   *.T_SaleID:订单号
   *.T_RecID：订单行编码
   ---------------------------------------------------------------------------//
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_PStation varChar(10), P_MStation varChar(10),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_KZValue $Float,'+
       'P_HisTruck varchar(15), P_HisPValue decimal(15,5),'+
       'P_KWDate datetime)';
  {-----------------------------------------------------------------------------
   过磅记录: Materails
   *.P_ID: 编号
   *.P_Type: 类型(销售,供应,临时)
   *.P_Order: 订单号(供应)
   *.P_Bill: 交货单
   *.P_Truck: 车牌
   *.P_CusID: 客户号
   *.P_CusName: 物料名
   *.P_MID: 物料号
   *.P_MName: 物料名
   *.P_MType: 包,散等
   *.P_LimValue: 票重
   *.P_PValue,P_PDate,P_PMan: 皮重
   *.P_MValue,P_MDate,P_MMan: 毛重
   *.P_FactID: 工厂编号
   *.P_PStation,P_MStation: 称重磅站
   *.P_Direction: 物料流向(进,出)
   *.P_PModel: 过磅模式(标准,配对等)
   *.P_Status: 记录状态
   *.P_Valid: 是否有效
   *.P_PrintNum: 打印次数
   *.P_DelMan,P_DelDate: 删除记录
   *.P_KZValue: 供应扣杂
   *.P_HisTruck: 勘误车号
   *.P_HisPValue: 勘误皮重
   *.P_KWDate: 勘误日期

  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   图片: Picture
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_Mate: 物料
   *.P_Date: 时间
   *.P_Picture: 图片
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer,' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer,'+
       'Z_CenterID Varchar(20),Z_LocationID Varchar(20))';
  {-----------------------------------------------------------------------------
   装车线配置: ZTLines
   *.R_ID: 记录号
   *.Z_ID: 编号
   *.Z_Name: 名称
   *.Z_StockNo: 品种编号
   *.Z_Stock: 品名
   *.Z_StockType: 类型(袋,散)
   *.Z_PeerWeight: 袋重
   *.Z_QueueMax: 队列大小
   *.Z_VIPLine: VIP通道
   *.Z_Valid: 是否有效
   *.Z_Index: 顺序索引
   *.Z_CenterID: 生产线
   *.Z_LocationID: 仓库
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0,' +
       'T_PDate DateTime, T_IsPound Char(1),T_HKBills varChar(200))';
  {-----------------------------------------------------------------------------
   待装车队列: ZTTrucks
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_StockNo: 品种编号
   *.T_Stock: 品种名称
   *.T_Type: 品种类型(D,S)
   *.T_Line: 所在道
   *.T_Index: 顺序索引
   *.T_InTime: 入队时间
   *.T_InFact: 进厂时间
   *.T_InQueue: 上屏时间
   *.T_InLade: 提货时间
   *.T_VIP: 特权
   *.T_Bill: 提单号
   *.T_Valid: 是否有效
   *.T_Value: 提货量
   *.T_PeerWeight: 袋重
   *.T_Total: 总装袋数
   *.T_Normal: 正常袋数
   *.T_BuCha: 补差袋数
   *.T_PDate: 过磅时间
   *.T_IsPound: 需过磅(Y/N)
   *.T_HKBills: 合卡交货单列表
  -----------------------------------------------------------------------------}

  sSQL_NewDataTemp = 'Create Table $Table(T_SysID varChar(15))';
  {-----------------------------------------------------------------------------
   临时数据表: DataTemp
   *.T_SysID: 系统编号
  -----------------------------------------------------------------------------}
  
  sSQL_NewInvoiceWeek = 'Create Table $Table(W_ID $Inc, W_NO varChar(15),' +
       'W_Name varChar(50), W_Begin DateTime, W_End DateTime,' +
       'W_Man varChar(32), W_Date DateTime, W_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   发票结算周期:InvoiceWeek
   *.W_ID:记录编号
   *.W_NO:周期编号
   *.W_Name:名称
   *.W_Begin:开始
   *.W_End:结束
   *.W_Man:创建人
   *.W_Date:创建时间
   *.W_Memo:备注信息
  -----------------------------------------------------------------------------}
  
  sSQL_NewInvoice = 'Create Table $Table(I_ID varChar(25) PRIMARY KEY,' +
       'I_Week varChar(15), I_CusID varChar(15), I_Customer varChar(80),' +
       'I_SaleID varChar(15), I_SaleMan varChar(50), I_Status Char(1),' +
       'I_Flag Char(1), I_InMan varChar(32), I_InDate DateTime,' +
       'I_OutMan varChar(32), I_OutDate DateTime, I_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   发票票据:Invoice
   *.I_ID:编号
   *.I_Week:结算周期
   *.I_CusID:客户编号
   *.I_Customer:客户名
   *.I_SaleID:业务员号
   *.I_SaleMan:业务员
   *.I_Status:状态
   *.I_Flag:标记
   *.I_InMan:录入人
   *.I_InDate:录入日期
   *.I_OutMan:领用人
   *.I_OutDate:领用日期
   *.I_Memo:备注
  -----------------------------------------------------------------------------}

  sSQL_NewInvoiceDtl = 'Create Table $Table(D_ID $Inc, D_Invoice varChar(25),' +
       'D_Type Char(1), D_Stock varChar(30), D_Price $Float Default 0,' +
       'D_Value $Float Default 0, D_KPrice $Float Default 0,' +
       'D_DisCount $Float Default 0, D_DisMoney $Float Default 0)';
  {-----------------------------------------------------------------------------
   发票明细:InvoiceDetail
   *.D_ID:编号
   *.D_Invoice:票号
   *.D_Type:类型(带,散)
   *.D_Stock:品种
   *.D_Price:单价
   *.D_Value:开票量
   *.D_KPrice:开票价
   *.D_DisCount:折扣比
   *.D_DisMoney:折扣钱数
  -----------------------------------------------------------------------------}

  sSQL_NewInvoiceReq = 'Create Table $Table(R_ID $Inc, R_Week varChar(15),' +
       'R_CusID varChar(15), R_Customer varChar(80),' +
       'R_SaleID varChar(15), R_SaleMan varChar(50), R_Type Char(1),' +
       'R_Stock varChar(30), R_Price $Float, R_Value $Float, ' +
       'R_PreHasK $Float Default 0, R_ReqValue $Float, R_KPrice $Float,' +
       'R_KValue $Float Default 0, R_KOther $Float Default 0,' +
       'R_Man varChar(32), R_Date DateTime)';
  {-----------------------------------------------------------------------------
   发票结算申请:InvoiceReq
   *.R_ID:记录编号
   *.R_Week:结算周期
   *.R_CusID:客户号
   *.R_Customer:客户名
   *.R_SaleID:业务员号
   *.R_SaleMan:业务员名
   *.R_Type:水泥类型(D,S)
   *.R_Stock:水泥名称
   *.R_Price:单价
   *.R_Value:提货量
   *.R_PreHasK:之前已开量
   *.R_ReqValue:申请量
   *.R_KPrice:开票单价
   *.R_KValue:申请已完成量
   *.R_KOther:本周申请量之外已开
   *.R_Man:申请人
   *.R_Date:申请时间
  -----------------------------------------------------------------------------}

  sSQL_NewWXLog = 'Create Table $Table(R_ID $Inc, L_UserID varChar(50), ' +
       'L_Data varChar(2000), L_MsgID varChar(20), L_Result varChar(150),' +
       'L_Count Integer Default 0, L_Status Char(1), ' +
       'L_Comment varChar(100), L_Date DateTime)';
  {-----------------------------------------------------------------------------
   微信发送日志:WeixinLog
   *.R_ID:记录编号
   *.L_UserID: 接收者ID
   *.L_Data:微信数据
   *.L_Count:发送次数
   *.L_MsgID: 微信返回标识
   *.L_Result:发送返回信息
   *.L_Status:发送状态(N待发送,I发送中,Y已发送)
   *.L_Comment:备注
   *.L_Date: 发送时间
  -----------------------------------------------------------------------------}

  sSQL_NewWXMatch = 'Create Table $Table(R_ID $Inc, M_ID varChar(15), ' +
       'M_WXID varChar(50), M_WXName varChar(64), M_WXFactory varChar(15), ' +
       'M_IsValid Char(1), M_Comment varChar(100), ' +
       'M_AttentionID varChar(32), M_AttentionType Char(1))';
  {-----------------------------------------------------------------------------
   微信账户:WeixinMatch
   *.R_ID:记录编号
   *.M_ID: 微信编号
   *.M_WXID:开发ID
   *.M_WXName:微信名
   *.M_WXFactory:微信注册工厂编码
   *.M_IsValid: 是否有效
   *.M_Comment: 备注             
   *.M_AttentionID,M_AttentionType: 微信关注客户ID,类型(S、业务员;C、客户;G、管理员)
  -----------------------------------------------------------------------------}

  sSQL_NewWXTemplate = 'Create Table $Table(R_ID $Inc, W_Type varChar(15), ' +
       'W_TID varChar(50), W_TFields varChar(64), ' +
       'W_TComment Char(300), W_IsValid Char(1))';
  {-----------------------------------------------------------------------------
   微信账户:WeixinMatch
   *.R_ID:记录编号
   *.W_Type:类型
   *.W_TID:标识
   *.W_TFields:数据域段
   *.W_IsValid: 是否有效
   *.W_TComment: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   供应商: Provider
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_PY: 拼音简写
   *.P_Phone: 联系方式
   *.P_Saler: 业务员
   *.P_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(R_ID $Inc, M_ID varChar(32),' +
       'M_Name varChar(80),M_PY varChar(80),M_Unit varChar(20),M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50),'+
       'M_GroupID varChar(20), M_CenterID varChar(20),M_Weighning char(1))';
  {-----------------------------------------------------------------------------
   物料表: Materails
   *.M_ID: 编号
   *.M_Name: 名称
   *.M_PY: 拼音简写
   *.M_Unit: 单位
   *.M_PrePValue: 预置皮重
   *.M_PrePTime: 皮重时长(天)
   *.M_Memo: 备注
   *.M_GroupID: 物料组编号
   *.M_CenterID: 生产线编号
   *.M_Weighning: 是否过磅
  -----------------------------------------------------------------------------}

  sSQL_NewStockParam = 'Create Table $Table(P_ID varChar(15), P_Stock varChar(30),' +
       'P_Type Char(1), P_Name varChar(50), P_QLevel varChar(20), P_Memo varChar(50),' +
       'P_MgO varChar(20), P_SO3 varChar(20), P_ShaoShi varChar(20),' +
       'P_CL varChar(20), P_BiBiao varChar(20), P_ChuNing varChar(20),' +
       'P_ZhongNing varChar(20), P_AnDing varChar(20), P_XiDu varChar(20),' +
       'P_Jian varChar(20), P_ChouDu varChar(20), P_BuRong varChar(20),' +
       'P_YLiGai varChar(20), P_Water varChar(20), P_KuangWu varChar(20),' +
       'P_GaiGui varChar(20), P_3DZhe varChar(20), P_28Zhe varChar(20),' +
       'P_3DYa varChar(20), P_28Ya varChar(20))';
  {-----------------------------------------------------------------------------
   品种参数:StockParam
   *.P_ID:记录编号
   *.P_Stock:品名
   *.P_Type:类型(袋,散)
   *.P_Name:等级名
   *.P_QLevel:强度等级
   *.P_Memo:备注
   *.P_MgO:氧化镁
   *.P_SO3:三氧化硫
   *.P_ShaoShi:烧失量
   *.P_CL:氯离子
   *.P_BiBiao:比表面积
   *.P_ChuNing:初凝时间
   *.P_ZhongNing:终凝时间
   *.P_AnDing:安定性
   *.P_XiDu:细度
   *.P_Jian:碱含量
   *.P_ChouDu:稠度
   *.P_BuRong:不溶物
   *.P_YLiGai:游离钙
   *.P_Water:保水率
   *.P_KuangWu:硅酸盐矿物
   *.P_GaiGui:钙硅比
   *.P_3DZhe:3天抗折强度
   *.P_28DZhe:28抗折强度
   *.P_3DYa:3天抗压强度
   *.P_28DYa:28抗压强度
  -----------------------------------------------------------------------------}

  sSQL_NewStockRecord = 'Create Table $Table(R_ID $Inc, R_SerialNo varChar(15),' +
       'R_PID varChar(15),' +
       'R_SGType varChar(20), R_SGValue varChar(20),' +
       'R_HHCType varChar(20), R_HHCValue varChar(20),' +
       'R_MgO varChar(20), R_SO3 varChar(20), R_ShaoShi varChar(20),' +
       'R_CL varChar(20), R_BiBiao varChar(20), R_ChuNing varChar(20),' +
       'R_ZhongNing varChar(20), R_AnDing varChar(20), R_XiDu varChar(20),' +
       'R_Jian varChar(20), R_ChouDu varChar(20), R_BuRong varChar(20),' +
       'R_YLiGai varChar(20), R_Water varChar(20), R_KuangWu varChar(20),' +
       'R_GaiGui varChar(20),' +
       'R_3DZhe1 varChar(20), R_3DZhe2 varChar(20), R_3DZhe3 varChar(20),' +
       'R_28Zhe1 varChar(20), R_28Zhe2 varChar(20), R_28Zhe3 varChar(20),' +
       'R_3DYa1 varChar(20), R_3DYa2 varChar(20), R_3DYa3 varChar(20),' +
       'R_3DYa4 varChar(20), R_3DYa5 varChar(20), R_3DYa6 varChar(20),' +
       'R_28Ya1 varChar(20), R_28Ya2 varChar(20), R_28Ya3 varChar(20),' +
       'R_28Ya4 varChar(20), R_28Ya5 varChar(20), R_28Ya6 varChar(20),' +
       'R_Date DateTime, R_Man varChar(32),'+
       'R_BatQuaStart varchar(20) not null default(''0''),'+
       'R_BatQuaEnd varchar(20) not null default(''0''),'+
       'R_BatValid char(1) not null default(''Y''),'+
       'R_ZMJNAME varChar(20), R_ZMJVALUE varChar(20),'+
       'R_C3S varChar(20), R_C3A varChar(20),'+
       'R_SHR3D varChar(20), R_SHR7D varChar(20),'+
       'R_C2S varChar(20),R_CenterID varChar(20))';
  {-----------------------------------------------------------------------------
   检验记录:StockRecord
   *.R_ID:记录编号
   *.R_SerialNo:水泥编号
   *.R_PID:品种参数
   *.R_SGType: 石膏种类
   *.R_SGValue: 石膏掺入量
   *.R_HHCType: 混合材料类
   *.R_HHCValue: 混合材掺入量
   *.R_MgO:氧化镁
   *.R_SO3:三氧化硫
   *.R_ShaoShi:烧失量
   *.R_CL:氯离子
   *.R_BiBiao:比表面积
   *.R_ChuNing:初凝时间
   *.R_ZhongNing:终凝时间
   *.R_AnDing:安定性
   *.R_XiDu:细度
   *.R_Jian:碱含量
   *.R_ChouDu:稠度
   *.R_BuRong:不溶物
   *.R_YLiGai:游离钙
   *.R_Water:保水率
   *.R_KuangWu:硅酸盐矿物
   *.R_GaiGui:钙硅比
   *.R_3DZhe1:3天抗折强度1
   *.R_3DZhe2:3天抗折强度2
   *.R_3DZhe3:3天抗折强度3
   *.R_28Zhe1:28抗折强度1
   *.R_28Zhe2:28抗折强度2
   *.R_28Zhe3:28抗折强度3
   *.R_3DYa1:3天抗压强度1
   *.R_3DYa2:3天抗压强度2
   *.R_3DYa3:3天抗压强度3
   *.R_3DYa4:3天抗压强度4
   *.R_3DYa5:3天抗压强度5
   *.R_3DYa6:3天抗压强度6
   *.R_28Ya1:28抗压强度1
   *.R_28Ya2:28抗压强度2
   *.R_28Ya3:28抗压强度3
   *.R_28Ya4:28抗压强度4
   *.R_28Ya5:28抗压强度5
   *.R_28Ya6:28抗压强度6
   *.R_Date:取样日期
   *.R_Man:录入人
   *.R_ZMJNAME: 助磨剂名称
   *.R_ZMJVALUE: 助磨剂量
   *.R_C3S: 矿物C3S
   *.R_C3A: 矿物C3A
   *.R_SHR3D: 水化热3D
   *.R_SHR7D；水化热7D
   *.R_C2S: 矿物C2S
   *.R_CenterID: 生产线ID
  -----------------------------------------------------------------------------}

  sSQL_NewStockHuaYan = 'Create Table $Table(H_ID $Inc, H_No varChar(15),' +
       'H_Custom varChar(15), H_CusName varChar(80), H_SerialNo varChar(15),' +
       'H_Truck varChar(15), H_Value $Float, H_BillDate DateTime,' +
       'H_EachTruck Char(1), H_ReportDate DateTime, H_Reporter varChar(32))';
  {-----------------------------------------------------------------------------
   开化验单:StockHuaYan
   *.H_ID:记录编号
   *.H_No:化验单号
   *.H_Custom:客户编号
   *.H_CusName:客户名称
   *.H_SerialNo:水泥编号
   *.H_Truck:提货车辆
   *.H_Value:提货量
   *.H_BillDate:提货日期
   *.H_EachTruck: 随车开单
   *.H_ReportDate:报告日期
   *.H_Reporter:报告人
  -----------------------------------------------------------------------------}
  sSQL_NewBindInfo = 'Create Table $Table(ID $Inc, Phone varChar(30),' +
       'Factory varChar(50), ToUser varChar(50), IsBind Char(1),' +
       'ErrCode int, ErrMsg varChar(30), BindDate DateTime)';
  {-----------------------------------------------------------------------------
   工厂绑定用户：W_BindInfo
   *.ID:记录编号（自增长）
   *.Phone：手机号码
   *.Factory：工厂ID
   *.ToUser：绑定用户ID
   *.IsBind：绑定类型（绑定、解绑）
   *.ErrCode：返回码
   *.ErrMsg：返回结果
   *.BindDate：绑定日期
  -----------------------------------------------------------------------------}

  sSQL_NewCustomerInfo = 'Create Table $Table(ID $Inc, ErrCode int,' +
       'ErrMsg varChar(30), Factory varChar(50), Phone varChar(20),' +
       'AppId varChar(30), BindCustomerId varChar(50), NamePinYin varChar(30),' +
       'Email varChar(30), OpenId varChar(30), BindDate DateTime)';
  {-----------------------------------------------------------------------------
   获取微信公众号客户信息：W_CustomerInfo
   *.ID：记录编号（自增长）
   *.ErrCode：返回码
   *.ErrMsg：返回消息
   *.Factory：工厂ID
   *.Phone：手机号码
   *.AppId：
   *.BindCustomerId：绑定客户ID
   *.NamePinYin：客户姓名全拼
   *.Email：电子邮箱
   *.OpenId：
   *.BindDate：绑定日期
  -----------------------------------------------------------------------------}
  sSQL_NewInventDim = 'Create Table $Table(ID $Inc, I_DimID varChar(20),' +
       'I_BatchID varChar(20), I_WMSLocationID varChar(10), I_SerialID varChar(20),' +
       'I_LocationID varChar(20), I_DatareaID varChar(4), I_RecVersion int,' +
       'I_RECID bigint, I_CenterID varChar(20))';
  {-----------------------------------------------------------------------------
   维度信息表：Sys_InventDim
   *.ID：自增长ID
   *.I_DimID：
   *.I_BatchID：
   *.I_WMSLocationID：
   *.I_SerialID：
   *.I_LocationID：
   *.I_DatareaID：
   *.I_RecVersion：
   *.I_RECID：
   *.I_CenterID：
  -----------------------------------------------------------------------------}
  sSQL_NewInventCenter ='Create Table $Table(ID $Inc, I_CenterID varChar(20),' +
       'I_Name varChar(60), I_DataReaID varChar(4))';
  {-----------------------------------------------------------------------------
   生产线基础表：Sys_InventCenter
   *.ID：自增长ID
   *.I_CenterID：生产线编号
   *.I_Name：生产线名称
   *.I_DataReaID：公司账套
  -----------------------------------------------------------------------------}
  sSQL_NewInvCenGroup ='Create Table $Table(ID $Inc, G_ItemGroupID varChar(20),' +
       'G_InventCenterID varChar(60), DataAreaID varChar(3))';
  {-----------------------------------------------------------------------------
   物料组生产线：sys_InvCenGroup
   *.ID：自增长ID
   *.G_ItemGroupID：物料组ID
   *.G_InventCenterID：生产线ID
   *.DataAreaID：公司账套
  -----------------------------------------------------------------------------}
  sSQL_NewInventLocation ='Create Table $Table(ID $Inc, I_LocationID varChar(20),' +
       'I_Name varChar(60), I_DataReaID varChar(4))';
  {-----------------------------------------------------------------------------
   仓库基础表：Sys_InventLocation
   *.ID：自增长ID
   *.I_LocationID：仓库编号
   *.I_Name：仓库名称
   *.I_DataReaID：公司账套
  -----------------------------------------------------------------------------}
  sSQL_NewAddTreaty ='Create Table $Table(ID $Inc, A_SalesId varChar(20),' +
       'A_XTEadjustBillNum varChar(20), A_ItemId varChar(60), '+
       'A_SalesNewAmount numeric(28, 12),A_TakeEffectDate DateTime,'+
       'A_TakeEffectTime int not null default((1)), '+
       'RefRecid bigint not null default ((0)),'+
       'Recid bigint not null default ((0)),'+
       'DataAreaID varChar(3) not null default (''dat''),'+
       'A_Date datetime)';
  {-----------------------------------------------------------------------------
   补充协议表：Sys_AddTreaty
   *.ID：自增长ID
   *.A_SalesId：销售订单号
   *.A_XTEadjustBillNum：补充协议单号
   *.A_ItemId：物料编号
   *.A_SalesNewAmount: 调整价格
   *.A_TakeEffectDate: 生效日期
   *.A_TakeEffectTime: 生效时间
   *.DataAreaID: 账套
   *.RefRecid: 销售订单行关联ID
   *.Recid: 行编号
   *.A_Date: 创建/更新日期
  -----------------------------------------------------------------------------}
  sSQL_NewEmployees = 'Create Table $Table(ID $Inc, EmplId varChar(10),' +
       'EmplName varChar(60), '+
       'DataAreaID varChar(3) not null default (''dat''))';
  {-----------------------------------------------------------------------------
   员工信息表：Sys_Employees
   *.EmplId: 员工编号
   *.EmplName：员工姓名
   *.DataAreaID：账套
  -----------------------------------------------------------------------------}
  sSQL_NewPoundWucha = 'Create Table $Table(ID $Inc, W_Type Char(1),' +
       'W_StartValue $Float, W_EndValue $Float, '+
       'W_ZValue $Float, W_FValue $Float, W_Memo varChar(60), '+
       'W_Date datetime)';
  {-----------------------------------------------------------------------------
   称重误差参数表：Sys_PoundWuCha
   *.W_Type: 类型 1 水泥 2 其它
   *.W_StartValue：开始吨位
   *.W_EndValue：结束吨位
   *.W_ZValue：正误差值
   *.W_FValue：负误差值
   *.W_Memo：备注
   *.W_Date: 操作日期
  -----------------------------------------------------------------------------}
  sSQL_NewPoundDevia = 'Create Table $Table(R_ID $Inc, D_Bill varChar(20),' +
       'D_Truck varChar(20), D_CusID varChar(32), D_CusName varChar(80), '+
       'D_StockName varChar(80), '+
       'D_PlanValue $Float, D_JValue $Float, D_DeviaValue $Float, '+
       'D_Memo varChar(80), D_Date datetime)';
  {-----------------------------------------------------------------------------
   称重误差参数表：Sys_PoundDevia
   *.D_Bill: 提货单号
   *.D_Truck：车号
   *.D_CusID：客户ID
   *.D_CusName：客户名称
   *.D_StockName：水泥名称
   *.D_PlanValue: 票重
   *.D_JValue: 净重
   *.D_DeviaValue: 误差值
   *.D_Memo：备注
   *.D_Date: 操作日期
  -----------------------------------------------------------------------------}
  sSQL_NewZTWorkSet = 'Create Table $Table(R_ID $Inc, Z_WorkOrder varchar(20),' +
       'Z_StartTime time(7), Z_EndTime time(7), Z_Date datetime)';
  {-----------------------------------------------------------------------------
   栈台班别设置表：S_ZTWorkSet
   *.Z_WorkOrder: 班别
   *.Z_StartTime：开始时间
   *.Z_EndTime：结束时间
   *.Z_Date: 操作日期
  -----------------------------------------------------------------------------}
  sSQL_NewInOutFatory = 'Create Table $Table(R_ID $Inc, I_Card varChar(16),I_Truck varChar(20),' +
       'I_CusName varChar(80), I_Context varChar(100), I_Memo varChar(200), '+
       'I_Man varChar(20),I_Date datetime, I_InDate datetime, I_OutDate datetime)';
  {-----------------------------------------------------------------------------
   临时卡进厂出厂表：L_InOutFactory
   *.I_Card: 卡号
   *.I_Truck：车号
   *.I_CusName：客户名称
   *.I_Context：内容
   *.I_Memo：备注
   *.I_Man: 操作人
   *.I_Date: 操作日期
   *.I_InDate: 进厂日期
   *.I_OutDate: 出厂日期
  -----------------------------------------------------------------------------}
  sSQL_NewKuWei = 'Create Table $Table(R_ID $Inc, K_Type varChar(16),' +
       'K_LocationID varChar(20), K_KuWeiNo varChar(50), K_Date datetime)';
  {-----------------------------------------------------------------------------
   库位设置表：Sys_KuWei
   *.K_Type: 类型  （袋装、散装、熟料）
   *.K_LocationID: 仓库ID
   *.K_KuWeiNo：库位
   *.K_Date；操作日期
  -----------------------------------------------------------------------------}
  sSQL_NewCompanyArea = 'Create Table $Table(R_ID $Inc, C_XSQYBM varChar(20),' +
       'C_XSQYMC varChar(20), C_XSGSDM varChar(20), C_XSGSMC varChar(20),'+
       'C_XTESALESAREATYPE int,C_ISVALID int,C_RECVERSION int,C_RECID bigint)';
  {-----------------------------------------------------------------------------
   销售区域表：Sys_CompanyArea
   *.C_XSQYBM: 销售区域编码
   *.C_XSQYMC：销售区域名称
   *.C_XSGSDM；销售公司编码
   *.C_XSGSMC: 销售公司名称
  -----------------------------------------------------------------------------}
  sSQL_NewTransfer = 'Create Table $Table(R_ID $Inc, T_ID varChar(20),' +
       'T_Card varChar(16), T_Truck varChar(15), T_PID varChar(15),' +
       'T_SrcAddr varChar(160), T_DestAddr varChar(160),' +
       'T_Type Char(1), T_StockNo varChar(32), T_StockName varChar(160),' +
       'T_PValue $Float, T_PDate DateTime, T_PMan varChar(32),' +
       'T_MValue $Float, T_MDate DateTime, T_MMan varChar(32),' +
       'T_Value $Float, T_Man varChar(32), T_Date DateTime,' +
       'T_DelMan varChar(32), T_DelDate DateTime, T_Memo varChar(500),' +
       'T_DDAX Char(1), T_SyncNum Integer Default 0, T_SyncDate DateTime, T_SyncMemo varChar(500),'+
       'T_BID varChar(20), T_BRecID bigint not null default ((0)))';
  {-----------------------------------------------------------------------------
   入厂表: Transfer
   *.R_ID: 编号
   *.T_ID: 短倒业务号
   *.T_PID: 磅单编号
   *.T_Card: 磁卡号
   *.T_Truck: 车牌号
   *.T_SrcAddr:倒出地点
   *.T_DestAddr:倒入地点
   *.T_Type: 类型(袋,散)
   *.T_StockNo: 物料编号
   *.T_StockName: 物料描述
   *.T_PValue,T_PDate,T_PMan: 称皮重
   *.T_MValue,T_MDate,T_MMan: 称毛重
   *.T_Value: 收货量
   *.T_Man,T_Date: 单据信息
   *.T_DelMan,T_DelDate: 删除信息
   *.T_DDAX, T_SyncNum, T_SyncDate, T_SyncMemo: 同步次数; 同步完成时间; 同步信息
   *.T_BID: 订单编号
   *.T_BRecID: 行编码
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 数据查询
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   从数据字典读取数据
   *.$Table:数据字典表
   *.$Name:字典项名称
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   从扩展信息表读取数据
   *.$Table:扩展信息表
   *.$Group:分组名称
   *.$ID:信息标识
  -----------------------------------------------------------------------------}

function CardStatusToStr(const nStatus: string): string;
//磁卡状态
function TruckStatusToStr(const nStatus: string): string;
//车辆状态
function BillTypeToStr(const nType: string): string;
//订单类型
function PostTypeToStr(const nPost: string): string;
//岗位类型

implementation

//Desc: 将nStatus转为可读内容
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '空闲' else
  if nStatus = sFlag_CardUsed then Result := '正常' else
  if nStatus = sFlag_CardLoss then Result := '挂失' else
  if nStatus = sFlag_CardInvalid then Result := '注销' else Result := '未知';
end;

//Desc: 将nStatus转为可识别的内容
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '进厂' else
  if nStatus = sFlag_TruckOut then Result := '出厂' else
  if nStatus = sFlag_TruckBFP then Result := '称皮重' else
  if nStatus = sFlag_TruckBFM then Result := '称毛重' else
  if nStatus = sFlag_TruckSH then Result := '送货中' else
  if nStatus = sFlag_TruckXH then Result := '验收处' else
  if nStatus = sFlag_TruckFH then Result := '放灰处' else
  if nStatus = sFlag_TruckZT then Result := '栈台' else Result := '未进厂';
end;

//Desc: 交货单类型转为可识别内容
function BillTypeToStr(const nType: string): string;
begin
  if nType = sFlag_TypeShip then Result := '船运' else
  if nType = sFlag_TypeZT   then Result := '栈台' else
  if nType = sFlag_TypeVIP  then Result := 'VIP' else Result := '普通';
end;

//Desc: 将岗位转为可识别内容
function PostTypeToStr(const nPost: string): string;
begin
  if nPost = sFlag_TruckIn   then Result := '门卫进厂' else
  if nPost = sFlag_TruckOut  then Result := '门卫出厂' else
  if nPost = sFlag_TruckBFP  then Result := '磅房称皮' else
  if nPost = sFlag_TruckBFM  then Result := '磅房称重' else
  if nPost = sFlag_TruckFH   then Result := '散装放灰' else
  if nPost = sFlag_TruckZT   then Result := '袋装栈台' else Result := '厂外';
end;

//------------------------------------------------------------------------------
//Desc: 添加系统表项
procedure AddSysTableItem(const nTable,nNewSQL,nNewSQL1: String);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL+nNewSQL1;
end;

//Desc: 系统表
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict,'');
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo,'');
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog,'');

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo,'');
  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase,'');
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus,'');
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch,'');
  AddSysTableItem(sTable_WorkePC, sSQL_NewWorkePC,'');

  AddSysTableItem(sTable_Customer, sSQL_NewCustomer,'');
  AddSysTableItem(sTable_Salesman, sSQL_NewSalesMan,'');
  AddSysTableItem(sTable_SaleContract, sSQL_NewSaleContract,'');
  AddSysTableItem(sTable_SContractExt, sSQL_NewSContractExt,'');

  AddSysTableItem(sTable_CusAccount, sSQL_NewCusAccount,'');
  AddSysTableItem(sTable_InOutMoney, sSQL_NewInOutMoney,'');
  AddSysTableItem(sTable_CusCredit, sSQL_NewCusCredit,'');
  AddSysTableItem(sTable_SysShouJu, sSQL_NewSysShouJu,'');

  AddSysTableItem(sTable_InvoiceWeek, sSQL_NewInvoiceWeek,'');
  AddSysTableItem(sTable_Invoice, sSQL_NewInvoice,'');
  AddSysTableItem(sTable_InvoiceDtl, sSQL_NewInvoiceDtl,'');
  AddSysTableItem(sTable_InvoiceReq, sSQL_NewInvoiceReq,'');
  AddSysTableItem(sTable_InvReqtemp, sSQL_NewInvoiceReq,'');
  AddSysTableItem(sTable_DataTemp, sSQL_NewDataTemp,'');

  AddSysTableItem(sTable_WeixinLog, sSQL_NewWXLog,'');
  AddSysTableItem(sTable_WeixinMatch, sSQL_NewWXMatch,'');
  AddSysTableItem(sTable_WeixinTemp, sSQL_NewWXTemplate,'');

  AddSysTableItem(sTable_ZhiKa, sSQL_NewZhiKa,'');
  AddSysTableItem(sTable_ZhiKaDtl, sSQL_NewZhiKaDtl,'');
  AddSysTableItem(sTable_Card, sSQL_NewCard,'');
  AddSysTableItem(sTable_Bill, sSQL_NewBill, sSQL_NewBill1);
  AddSysTableItem(sTable_BillBak, sSQL_NewBill, sSQL_NewBill1);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck,'');
  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines,'');
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks,'');
  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog,'');
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog,'');
  AddSysTableItem(sTable_Picture, sSQL_NewPicture,'');
  AddSysTableItem(sTable_Provider, ssql_NewProvider,'');
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails,'');

  AddSysTableItem(sTable_StockParam, sSQL_NewStockParam,'');
  AddSysTableItem(sTable_StockParamExt, sSQL_NewStockRecord,'');
  AddSysTableItem(sTable_StockRecord, sSQL_NewStockRecord,'');
  AddSysTableItem(sTable_StockHuaYan, sSQL_NewStockHuaYan,'');

  AddSysTableItem(sTable_Order, sSQL_NewOrder,'');
  AddSysTableItem(sTable_OrderBak, sSQL_NewOrder,'');
  AddSysTableItem(sTable_OrderDtl, sSQL_NewOrderDtl,'');
  AddSysTableItem(sTable_OrderDtlBak, sSQL_NewOrderDtl,'');
  AddSysTableItem(sTable_OrderBaseMain, sSQL_NewOrdBaseMain,'');
  AddSysTableItem(sTable_OrderBase, sSQL_NewOrderBase,'');
  AddSysTableItem(sTable_OrderBaseBak, sSQL_NewOrderBase,'');
  AddSysTableItem(sTable_Deduct, sSQL_NewDeduct,'');
  AddSysTableItem(sTable_BindInfo, sSQL_NewBindInfo,'');
  AddSysTableItem(sTable_CustomerInfo, sSQL_NewCustomerInfo,'');

  AddSysTableItem(sTable_InventDim, sSQL_NewInventDim,'');
  AddSysTableItem(sTable_InventCenter, sSQL_NewInventCenter,'');
  AddSysTableItem(sTable_InventLocation, sSQL_NewInventLocation,'');
  AddSysTableItem(sTable_CusContCredit, sSQL_NewCusConCredit,'');
  AddSysTableItem(sTable_CustPresLog, sSQL_NewCustPresLog,'');
  AddSysTableItem(sTable_AddTreaty, sSQL_NewAddTreaty,'');
  AddSysTableItem(sTable_ContPresLog, sSQL_NewContPresLog,'');
  AddSysTableItem(sTable_InvCenGroup, sSQL_NewInvCenGroup,'');
  AddSysTableItem(sTable_EMPL, sSQL_NewEmployees,'');
  AddSysTableItem(sTable_PoundWucha, sSQL_NewPoundWucha,'');
  AddSysTableItem(sTable_PoundDevia, sSQL_NewPoundDevia,'');
  AddSysTableItem(sTable_ZTWorkSet, sSQL_NewZTWorkSet,'');
  AddSysTableItem(sTable_InOutFatory, sSQL_NewInOutFatory,'');
  AddSysTableItem(sTable_KuWei, sSQL_NewKuWei,'');
  AddSysTableItem(sTable_CompanyArea, sSQL_NewCompanyArea, '');

  AddSysTableItem(sTable_Transfer, sSQL_NewTransfer,'');
  AddSysTableItem(sTable_TransferBak, sSQL_NewTransfer,'');
end;

//Desc: 清理系统表
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


