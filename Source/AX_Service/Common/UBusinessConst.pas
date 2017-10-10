{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务常量定义

  备注:
  *.所有In/Out数据,最好带有TBWDataBase基数据,且位于第一个元素.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  UBusinessPacker;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*business command*}
  cBC_ReadBillInfo            = $0001;
  cBC_AXSalesOrder            = $0300;//获取AX销售订单
  cBC_AXSalesOrdLine          = $0301;//获取AX销售订单行
  cBC_AXSupAgreement          = $0302;//获取补充协议
  cBC_AXCreLimCust            = $0303;//获取信用额度增减（客户）
  cBC_AXCreLimCusCont         = $0304;//获取信用额度增减（客户-合同）
  cBC_AXSalesCont             = $0305;//获取销售合同
  cBC_AXSalesContLine         = $0306;//获取销售合同行
  cBC_AXVehicleNo             = $0307;//获取车号
  cBC_AXPurOrder              = $0308;//获取采购订单
  cBC_AXPurOrdLine            = $0309;//获取采购订单行
  cBC_AXCustNo                = $0310;//获取客户信息
  cBC_AXProvider              = $0311;//获取供应商信息
  cBC_AXMaterails             = $0312;//获取物料信息
  cBC_AXThInfo                = $0313;//获取提货信息
  cBC_AXYKAmount              = $0314;//更新预扣金额

type
  PReadXSSaleOrderIn = ^TReadXSSaleOrderIn;
  TReadXSSaleOrderIn = record
    FBase  : TBWDataBase;          //基础数据
    FVBELN : string;               //销售订单号
    FVSTEL : string;               //装运点,接收点
  end;

  PWorkerMessageData = ^TWorkerMessageData;
  TWorkerMessageData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //类型
    FData     : string;            //数据
    FExtParam : string;            //参数
  end;

  PWorkerBusinessAXCommand = ^TWorkerBusinessAXCommand;
  TWorkerBusinessAXCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //命令
    FData     : string;            //数据
    FExtParam : string;            //参数
    FExXml    : string;            //xml
    FRemoteUL : string;            //工厂服务器UL
  end;

resourcestring
  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //业务模块
  {*common function*}
  sSys_SweetHeart             = 'Sys_SweetHeart';       //心跳指令
  sSys_BasePacker             = 'Sys_BasePacker';       //基本封包器

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //服务状态
  sBus_BusinessAXCommand        = 'Bus_BusinessAXCommand';  //业务指令
  sBus_BusinessMessage        = 'Bus_BusinessMessage'; //服务端消息指令

  {*client function name*}
  sCLI_BusinessMessage        = 'CLI_BusinessMessage';  //客户端消息指令

implementation

end.


