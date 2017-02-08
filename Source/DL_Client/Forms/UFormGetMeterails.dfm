inherited fFormGetMeterails: TfFormGetMeterails
  Left = 503
  Width = 520
  Height = 309
  BorderStyle = bsSizeable
  Constraints.MinHeight = 220
  Constraints.MinWidth = 400
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 504
    Height = 271
    inherited BtnOK: TButton
      Left = 358
      Top = 238
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 428
      Top = 238
      TabOrder = 4
    end
    object EditMeterails: TcxButtonEdit [2]
      Left = 69
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListMeterails: TcxListView [3]
      Left = 23
      Top = 82
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #21407#26448#26009#32534#21495
          Width = 80
        end
        item
          Caption = #21407#26448#26009#21517#31216
          Width = 100
        end
        item
          Caption = #22791#27880
          Width = 70
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = ListMeterailsDblClick
      OnKeyPress = ListMeterailsKeyPress
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 61
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21407#26448#26009':'
          Control = EditMeterails
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26597#35810#32467#26524':'
          ShowCaption = False
          Control = ListMeterails
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
