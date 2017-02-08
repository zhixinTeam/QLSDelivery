inherited fFormInvoiceAdjust: TfFormInvoiceAdjust
  Left = 473
  Top = 334
  ClientHeight = 175
  ClientWidth = 329
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 329
    Height = 175
    AutoControlAlignment = False
    inherited BtnOK: TButton
      Left = 183
      Top = 142
      Caption = #30830#23450
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 253
      Top = 142
      TabOrder = 5
    end
    object EditPrice: TcxTextEdit [2]
      Left = 93
      Top = 103
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object cxLabel2: TcxLabel [3]
      Left = 23
      Top = 82
      Caption = 'xxxx'
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaTop
      Transparent = True
    end
    object EditValue: TcxTextEdit [4]
      Left = 81
      Top = 57
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object cxLabel1: TcxLabel [5]
      Left = 23
      Top = 36
      Caption = 'xxxx'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item6: TdxLayoutItem
          Caption = 'cxLabel2'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = '  '#30003#35831#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = '  '#24320#31080#21333#20215':'
          Control = EditPrice
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        inherited dxLayout1Item1: TdxLayoutItem
          AutoAligns = []
          AlignVert = avBottom
        end
      end
    end
  end
end
