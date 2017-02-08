inherited fFormPWuCha: TfFormPWuCha
  Left = 462
  Top = 291
  Caption = 'fFormPWuCha'
  ClientHeight = 183
  ClientWidth = 262
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 262
    Height = 183
    inherited BtnOK: TButton
      Left = 116
      Top = 150
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 186
      Top = 150
      TabOrder = 5
    end
    object EditStart: TcxTextEdit [2]
      Left = 87
      Top = 36
      Hint = 'P.W_StartValue'
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditEnd: TcxTextEdit [3]
      Left = 87
      Top = 61
      Hint = 'P.W_EndValue'
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditZValue: TcxTextEdit [4]
      Left = 87
      Top = 86
      Hint = 'P.W_ZValue'
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditFValue: TcxTextEdit [5]
      Left = 87
      Top = 111
      Hint = 'P.W_FValue'
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21442#25968#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = #24320#22987#21544#20301#65306
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #32467#26463#21544#20301#65306
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #27491#35823#24046#20540#65306
          Control = EditZValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36127#35823#24046#20540#65306
          Control = EditFValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
