inherited fFormGetNCStock: TfFormGetNCStock
  Left = 401
  Top = 134
  Width = 509
  Height = 384
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 493
    Height = 346
    inherited BtnOK: TButton
      Left = 347
      Top = 313
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 417
      Top = 313
      TabOrder = 4
    end
    object EditCus: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListQuery: TcxListView [3]
      Left = 23
      Top = 82
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #32534#21495
          Width = 120
        end
        item
          Caption = #21517#31216
          Width = 200
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = ListQueryDblClick
      OnKeyPress = ListQueryKeyPress
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 61
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26597#35810#32467#26524':'
          ShowCaption = False
          Control = ListQuery
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
