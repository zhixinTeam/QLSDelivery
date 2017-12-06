{*******************************************************************************
  作者: dmzn@163.com 2012-4-22
  描述: 硬件动作业务
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue,
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrRemotePrint,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrLEDDisp, UMgrRFID102, UMITConst, Graphics, UMgrTTCEM100;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
//有新卡号到达读头
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//现场读头有新卡号
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//现场读头卡号超时
procedure WhenBusinessMITSharedDataIn(const nData: string);
//业务中间件共享数据
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//保存计数结果
procedure MakeTruckIn(const nCard,nReader: string);
//车辆进厂
procedure SendMsgToWebMall(const nLid:string;const MsgType:Integer;const nBillType:string);
//推送消息到微信平台
function Do_send_event_msg(const nXmlStr: string): string;
//发送消息
procedure ModifyWebOrderStatus(const nLId:string;nStatus:Integer=c_WeChatStatusFinished;
                               const AWebOrderID:string='';const nNetWeight:string='0');
//修改网上订单状态  nStatus 0:已开卡；1:已出厂
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;
//修改网上订单状态
function VerifyTruckTunnel(const nTruck: string; nTunnelEx: string):Boolean;
//匹配通道用于两通道共用读卡器

function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
      const nImage: string): Boolean; overload;
function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nImage: TGraphic): Boolean; overload;

procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, HKVNetSDK, UFormCtrl;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
      const nImage: string): Boolean;
var nPic: TPicture;
begin
  Result := False;
  if not FileExists(nImage) then Exit;

  nPic := nil;
  try
    nPic := TPicture.Create;
    nPic.LoadFromFile(nImage);

    SaveDBImage(nDS, nFieldName, nPic.Graphic);
    FreeAndNil(nPic);
  except
    if Assigned(nPic) then nPic.Free;
  end;
end;

