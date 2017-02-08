inherited fFormSaleAdjust: TfFormSaleAdjust
  Left = 351
  Top = 280
  ClientHeight = 550
  ClientWidth = 529
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 15
  inherited dxLayout1: TdxLayoutControl
    Width = 529
    Height = 550
    inherited BtnOK: TButton
      Left = 347
      Top = 508
      Caption = #30830#23450
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 434
      Top = 508
      TabOrder = 7
    end
    object ListInfo: TcxMCListBox [2]
      Left = 29
      Top = 45
      Width = 422
      Height = 145
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 85
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 333
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditID: TcxButtonEdit [3]
      Left = 87
      Top = 195
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 155
    end
    object EditSalesMan: TcxComboBox [4]
      Left = 305
      Top = 195
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 18
      Properties.OnChange = EditSalesManPropertiesChange
      TabOrder = 2
      Width = 151
    end
    object EditName: TcxComboBox [5]
      Left = 87
      Top = 223
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditNamePropertiesEditValueChanged
      TabOrder = 3
      OnKeyPress = EditNameKeyPress
      Width = 232
    end
    object ListDetail: TcxListView [6]
      Left = 29
      Top = 319
      Width = 444
      Height = 193
      Checkboxes = True
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 150
        end
        item
          Caption = #21333#20215'('#20803'/'#21544')'
          Width = 125
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 125
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 5
      ViewStyle = vsReport
    end
    object EditZK: TcxComboBox [7]
      Left = 87
      Top = 291
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditZKPropertiesEditValueChanged
      TabOrder = 4
      OnKeyPress = EditNameKeyPress
      Width = 460
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = '1.'#36873#25321#23458#25143
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #23458#25143#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #19994#21153#20154#21592':'
            Control = EditSalesMan
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = []
          AlignHorz = ahClient
          AlignVert = avBottom
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = '2.'#36873#25321#32440#21345
        object dxLayout1Item4: TdxLayoutItem
          Caption = #32440#21345#21015#34920':'
          Control = EditZK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
