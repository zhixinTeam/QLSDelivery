inherited fFormInvoicesView: TfFormInvoicesView
  Left = 292
  Top = 260
  Width = 573
  Height = 356
  BorderStyle = bsSizeable
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 565
    Height = 322
    AutoContentSizes = [acsWidth, acsHeight]
    inherited BtnOK: TButton
      Left = 419
      Top = 289
      Caption = #30830#23450
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 489
      Top = 289
      TabOrder = 2
    end
    object ListDetail: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 433
      Height = 170
      HeaderSections = <
        item
          Text = #21457#31080#32534#21495
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #25552#36135#21333#20215
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24320#31080#21333#20215
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24320#31080#21544#25968
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #24320#31080#37329#39069
          Width = 75
        end
        item
          Alignment = taCenter
          Text = #25240#25187#37329#39069
          Width = 65
        end
        item
          Text = #24320#31080#26102#38388
          Width = 75
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #21457#31080#21015#34920
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        inherited dxLayout1Item1: TdxLayoutItem
          AutoAligns = []
          AlignVert = avBottom
        end
      end
    end
  end
end
