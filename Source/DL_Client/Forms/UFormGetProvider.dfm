inherited fFormGetProvider: TfFormGetProvider
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
    object EditProvider: TcxButtonEdit [2]
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
    object ListProvider: TcxListView [3]
      Left = 23
      Top = 82
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #20379#24212#21830#32534#21495
          Width = 80
        end
        item
          Caption = #20379#24212#21830#21517#31216
          Width = 100
        end
        item
          Caption = #36741#21161#32534#21495
          Width = 70
        end
        item
          Caption = #19994#21153#21592
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = ListProviderDblClick
      OnKeyPress = ListProviderKeyPress
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
          Caption = #20379#24212#21830':'
          Control = EditProvider
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
          Control = ListProvider
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
