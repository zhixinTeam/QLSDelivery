object fFormMain: TfFormMain
  Left = 329
  Top = 201
  Width = 557
  Height = 394
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Remote Printer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 549
    Height = 70
    Align = alTop
    TabOrder = 0
    object CheckSrv: TCheckBox
      Left = 45
      Top = 45
      Width = 100
      Height = 17
      Caption = #21551#21160#23432#25252#26381#21153
      TabOrder = 0
      OnClick = CheckSrvClick
    end
    object EditPort: TLabeledEdit
      Left = 45
      Top = 20
      Width = 80
      Height = 20
      EditLabel.Width = 30
      EditLabel.Height = 12
      EditLabel.Caption = #31471#21475':'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
    end
    object CheckAuto: TCheckBox
      Left = 180
      Top = 23
      Width = 100
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160
      TabOrder = 2
    end
    object CheckLoged: TCheckBox
      Left = 180
      Top = 45
      Width = 100
      Height = 17
      Caption = #26174#31034#35843#35797#26085#24535
      TabOrder = 3
      OnClick = CheckLogedClick
    end
    object BtnConn: TButton
      Left = 312
      Top = 37
      Width = 75
      Height = 25
      Caption = #25968#25454#36830#25509
      TabOrder = 4
      OnClick = BtnConnClick
    end
    object BtnTest: TButton
      Left = 416
      Top = 37
      Width = 89
      Height = 25
      Caption = #21457#36865#25171#21360#25968#25454
      TabOrder = 5
      OnClick = BtnTestClick
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 70
    Width = 549
    Height = 274
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 344
    Width = 549
    Height = 19
    Panels = <>
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 14
    Top = 114
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 42
    Top = 114
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 70
    Top = 114
  end
end
