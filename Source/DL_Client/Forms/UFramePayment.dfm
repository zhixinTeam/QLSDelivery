inherited fFramePayment: TfFramePayment
  Width = 686
  Height = 370
  inherited ToolBar1: TToolBar
    Width = 686
    inherited BtnAdd: TToolButton
      Caption = #22238#27454
      ImageIndex = 18
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Caption = #32440#21345
      ImageIndex = 15
      Visible = False
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 686
    Height = 168
    inherited cxView1: TcxGridDBTableView
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 686
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 279
      Top = 93
      Hint = 'T.M_Money'
      ParentFont = False
      TabOrder = 3
      Width = 90
    end
    object EditID: TcxButtonEdit [1]
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
      Width = 135
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 432
      Top = 93
      Hint = 'T.M_Memo'
      ParentFont = False
      TabOrder = 4
      Width = 135
    end
    object EditDate: TcxButtonEdit [3]
      Left = 279
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
    object cxTextEdit4: TcxTextEdit [4]
      Left = 81
      Top = 93
      Hint = 'T.M_CusName'
      ParentFont = False
      TabOrder = 2
      Width = 135
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditID
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
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #37329#39069'('#20803'):'
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
      Caption = #36135#27454#22238#25910#35760#24405
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
end
