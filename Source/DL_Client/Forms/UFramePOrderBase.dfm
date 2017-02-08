inherited fFramePOrderBase: TfFramePOrderBase
  Width = 957
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 957
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 957
    Height = 234
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 957
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
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditName: TcxButtonEdit [1]
      Left = 433
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 81
      Top = 93
      Hint = 'T.O_ID'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [3]
      Left = 257
      Top = 93
      Hint = 'T.O_ProName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Width = 125
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 433
      Top = 93
      Hint = 'T.O_SaleMan'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 125
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 621
      Top = 93
      Hint = 'T.O_Project'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 121
    end
    object EditCustomer: TcxButtonEdit [6]
      Left = 257
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditDate: TcxButtonEdit [7]
      Left = 621
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 3
      Width = 185
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #30003#35831#21333#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20379#24212#21830':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #19994#21153#21592':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #30003#35831#21333#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #20379#24212#21830':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #19994#21153#21592':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #26085#26399#31579#36873':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 957
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 957
    inherited TitleBar: TcxLabel
      Caption = #37319#36141#30003#35831#21333#31649#29702
      Style.IsFontAssigned = True
      Width = 957
      AnchorX = 479
      AnchorY = 11
    end
  end
  object Check1: TcxCheckBox [5]
    Left = 809
    Top = 92
    Caption = #26597#35810#24050#21024#38500
    ParentFont = False
    TabOrder = 5
    Transparent = True
    OnClick = Check1Click
    Width = 110
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
    Left = 4
    Top = 264
    object N1: TMenuItem
      Caption = #21150#29702#30913#21345
      Visible = False
    end
    object N2: TMenuItem
      Caption = #27880#38144#30913#21345
      Visible = False
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #20462#25913#36710#29260#21495
      Visible = False
    end
  end
end
