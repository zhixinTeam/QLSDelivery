inherited fFormInvoiceWeek: TfFormInvoiceWeek
  Left = 574
  Top = 431
  ClientHeight = 202
  ClientWidth = 359
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 359
    Height = 202
    AutoContentSizes = [acsWidth, acsHeight]
    inherited BtnOK: TButton
      Left = 213
      Top = 169
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 283
      Top = 169
      TabOrder = 5
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 36
      Hint = 'T.W_Name'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 0
      Width = 174
    end
    object EditMemo: TcxMemo [3]
      Left = 81
      Top = 111
      Hint = 'T.W_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 3
      Height = 45
      Width = 403
    end
    object EditStart: TcxDateEdit [4]
      Left = 81
      Top = 61
      Hint = 'T.W_Begin'
      ParentFont = False
      TabOrder = 1
      Width = 130
    end
    object EditEnd: TcxDateEdit [5]
      Left = 81
      Top = 86
      Hint = 'T.W_End'
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21608#26399#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #24320#22987#26085#26399':'
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #32467#26463#26085#26399':'
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
