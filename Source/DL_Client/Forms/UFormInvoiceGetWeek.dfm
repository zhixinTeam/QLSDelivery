inherited fFormInvoiceGetWeek: TfFormInvoiceGetWeek
  Left = 658
  Top = 487
  ClientHeight = 134
  ClientWidth = 296
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 296
    Height = 134
    AutoContentSizes = [acsWidth, acsHeight]
    inherited BtnOK: TButton
      Left = 150
      Top = 101
      Caption = #30830#23450
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 220
      Top = 101
      TabOrder = 3
    end
    object EditYear: TcxComboBox [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditYearPropertiesEditValueChanged
      TabOrder = 0
      Width = 100
    end
    object EditWeek: TcxComboBox [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 18
      TabOrder = 1
      Width = 142
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #35831#36873#25321':'
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25152#22312#24180#20221':'
          Control = EditYear
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #21608#26399#21015#34920':'
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
