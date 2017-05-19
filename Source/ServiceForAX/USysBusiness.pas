{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 系统业务处理
*******************************************************************************}
unit USysBusiness;

interface
{$I Link.inc}
uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, USysLoger, uDM, USysDB, NativeXml,
  fServerForm, UMITConst, UMgrParam, UMgrDBConn;

procedure WriteLog(const nEvent: string);
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
function GetAXSalesOrder(const XMLPrimaryKey: Widestring): Boolean;//获取销售订单
function GetAXSalesOrdLine(const XMLPrimaryKey: Widestring): Boolean;//获取销售订单行
function GetAXSupAgreement(const XMLPrimaryKey: Widestring): Boolean;//获取补充协议
function GetAXCreLimCust(const XMLPrimaryKey: Widestring): Boolean;//获取信用额度增减（客户）
function GetAXCreLimCusCont(const XMLPrimaryKey: Widestring): Boolean;//获取信用额度增减（客户-合同）
function GetAXSalesContract(const XMLPrimaryKey: Widestring): Boolean;//获取销售合同
function GetAXSalesContLine(const XMLPrimaryKey: Widestring): Boolean;//获取销售合同行
function GetAXVehicleNo(const XMLPrimaryKey: Widestring): Boolean;//获取车号
function GetAXPurOrder(const XMLPrimaryKey: Widestring): Boolean;//获取采购订单
function GetAXPurOrdLine(const XMLPrimaryKey: Widestring): Boolean;//获取采购订单行
function CalCreLimCust(const nCustAcc, nDataAreaID, nRecId: string): Boolean;//计算信用额度（客户）
function CalCreLimCusCont(const nCustAcc, nDataAreaID, nContractId, nRecId :string): Boolean;//计算信用额度（客户-合同）
function LoadAXCustomer(const nCusID,nDataAreaID:string):Boolean;//下载三角贸易客户信息
function LoadAXSalesContract(const nContactId,nDataAreaID:string):Boolean;//下载三角贸易合同信息
function LoadAXSalesContLine(const nContactId,nDataAreaID:string):Boolean;//下载三角贸易合同行信息
function GetAXCustomer(const XMLPrimaryKey: Widestring):Boolean;//获取客户信息
function GetAXMaterails(const XMLPrimaryKey: Widestring):Boolean;//获取物料信息
function GetAXProviders(const XMLPrimaryKey: Widestring):Boolean;//获取供应商信息
function SetOnLineModel(nModel:Boolean):Boolean;//设置在线模式
function GetOnLineModel:Boolean;//获取在线模式
function GetAXTPRESTIGEMANAGE(const nCustAcc, nDataAreaID: string): Boolean;//在线获取信用额度（客户）
function GetAXTPRESTIGEMBYCONT(const nCustAcc, nDataAreaID, nContractId :string): Boolean;//在线获取信用额度（客户-合同）
//function GetAXLocationID(const XMLPrimaryKey: Widestring):Boolean;//获取仓库ID
//function GetAXCenterID(const XMLPrimaryKey: Widestring):Boolean;//获取生产线ID
function UpdateYKAmount(const XMLPrimaryKey: Widestring): Boolean;//更新预扣金额
function GetThInfo(const XMLPrimaryKey: Widestring):Boolean; //获取提货单信息
function GetPurchInfo(const XMLPrimaryKey: Widestring):Boolean; //获取采购单信息

implementation

//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  with ServerForm do
  begin
    if chkShowLog.Checked then
    begin
      if mmo1.Lines.Count > 50 then mmo1.Lines.Clear;
      mmo1.Lines.Add('['+FormatDateTime('yyyy-mm-dd hh:mm:ss',Now)+']'+nEvent);
    end;
  end;
  gSysLoger.AddLog(TServerForm,'数据接收日志',nEvent);
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

