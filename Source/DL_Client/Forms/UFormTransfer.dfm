inherited fFormTransfer: TfFormTransfer
  Left = 406
  Top = 312
  Caption = #20498#26009#31649#29702
  ClientHeight = 309
  ClientWidth = 385
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 385
    Height = 309
    inherited BtnOK: TButton
      Left = 239
      Top = 276
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 309
      Top = 276
      TabOrder = 9
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 61
      Enabled = False
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 96
    end
    object EditMate: TcxTextEdit [3]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 3
      Width = 96
    end
    object EditSrcAddr: TcxTextEdit [4]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 5
      Width = 96
    end
    object EditDstAddr: TcxTextEdit [5]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 7
      Width = 96
    end
    object EditMID: TcxComboBox [6]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.OnChange = EditMIDPropertiesChange
      TabOrder = 2
      Width = 121
    end
    object EditDC: TcxComboBox [7]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.OnChange = EditDCPropertiesChange
      TabOrder = 4
      Width = 121
    end
    object EditDR: TcxComboBox [8]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.OnChange = EditDCPropertiesChange
      TabOrder = 6
      Width = 121
    end
    object cbxSaleID: TcxComboBox [9]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item10: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = cbxSaleID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21407#26009#32534#21495':'
          Control = EditMID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21407#26009#21517#31216':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #20498#20986#32534#21495':'
          Control = EditDC
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #20498#20986#22320#28857':'
          Control = EditSrcAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #20498#20837#32534#21495':'
          Control = EditDR
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20498#20837#22320#28857':'
          Control = EditDstAddr
          ControlOptions.ShowBorder = False
        end
      end
    end
    object TdxLayoutGroup
    end
  end
end
