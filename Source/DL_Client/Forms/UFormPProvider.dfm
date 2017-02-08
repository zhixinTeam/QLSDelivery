inherited fFormProvider: TfFormProvider
  Left = 605
  Top = 319
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 500
  ClientWidth = 465
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 15
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 465
    Height = 500
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object EditName: TcxTextEdit
      Left = 87
      Top = 73
      Hint = 'T.P_Name'
      ParentFont = False
      Properties.MaxLength = 80
      TabOrder = 1
      OnKeyDown = FormKeyDown
      Width = 173
    end
    object EditMemo: TcxMemo
      Left = 87
      Top = 129
      Hint = 'T.P_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 4
      Height = 62
      Width = 460
    end
    object InfoList1: TcxMCListBox
      Left = 29
      Top = 292
      Width = 496
      Height = 131
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 105
        end
        item
          AutoSize = True
          Text = #20869#23481
          Width = 387
        end>
      ParentFont = False
      Style.BorderStyle = cbsOffice11
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 9
    end
    object InfoItems: TcxComboBox
      Left = 87
      Top = 236
      ParentFont = False
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.MaxLength = 30
      TabOrder = 5
      Width = 94
    end
    object EditInfo: TcxTextEdit
      Left = 87
      Top = 264
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 7
      Width = 113
    end
    object BtnAdd: TButton
      Left = 380
      Top = 236
      Width = 56
      Height = 22
      Caption = #28155#21152
      TabOrder = 6
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 380
      Top = 264
      Width = 56
      Height = 22
      Caption = #21024#38500
      TabOrder = 8
      OnClick = BtnDelClick
    end
    object BtnOK: TButton
      Left = 272
      Top = 458
      Width = 87
      Height = 28
      Caption = #20445#23384
      TabOrder = 10
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 364
      Top = 458
      Width = 87
      Height = 28
      Caption = #21462#28040
      TabOrder = 11
      OnClick = BtnExitClick
    end
    object cxTextEdit3: TcxTextEdit
      Left = 282
      Top = 101
      Hint = 'T.P_Phone'
      ParentFont = False
      Properties.MaxLength = 20
      TabOrder = 3
      OnKeyDown = FormKeyDown
      Width = 182
    end
    object EditID: TcxTextEdit
      Left = 87
      Top = 45
      Hint = 'T.P_ID'
      ParentFont = False
      Properties.MaxLength = 80
      TabOrder = 0
      OnKeyDown = FormKeyDown
      Width = 348
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
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #20379#24212#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item2: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #20379#24212#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item14: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32852#31995#26041#24335':'
            Control = cxTextEdit3
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #38468#21152#20449#24687
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449' '#24687' '#39033':'
              Control = InfoItems
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button1'
              ShowCaption = False
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449#24687#20869#23481':'
              Control = EditInfo
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button2'
              ShowCaption = False
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = InfoList1
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
