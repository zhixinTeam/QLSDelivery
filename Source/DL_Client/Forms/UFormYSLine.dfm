inherited fFormYSLine: TfFormYSLine
  Left = 457
  Top = 241
  Caption = #39564#25910#36890#36947#37197#32622
  ClientHeight = 200
  ClientWidth = 302
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 302
    Height = 200
    inherited BtnOK: TButton
      Left = 156
      Top = 167
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 226
      Top = 167
      TabOrder = 6
    end
    object EditID: TcxTextEdit [2]
      Left = 81
      Top = 36
      Hint = 'T.Z_ID'
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 210
    end
    object CheckValid: TcxCheckBox [3]
      Left = 11
      Top = 167
      Hint = 'T.Z_Valid'
      Caption = #36890#36947#26377#25928
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Transparent = True
      Width = 80
    end
    object EditStockName: TcxTextEdit [4]
      Left = 81
      Top = 111
      Hint = 'T.Z_Stock'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 3
      Width = 121
    end
    object EditStockID: TcxComboBox [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      Properties.MaxLength = 20
      Properties.OnChange = EditStockIDPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      Width = 210
    end
    object EditName: TcxTextEdit [6]
      Left = 81
      Top = 61
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object LayItem1: TdxLayoutItem
          Caption = #36890#36947#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36890#36947#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item21: TdxLayoutItem
          Caption = #21697#31181#32534#21495':'
          Control = EditStockID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21697#31181#21517#31216':'
          Control = EditStockName
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
end