//Date: 2016-06-29
//获取AX销售订单
function GetAXSalesOrder(const XMLPrimaryKey: Widestring): Boolean;
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nSalesId,nRecid,nDataAreaID,nInnerOrderQY,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nSalesId:= nNode.NodeByName('SalesId').ValueAsString;   //订单ID
    except
      nSalesId:= '';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;       //行ID
    except
      nRecid:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString; //账套
    except
      nDataAreaID:='';
    end;
    try
      nInnerOrderQY:= nNode.NodeByName('innerOrderQY').ValueAsString; //最终销售区域
    except
      nInnerOrderQY:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nSalesId='') or (nRecid='') or (nDataAreaID='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where SalesId=''%s'' and DataAreaID=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_Sales, nSalesId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的销售订单不存在.';
            nStr := Format(nStr, [nSalesId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['Z_ID']:= FieldByName('SalesId').AsString;
            Values['Z_Name']:= FieldByName('SalesName').AsString;
            Values['Z_CID']:= FieldByName('CMT_ContractNo').AsString;
            Values['Z_Customer']:= FieldByName('CustAccount').AsString;
            if (Pos('1900',FieldByName('FixedDueDate').AsString)>0) then
              Values['Z_ValidDays']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now+1)
            else
              Values['Z_ValidDays']:= FieldByName('FixedDueDate').AsString;
            Values['Z_SalesStatus']:= FieldByName('salesstatus').AsString;
            Values['Z_SalesType']:= FieldByName('SalesType').AsString;
            Values['Z_TriangleTrade']:= FieldByName('CMT_TriangleTrade').AsString;
            Values['Z_OrgAccountNum']:= FieldByName('CMT_OrgAccountNum').AsString;
            Values['Z_OrgAccountName']:= FieldByName('CMT_OrgAccountName').AsString;
            Values['Z_IntComOriSalesId']:= FieldByName('InterCompanyOriginalSalesId').AsString;
            Values['Z_XSQYBM']:= FieldByName('XSQYBM').AsString;
            Values['Z_KHSBM']:= FieldByName('CMT_KHSBM').AsString;
            Values['Z_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
            Values['Z_Lading']:= FieldByName('XTFreightNew').AsString;
            Values['Z_CompanyId']:= FieldByName('InterCompanyCompanyId').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where Z_ID=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_ZhiKa, nSalesId, nDataAreaID]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set Z_Name='''+Values['Z_Name']+
                  ''',Z_CID='''+Values['Z_CID']+
                  ''',Z_Customer='''+Values['Z_Customer']+
                  ''',Z_ValidDays='''+Values['Z_ValidDays']+
                  ''',Z_SalesStatus='''+Values['Z_SalesStatus']+
                  ''',Z_SalesType='''+Values['Z_SalesType']+
                  ''',Z_TriangleTrade='''+Values['Z_TriangleTrade']+
                  ''',Z_OrgAccountNum='''+Values['Z_OrgAccountNum']+
                  ''',Z_OrgAccountName='''+Values['Z_OrgAccountName']+
                  ''',Z_IntComOriSalesId='''+Values['Z_IntComOriSalesId']+
                  ''',Z_Date='''+Values['Z_Date']+
                  ''',Z_XSQYBM='''+Values['Z_XSQYBM']+
                  ''',Z_KHSBM='''+Values['Z_KHSBM']+
                  ''',Z_Lading='''+Values['Z_Lading']+
                  ''',Z_CompanyId='''+Values['Z_CompanyId']+
                  ''',Z_OrgXSQYBM='''+nInnerOrderQY+
                  ''' where Z_ID=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_ZhiKa, nSalesId, nDataAreaID]);
          end else
          begin
            nStr:= 'Insert into %s (Z_ID,Z_Name,Z_CID,Z_Customer,Z_ValidDays,'+
                   'Z_SalesStatus,Z_SalesType,Z_TriangleTrade,Z_OrgAccountNum,'+
                   'Z_OrgAccountName,Z_IntComOriSalesId,Z_Date,Z_Lading,Z_CompanyId,'+
                   'Z_XSQYBM,Z_KHSBM,Z_OrgXSQYBM,DataAreaID) '+
                   'values ('''+Values['Z_ID']+''','''+Values['Z_Name']+''','''+
                   Values['Z_CID']+''','''+Values['Z_Customer']+''','''+
                   Values['Z_ValidDays']+''','''+Values['Z_SalesStatus']+''','''+
                   Values['Z_SalesType']+''','''+Values['Z_TriangleTrade']+''','''+
                   Values['Z_OrgAccountNum']+''','''+Values['Z_OrgAccountName']+''','''+
                   Values['Z_IntComOriSalesId']+''','''+Values['Z_Date']+''','''+
                   Values['Z_Lading']+''','''+Values['Z_CompanyId']+''','''+
                   Values['Z_XSQYBM']+''','''+Values['Z_KHSBM']+''','''+
                   nInnerOrderQY+''','''+nDataAreaID+''')';
            nStr := Format(nStr, [sTable_ZhiKa]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
      qryRem.Active:=False;
    end;
  end;
end;

function GetAXSalesOrdLine(const XMLPrimaryKey: Widestring): Boolean;//获取销售订单行
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nSalesId,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nSalesId:= nNode.NodeByName('SalesId').ValueAsString;
    except
      nSalesId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nSalesId='') or (nDataAreaID='') or (nRecid='')  then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where SalesId=''%s'' and DataAreaID=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_SalLine, nSalesId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的销售订单行不存在.';
            nStr := Format(nStr, [nSalesId]);
            Result := True;
            Exit;
          end;
          with FListA do
          begin
            Values['D_ZID']:= FieldByName('SalesId').AsString;
            if FieldByName('CMT_PACKTYPE').AsString='1' then
              Values['D_Type']:='D'
            else if FieldByName('CMT_PACKTYPE').AsString='2' then
              Values['D_Type']:='S'
            else
              Values['D_Type']:= FieldByName('CMT_PACKTYPE').AsString;
            Values['D_StockNo']:= UpperCase(FieldByName('ItemId').AsString);
            Values['D_StockName']:= FieldByName('Name').AsString;
            Values['D_SalesStatus']:= FieldByName('SalesStatus').AsString;
            Values['D_Price']:= FieldByName('SalesPrice').AsString;
            Values['D_Value']:= FieldByName('RemainSalesPhysical').AsString;
            Values['D_Blocked']:= FieldByName('Blocked').AsString;
            Values['D_Memo']:= FieldByName('CMT_Notes').AsString;
            Values['D_TotalValue']:= FieldByName('SalesQty').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where D_ZID=''%s'' and DataAreaID=''%s'' and D_RECID=''%s'' ';
          nStr := Format(nStr, [sTable_ZhiKaDtl, nSalesId, nDataAreaID, nRecid]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set D_Type='''+Values['D_Type']+
                  ''',D_StockNo='''+Values['D_StockNo']+
                  ''',D_StockName='''+Values['D_StockName']+
                  ''',D_SalesStatus='''+Values['D_SalesStatus']+
                  ''',D_Price='''+Values['D_Price']+
                  ''',D_TotalValue='''+Values['D_TotalValue']+
                  ''',D_Blocked='''+Values['D_Blocked']+
                  ''',D_Memo='''+Values['D_Memo']+
                  ''' where D_ZID=''%s'' and DataAreaID=''%s'' and D_RECID=''%s'' ';
            nStr := Format(nStr, [sTable_ZhiKaDtl, nSalesId, nDataAreaID, nRecid]);
          end else
          begin
            nStr:= 'Insert into %s (D_ZID,D_Type,D_StockNo,D_StockName,'+
                   'D_SalesStatus,D_Price,D_Value,D_TotalValue,D_Blocked,'+
                   'D_Memo,DataAreaID,D_RECID) '+
                   'values ('''+Values['D_ZID']+''','''+
                   Values['D_Type']+''','''+Values['D_StockNo']+''','''+
                   Values['D_StockName']+''','''+Values['D_SalesStatus']+''','''+
                   Values['D_Price']+''','''+Values['D_Value']+''','''+
                   Values['D_TotalValue']+''','''+
                   Values['D_Blocked']+''','''+Values['D_Memo']+''','''+
                   nDataAreaID+''','''+nRecid+''')';
            nStr := Format(nStr, [sTable_ZhiKaDtl]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
      qryRem.Active:=False;
    end;
  end;
end;

function GetAXSupAgreement(const XMLPrimaryKey: Widestring): Boolean;//获取补充协议
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nXTEadjustBillNum,nRefRecid,nDataAreaID,nRecId,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nXTEadjustBillNum:= nNode.NodeByName('XTEadjustBillNum').ValueAsString;
    except
      nXTEadjustBillNum:= '';
    end;
    try
      nRefRecid:= nNode.NodeByName('RefRecid').ValueAsString;
    except
      nRefRecid:='';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecId:= nNode.NodeByName('recid').ValueAsString;
    except
      nRecId:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nXTEadjustBillNum='') or (nRefRecid='') or (nDataAreaID='') or (nRecId='') then
  begin
    WriteLog(nXTEadjustBillNum+'|'+nRefRecid+'|'+nDataAreaID+'|'+nRecId);
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where XTEadjustBillNum=''%s'' and RefRecid=''%s'' and DataAreaID=''%s'' and RecId=''%s'' ';
        nStr := Format(nStr, [sTable_AX_SupAgre, nXTEadjustBillNum, nRefRecid, nDataAreaID, nRecId]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的补充协议不存在.';
            nStr := Format(nStr, [nXTEadjustBillNum]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['A_SalesId']:= FieldByName('SalesId').AsString;
            Values['A_ItemId']:= UpperCase(FieldByName('ItemId').AsString);
            Values['A_SalesNewAmount']:= FieldByName('SalesNewAmount').AsString;
            Values['A_TakeEffectDate']:= FieldByName('TakeEffectDate').AsString;
            values['A_TakeEffectTime']:= FieldByName('TakeEffectTime').AsString;
            Values['A_Date']:=FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where A_XTEadjustBillNum=''%s'' and RefRecid=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_AddTreaty, nXTEadjustBillNum, nRefRecid, nDataAreaID]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set A_SalesId='''+Values['A_SalesId']+
                  ''',A_ItemId='''+Values['A_ItemId']+
                  ''',A_SalesNewAmount='''+Values['A_SalesNewAmount']+
                  ''',A_TakeEffectDate='''+Values['A_TakeEffectDate']+
                  ''',A_TakeEffectTime='''+Values['A_TakeEffectTime']+
                  ''',A_Date='''+Values['A_Date']+
                  ''' where A_XTEadjustBillNum=''%s'' and RefRecid=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_AddTreaty, nXTEadjustBillNum, nRefRecid, nDataAreaID]);
          end else
          begin
            nStr:= 'Insert into %s (A_XTEadjustBillNum,A_SalesId,A_ItemId,'+
                   'A_SalesNewAmount,A_TakeEffectDate,A_TakeEffectTime,'+
                   'RefRecid,Recid,DataAreaID,A_Date) '+
                   'values ('''+nXTEadjustBillNum+''','''+Values['A_SalesId']+''','''+
                   Values['A_ItemId']+''','''+Values['A_SalesNewAmount']+''','''+
                   Values['A_TakeEffectDate']+''','''+Values['A_TakeEffectTime']+''','''+
                   nRefRecid+''','''+nRecId+''','''+nDataAreaID+''','''+Values['A_Date']+''')';
            nStr := Format(nStr, [sTable_AddTreaty]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

function GetAXCreLimCust(const XMLPrimaryKey: Widestring): Boolean;//获取信用额度增减（客户）
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nCustAcc,nDataAreaID,nRecId,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nCustAcc:= nNode.NodeByName('CustAccount').ValueAsString;
    except
      nCustAcc:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecId:= nNode.NodeByName('RecId').ValueAsString;
    except
      nRecId:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nCustAcc='') or (nDataAreaID='') or (nRecId='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where CustAccount=''%s'' and DataAreaID=''%s'' and RecId=''%s'' ';
        nStr := Format(nStr, [sTable_AX_CreLimLog, nCustAcc, nDataAreaID, nRecId]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的信用额度增减记录不存在.';
            nStr := Format(nStr, [nCustAcc]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_CusID']:= FieldByName('CustAccount').AsString;
            Values['C_SubCash']:= FieldByName('XTSubCash').AsString;
            Values['C_SubThreeBill']:= FieldByName('XTSubThreeBill').AsString;
            Values['C_SubSixBil']:= FieldByName('XTSubSixBill').AsString;
            Values['C_SubTmp']:= FieldByName('XTSubTmp').AsString;
            values['C_SubPrest']:= FieldByName('PRESTIGEQUOTA').AsString;
            Values['C_Createdby']:= FieldByName('Createdby').AsString;
            Values['C_Createdate']:= FieldByName('Createddatetime').AsString;
            //Values['C_Createtime']:= FieldByName('createdtime').AsString;
            Values['C_YKAmount']:= FieldByName('YKAmount').AsString;
            Values['C_TransPlanID']:= FieldByName('CMT_TransPlanID').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' and RecID=''%s'' ';
          nStr := Format(nStr, [sTable_CustPresLog, nCustAcc, nDataAreaID, nRecId]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount<1 then
          begin
            nStr:= 'Insert into %s (C_CusID,C_SubCash,C_SubThreeBill,'+
                   'C_SubSixBil,C_SubTmp,C_SubPrest,C_Createdby,'+
                   'C_YKAmount,C_TransPlanID,'+
                   'C_Createdate,DataAreaID,RecID) '+
                   'values ('''+Values['C_CusID']+''','''+Values['C_SubCash']+''','''+
                   Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                   Values['C_SubTmp']+''','''+Values['C_SubPrest']+''','''+
                   Values['C_Createdby']+''','''+
                   Values['C_YKAmount']+''','''+Values['C_TransPlanID']+''','''+
                   Values['C_Createdate']+''','''+
                   nDataAreaID+''','''+nRecId+''')';
            nStr := Format(nStr, [sTable_CustPresLog]);
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            ExecSQL;
          end;
          Result:=True;
          //if GetAXTPRESTIGEMANAGE(nCustAcc, nDataAreaID) then  WriteLog('['+nCustAcc+']在线获取信用额度（客户）成功');
          if CalCreLimCust(nCustAcc, nDataAreaID, nRecId) then  WriteLog('['+nCustAcc+']计算信用额度（客户）成功');
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//在线获取信用额度（客户）
function GetAXTPRESTIGEMANAGE(const nCustAcc, nDataAreaID: string): Boolean;
var nStr: string;
    FListA:TStrings;
begin
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s '+
                'where CustAccount=''%s'' and DataAreaID=''%s'' ';
        nStr := Format(nStr, [sTable_AX_TPRESTIGEMANAGE, nCustAcc, nDataAreaID]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的客户信用额度记录不存在.';
            nStr := Format(nStr, [nCustAcc]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_CusID']:= FieldByName('CustAccount').AsString;
            Values['C_SubCash']:= FieldByName('CashBalance').AsString;
            Values['C_SubThreeBill']:= FieldByName('BillBalanceThreeMonths').AsString;
            Values['C_SubSixBil']:= FieldByName('BillBalancesixMonths').AsString;
            Values['C_SubTmp']:= FieldByName('TemporaryBalance').AsString;
            values['C_SubPrest']:= FieldByName('PrestigeQuota').AsString;
            Values['C_YKAmount']:= FieldByName('YKAMOUNT').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_CusCredit, nCustAcc, nDataAreaID]);
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_CashBalance=%s,'+
                  'C_BillBalance3M=%s,'+
                  'C_BillBalance6M=%s,'+
                  'C_TemporBalance=%s,'+
                  'C_PrestigeQuota=%s,'+
                  'C_Date=''%s'' '+
                  ' where C_CusID=''%s'' and DataAreaID=''%s'' ';
            nStr:=Format(nStr, [sTable_CusCredit, Values['C_SubCash'],
                                Values['C_SubThreeBill'], Values['C_SubSixBil'],
                                Values['C_SubTmp'], values['C_SubPrest'],
                                Values['C_Date'], nCustAcc, nDataAreaID]);
          end else
          begin
            nStr:='insert into %s (C_CusID,C_CashBalance,C_BillBalance3M,'+
                  'C_BillBalance6M,C_TemporBalance,C_PrestigeQuota,C_Date,'+
                  'DataAreaID) '+
                  'values ('''+nCustAcc+''','''+Values['C_SubCash']+''','''+
                  Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                  Values['C_SubTmp']+''','''+values['C_SubPrest']+''','''+
                  Values['C_Date']+''','''+nDataAreaID+''')';
            nStr:=Format(nStr, [sTable_CusCredit]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          nStr:='Update %s Set A_FreezeMoney=%s Where A_CID=''%s''';
          nStr:= Format(nStr, [sTable_CusAccount, Values['C_YKAmount'], nCustAcc]);
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;


