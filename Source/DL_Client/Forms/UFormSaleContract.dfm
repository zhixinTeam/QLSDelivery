inherited fFormSaleContract: TfFormSaleContract
  Left = 477
  Top = 235
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 518
  ClientWidth = 502
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 502
    Height = 518
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlAlignment = False
    LookAndFeel = FDM.dxLayoutWeb1
    object EditMemo: TcxMemo
      Left = 81
      Top = 211
      Hint = 'T.C_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 12
      Height = 40
      Width = 437
    end
    object BtnOK: TButton
      Left = 347
      Top = 484
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 19
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 422
      Top = 484
      Width = 69
      Height = 23
      Caption = #21462#28040
      TabOrder = 20
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'T.C_ID'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      Width = 175
    end
    object StockList1: TcxMCListBox
      Left = 23
      Top = 338
      Width = 473
      Height = 172
      HeaderSections = <
        item
          DataIndex = 1
          Text = #27700#27877#31867#22411
          Width = 74
        end
        item
          Alignment = taCenter
          DataIndex = 2
          Text = #25968#37327'('#21544')'
          Width = 70
        end
        item
          Alignment = taCenter
          DataIndex = 3
          Text = #21333#20215'('#20803'/'#21544')'
          Width = 82
        end
        item
          Alignment = taCenter
          DataIndex = 4
          Text = #37329#39069'('#20803')'
          Width = 80
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 17
      OnClick = StockList1Click
    end
    object EditSalesMan: TcxComboBox
      Left = 81
      Top = 86
      Hint = 'T.C_SaleMan'
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditSalesManPropertiesEditValueChanged
      TabOrder = 2
      OnKeyDown = EditSalesManKeyDown
      Width = 145
    end
    object cxTextEdit1: TcxTextEdit
      Left = 81
      Top = 61
      Hint = 'T.C_Project'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 1
      Width = 121
    end
    object EditCustomer: TcxComboBox
      Left = 289
      Top = 86
      Hint = 'T.C_Customer'
      ParentFont = False
      Properties.DropDownRows = 25
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 20
      TabOrder = 3
      OnKeyDown = EditSalesManKeyDown
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit
      Left = 289
      Top = 111
      Hint = 'T.C_Addr'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 5
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit
      Left = 289
      Top = 136
      Hint = 'T.C_Delivery'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 7
      Width = 121
    end
    object EditPayment: TcxComboBox
      Left = 81
      Top = 161
      Hint = 'T.C_Payment'
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 20
      Properties.MaxLength = 20
      TabOrder = 8
      Width = 145
    end
    object cxTextEdit4: TcxTextEdit
      Left = 289
      Top = 161
      Hint = 'T.C_Approval'
      ParentFont = False
      Properties.MaxLength = 30
      TabOrder = 9
      Width = 121
    end
    object EditName: TcxTextEdit
      Left = 57
      Top = 288
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 13
      Width = 120
    end
    object EditMoney: TcxTextEdit
      Left = 216
      Top = 313
      ParentFont = False
      TabOrder = 16
      OnExit = EditValueExit
      Width = 120
    end
    object EditPrice: TcxTextEdit
      Left = 57
      Top = 313
      ParentFont = False
      TabOrder = 15
      OnExit = EditValueExit
      Width = 120
    end
    object EditValue: TcxTextEdit
      Left = 216
      Top = 288
      ParentFont = False
      TabOrder = 14
      OnExit = EditValueExit
      Width = 120
    end
    object EditDate: TcxButtonEdit
      Left = 81
      Top = 111
      Hint = 'T.C_Date'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 20
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 4
      Width = 145
    end
    object cxButtonEdit1: TcxButtonEdit
      Left = 81
      Top = 136
      Hint = 'T.C_Area'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
      TabOrder = 6
      Width = 145
    end
    object Check1: TcxCheckBox
      Left = 11
      Top = 486
      Caption = #34394#25311#21512#21516': '#21150#29702#32440#21345#26102#20801#35768#21464#26356#19994#21153#21592#21644#23458#25143#21517#31216'.'
      ParentFont = False
      TabOrder = 18
      Transparent = True
      Width = 300
    end
    object EditDays: TcxTextEdit
      Left = 81
      Top = 186
      Hint = 'T.C_ZKDays'
      ParentFont = False
      TabOrder = 10
      Text = '1'
      Width = 145
    end
    object cxLabel1: TcxLabel
      Left = 231
      Top = 186
      AutoSize = False
      Caption = #22825'  '#27880':'#29992#25143#38656#35201#22312#25351#23450#26102#38271#20869#23558#27700#27877#25552#23436'.'
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 268
      AnchorY = 196
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item1: TdxLayoutItem
            Caption = #21512#21516#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #39033#30446#21517#31216':'
            Control = cxTextEdit1
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item5: TdxLayoutItem
              Caption = #19994#21153#20154#21592':'
              Control = EditSalesMan
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #23458#25143#21517#31216':'
              Control = EditCustomer
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Group7: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item19: TdxLayoutItem
            Caption = #31614#35746#26102#38388':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item7: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #31614#35746#22320#28857':'
            Control = cxTextEdit2
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group10: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item8: TdxLayoutItem
            Caption = #25152#23646#21306#22495':'
            Control = cxButtonEdit1
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #20132#36135#22320#28857':'
            Control = cxTextEdit3
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item12: TdxLayoutItem
            Caption = #20184#27454#26041#24335':'
            Control = EditPayment
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item13: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25209' '#20934' '#20154':'
            Control = cxTextEdit4
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group11: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item20: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25552#36135#26102#38271':'
            Control = EditDays
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item21: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        ShowCaption = False
        Hidden = True
        ShowBorder = False
        object dxLayoutControl1Group2: TdxLayoutGroup
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #21512#21516#26126#32454
          object dxLayoutControl1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayoutControl1Group4: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayoutControl1Item14: TdxLayoutItem
                Caption = #31867#22411':'
                Control = EditName
                ControlOptions.ShowBorder = False
              end
              object dxLayoutControl1Item17: TdxLayoutItem
                Caption = #25968#37327':'
                Control = EditValue
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayoutControl1Group13: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayoutControl1Item16: TdxLayoutItem
                Caption = #21333#20215':'
                Control = EditPrice
                ControlOptions.ShowBorder = False
              end
              object dxLayoutControl1Item15: TdxLayoutItem
                Caption = #37329#39069':'
                Control = EditMoney
                ControlOptions.ShowBorder = False
              end
            end
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            AutoAligns = [aaHorizontal]
            AlignVert = avClient
            Caption = #21015#34920':'
            ShowCaption = False
            Control = StockList1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group12: TdxLayoutGroup
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item18: TdxLayoutItem
            AutoAligns = [aaHorizontal]
            AlignVert = avBottom
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = Check1
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = 'Button3'
            ShowCaption = False
            Control = BtnOK
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item11: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = 'Button4'
            ShowCaption = False
            Control = BtnExit
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
