inherited fFrameZTQuery: TfFrameZTQuery
  inherited ToolBar1: TToolBar
    inherited BtnAdd: TToolButton
      Caption = #35774#32622
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Enabled = False
      Visible = False
    end
    inherited BtnDel: TToolButton
      Enabled = False
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    inherited cxView1: TcxGridDBTableView
      PopupMenu = pm1
    end
    inherited cxLevel1: TcxGridLevel
      Caption = #35013#36710#26597#35810
    end
  end
  inherited dxLayout1: TdxLayoutControl
    object EditDate: TcxButtonEdit [0]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 0
      Width = 176
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 332
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = EditTruckKeyPress
      Width = 100
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#31579#36873#65306
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721#65306
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #35013#36710#26597#35810
      Style.IsFontAssigned = True
      AnchorX = 351
      AnchorY = 11
    end
  end
  object pm1: TPopupMenu
    Left = 6
    Top = 232
    object N1: TMenuItem
      Caption = #25171#21360#23567#31080
      OnClick = N1Click
    end
  end
end
