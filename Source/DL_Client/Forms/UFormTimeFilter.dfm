object fFormTimeFilter: TfFormTimeFilter
  Left = 704
  Top = 313
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 153
  ClientWidth = 309
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 309
    Height = 153
    Align = alClient
    TabOrder = 0
    TabStop = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 164
      Top = 118
      Width = 62
      Height = 22
      Caption = #30830#23450
      TabOrder = 3
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 231
      Top = 118
      Width = 62
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 4
    end
    object ItemID: TcxButtonEdit
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      Width = 200
    end
    object EditStart: TcxTimeEdit
      Left = 81
      Top = 61
      EditValue = 0d
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditEnd: TcxTimeEdit
      Left = 81
      Top = 86
      EditValue = 0d
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #26085#26399#35774#23450
        object dxLayoutControl1Item5: TdxLayoutItem
          Caption = #26102#38388#32534#21495':'
          Control = ItemID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #24320#22987#26102#38388':'
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #32467#26463#26102#38388
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button2'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
