inherited fFormWXSendlog: TfFormWXSendlog
  Left = 554
  Top = 415
  Width = 465
  Height = 432
  BorderStyle = bsSizeable
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 457
    Height = 405
    inherited BtnOK: TButton
      Left = 311
      Top = 372
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 381
      Top = 372
      TabOrder = 6
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 64
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditSend: TcxMemo [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 500
      TabOrder = 3
      Height = 89
      Width = 185
    end
    object EditRecv: TcxMemo [4]
      Left = 81
      Top = 226
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 4
      Height = 89
      Width = 185
    end
    object EditNum: TcxTextEdit [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 3
      TabOrder = 1
      Width = 121
    end
    object EditStatus: TcxComboBox [6]
      Left = 265
      Top = 61
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        'N'#12289#24453#21457#36865
        'I'#12289#21457#36865#20013
        'Y'#12289#24050#21457#36865)
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25509#25910#32534#21495':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item4: TdxLayoutItem
            Caption = #21457#36865#27425#25968':'
            Control = EditNum
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21457#36865#29366#24577':'
            Control = EditStatus
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #21457#36865#25968#25454':'
          Control = EditSend
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #24212#31572#25968#25454':'
          Control = EditRecv
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
