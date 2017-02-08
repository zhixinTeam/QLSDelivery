inherited fFrameHYData_Each: TfFrameHYData_Each
  Width = 837
  Height = 481
  inherited ToolBar1: TToolBar
    Width = 837
    inherited BtnAdd: TToolButton
      Caption = '   '#24320#21333'   '
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 179
    Width = 837
    Height = 302
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
      DataController.DataSource = DataSource2
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    inherited cxLevel1: TcxGridLevel
      Caption = #24050#24320#21270#39564#21333
    end
    object cxLevel2: TcxGridLevel
      Caption = #26410#24320#21270#39564#21333
      GridView = cxView2
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 837
    Height = 112
    object EditDate: TcxButtonEdit [0]
      Left = 630
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 3
      Width = 175
    end
    object EditCustomer: TcxButtonEdit [1]
      Left = 417
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 150
    end
    object EditID: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 105
    end
    object EditStock: TcxButtonEdit [3]
      Left = 249
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 105
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #21333#25454#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 171
    Width = 837
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 837
    inherited TitleBar: TcxLabel
      Caption = #27700#27877#21270#39564#21333#35760#24405
      Style.IsFontAssigned = True
      Width = 837
      AnchorX = 419
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 218
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 218
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 4
    Top = 272
    object N1: TMenuItem
      Caption = #25171#21360#21270#39564#21333
      OnClick = N1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #25171#21360#21512#26684#35777
      OnClick = N2Click
    end
  end
  object QueryNo: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 4
    Top = 246
  end
  object DataSource2: TDataSource
    DataSet = QueryNo
    Left = 32
    Top = 246
  end
end