function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nImage: TGraphic): Boolean;
var nField: TField;
    nStream: TMemoryStream;
    nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  nStream := nil;
  try
    if not Assigned(nImage) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post; Result := True; Exit;
    end;

    nStream := TMemoryStream.Create;
    nImage.SaveToStream(nStream);
    nStream.Seek(0, soFromEnd);

    FillChar(nBuf, MAX_PATH, #0);
    StrPCopy(@nBuf[1], nImage.ClassName);
    nStream.WriteBuffer(nBuf, MAX_PATH);

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    FreeAndNil(nStream);
    Result := True;
  except
    if Assigned(nStream) then nStream.Free;
    if nDS.State = dsEdit then nDS.Cancel;
  end;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallBusinessCommand(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
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

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
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

//Date: 2015-08-06
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessPurchaseOrder(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrder);
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

//Date: 2014-10-16
//Parm: 命令;数据;参数;输出
//Desc: 调用硬件守护上的业务对象
function CallHardwareCommand(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
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

//Date: 2012-3-23
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号
//Desc: 获取磁卡使用类型
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号;岗位;采购单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2015-08-06
//Parm: 岗位;采购单列表
//Desc: 保存nPost岗位上的采购单数据
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: 事件描述;岗位标识
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, '硬件守护辅助', nEvent);
end;

{procedure BlueOpenDoor(const nReader: string);
begin
  if gHardwareHelper.ConnHelper then
       gHardwareHelper.OpenDoor(nReader)
  else gBlueReader.OpenDoor(nReader);
end;}


procedure SendMsgToWebMall(const nLid:string;const MsgType:Integer;const nBillType:string);
var
  nSql:string;
  nDs:TDataSet;

  nBills: TLadingBillItems;
  nXmlStr,nData:string;
    nIdx:Integer;
begin
  if nBillType=sFlag_Sale then
  begin
    //加载提货单信息
    if not GetLadingBills(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else if nBillType=sFlag_Provide then
  begin
    //加载采购订单信息
    if not GetLadingOrders(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else begin
    Exit;
  end;

  for nIdx := Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
        +'<DATA>'
        +'<head>'
        +'<Factory>%s</Factory>'
        +'<ToUser>%s</ToUser>'
        +'<MsgType>%d</MsgType>'
        +'</head>'
        +'<Items>'
        +'	  <Item>'
        +'	      <BillID>%s</BillID>'
        +'	      <Card>%s</Card>'
        +'	      <Truck>%s</Truck>'
        +'	      <StockNo>%s</StockNo>'
        +'	      <StockName>%s</StockName>'
        +'	      <CusID>%s</CusID>'
        +'	      <CusName>%s</CusName>'
        +'	      <CusAccount>0</CusAccount>'
        +'	      <MakeDate></MakeDate>'
        +'	      <MakeMan></MakeMan>'
        +'	      <TransID></TransID>'
        +'	      <TransName></TransName>'
        +'	      <Searial></Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'        <NetWeight>%s</NetWeight>'
        +'	  </Item>	'
        +'</Items>'
        +'   <remark/>'
        +'</DATA>';
    nXmlStr := Format(nXmlStr,[gSysParam.FFactory, FCusID, MsgType,//cSendWeChatMsgType_DelBill,
               FID, FCard, FTruck, FStockNo, FStockName, FCusID, FCusName,FloatToStr(FValue)]);
    nXmlStr := PackerEncodeStr(nXmlStr);
    nData := Do_send_event_msg(nXmlStr);
    gSysLoger.AddLog(nData);

    if ndata<>'' then
    begin
      WriteHardHelperLog(nData, sPost_Out);
    end;
  end;
end;

//发送消息
function Do_send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//修改网上订单状态
procedure ModifyWebOrderStatus(const nLId:string;nStatus:Integer;const AWebOrderID:string;const nNetWeight:string);
var
  nXmlStr,nData,nSql:string;
  nDBConn: PDBWorker;
  nWebOrderId:string;
  nIdx:Integer;
begin
  nWebOrderId := AWebOrderID;
  nDBConn := nil;

  if nWebOrderId='' then
  begin
    with gParamManager.ActiveParam^ do
    begin
      try
        nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
        if not Assigned(nDBConn) then
        begin
  //        WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
          Exit;
        end;
        if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;

        //查询网上商城订单
        nSql := 'select WOM_WebOrderID from %s where WOM_LID=''%s''';
        nSql := Format(nSql,[sTable_WebOrderMatch,nLId]);

        with gDBConnManager.WorkerQuery(nDBConn, nSql) do
        begin
          if recordcount>0 then
          begin
            nWebOrderId := FieldByName('WOM_WebOrderID').asstring;
          end;
        end;

      finally
        gDBConnManager.ReleaseConnection(nDBConn);
      end;
    end;
  end;

  if nWebOrderId='' then Exit;

  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head><ordernumber>%s</ordernumber>'
            +'<status>%d</status>'
            +'<NetWeight>%s</NetWeight>'
            +'</head>'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[nWebOrderId,nStatus,nNetWeight]);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := Do_ModifyWebOrderStatus(nXmlStr);
  gSysLoger.AddLog(nData);

  if ndata<>'' then
  begin
    WriteHardHelperLog(nData, sPost_Out);
  end;
end;

//修改网上订单状态
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2012-4-22
//Parm: 卡号
//Desc: 对nCard放行进厂
procedure MakeTruckIn(const nCard,nReader: string);
var nStr,nTruck,nCardType: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nRet: Boolean;
    nErrNum: Integer;
    nDB: PDBWorker;
begin
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //同读头同卡,在2分钟内不做二次进厂业务.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Other then   //临时卡进厂
  begin
    nDB := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDB := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDB) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDB,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        if FieldByName('I_InDate').IsNull then
        begin
          gHYReaderManager.OpenDoor(nReader);//抬杆
          nStr := '临时卡[ %s ]进厂.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          nStr := 'Update %s Set I_InDate=getdate() Where I_Card=''%s''';
          nStr := Format(nStr, [sTable_InOutFatory, nCard]);
          //xxxxx

          gDBConnManager.WorkerExec(nDB, nStr);
        end;
      end;
      nStr := 'select * from %s Where (I_Card=''%s'') and '+
              '(I_InDate is not null) and (I_OutDate is not null) ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDB,nStr) do
      if RecordCount > 0 then
      begin
        nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
        nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, nCard]);
        gDBConnManager.WorkerExec(nDB, nStr);

        nStr := 'Update %s Set I_Card=''注''+I_Card Where I_Card=''%s''';
        nStr := Format(nStr, [sTable_InOutFatory, nCard]);
        gDBConnManager.WorkerExec(nDB, nStr);
      end;
    finally
      gDBConnManager.ReleaseConnection(nDB);
    end;
    Exit;
  end;

  if nCardType = sFlag_ST then    //商砼卡进厂
  begin
    nDB := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDB := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDB) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;
      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_STInOutFact, nCard]);
      with gDBConnManager.WorkerQuery(nDB,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        nTruck:=FieldByName('I_truck').AsString;
        gHYReaderManager.OpenDoor(nReader);//抬杆
        nStr := '%s商砼卡[ %s ]进厂.';
        nStr := Format(nStr, [nTruck,nCard]);

        WriteHardHelperLog(nStr, sPost_In);
        nStr := 'Insert into %s (I_Card,I_truck,I_Date,I_InDate) Values (''%s'',''%s'',getdate(),getdate()) ';
        nStr := Format(nStr, [sTable_STInOutFact, nCard,nTruck]);
        //xxxxx
        gDBConnManager.WorkerExec(nDB, nStr);
      end;
    finally
      gDBConnManager.ReleaseConnection(nDB);
    end;
    Exit;
  end;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要进厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    //未进长,或已进厂
    {$IFDEF YDKP}
      {$IFDEF XHPZ}
      if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
      {$ELSE}
      if (FStatus = sFlag_TruckNone) then Continue;
      {$ENDIF}
    {$ELSE}
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    {$ENDIF}
    nStr := '车辆[ %s ]下一状态为:[ %s ],进厂刷卡无效.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    nDB := nil;
    nRet := False;
    with gParamManager.ActiveParam^ do
    Try
      nDB := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDB) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;
      nStr := 'select * from %s Where D_Value=''%s'' And D_Name=''KsItem'' ';
      nStr := Format(nStr, [sTable_SysDict, nReader]);
      with gDBConnManager.WorkerQuery(nDB,nStr) do
      begin
        if RecordCount > 0 then
          nRet := True;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDB);
    end;
    //平凉矿山自动进厂判断
    if (gTruckQueueManager.IsTruckAutoIn) or nRet then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      gHYReaderManager.OpenDoor(nReader);
      //抬杆

      nStr := '车辆[ %s ]再次抬杆操作.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);
    end;
    Exit;
  end;

  if nCardType = sFlag_Provide then
  begin
    if not SaveLadingOrders(sFlag_TruckIn, nTrucks) then
    begin
      nStr := '车辆[ %s ]进厂放行失败.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      //BlueOpenDoor(nReader);
      gHYReaderManager.OpenDoor(nReader);
      //抬杆
    end;

    nStr := '原材料卡[%s]进厂抬杆成功';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;
  //采购磁卡直接抬杆
  {$IFNDEF YDSN}
  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //非延时队列(厂内模式)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '车辆[ %s ]没有在调度队列中.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;
  {$ENDIF}

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '车辆[ %s ]进厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if gTruckQueueManager.IsTruckAutoIn then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
  end else
  begin
    //BlueOpenDoor(nReader);
    gHYReaderManager.OpenDoor(nReader);
    //抬杆
  end;

  nDB := nil;
  with gParamManager.ActiveParam^ do
  Try
    nDB := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDB) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;
    with gTruckQueueManager do
    if not IsDelayQueue then //厂外模式,进厂时绑定道号(一车多单)
    try
      SyncLock.Enter;
      nTruck := nTrucks[0].FTruck;

      for nIdx:=Lines.Count - 1 downto 0 do
      begin
        nPLine := Lines[nIdx];
        nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

        if nInt < 0 then Continue;
        nPTruck := nPLine.FTrucks[nInt];

        nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
        nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
                nPTruck.FBill]);
        //xxxxx

        gDBConnManager.WorkerExec(nDB, nStr);
        //绑定通道
      end;
    finally
      SyncLock.Leave;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;

