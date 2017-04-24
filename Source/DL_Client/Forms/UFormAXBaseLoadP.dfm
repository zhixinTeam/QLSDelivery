inherited fFormAXBaseLoadP: TfFormAXBaseLoadP
  Top = 287
  Caption = #37319#36141#22522#30784#25968#25454#19979#36733
  ClientHeight = 135
  ClientWidth = 333
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 333
    Height = 135
    inherited BtnOK: TButton
      Left = 187
      Top = 102
      Caption = #19979#36733
    end
    inherited BtnExit: TButton
      Left = 257
      Top = 102
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #19979#36733#36873#39033
        LayoutDirection = ldHorizontal
      end
    end
  end
  object chkProviders: TcxCheckBox
    Left = 151
    Top = 36
    Caption = ' '#20379#24212#21830#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 1
    Width = 154
  end
  object chkInvent: TcxCheckBox
    Left = 23
    Top = 36
    Caption = ' '#29289#26009#20449#24687
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 2
    Width = 123
  end
  object chkPurOrder: TcxCheckBox
    Left = 22
    Top = 62
    Caption = ' '#37319#36141#35746#21333
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 3
    Width = 123
  end
  object chkPurOrdLine: TcxCheckBox
    Left = 151
    Top = 62
    Caption = ' '#37319#36141#35746#21333#34892
    ParentFont = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.HotTrack = False
    TabOrder = 4
    Width = 154
  end
end
