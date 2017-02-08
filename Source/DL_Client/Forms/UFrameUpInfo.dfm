inherited fFrameUpInfo: TfFrameUpInfo
  Width = 979
  Height = 544
  inherited ToolBar1: TToolBar
    Width = 979
    inherited BtnAdd: TToolButton
      Caption = #26032#22686
      Enabled = False
      Visible = False
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Enabled = False
      Visible = False
    end
    inherited BtnDel: TToolButton
      Enabled = False
      Visible = False
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 979
    Height = 339
    LevelTabs.Slants.Kind = skCutCorner
    LevelTabs.Style = 9
    RootLevelOptions.DetailTabsPosition = dtpTop
    OnActiveTabChanged = cxGrid1ActiveTabChanged
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
    object cxView2: TcxGridDBTableView [1]
      OnDblClick = cxView2DblClick
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 979
    Height = 138
    object EditBill: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditCus: TcxButtonEdit [2]
      Left = 457
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditDate: TcxButtonEdit [3]
      Left = 645
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 3
      Width = 185
    end
    object cxTextEdit1: TcxTextEdit [4]
      Left = 81
      Top = 94
      Hint = 'T.L_ID'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Width = 125
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 269
      Top = 94
      Hint = 'T.L_Truck'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [6]
      Left = 457
      Top = 94
      Hint = 'T.L_CusName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 121
    end
    object CheckDelete: TcxCheckBox [7]
      Left = 835
      Top = 36
      Caption = #26597#35810#24050#21024#38500
      ParentFont = False
      TabOrder = 4
      OnClick = CheckDeleteClick
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #20132#36135#21333#21495':'
          Control = EditBill
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckDelete
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #20132#36135#21333#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 979
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 979
    inherited TitleBar: TcxLabel
      Caption = #38144#21806#19978#20256#35760#24405#26597#35810
      Style.IsFontAssigned = True
      Width = 979
      AnchorX = 490
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 2
    Top = 262
  end
  inherited DataSource1: TDataSource
    Left = 30
    Top = 262
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 2
    Top = 294
    object N1: TMenuItem
      Caption = #26597#35810#36873#39033
      object N5: TMenuItem
        Caption = #26410#19978#20256#25552#36135#21333
        OnClick = N5Click
      end
      object N8: TMenuItem
        Caption = #26410#19978#20256#30917#21333
        OnClick = N8Click
      end
      object N6: TMenuItem
        Caption = #26597#35810#20840#37096
        OnClick = N6Click
      end
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N9: TMenuItem
      Caption = #25209#37327#19978#20256#25552#36135#21333
      OnClick = N9Click
    end
    object N10: TMenuItem
      Caption = #25209#37327#19978#20256#30917#21333
      OnClick = N10Click
    end
  end
end
