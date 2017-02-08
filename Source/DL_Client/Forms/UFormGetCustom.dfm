inherited fFormGetCustom: TfFormGetCustom
  Left = 322
  Top = 210
  Width = 606
  Height = 399
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 598
    Height = 368
    inherited BtnOK: TButton
      Left = 452
      Top = 335
      Caption = #30830#23450
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 522
      Top = 335
      TabOrder = 5
    end
    object EditCustom: TcxComboBox [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditCustomPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Width = 121
    end
    object EditCus: TcxButtonEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListCustom: TcxListView [4]
      Left = 23
      Top = 107
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #23458#25143#32534#21495
          Width = 80
        end
        item
          Caption = #23458#25143#21517#31216
          Width = 200
        end
        item
          Caption = #35746#21333#32534#21495
          Width = 80
        end
        item
          Caption = #38144#21806#21306#22495
          Width = 80
        end
        item
          Caption = #27700#27877#21697#31181
          Width = 100
        end
        item
          Caption = #31867#22411
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 3
      ViewStyle = vsReport
      OnDblClick = ListCustomDblClick
      OnKeyPress = ListCustomKeyPress
    end
    object cxLabel1: TcxLabel [5]
      Left = 23
      Top = 86
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
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143'('#36873'):'
          Control = EditCustom
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListCustom
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
