{
   by lih 2016-06-29
   功能：同步AX基础表数据到DL
}
unit USyncAXBaseInfo;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBusiness;

const LessMark    = '<=';
const GreaterMark = '>';

type
  TAXSyncer = class;
  TAXSyncThread = class(TThread)
  private
    FOwner: TAXSyncer;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FNumAXSync: Integer;
    //提货单同步计时计数
    FNumPoundSync: Integer;
    //磅单同步计时计数
    //FNumAXBASESync: Integer;
    //基础表同步计数计时
    FNumFaildDataSync: Integer;
    //基础表同步计数计时
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    function GetOnLineModel: string;
    //获取在线模式
    procedure DoNewAXSync;
    procedure DoNewBillSyncAX(nMark :string);
    procedure DoDelBillSyncAX(nMark :string);
    procedure DoEmptyBillSyncAX(nMark :string);
    procedure DoPoundSyncAX(nMark :string);
    procedure DoPurSyncAX(nMark :string);
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TAXSyncer);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TAXSyncer = class(TObject)
  private
    FThread: TAXSyncThread;
    //扫描线程
  public
    SyncTime:string;
    //设定同步时间
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
    procedure LoadConfig(const nFile:string);//载入配置文件
  end;

var
  gAXSyncer: TAXSyncer = nil;
  //全局使用


implementation
procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TAXSyncer, 'AX数据同步', nMsg);
end;

constructor TAXSyncer.Create;
begin
  FThread := nil;
end;

destructor TAXSyncer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TAXSyncer.Start;
begin
  if not Assigned(FThread) then
    FThread := TAXSyncThread.Create(Self);
  FThread.Wakeup;
end;

procedure TAXSyncer.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//载入nFile配置文件
procedure TAXSyncer.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nTime: TDateTime;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      SyncTime:= nNode.NodeByName('SyncTime').ValueAsString;
      nTime:= StrToTime(SyncTime);
      SyncTime:= formatdatetime('hh:mm',nTime);
    except
      SyncTime:= '00:00';
    end;
    gCompanyAct:= nNode.NodeByName('CompanyAct').ValueAsString;
    nTmp := nNode.NodeByName('URLAddr');
    if Assigned(nTmp) then
      gURLAddr := nTmp.ValueAsString
    else
      gURLAddr := '';
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TAXSyncThread.Create(AOwner: TAXSyncer);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60*1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_AX_Sync');
  //process sync
end;

destructor TAXSyncThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;
  
  FSyncLock.Free;
  inherited;
end;

procedure TAXSyncThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TAXSyncThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TAXSyncThread.Execute;
var nErr: Integer;
    nInit: Int64;
    nModel: string;
