inherited fFormStockMatch: TfFormStockMatch
  Left = 457
  Top = 241
  Caption = #22810#21697#31181#20849#29992#36890#36947
  ClientHeight = 204
  ClientWidth = 411
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 411
    Height = 204
    inherited BtnOK: TButton
      Left = 265
      Top = 171
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 335
      Top = 171
      TabOrder = 7
    end
    object EditID: TcxTextEdit [2]
      Left = 81
      Top = 36
      Hint = 'T.M_Group'
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 210
    end
    object CheckValid: TcxCheckBox [3]
      Left = 11
      Top = 171
      Hint = 'T.M_Status'
      Caption = #26159#21542#26377#25928
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Transparent = True
      Width = 80
    end
    object EditName: TcxTextEdit [4]
      Left = 81
      Top = 61
      Hint = 'T.M_LineNo'
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object chkcbbStockname: TcxCheckComboBox [5]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.EditValueFormat = cvfCaptions
      Properties.Items = <>
      Properties.OnChange = chkcbbStocknamePropertiesChange
      TabOrder = 4
      Width = 121
    end
    object editStockno: TcxTextEdit [6]
      Left = 81
      Top = 86
      Hint = 'T.M_ID'
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object editStockname: TcxTextEdit [7]
      Left = 81
      Top = 111
      Hint = 'T.M_Name'
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object LayItem1: TdxLayoutItem
          Caption = #20998#32452#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36890#36947#32534#21495':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21697#31181#32534#21495
          Control = editStockno
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21697#31181#21517#31216
          Control = editStockname
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #21697#31181#21517#31216
          Control = chkcbbStockname
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem [0]
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 181
    Top = 169
  end
end
