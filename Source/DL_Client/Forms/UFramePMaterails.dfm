inherited fFrameMaterails: TfFrameMaterails
  Width = 686
  inherited ToolBar1: TToolBar
    Width = 686
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
    Width = 686
    Height = 165
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 686
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 69
      Top = 93
      Hint = 'T.M_Name'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 125
    end
    object EditName: TcxButtonEdit [1]
      Left = 69
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 257
      Top = 93
      Hint = 'T.M_Memo'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 274
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #21407#26448#26009':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #21407#26448#26009':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
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
      Caption = #21407#26448#26009#31649#29702
      Style.IsFontAssigned = True
      Width = 686
      AnchorX = 343
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 234
  end
  inherited DataSource1: TDataSource
    Top = 234
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 56
    Top = 232
    object N1: TMenuItem
      Caption = #21516#27493#21407#26448#26009
      Visible = False
      OnClick = N1Click
    end
  end
end