//Date: 2012-4-22
//Parm: 卡号;读头;打印机
//Desc: 对nCard放行出厂
procedure MakeTruckOut(const nCard,nReader,nPrinter,nHyprinter: string);
var nStr,nCardType,nTruck: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Other then
  begin
    nDBConn := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDBConn) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;
      //conn db
      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        {$IFDEF QHSN}
        nTruck:=FieldByName('I_truck').AsString;
        gHYReaderManager.OpenDoor(nReader);//抬杆
        nStr := '临时卡[ %s ]进厂.';
        nStr := Format(nStr, [nCard]);

        WriteHardHelperLog(nStr, sPost_In);
        nStr := 'Insert into %s (I_Card,I_truck,I_InDate) Values (''%s'',''%s'',getdate()) ';
        nStr := Format(nStr, [sTable_InOutFatory, nCard,nTruck]);
        //xxxxx

        gDBConnManager.WorkerExec(nDBConn, nStr);
        {$ELSE}
        if FieldByName('I_OutDate').IsNull then
        begin
          gHYReaderManager.OpenDoor(nReader);//抬杆
          nStr := '临时卡[ %s ]出厂.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          nStr := 'Update %s Set I_OutDate=getdate() Where I_Card=''%s''';
          nStr := Format(nStr, [sTable_InOutFatory, nCard]);
          //xxxxx

          gDBConnManager.WorkerExec(nDBConn, nStr);
        end;
        {$ENDIF}
      end;
      {$IFDEF QHSN}

      {$ELSE}
      nStr := 'select * from %s Where (I_Card=''%s'') and '+
              '(I_InDate is not null) and (I_OutDate is not null) ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      if RecordCount > 0 then
      begin
        nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
        nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, nCard]);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        nStr := 'Update %s Set I_Card=''注''+I_Card Where I_Card=''%s''';
        nStr := Format(nStr, [sTable_InOutFatory, nCard]);
        gDBConnManager.WorkerExec(nDBConn, nStr);
      end;
      {$ENDIF}
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
    Exit;
  end;

  if nCardType = sFlag_ST then
  begin
    nDBConn := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDBConn) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;
      //conn db
      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_STInOutFact, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        nTruck:=FieldByName('I_truck').AsString;
        gHYReaderManager.OpenDoor(nReader);//抬杆
        nStr := '%s商砼卡[ %s ]出厂.';
        nStr := Format(nStr, [nTruck,nCard]);

        WriteHardHelperLog(nStr, sPost_In);
        nStr := 'Insert into %s (I_Card,I_truck,I_Date,I_OutDate) Values (''%s'',''%s'',getdate(),getdate()) ';
        nStr := Format(nStr, [sTable_STInOutFact, nCard,nTruck]);
        //xxxxx
        gDBConnManager.WorkerExec(nDBConn, nStr);
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
    Exit;
  end;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nCardType = sFlag_Provide then
        nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks)
  else  nRet := SaveLadingBills(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if (nReader <> '') and (Pos('V',nReader)<=0) then gHYReaderManager.OpenDoor(nReader);
  //抬杆
  if gSysParam.FGPWSURL <> '' then
  begin
    //更新微信订单状态
    ModifyWebOrderStatus(nTrucks[0].FID,c_WeChatStatusFinished,'',FloatToStr(nTrucks[0].FValue));
    //发送微信消息
    SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF ZXKP}
    if (nCardType = sFlag_Provide) and (nTrucks[nIdx].FNeiDao = sFlag_Yes) then
    begin
      nStr := '车辆[ %s ]内倒出厂不打印.';
      nStr := Format(nStr, [nTrucks[nIdx].FTruck]);

      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
    {$ENDIF}
    {$IFDEF QHSN}
    if (nCardType = sFlag_Provide) and (nTrucks[nIdx].FNeiDao = sFlag_Yes) then
    begin
      nStr := '车辆[ %s ]内倒出厂不打印.';
      nStr := Format(nStr, [nTrucks[nIdx].FTruck]);

      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //磁卡类型

    if (nPrinter = '') and (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + nStr);
    end else
    if (nPrinter <> '') and (nHyprinter <> '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #11 + nHyprinter + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nHyprinter + nStr);
    end else
    if (nPrinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #11 + nHyprinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nHyprinter + nStr);
    end else
    if (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
    end;
  end; //打印报表
end;

//Date: 2017-10-31
//Parm: 卡号;读头;打印机
//lih: 对nCard放行出厂
function MakeTruckOutM100(const nCard,nReader,nPrinter,nHyprinter: string; var nCType:string): Boolean;
var nStr,nCardType,nTruck: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  Result:= False;
  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;
  nCType := nCardType;
  
  if nCardType = sFlag_Other then
  begin
    nDBConn := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDBConn) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;
      //conn db
      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);
          Result := True;
          
          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        {$IFDEF QHSN}
        nTruck:=FieldByName('I_truck').AsString;
        gHYReaderManager.OpenDoor(nReader);//抬杆
        nStr := '临时卡[ %s ]进厂.';
        nStr := Format(nStr, [nCard]);

        WriteHardHelperLog(nStr, sPost_In);
        nStr := 'Insert into %s (I_Card,I_truck,I_InDate) Values (''%s'',''%s'',getdate()) ';
        nStr := Format(nStr, [sTable_InOutFatory, nCard,nTruck]);
        //xxxxx

        gDBConnManager.WorkerExec(nDBConn, nStr);
        {$ELSE}
        if FieldByName('I_OutDate').IsNull then
        begin
          gHYReaderManager.OpenDoor(nReader);//抬杆
          nStr := '临时卡[ %s ]出厂.';
          nStr := Format(nStr, [nCard]);

          WriteHardHelperLog(nStr, sPost_In);
          nStr := 'Update %s Set I_OutDate=getdate() Where I_Card=''%s''';
          nStr := Format(nStr, [sTable_InOutFatory, nCard]);
          //xxxxx

          gDBConnManager.WorkerExec(nDBConn, nStr);
        end;
        {$ENDIF}
      end;
      {$IFDEF QHSN}

      {$ELSE}
      nStr := 'select * from %s Where (I_Card=''%s'') and '+
              '(I_InDate is not null) and (I_OutDate is not null) ';
      nStr := Format(nStr, [sTable_InOutFatory, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      if RecordCount > 0 then
      begin
        nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
        nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, nCard]);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        nStr := 'Update %s Set I_Card=''注''+I_Card Where I_Card=''%s''';
        nStr := Format(nStr, [sTable_InOutFatory, nCard]);
        gDBConnManager.WorkerExec(nDBConn, nStr);
      end;
      {$ENDIF}
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
    Result := True;
    Exit;
  end;

  if nCardType = sFlag_ST then
  begin
    nDBConn := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDBConn) then
      begin
        WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;
      //conn db
      nStr := 'select * from %s Where I_Card=''%s'' ';
      nStr := Format(nStr, [sTable_STInOutFact, nCard]);
      with gDBConnManager.WorkerQuery(nDBConn,nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '读取磁卡[ %s ]订单信息失败.';
          nStr := Format(nStr, [nCard]);
          Result := True;
          
          WriteHardHelperLog(nStr, sPost_In);
          Exit;
        end;
        nTruck:=FieldByName('I_truck').AsString;
        gHYReaderManager.OpenDoor(nReader);//抬杆
        nStr := '%s商砼卡[ %s ]出厂.';
        nStr := Format(nStr, [nTruck,nCard]);

        WriteHardHelperLog(nStr, sPost_In);
        nStr := 'Insert into %s (I_Card,I_truck,I_Date,I_OutDate) Values (''%s'',''%s'',getdate(),getdate()) ';
        nStr := Format(nStr, [sTable_STInOutFact, nCard,nTruck]);
        //xxxxx
        gDBConnManager.WorkerExec(nDBConn, nStr);
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
    Result := True;
    Exit;
  end;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nCardType = sFlag_Provide then
        nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks)
  else  nRet := SaveLadingBills(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if (nReader <> '') and (Pos('V',nReader)<=0) then gHYReaderManager.OpenDoor(nReader);
  //抬杆
  if gSysParam.FGPWSURL <> '' then
  begin
    //更新微信订单状态
    ModifyWebOrderStatus(nTrucks[0].FID,c_WeChatStatusFinished,'',FloatToStr(nTrucks[0].FValue));
    //发送微信消息
    SendMsgToWebMall(nTrucks[0].FID,cSendWeChatMsgType_OutFactory,nCardType);
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF ZXKP}
    if (nCardType = sFlag_Provide) and (nTrucks[nIdx].FNeiDao = sFlag_Yes) then
    begin
      nStr := '车辆[ %s ]内倒出厂不打印.';
      nStr := Format(nStr, [nTrucks[nIdx].FTruck]);
      Result := True;
      
      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
    {$ENDIF}
    {$IFDEF QHSN}
    if (nCardType = sFlag_Provide) and (nTrucks[nIdx].FNeiDao = sFlag_Yes) then
    begin
      nStr := '车辆[ %s ]内倒出厂不打印.';
      nStr := Format(nStr, [nTrucks[nIdx].FTruck]);
      Result := True;
      
      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //磁卡类型

    if (nPrinter = '') and (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + nStr);
    end else
    if (nPrinter <> '') and (nHyprinter <> '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #11 + nHyprinter + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nHyprinter + nStr);
    end else
    if (nPrinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #11 + nHyprinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nHyprinter + nStr);
    end else
    if (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
    end;
  end; //打印报表
  Result := True;
end;

//Date: 2012-10-19
//Parm: 卡号;读头
//Desc: 检测车辆是否在队列中,决定是否抬杆
procedure MakeTruckPassGate(const nCard,nReader: string);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
    nDBConn: PDBWorker;
    nErrNum: Integer;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要通过道闸的车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '车辆[ %s ]不在队列,禁止通过道闸.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  //BlueOpenDoor(nReader);
  //抬杆
  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  Try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
      nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

      gDBConnManager.WorkerExec(nDBConn, nStr);
      //更新提货时间,语音程序将不再叫号.
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2012-4-22
//Parm: 读头数据
//Desc: 对nReader读到的卡号做具体动作
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived进入.'+nReader.FID+' 读头类型：'+nReader.FType);
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
    end else
    begin
      nStr := Format('磁卡号[ %s ]匹配失败.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
  
  try
    if nReader.FType = rtIn then
    begin
      MakeTruckIn(nStr, nReader.FID);
    end else
    if nReader.FType = rtOut then
    begin
      MakeTruckOut(nStr, nReader.FID, nReader.FPrinter, nReader.FHyprinter);
    end else

    if nReader.FType = rtGate then
    begin
      //if nReader.FID <> '' then
      //  BlueOpenDoor(nReader.FID);
      //抬杆
    end else

    if nReader.FType = rtQueueGate then
    begin
      if nReader.FID <> '' then
        MakeTruckPassGate(nStr, nReader.FID);
      //抬杆
    end;
  except
    On E:Exception do
    begin
      WriteHardHelperLog(E.Message);
    end;
  end;

end;

procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);   //2016-06-24 lih
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('华益标签 %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
      rt900 :gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
      rt02n :g02NReader.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard);
    end;
  end else
  begin
    g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
    WriteHardHelperLog('WhenHYReaderCardArrived.g02NReader.ActiveELabel('+nReader.FTunnel+', '+nReader.FCard+')');
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/10/31
//Parm: 三合一读卡器
//lih: 处理三合一读卡器信息
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
    nCType: string;
    nDBConn: PDBWorker;
    nErrNum: Integer;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '三合一读卡器卡号'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}

  try
    if not nItem.FVirtual then Exit;
    case nItem.FVType of
    rtOutM100 :
    begin
      nRetain := MakeTruckOutM100(nItem.FCard, nItem.FVReader, nItem.FVPrinter, nItem.FVHYPrinter, nCType);
      if nCType = sFlag_Provide then
      begin
        nDBConn := nil;
        with gParamManager.ActiveParam^ do
        Try
          nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
          if not Assigned(nDBConn) then
          begin
            WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
            Exit;
          end;

          if not nDBConn.FConn.Connected then
            nDBConn.FConn.Connected := True;
          //conn db
          nStr := 'select O_CType from %s Where O_Card=''%s'' ';
          nStr := Format(nStr, [sTable_Order, nItem.FCard]);
          with gDBConnManager.WorkerQuery(nDBConn,nStr) do
          if RecordCount > 0 then
          begin
            if FieldByName('O_CType').AsString = sFlag_OrderCardG then nRetain := False;
          end;
        finally
          gDBConnManager.ReleaseConnection(nDBConn);
        end;
      end;
    end
    else
      gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain);
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '现场近距读卡器', nEvent);
end;

