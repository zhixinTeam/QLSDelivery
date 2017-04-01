object fFormMain: TfFormMain
  Left = 379
  Top = 162
  Width = 787
  Height = 544
  Caption = 'SQL Server'#25968#25454#24211#20998#26512#24037#20855
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 771
    Height = 89
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 48
      Width = 42
      Height = 12
      Caption = #34920#21517#31216':'
    end
    object Label2: TLabel
      Left = 216
      Top = 48
      Width = 54
      Height = 12
      Caption = #23383#27573#21517#31216':'
    end
    object Label3: TLabel
      Left = 464
      Top = 48
      Width = 54
      Height = 12
      Caption = #23383#27573#21462#20540':'
    end
    object BtnConn: TButton
      Left = 14
      Top = 8
      Width = 75
      Height = 25
      Caption = '1.'#36830#25509
      TabOrder = 0
      OnClick = BtnConnClick
    end
    object BtnParse: TButton
      Left = 99
      Top = 8
      Width = 75
      Height = 25
      Caption = '2.'#20998#26512
      TabOrder = 1
      OnClick = BtnParseClick
    end
    object BtnSave: TButton
      Left = 184
      Top = 8
      Width = 75
      Height = 25
      Caption = '3.'#20445#23384
      TabOrder = 2
      OnClick = BtnSaveClick
    end
    object BtnEnum: TButton
      Left = 336
      Top = 8
      Width = 75
      Height = 25
      Caption = '*.'#26816#32034
      TabOrder = 3
      OnClick = BtnEnumClick
    end
    object EditTable: TEdit
      Left = 72
      Top = 44
      Width = 121
      Height = 20
      Hint = #34920#21517#31216
      TabOrder = 4
    end
    object BtnQuery: TButton
      Left = 488
      Top = 8
      Width = 121
      Height = 25
      Caption = #26597#35810#25351#23450#34920#20449#24687
      TabOrder = 5
      OnClick = BtnQueryClick
    end
    object BtnSaveTable: TButton
      Left = 616
      Top = 8
      Width = 150
      Height = 25
      Caption = #20445#23384#25351#23450#34920#20449#24687
      TabOrder = 6
      OnClick = BtnSaveTableClick
    end
    object EditField: TEdit
      Left = 288
      Top = 44
      Width = 121
      Height = 20
      Hint = #34920#21517#31216
      TabOrder = 7
    end
    object EditValue: TEdit
      Left = 536
      Top = 44
      Width = 121
      Height = 20
      Hint = #34920#21517#31216
      TabOrder = 8
    end
  end
  object MemoSQL: TMemo
    Left = 0
    Top = 89
    Width = 417
    Height = 398
    Align = alLeft
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object stat1: TStatusBar
    Left = 0
    Top = 487
    Width = 771
    Height = 19
    Panels = <>
  end
  object mmoResult: TMemo
    Left = 424
    Top = 89
    Width = 347
    Height = 398
    Align = alRight
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Left = 426
    Top = 6
  end
  object Query1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 454
    Top = 6
  end
end
