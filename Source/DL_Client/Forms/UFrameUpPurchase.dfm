inherited fFrameUpPurchase: TfFrameUpPurchase
  Width = 961
  inherited ToolBar1: TToolBar
    Width = 961
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
  inherited cxGrid1: TcxGrid
    Width = 961
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 961
    object EditBill: TcxButtonEdit [0]
      Left = 81
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      Width = 121
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 265
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
    object EditCus: TcxButtonEdit [2]
      Left = 437
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 2
      Width = 121
    end
    object EditDate: TcxButtonEdit [3]
      Left = 621
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 3
      Width = 185
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #20379#24212#21333#21495':'
          Control = EditBill
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #20379#24212#21830':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Width = 961
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 961
    inherited TitleBar: TcxLabel
      Caption = #37319#36141#19978#20256#26597#35810
      Style.IsFontAssigned = True
      Width = 961
      AnchorX = 481
      AnchorY = 11
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 5
    Top = 232
    object N1: TMenuItem
      Caption = #26410#19978#20256#30917#21333
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #26597#35810#20840#37096
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Caption = #25209#37327#19978#20256
      OnClick = N4Click
    end
  end
end
