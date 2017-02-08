inherited fFormInvoice: TfFormInvoice
  Left = 658
  Top = 487
  ClientHeight = 249
  ClientWidth = 352
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 352
    Height = 249
    AutoContentSizes = [acsWidth, acsHeight]
    inherited BtnOK: TButton
      Left = 206
      Top = 216
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 276
      Top = 216
      TabOrder = 7
    end
    object EditMemo: TcxMemo [2]
      Left = 23
      Top = 132
      Hint = 'T.W_Memo'
      ParentFont = False
      Properties.MaxLength = 0
      Properties.ScrollBars = ssVertical
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 5
      Height = 45
      Width = 403
    end
    object Radio1: TcxRadioButton [3]
      Left = 23
      Top = 86
      Width = 100
      Height = 17
      Caption = #28155#21152#21333#24352#21457#31080
      Checked = True
      ParentColor = False
      TabOrder = 3
      TabStop = True
      OnClick = Radio2Click
    end
    object Radio2: TcxRadioButton [4]
      Left = 23
      Top = 36
      Width = 100
      Height = 17
      Caption = #25209#37327#28155#21152#21457#31080
      ParentColor = False
      TabOrder = 0
      OnClick = Radio2Click
    end
    object EditNo: TcxTextEdit [5]
      Left = 186
      Top = 86
      ParentFont = False
      Properties.MaxLength = 25
      TabOrder = 4
      Width = 165
    end
    object EditStart: TcxTextEdit [6]
      Left = 186
      Top = 36
      ParentFont = False
      Properties.MaxLength = 30
      Style.Color = clWindow
      TabOrder = 1
      Width = 165
    end
    object EditEnd: TcxTextEdit [7]
      Left = 186
      Top = 61
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 2
      Width = 165
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item5: TdxLayoutItem
              ShowCaption = False
              Control = Radio2
              ControlOptions.AutoColor = True
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Group5: TdxLayoutGroup
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item7: TdxLayoutItem
                Caption = #24320#22987#32534#21495':'
                Control = EditStart
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item8: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #32467#26463#32534#21495':'
                Control = EditEnd
                ControlOptions.ShowBorder = False
              end
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item3: TdxLayoutItem
              ShowCaption = False
              Control = Radio1
              ControlOptions.AutoColor = True
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21457#31080#32534#21495':'
              Control = EditNo
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item12: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #25552#31034#20449#24687':'
          CaptionOptions.Layout = clTop
          Offsets.Top = 3
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
