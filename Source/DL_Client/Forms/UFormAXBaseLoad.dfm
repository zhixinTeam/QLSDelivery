inherited fFormAXBaseLoad: TfFormAXBaseLoad
  Top = 287
  Caption = #37319#36141#22522#30784#25968#25454#19979#36733
  ClientHeight = 321
  ClientWidth = 333
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 333
    Height = 321
    inherited BtnOK: TButton
      Left = 187
      Top = 288
      Caption = #19979#36733
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 257
      Top = 288
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
  object chkProviders: TcxCheckBox
    Left = 151
    Top = 36
    Caption = ' '#20379#24212#21830#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 3
    Width = 154
  end
  object chkInvent: TcxCheckBox
    Left = 23
    Top = 81
    Caption = ' '#29289#26009#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 4
    Width = 123
  end
  object chkINVENTDIM: TcxCheckBox
    Left = 23
    Top = 104
    Caption = ' '#32500#24230#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 5
    Width = 123
  end
  object chkINVENTLOCATION: TcxCheckBox
    Left = 151
    Top = 105
    Caption = ' '#20179#24211#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 6
    Width = 154
  end
  object chkInvCenGroup: TcxCheckBox
    Left = 151
    Top = 128
    Caption = ' '#29289#26009#32452#29983#20135#32447#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 7
    Width = 154
  end
  object chkEmpl: TcxCheckBox
    Left = 23
    Top = 151
    Caption = ' '#21592#24037#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 8
    Width = 123
  end
  object chkINVENTCENTER: TcxCheckBox
    Left = 23
    Top = 127
    Caption = ' '#29983#20135#32447#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 9
    Width = 123
  end
  object chkCement: TcxCheckBox
    Left = 151
    Top = 82
    Caption = ' '#27700#27877#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 10
    Width = 154
  end
  object chkTruck: TcxCheckBox
    Left = 151
    Top = 151
    Caption = ' '#36710#36742#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 11
    Width = 154
  end
  object chkSalOrder: TcxCheckBox
    Left = 23
    Top = 174
    Caption = ' '#38144#21806#35746#21333
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 12
    Width = 123
  end
  object chkSalOrderLine: TcxCheckBox
    Left = 151
    Top = 174
    Caption = ' '#38144#21806#35746#21333#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 13
    Width = 154
  end
  object chkContract: TcxCheckBox
    Left = 23
    Top = 197
    Caption = ' '#38144#21806#21512#21516
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 14
    Width = 123
  end
  object chkContractLine: TcxCheckBox
    Left = 151
    Top = 197
    Caption = ' '#38144#21806#21512#21516#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 15
    Width = 154
  end
  object chkPurOrder: TcxCheckBox
    Left = 23
    Top = 220
    Caption = ' '#37319#36141#35746#21333
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 16
    Width = 123
  end
  object chkPurOrdLine: TcxCheckBox
    Left = 151
    Top = 220
    Caption = ' '#37319#36141#35746#21333#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 17
    Width = 154
  end
  object chkSupAgr: TcxCheckBox
    Left = 23
    Top = 244
    Caption = ' '#34917#20805#21327#35758
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 18
    Width = 123
  end
  object chkKuWei: TcxCheckBox
    Left = 151
    Top = 244
    Caption = ' '#24211#20301#20449#24687
    Enabled = False
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 19
    Width = 123
  end
end
