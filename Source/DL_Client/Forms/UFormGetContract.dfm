inherited fFormGetContract: TfFormGetContract
  Left = 401
  Top = 134
  Width = 445
  Height = 300
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 15
  inherited dxLayout1: TdxLayoutControl
    Width = 437
    Height = 268
    inherited BtnOK: TButton
      Left = 255
      Top = 226
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 342
      Top = 226
      TabOrder = 6
    end
    object EditSMan: TcxComboBox [2]
      Left = 87
      Top = 70
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditSManPropertiesEditValueChanged
      TabOrder = 1
      Width = 152
    end
    object EditCustom: TcxComboBox [3]
      Left = 87
      Top = 95
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditCustomPropertiesEditValueChanged
      TabOrder = 2
      Width = 152
    end
    object EditCID: TcxButtonEdit [4]
      Left = 87
      Top = 45
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 152
    end
    object ListContract: TcxListView [5]
      Left = 29
      Top = 141
      Width = 521
      Height = 181
      Columns = <
        item
          Caption = #21512#21516#32534#21495
          Width = 63
        end
        item
          Caption = #19994#21153#21592
          Width = 63
        end
        item
          Caption = #23458#25143#21517#31216
          Width = 63
        end
        item
          Caption = #39033#30446#21517#31216
          Width = 63
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 4
      ViewStyle = vsReport
      OnDblClick = ListContractDblClick
      OnKeyPress = ListContractKeyPress
    end
    object cxLabel1: TcxLabel [6]
      Left = 29
      Top = 120
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21512#21516#32534#21495':'
          Control = EditCID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #19994#21153#20154#21592':'
            Control = EditSMan
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            Caption = #23458#25143#21517#31216':'
            Control = EditCustom
            ControlOptions.ShowBorder = False
          end
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
          Control = ListContract
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
