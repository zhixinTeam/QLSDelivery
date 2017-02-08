inherited fFrameInvoiceK: TfFrameInvoiceK
  Width = 773
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 773
    inherited BtnAdd: TToolButton
      Caption = '  '#24320#21457#31080'  '
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Caption = #20316#24223
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 199
    Width = 773
    Height = 237
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OptionsSelection.MultiSelect = True
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 773
    Height = 132
    object EditWeek: TcxButtonEdit [0]
      Left = 279
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 1
      Width = 266
    end
    object EditCus: TcxButtonEdit [1]
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
      Width = 135
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 81
      Top = 93
      Hint = 'T.R_Stock'
      ParentFont = False
      TabOrder = 2
      Width = 135
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 321
      Top = 93
      Hint = 'T.R_Price'
      ParentFont = False
      TabOrder = 3
      Width = 75
    end
    object cxTextEdit5: TcxTextEdit [4]
      Left = 471
      Top = 93
      Hint = 'T.R_ReqValue'
      ParentFont = False
      TabOrder = 4
      Width = 75
    end
    object cxTextEdit6: TcxTextEdit [5]
      Left = 609
      Top = 93
      Hint = 'T.R_Customer'
      ParentFont = False
      TabOrder = 5
      Width = 254
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #21608#26399#31579#36873':'
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #27700#27877#21517#31216':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #24320#31080#21333#20215'('#20803'/'#21544'):'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #24320#31080#37327'('#21544'):'
          Control = cxTextEdit5
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit6
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 191
    Width = 773
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 773
    inherited TitleBar: TcxLabel
      Caption = #24320#20855#38144#21806#21457#31080
      Style.IsFontAssigned = True
      Width = 773
      AnchorX = 387
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 4
    Top = 264
    object N1: TMenuItem
      Tag = 10
      Caption = #24320#20855#21457#31080
      OnClick = BtnAddClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Tag = 20
      Caption = #26597#30475#26126#32454
      OnClick = N4Click
    end
    object N3: TMenuItem
      Tag = 30
      Caption = #26597#35810#26410#24320
      OnClick = N3Click
    end
  end
end
