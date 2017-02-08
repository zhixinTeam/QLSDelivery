inherited fFormPayCustom: TfFormPayCustom
  Left = 244
  Top = 161
  ClientHeight = 395
  ClientWidth = 401
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 401
    Height = 395
    AutoContentSizes = [acsWidth]
    inherited BtnOK: TButton
      Left = 255
      Top = 360
      TabOrder = 9
    end
    inherited BtnExit: TButton
      Left = 325
      Top = 360
      TabOrder = 10
    end
    object EditType: TcxComboBox [2]
      Left = 81
      Top = 258
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 20
      TabOrder = 5
      Width = 112
    end
    object EditMoney: TcxTextEdit [3]
      Left = 256
      Top = 258
      ParentFont = False
      TabOrder = 6
      Text = '0'
      Width = 125
    end
    object EditDesc: TcxMemo [4]
      Left = 81
      Top = 283
      Lines.Strings = (
        #38144#21806#36864#36141','#36820#36824#27700#27877#27454'.')
      ParentFont = False
      Properties.MaxLength = 200
      Properties.ScrollBars = ssVertical
      TabOrder = 8
      Height = 65
      Width = 297
    end
    object cxLabel2: TcxLabel [5]
      Left = 353
      Top = 258
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 268
    end
    object ListInfo: TcxMCListBox [6]
      Left = 23
      Top = 36
      Width = 427
      Height = 110
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 85
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 338
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditID: TcxButtonEdit [7]
      Left = 259
      Top = 151
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 119
    end
    object EditSalesMan: TcxComboBox [8]
      Left = 81
      Top = 176
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 18
      Properties.OnChange = EditSalesManPropertiesChange
      TabOrder = 3
      Width = 121
    end
    object EditName: TcxComboBox [9]
      Left = 81
      Top = 201
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditNamePropertiesEditValueChanged
      TabOrder = 4
      OnKeyPress = EditNameKeyPress
      Width = 185
    end
    object EditCard: TcxButtonEdit [10]
      Left = 81
      Top = 151
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCardPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #23458#25143#20449#24687
        object dxLayout1Item7: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item11: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #30913#21345#32534#21495':'
            Control = EditCard
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #23458#25143#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item9: TdxLayoutItem
            Caption = #19994#21153#20154#21592':'
            Control = EditSalesMan
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #23458#25143#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #36164#37329#36820#36824
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #25903#20184#26041#24335':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36820#36824#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            ShowCaption = False
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditDesc
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
