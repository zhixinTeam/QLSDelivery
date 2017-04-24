unit uFormGetWechartAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, ComCtrls, cxListView, cxLabel, cxTextEdit;

type
  //客户注册信息
  PWechartCustomerInfo = ^TWechartCustomerInfo;
  TWechartCustomerInfo = record
    FBindcustomerid:string;//绑定客户id  
    FNamepinyin:string;//登录账号
    FEmail:string;//邮箱
    Fphone:string;//手机号码
  end;

  TfFormGetWechartAccount = class(TfFormNormal)
    edtinput: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    ListQuery: TcxListView;
    dxLayout1Item5: TdxLayoutItem;
    procedure edtinputKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
    procedure ListQueryDblClick(Sender: TObject);
  private
    { Private declarations }
    //微信注册用户信息列表
    FCustomerInfos:TList;
    FSelectedStr:string;
    FNamepinyin:string;
    FPhone:string;
    //查询数据
    procedure GetResult;
    procedure FilterFunc(const nInputStr:string);
    function DownloadAllCustomerInfos:Boolean;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation
uses
  Contnrs,UFormBase,USysConst,UBusinessPacker,ULibFun,UMgrControl,USysBusiness,
  UDataModule,USysDB;
{$R *.dfm}

{ TfFormNormal1 }

class function TfFormGetWechartAccount.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetWechartAccount.Create(Application) do
  try
    FCustomerInfos := TList.Create;
    FSelectedStr := '';
    FNamepinyin := '';
    FPhone := '';

    Caption := '选择账号';
//    dxLayout1Item5.Caption := '商城注册信息选择';

    nP.FCommand := cCmd_ModalResult;

    DownloadAllCustomerInfos;
    
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := PackerEncodeStr(FSelectedStr);
      nP.FParamC := PackerEncodeStr(FNamepinyin);
      np.FParamD := PackerEncodeStr(FPhone);
    end;
  finally
    FCustomerInfos.Clear;
    FCustomerInfos.Free;
    Free;
  end;
end;

class function TfFormGetWechartAccount.FormID: integer;
begin
  Result := cFI_FormGetWechartAccount;
end;

procedure TfFormGetWechartAccount.edtinputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListQuery.Items.Count=1 then
    begin
      ListQuery.ItemIndex := 0;
      GetResult;
      ModalResult := mrOk;
    end;
  end
  else begin
    FilterFunc(edtinput.Text);
  end;
end;

procedure TfFormGetWechartAccount.GetResult;
begin
  with ListQuery.Selected do
  begin
    FSelectedStr := SubItems[2];
    FNamepinyin := Caption;
    FPhone := SubItems[1];
  end;
end;

procedure TfFormGetWechartAccount.FilterFunc(const nInputStr: string);
var
  i:Integer;
  nRec:PWechartCustomerInfo;
begin
  ListQuery.Clear;
  if nInputStr='' then
  begin
    for i := 0 to FCustomerInfos.Count-1 do
    begin
      nRec := PWechartCustomerInfo(FCustomerInfos.Items[i]);
      with ListQuery.Items.Add do
      begin
        Caption := nRec.FNamepinyin;
        SubItems.Add(nRec.FEmail);
        SubItems.Add(nRec.Fphone);
        SubItems.Add(nRec.FBindcustomerid);
        ImageIndex := cItemIconIndex;
      end;
    end;
  end
  else begin
    for i := 0 to FCustomerInfos.Count-1 do
    begin
      nRec := PWechartCustomerInfo(FCustomerInfos.Items[i]);
      if (Pos(LowerCase(nInputStr),LowerCase(nRec.FNamepinyin))>0)
        or (Pos(LowerCase(nInputStr),LowerCase(nrec.Fphone))>0) then
      begin
        with ListQuery.Items.Add do
        begin
          Caption := nRec.FNamepinyin;
          SubItems.Add(nRec.FEmail);
          SubItems.Add(nRec.Fphone);
          SubItems.Add(nRec.FBindcustomerid);
          ImageIndex := cItemIconIndex;
        end;
      end;
    end;  
  end;
end;

function TfFormGetWechartAccount.DownloadAllCustomerInfos: Boolean;
var
  nXmlStr,nData:string;
  i:Integer;
  nList,nListsub:TStrings;
  nRec:PWechartCustomerInfo;
begin
  Result := False;
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'</head>'
            +'</DATA>';
   nXmlStr := Format(nXmlStr,[gSysParam.FFactory]);
   nXmlStr := PackerEncodeStr(nXmlStr);
   //获取客户注册信息
   nData := getCustomerInfo(nXmlStr);
   if nData='' then
   begin
     ShowMsg('未查询到当前工厂的注册用户信息', sHint);
     Exit;
   end;

  //解析客户注册信息
  nData := PackerDecodeStr(nData);
  nList := TStringList.Create;
  nListsub := TStringList.Create;
  try
    nList.Text := nData;
    for i := 0 to nList.Count-1 do
    begin
      New(nRec);
      nListsub.CommaText := nList.Strings[i];
      nRec.Fphone := nListsub.Values['phone'];
      nRec.FBindcustomerid := nListsub.Values['Bindcustomerid'];
      nRec.FNamepinyin := nListsub.Values['Namepinyin'];
      nRec.FEmail := nListsub.Values['Email'];
      FCustomerInfos.Add(nRec);
    end;
    FilterFunc('');
  finally
    nListsub.Free;
    nList.Free;
  end;
end;

procedure TfFormGetWechartAccount.BtnOKClick(Sender: TObject);
var
  nStr: string;
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('请在查询结果中选择', sHint);
end;

procedure TfFormGetWechartAccount.ListQueryDblClick(Sender: TObject);
begin
  BtnOK.Click;
end;

initialization
  gControlManager.RegCtrl(TfFormGetWechartAccount, TfFormGetWechartAccount.FormID);

end.
