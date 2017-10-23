inherited fFrameForceCenterID: TfFrameForceCenterID
  Width = 785
  Height = 380
  inherited ToolBar1: TToolBar
    Width = 785
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
    Width = 785
    Height = 178
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 785
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'F.F_ID'
      ParentFont = False
      TabOrder = 1
      Width = 125
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
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 269
      Top = 93
      Hint = 'F.F_Name'
      ParentFont = False
      TabOrder = 2
      Width = 125
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 457
      Top = 93
      Hint = 'F.F_Stock'
      ParentFont = False
      TabOrder = 3
      Width = 125
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 627
      Top = 93
      Hint = 'F.F_CenterID'
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #27700#27877#21517#31216':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #29983#20135#32447
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 785
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 785
    inherited TitleBar: TcxLabel
      Caption = #29983#20135#32447#20851#32852
      Style.IsFontAssigned = True
      Width = 785
      AnchorX = 393
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