//Date: 2012-4-24
//Parm: 车牌;通道;是否检查先后顺序;提示信息
//Desc: 检查nTuck是否可以在nTunnel装车
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //不在当前队列
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //刷卡道与队列道品种不匹配

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //挪动车辆到新道

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '车辆[ %s ]自主换道[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //袋装重调队列

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]不在[ %s ]队列中.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //同步物料名
    Result := True;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: 通道号;交货单;
//Desc: 在nTunnel上打印nBill防伪码
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '向通道[ %s ]发送防违流码失败,描述: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: 车牌;通道;交货单;启动计数
//Desc: 对在nTunnel的车辆开启计数器
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]已不再队列.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
      
      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
      
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: 交货单号
//Desc: 查询nBill上的已装量
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
    nDBConn: PDBWorker;
    nIdx:Integer;
begin
  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  begin
    try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
      if not Assigned(nDBConn) then
      begin
        WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;

      nDBConn.FConn.BeginTrans;
      try
        nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        nStr := 'Select Max(%s) From %s';
        nStr := Format(nStr, ['R_ID', sTable_Picture]);

        with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        if RecordCount > 0 then
        begin
          nRID := Fields[0].AsInteger;
        end;

        nStr := 'Select P_Picture From %s Where R_ID=%d';
        nStr := Format(nStr, [sTable_Picture, nRID]);
        SaveDBImage(gDBConnManager.WorkerQuery(nDBConn, nStr), 'P_Picture', nFile);

        nDBConn.FConn.CommitTrans;
      except
        nDBConn.FConn.RollbackTrans;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
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
{
procedure CapturePicture(const nTunnel: PReaderHost; const nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr,nTmp: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
    nHost, nPort, nUser, nPwd: string;
    nPicSize, nPicQuality: Integer;
begin
  nList.Clear;

  if not Assigned(nTunnel.FOptions) then Exit;
  nHost:= nTunnel.FOptions.Values[''];
  nPort:= nTunnel.FOptions.Values[''];
  nUser:= nTunnel.FOptions.Values[''];
  nPwd := nTunnel.FOptions.Values[''];
  nPicSize:= StrToIntDef(nTunnel.FOptions.Values[''], 1);
  nPicQuality:= StrToIntDef(nTunnel.FOptions.Values[''], 1);

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;

  nLogin := -1;

  NET_DVR_Init();

  try
    for nIdx:=1 to cRetry do
    begin
      nStr := 'NET_DVR_Login(IPAddr=%s,wDVRPort=%d,UserName=%s,PassWord=%s)';
      nStr := Format(nStr,[nHost,nPort,nUser,nPwd]);

      nLogin := NET_DVR_Login(PChar(nHost),
                   nPort,
                   PChar(nUser),
                   PChar(nPwd), @nInfo);

      nErr := NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nHost, nPort, nErr]);
        WriteNearReaderLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nPicSize;
    nPic.wPicQuality := nPicQuality;
    nStr := 'nPic.wPicSize=%d,nPic.wPicQuality=%d';
    nStr := Format(nStr,[nPic.wPicSize,nPic.wPicQuality]);

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        nTmp := 'NET_DVR_CaptureJPEGPicture(LoginID=%d,lChannel=%d,sPicFileName=%s)';
        nTmp := Format(nTmp,[nLogin,nTunnel.FCameraTunnels[nIdx],nStr]);

        NET_DVR_CaptureJPEGPicture(nLogin, nTunnel.FCameraTunnels[nIdx],
                                   @nPic, PChar(nStr));

        nErr := NET_DVR_GetLastError;

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
          WriteNearReaderLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
      NET_DVR_Logout(nLogin);
    NET_DVR_Cleanup();
  end;
