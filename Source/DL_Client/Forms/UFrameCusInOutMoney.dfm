inherited fFrameCusInOutMoney: TfFrameCusInOutMoney
  Width = 699
  inherited ToolBar1: TToolBar
    Width = 699
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
    Width = 699
    Height = 165
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 699
    Height = 135
    object cxTextEdit3: TcxTextEdit [0]
      Left = 81
      Top = 96
      Hint = 'T.M_CusID'
      ParentFont = False
      TabOrder = 2
      Width = 120
    end
    object EditDate: TcxButtonEdit [1]
      Left = 264
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
      Width = 185
    end
    object cxTextEdit4: TcxTextEdit [2]
      Left = 264
      Top = 96
      Hint = 'T.M_CusName'
      ParentFont = False
      TabOrder = 3
      Width = 185
    end
    object EditCustomer: TcxButtonEdit [3]
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
      Width = 120
    end
    object cxTextEdit5: TcxTextEdit [4]
      Left = 512
      Top = 96
      Hint = 'T.M_Memo'
      ParentFont = False
      TabOrder = 4
      Width = 100
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustomer
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
          Caption = #23458#25143#32534#21495':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25551#36848#20449#24687':'
          Control = cxTextEdit5
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 699
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 699
    inherited TitleBar: TcxLabel
      Caption = #23458#25143#36164#37329#26126#32454#26597#35810
      Style.IsFontAssigned = True
      Width = 699
      AnchorX = 350
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 234
  end
  inherited DataSource1: TDataSource
    Top = 234
  end
end
