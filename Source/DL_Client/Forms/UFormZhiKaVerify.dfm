inherited fFormZhiKaVerify: TfFormZhiKaVerify
  Left = 457
  Top = 240
  ClientHeight = 450
  ClientWidth = 440
  OnClick = FormClick
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 15
  inherited dxLayout1: TdxLayoutControl
    Width = 440
    Height = 450
    AutoControlAlignment = False
    inherited BtnOK: TButton
      Left = 258
      Top = 408
      Caption = #30830#23450
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 345
      Top = 408
      TabOrder = 8
    end
    object ListInfo: TcxMCListBox [2]
      Left = 29
      Top = 45
      Width = 412
      Height = 144
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 334
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditMoney: TcxTextEdit [3]
      Left = 263
      Top = 302
      ParentFont = False
      TabOrder = 4
      Text = '0'
      Width = 151
    end
    object EditDesc: TcxMemo [4]
      Left = 87
      Top = 332
      ParentFont = False
      Properties.MaxLength = 200
      Properties.ScrollBars = ssVertical
      TabOrder = 6
      Height = 62
      Width = 355
    end
    object EditZID: TcxTextEdit [5]
      Left = 87
      Top = 212
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 152
    end
    object EditType: TcxComboBox [6]
      Left = 87
      Top = 302
      ParentFont = False
      Properties.MaxLength = 20
      TabOrder = 3
      Width = 113
    end
    object cxLabel1: TcxLabel [7]
      Left = 380
      Top = 302
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 25
      Width = 31
      AnchorY = 315
    end
    object EditInfo: TcxTextEdit [8]
      Left = 87
      Top = 277
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 152
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #32440#21345#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = EditZID
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #23457#26680#22238#27454
        object dxLayout1Item9: TdxLayoutItem
          Caption = #24453#32564#37329#39069':'
          Control = EditInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            Caption = #20184#27454#26041#24335':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32564#32435#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditDesc
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
