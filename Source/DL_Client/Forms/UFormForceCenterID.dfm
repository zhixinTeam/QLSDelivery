inherited fFormForceCenterID: TfFormForceCenterID
  Left = 478
  Top = 286
  Caption = #29983#20135#32447#20851#32852
  ClientHeight = 249
  ClientWidth = 547
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 547
    Height = 249
    inherited BtnOK: TButton
      Left = 401
      Top = 216
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 471
      Top = 216
      TabOrder = 8
    end
    object EditName: TcxTextEdit [2]
      Left = 93
      Top = 61
      Hint = 'F.F_Name'
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 110
    end
    object CheckValid: TcxCheckBox [3]
      Left = 11
      Top = 216
      Hint = 'F.F_Valid'
      Caption = #20851#32852#26377#25928
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Transparent = True
      Width = 80
    end
    object EditStockID: TcxComboBox [4]
      Left = 93
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
    object cbxCenterID: TcxComboBox [5]
      Left = 93
      Top = 136
      ParentFont = False
      Properties.ReadOnly = False
      Properties.OnChange = cbxCenterIDPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 4
      Width = 216
    end
    object EditID: TcxComboBox [6]
      Left = 93
      Top = 36
      ParentFont = False
      Properties.OnChange = EditIDPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxTextEdit [7]
      Left = 93
      Top = 111
      Hint = 'F.F_Stock'
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object cbxCusGroup: TcxComboBox [8]
      Left = 93
      Top = 161
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsDefault
      TabOrder = 5
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item21: TdxLayoutItem
          Caption = #21697#31181#32534#21495':'
          Control = EditStockID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #21697#31181#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29983#20135#32447'ID:'
          Control = cbxCenterID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#25152#22312#32452':'
          Control = cbxCusGroup
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
