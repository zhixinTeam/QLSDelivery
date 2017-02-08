object fFormHYRecord: TfFormHYRecord
  Left = 330
  Top = 99
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 572
  ClientWidth = 470
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
    Width = 470
    Height = 572
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlTabOrders = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 314
      Top = 538
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 0
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 389
      Top = 538
      Width = 70
      Height = 23
      Caption = #21462#28040
      TabOrder = 1
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 93
      Top = 36
      Hint = 'E.R_SerialNo'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      Width = 121
    end
    object wPanel: TPanel
      Left = 23
      Top = 218
      Width = 424
      Height = 240
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 4
      object Label17: TLabel
        Left = 6
        Top = 282
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label18: TLabel
        Left = 6
        Top = 251
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Label25: TLabel
        Left = 205
        Top = 282
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label26: TLabel
        Left = 205
        Top = 251
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Bevel2: TBevel
        Left = 1
        Top = 230
        Width = 421
        Height = 7
        Shape = bsBottomLine
      end
      object Label19: TLabel
        Left = 2
        Top = 109
        Width = 54
        Height = 12
        Caption = #30897' '#21547' '#37327':'
        Transparent = True
      end
      object Label20: TLabel
        Left = 136
        Top = 31
        Width = 72
        Height = 12
        Caption = #19981#28342#29289'/'#23494#24230':'
        Transparent = True
      end
      object Label21: TLabel
        Left = 2
        Top = 135
        Width = 54
        Height = 12
        Caption = #26631#20934#31264#24230':'
        Transparent = True
      end
      object Label22: TLabel
        Left = 2
        Top = 83
        Width = 54
        Height = 12
        Caption = #32454'    '#24230':'
        Transparent = True
      end
      object Label23: TLabel
        Left = 2
        Top = 187
        Width = 54
        Height = 12
        Caption = #27695' '#31163' '#23376':'
        Transparent = True
      end
      object Label24: TLabel
        Left = 2
        Top = 5
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38209':'
        Transparent = True
      end
      object Label27: TLabel
        Left = 144
        Top = 57
        Width = 54
        Height = 12
        Caption = #21021#20957#26102#38388':'
        Transparent = True
      end
      object Label28: TLabel
        Left = 144
        Top = 83
        Width = 54
        Height = 12
        Caption = #32456#20957#26102#38388':'
        Transparent = True
      end
      object Label29: TLabel
        Left = 144
        Top = 5
        Width = 54
        Height = 12
        Caption = #27604#34920#38754#31215':'
        Transparent = True
      end
      object Label30: TLabel
        Left = 144
        Top = 109
        Width = 54
        Height = 12
        Caption = #23433' '#23450' '#24615':'
        Transparent = True
      end
      object Label31: TLabel
        Left = 2
        Top = 31
        Width = 54
        Height = 12
        Caption = #19977#27687#21270#30827':'
      end
      object Label32: TLabel
        Left = 2
        Top = 57
        Width = 54
        Height = 12
        Caption = #28903' '#22833' '#37327':'
      end
      object Label34: TLabel
        Left = 2
        Top = 160
        Width = 54
        Height = 12
        Caption = #28216' '#31163' '#38041':'
        Transparent = True
      end
      object Label41: TLabel
        Left = 142
        Top = 135
        Width = 54
        Height = 12
        Caption = #30707#33167#31181#31867':'
        Transparent = True
      end
      object Label42: TLabel
        Left = 142
        Top = 160
        Width = 54
        Height = 12
        Caption = #30707' '#33167' '#37327':'
      end
      object Label43: TLabel
        Left = 294
        Top = 4
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#31867':'
      end
      object Label44: TLabel
        Left = 294
        Top = 31
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#37327':'
        Transparent = True
      end
      object Label1: TLabel
        Left = 294
        Top = 57
        Width = 54
        Height = 12
        Caption = #21161#30952#21058#31867':'
        Transparent = True
      end
      object Label2: TLabel
        Left = 293
        Top = 83
        Width = 54
        Height = 12
        Caption = #21161#30952#21058#37327':'
        Transparent = True
      end
      object Label3: TLabel
        Left = 293
        Top = 109
        Width = 48
        Height = 12
        Caption = #30719#29289'C3S:'
        Transparent = True
      end
      object Label4: TLabel
        Left = 293
        Top = 135
        Width = 48
        Height = 12
        Caption = #30719#29289'C3A:'
        Transparent = True
      end
      object Label5: TLabel
        Left = 293
        Top = 160
        Width = 54
        Height = 12
        Caption = #27700#21270#28909'3D:'
        Transparent = True
      end
      object Label6: TLabel
        Left = 293
        Top = 187
        Width = 54
        Height = 12
        Caption = #27700#21270#28909'7D:'
        Transparent = True
      end
      object Label7: TLabel
        Left = 142
        Top = 187
        Width = 54
        Height = 12
        Caption = #38041' '#30789' '#27604':'
      end
      object Label8: TLabel
        Left = 0
        Top = 212
        Width = 48
        Height = 12
        Caption = #30719#29289'C2S:'
        Transparent = True
      end
      object cxTextEdit29: TcxTextEdit
        Left = 76
        Top = 246
        Hint = 'E.R_3DZhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 12
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit30: TcxTextEdit
        Left = 76
        Top = 271
        Hint = 'E.R_3DYa1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 15
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit31: TcxTextEdit
        Left = 284
        Top = 246
        Hint = 'E.R_28Zhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 21
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit32: TcxTextEdit
        Left = 284
        Top = 271
        Hint = 'E.R_28Ya1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 24
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit33: TcxTextEdit
        Left = 324
        Top = 246
        Hint = 'E.R_28Zhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 22
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit34: TcxTextEdit
        Left = 363
        Top = 246
        Hint = 'E.R_28Zhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 23
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit35: TcxTextEdit
        Left = 324
        Top = 271
        Hint = 'E.R_28Ya2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 25
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit36: TcxTextEdit
        Left = 363
        Top = 271
        Hint = 'E.R_28Ya3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 26
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit37: TcxTextEdit
        Left = 116
        Top = 246
        Hint = 'E.R_3DZhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 13
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit38: TcxTextEdit
        Left = 116
        Top = 271
        Hint = 'E.R_3DYa2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 16
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit39: TcxTextEdit
        Left = 156
        Top = 246
        Hint = 'E.R_3DZhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 14
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit40: TcxTextEdit
        Left = 156
        Top = 271
        Hint = 'E.R_3DYa3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 17
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit41: TcxTextEdit
        Left = 76
        Top = 288
        Hint = 'E.R_3DYa4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 18
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit42: TcxTextEdit
        Left = 116
        Top = 288
        Hint = 'E.R_3DYa5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 19
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit43: TcxTextEdit
        Left = 156
        Top = 288
        Hint = 'E.R_3DYa6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 20
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit47: TcxTextEdit
        Left = 284
        Top = 288
        Hint = 'E.R_28Ya4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 27
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit48: TcxTextEdit
        Left = 324
        Top = 288
        Hint = 'E.R_28Ya5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 28
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit49: TcxTextEdit
        Left = 363
        Top = 288
        Hint = 'E.R_28Ya6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 29
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit17: TcxTextEdit
        Left = 60
        Top = 0
        Hint = 'E.R_MgO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 0
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit18: TcxTextEdit
        Left = 60
        Top = 180
        Hint = 'E.R_CL'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 7
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit19: TcxTextEdit
        Left = 60
        Top = 78
        Hint = 'E.R_XiDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 3
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit20: TcxTextEdit
        Left = 60
        Top = 130
        Hint = 'E.R_ChouDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 5
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit21: TcxTextEdit
        Left = 204
        Top = 26
        Hint = 'E.R_BuRong'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 9
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit22: TcxTextEdit
        Left = 60
        Top = 104
        Hint = 'E.R_Jian'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 4
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit23: TcxTextEdit
        Left = 60
        Top = 26
        Hint = 'E.R_SO3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 1
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit24: TcxTextEdit
        Left = 60
        Top = 52
        Hint = 'E.R_ShaoShi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 2
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit26: TcxTextEdit
        Left = 204
        Top = 0
        Hint = 'E.R_BiBiao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 8
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit27: TcxTextEdit
        Left = 204
        Top = 78
        Hint = 'E.R_ZhongNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 11
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit28: TcxTextEdit
        Left = 204
        Top = 52
        Hint = 'E.R_ChuNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 10
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit45: TcxTextEdit
        Left = 60
        Top = 155
        Hint = 'E.R_YLiGai'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 6
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit55: TcxTextEdit
        Left = 204
        Top = 130
        Hint = 'E.R_SGType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 30
        Width = 75
      end
      object cxTextEdit56: TcxTextEdit
        Left = 204
        Top = 155
        Hint = 'E.R_SGValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 31
        Width = 75
      end
      object cxTextEdit58: TcxTextEdit
        Left = 350
        Top = 26
        Hint = 'E.R_HHCValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 32
        Width = 75
      end
      object cxComboBox1: TcxComboBox
        Left = 205
        Top = 105
        Hint = 'E.R_AnDing'
        ParentFont = False
        Properties.Items.Strings = (
          #21512#26684
          #19981#21512#26684)
        TabOrder = 33
        Text = #35831#36873#25321
        Width = 75
      end
      object cbxHhcl: TcxComboBox
        Left = 350
        Top = 0
        Hint = 'E.R_HHCType'
        ParentFont = False
        TabOrder = 34
        Text = #35831#36873#25321
        Width = 75
      end
      object cxTextEdit1: TcxTextEdit
        Left = 349
        Top = 52
        Hint = 'E.R_ZMJNAME'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 35
        Width = 75
      end
      object cxTextEdit2: TcxTextEdit
        Left = 349
        Top = 79
        Hint = 'E.R_ZMJVALUE'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 36
        Width = 75
      end
      object cxTextEdit3: TcxTextEdit
        Left = 349
        Top = 106
        Hint = 'E.R_C3S'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 37
        Width = 75
      end
      object cxTextEdit4: TcxTextEdit
        Left = 349
        Top = 130
        Hint = 'E.R_C3A'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 38
        Width = 75
      end
      object cxTextEdit5: TcxTextEdit
        Left = 349
        Top = 155
        Hint = 'E.R_SHR3D'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 39
        Width = 75
      end
      object cxTextEdit6: TcxTextEdit
        Left = 349
        Top = 180
        Hint = 'E.R_SHR7D'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 40
        Width = 75
      end
      object cxTextEdit7: TcxTextEdit
        Left = 204
        Top = 180
        Hint = 'E.R_GaiGui'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 41
        Width = 75
      end
      object cxTextEdit8: TcxTextEdit
        Left = 59
        Top = 208
        Hint = 'E.R_C2S'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 42
        Width = 75
      end
    end
    object EditDate: TcxDateEdit
      Left = 93
      Top = 86
      Hint = 'E.R_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 5
      Width = 155
    end
    object EditMan: TcxTextEdit
      Left = 299
      Top = 86
      Hint = 'E.R_Man'
      ParentFont = False
      TabOrder = 6
      Width = 120
    end
    object EditQuaStart: TcxTextEdit
      Left = 93
      Top = 111
      Hint = 'E.R_BatQuaStart'
      ParentFont = False
      TabOrder = 7
      Width = 121
    end
    object cxComboBox2: TcxComboBox
      Left = 93
      Top = 161
      Hint = 'E.R_BatValid'
      ParentFont = False
      Properties.Items.Strings = (
        'Y'
        'N')
      TabOrder = 9
      Text = 'Y'
      Width = 121
    end
    object EditStock: TcxComboBox
      Left = 93
      Top = 61
      Hint = 'E.R_PID'
      ParentFont = False
      Properties.OnChange = EditStockPropertiesEditValueChanged
      TabOrder = 3
      Width = 155
    end
    object EditQuaEnd: TcxTextEdit
      Left = 93
      Top = 136
      Hint = 'E.R_BatQuaEnd'
      ParentFont = False
      TabOrder = 8
      Width = 121
    end
    object cbxCenterID: TcxComboBox
      Left = 299
      Top = 61
      Hint = 'E.R_CenterID'
      ParentFont = False
      TabOrder = 10
      Width = 148
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #20986#21378#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item7: TdxLayoutItem
            Caption = #25152#23646#21697#31181':'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item9: TdxLayoutItem
            Caption = #29983#20135#32447':'
            Control = cbxCenterID
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #20986#21378#26085#26399':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #24405#20837#20154':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          Caption = #25209#27425#37327'('#21544'):'
          Control = EditQuaStart
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item8: TdxLayoutItem
          Caption = #39044#35686#37327'('#21544'):'
          Control = EditQuaEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item6: TdxLayoutItem
          Caption = #26159#21542#29983#25928':'
          Control = cxComboBox2
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26816#39564#25968#25454
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'Panel1'
          ShowCaption = False
          Control = wPanel
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
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
