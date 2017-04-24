{*******************************************************************************
  作者: dmzn@163.com 2009-6-11
  描述: 客户管理
*******************************************************************************}
unit UFrameCustomer;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameCustomer = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    m_bindWechartAccount: TMenuItem;
    N5: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure m_bindWechartAccountClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}

    function AddMallUser(const nBindcustomerid,nCus_num,nCus_name:string):Boolean;
    function DelMallUser(const nNamepinyin,nCus_id:string):boolean;    
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, USysBusiness,
  USysConst, USysDB, uFormGetWechartAccount, UBusinessPacker, USysLoger;

class function TfFrameCustomer.FrameID: integer;
begin
  Result := cFI_FrameCustomer;
end;

//Desc: 数据查询SQL
function TfFrameCustomer.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select cus.*,bind.* From $Cus cus' +
            ' Left Join $Bind bind On bind.w_CID=cus.C_ID';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where C_XuNi<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
            MI('$Bind', sTable_WeixinBind), MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: 关闭
procedure TfFrameCustomer.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormCustomer, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 添加
procedure TfFrameCustomer.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameCustomer.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFrameCustomer.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_ID').AsString;
  nSQL := 'Select Count(*) From %s Where Z_Customer=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该客户不能删除', '已办纸卡'); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('确定要删除名称为[ ' + nStr + ' ]的客户吗', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Customer, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_CustomerItem, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where A_CID=''%s''';
    nSQL := Format(nSQL, [sTable_CusAccount, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where C_CusID=''%s''';
    nSQL := Format(nSQL, [sTable_CusCredit, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

//Desc: 查看内容
procedure TfFrameCustomer.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
    CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);
  end;
end;

//Desc: 执行查询
procedure TfFrameCustomer.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------

procedure TfFrameCustomer.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N3.Visible := True;
  N4.Visible := True;
  {$ELSE}
  N3.Visible := False;
  N4.Visible := False;
  {$ENDIF}
end;


//Desc: 快捷菜单
procedure TfFrameCustomer.N2Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('IsNull(C_XuNi, '''')=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameCustomer.N4Click(Sender: TObject);
begin
  ShowWaitForm(ParentForm, '正在同步,请稍后');
  try
    if SyncRemoteCustomer then InitFormData(FWhere);
  finally
    CloseWaitForm;
  end; 
end;

procedure TfFrameCustomer.m_bindWechartAccountClick(Sender: TObject);
var
  nParam: TFormCommandParam;
  nCus_ID,nCusName:string;
  nBindcustomerid:string;
  nWechartAccount:string;
  nWechartPhone:string;
  nStr:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要开通的记录', sHint);
    Exit;
  end;

  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  nWechartAccount := SQLQuery.FieldByName('wcb_Namepinyin').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('商城账户['+nWechartAccount+']已存在', sHint);
    Exit;
  end;
  
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    nBindcustomerid := PackerDecodeStr(nParam.FParamB);
    nWechartAccount := PackerDecodeStr(nParam.FParamC);
    nWechartPhone := PackerDecodeStr(nParam.FParamD);
    if not AddMallUser(nBindcustomerid,nCus_ID,nCusName) then Exit;
    
    nStr := 'Insert into %s (w_CID, w_CusName, wcb_Phone, wcb_Bindcustomerid, wcb_Namepinyin) '+
            'values (''%s'',''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr,[sTable_WeixinBind,nCus_ID,nCusName,nWechartPhone,nBindcustomerid,nWechartAccount]);
    //gSysLoger.AddLog(nStr);

    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('客户 [ '+nCusName+' ] 关联商城用户成功！',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('关联商城用户失败', '未知错误');
    end;
  end;
end;

function TfFrameCustomer.AddMallUser(const nBindcustomerid,nCus_num,nCus_name:string): Boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //发送绑定请求开户请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8" ?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<Customer>%s</Customer>'   //销售需要这个传客户号
            +'<Provider></Provider>'     //采购需要这个节点传供应商编号
            +'<type>add</type>'
            +'</head>'
            +'<Items>'
            +'<Item>'
            +'<clientname>%s</clientname>'
            +'<cash>0</cash>'
            +'<clientnumber>%s</clientnumber>'
            +'</Item>'
            +'</Items>'
            +'<remark />'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nBindcustomerid,nCus_name,nCus_num]);
  nXmlStr := PackerEncodeStr(nXmlStr);
//  nXmlStr := PackerEncodeStr(UTF8Encode(nXmlStr));

  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer,'AddMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('客户[ '+nCus_num+' ]关联商城用户失败！', sError);
    Exit;
  end;
  Result := True;
end;

function TfFrameCustomer.DelMallUser(const nNamepinyin,nCus_id:string):boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //发送http请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head>'
      +'<Factory>%s</Factory>'
      +'<Customer>%s</Customer>'
      +'<type>del</type>'
      +'</head>'
      +'<Items>'
      +'<Item>'
      +'<clientnumber>%s</clientnumber>'
      +'</Item></Items><remark/></DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nNamepinyin,nCus_id]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer,'DelMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('客户[ '+nCus_id+' ]取消商城账户关联 失败！', sError);
    Exit;
  end;
  Result := True;
end;

procedure TfFrameCustomer.N5Click(Sender: TObject);
var
  nWechartAccount:string;
  nStr:string;
  nCus_ID,nCusName:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要取消的记录', sHint);
    Exit;
  end;

  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  nWechartAccount := SQLQuery.FieldByName('wcb_Namepinyin').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('商城账户不已存在',sHint);
    Exit;
  end;

  if not DelMallUser(nWechartAccount, nCus_ID) then Exit;
  nStr := 'delete from %s where w_CID=''%s'' and wcb_Namepinyin=''%s'' ';
  nStr := Format(nStr,[sTable_WeixinBind,nCus_ID,nWechartAccount]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('客户 [ '+nCusName+' ] 取消商城账户关联 成功！',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('取消商城账户关联 失败', '未知错误');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer, TfFrameCustomer.FrameID);
end.
