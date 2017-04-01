unit UFormSTCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxMemo, cxTextEdit, CPort, CPortTypes;

type
  TfFormSTCard = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditContext: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    MemoBz: TcxMemo;
    dxLayout1Item6: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    ComPort1: TComPort;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
    FRecord: string;
    //记录编号
    FBuffer: string;
    //接收缓冲
    procedure LoadFormData(const nID: string);
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormSTCard: TfFormSTCard;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, USysBusiness,
  IniFiles, USmallFunc;

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

class function TfFormSTCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormSTCard.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '商砼卡 - 添加';
      FRecord := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '商砼卡 - 修改';
      FRecord := nP.FParamA;
    end;

    LoadFormData(FRecord);
    ActionComPort(False);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

  finally
    Free;
  end;
end;

class function TfFormSTCard.FormID: integer;
begin
  Result := cFI_FormSTCard;
end;

procedure TfFormSTCard.ActionComPort(const nStop: Boolean);
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

procedure TfFormSTCard.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_InOutFatory, nID]);
    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      EditCard.Text := FieldByName('I_Card').AsString;
      EditTruck.Text := FieldByName('I_Truck').AsString;
      EditName.Text := FieldByName('I_CusName').AsString;
      EditContext.Text := FieldByName('I_Context').AsString;
      MemoBz.Text := FieldByName('I_Memo').AsString;
    end;
  end;
end;

procedure TfFormSTCard.BtnOKClick(Sender: TObject);
var
  nStr,nTruck:string;
begin
  if EditCard.Text = '' then
  begin
    ShowMsg('请刷卡',sHint);
    Exit;
  end;
  nStr := 'select * from %s where I_Card =''%s'' ';
  nStr := Format(nStr,[sTable_InOutFatory, EditCard.Text]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      nTruck:=FieldByName('I_Truck').AsString;
      ShowMsg(nTruck+'正在使用'+EditCard.Text+#13#10+'请注销卡号',sHint);
      Exit;
    end;
  end;
  if EditTruck.Text = '' then
  begin
    ShowMsg('请输入车牌号码',sHint);
    Exit;
  end;
  if EditContext.Text = '' then
  begin
    ShowMsg('请输入客户名称',sHint);
    Exit;
  end;
  nStr := MakeSQLByStr([SF('I_Card', EditCard.Text),
          SF('I_Truck', EditTruck.Text),
          SF('I_CusName', EditName.Text),
          SF('I_Context', EditContext.Text),
          SF('I_Memo', MemoBz.Text),
          SF('I_Man', gSysParam.FUserID),
          SF('I_Date', sField_SQLServer_Now, sfVal)
          ], sTable_STInOutFact, nStr, FRecord = '');
  FDM.ExecuteSQL(nStr);

  nStr := Format('C_Card=''%s''', [EditCard.Text]);
  nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
          SF('C_Used', sFlag_ST),
          SF('C_Freeze', sFlag_No),
          SF('C_Man', gSysParam.FUserID),
          SF('C_Date', sField_SQLServer_Now, sfVal)
          ], sTable_Card, nStr, False);
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('保存成功', sHint);
end;

procedure TfFormSTCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ActionComPort(True);
end;

procedure TfFormSTCard.ComPort1RxChar(Sender: TObject; Count: Integer);
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
    end;
    FBuffer := '';
    Exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormSTCard, TfFormSTCard.FormID);

end.
