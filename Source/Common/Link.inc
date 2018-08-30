//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{.$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE QLS}
//特定系统

//祁连山
{$IFDEF QLS}
  {$DEFINE COMMON}
  //通用版本
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE M100Reader}
  //启用M100Reader自动收卡机(成县,夏河,平凉,古浪,青海,文县,漳县)(无吞卡机:民和,甘谷)

  {.$DEFINE GLPURCH} 
  //古浪
  {.$DEFINE YDKP} 
  //永登开票
  {.$DEFINE YDSN} 
  //永登、中川商砼、甘谷商砼
  {$DEFINE PLKP} 
  //平凉开票
  {.$DEFINE XHPZ} 
  //夏河、定西
  {.$DEFINE DXSN} 
  //定西
  {.$DEFINE ZXKP} 
  //漳县、定西
  {.$DEFINE ZCST}
  //中川商砼、甘谷商砼
  {.$DEFINE GGJC} 
  //甘谷、兰州商砼、中川商砼、甘谷商砼自动出厂
  {.$DEFINE CXSY} 
  //成县试样编号
  {.$DEFINE CXKC}
  //成县空车出厂
  {.$DEFINE LZST} 
  //兰州商砼水泥內倒
  {.$DEFINE QHSN} 
  //青海
  {.$DEFINE MHSN} 
  //民和
  {.$DEFINE WDFH}
  //陇南武都散装共用道放灰
  {.$DEFINE ZTLineChange}
  //装车线变更校验(陇南)
  {.$DEFINE JSTruck}
  //格式化计数器车牌(漳县)
  {.$DEFINE XHYY}
  //夏河装车道语音
  {$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE StockMill}
  //水泥磨(夏河)
{$ENDIF}
