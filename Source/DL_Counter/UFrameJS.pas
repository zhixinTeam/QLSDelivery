{*******************************************************************************
  作者: dmzn@163.com 2012-4-29
  描述: 单道计数
*******************************************************************************}
unit UFrameJS;

{$I js_inc.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMultiJS, ULibFun, USysConst, UFormWait, UFormInputbox, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls, ExtCtrls, cxLabel,
  cxGraphics, cxControls;

type
  TfFrameCounter = class(TFrame)
    GroupBox1: TGroupBox;
    LabelHint: TcxLabel;
    EditTruck: TLabeledEdit;
    EditDai: TLabeledEdit;
    BtnStart: TButton;
    BtnClear: TButton;
    EditTon: TLabeledEdit;
    Timer1: TTimer;
    BtnPause: TButton;
    procedure BtnClearClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure EditTonChange(Sender: TObject);
    procedure EditTonDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FBill: string;
    //交货单
    FDaiNum: Integer;
    //装车量
    FPeerWeight: Integer;
    //带重
    FTunnel: PMultiJSTunnel;
    //计数通道
    procedure SaveCountResult(const nProcess: Boolean);
    //保存计数
    constructor Create(AOwner: TComponent); override;
    //初始化
  end;

implementation

{$R *.dfm}

constructor TfFrameCounter.Create(AOwner: TComponent);
begin
  inherited;
  BtnPause.Enabled := False;
end;

procedure TfFrameCounter.SaveCountResult(const nProcess: Boolean);
var nDai: Integer;
begin
  if IsNumber(LabelHint.Caption, False) then
       nDai := StrToInt(LabelHint.Caption)
  else nDai := 0;

  if (FBill <> '') and (nDai > 0) then
  try
    BtnClear.Enabled := False;
    if nProcess then
      ShowWaitForm(Application.MainForm, '保存袋数');
    SaveTruckCountData(FBill, nDai);
  finally
    BtnClear.Enabled := True;
    if nProcess then CloseWaitForm;
  end;
end;

procedure TfFrameCounter.BtnClearClick(Sender: TObject);
begin
  try
    if Assigned(Sender) then
    begin
      {$IFDEF USE_MIT}
      StopJS(FTunnel.FID);
      {$ELSE}
      gMultiJSManager.DelJS(FTunnel.FID);
      if not BtnStart.Enabled then
        SaveCountResult(True);
      //正常计数
      {$ENDIF}
    end;
  finally
    FBill := '' ;
    LabelHint.Caption := '0';

    EditTruck.Text := '';
    EditDai.Text := '';
    EditTon.Text := '';
        
    EditDai.Enabled := True;
    EditTon.Enabled := True;
    BtnStart.Enabled := True;
    BtnPause.Enabled := False;
  end;
end;

procedure TfFrameCounter.BtnStartClick(Sender: TObject);
var nHint: string;
    nInt: Integer;
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then
  begin
    ShowDlg('请刷新队列获取车辆信息', sHint);
    Exit;
  end;

  if (not IsNumber(EditDai.Text, False)) or (StrToInt(EditDai.Text) <= 0) then
  begin
    ShowDlg('请输入袋数', sHint);
    Exit;
  end;

  BtnStart.Enabled := False;
  //disabled
  ShowWaitForm(Application.MainForm, '连接喷码机', True);
  try
    Sleep(1000);

    if not PrintBillCode(FTunnel.FID, FBill, nHint) then
    begin
      CloseWaitForm;
      Application.ProcessMessages;

      ShowDlg(nHint, sWarn);
      Exit;
    end;

    nInt := StrToInt(EditDai.Text);
    {$IFDEF USE_MIT}
    ShowWaitForm(nil, '连接计数器');
    StartJS(FTunnel.FID, EditTruck.Text, FBill, nInt);
    {$ELSE}
    gMultiJSManager.AddJS(FTunnel.FID, EditTruck.Text, '', nInt);
    {$ENDIF}

    Timer1.Enabled := True;
    //计数
  finally
    CloseWaitForm;
    BtnStart.Enabled := True;
  end;

  EditDai.Enabled := False;
  EditTon.Enabled := False;
  BtnStart.Enabled := False;

  {$IFNDEF USE_MIT}
  BtnPause.Enabled := True;
  {$ENDIF}
end;

procedure TfFrameCounter.EditTonDblClick(Sender: TObject);
var nStr: string;
begin
  nStr := IntToStr(FPeerWeight);
  if not ShowInputBox('请输入袋重: ', sHint, nStr) then Exit;

  if IsNumber(nStr, False) and (StrToInt(nStr) > 0) then
       FPeerWeight := StrToInt(nStr)
  else ShowMsg('袋重为大于0的整数', sHint);
end;

procedure TfFrameCounter.EditTonChange(Sender: TObject);
var nVal: Double;
begin
  if not EditTon.Focused then Exit;
  if FPeerWeight < 1 then FPeerWeight := 50;
  if not IsNumber(EditTon.Text, True) then Exit;

  nVal := StrToFloat(EditTon.Text) * 1000 / FPeerWeight;
  EditDai.Text := IntToStr(Trunc(nVal));
end;

procedure TfFrameCounter.Timer1Timer(Sender: TObject);
begin
  if (not BtnStart.Enabled) and IsNumber(LabelHint.Caption, False) then
  begin
    FDaiNum := StrToInt(LabelHint.Caption);
    if StrToInt(EditDai.Text) <> FDaiNum then Exit;

    Timer1.Enabled := False;
    {$IFDEF USE_MIT}
    BtnClearClick(nil);
    {$ELSE}
    BtnClear.Click;
    {$ENDIF}
    ShowMsg('装车完成', sHint);
  end;
end;

procedure TfFrameCounter.BtnPauseClick(Sender: TObject);
begin
  {$IFDEF USE_MIT}
  PauseJS(FTunnel.FID);
  {$ELSE}
  gMultiJSManager.PauseJS(FTunnel.FID);
  {$ENDIF}
  BtnStart.Enabled := True;
end;

end.
