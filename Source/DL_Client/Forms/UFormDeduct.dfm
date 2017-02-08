inherited fFormDeduct: TfFormDeduct
  Left = 586
  Top = 381
  ClientHeight = 257
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 257
    inherited BtnOK: TButton
      Left = 229
      Top = 224
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 224
      TabOrder = 6
    end
    object EditValue: TcxTextEdit [2]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Text = '0.00'
      Width = 121
    end
    object CheckValid: TcxCheckBox [3]
      Left = 23
      Top = 165
      Caption = #35813#35268#21017#26377#25928'.'
      ParentFont = False
      TabOrder = 3
      Transparent = True
      Width = 80
    end
    object CheckPercent: TcxCheckBox [4]
      Left = 23
      Top = 191
      Caption = #25353#20928#37325#30334#20998#27604#25187#20943'.'
      ParentFont = False
      TabOrder = 4
      Transparent = True
      Width = 310
    end
    object EditStock: TcxButtonEdit [5]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditStockPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditCus: TcxButtonEdit [6]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditCusPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25187' '#20943' '#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #35268#21017#21442#25968
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          ShowCaption = False
          Control = CheckPercent
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