end; }

//Date: 2017-6-2
//Parm: 磁卡号;通道号
//Desc: 对nCard执行验收操作
procedure MakeTruckAcceptance(const nCard: string; nTunnel: string;const nHost: PReaderHost);
var
  nStr:string;
  nDBConn: PDBWorker;
  nIdx,nInt,nTmp:Integer;
  nY_valid,nY_stockno:string;
  nBills: TLadingBillItems;
  nList: TStrings;
  nCardType:string;
  function SimpleTruckno(const nTruckno:WideString):string;
  var
    i:Integer;
  begin
    Result := '';
    for i := 1 to Length(nTruckno) do
    begin
      if Ord(nTruckno[i])>127 then Continue;
      Result := Result+nTruckno[i];
    end;
  end;
begin
  nDBConn := nil;
  if not GetCardUsed(nCard, nCardType) then Exit;

  with gParamManager.ActiveParam^ do
  begin
    try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
      if not Assigned(nDBConn) then
        begin
          WriteNearReaderLog('连接'+FDB.FID+'数据库失败(DBConn Is Null).');
          Exit;
        end;
        if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;

        nStr := 'select * from %s where y_id=''%s''';
        nStr := Format(nStr,[sTable_YSLines,nTunnel]);

        with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        begin
          if recordcount=0 then
          begin
            WriteNearReaderLog('验收通道'+nTunnel+'不存在');
            Exit;
          end;
          nY_valid := FieldByName('Y_Valid').asstring;
          if nY_valid=sflag_no then
          begin
            WriteNearReaderLog('验收通道'+nTunnel+'已关闭');
            Exit;
          end;
          nY_stockno := FieldByName('Y_StockNo').asstring;
        end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
  end;

  if not GetLadingOrders(nCard, sFlag_TruckBFM, nBills) then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);
    WriteNearReaderLog(nStr);
    Exit;
  end;
  if Length(nBills) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要现场验收车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  nStr := '';
  nInt := 0;
  for nIdx:=Low(nBills) to High(nBills) do
  begin
    with nBills[nIdx] do
    begin
      if nCardType=sFlag_Provide then
      begin
        if Pos(FStockNo,nY_stockno)=0 then
        begin
          nTmp := Length(nBills[0].FTruck);
