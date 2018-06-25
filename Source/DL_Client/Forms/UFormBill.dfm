inherited fFormBill: TfFormBill
  Left = 369
  Top = 135
  ClientHeight = 485
  ClientWidth = 462
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 462
    Height = 485
    inherited BtnOK: TButton
      Left = 316
      Top = 452
      Caption = #24320#21333
      TabOrder = 18
    end
    inherited BtnExit: TButton
      Left = 386
      Top = 452
      TabOrder = 19
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 351
      Height = 116
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 273
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object ListBill: TcxListView [3]
      Left = 23
      Top = 389
      Width = 372
      Height = 113
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 200
        end
        item
          Caption = #25552#36135#36710#36742
          Width = 70
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 90
        end>
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 15
      ViewStyle = vsReport
    end
    object EditValue: TcxTextEdit [4]
      Left = 81
      Top = 289
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Width = 95
    end
    object EditTruck: TcxTextEdit [5]
      Left = 264
      Top = 157
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object BtnAdd: TButton [6]
      Left = 400
      Top = 264
      Width = 39
      Height = 17
      Caption = #28155#21152
      TabOrder = 7
      OnClick = BtnAddClick
    end
    object BtnDel: TButton [7]
      Left = 400
      Top = 289
      Width = 39
      Height = 18
      Caption = #21024#38500
      TabOrder = 9
      OnClick = BtnDelClick
    end
    object EditLading: TcxComboBox [8]
      Left = 81
      Top = 157
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        '0=0'#12289#33258#25552
        '1=1'#12289#19968#31080#21046
        '2=2'#12289#20004#31080#21046)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object chkIfHYprint: TcxCheckBox [9]
      Left = 11
      Top = 452
      Caption = #26159#21542#25171#21360#21270#39564#21333
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 16
      Width = 121
    end
    object EditStock: TcxComboBox [10]
      Left = 81
      Top = 264
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 6
      Width = 314
    end
    object EditJXSTHD: TcxTextEdit [11]
      Left = 277
      Top = 182
      ParentFont = False
      TabOrder = 4
      Width = 162
    end
    object cbxSampleID: TcxComboBox [12]
      Left = 277
      Top = 314
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.OnChange = cbxSampleIDPropertiesChange
      TabOrder = 11
      Width = 117
    end
    object cbxCenterID: TcxComboBox [13]
      Left = 81
      Top = 314
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.OnEditValueChanged = cbxCenterIDPropertiesEditValueChanged
      TabOrder = 10
      Width = 121
    end
    object cxLabel1: TcxLabel [14]
      Left = 399
      Top = 314
      AutoSize = False
      ParentFont = False
      Height = 16
      Width = 39
    end
    object cbxKw: TcxComboBox [15]
      Left = 81
      Top = 339
      ParentFont = False
      TabOrder = 13
      Width = 300
    end
    object chkFenChe: TcxCheckBox [16]
      Left = 137
      Top = 452
      Caption = #20998#36710#25552#36135
      ParentFont = False
      TabOrder = 17
      Width = 121
    end
    object EditType: TcxComboBox [17]
      Left = 81
      Top = 182
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'V=V'#12289'VIP'
        'Z=Z'#12289#26632#21488
        'S=S'#12289#33337#36816)
      TabOrder = 3
      Width = 121
    end
    object EditHYCus: TComboBox [18]
      Left = 81
      Top = 207
      Width = 358
      Height = 20
      Ctl3D = True
      ItemHeight = 12
      ParentCtl3D = False
      TabOrder = 5
    end
    object EditMill: TcxComboBox [19]
      Left = 81
      Top = 364
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      TabOrder = 14
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #25552#36135#26041#24335':'
            Control = EditLading
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item18: TdxLayoutItem
            Caption = #25552#36135#31867#22411':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            Caption = #25552#21333#21495'('#32463'):'
            Control = EditJXSTHD
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item20: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditHYCus
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#26126#32454
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              Caption = #27700#27877#31867#22411':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item10: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21150#29702#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item14: TdxLayoutItem
            Caption = #29983' '#20135' '#32447':'
            Control = cbxCenterID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            Caption = #35797#26679#32534#21495':'
            Control = cbxSampleID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item15: TdxLayoutItem
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = #24211'    '#20301':'
          Control = cbxKw
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item19: TdxLayoutItem
          Caption = #29983' '#20135' '#32447':'
          Control = EditMill
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListBill
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item13: TdxLayoutItem [0]
          Control = chkIfHYprint
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem [1]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = chkFenChe
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
