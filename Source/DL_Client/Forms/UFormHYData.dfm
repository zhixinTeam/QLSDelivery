inherited fFormHYData: TfFormHYData
  Left = 323
  Top = 208
  ClientHeight = 219
  ClientWidth = 450
  Constraints.MinHeight = 245
  Constraints.MinWidth = 460
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 450
    Height = 219
    inherited BtnOK: TButton
      Left = 304
      Top = 186
      Caption = #30830#23450
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 374
      Top = 186
      TabOrder = 8
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 131
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 5
      OnKeyPress = EditTruckKeyPress
      Width = 147
    end
    object EditValue: TcxTextEdit [3]
      Left = 303
      Top = 131
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 6
      Width = 403
    end
    object EditCustom: TcxComboBox [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnChange = EditCustomPropertiesChange
      TabOrder = 0
      OnKeyPress = EditCustomKeyPress
      Width = 121
    end
    object EditNo: TcxButtonEdit [5]
      Left = 303
      Top = 106
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNoPropertiesButtonClick
      TabOrder = 4
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditDate: TcxDateEdit [6]
      Left = 81
      Top = 106
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 3
      Width = 147
    end
    object EditName: TcxTextEdit [7]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 80
      TabOrder = 1
      Width = 121
    end
    object cxLabel2: TcxLabel [8]
      Left = 23
      Top = 86
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Vert = taBottomJustify
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 15
      Width = 466
      AnchorY = 101
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustom
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #24320#21333#23458#25143':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          ShowCaption = False
          Control = cxLabel2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            Caption = #25552#36135#26085#26399':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #20986#21378#32534#21495':'
            Control = EditNo
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#37327'('#21544'):'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
