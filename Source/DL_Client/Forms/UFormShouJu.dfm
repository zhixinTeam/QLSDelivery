inherited fFormShouJu: TfFormShouJu
  Left = 684
  Top = 370
  ClientHeight = 282
  ClientWidth = 512
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 512
    Height = 282
    inherited BtnOK: TButton
      Left = 366
      Top = 249
      TabOrder = 11
    end
    inherited BtnExit: TButton
      Left = 436
      Top = 249
      TabOrder = 12
    end
    object EditDate: TcxDateEdit [2]
      Left = 81
      Top = 36
      Hint = 'T.S_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 0
      Width = 165
    end
    object EditMan: TcxTextEdit [3]
      Left = 309
      Top = 36
      Hint = 'T.S_Man'
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 1
      Width = 174
    end
    object cxLabel2: TcxLabel [4]
      Left = 23
      Top = 61
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Vert = taBottomJustify
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 15
      Width = 461
      AnchorY = 76
    end
    object EditID: TcxButtonEdit [5]
      Left = 81
      Top = 81
      Hint = 'T.S_Code'
      HelpType = htKeyword
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 3
      Width = 165
    end
    object EditName: TcxTextEdit [6]
      Left = 81
      Top = 106
      Hint = 'T.S_Sender'
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 5
      Width = 403
    end
    object EditReason: TcxTextEdit [7]
      Left = 81
      Top = 131
      Hint = 'T.S_Reason'
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 6
      Width = 403
    end
    object EditMoney: TcxTextEdit [8]
      Left = 81
      Top = 156
      Hint = 'T.S_Money'
      ParentFont = False
      TabOrder = 7
      OnExit = EditMoneyExit
      Width = 100
    end
    object cxLabel1: TcxLabel [9]
      Left = 186
      Top = 156
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 166
    end
    object EditBig: TcxTextEdit [10]
      Left = 274
      Top = 156
      Hint = 'T.S_BigMoney'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 9
      Width = 208
    end
    object EditMemo: TcxMemo [11]
      Left = 81
      Top = 181
      Hint = 'T.S_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 10
      Height = 46
      Width = 403
    end
    object EditBank: TcxComboBox [12]
      Left = 309
      Top = 81
      Hint = 'T.S_Bank'
      ParentFont = False
      Properties.DropDownRows = 16
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 35
      TabOrder = 4
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #24320#25454#26102#38388':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #20986#32435#21592':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item5: TdxLayoutItem
          ShowCaption = False
          Control = cxLabel2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            Caption = #20973#21333#21495#30721':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item13: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36716#36134#38134#34892':'
            Control = EditBank
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20857'    '#30001':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            Caption = #20132'    '#26469':'
            Control = EditReason
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group5: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item9: TdxLayoutItem
                Caption = #20154' '#27665' '#24065':'
                Control = EditMoney
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item10: TdxLayoutItem
                ShowCaption = False
                Control = cxLabel1
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item11: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #22823#20889#37329#39069':'
                Control = EditBig
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item12: TdxLayoutItem
              Caption = #22791#27880#20449#24687':'
              Control = EditMemo
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
    end
  end
end
