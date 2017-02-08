object fFormInvoiceK: TfFormInvoiceK
  Left = 276
  Top = 208
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 416
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 424
    Height = 416
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 268
      Top = 383
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 11
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 343
      Top = 383
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 12
      OnClick = BtnExitClick
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 111
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      TabOrder = 5
      Height = 45
      Width = 240
    end
    object EditInvoice: TcxComboBox
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      TabOrder = 0
      Width = 125
    end
    object EditMoney: TcxTextEdit
      Left = 269
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Text = '0'
      Width = 125
    end
    object EditZheKou: TcxTextEdit
      Left = 269
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Text = '0'
      Width = 125
    end
    object EditStock: TcxTextEdit
      Left = 81
      Top = 193
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 125
    end
    object EditPrice: TcxTextEdit
      Left = 269
      Top = 193
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 7
      Width = 80
    end
    object EditValue: TcxTextEdit
      Left = 269
      Top = 218
      OnFocusChanged = EditValueFocusChanged
      ParentFont = False
      TabOrder = 9
      Width = 125
    end
    object ListDetail: TcxMCListBox
      Left = 23
      Top = 243
      Width = 374
      Height = 100
      HeaderSections = <
        item
          Text = #27700#27877#21697#31181
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #25552#36135#21333#20215
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24320#31080#21333#20215
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24453#24320#21544#25968
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24050#24320#21544#25968
          Width = 75
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 10
      OnClick = ListDetailClick
    end
    object EditZK: TcxTextEdit
      Left = 81
      Top = 218
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 8
      Width = 125
    end
    object EditCus: TcxTextEdit
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Width = 125
    end
    object EditSale: TcxTextEdit
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 125
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #21457#31080#20449#24687
        object dxLayoutControl1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #21457#31080#32534#21495':'
            Control = EditInvoice
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item2: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21457#31080#24635#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item13: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #19994' '#21153' '#21592':'
            Control = EditSale
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25240#25187#24635#39069':'
            Control = EditZheKou
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item8: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #21457#31080#26126#32454
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item1: TdxLayoutItem
              Caption = #27700#27877#21697#31181':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item5: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #24320#31080#21333#20215':'
              Control = EditPrice
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #25240#25187#37329#39069':'
              Control = EditZK
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #24320#31080#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'cxMCListBox1'
          ShowCaption = False
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
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
