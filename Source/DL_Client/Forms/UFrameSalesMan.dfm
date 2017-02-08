inherited fFrameSalesMan: TfFrameSalesMan
  Width = 773
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 773
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
    Width = 773
    Height = 234
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 773
    Height = 135
    object EditID: TcxButtonEdit [0]
      Left = 93
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
    object EditName: TcxButtonEdit [1]
      Left = 303
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
      Width = 135
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 93
      Top = 93
      Hint = 'T.S_ID'
      ParentFont = False
      TabOrder = 2
      Width = 135
    end
    object cxTextEdit2: TcxTextEdit [3]
      Left = 303
      Top = 93
      Hint = 'T.S_Name'
      ParentFont = False
      TabOrder = 3
      Width = 135
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 501
      Top = 93
      Hint = 'T.S_Phone'
      ParentFont = False
      TabOrder = 4
      Width = 135
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 699
      Top = 93
      Hint = 'T.S_Memo'
      ParentFont = False
      TabOrder = 5
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #19994#21153#21592#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #19994#21153#21592#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #19994#21153#21592#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #19994#21153#21592#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #32852#31995#30005#35805':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #22791#27880#20449#24687':'
          Control = cxTextEdit3
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
      Caption = #19994#21153#20154#21592#31649#29702
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
      Caption = #26080#25928#20154#21592
      OnClick = N2Click
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Caption = #21516#27493#19994#21153#21592
      OnClick = N4Click
    end
  end
end
