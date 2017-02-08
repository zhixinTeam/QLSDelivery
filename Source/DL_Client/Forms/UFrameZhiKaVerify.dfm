inherited fFrameZhiKaVerify: TfFrameZhiKaVerify
  Width = 686
  inherited ToolBar1: TToolBar
    Width = 686
    inherited BtnAdd: TToolButton
      Caption = '   '#23457#26680'   '
      OnClick = BtnAddClick
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
    Top = 202
    Width = 686
    Height = 165
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 686
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 259
      Top = 96
      Hint = 'T.Z_ID'
      ParentFont = False
      TabOrder = 4
      Width = 115
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
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    object EditZK: TcxButtonEdit [2]
      Left = 259
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    object EditDate: TcxButtonEdit [3]
      Left = 437
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
      Left = 81
      Top = 96
      Hint = 'T.Z_CID'
      ParentFont = False
      TabOrder = 3
      Width = 115
    end
    object cxTextEdit2: TcxTextEdit [5]
      Left = 437
      Top = 96
      Hint = 'T.M_Memo'
      ParentFont = False
      TabOrder = 5
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = EditZK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #21512#21516#32534#21495':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #22791#27880#20449#24687':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 686
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 686
    inherited TitleBar: TcxLabel
      Caption = #32440#21345#23457#26680#35760#24405
      Style.IsFontAssigned = True
      Width = 686
      AnchorX = 343
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 232
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 232
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 4
    Top = 260
    object N1: TMenuItem
      Caption = #23457#26680#32440#21345
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #26597#35810#36873#39033
      object N4: TMenuItem
        Tag = 10
        Caption = #26410#23457#26680#32440#21345
        OnClick = N5Click
      end
      object N5: TMenuItem
        Tag = 20
        Caption = #24050#23457#26680#32440#21345
        OnClick = N5Click
      end
    end
  end
end