//          nStr := SimpleTruckno(nBills[0].FTruck) + '请更换验收通道';
          nStr := '请更换验收通道';
          gDisplayManager.Display(nTunnel, nStr);
          nStr := SimpleTruckno(nBills[0].FTruck) + '请更换验收通道';
          WriteHardHelperLog('在['+nTunnel+']通道刷卡无效，'+nStr+',订单物料['+FStockNo+']通道物料['+nY_stockno+']');
          Exit;
        end;
      end;
      FSelected := (FStatus = sFlag_TruckXH) or (FNextStatus = sFlag_TruckXH);
      if FSelected then
      begin
        Inc(nInt);
        Continue;
      end;

//      nStr := '%s    无法验收.';
//      nStr := Format(nStr, [SimpleTruckno(FTruck), TruckStatusToStr(FNextStatus)]);
      nStr := '请称量毛重';
      gDisplayManager.Display(nTunnel, nStr);
      nStr := '%s    无法验收.';
      nStr := Format(nStr, [SimpleTruckno(FTruck), TruckStatusToStr(FNextStatus)]);
      WriteNearReaderLog('在['+nTunnel+']通道刷卡无效，'+nStr+',订单物料['+FStockNo+']通道物料['+nY_stockno+']');
    end;
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

//  nStr := SimpleTruckno(nBills[0].FTruck) + '    刷卡完成';
  nStr := '刷卡验收完成';
  gDisplayManager.Display(nTunnel, nStr);
  nStr := SimpleTruckno(nBills[0].FTruck) + '    刷卡完成';
  WriteNearReaderLog('lixw-debug gDisplayManager.Display(nTunnel='+nTunnel+',nStr='+nStr+')');
  if not SaveLadingOrders(sFlag_TruckXH, nBills) then
  begin
    nStr := '车辆[ %s ]验收失败.';
    nStr := Format(nStr, [nBills[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;
  {nList := TStringList.Create;
  try
    CapturePicture(nHost, nList);

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nTunnel+FormatDateTime('yyyymmdd',date), nBills[0].FTruck,
                              nBills[0].FStockName, nList[nIdx]);
  finally
    nList.Free;
  end;}
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := '通道[ %s ]装车中,业务无效.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('通道[ ' + nTunnel + ' ]: MakeTruckLadingDai进入.');

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要栈台提货车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF CXKC}
  if nTrucks[0].FYSValid = sFlag_Yes then
  begin
    nStr := '车辆[ %s ]已办理空车出厂.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;
  {$ENDIF}

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //重新定位车辆所在车道
    if IsJSRun then Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //检查通道

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //刷卡通道对应的交货单
      Continue;
    end;

    FSelected := False;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法栈台提货.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '袋装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '车辆[ %s ]栈台提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: 车辆;通道
//Desc: 授权nTruck在nTunnel车道放灰
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel, nTunnelEx: string);
var nStr,nTmp,nCardUse: string;
   nField: TField;
   nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_Card');
      if Assigned(nField) then nTmp := nField.AsString;

      nField := FindField('T_Card2');
      if (Assigned(nField)) and (Length(nField.AsString)>0) then
      begin
        if Length(nTmp)>0 then
          nTmp := nTmp+';'+nField.AsString
        else
          nTmp := nField.AsString;
      end;

      nField := FindField('T_CardUse');
      if Assigned(nField) then nCardUse := nField.AsString;

      if nCardUse = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  {$IFDEF WDFH}
  if VerifyTruckTunnel(nTruck.FTruck, nTunnelEx) then
  begin
    gERelayManager.LineClose(nTunnel);
    nStr := '通道[ %s ]关闭继电器';
    nStr := Format(nStr, [nTunnel]);
    Sleep(100);
    WriteHardHelperLog(nStr, sPost_In);

    gERelayManager.LineOpen(nTunnelEx);
    nStr := '通道[ %s ]打开继电器';
    nStr := Format(nStr, [nTunnelEx]);

    WriteHardHelperLog(nStr, sPost_In);
  end
  else
  begin
    gERelayManager.LineClose(nTunnelEx);
    nStr := '通道[ %s ]关闭继电器';
    nStr := Format(nStr, [nTunnelEx]);
    Sleep(100);
    WriteHardHelperLog(nStr, sPost_In);

    gERelayManager.LineOpen(nTunnel);
    nStr := '通道[ %s ]打开继电器';
    nStr := Format(nStr, [nTunnel]);

    WriteHardHelperLog(nStr, sPost_In);
  end;
  {$ELSE}
  gERelayManager.LineOpen(nTunnel);
  //打开放灰
  {$ENDIF}

  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  //xxxxx

  gERelayManager.ShowTxt(nTunnel, nStr);
  //显示内容
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingSan(const nCard,nTunnel,nTunnelEx: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nChange: Boolean;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan进入.');
  {$ENDIF}
  WriteNearReaderLog('通道[ ' + nTunnel + ' ]: MakeTruckLadingSan进入.' + '扩展通道:' + nTunnelEx);

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要放灰车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) or (FStatus = sFlag_TruckBFM) then Continue;
    //未装或已装

    nStr := '车辆[ %s ]下一状态为:[ %s ],无法放灰.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  {$IFDEF WDFH}
  if not VerifyTruckTunnel(nTrucks[0].FTruck, nTunnelEx) then
  begin
    //1.车辆通道号与扩展通道号匹配
    nChange := IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
           nPTruck, nPLine, sFlag_San);
    //2.第1步匹配失败后检索nTruck可否在nTunnel装车
    if not nChange then
    if not IsTruckInQueue(nTrucks[0].FTruck, nTunnelEx, False, nStr,
           nPTruck, nPLine, sFlag_San) then
    begin
      //3.第2步检索失败后检索nTruck可否在nTunnelEx装车,用以兼顾2个同品种nTunnelEx换道
      WriteNearReaderLog(nStr);
      //loged

      nIdx := Length(nTrucks[0].FTruck);
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';
      gERelayManager.ShowTxt(nTunnel, nStr);
      Exit;
    end; //检查通道
  end
  else
  begin
    if not IsTruckInQueue(nTrucks[0].FTruck, nTunnelEx, False, nStr,
           nPTruck, nPLine, sFlag_San) then
    begin
      WriteNearReaderLog(nStr);
      //loged

      nIdx := Length(nTrucks[0].FTruck);
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';
      gERelayManager.ShowTxt(nTunnel, nStr);
      Exit;
    end; //检查通道
  end;
  {$ELSE}
  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //检查通道
  {$ENDIF}

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := '散装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nTunnel, nTunnelEx);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '车辆[ %s ]放灰处提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nTunnel, nTunnelEx);
  //执行放灰
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard新到卡号作出动作
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var
  nCardType: string;
