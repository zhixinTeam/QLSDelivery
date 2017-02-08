inherited fFormInvoiceZZCus: TfFormInvoiceZZCus
  Left = 377
  Top = 91
  Width = 520
  Height = 596
  BorderStyle = bsSizeable
  Constraints.MinHeight = 452
  Constraints.MinWidth = 455
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 512
    Height = 569
    inherited BtnOK: TButton
      Left = 366
      Top = 536
      Caption = #24320#22987
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 436
      Top = 536
      TabOrder = 6
    end
    object EditMemo: TcxMemo [2]
      Left = 23
      Top = 420
      Hint = 'T.W_Memo'
      ParentFont = False
      Properties.MaxLength = 0
      Properties.ScrollBars = ssVertical
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 4
      Height = 104
      Width = 551
    end
    object EditWeek: TcxButtonEdit [3]
      Left = 81
      Top = 360
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditWeekPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 385
      AutoSize = False
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 12
      Width = 395
    end
    object cxGrid1: TcxGrid [5]
      Left = 23
      Top = 36
      Width = 250
      Height = 200
      TabOrder = 0
      object cxView1: TcxGridTableView
        PopupMenu = PMenu1
        NavigatorButtons.ConfirmDelete = False
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object cxColumn0: TcxGridColumn
          Caption = #29366#24577
          PropertiesClassName = 'TcxCheckBoxProperties'
          HeaderAlignmentHorz = taCenter
        end
        object cxColumn1: TcxGridColumn
          Tag = 1
          Caption = #19994#21153#21592
        end
        object cxColumn2: TcxGridColumn
          Tag = 2
          Caption = #23458#25143#32534#21495
        end
        object cxColumn3: TcxGridColumn
          Tag = 3
          Caption = #23458#25143#21517#31216
        end
      end
      object cxLevel1: TcxGridLevel
        GridView = cxView1
      end
    end
    object EditCus: TcxButtonEdit [6]
      Left = 81
      Top = 303
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCusPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 96
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36873#25321#23458#25143
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #23458#25143#21015#34920':'
          CaptionOptions.Layout = clTop
          ShowCaption = False
          Control = cxGrid1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        Caption = #25552#31034#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32467#31639#21608#26399':'
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxLabel1'
          CaptionOptions.Layout = clTop
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
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 32
    Top = 62
    object N4: TMenuItem
      Tag = 10
      Caption = #20840#37096#36873#20013
      OnClick = N4Click
    end
    object N5: TMenuItem
      Tag = 20
      Caption = #20840#37096#21462#28040
      OnClick = N4Click
    end
    object N6: TMenuItem
      Tag = 30
      Caption = #20840#37096#21453#36873
      OnClick = N4Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = #36733#20837#36873#39033
      OnClick = N1Click
    end
    object N3: TMenuItem
      Caption = #20445#23384#36873#39033
      OnClick = N3Click
    end
  end
end
