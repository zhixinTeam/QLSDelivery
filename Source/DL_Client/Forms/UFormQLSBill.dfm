inherited fFormQLSBill: TfFormQLSBill
  Left = 372
  Top = 166
  ClientHeight = 422
  ClientWidth = 462
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 462
    Height = 422
    inherited BtnOK: TButton
      Left = 316
      Top = 389
      Caption = #24320#21333
      TabOrder = 13
    end
    inherited BtnExit: TButton
      Left = 386
      Top = 389
      TabOrder = 14
    end
    object EditValue: TcxTextEdit [2]
      Left = 81
      Top = 225
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 95
    end
    object EditTruck: TcxTextEdit [3]
      Left = 264
      Top = 125
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditLading: TcxComboBox [4]
      Left = 81
      Top = 125
      Enabled = False
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        '0=0'#12289#33258#25552
        '1=1'#12289#19968#31080#21046
        '2=2'#12289#20004#31080#21046)
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object chkIfHYprint: TcxCheckBox [5]
      Left = 11
      Top = 389
      Caption = #26159#21542#25171#21360#21270#39564#21333
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 11
      Width = 121
    end
    object EditStock: TcxComboBox [6]
      Left = 81
      Top = 200
      Enabled = False
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 314
    end
    object EditJXSTHD: TcxTextEdit [7]
      Left = 277
      Top = 150
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 4
      Width = 162
    end
    object cbxSampleID: TcxComboBox [8]
      Left = 277
      Top = 250
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.OnChange = cbxSampleIDPropertiesChange
      TabOrder = 9
      Width = 117
    end
    object cbxCenterID: TcxComboBox [9]
      Left = 81
      Top = 250
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.OnEditValueChanged = cbxCenterIDPropertiesEditValueChanged
      TabOrder = 8
      Width = 121
    end
    object cxLabel1: TcxLabel [10]
      Left = 399
      Top = 250
      AutoSize = False
      ParentFont = False
      Height = 16
      Width = 39
    end
    object chkFenChe: TcxCheckBox [11]
      Left = 137
      Top = 389
      Caption = #20998#36710#25552#36135
      ParentFont = False
      TabOrder = 12
      Width = 121
    end
    object EditType: TcxComboBox [12]
      Left = 81
      Top = 150
      Enabled = False
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'V=V'#12289'VIP'
        'Z=Z'#12289#26632#21488
        'S=S'#12289#33337#36816)
      Properties.ReadOnly = False
      TabOrder = 3
      Width = 121
    end
    object EditHYCus: TComboBox [13]
      Left = 81
      Top = 175
      Width = 358
      Height = 20
      Ctl3D = True
      Enabled = False
      ItemHeight = 12
      ParentCtl3D = False
      TabOrder = 5
    end
    object EditID: TcxButtonEdit [14]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Caption = #26597#35810
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = EditIDKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #25552#36135#21333#21495
        object dxLayout1Item4: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditID
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
            ShowBorder = False
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
            object dxLayout1Item7: TdxLayoutItem
              Caption = #27700#27877#31867#22411':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21150#29702#21544#25968':'
            Control = EditValue
            ControlOptions.ShowBorder = False
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
