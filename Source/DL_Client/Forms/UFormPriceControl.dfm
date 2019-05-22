inherited fFormPriceControl: TfFormPriceControl
  Left = 482
  Top = 252
  ClientHeight = 269
  ClientWidth = 414
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 414
    Height = 269
    inherited BtnOK: TButton
      Left = 268
      Top = 236
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 338
      Top = 236
      TabOrder = 7
    end
    object CheckValid: TcxCheckBox [2]
      Left = 23
      Top = 203
      Caption = #21333#20215#26377#25928
      ParentFont = False
      TabOrder = 5
      Transparent = True
      Width = 80
    end
    object ChkUsePC: TcxCheckBox [3]
      Left = 23
      Top = 36
      Caption = #21551#29992#21333#20215#31649#29702
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditCus: TcxComboBox [4]
      Left = 81
      Top = 103
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.IncrementalSearch = False
      Properties.OnChange = EditCusPropertiesChange
      TabOrder = 1
      Width = 121
    end
    object EditPrice: TcxTextEdit [5]
      Left = 81
      Top = 153
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditMemo: TcxTextEdit [6]
      Left = 81
      Top = 178
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditStock: TcxComboBox [7]
      Left = 81
      Top = 128
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21333#20215#31649#29702#24635#25511#21046
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkUsePC
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #21333#20215#31649#29702#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #21333'    '#20215':'
          Control = EditPrice
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #25511#21046#22791#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
