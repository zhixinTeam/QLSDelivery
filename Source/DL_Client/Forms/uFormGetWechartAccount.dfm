inherited fFormGetWechartAccount: TfFormGetWechartAccount
  Left = 445
  Top = 249
  Caption = 'fFormGetWechartAccount'
  ClientHeight = 398
  ClientWidth = 638
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 638
    Height = 398
    inherited BtnOK: TButton
      Left = 492
      Top = 365
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 562
      Top = 365
      TabOrder = 4
    end
    object edtinput: TcxTextEdit [2]
      Left = 87
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      OnKeyPress = edtinputKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [3]
      Left = 23
      Top = 61
      Caption = #26597#35810#32467#26524
      ParentFont = False
      Style.HotTrack = False
      Transparent = True
    end
    object ListQuery: TcxListView [4]
      Left = 23
      Top = 82
      Width = 576
      Height = 271
      Columns = <
        item
          Caption = #30331#24405#36134#21495
          Width = 150
        end
        item
          Caption = #37038#31665
          Width = 120
        end
        item
          Caption = #25163#26426
          Width = 120
        end
        item
          Caption = 'customerid'
          Width = 1
        end>
      ParentFont = False
      RowSelect = True
      SmallImages = FDM.ImageBar
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = ListQueryDblClick
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25163#26426#21495#30721#65306
          Control = edtinput
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Control = ListQuery
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
