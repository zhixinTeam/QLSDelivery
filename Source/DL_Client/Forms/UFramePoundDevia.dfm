inherited fFramePoundDevia: TfFramePoundDevia
  inherited ToolBar1: TToolBar
    inherited BtnAdd: TToolButton
      Enabled = False
      Visible = False
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
  inherited dxLayout1: TdxLayoutControl
    object EditDate: TcxButtonEdit [0]
      Left = 81
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 0
      Width = 200
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 344
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 1
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #31216#37325#35823#24046#26597#35810
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
