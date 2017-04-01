inherited fFormGetZhiKa: TfFormGetZhiKa
  Left = 321
  Top = 195
  ClientHeight = 440
  ClientWidth = 495
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 495
    Height = 440
    inherited BtnOK: TButton
      Left = 349
      Top = 407
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 419
      Top = 407
      TabOrder = 6
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 338
      Height = 116
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 85
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 249
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditID: TcxButtonEdit [3]
      Left = 81
      Top = 157
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 124
    end
    object EditName: TcxComboBox [4]
      Left = 81
      Top = 182
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditNamePropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      OnKeyPress = EditNameKeyPress
      Width = 185
    end
    object ListDetail: TcxListView [5]
      Left = 23
      Top = 264
      Width = 355
      Height = 154
      Checkboxes = True
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 200
        end
        item
          Caption = #21333#20215'('#20803'/'#21544')'
          Width = 60
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 80
        end
        item
          Caption = #22791#27880
          Width = 100
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 4
      ViewStyle = vsReport
    end
    object EditZK: TcxComboBox [6]
      Left = 81
      Top = 239
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditZKPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      OnKeyPress = EditZKKeyPress
      Width = 368
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = '1.'#36873#25321#23458#25143
        object dxLayout1Item7: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = '2.'#36873#25321#32440#21345
        object dxLayout1Item4: TdxLayoutItem
          Caption = #35746#21333#21015#34920':'
          Control = EditZK
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
