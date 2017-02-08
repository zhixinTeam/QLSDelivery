object fFormCard: TfFormCard
  Left = 525
  Top = 391
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #35831#21047#30913#21345
  ClientHeight = 122
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  DesignSize = (
    275
    122)
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 16
    Top = 28
    Width = 114
    Height = 12
    Caption = #35831#36755#20837#26377#25928#30340#30913#21345#21495':'
  end
  object BtnOK: TButton
    Left = 129
    Top = 90
    Width = 65
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 0
    OnClick = BtnOKClick
  end
  object BtnExit: TButton
    Left = 199
    Top = 90
    Width = 65
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 1
  end
  object EditCard: TEdit
    Left = 16
    Top = 46
    Width = 247
    Height = 20
    TabOrder = 2
  end
  object IdClient1: TIdUDPClient
    Port = 0
    Left = 8
    Top = 84
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalMultiplier = 10
    Timeouts.ReadTotalConstant = 100
    OnRxChar = ComPort1RxChar
    Left = 36
    Top = 84
  end
end
