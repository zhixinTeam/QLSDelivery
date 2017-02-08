inherited fFormZhiKa: TfFormZhiKa
  Left = 629
  Top = 200
  ClientHeight = 450
  ClientWidth = 430
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 430
    Height = 450
    inherited BtnOK: TButton
      Left = 284
      Top = 417
      TabOrder = 15
    end
    inherited BtnExit: TButton
      Left = 354
      Top = 417
      TabOrder = 16
    end
    object ListDetail: TcxListView [2]
      Left = 23
      Top = 224
      Width = 400
      Height = 149
      Checkboxes = True
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 120
        end
        item
          Caption = #21333#20215'('#20803'/'#21544')'
          Width = 100
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 100
        end>
      HideSelection = False
      ParentFont = False
      PopupMenu = PMenu1
      ReadOnly = True
      RowSelect = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 10
      ViewStyle = vsReport
      OnClick = ListDetailClick
    end
    object EditStock: TcxTextEdit [3]
      Left = 81
      Top = 385
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 11
      Width = 123
    end
    object EditPrice: TcxTextEdit [4]
      Left = 200
      Top = 385
      ParentFont = False
      Properties.OnEditValueChanged = EditPricePropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 12
      Width = 79
    end
    object EditValue: TcxTextEdit [5]
      Left = 330
      Top = 385
      ParentFont = False
      Properties.OnEditValueChanged = EditPricePropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 13
      Width = 77
    end
    object EditCID: TcxButtonEdit [6]
      Left = 269
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
      TabOrder = 1
      OnExit = EditCIDExit
      OnKeyPress = EditCIDKeyPress
      Width = 121
    end
    object EditPName: TcxTextEdit [7]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 121
    end
    object EditSMan: TcxComboBox [8]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditSManPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      Width = 121
    end
    object EditCustom: TcxComboBox [9]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 4
      OnKeyPress = EditCustomKeyPress
      Width = 121
    end
    object EditLading: TcxComboBox [10]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      Properties.MaxLength = 20
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 5
      Width = 125
    end
    object EditPayment: TcxComboBox [11]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 20
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 7
      Width = 125
    end
    object EditMoney: TcxTextEdit [12]
      Left = 269
      Top = 161
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Text = '0'
      Width = 121
    end
    object cxLabel2: TcxLabel [13]
      Left = 387
      Top = 161
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 20
      AnchorY = 171
    end
    object Check1: TcxCheckBox [14]
      Left = 11
      Top = 417
      Caption = #23436#25104#21518#25171#24320#38480#25552#31383#21475
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 14
      Transparent = True
      Width = 142
    end
    object EditDays: TcxDateEdit [15]
      Left = 269
      Top = 136
      ParentFont = False
      Properties.SaveTime = False
      Properties.ShowTime = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 6
      Width = 121
    end
    object EditName: TcxTextEdit [16]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 125
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item13: TdxLayoutItem
            Caption = #32440#21345#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21512#21516#32534#21495':'
            Control = EditCID
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #39033#30446#21517#31216':'
          Control = EditPName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #19994#21153#20154#21592':'
          Control = EditSMan
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustom
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item11: TdxLayoutItem
            Caption = #25552#36135#26041#24335':'
            Control = EditLading
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item18: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#26102#38271':'
            Control = EditDays
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #20184#27454#26041#24335':'
            Control = EditPayment
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item15: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #39044#20184#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item16: TdxLayoutItem
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #21150#29702#26126#32454':'
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #31867#22411':'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = #21333#20215':'
            Control = EditPrice
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = #21150#29702#37327':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item17: TdxLayoutItem [0]
          Control = Check1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 36
    Top = 268
    object N1: TMenuItem
      Tag = 10
      Caption = #20840#37096#36873#20013
      OnClick = N3Click
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #20840#37096#21462#28040
      OnClick = N3Click
    end
    object N3: TMenuItem
      Tag = 30
      Caption = #21453#30456#36873#25321
      OnClick = N3Click
    end
  end
end
