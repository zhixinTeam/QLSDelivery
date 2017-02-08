inherited fFrameInvoiceWeek: TfFrameInvoiceWeek
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
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 773
    Height = 135
    object EditName: TcxButtonEdit [0]
      Left = 208
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
    object EditDesc: TcxTextEdit [1]
      Left = 413
      Top = 93
      ParentFont = False
      TabOrder = 5
      Width = 185
    end
    object EditSName: TcxTextEdit [2]
      Left = 208
      Top = 93
      ParentFont = False
      TabOrder = 4
      Width = 142
    end
    object EditDate: TcxButtonEdit [3]
      Left = 413
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 185
    end
    object EditID: TcxButtonEdit [4]
      Left = 57
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
      Width = 112
    end
    object EditSID: TcxTextEdit [5]
      Left = 57
      Top = 93
      ParentFont = False
      TabOrder = 3
      Width = 112
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #32534#21495':'
          Control = EditSID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #21517#31216':'
          Control = EditSName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32467#31639#26102#38388':'
          Control = EditDesc
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
      Caption = #21457#31080#32467#31639#21608#26399
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
