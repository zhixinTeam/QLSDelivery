inherited fFrameCusAccount: TfFrameCusAccount
  Width = 788
  Height = 407
  inherited ToolBar1: TToolBar
    Width = 788
    inherited BtnAdd: TToolButton
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
    Top = 202
    Width = 788
    Height = 205
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 788
    Height = 135
    object cxTextEdit3: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.A_CID'
      ParentFont = False
      TabOrder = 2
      Width = 115
    end
    object cxTextEdit4: TcxTextEdit [1]
      Left = 259
      Top = 93
      Hint = 'T.C_Name'
      ParentFont = False
      TabOrder = 3
      Width = 150
    end
    object EditCustomer: TcxButtonEdit [2]
      Left = 259
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
      Width = 150
    end
    object cxTextEdit5: TcxTextEdit [3]
      Left = 710
      Top = 93
      Hint = 'T.C_Bank'
      ParentFont = False
      TabOrder = 5
      Width = 100
    end
    object cxTextEdit1: TcxTextEdit [4]
      Left = 472
      Top = 93
      Hint = 'T.C_Account'
      ParentFont = False
      TabOrder = 4
      Width = 175
    end
    object EditID: TcxButtonEdit [5]
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
      Width = 115
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #38134#34892#36134#25143':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #24320#25143#38134#34892':'
          Control = cxTextEdit5
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 788
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 788
    inherited TitleBar: TcxLabel
      Caption = #23458#25143#36164#37329#36134#25143#26597#35810
      Style.IsFontAssigned = True
      Width = 788
      AnchorX = 394
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 8
    Top = 248
  end
  inherited DataSource1: TDataSource
    Left = 36
    Top = 248
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 8
    Top = 276
    object N1: TMenuItem
      Tag = 10
      Caption = #38750#27491#24335#23458#25143
      OnClick = N3Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = #26597#35810#36134#25143#20313#39069
      OnClick = N4Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Caption = #26657#27491#23458#25143#36164#37329
      OnClick = N6Click
    end
  end
end
