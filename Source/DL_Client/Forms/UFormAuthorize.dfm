inherited fFormAuthorize: TfFormAuthorize
  Left = 438
  Top = 418
  Caption = #25509#20837#30003#35831
  ClientHeight = 210
  ClientWidth = 371
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 371
    Height = 210
    inherited BtnOK: TButton
      Left = 225
      Top = 177
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 295
      Top = 177
      TabOrder = 6
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = False
      TabOrder = 1
      Width = 96
    end
    object EditMAC: TcxTextEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 96
    end
    object EditFact: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 2
      Width = 96
    end
    object EditSerial: TcxTextEdit [5]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 3
      Width = 96
    end
    object EditDepart: TcxTextEdit [6]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 4
      Width = 96
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #30005#33041#26631#35782':'
          Control = EditMAC
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #30005#33041#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #24037#21378#32534#21495':'
          Control = EditFact
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30005#33041#32534#21495':'
          Control = EditSerial
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #25152#23646#37096#38376':'
          Control = EditDepart
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