function CalCreLimCust(const nCustAcc, nDataAreaID, nRecId: string): Boolean;//计算信用额度（客户）
var nStr,nLID: string;
    FListA: TStrings;
    nAXYKMouney,nYKMouney: Double;
begin
  FListA:=TStringList.Create;
  try
    with DM.qryLoc do
    begin
      try
        FListA.Clear;
        nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' and RecID=''%s'' ';
        nStr := Format(nStr, [sTable_CustPresLog, nCustAcc, nDataAreaID, nRecId]);
        Close;
        SQL.Text:=nStr;
        Open;
        if RecordCount>0 then
        begin
          with FListA do
          begin
            Values['C_SubCash']:= FieldByName('C_SubCash').AsString;
            Values['C_SubThreeBill']:= FieldByName('C_SubThreeBill').AsString;
            Values['C_SubSixBil']:= FieldByName('C_SubSixBil').AsString;
            Values['C_SubTmp']:= FieldByName('C_SubTmp').AsString;
            values['C_SubPrest']:= FieldByName('C_SubPrest').AsString;
            Values['C_YKAmount']:= FieldByName('C_YKAmount').AsString;
            Values['C_TransPlanID']:= FieldByName('C_TransPlanID').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
            Values['C_Man']:=FieldByName('C_Createdby').AsString;

            nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_CusCredit, nCustAcc, nDataAreaID]);
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            Open;
            if RecordCount>0 then
            begin
              nStr:='update %s set C_CashBalance=C_CashBalance+(%s),'+
                    'C_BillBalance3M=C_BillBalance3M+(%s),'+
                    'C_BillBalance6M=C_BillBalance6M+(%s),'+
                    'C_TemporBalance=C_TemporBalance+(%s),'+
                    'C_PrestigeQuota=C_PrestigeQuota+(%s),'+
                    'C_Date=''%s'',C_Man=''%s'' '+
                    ' where C_CusID=''%s'' and DataAreaID=''%s'' ';
              nStr:=Format(nStr, [sTable_CusCredit, Values['C_SubCash'],
                                  Values['C_SubThreeBill'], Values['C_SubSixBil'],
                                  Values['C_SubTmp'], values['C_SubPrest'],
                                  Values['C_Date'], Values['C_Man'],
                                  nCustAcc, nDataAreaID]);
            end else
            begin
              nStr:='insert into %s (C_CusID,C_CashBalance,C_BillBalance3M,'+
                    'C_BillBalance6M,C_TemporBalance,C_PrestigeQuota,C_Date,'+
                    'C_Man,DataAreaID) '+
                    'values ('''+nCustAcc+''','''+Values['C_SubCash']+''','''+
                    Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                    Values['C_SubTmp']+''','''+values['C_SubPrest']+''','''+
                    Values['C_Date']+''','''+Values['C_Man']+''','''+
                    nDataAreaID+''')';
              nStr:=Format(nStr, [sTable_CusCredit]);
            end;
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            ExecSQL;
          end;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog('['+nCustAcc+']计算信用额度（客户）失败，'+e.Message);
        end;
      end;
    end;
  finally
    FListA.Free;
  end;
end;

function GetAXCreLimCusCont(const XMLPrimaryKey: Widestring): Boolean;//获取信用额度增减（客户-合同）
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nCustAcc,nDataAreaID,nContractId,nRecId,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nCustAcc:= nNode.NodeByName('CustAccount').ValueAsString;
    except
      nCustAcc:= '';
    end;
    try
      nTmp:= nNode.NodeByName('DataAreaID');
      if Assigned(nTmp) then
        nDataAreaID:= nTmp.ValueAsString
      else
        nDataAreaID:= nNode.NodeByName('companyid').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nContractId:= nNode.NodeByName('ContractId').ValueAsString;
    except
      nContractId:='';
    end;
    try
      nRecId:= nNode.NodeByName('RecId').ValueAsString;
    except
      nRecId:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nCustAcc='') or (nDataAreaID='') or (nContractId='') or (nRecId='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where CustAccount=''%s'' and DataAreaID=''%s'' and CMT_ContractId=''%s'' and RecId=''%s'' ';
        nStr := Format(nStr, [sTable_AX_ContCreLimLog, nCustAcc, nDataAreaID, nContractId, nRecId]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的信用额度增减记录(合同)不存在.';
            nStr := Format(nStr, [nCustAcc]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_CusID']:= FieldByName('CustAccount').AsString;
            Values['C_SubCash']:= FieldByName('XTSubCash').AsString;
            Values['C_SubThreeBill']:= FieldByName('XTSubThreeBill').AsString;
            Values['C_SubSixBil']:= FieldByName('XTSubSixBill').AsString;
            Values['C_SubTmp']:= FieldByName('XTSubTmp').AsString;
            values['C_SubPrest']:= FieldByName('PRESTIGEQUOTA').AsString;
            //Values['C_Subdate']:= FieldByName('XTSubdate').AsString;
            Values['C_Createdby']:= FieldByName('Createdby').AsString;
            Values['C_Createdate']:= FieldByName('Createddatetime').AsString;
            //Values['C_Createtime']:= FieldByName('createdtime').AsString;
            Values['C_ContractId']:=FieldByName('CMT_ContractId').AsString;
            Values['C_YKAmount']:= FieldByName('YKAmount').AsString;
            Values['C_TransPlanID']:= FieldByName('CMT_TransPlanID').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' and C_ContractId=''%s'' and RecId=''%s'' ';
          nStr := Format(nStr, [sTable_ContPresLog, nCustAcc, nDataAreaID, nContractId, nRecId]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount<1 then
          begin
            nStr:= 'Insert into %s (C_CusID,C_SubCash,C_SubThreeBill,'+
                   'C_SubSixBil,C_SubTmp,C_SubPrest,C_Createdby,C_Createdate,'+
                   'C_YKAmount,C_TransPlanID,C_ContractId,DataAreaID,RecId) '+
                   'values ('''+Values['C_CusID']+''','''+Values['C_SubCash']+''','''+
                   Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                   Values['C_SubTmp']+''','''+Values['C_SubPrest']+''','''+
                   Values['C_Createdby']+''','''+Values['C_Createdate']+''','''+
                   Values['C_YKAmount']+''','''+Values['C_TransPlanID']+''','''+
                   Values['C_ContractId']+''','''+nDataAreaID+''','''+nRecId+''')';
            nStr := Format(nStr, [sTable_ContPresLog]);
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            ExecSQL;
          end;
          Result:=True;
          {if GetAXTPRESTIGEMBYCONT(nCustAcc, nDataAreaID, nContractId) then
            WriteLog('['+nCustAcc+','+nContractId+']在线获取信用额度（客户-合同）成功'); }
          if CalCreLimCusCont(nCustAcc, nDataAreaID, nContractId, nRecId) then
            WriteLog('['+nCustAcc+','+nContractId+']计算信用额度（客户-合同）成功');
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//在线获取信用额度（客户-合同）
function GetAXTPRESTIGEMBYCONT(const nCustAcc, nDataAreaID, nContractId :string): Boolean;
var nStr: string;
    FListA:TStrings;
begin
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s '+
                'where CustAccount=''%s'' and CMT_ContractId=''%s'' and DataAreaID=''%s'' ';
        nStr := Format(nStr, [sTable_AX_TPRESTIGEMBYCONT, nCustAcc, nContractId, nDataAreaID]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的合同信用额度记录不存在.';
            nStr := Format(nStr, [nContractId]);
            Result := False;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_CusID']:= FieldByName('CustAccount').AsString;
            Values['C_SubCash']:= FieldByName('CashBalance').AsString;
            Values['C_SubThreeBill']:= FieldByName('BillBalanceThreeMonths').AsString;
            Values['C_SubSixBil']:= FieldByName('BillBalancesixMonths').AsString;
            Values['C_SubTmp']:= FieldByName('TemporaryBalance').AsString;
            values['C_SubPrest']:= FieldByName('PrestigeQuota').AsString;
            Values['C_YKAmount']:= FieldByName('YKAMOUNT').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_CusContCredit, nCustAcc, nContractId, nDataAreaID]);
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_CashBalance=%s,'+
                  'C_BillBalance3M=%s,'+
                  'C_BillBalance6M=%s,'+
                  'C_TemporBalance=%s,'+
                  'C_PrestigeQuota=%s,'+
                  'C_Date=''%s'' '+
                  ' where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
            nStr:=Format(nStr, [sTable_CusContCredit, Values['C_SubCash'],
                                Values['C_SubThreeBill'], Values['C_SubSixBil'],
                                Values['C_SubTmp'], values['C_SubPrest'],
                                Values['C_Date'], nCustAcc, nContractId, nDataAreaID]);
          end else
          begin
            nStr:='insert into %s (C_CusID,C_ContractId,C_CashBalance,C_BillBalance3M,'+
                  'C_BillBalance6M,C_TemporBalance,C_PrestigeQuota,C_Date,'+
                  'DataAreaID) '+
                  'values ('''+nCustAcc+''','''+nContractId+''','''+
                  Values['C_SubCash']+''','''+
                  Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                  Values['C_SubTmp']+''','''+values['C_SubPrest']+''','''+
                  Values['C_Date']+''','''+nDataAreaID+''')';
            nStr:=Format(nStr, [sTable_CusContCredit]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          nStr:='Update %s Set A_ConFreezeMoney=%s Where A_CID=''%s''';
          nStr:= Format(nStr, [sTable_CusAccount, Values['C_YKAmount'], nCustAcc]);
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;


