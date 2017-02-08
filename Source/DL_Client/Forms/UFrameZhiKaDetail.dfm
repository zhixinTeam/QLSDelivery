inherited fFrameZhiKaDetail: TfFrameZhiKaDetail
  Width = 686
  inherited ToolBar1: TToolBar
    Width = 686
    inherited BtnAdd: TToolButton
      Caption = #21150#29702
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
    inherited S1: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 686
    Height = 162
    LevelTabs.Slants.Kind = skCutCorner
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OptionsSelection.MultiSelect = True
    end
    inherited cxLevel1: TcxGridLevel
      Caption = #24050#21150#29702
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 686
    Height = 138
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.Z_ID'
      ParentFont = False
      TabOrder = 3
      Width = 112
    end
    object EditCus: TcxButtonEdit [1]
      Left = 256
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditZKPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 135
    end
    object EditZK: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditZKPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 112
    end
    object EditDate: TcxButtonEdit [3]
      Left = 454
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 185
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 256
      Top = 93
      Hint = 'T.D_StockName'
      ParentFont = False
      TabOrder = 4
      Width = 135
    end
    object cxTextEdit2: TcxTextEdit [5]
      Left = 617
      Top = 93
      Hint = 'T.C_Name'
      ParentFont = False
      TabOrder = 6
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit [6]
      Left = 454
      Top = 93
      Hint = 'T.D_Value'
      ParentFont = False
      TabOrder = 5
      Width = 100
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = EditZK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #27700#27877#21697#31181':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21150#29702#21544#25968':'
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
    Width = 686
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 686
    inherited TitleBar: TcxLabel
      Caption = #32440#21345#26126#32454#26597#35810
      Style.IsFontAssigned = True
      Width = 686
      AnchorX = 343
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 2
    Top = 242
  end
  inherited DataSource1: TDataSource
    Left = 30
    Top = 242
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 2
    Top = 270
    object N4: TMenuItem
      Caption = #8251#32440#21345#20923#32467#8251
      Enabled = False
    end
    object N7: TMenuItem
      Tag = 30
      Caption = #20923#32467#32440#21345
      OnClick = N1Click
    end
    object N10: TMenuItem
      Tag = 40
      Caption = #35299#38500#20923#32467
      OnClick = N1Click
    end
    object N8: TMenuItem
      Caption = #25353#21697#31181#20923#32467
      OnClick = N8Click
    end
    object N17: TMenuItem
      Caption = #25353#21512#21516#21306#22495#20923#32467
      OnClick = N17Click
    end
    object N18: TMenuItem
      Caption = #25353#21512#21516#21306#22495#35299#20923
      OnClick = N17Click
    end
    object N20: TMenuItem
      Caption = #25353#19994#21153#21592#21306#22495#20923#32467
      OnClick = N20Click
    end
    object N19: TMenuItem
      Caption = #25353#19994#21153#21592#21306#22495#35299#20923
      OnClick = N20Click
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Caption = #8251#32440#21345#35843#20215#8251
      Enabled = False
    end
    object N14: TMenuItem
      Caption = #20215#26684#35843#25972
      OnClick = N6Click
    end
    object N13: TMenuItem
      Caption = #35843#20215#35760#24405
      OnClick = N13Click
    end
    object N11: TMenuItem
      Caption = #35843#20215#35774#32622
      object N15: TMenuItem
        Tag = 10
        Caption = #21442#19982#35843#20215
        OnClick = N15Click
      end
      object N16: TMenuItem
        Tag = 20
        Caption = #19981#21442#19982#35843#20215
        OnClick = N15Click
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #8251#20449#24687#26597#35810#8251
      Enabled = False
    end
    object N1: TMenuItem
      Tag = 10
      Caption = #26080#25928#32440#21345
      OnClick = N1Click
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096
      OnClick = N1Click
    end
    object N12: TMenuItem
      Tag = 50
      Caption = #24050#20923#32467#32440#21345
      OnClick = N1Click
    end
  end
end