begin
  if not GetCardUsed(nCard, nCardType) then Exit;
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfIn then
    begin
      MakeTruckIn(nCard, '');
    end else
    if nHost.FFun = rfOut then
    begin
      if Assigned(nHost.FOptions) then
        MakeTruckOut(nCard, '', nHost.FPrinter, nHost.FOptions.Values['HYprinter'])
      else
        MakeTruckOut(nCard, '', nHost.FPrinter, '');
    end else
    begin
      if nCardType = sFlag_Sale then
      begin
        MakeTruckLadingDai(nCard, nHost.FTunnel);
      end
      else if (nCardType = sFlag_Provide) or (nCardType = sFlag_other) then
      begin
        MakeTruckAcceptance(nCard,nhost.FTunnel,nHost);
      end;
    end;
  end
  else if nHost.FType = rtKeep then
  begin
    if nCardType = sFlag_Sale then
    begin
      {$IFDEF WDFH}
      if Assigned(nHost.FOptions) then
        MakeTruckLadingSan(nCard, nHost.FTunnel, nHost.FOptions.Values['TunnelEx'])
      else
        MakeTruckLadingSan(nCard, nHost.FTunnel, '');
      {$ELSE}
        MakeTruckLadingSan(nCard, nHost.FTunnel, '');
      {$ENDIF}
    end
    else if (nCardType = sFlag_Provide) or (nCardType = sFlag_other) then
    begin
      MakeTruckAcceptance(nCard,nhost.FTunnel,nHost);
    end;
  end;
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard超时卡作出动作
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut退出.');
  {$ENDIF}

  {$IFDEF WDFH}
  if Assigned(nHost.FOptions) then
    gERelayManager.LineClose(nHost.FOptions.Values['TunnelEx']);
  Sleep(100);
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  if nHost.FETimeOut then
       gERelayManager.ShowTxt(nHost.FTunnel, '电子标签超出范围')
  else gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: 磁卡号
