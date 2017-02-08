inherited fFormZhiKaFixMoney: TfFormZhiKaFixMoney
  Left = 578
  Top = 226
  ClientHeight = 480
  ClientWidth = 475
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 15
  inherited dxLayout1: TdxLayoutControl
    Width = 475
    Height = 480
    AutoControlAlignment = False
    inherited BtnOK: TButton
      Left = 293
      Top = 438
      Caption = #30830#23450
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 380
      Top = 438
      TabOrder = 9
    end
    object ListInfo: TcxMCListBox [2]
      Left = 29
      Top = 45
      Width = 467
      Height = 138
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 389
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditZK: TcxTextEdit [3]
      Left = 87
      Top = 220
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 132
    end
    object EditOut: TcxTextEdit [4]
      Left = 282
      Top = 285
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Text = '0'
      Width = 152
    end
    object EditIn: TcxTextEdit [5]
      Left = 87
      Top = 285
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 2
      Text = '0'
      Width = 132
    end
    object EditFreeze: TcxTextEdit [6]
      Left = 87
      Top = 310
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Text = '0'
      Width = 132
    end
    object EditValid: TcxTextEdit [7]
      Left = 282
      Top = 310
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Text = '0'
      Width = 152
    end
    object EditMoney: TcxTextEdit [8]
      Left = 87
      Top = 375
      ParentFont = False
      TabOrder = 6
      Width = 152
    end
    object Check1: TcxCheckBox [9]
      Left = 29
      Top = 400
      Caption = #38480#21046#35813#32440#21345#30340#21487#25552#36135#37327'.'
      ParentFont = False
      TabOrder = 7
      Transparent = True
      OnClick = Check1Click
      Width = 151
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
          Control = EditZK
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #36134#25143#20449#24687
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item9: TdxLayoutItem
            Caption = #20837#37329#24635#39069':'
            Control = EditIn
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #20986#37329#24635#39069':'
            Control = EditOut
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = #20923#32467#37329#39069':'
            Control = EditFreeze
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21487#29992#37329#39069':'
            Control = EditValid
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup3: TdxLayoutGroup [2]
        Caption = #21487#25552#36135#37329#39069
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #37329#39069'('#20803'):'
          Control = EditMoney
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
