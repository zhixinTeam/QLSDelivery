inherited fFormPurchaseOrder: TfFormPurchaseOrder
  Left = 451
  Top = 243
  ClientHeight = 277
  ClientWidth = 478
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 478
    Height = 277
    inherited BtnOK: TButton
      Left = 332
      Top = 244
      Caption = #24320#21333
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 402
      Top = 244
      TabOrder = 9
    end
    object EditValue: TcxTextEdit [2]
      Left = 279
      Top = 152
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Text = '0.00'
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditMate: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditID: TcxTextEdit [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditProvider: TcxTextEdit [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [6]
      Left = 81
      Top = 152
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditCardType: TcxComboBox [7]
      Left = 81
      Top = 177
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.Items.Strings = (
        'L=L'#12289#20020#26102#21345
        'G=G'#12289#38271#26399#21345)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 4
      Width = 121
    end
    object cxLabel1: TcxLabel [8]
      Left = 221
      Top = 177
      Caption = #27880':'#20020#26102#21345#20986#21378#26102#22238#25910';'#22266#23450#21345#20986#21378#26102#19981#22238#25910
      ParentFont = False
    end
    object chkNeiDao: TcxCheckBox [9]
      Left = 23
      Top = 202
      Caption = #20869#37096#20498#36816
      ParentFont = False
      TabOrder = 5
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #30003#35831#21333#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #20379' '#24212' '#21830':'
          Control = EditProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #21407' '#26448' '#26009':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        LayoutDirection = ldHorizontal
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxlytmLayout1Item12: TdxLayoutItem
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            Caption = #21345#29255#31867#22411':'
            Control = EditCardType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = chkNeiDao
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            Caption = #21150#29702#21544#25968':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
