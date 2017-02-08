inherited fFrameInvoice: TfFrameInvoice
  Width = 773
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 773
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Caption = #20316#24223
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 773
    Height = 234
    inherited cxView1: TcxGridDBTableView
      OnDblClick = cxView1DblClick
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
    object cxTextEdit1: TcxTextEdit [1]
      Left = 81
      Top = 93
      Hint = 'T.I_ID'
      ParentFont = False
      TabOrder = 3
      Width = 105
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 249
      Top = 93
      Hint = 'T.I_Status'
      ParentFont = False
      TabOrder = 4
      Width = 100
    end
    object cxTextEdit4: TcxTextEdit [3]
      Left = 400
      Top = 93
      Hint = 'T.I_SaleMan'
      ParentFont = False
      TabOrder = 5
      Width = 100
    end
    object cxTextEdit3: TcxTextEdit [4]
      Left = 563
      Top = 93
      Hint = 'T.I_CusName'
      ParentFont = False
      TabOrder = 6
      Width = 121
    end
    object EditDate: TcxButtonEdit [5]
      Left = 454
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
      TabOrder = 2
      Width = 186
    end
    object EditCus: TcxButtonEdit [6]
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
      Width = 142
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #21457#31080#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21457#31080#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #21457#31080#29366#24577':'
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
          Caption = #23458#25143#21517#31216':'
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
      Caption = #38144#21806#21457#31080#31649#29702
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
end
