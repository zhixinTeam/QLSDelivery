unit UFormPurchReject;

{$I Link.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, CPort, CPortTypes,
  dxLayoutcxEditAdapters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormPurchReject = class(TfFormNormal)
    ComPort1: TComPort;
    EditCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditLID: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    procedure ActionComPort(const nStop: Boolean);
    procedure GetPurchOrderInfo(const nCardNo: string); //获取交货单信息
    procedure ShowFormData;  //显示数据
    procedure ClearFormData; //清空数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormPurchReject: TfFormPurchReject;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, UBusinessConst, USysConst ,USysLoger, USmallFunc, USysBusiness;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;
var
  gReaderItem: TReaderItem;
  //全局使用
  gBills: TLadingBillItems;

class function TfFormPurchReject.FormID: integer;
begin
  Result := cFI_FormPurchReject;
end;

class function TfFormPurchReject.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
begin
  Result:=nil;
  with TfFormPurchReject.Create(Application) do
  begin
    Caption := '原材料拒收';
    ActionComPort(False);
    BtnOK.Enabled:=False;
    ShowModal;
    Free;
  end;
end;

procedure TfFormPurchReject.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ActionComPort(True);
end;

procedure TfFormPurchReject.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;


procedure TfFormPurchReject.ComPort1RxChar(Sender: TObject;
  Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    nCard:string;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    nCard:= ParseCardNO(nStr, True);
    if nCard <> EditCard.Text then
    begin
      EditCard.Text := nCard;
      GetPurchOrderInfo(Trim(EditCard.Text));
    end;
    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormPurchReject.GetPurchOrderInfo(const nCardNo: string);
var nStr,nHint: string;
    nIdx,nInt: Integer;
    nFID :string;
begin
  nFID:='';
  if GetPurchaseOrders(nCardNo, sFlag_TruckXH, gBills) then
  begin
    nInt := 0 ;
    nHint := '';

    for nIdx:=Low(gBills) to High(gBills) do
    with gBills[nIdx] do
    begin
      FSelected := (FNextStatus = sFlag_TruckXH) or (FNextStatus = sFlag_TruckBFM);
      if FSelected then
      begin
        Inc(nInt);
        Continue;
      end;

      nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
      if nIdx < High(gBills) then nStr := nStr + #13#10;

      nStr := Format(nStr, [FID,
              TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
      nHint := nHint + nStr;
    end;

    if (nHint <> '') and (nInt = 0) then
    begin
      nHint := '该车辆当前不能拒收,详情如下: ' + #13#10#13#10 + nHint;
      ShowDlg(nHint, sHint);
      Exit;
    end;

    ShowFormData;

  end else
  begin
    nHint := '无相关数据';
    ShowDlg(nHint, sHint);
  end;
end;

procedure TfFormPurchReject.ShowFormData;
begin
  with gBills[0] do
  begin
    EditLID.Text:= gBills[0].FID;
    EditCustomer.Text:= FCusName;
    EditTruck.Text:= gBills[0].FTruck;
    EditStockName.Text:= gBills[0].FStockName;
  end;
  BtnOK.Enabled:=True;
end;

procedure TfFormPurchReject.ClearFormData;
var i:Integer;
begin
  for i:= 0 to ComponentCount-1 do
  begin
    if Components[i] is TcxTextEdit then
      (Components[i] as TcxTextEdit).Text:='';
    if Components[i] is TcxComboBox then
      (Components[i] as TcxComboBox).Text:='';
  end;
end;

procedure TfFormPurchReject.BtnOKClick(Sender: TObject);
var nStr : string ;
begin
  if EditCard.Text = '' then
  begin
    ShowMsg('请输入拒收磁卡号', sHint);
    Exit;
  end;
  nStr := '确定拒收吗?';
  if not QueryDlg(nStr, sAsk) then Exit;

  with gBills[0] do
  begin
    FYSValid := sFlag_NO;
  end;

  if SavePurchaseOrders(sFlag_TruckXH, gBills) then
  begin
    ShowMsg('原材料拒收成功', sHint);
    ClearFormData;
    ModalResult := mrOk;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPurchReject, TfFormPurchReject.FormID);

end.