//Desc: 对nCardNo做自动出厂(模拟读头刷卡)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader,nExtReader: string;
begin
  {$IFDEF GGJC}
  nReader := gHardwareHelper.GetReaderLastOn(nCardNo,nExtReader);
  if nReader <> '' then
    gHardwareHelper.SetReaderCard(nReader, nCardNo);
  //模拟刷卡
  {$ELSE}
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo,nExtReader);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //模拟刷卡
  end;
  {$ENDIF}
end;

//Date: 2012-12-16
//Parm: 共享数据
//Desc: 处理业务中间件与硬件守护的交互数据
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('收到Bus_MIT业务请求:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2013-07-17
//Parm: 计数器通道
//Desc: 保存nTunnel计数结果
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

//Date: 2017-11-05
//Parm: 车辆
//Desc: 查询nTruck所在道并与虚拟道匹配
function VerifyTruckTunnel(const nTruck: string; nTunnelEx: string):Boolean;
var nStr: string;
   nWorker: PDBWorker;
begin
  Result := False;
  if nTunnelEx = '' then Exit;

  nWorker := nil;
  try
    nStr := 'Select T_Line From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if Length(nStr) > 0 then
      begin
        if nTunnelEx = nStr then
          Result := True;
      end;
      //xxxxx
    end;

  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

end.
