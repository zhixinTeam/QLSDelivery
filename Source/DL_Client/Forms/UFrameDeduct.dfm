inherited fFrameDeduct: TfFrameDeduct
  Width = 736
  Height = 388
  inherited ToolBar1: TToolBar
    Width = 736
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 736
    Height = 186
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 736
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.D_Name'
      ParentFont = False
      TabOrder = 1
      Width = 110
    end
    object EditName: TcxButtonEdit [1]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 110
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 254
      Top = 93
      Hint = 'T.D_CusName'
      ParentFont = False
      TabOrder = 2
      Width = 110
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 415
      Top = 93
      Hint = 'T.D_Value'
      ParentFont = False
      TabOrder = 3
      Width = 110
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 588
      Top = 93
      Hint = 'T.D_Type'
      ParentFont = False
      TabOrder = 4
      Width = 110
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25187#20943#37327':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25187#20943#26041#24335':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 736
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 736
    inherited TitleBar: TcxLabel
      Caption = #35745#37327#25187#21544#35268#21017
      Style.IsFontAssigned = True
      Width = 736
      AnchorX = 368
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 238
  end
  inherited DataSource1: TDataSource
    Top = 238
  end
  object PMenu1: TPopupMenu
    Left = 64
    Top = 240
    object N1: TMenuItem
      Caption = #35774#32622#26102#38388#27573
      OnClick = N1Click
    end
  end
end
