object fFormMain: TfFormMain
  Left = 329
  Top = 201
  Width = 577
  Height = 421
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'HKSnap System'
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
    Width = 561
    Height = 70
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 295
      Top = 26
      Width = 30
      Height = 12
      Caption = #23631#21345':'
    end
    object Label2: TLabel
      Left = 295
      Top = 48
      Width = 30
      Height = 12
      Caption = #20869#23481':'
    end
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
    object BtnTest: TButton
      Left = 484
      Top = 45
      Width = 55
      Height = 22
      Caption = #21457#36865
      Enabled = False
      TabOrder = 4
      OnClick = BtnTestClick
    end
    object EditCard: TComboBox
      Left = 330
      Top = 20
      Width = 145
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      TabOrder = 5
    end
    object EditText: TEdit
      Left = 330
      Top = 46
      Width = 145
      Height = 20
      TabOrder = 6
      Text = #27979#35797#20869#23481
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 150
    Width = 561
    Height = 214
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 364
    Width = 561
    Height = 19
    Panels = <>
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 70
    Width = 561
    Height = 80
    Align = alClient
    Caption = #25235#25293
    TabOrder = 3
    object Label3: TLabel
      Left = 4
      Top = 35
      Width = 60
      Height = 12
      Caption = #25235#25293#25668#20687#26426
    end
    object EditSnap: TComboBox
      Left = 65
      Top = 31
      Width = 113
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      TabOrder = 0
    end
    object Button1: TButton
      Left = 9
      Top = 52
      Width = 75
      Height = 25
      Caption = #24320#22987#25235#25293
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 100
      Top = 52
      Width = 75
      Height = 25
      Caption = #20572#27490#25235#25293
      TabOrder = 2
      OnClick = Button2Click
    end
    object SnapView1: TPanel
      Left = 176
      Top = 8
      Width = 89
      Height = 68
      TabOrder = 3
    end
    object BtnConn: TButton
      Left = 100
      Top = 8
      Width = 75
      Height = 23
      Caption = #25968#25454#36830#25509
      TabOrder = 4
      OnClick = BtnConnClick
    end
    object SnapView2: TPanel
      Left = 266
      Top = 8
      Width = 92
      Height = 68
      TabOrder = 5
    end
    object SnapView3: TPanel
      Left = 360
      Top = 8
      Width = 92
      Height = 68
      TabOrder = 6
    end
    object SnapView4: TPanel
      Left = 455
      Top = 8
      Width = 92
      Height = 67
      TabOrder = 7
    end
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 14
    Top = 154
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 42
    Top = 154
  end
end
