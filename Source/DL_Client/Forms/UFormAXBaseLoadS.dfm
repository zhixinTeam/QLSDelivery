inherited fFormAXBaseLoadS: TfFormAXBaseLoadS
  Top = 287
  Caption = #38144#21806#22522#30784#25968#25454#19979#36733
  ClientHeight = 185
  ClientWidth = 333
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 333
    Height = 185
    inherited BtnOK: TButton
      Left = 187
      Top = 152
      Caption = #19979#36733
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 257
      Top = 152
      TabOrder = 2
    end
    object chkCustomer: TcxCheckBox [2]
      Left = 23
      Top = 36
      Caption = ' '#23458#25143#20449#24687
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #19979#36733#36873#39033
        LayoutDirection = ldHorizontal
        object dxLayout1Item3: TdxLayoutItem
          Control = chkCustomer
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object chkTPRESTIGEMANAGE: TcxCheckBox
    Left = 23
    Top = 58
    Caption = ' '#20449#29992#39069#24230#65288#23458#25143#65289
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 1
    Width = 123
  end
  object chkTPRESTIGEMBYCONT: TcxCheckBox
    Left = 151
    Top = 59
    Caption = ' '#20449#29992#39069#24230#65288#23458#25143'-'#21512#21516#65289
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 2
    Width = 154
  end
  object chkSalOrder: TcxCheckBox
    Left = 23
    Top = 84
    Caption = ' '#38144#21806#35746#21333
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 3
    Width = 123
  end
  object chkSalOrderLine: TcxCheckBox
    Left = 151
    Top = 84
    Caption = ' '#38144#21806#35746#21333#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 4
    Width = 154
  end
  object chkContract: TcxCheckBox
    Left = 23
    Top = 107
    Caption = ' '#38144#21806#21512#21516
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 5
    Width = 123
  end
  object chkContractLine: TcxCheckBox
    Left = 151
    Top = 107
    Caption = ' '#38144#21806#21512#21516#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 6
    Width = 154
  end
  object chkSupAgr: TcxCheckBox
    Left = 151
    Top = 36
    Caption = ' '#34917#20805#21327#35758
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 7
    Width = 123
  end
end