function CalCreLimCusCont(const nCustAcc, nDataAreaID, nContractId, nRecId :string): Boolean;//计算信用额度（客户-合同）
var nStr,nLID: string;
    FListA: TStrings;
    nAXYKMouney,nYKMouney: Double;
begin
  FListA:=TStringList.Create;
  try
    with DM.qryLoc do
    begin
      try
        FListA.Clear;
        nStr:='select * from %s where C_CusID=''%s'' and DataAreaID=''%s'' and C_ContractId=''%s'' and RecId=''%s'' ';
        nStr := Format(nStr, [sTable_ContPresLog, nCustAcc, nDataAreaID, nContractId, nRecId]);
        Close;
        SQL.Text:=nStr;
        Open;
        if RecordCount>0 then
        begin
          with FListA do
          begin
            Values['C_SubCash']:= FieldByName('C_SubCash').AsString;
            Values['C_SubThreeBill']:= FieldByName('C_SubThreeBill').AsString;
            Values['C_SubSixBil']:= FieldByName('C_SubSixBil').AsString;
            Values['C_SubTmp']:= FieldByName('C_SubTmp').AsString;
            values['C_SubPrest']:= FieldByName('C_SubPrest').AsString;
            Values['C_YKAmount']:= FieldByName('C_YKAmount').AsString;
            Values['C_TransPlanID']:= FieldByName('C_TransPlanID').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
            Values['C_Man']:=FieldByName('C_Createdby').AsString;

            nStr:='select * from %s where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_CusContCredit, nCustAcc, nContractId, nDataAreaID]);
            Close;
            SQL.Text:=nStr;
            Open;
            if RecordCount>0 then
            begin
              nStr:='update %s set C_CashBalance=C_CashBalance+(%s),'+
                    'C_BillBalance3M=C_BillBalance3M+(%s),'+
                    'C_BillBalance6M=C_BillBalance6M+(%s),'+
                    'C_TemporBalance=C_TemporBalance+(%s),'+
                    'C_PrestigeQuota=C_PrestigeQuota+(%s),'+
                    'C_Date=''%s'',C_Man=''%s'' '+
                    ' where C_CusID=''%s'' and C_ContractId=''%s'' and DataAreaID=''%s'' ';
              nStr:=Format(nStr, [sTable_CusContCredit, Values['C_SubCash'],
                                  Values['C_SubThreeBill'], Values['C_SubSixBil'],
                                  Values['C_SubTmp'], values['C_SubPrest'],
                                  Values['C_Date'], Values['C_Man'],
                                  nCustAcc, nContractId, nDataAreaID]);
            end else
            begin
              nStr:='insert into %s (C_CusID,C_ContractId,C_CashBalance,C_BillBalance3M,'+
                    'C_BillBalance6M,C_TemporBalance,C_PrestigeQuota,C_Date,'+
                    'C_Man,DataAreaID) '+
                    'values ('''+nCustAcc+''','''+nContractId+''','''+
                    Values['C_SubCash']+''','''+
                    Values['C_SubThreeBill']+''','''+Values['C_SubSixBil']+''','''+
                    Values['C_SubTmp']+''','''+values['C_SubPrest']+''','''+
                    Values['C_Date']+''','''+Values['C_Man']+''','''+
                    nDataAreaID+''')';
              nStr:=Format(nStr, [sTable_CusContCredit]);
            end;
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            ExecSQL;
          end;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog('['+nCustAcc+','+nContractId+']计算信用额度（客户-合同）失败，'+e.Message);
        end;
      end;
    end;
  finally
    FListA.Free;
  end;
end;

function GetAXSalesContract(const XMLPrimaryKey: Widestring): Boolean;//获取销售合同
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nContactId,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nContactId:= nNode.NodeByName('ContactId').ValueAsString;
    except
      nContactId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nContactId='') or (nDataAreaID='') or (nRecid='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where ContactId=''%s'' and companyid=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_SalesCont, nContactId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的销售合同不存在.';
            nStr := Format(nStr, [nContactId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_ID']:= FieldByName('ContactId').AsString;
            Values['C_Customer']:= FieldByName('CUST').AsString;
            Values['C_CustName']:= FieldByName('custname').AsString;
            values['C_Addr']:= FieldByName('ContactAddress').AsString;
            Values['C_SFSP']:= FieldByName('CMT_SFSP').AsString;
            Values['C_ContType']:= FieldByName('xtEContractSuperType').AsString;
            Values['C_ContQuota']:= FieldByName('XTContactQuota').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_ID=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_SaleContract, nContactId, nDataAreaID]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_Customer='''+Values['C_Customer']+
                  ''',C_CustName='''+Values['C_CustName']+
                  ''',C_Addr='''+Values['C_Addr']+
                  ''',C_SFSP='''+Values['C_SFSP']+
                  ''',C_ContType='''+Values['C_ContType']+
                  ''',C_ContQuota='''+Values['C_ContQuota']+
                  ''' where C_ID=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_SaleContract, nContactId, nDataAreaID]);
          end else
          begin
            nStr:= 'Insert into %s (C_ID,C_Customer,C_CustName,'+
                   'C_Addr,C_SFSP,C_ContType,C_ContQuota,C_Date,DataAreaID) '+
                   'values ('''+Values['C_ID']+''','''+Values['C_Customer']+''','''+
                   Values['C_CustName']+''','''+Values['C_Addr']+''','''+
                   Values['C_SFSP']+''','''+Values['C_ContType']+''','''+
                   Values['C_ContQuota']+''','''+Values['C_Date']+''','''+
                   nDataAreaID+''')';
            nStr := Format(nStr, [sTable_SaleContract]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

function GetAXSalesContLine(const XMLPrimaryKey: Widestring): Boolean;//获取销售合同行
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nContactId,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
    nType: string;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nContactId:= nNode.NodeByName('ContactId').ValueAsString;
    except
      nContactId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nContactId='') or (nDataAreaID='') or (nRecid='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where ContactId=''%s'' and DataAreaID=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_SalContLine, nContactId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的销售合同行不存在.';
            nStr := Format(nStr, [nContactId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            if FieldByName('packtype').AsString='1' then
              nType:='D'
            else if FieldByName('packtype').AsString='2' then
              nType:='S'
            else
              nType:=FieldByName('packtype').AsString;
            Values['E_CID']:= FieldByName('ContactId').AsString;
            Values['E_Type']:= nType;
            Values['E_StockNo']:= UpperCase(FieldByName('itemid').AsString);
            values['E_StockName']:= FieldByName('itemname').AsString;
            Values['E_Value']:= FieldByName('qty').AsString;
            Values['E_Price']:= FieldByName('price').AsString;
            Values['E_Money']:= FieldByName('amount').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where E_CID=''%s'' and DataAreaID=''%s'' and E_RecID=''%s'' ';
          nStr := Format(nStr, [sTable_SContractExt, nContactId, nDataAreaID, nRecid]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set E_Type='''+Values['E_Type']+
                  ''',E_StockNo='''+Values['E_StockNo']+
                  ''',E_StockName='''+Values['E_StockName']+
                  ''',E_Value='''+Values['E_Value']+
                  ''',E_Price='''+Values['E_Price']+
                  ''',E_Money='''+Values['E_Money']+
                  ''' where E_CID=''%s'' and DataAreaID=''%s'' and E_RecID=''%s'' ';
            nStr := Format(nStr, [sTable_SContractExt, nContactId, nDataAreaID, nRecid]);
          end else
          begin
            nStr:= 'Insert into %s (E_CID,E_Type,E_StockNo,'+
                   'E_StockName,E_Value,E_Price,E_Money,DataAreaID,E_RecID) '+
                   'values ('''+Values['E_CID']+''','''+Values['E_Type']+''','''+
                   Values['E_StockNo']+''','''+Values['E_StockName']+''','''+
                   Values['E_Value']+''','''+Values['E_Price']+''','''+
                   Values['E_Money']+''','''+
                   nDataAreaID+''','''+nRecid+''')';
            nStr := Format(nStr, [sTable_SContractExt]);
          end;
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

function GetAXVehicleNo(const XMLPrimaryKey: Widestring): Boolean;//获取车号
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nVehId,nRecid,nDataAreaID,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nVehId:= nNode.NodeByName('VehicleId').ValueAsString;
    except
      nVehId:= '';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nDataAreaID:= nNode.NodeByName('companyid').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nDataAreaID='') or (nRecid='') then
  begin
    nStr := 'XML内容非法，直接忽略并返回成功.';
    Result := True;
    WriteLog(nStr);
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where companyid=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_VehicleNo, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的车辆信息不存在.';
            nStr := Format(nStr, [nVehId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['T_Truck']:= FieldByName('VehicleId').AsString;
            Values['T_Owner']:= FieldByName('CZ').AsString;
            Values['T_Driver']:= FieldByName('DriverId').AsString;
            values['T_Card']:= FieldByName('CMT_PrivateId').AsString;
            Values['T_CompanyID']:= FieldByName('companyid').AsString;
            Values['T_XTECB']:= FieldByName('XTECB').AsString;
            Values['T_VendAccount']:= FieldByName('VendAccount').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where T_Truck=''%s'' ';
          nStr := Format(nStr, [sTable_Truck, nVehId]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set T_Owner='''+Values['T_Owner']+
                  ''',T_Driver='''+Values['T_Driver']+
                  ''',T_Card='''+Values['T_Card']+
                  ''',T_CompanyID='''+Values['T_CompanyID']+
                  ''',T_XTECB='''+Values['T_XTECB']+
                  ''',T_VendAccount='''+Values['T_VendAccount']+
                  ''' where T_Truck=''%s'' ';
            nStr := Format(nStr, [sTable_Truck, nVehId]);
          end else
          begin
            nStr:= 'Insert into %s (T_Truck,T_Owner,T_Driver,'+
                   'T_Card,T_CompanyID,T_XTECB,T_VendAccount) '+
                   'values ('''+Values['T_Truck']+''','''+Values['T_Owner']+''','''+
                   Values['T_Driver']+''','''+Values['T_Card']+''','''+
                   Values['T_CompanyID']+''','''+Values['T_XTECB']+''','''+
                   Values['T_VendAccount']+''')';
            nStr := Format(nStr, [sTable_Truck]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

function GetAXPurOrder(const XMLPrimaryKey: Widestring): Boolean;//获取采购订单
var nStr: string;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nPurchId,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nPurchId:= nNode.NodeByName('PurchId').ValueAsString;
    except
      nPurchId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nPurchId='') or (nDataAreaID='') or (nRecid='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where PurchId=''%s'' and DataAreaID=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_PurOrder, nPurchId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的采购订单不存在.';
            nStr := Format(nStr, [nPurchId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['M_ID']:= FieldByName('PurchId').AsString;
            Values['M_ProID']:= FieldByName('OrderAccount').AsString;
            Values['M_ProName']:= FieldByName('PURCHNAME').AsString;
            Values['M_ProPY']:= GetPinYinOfStr(FieldByName('PURCHNAME').AsString);
            Values['M_CID']:= FieldByName('xtContractId').AsString;
            Values['M_BStatus']:= FieldByName('PurchStatus').AsString;
            Values['M_TriangleTrade']:= FieldByName('CMT_TriangleTrade').AsString;
            Values['M_IntComOriSalesId']:= FieldByName('InterCompanyOriginalSalesId').AsString;
            Values['M_PurchType']:= FieldByName('PurchaseType').AsString;
            Values['M_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
            Values['M_DState']:= FieldByName('DocumentState').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where M_ID=''%s'' ';
          nStr := Format(nStr, [sTable_OrderBaseMain, nPurchId]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set M_ProID='''+Values['M_ProID']+
                  ''',M_ProName='''+Values['M_ProName']+
                  ''',M_ProPY='''+Values['M_ProPY']+
                  ''',M_CID='''+Values['M_CID']+
                  ''',M_BStatus='''+Values['M_BStatus']+
                  ''',M_TriangleTrade='''+Values['M_TriangleTrade']+
                  ''',M_IntComOriSalesId='''+Values['M_IntComOriSalesId']+
                  ''',M_PurchType='''+Values['M_PurchType']+
                  ''',M_DState='''+Values['M_DState']+
                  ''',M_Date='''+Values['M_Date']+
                  ''' where M_ID=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_OrderBaseMain, nPurchId, nDataAreaID]);
          end else
          begin
            nStr:= 'Insert into %s (M_ID,M_ProID,M_ProName,M_ProPY,M_CID,M_BStatus,'+
                   'M_TriangleTrade,M_IntComOriSalesId,M_PurchType,M_DState,M_Date,DataAreaID) '+
                   'values ('''+Values['M_ID']+''','''+Values['M_ProID']+''','''+
                   Values['M_ProName']+''','''+Values['M_ProPY']+''','''+
                   Values['M_CID']+''','''+
                   Values['M_BStatus']+''','''+Values['M_TriangleTrade']+''','''+
                   Values['M_IntComOriSalesId']+''','''+Values['M_PurchType']+''','''+
                   Values['M_DState']+''','''+
                   Values['M_Date']+''','''+nDataAreaID+''')';
            nStr := Format(nStr, [sTable_OrderBaseMain]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

function GetAXPurOrdLine(const XMLPrimaryKey: Widestring): Boolean;//获取采购订单行
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nPurchId,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nPurchId:= nNode.NodeByName('PurchId').ValueAsString;
    except
      nPurchId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('DataAreaID').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('Recid').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nPurchId='') or (nDataAreaID='') or (nRecid='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where PurchId=''%s'' and DataAreaID=''%s'' and Recid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_PurOrdLine, nPurchId, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的采购订单行不存在.';
            nStr := Format(nStr, [nPurchId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['B_ID']:= FieldByName('PurchId').AsString;
            Values['B_StockType']:= FieldByName('CMT_PACKTYPE').AsString;
            Values['B_StockNo']:= UpperCase(FieldByName('ItemId').AsString);
            Values['B_StockName']:= FieldByName('Name').AsString;
            Values['B_BStatus']:= FieldByName('PurchStatus').AsString;
            Values['B_Value']:= FieldByName('QtyOrdered').AsString;
            Values['B_SentValue']:= FieldByName('PurchReceivedNow').AsString;
            Values['B_RestValue']:= FieldByName('RemainPurchPhysical').AsString;
            Values['B_Blocked']:= FieldByName('Blocked').AsString;
            Values['B_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where B_ID=''%s'' and DataAreaID=''%s'' and B_RecID=''%s'' ';
          nStr := Format(nStr, [sTable_OrderBase, nPurchId, nDataAreaID, nRecid]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set B_StockType='''+Values['B_StockType']+
                  ''',B_StockNo='''+Values['B_StockNo']+
                  ''',B_StockName='''+Values['B_StockName']+
                  ''',B_BStatus='''+Values['B_BStatus']+
                  ''',B_Value='''+Values['B_Value']+
                  ''',B_SentValue='''+Values['B_SentValue']+
                  ''',B_RestValue='''+Values['B_RestValue']+
                  ''',B_Blocked='''+Values['B_Blocked']+
                  ''',B_Date='''+Values['B_Date']+
                  ''' where B_ID=''%s'' and DataAreaID=''%s'' and B_RECID=''%s'' ';
            nStr := Format(nStr, [sTable_OrderBase, nPurchId, nDataAreaID, nRecid]);
          end else
          begin
            nStr:= 'Insert into %s (B_ID,B_StockNo,B_StockName,B_BStatus,'+
                   'B_Value,B_SentValue,B_RestValue,B_Blocked,B_Date,'+
                   'DataAreaID,B_RECID) '+
                   'values ('''+Values['B_ID']+''','''+Values['B_StockNo']+''','''+
                   Values['B_StockName']+''','''+Values['B_BStatus']+''','''+
                   Values['B_Value']+''','''+Values['B_SentValue']+''','''+
                   Values['B_RestValue']+''','''+
                   Values['B_Blocked']+''','''+Values['B_Date']+''','''+
                   nDataAreaID+''','''+nRecid+''')';
            nStr := Format(nStr, [sTable_OrderBase]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//获取客户信息
function GetAXCustomer(const XMLPrimaryKey: Widestring):Boolean;
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nCustNum,nDataAreaID,nRecid,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nCustNum:= nNode.NodeByName('AccountNum').ValueAsString;
    except
      nCustNum:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('dataAreaId').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nRecid:= nNode.NodeByName('RecId').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nCustNum='') or (nDataAreaID='') or (nRecid='') then
  begin
    Result:=False;
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select AccountNum,Name,CreditMax,MandatoryCreditLimit,' +
                'ContactPersonId,CMT_KHYH,CMT_KHZH '+
                'From %s where AccountNum=''%s'' and DataAreaID=''%s'' and RecID=''%s'' ';
        nStr := Format(nStr, [sTable_AX_Cust, nCustNum, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的客户信息不存在.';
            nStr := Format(nStr, [nCustNum]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_ID']:= FieldByName('AccountNum').AsString;
            Values['C_Name']:= FieldByName('Name').AsString;
            Values['C_PY']:= GetPinYinOfStr(FieldByName('Name').AsString);
            //Values['C_FaRen']:= FieldByName('CMT_Lawagencer').AsString;
            //Values['C_Phone']:= FieldByName('Phone').AsString;
            Values['C_CredMax']:= FieldByName('CreditMax').AsString;
            Values['C_MaCredLmt']:= FieldByName('MandatoryCreditLimit').AsString;
            //Values['C_CelPhone']:= FieldByName('CellularPhone').AsString;
            Values['C_Account']:= FieldByName('CMT_KHZH').AsString;
            Values['C_XuNi']:= sFlag_No;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_ID=''%s'' ';
          nStr := Format(nStr, [sTable_Customer, nCustNum]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_Name='''+Values['C_Name']+
                  ''',C_PY='''+Values['C_PY']+
                  //''',C_FaRen='''+Values['C_FaRen']+
                  //''',C_Phone='''+Values['C_Phone']+
                  ''',C_CredMax='''+Values['C_CredMax']+
                  ''',C_MaCredLmt='''+Values['C_MaCredLmt']+
                  //''',C_CelPhone='''+Values['C_CelPhone']+
                  ''',C_Account='''+Values['C_Account']+
                  ''',C_XuNi='''+Values['C_XuNi']+
                  ''' where C_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Customer, nCustNum]);
          end else
          begin
            nStr:= 'Insert into %s (C_ID,C_Name,C_PY,'+
                   'C_CredMax,C_MaCredLmt,C_Account,C_XuNi) '+
                   'values ('''+Values['C_ID']+''','''+Values['C_Name']+''','''+
                   Values['C_PY']+''','''+Values['C_CredMax']+''','''+
                   Values['C_MaCredLmt']+''','''+
                   Values['C_Account']+''','''+Values['C_XuNi']+''')';
            nStr := Format(nStr, [sTable_Customer]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          nStr:='select * from %s where A_CID=''%s'' ';
          nStr := Format(nStr, [sTable_CusAccount, nCustNum]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr:= 'Insert into %s (A_CID,A_Date) '+
                   'values ('''+nCustNum+''','''+Formatdatetime('yyyy-mm-dd hh:mm:ss',Now)+''')';
            nStr := Format(nStr, [sTable_CusAccount]);
            WriteLog(nStr);
            Close;
            SQL.Text:=nStr;
            ExecSQL;
          end;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//获取供应商信息
function GetAXProviders(const XMLPrimaryKey: Widestring):Boolean;
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nAccountNum,nRecid,nDataAreaID,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nAccountNum:= nNode.NodeByName('AccountNum').ValueAsString;
    except
      nAccountNum:= '';
    end;
    try
      nRecid:= nNode.NodeByName('RecId').ValueAsString;
    except
      nRecid:='';
    end;
    try
      nDataAreaID:= nNode.NodeByName('dataAreaId').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nAccountNum='') or (nRecid='') or (nDataAreaID='') then
  begin
    Result:=False;
    WriteLog(nAccountNum+'/'+nDataAreaID);
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select AccountNum,Name From %s where AccountNum=''%s'' and DataAreaID=''%s'' and RecID=''%s'' ';
        nStr := Format(nStr, [sTable_AX_VEND, nAccountNum, nDataAreaID, nRecid]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的供应商信息不存在.';
            nStr := Format(nStr, [nAccountNum]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['P_ID']:= FieldByName('AccountNum').AsString;
            Values['P_Name']:= FieldByName('Name').AsString;
            Values['P_PY']:= GetPinYinOfStr(FieldByName('Name').AsString);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where P_ID=''%s'' ';
          nStr := Format(nStr, [sTable_Provider, nAccountNum]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set P_Name='''+Values['P_Name']+
                  ''',P_PY='''+Values['P_PY']+
                  ''' where P_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Provider, nAccountNum]);
          end else
          begin
            nStr:= 'Insert into %s (P_ID,P_Name,P_PY) '+
                   'values ('''+Values['P_ID']+''','''+Values['P_Name']+''','''+
                   Values['P_PY']+''')';
            nStr := Format(nStr, [sTable_Provider]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
      qryRem.Active:=False;
    end;
  end;
end;

//获取物料信息
function GetAXMaterails(const XMLPrimaryKey: Widestring):Boolean;
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nItemId,nDataAreaID,nOperation:string;
    FListA:TStrings;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
    try
      nItemId:= nNode.NodeByName('ItemId').ValueAsString;
    except
      nItemId:= '';
    end;
    try
      nDataAreaID:= nNode.NodeByName('dataAreaId').ValueAsString;
    except
      nDataAreaID:='';
    end;
    try
      nOperation:= UpperCase(nNode.NodeByName('Operation').ValueAsString);    //操作类型：i->新增 u->更新 d->删除
    except
      nOperation:='';
    end;
  finally
    nXML.Free;
  end;
  if (nItemId='') or (nDataAreaID='') then
  begin
    Result:=False;
    WriteLog(nItemId+'/'+nDataAreaID);
    Exit;
  end;
  if nOperation='D' then
  begin
    Result:=True;
    Exit;
  end;
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select ItemId,ItemName,ItemGroupId,Weighning From '+sTable_AX_INVENT+
                ' where DataAreaID='''+nDataAreaID+''' and ItemId = '''+nItemId+''' ';
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的物料信息不存在.';
            nStr := Format(nStr, [nItemId]);
            Result := True;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['M_ID']:= FieldByName('ItemId').AsString;
            Values['M_Name']:= FieldByName('ItemName').AsString;
            Values['M_PY']:= GetPinYinOfStr(FieldByName('ItemName').AsString);
            Values['M_GroupID']:= FieldByName('ItemGroupId').AsString;
            Values['M_Weighning']:= FieldByName('Weighning').AsString;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where M_ID=''%s'' ';
          nStr := Format(nStr, [sTable_Materails, nItemId]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set M_Name='''+Values['M_Name']+
                  ''',M_PY='''+Values['M_PY']+
                  ''',M_GroupID='''+Values['M_GroupID']+
                  ''',M_Weighning='''+Values['M_Weighning']+
                  ''' where M_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Materails, nItemId]);
          end else
          begin
            nStr:= 'Insert into %s (M_ID,M_Name,M_PY,M_GroupID,M_Weighning) '+
                   'values ('''+Values['M_ID']+''','''+Values['M_Name']+''','''+
                   Values['M_PY']+''','''+Values['M_GroupID']+''','''+
                   Values['M_Weighning']+''')';
            nStr := Format(nStr, [sTable_Materails]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//下载三角贸易客户信息
function LoadAXCustomer(const nCusID,nDataAreaID:string):Boolean;
var nStr: string;
    nIdx: Integer;
    FListA:TStrings;
begin
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select AccountNum,Name,Phone,CreditMax,MandatoryCreditLimit,' +
                'CellularPhone,ContactPersonId,CMT_Lawagencer,CMT_KHYH,CMT_KHZH '+
                'From %s where AccountNum=''%s'' and DataAreaID=''%s'' ';
        nStr := Format(nStr, [sTable_AX_Cust, nCusID, nDataAreaID]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的客户信息不存在.';
            nStr := Format(nStr, [nCusID]);
            Result := False;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_ID']:= FieldByName('AccountNum').AsString;
            Values['C_Name']:= FieldByName('Name').AsString;
            Values['C_PY']:= UpperCase(FieldByName('Name').AsString);
            //Values['C_FaRen']:= FieldByName('CMT_Lawagencer').AsString;
            //Values['C_Phone']:= FieldByName('Phone').AsString;
            Values['C_CredMax']:= FieldByName('CreditMax').AsString;
            Values['C_MaCredLmt']:= FieldByName('MandatoryCreditLimit').AsString;
            //Values['C_CelPhone']:= FieldByName('CellularPhone').AsString;
            Values['C_Account']:= FieldByName('CMT_KHZH').AsString;
            Values['C_XuNi']:= sFlag_No;
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_ID=''%s'' ';
          nStr := Format(nStr, [sTable_Customer, nCusID]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_Name='''+Values['C_Name']+
                  ''',C_PY='''+Values['C_PY']+
                  //''',C_FaRen='''+Values['C_FaRen']+
                  //''',C_Phone='''+Values['C_Phone']+
                  ''',C_CredMax='''+Values['C_CredMax']+
                  ''',C_MaCredLmt='''+Values['C_MaCredLmt']+
                  //''',C_CelPhone='''+Values['C_CelPhone']+
                  ''',C_Account='''+Values['C_Account']+
                  ''',C_XuNi='''+Values['C_XuNi']+
                  ''' where C_ID=''%s'' ';
            nStr := Format(nStr, [sTable_Customer, nCusID]);
          end else
          begin
            nStr:= 'Insert into %s (C_ID,C_Name,C_PY,'+
                   'C_CredMax,C_MaCredLmt,C_Account,C_XuNi) '+
                   'values ('''+Values['C_ID']+''','''+Values['C_Name']+''','''+
                   Values['C_PY']+''','''+Values['C_CredMax']+''','''+
                   Values['C_MaCredLmt']+''','''+
                   Values['C_Account']+''','''+Values['C_XuNi']+''')';
            nStr := Format(nStr, [sTable_Customer]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//下载三角贸易合同信息
function LoadAXSalesContract(const nContactId,nDataAreaID:string):Boolean;
var nStr: string;
    nIdx: Integer;
    FListA:TStrings;
begin
  with DM do
  begin
    FListA:=TStringList.Create;
    try
      FListA.Clear;
      try
        nStr := 'Select * From %s Where ContactId=''%s'' and companyid=''%s'' ';
        nStr := Format(nStr, [sTable_AX_SalesCont, nContactId, nDataAreaID]);
        with qryRem do
        begin
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount < 1 then
          begin
            nStr := '编号为[ %s ]的销售合同不存在.';
            nStr := Format(nStr, [nContactId]);
            Result := False;
            WriteLog(nStr);
            Exit;
          end;
          with FListA do
          begin
            Values['C_ID']:= FieldByName('ContactId').AsString;
            Values['C_Customer']:= FieldByName('CUST').AsString;
            Values['C_CustName']:= FieldByName('custname').AsString;
            values['C_Addr']:= FieldByName('ContactAddress').AsString;
            Values['C_SFSP']:= FieldByName('CMT_SFSP').AsString;
            Values['C_ContType']:= FieldByName('xtEContractSuperType').AsString;
            Values['C_ContQuota']:= FieldByName('XTContactQuota').AsString;
            Values['C_Date']:= FormatDateTime('yyyy-mm-dd hh:mm:ss',Now);
          end;
        end;
        with qryLoc,FListA do
        begin
          nStr:='select * from %s where C_ID=''%s'' and DataAreaID=''%s'' ';
          nStr := Format(nStr, [sTable_SaleContract, nContactId, nDataAreaID]);
          Close;
          SQL.Text:=nStr;
          Open;
          if RecordCount>0 then
          begin
            nStr:='update %s set C_Customer='''+Values['C_Customer']+
                  ''',C_CustName='''+Values['C_CustName']+
                  ''',C_Addr='''+Values['C_Addr']+
                  ''',C_SFSP='''+Values['C_SFSP']+
                  ''',C_ContType='''+Values['C_ContType']+
                  ''',C_ContQuota='''+Values['C_ContQuota']+
                  ''' where C_ID=''%s'' and DataAreaID=''%s'' ';
            nStr := Format(nStr, [sTable_SaleContract, nContactId, nDataAreaID]);
          end else
          begin
            nStr:= 'Insert into %s (C_ID,C_Customer,C_CustName,'+
                   'C_Addr,C_SFSP,C_ContType,C_ContQuota,C_Date,DataAreaID) '+
                   'values ('''+Values['C_ID']+''','''+Values['C_Customer']+''','''+
                   Values['C_CustName']+''','''+Values['C_Addr']+''','''+
                   Values['C_SFSP']+''','''+Values['C_ContType']+''','''+
                   Values['C_ContQuota']+''','''+Values['C_Date']+''','''+
                   nDataAreaID+''')';
            nStr := Format(nStr, [sTable_SaleContract]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
          Result:=True;
        end;
      except
        on e:Exception do
        begin
          WriteLog(e.Message);
        end;
      end;
    finally
      FListA.Free;
    end;
  end;
end;

//下载三角贸易合同行信息
function LoadAXSalesContLine(const nContactId,nDataAreaID:string):Boolean;
begin

end;

//设置在线模式
function SetOnLineModel(nModel:Boolean):Boolean;
var nStr:string;
begin
  Result:=False;
  with DM.qryLoc do
  begin
    if nModel then
    begin
      nStr:='Update Sys_Dict set D_Value=''Y'' where D_Name=''OnLineModel'' ';
    end else
    begin
      nStr:='Update Sys_Dict set D_Value=''N'' where D_Name=''OnLineModel'' ';
    end;
    Close;
    SQL.Text:=nStr;
    ExecSQL;
    Result:=True;
  end;
end;

//获取在线模式
function GetOnLineModel:Boolean;
var nStr:string;
begin
  Result:=True;
  with DM.qryLoc do
  begin
    nStr:='select D_Value from Sys_Dict where D_Name=''OnLineModel'' ';
    Close;
    SQL.Text:=nStr;
    Open;
    if RecordCount>0 then
    begin
      if FieldByName('D_Value').AsString='N' then Result:=False;
    end;
  end;
end;

//更新预扣金额
function UpdateYKAmount(const XMLPrimaryKey: Widestring): Boolean;
var nStr, nLID, nCustAcc, nContQuota: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nTRANSPLANID,nDataAreaID:string;
    nYKMouney: Double;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;

    nTmp := nNode.NodeByName('TRANSPLANID');
    if Assigned(nTmp) then
      nTRANSPLANID:= nTmp.ValueAsString
    else
      nTRANSPLANID:= '';

    nTmp := nNode.NodeByName('DataAreaID');
    if Assigned(nTmp) then
      nDataAreaID:= nTmp.ValueAsString
    else
      nDataAreaID:='';
  finally
    nXML.Free;
  end;
  if (nTRANSPLANID='') or (nDataAreaID='') then
  begin
    Result:=False;
    WriteLog(nTRANSPLANID+'/'+nDataAreaID);
    Exit;
  end;
  with DM do
  begin
    try
      with qryLoc do
      begin
        nLID:='T'+nTRANSPLANID;
        nStr:='select L_Value*L_Price as L_TotalMoney,L_CusID,L_ContQuota from %s where L_BDAX=''2'' and L_ID=''%s'' ';
        nStr := Format(nStr, [sTable_Bill, nLID]);
        WriteLog(nStr);
        Close;
        SQL.Text:=nStr;
        Open;
        if RecordCount > 0 then
        begin
          nYKMouney := FieldByName('L_TotalMoney').AsFloat;
          nCustAcc := FieldByName('L_CusID').AsString;
          nContQuota:= FieldByName('L_ContQuota').AsString;

          if nContQuota = '1' then
          begin
            nStr:='Update %s Set A_ConFreezeMoney=A_ConFreezeMoney-(%s) Where A_CID=''%s''';
            nStr:= Format(nStr, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
          end else
          begin
            nStr:='Update %s Set A_FreezeMoney=A_FreezeMoney-(%s) Where A_CID=''%s''';
            nStr:= Format(nStr, [sTable_CusAccount, FormatFloat('0.00',nYKMouney), nCustAcc]);
          end;
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;

          nStr:='Update %s Set L_BDAX=''1'' Where L_ID=''%s'' ';
          nStr:= Format(nStr, [sTable_Bill, nLID]);
          WriteLog(nStr);
          Close;
          SQL.Text:=nStr;
          ExecSQL;
        end;
        Result:=True;
      end;
    except
      on e:Exception do
      begin
        WriteLog(e.Message);
      end;
    end;
  end;
end;

//获取提货单信息
function GetThInfo(const XMLPrimaryKey: Widestring):Boolean;
var nStr, nLID, nCustAcc, nContQuota: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nDBConn: PDBWorker;
    nErrNum: Integer;
    nPLANQTY,nVEHICLEId,nITEMID,nITEMNAME,nITEMTYPE,nITEMPRICE :string;
    nCUSTOMERID,nCUSTOMERNAME,nTRANSPORTER,nTRANSPLANID :string;
    nSALESID,nSALESLINERECID,nCOMPANYID,nDestinationcode :string;
    nWMSLocationId,nFYPlanStatus,nInventLocationId :string;
    nxtDInventCenterId :string;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('PRIMARY');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;

    nTmp := nNode.NodeByName('PLANQTY');
    if Assigned(nTmp) then
      nPLANQTY:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('VEHICLEId');
    if Assigned(nTmp) then
      nVEHICLEId:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMID');
    if Assigned(nTmp) then
      nITEMID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMNAME');
    if Assigned(nTmp) then
      nITEMNAME:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMTYPE');
    if Assigned(nTmp) then
      nITEMTYPE:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('ITEMPRICE');
    if Assigned(nTmp) then
      nITEMPRICE:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('CUSTOMERID');
    if Assigned(nTmp) then
      nCUSTOMERID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('CUSTOMERNAME');
    if Assigned(nTmp) then
      nCUSTOMERNAME:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('TRANSPORTER');
    if Assigned(nTmp) then
      nTRANSPORTER:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('TRANSPLANID');
    if Assigned(nTmp) then
      nTRANSPLANID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('SALESID');
    if Assigned(nTmp) then
      nSALESID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('SALESLINERECID');
    if Assigned(nTmp) then
      nSALESLINERECID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('COMPANYID');
    if Assigned(nTmp) then
      nCOMPANYID:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('Destinationcode');
    if Assigned(nTmp) then
      nDestinationcode:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('WMSLocationId');
    if Assigned(nTmp) then
      nWMSLocationId:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('FYPlanStatus');
    if Assigned(nTmp) then
      nFYPlanStatus:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('InventLocationId');
    if Assigned(nTmp) then
      nInventLocationId:= nTmp.ValueAsString;

    nTmp := nNode.NodeByName('xtDInventCenterId');
    if Assigned(nTmp) then
      nxtDInventCenterId:= nTmp.ValueAsString;

    nStr := 'Insert into %s (AX_PLANQTY,AX_VEHICLEId,AX_ITEMID,AX_ITEMNAME,'+
                           'AX_ITEMTYPE,AX_ITEMPRICE,AX_CUSTOMERID,AX_CUSTOMERNAME,'+
                           'AX_TRANSPORTER,AX_TRANSPLANID,AX_SALESID,AX_SALESLINERECID,'+
                           'AX_COMPANYID,AX_Destinationcode,AX_WMSLocationId,AX_FYPlanStatus,'+
                           'AX_InventLocationId,AX_xtDInventCenterId) '+
                           'values '+
                           '(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr,[sTable_AxPlanInfo, nPLANQTY,nVEHICLEId,nITEMID,nITEMNAME,nITEMTYPE,nITEMPRICE,
                        nCUSTOMERID,nCUSTOMERNAME,nTRANSPORTER,nTRANSPLANID,nSALESID,nSALESLINERECID,
                        nCOMPANYID,nDestinationcode,nWMSLocationId,nFYPlanStatus,nInventLocationId,
                        nxtDInventCenterId]);
    WriteLog(nStr);
    with DM do
    try
      ADOCLoc.BeginTrans;
      with qryLoc do
      begin
        Close;
        SQL.Text:=nStr;
        ExecSQL;
        ADOCLoc.CommitTrans;
        Result:= True;
      end;
    except
      if ADOCLoc.InTransaction then
          ADOCLoc.RollbackTrans;
      WriteLog('GetThInfo Insert Error: RollbackTrans');
    end;

    {nDBConn := nil;
    with gParamManager.ActiveParam^ do
    Try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
      if not Assigned(nDBConn) then
      begin
        WriteLog('连接数据库失败(DBConn Is Null).');
        Exit;
      end;

      if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;  
      //conn db

      nStr := 'Insert into %s (AX_PLANQTY,AX_VEHICLEId,AX_ITEMID,AX_ITEMNAME,'+
                           'AX_ITEMTYPE,AX_ITEMPRICE,AX_CUSTOMERID,AX_CUSTOMERNAME,'+
                           'AX_TRANSPORTER,AX_TRANSPLANID,AX_SALESID,AX_SALESLINERECID,'+
                           'AX_COMPANYID,AX_Destinationcode,AX_WMSLocationId,AX_FYPlanStatus,'+
                           'AX_InventLocationId,AX_xtDInventCenterId) '+
                           'values '+
                           '(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'','+
                           '''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'','+
                           '''%s'',''%s'',''%s'')';
      nStr := Format(nStr,[sTable_AxPlanInfo, nPLANQTY,nVEHICLEId,nITEMID,nITEMNAME,nITEMTYPE,nITEMPRICE,
                          nCUSTOMERID,nCUSTOMERNAME,nTRANSPORTER,nTRANSPLANID,nSALESID,nSALESLINERECID,
                          nCOMPANYID,nDestinationcode,nWMSLocationId,nFYPlanStatus,nInventLocationId,
                          nxtDInventCenterId]);
      WriteLog(nStr);
      try
        nDBConn.FConn.BeginTrans;
        gDBConnManager.WorkerExec(nDBConn,nStr);
        nDBConn.FConn.CommitTrans;
      except
        if nDBConn.FConn.InTransaction then
          nDBConn.FConn.RollbackTrans;
        raise;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;}
  finally
    nXML.Free;
  end;
end;

//获取采购单信息
function GetPurchInfo(const XMLPrimaryKey: Widestring):Boolean; 
var nStr, nLID, nCustAcc, nContQuota: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.ReadFromString('<?xml version="1.0" encoding="UTF-8"?><DATA>'+XMLPrimaryKey+'</DATA>');
    nNode := nXML.Root.FindNode('Primary');
    if not Assigned(nNode) then
    begin
      Result:=False;
      Exit;
    end;
  finally
    nXML.Free;
  end;
  Result:= True;
end;


end.
