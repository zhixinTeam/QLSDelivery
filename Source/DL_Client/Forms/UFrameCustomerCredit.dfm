inherited fFrameCustomerCredit: TfFrameCustomerCredit
  Width = 773
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 773
    inherited BtnAdd: TToolButton
      Enabled = False
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Caption = #20449#29992#21464#21160
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      Enabled = False
      Visible = False
    end
    inherited S1: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 773
    Height = 234
    LevelTabs.Slants.Kind = skCutCorner
    LevelTabs.Style = 9
    RootLevelOptions.DetailTabsPosition = dtpTop
    inherited cxView1: TcxGridDBTableView
      OnDblClick = cxView1DblClick
    end
    object cxView2: TcxGridDBTableView [1]
      NavigatorButtons.ConfirmDelete = False
      OnFocusedRecordChanged = cxView2FocusedRecordChanged
      DataController.DataSource = DataSource2
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    inherited cxLevel1: TcxGridLevel
      Caption = #23458#25143#20449#29992
    end
    object cxLevel2: TcxGridLevel
      Caption = #21464#21160#26126#32454
      GridView = cxView2
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 773
    Height = 135
    object EditID: TcxButtonEdit [0]
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
    object EditName: TcxButtonEdit [1]
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
      Width = 120
    end
    object EditCusID: TcxTextEdit [2]
      Left = 81
      Top = 94
      Hint = 'T.C_ID'
      ParentFont = False
      TabOrder = 4
      Width = 105
    end
    object EditCusName: TcxTextEdit [3]
      Left = 249
      Top = 94
      Hint = 'T.C_Name'
      ParentFont = False
      TabOrder = 5
      Width = 120
    end
    object EditMoney: TcxTextEdit [4]
      Left = 456
      Top = 94
      Hint = 'T.A_CreditLimit'
      ParentFont = False
      TabOrder = 6
      Width = 74
    end
    object EditMemo: TcxTextEdit [5]
      Left = 593
      Top = 94
      ParentFont = False
      TabOrder = 7
      Width = 121
    end
    object EditDate: TcxButtonEdit [6]
      Left = 432
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 176
    end
    object chkZKZY: TcxCheckBox [7]
      Left = 613
      Top = 36
      Caption = #19987#27454#19987#29992
      ParentFont = False
      TabOrder = 3
      OnClick = chkZKZYClick
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = chkZKZY
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #20449#29992#37329#39069'('#20803'):'
          Control = EditMoney
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 773
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 773
    inherited TitleBar: TcxLabel
      Caption = #23458#25143#20449#29992#31649#29702
      Style.IsFontAssigned = True
      Width = 773
      AnchorX = 387
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 256
  end
  inherited DataSource1: TDataSource
    Top = 256
  end
  object QueryDtl: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 6
    Top = 284
  end
  object DataSource2: TDataSource
    DataSet = QueryDtl
    Left = 34
    Top = 284
  end
end
