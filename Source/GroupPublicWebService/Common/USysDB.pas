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

  {*相关标记*}
  sFlag_Yes           = 'Y';                         //是
  sFlag_No            = 'N';                         //否
  sFlag_Unknow        = 'U';                         //未知        
  sFlag_Enabled       = 'Y';                         //启用
  sFlag_Disabled      = 'N';                         //禁用

  sFlag_Integer       = 'I';                         //整数
  sFlag_Decimal       = 'D';                         //小数

  sFlag_NotMatter     = '@';                         //无关编号(任意编号都可)
  sFlag_ForceDone     = '#';                         //强制完成(未完成前不换)
  sFlag_FixedNo       = '$';                         //指定编号(使用相同编号)

  sFlag_Provide       = 'P';                         //供应
  sFlag_Sale          = 'S';                         //销售
  sFlag_Other         = 'O';                         //其它

  sFlag_Dai           = 'D';                         //袋装
  sFlag_PoundDai      = 'P';                         //袋装(磅房标记)
  sFlag_San           = 'S';                         //散装
  sFlag_PoundSan      = 'B';                         //散装(磅房标记)

  sFlag_PoundBZ       = 'B';                         //标准
  sFlag_PoundPZ       = 'Z';                         //皮重
  sFlag_PoundPD       = 'P';                         //配对
  sFlag_PoundCC       = 'C';                         //出厂(过磅模式)

  sFlag_XS            = 'X';                         //销售
  sFlag_ZC            = 'Z';                         //转储

  sFlag_TiHuo         = 'T';                         //自提
  sFlag_SongH         = 'S';                         //送货
  sFlag_XieH          = 'X';                         //运卸

  sFlag_BillNew       = 'N';                         //新单
  sFlag_BillEdit      = 'E';                         //修改
  sFlag_BillDel       = 'D';                         //删除
  sFlag_BillLading    = 'L';                         //提货中
  sFlag_BillPick      = 'P';                         //拣配
  sFlag_BillPost      = 'G';                         //过账
  sFlag_BillDone      = 'O';                         //完成
  sFlag_BillZRE       = 'ZRE';                       //退货订单
  sFlag_BillZLR       = 'ZLR';                       //退货交货单 ZLR       //TANXIN 2013-03-21
  sFlag_BillZNR1       = 'ZNR1';                     //退货交货单 ZNR1
  sFlag_BillZNR2       = 'ZNR2';                     //退货交货单 ZNR2
  sFlag_BillZNR3       = 'ZNR3';                     //退货交货单 ZNR3
  sFlag_BillZRL1       = 'ZRL1';                     //退货交货单 ZRL1
  sFlag_BillZRL2       = 'ZRL2';                     //退货交货单 ZRL2
  sFlag_BillZRL3       = 'ZRL3';                     //退货交货单 ZRL3

  sFlag_TypeShip      = 'S';                         //船运
  sFlag_TypeZT        = 'Z';                         //栈台
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //普通,订单类型

  sFlag_TruckNone     = 'N';                         //无状态车辆
  sFlag_TruckIn       = 'I';                         //进厂车辆
  sFlag_TruckOut      = 'O';                         //出厂车辆
  sFlag_TruckBFP      = 'P';                         //磅房皮重车辆
  sFlag_TruckBFM      = 'M';                         //磅房毛重车辆
  sFlag_TruckSH       = 'S';                         //送货车辆
  sFlag_TruckFH       = 'F';                         //放灰车辆
  sFlag_TruckZT       = 'Z';                         //栈台车辆
  sFlag_TruckMIT      = 'T';                         //更新至MIT
  sFlag_TruckSAP      = 'A';                         //更新至SAP

  sFlag_CardIdle      = 'I';                         //空闲卡
  sFlag_CardUsed      = 'U';                         //使用中
  sFlag_CardLoss      = 'L';                         //挂失卡
  sFlag_CardInvalid   = 'N';                         //注销卡

  sFlag_SerialSAP     = 'SAPFunction';               //SAP编码组
  sFlag_SAPMsgNo      = 'SAP_MsgNo';                 //SAP消息号
  sFlag_ForceHint     = 'Bus_HintMsg';               //强制提示

  sFlag_SerailSYS     = 'SYSTableID';                //SYS编码组
  sFlag_TruckLog      = 'SYS_TruckLog';              //车辆记录
  sFlag_PoundLog      = 'SYS_PoundLog';              //过磅记录

  sFlag_SysParam      = 'SysParam';                  //系统参数
  sFlag_Company       = 'Company';                   //公司名
  sFlag_JBTime        = 'JiaoBanTime';               //交班时间
  sFlag_JBParam       = 'JiaoBanParam';              //交班参数
  sFlag_AutoIn        = 'Truck_AutoIn';              //自动进厂
  sFlag_AutoOut       = 'Truck_AutoOut';             //自动出厂
  sFlag_InTimeout     = 'InFactTimeOut';             //进厂超时(队列)
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //袋装禁用队列
  sFlag_NoSanQueue    = 'NoSanQueue';                //散装禁用队列
  sFlag_DelayQueue    = 'DelayQueue';                //延迟排队(厂内)
  sFlag_EnableBakdb   = 'Uses_BackDB';               //备用库
  sFlag_CusType       = 'CustomerType';              //客户类型
  sFlag_SAPSrvURL     = 'SAPServiceURL';
  sFlag_MITSrvURL     = 'MITServiceURL';
  sFlag_CRMSrvURL     = 'CRMServiceURL';             //CRM服务          20130524
  sFlag_CRMMessURL    = 'CRMMessURL';                //CRM短信          20130603
  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_ServerIP      = 'ServerHostIP';              //服务地址
  sFlag_UpdateServer  = 'UpdateServer';              
  sFlag_UpdateUser    = 'UpdateUser';                //升级服务
  sFlag_ViaBillCard   = 'ViaBillCard';               //直接制卡
  sFlag_PrintBill     = 'PrintStockBill';            //需打印订单
  sFlag_NFStock       = 'NoFaHuoStock';              //无发货品种
  sFlag_LineStock     = 'LineStock';                 //通道品种
  sFlag_PoundID       = 'PoundID';                   //磅站编号
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //过磅误差         20130708
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //过磅误差         20130708
  sFlag_PoundWuCha    = 'PoundWuCha';                //过磅误差
  sFlag_PoundWarning  = 'PoundWarning';              //皮重预警         20130703
                                                                 
  sFlag_LoadMaterails = 'LoadMaterails';             //载入物料
  sFlag_PoundIfDai    = 'PoundIFDai';                //袋装过磅
  sFlag_ZYPoint       = 'OrderZYPoint';              //装运点
  sFlag_TruckQueue    = 'TruckQueue';                //车辆队列

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

  sTable_StorLocation = 'S_StockLocation';           //库存点
  sTable_StockMatch   = 'S_StockMatch';              //品种映射
  sTable_Bill         = 'S_Bill';                    //交货单
  sTable_BillInfo     = 'S_BillInfo';                //扩展信息
  sTable_OrderXS      = 'S_OrderXS';                 //销售订单信息
  sTable_OrderZC      = 'S_OrderZC';                 //转储订单信息
  sTable_Card         = 'S_Card';                    //销售磁卡

  sTable_Truck        = 'S_Truck';                   //车辆表
  sTable_TruckLog     = 'S_TruckLog';                //车辆日志

  sTable_Customer     = 'S_Customer';                //客户表
  sTable_Materails    = 'S_Materails';               //物料表
  sTable_PoundLog     = 'S_PoundLog';                //过磅数据
  sTable_PoundBak     = 'S_PoundBak';                //过磅作废

  sTable_ZTLines      = 'S_ZTLines';                 //装车道
  sTable_ZTTrucks     = 'S_ZTTrucks';                //车辆队列
  sTable_ZTTruckLog   = 'S_ZTTruckLog';              //装车纪录

  sTable_Message      = 'M_Message';                 //短信记录         20130605
  sTable_MTime        = 'M_Time';                    //时间设置
  sTable_MUser        = 'M_User';                    //人员设置
  sTable_Template     = 'M_Template';                //短信模板         21030725
  sTable_Definition   = 'M_Definition';              //短信定义         20130725

  {*新建表*}
  sSQL_NewMessage = 'Create Table $Table(L_Note varChar(500), L_Message varChar(500),' +
       'L_Date varChar(50))';
  {-----------------------------------------------------------------------------
   短信记录: M_Message
   *.L_Note: 号码
   *.L_Message: 内容
   *.L_Date: 时间
  -----------------------------------------------------------------------------}
  sSQL_NewMTime = 'Create Table $Table(T_Id $Inc, T_Time varChar(50),' +
       'T_LastTime varChar(50),D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   时间设置: M_MTime
   *.T_Id: 编号
   *.T_Time: 触发时间
   *.T_LastTime: 发送时间
  -----------------------------------------------------------------------------}
  sSQL_NewMUser = 'Create Table $Table(M_Note varChar(50), M_Name varChar(50))';
  {-----------------------------------------------------------------------------
   人员设置: M_MUser
   *.M_Note: 号码
   *.M_Name: 姓名                                              //增加表 20130613
   -----------------------------------------------------------------------------}
  sSQL_NewMDefinition = 'Create Table $Table(D_ID $Inc, D_Definition varChar(50),' +
         'D_SQL varChar(50),D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   宏定义设置: M_Definition
   *.D_ID: 编号
   *.D_Definition: 宏定义
   *.D_SQL: SQL                                                //增加表 20130808
  -----------------------------------------------------------------------------}
  sSQL_NewMTemplate = 'Create Table $Table(T_ID $Inc, T_Template varChar(500),' +
         'D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   模板设置: M_Template
   *.T_ID: 模板编号
   *.T_Template: 模板内容                                      //增加表 20130808
  -----------------------------------------------------------------------------}
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
   *.B_技术部Text: 内容
   *.B_Py: 拼音简写
   *.B_Memo: 备注信息
   *.B_PID: 上级节点
   *.B_Index: 创建顺序
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer)';
  {-----------------------------------------------------------------------------
   串行编号基数表: SerialBase
   *.B_ID: 编号
   *.B_Group: 分组
   *.B_Object: 对象
   *.B_Prefix: 前缀
   *.B_IDLen: 编号长
   *.B_Base: 基数
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(S_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行状态表: SerialStatus
   *.S_ID: 编号
   *.S_Object: 对象
   *.S_SerailID: 串行编号
   *.S_PairID: 配对编号
   *.S_Status: 状态(Y,N)
   *.S_Date: 创建时间
  -----------------------------------------------------------------------------}

  sSQL_NewStorLocation = 'Create Table $Table(L_ID $Inc, L_Name varChar(52),' +
       'L_PY varChar(52), L_Factory varChar(8), L_Locate varChar(8))';
  {-----------------------------------------------------------------------------
   库存点: StockLocation
   *.L_ID: 编号
   *.L_Name: 仓储点
   *.L_PY: 拼音
   *.L_Factory: 工厂编号
   *.L_Locate: 库位
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1))';
  {-----------------------------------------------------------------------------
   相似品种映射: StockMatch
   *.R_ID: 记录编号
   *.M_Group: 仓储点
   *.M_ID: 物料号
   *.M_Name: 物料名称
   *.M_Status: 状态
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16), L_Type Char(1), L_Stock varChar(80),' +
       'L_StockNo varChar(20), L_Truck varChar(50), L_TruckID varChar(15),' +
       'L_Value $Float, L_CusType varChar(8), L_CusID varChar(20),' +
       'L_CusName varChar(82), L_CusPY varChar(82),' +
       'L_Order Char(1), L_OrderID varChar(20),' +
       'L_Seal varChar(100), L_IsVIP varChar(1),' +
       'L_Man varChar(32), L_Date DateTime,' +
       'L_PickDate DateTime, L_PickMan varChar(32),' +
       'L_PostDay varChar(10), L_PostDate DateTime, L_PostMan varChar(32),' +
       'L_FactNum varChar(8), L_OutNum varChar(35), L_OutFact DateTime,' +
       'L_Status Char(1), L_Action Char(1), L_Result Char(1),' +
       'L_ExtInfo Integer Default 0, L_ExtRes Integer Default 0,' +
       'L_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   交货单表: Bill
   *.R_ID: 编号
   *.L_ID: 提单号
   *.L_Card: 磁卡号
   *.L_Type: 类型(袋,散)
   *.L_Stock: 物料描述
   *.L_StockNo: 物料编号
   *.L_Truck: 车船号
   *.L_TruckID: 提货记录
   *.L_Value: 交货量
   *.L_CusType: 客户类型
   *.L_CusID: 客户编号
   *.L_CusName: 客户名称
   *.L_CusPY: 拼音简写
   *.L_Order: 订单类型(销售,转储)
   *.L_OrderID: 订单号
   *.L_Seal: 封签号
   *.L_IsVIP: VIP单
   *.L_Man:操作人
   *.L_Date:创建时间
   *.L_PickDate: 拣配时间
   *.L_PickMan: 拣配人员
   *.L_PostDay: 过账日(周期)
   *.L_PostDate: 过账时间
   *.L_PostMan: 过账人
   *.L_FactNum: 工厂编号
   *.L_OutNum: 出厂编号
   *.L_OutFact: 出厂日期
   *.L_Status: 当前状态
   *.L_Action: 上一动作
   *.L_Result: 动作结果
   *.L_ExtInfo: 扩展载入次数
   *.L_ExtRes: 扩展Response次数
   *.L_Memo: 动作备注
  -----------------------------------------------------------------------------}

  sSQL_NewBillInfo = 'Create Table $Table(R_ID $Inc,VBELN varChar(20),' +
       'LFART varChar(8),VTEXT varChar(40),KUNNR_AG varChar(20),' +
       'NAME1_AG varChar(70),KUNNR_WE varChar(20),NAME1_WE varChar(70),' +
       'KUNNR_RE varChar(20),NAME1_RE varChar(70),KUNNR_RG varChar(20),' +
       'NAME1_RG varChar(70),VSTEL varChar(8),VSEXT varChar(60),' +
       'VKBUR varChar(8),BEZEI20 varChar(40),BZIRK varChar(12),' +
       'BZTXT varChar(40),ZSCDW varChar(40),KDGRP varChar(4),' +
       'KTEXT varChar(40),VSART varChar(4),VSZEI varChar(40),' +
       'ZCODE_QY varChar(10),ZDESC_QY varChar(40),ZCODE_SY varChar(20),' +
       'ZDESC_SY varChar(40),SORT1 varChar(40),SORT2 varChar(40),' +
       'VBELN_CT varChar(20),LIFNR_CT varChar(20),KOQUK varChar(2),' +
       'WBSTK varChar(2),PDSTK varChar(2),FKSTK varChar(2),FKIVK varChar(2),' +

       'POSNR $Float,VBELN_G varChar(20),POSNR_G $Float,VBELN_C varChar(20),' +
       'POSNR_C $Float,LFIMG $Float,MATNR varChar(36),ARKTX varChar(80),' +
       'WERKS varChar(8),NAME1 varChar(60),LGORT varChar(8),' +
       'LGOBE varChar(32),SPART varChar(4),SPEXT varChar(40),MVGR1 varChar(6),' +
       'BEZEI varChar(80),KDMAT varChar(70),CHARG varChar(20),' +
       'VTWEG varChar(4),VTEXT20 varChar(40),ZCCJ $Float)';

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
   *.C_Used:用途(供应,销售)
   *.C_UseTime:使用次数
   *.C_Status:状态(空闲,使用,注销,挂失)
   *.C_Freeze:是否冻结
   *.C_Man:办理人
   *.C_Date:办理时间
   *.C_Memo:备注信息
  -----------------------------------------------------------------------------}

  sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), ' +
       'T_Used Char(1), T_PrePValue $Float, T_PrePMan varChar(32), ' +
       'T_PrePTime DateTime, T_Man varChar(32), T_Valid Char(1))';
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
   *.T_Valid: 是否有效
  -----------------------------------------------------------------------------}

  sSQL_NewTruckLog = 'Create Table $Table(R_ID $Inc, T_ID varChar(15),' +
       'T_Truck varChar(15),T_Status Char(1), T_NextStatus Char(1),' +
       'T_IsHK Char(1),' +
       'T_InTime DateTime, T_InMan varChar(32),' +
       'T_OutTime DateTime, T_OutMan varChar(32),' +
       'T_BFPTime DateTime, T_BFPMan varChar(32), T_BFPValue $Float Default 0,' +
       'T_BFMTime DateTime, T_BFMMan varChar(32), T_BFMValue $Float Default 0,' +
       'T_FHSTime DateTime, T_FHETime DateTime, T_FHLenth Integer,' +
       'T_FHMan varChar(32), T_FHValue Decimal(15,5),' +
       'T_ZTTime DateTime, T_ZTMan varChar(32),' +
       'T_ZTValue $Float,T_ZTCount Integer, T_ZTDiff Integer)';
  {-----------------------------------------------------------------------------
   车辆日志:TruckLog
   *.T_ID:记录编号
   *.T_Truck:车牌号
   *.T_Status,T_NextStatus:状态
   *.T_IsHK: 是否合卡
   *.T_InTime,T_InMan:进厂时间,放行人
   *.T_OutTime,T_OutMan:出厂时间,放行人
   *.T_BFPTime,T_BFPMan,T_BFPValue:皮重时间,操作人,皮重
   *.T_BFMTime,T_BFMMan,T_BFMValue:毛重时间,操作人,毛重
   *.T_FHSTime,T_FHETime,
     T_FHLenth,T_FHMan,T_FHValue:开始时间,结束时间,时长操作人,放灰量
   *.T_ZTTime,T_ZTMan,
     T_ZTValue,T_ZTCount,T_ZTDiff:栈台时间,操作人,提货量,袋数,补差
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(C_ID varChar(32), C_Name varChar(80),' +
       'C_PY varChar(80), C_Phone varChar(20), C_Saler varChar(32),' +
       'C_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   客户表: Customer
   *.C_ID: 编号
   *.C_Name: 名称
   *.C_PY: 拼音简写
   *.C_Phone: 联系方式
   *.C_Saler: 业务员
   *.C_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(M_ID varChar(32), M_Name varChar(80),' +
       'M_PY varChar(80), M_Unit varChar(20), M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   物料表: Materails
   *.M_ID: 编号
   *.M_Name: 名称
   *.M_PY: 拼音简写
   *.M_Unit: 单位
   *.M_PrePValue: 预置皮重
   *.M_PrePTime: 皮重时长(天)
   *.M_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_Station varChar(10), P_MAC varChar(32),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   过磅记录: Materails
   *.P_ID: 编号
   *.P_Type: 类型(销售,供应,临时)
   *.P_Order: 订单号
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
   *.P_Station,P_MAC: 磅站标识
   *.P_Direction: 物料流向(进,出)
   *.P_PModel: 过磅模式(标准,配对等)
   *.P_Status: 记录状态
   *.P_Valid: 是否有效
   *.P_PrintNum: 打印次数
   *.P_DelMan,P_DelDate: 删除记录
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer,' +
       'Z_RdID varChar(32), Z_RdIP varChar(32), Z_RdPort Integer,' +
       'Z_CtrlID varChar(32), Z_CtrlIP varChar(32), Z_CtrlPort Integer,' +
       'Z_CtrlLine Integer,' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   装车线配置: ZTLines
   *.R_ID: 记录号
   *.Z_ID: 编号
   *.Z_Name: 名称
   *.Z_StockNo: 品种编号
   *.Z_Stock: 品名
   *.Z_StockType: 类型(袋,散)
   *.Z_PeerWeight: 袋重
   *.Z_RdID,Z_RdIP,Z_RdPort: 读卡器
   *.Z_CtrlID,Z_CtrlIP,Z_CtrlPort,Z_CtrlLine: 控制器  
   *.Z_QueueMax: 队列大小
   *.Z_VIPLine: VIP通道
   *.Z_Valid: 是否有效
   *.Z_Index: 顺序索引
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0)';
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
  -----------------------------------------------------------------------------}

  sSQL_ZTTruckLog = 'Create Table $Table(R_ID $Inc, L_Truck varChar(15),' +
       'L_Line varChar(15), L_Bill varChar(15), L_Total Integer,' +
       'L_Normal Integer, L_BuCha Integer)';
  {-----------------------------------------------------------------------------
   栈台装车记录: ZTTruckLog
   *.R_ID: 记录号
   *.L_Truck: 车牌号
   *.L_Line: 所在道
   *.L_Bill: 提单号
   *.L_Total: 总装袋数
   *.L_Normal: 正常袋数
   *.L_BuCha: 补差袋数
  -----------------------------------------------------------------------------}

  sSQL_NewXSOrder = 'Create Table $Table(R_ID $Inc, BillID varChar(20), ' +
       'VBELN varChar(20), AUART varChar(8), BEZEI varChar(40), ' +
       'VKORG varChar(8), VTEXT varChar(40), KUNNR_AG varChar(20), ' +
       'NAME1_AG varChar(70), KUNNR_WE varChar(20), NAME1_WE varChar(70), ' +
       'VBELN_CT varChar(20), LIFNR_CT varChar(20), OTHER_MG varChar(500),' +
       'POSNR varChar(12),  WERKS varChar(8),  NAME1 varChar(60),' +
       'VSTEL varChar(8),  VTEXT_1 varChar(60),  LGORT varChar(8),' +
       'LGOBE varChar(32), MATNR varChar(36), ARKTX varChar(80),' +
       'MVGR1 varChar(6), BEZEI_1 varChar(80), KWMENG $Float, RFMNG $Float,' +
       'WTSL $Float, KYSL $Float)';
  {-----------------------------------------------------------------------------
   销售订单表: OrderXS
    VBELN    : 销售订单号
    AUART    : 销售凭证类型
    BEZEI    : 类型描述
    VKORG    : 销售组织
    VTEXT    : 销售组织描述
    KUNNR_AG : 售达方
    NAME1_AG : 售达方描述
    KUNNR_WE : 送达方
    NAME1_WE : 送达方描述
    VBELN_CT : 运输合同号
    LIFNR_CT : 运输供应商
    OTHER_MG : 其它信息

    POSNR    : 订单项目号
    WERKS    : 工厂
    NAME1    : 工厂名称
    VSTEL    : 装运点
    VTEXT_1  : 装运点描述
    LGORT    : 库存地点
    LGOBE    : 库存地点描述
    MATNR    : 物料号
    ARKTX    : 物料描述
    MVGR1    : 物料组1
    BEZEI_1  : 物料类型
    KWMENG   : 累计订单数量
    RFMNG    : 已提数量
    WTSL     : 未提数量
    KYSL     : 可用数量
  -----------------------------------------------------------------------------}

  sSQL_NewZCOrder = 'Create Table $Table(R_ID $Inc, BillID varChar(20), ' +
       'VBELN varChar(20), BSART varChar(8), BATXT varChar(40),' +
       'LIFNR varChar(20), NAME1 varChar(70), KUNNR_WE varChar(20),' +
       'NAME1_WE varChar(70), VBELN_CT varChar(20), LIFNR_CT varChar(20),' +
       'OTHER_MG varChar(500), POSNR varChar(10),' +
       'WERKS varChar(8), NAME1_1 varChar(60), VSTEL varChar(8),' +
       'VTEXT varChar(60), LGORT varChar(8), LGOBE varChar(32),' +
       'WERKS_J varChar(8), NAME1_J varChar(60), MATNR varChar(36),' +
       'TXZ01 varChar(80), MENGE $Float, YTSL $Float,' +
       'WTSL $Float)';
  {-----------------------------------------------------------------------------
   转储订单表: OrderZC
    VBELN    : 转储订单号
    BSART    : 凭证类型
    BATXT    : 凭证类型的简短描述
    LIFNR    : 供应商
    NAME1    : 供应商描述
    KUNNR_WE : 送达方
    NAME1_WE : 送达方描述
    VBELN_CT : 运输合同号
    LIFNR_CT : 运输供应商
    OTHER_MG : 运输信息

    POSNR    : 转储订单项目号
    WERKS    : 工厂
    NAME1_1  : 工厂名称
    VSTEL    : 装运点/接收点
    VTEXT    : 装运点描述
    LGORT    : 库存地点
    LGOBE    : 库存地点描述
    WERKS_J  : 交货工厂
    NAME1_J  : 交货工厂描述
    MATNR    : 物料号
    TXZ01    : 物料描述
    MENGE    : 订单数量
    YTSL     : 已提数量
    WTSL     : 未提数量
  -----------------------------------------------------------------------------}
  
function CardStatusToStr(const nStatus: string): string;
//磁卡状态
function TruckStatusToStr(const nStatus: string): string;
//车辆状态

implementation

//------------------------------------------------------------------------------
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
  if nStatus = sFlag_TruckFH then Result := '放灰处' else
  if nStatus = sFlag_TruckZT then Result := '栈台' else Result := '未进厂';
end;

//------------------------------------------------------------------------------
//Desc: 添加系统表项
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: 系统表
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);
  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);

  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StorLocation, sSQL_NewStorLocation);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);

  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillInfo, sSQL_NewBillInfo);
  AddSysTableItem(sTable_OrderXS, sSQL_NewXSOrder);
  AddSysTableItem(sTable_OrderZC, sSQL_NewZCOrder);
  AddSysTableItem(sTable_Card, sSQL_NewCard);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_TruckLog, sSQL_NewTruckLog);
  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);
  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);

  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_ZTTruckLog, sSQL_ZTTruckLog);

  AddSysTableItem(sTable_Message, sSQL_NewMessage);                  // 20130613
  AddSysTableItem(sTable_MTime, sSQL_NewMTime);                      // 20130613
  AddSysTableItem(sTable_MUser, sSQL_NewMUser);                      // 20130613
  AddSysTableItem(sTable_Template, sSQL_NewMTemplate);               // 20130808
  AddSysTableItem(sTable_Definition, sSQL_NewMDefinition);           // 20130808
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