begin
  FNumAXSync    := 0;
  //init counter
  FNumPoundSync:=0;
  //FNumAXBASESync:=0;
  FNumFaildDataSync := 0;
  
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumAXSync);
    //inc counter
    Inc(FNumPoundSync);
    //Inc(FNumAXBASESync);
    Inc(FNumFaildDataSync);

    if FNumAXSync >= 3 then
      FNumAXSync := 0;
    //同步提货单到AX: 10次/小时
    if FNumPoundSync>=5 then
      FNumPoundSync:=0;
    //同步磅单到AX: 6次/小时
    {if FNumAXBASESync>=30 then
      FNumAXBASESync:=0; }
    //同步基础信息
    if FNumFaildDataSync>=720 then
      FNumFaildDataSync:=0;
    //同步失败数据到AX: 1次/12小时

    if (FNumAXSync <> 0) and (FNumPoundSync<>0) and (FNumFaildDataSync<>0) then Continue; //and (FNumAXBASESync<>0)
    //无业务可做

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      nModel := GetOnLineModel;

      if FNumAXSync = 0 then
      begin
        if nModel = sFlag_Yes then
        begin
          WriteLog('同步提货单到AX...');
          nInit := GetTickCount;
          DoNewBillSyncAX(LessMark);
          DoDelBillSyncAX(LessMark);
          DoEmptyBillSyncAX(LessMark);
          WriteLog('同步提货单到AX完毕,耗时: ' + IntToStr(GetTickCount - nInit));
        end else
        begin
          WriteLog('离线模式');
        end;
      end;

      if FNumPoundSync = 0 then
      begin
        if nModel = sFlag_Yes then
        begin
          WriteLog('同步磅单到AX...');
          nInit := GetTickCount;
          DoPoundSyncAX(LessMark);
          DoPurSyncAX(LessMark);
          //DoDuanSyncAX;
          WriteLog('同步磅单到AX完毕,耗时: ' + IntToStr(GetTickCount - nInit));
        end else
        begin
          WriteLog('离线模式');
        end;
      end;

      if FNumFaildDataSync = 0 then
      begin
        if nModel = sFlag_Yes then
        begin
          WriteLog('同步失败提货单到AX...');
          nInit := GetTickCount;
          DoNewBillSyncAX(GreaterMark);
          DoDelBillSyncAX(GreaterMark);
          DoEmptyBillSyncAX(GreaterMark);
          WriteLog('同步失败提货单到AX完毕,耗时: ' + IntToStr(GetTickCount - nInit));

          WriteLog('同步失败磅单到AX...');
          nInit := GetTickCount;
          DoPoundSyncAX(GreaterMark);
          DoPurSyncAX(GreaterMark);
          WriteLog('同步失败磅单到AX完毕,耗时: ' + IntToStr(GetTickCount - nInit));
        end else
        begin
          WriteLog('离线模式');
        end;
      end;

      {if FNumAXBASESync=0 then
      begin
        WriteLog('同步AX基础表数据...');
        nInit := GetTickCount;
        DoNewAXSync;
        WriteLog('同步AX基础表完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      end; }
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//获取在线模式
function TAXSyncThread.GetOnLineModel: string;
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
    WriteLog('OnLineModel: '+Result);
  end;
end;

//Date: 2016-07-09
//lih: 同步提货单到AX
procedure TAXSyncThread.DoNewBillSyncAX(nMark :string);
var
  nErr: Integer;
  nSQL,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    {$IFDEF GGJC}
    nSQL := 'select L_ID From '+sTable_Bill+' where (L_EmptyOut<>''Y'') '+
            'and ((L_FYAX <> ''1'') or (L_FYAX is null)) '+
            'and (L_PDate is not null) '+
            'and L_FYNUM'+ nMark +'3 ';
    {$ELSE}
    nSQL := 'select L_ID From %s where (L_EmptyOut<>''Y'') '+
            'and ((L_FYAX <> ''1'') or (L_FYAX is null)) '+
            'and (L_PDate is not null) '+
            'and L_FYNUM'+ nMark +'3 ';
    nSQL := Format(nSQL,[sTable_Bill]);
    {$ENDIF}

    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('无提货单同步数据');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncFYBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'提货单同步失败');
        end; 
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('同步提货单错误'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: 同步已删除提货单到AX
procedure TAXSyncThread.DoDelBillSyncAX(nMark :string);
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select L_ID From %s where (L_FYAX = ''1'') and (L_FYDEL = ''0'') and L_FYDELNUM'+ nMark +'3 ';
    nSQL := Format(nSQL,[sTable_BillBak]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('无删除提货单同步数据');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncDelSBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'已删提货单同步失败');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('同步已删提货单错误'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: 同步空车出厂提货单到AX
procedure TAXSyncThread.DoEmptyBillSyncAX(nMark :string);
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;

    nSQL := 'select L_ID From %s where (L_EmptyOut=''Y'') and '+
            '(L_FYAX = ''1'') and '+
            '((L_EOUTAX <> ''1'') or (L_EOUTAX is null)) and '+
            'L_EOUTNUM'+ nMark +'3 ';
    nSQL := Format(nSQL,[sTable_Bill]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('无空车出厂提货单同步数据');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncEmpOutBillAX,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'空车出厂提货单同步失败');
        end; 
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('同步空车出厂提货单错误'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: 同步销售磅单到AX
procedure TAXSyncThread.DoPoundSyncAX(nMark :string);
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select L_ID From %s '+
            'where (L_Status=''O'') and '+
            '(L_EmptyOut <> ''Y'') and '+
            '((L_BDAX <> ''1'') or (L_BDAX is null)) and '+
            '(L_BDAX <> ''2'') and '+
            '(L_FYAX=''1'') and L_BDNUM'+ nMark +'3 ';
    nSQL := Format(nSQL,[sTable_Bill]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('无销售磅单同步数据');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('L_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'销售磅单同步失败');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('同步销售磅单错误'+e.Message);
    end;
  end;
end;

//Date: 2016-07-09
//lih: 同步采购磅单到AX
procedure TAXSyncThread.DoPurSyncAX(nMark :string);
var
  nErr: Integer;
  nSql,nStr: string;
  nOut: TWorkerBusinessCommand;
  nIdx:Integer;
begin
  try
    FListA.Clear;
    nSQL := 'select D_ID From %s '+
            'where (D_Status=''O'') and '+
            '((D_BDAX <> ''1'') or (D_BDAX is null)) and '+
            'D_BDNUM'+ nMark +'3 '+ ' and ( D_YSResult = ''%s'' or D_YSResult is null) ';
    nSQL := Format(nSQL,[sTable_OrderDtl, sFlag_Yes]);
    with gDBConnManager.WorkerQuery(FDBConn,nSql) do
    begin
      if RecordCount<1 then
      begin
        WriteLog('无采购磅单同步数据');
        Exit;
      end;
      First;
      while not Eof do
      begin
        FListA.Add(FieldByName('D_ID').AsString);
        Next;
      end;
    end;
    if FListA.Count>0 then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder,FListA[nIdx],'',@nOut) then
        begin
          WriteLog(FListA[nIdx]+'采购磅单同步失败');
        end;
      end;
    end;
  except
    on e:Exception do
    begin
      WriteLog('同步采购磅单错误'+e.Message);
    end;
  end;
end;

//Date: 2016-06-29
//lih: 同步AX基础表信息
procedure TAXSyncThread.DoNewAXSync;
var
  nSql,nStr: string;
  nMsg:WideString;
  nOut: TWorkerBusinessCommand;
begin
  try
    if not TWorkerBusinessCommander.CallMe(cBC_SyncCustomer,'','',@nOut) then
    begin
      WriteLog('客户信息同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncTprGem,'','',@nOut) then
    begin
      WriteLog('信用额度（客户）信息同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncTprGemCont,'','',@nOut) then
    begin
      WriteLog('信用额度（客户-合同）信息同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesOrder,'','',@nOut) then
    begin
      WriteLog('销售订单同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesOrdLine,'','',@nOut) then
    begin
      WriteLog('销售订单行同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSupAgreement,'','',@nOut) then
    begin
      WriteLog('补充协议同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesCont,'','',@nOut) then
    begin
      WriteLog('销售合同同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesContLine,'','',@nOut) then
    begin
      WriteLog('销售合同行同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesCont,'','',@nOut) then
    begin
      WriteLog('销售合同同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetSalesContLine,'','',@nOut) then
    begin
      WriteLog('销售合同行同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetPurOrder,'','',@nOut) then
    begin
      WriteLog('采购订单同步失败');
    end;
    if not TWorkerBusinessCommander.CallMe(cBC_GetPurOrdLine,'','',@nOut) then
    begin
      WriteLog('采购订单行行同步失败');
    end;
    {$IFDEF DEBUG}
    //WriteLog(nSql);
    {$ENDIF}
  except
    on e:Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
end;

initialization
  gAXSyncer := nil;
finalization
  FreeAndNil(gAXSyncer);
end.

