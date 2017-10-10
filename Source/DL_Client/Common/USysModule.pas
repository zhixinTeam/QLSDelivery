{*******************************************************************************
  作者: dmzn@163.com 2009-6-25
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface
                 
uses
  UClientWorker, UMITPacker,
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFormBaseInfo, UFrameAuthorize, UFormAuthorize, //UFormOptions,
  UFrameCustomer, UFormCustomer, UFormGetCustom, UFrameSaleContract, UFormSaleContract,
  UFrameZhiKa, UFormZhiKa, UFormGetContract, UFormZhiKaAdjust, UFormZhiKaFixMoney,
  UFrameZhiKaVerify, UFormZhiKaVerify, UFrameCustomerCredit, UFormCustomerCredit,
  UFrameCusAccount, UFrameCusInOutMoney, UFormGetZhiKa, UFrameBill, UFormReadCard,
  UFormTruckEmpty, UFormBill, UFormGetTruck, UFrameZhiKaDetail, UFormZhiKaFreeze,
  UFormZhiKaPrice, UFrameQueryDiapatch, UFrameTruckQuery, UFrameBillCard,
  UFormCard, UFormTruckIn, UFormTruckOut, UFormLadingDai, UFormLadingSan,
  UFramePoundManual, UFramePoundAuto, UFramePMaterails, UFormPMaterails,
  UFramePProvider, UFormPProvider, UFramePoundQuery, UFrameQuerySaleDetail,
  UFrameZTDispatch, UFrameTrucks, UFormTruck, UFormRFIDCard,

  UFramePurchaseOrder, UFormPurchaseOrder, UFormPurchasing,
  UFrameQueryOrderDetail, UFrameOrderCard,  UFrameOrderDetail,
  UFormGetProvider, UFormGetMeterails, UFramePOrderBase, UFormPOrderBase,
  UFormGetPOrderBase, UFrameDeduct, UFormDeduct, UFormGetNCStock,
  //----------------------------------------------------------------------------
  UFormHYStock, UFormHYData, UFormHYRecord, UFormGetStockNo,
  UFrameHYStock, UFrameHYData, UFrameHYRecord, UFormAXBaseLoad, UFormSiteConfirm,
  //by lih 2016-05-26 //2016-07-18
  UFormPurchReject,//原材料拒收
  UFormOnLineModel,//设置在线离线状态
  UFrameUpInfo, UFramePoundWuCha, UFormPWuCha, UFrameZTQuery, UFormPoundKw,
  UFormWorkSet, UFrameUpPurchase, UFramePoundDevia, UFrameLSCard, UFormLSCard,
  UFormTransfer, UFrameQueryTransferDetail, UFrameSTCard, UFormSTCard,
  uFormGetWechartAccount, UFormQLSBill, UFormAXBaseLoadS, UFormAXBaseLoadP,
  UFrameYSLines, UFormYSLine;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  UMgrChannel, UChannelChooser, UDataModule, USysDB, USysMAC, SysUtils,
  USysLoger, USysConst, UMemDataPool;

//Desc: 初始化系统对象
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel

  gMemDataManager := TMemDataManager.Create;
  //mem pool
end;

//Desc: 运行系统对象
procedure RunSystemObject;
var nStr: string;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
  end;

  nStr := 'Select W_Factory,W_Serial From %s ' +
          'Where W_MAC=''%s'' And W_Valid=''%s''';
  nStr := Format(nStr, [sTable_WorkePC, gSysParam.FLocalMAC, sFlag_Yes]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FFactNum := Fields[0].AsString;
    gSysParam.FSerialID := Fields[1].AsString;
  end;

  //----------------------------------------------------------------------------
  with gSysParam do
  begin
    FPoundDaiZ := 0;
    FPoundDaiF := 0;
    FPoundSanF := 0;
    FDaiWCStop := False;
    FDaiPercent := False;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PDaiWuChaZ then
        gSysParam.FPoundDaiZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiWuChaF then
        gSysParam.FPoundDaiF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiPercent then
        gSysParam.FDaiPercent := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PDaiWuChaStop then
        gSysParam.FDaiWCStop := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PSanWuChaF then
        gSysParam.FPoundSanF := Fields[0].AsFloat;

      if nStr = sFlag_PEmpTWuCha then
        gSysParam.FEmpTruckWc := Fields[0].AsFloat;
        
      Next;
    end;

    with gSysParam do
    begin
      FPoundDaiZ_1 := FPoundDaiZ;
      FPoundDaiF_1 := FPoundDaiF;
      //backup wucha value
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      gChannelChoolser.AddChannelURL(Fields[0].AsString);
      Next;
    end;

    {$IFNDEF DEBUG}
    gChannelChoolser.StartRefresh;
    {$ENDIF}//update channel
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FHardMonURL := Fields[0].AsString;
  end;

  nStr := 'select D_value from %s where D_Name=''%s''';
  nStr := Format(nStr,[sTable_SysDict,sFlag_Factoryid]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FFactory := FieldByName('D_value').AsString;
  end;

end;

//Desc: 释放系统对象
procedure FreeSystemObject;
begin
  FreeAndNil(gSysLoger);
end;

end.
