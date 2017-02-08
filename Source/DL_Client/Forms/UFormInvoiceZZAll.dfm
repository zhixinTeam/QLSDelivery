inherited fFormInvoiceZZAll: TfFormInvoiceZZAll
  Left = 515
  Top = 349
  ClientHeight = 276
  ClientWidth = 437
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 437
    Height = 276
    inherited BtnOK: TButton
      Left = 291
      Top = 243
      Caption = #24320#22987
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 361
      Top = 243
      TabOrder = 4
    end
    object EditMemo: TcxMemo [2]
      Left = 23
      Top = 96
      Hint = 'T.W_Memo'
      ParentFont = False
      Properties.MaxLength = 0
      Properties.ScrollBars = ssVertical
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      Height = 45
      Width = 403
    end
    object EditWeek: TcxButtonEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditWeekPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 61
      AutoSize = False
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 12
      Width = 395
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36873#39033
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32467#31639#21608#26399':'
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #25552#31034#20449#24687':'
          CaptionOptions.Layout = clTop
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
