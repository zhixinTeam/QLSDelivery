inherited fFormPoundKw: TfFormPoundKw
  Caption = 'fFormPoundKw'
  ClientHeight = 204
  ClientWidth = 295
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 295
    Height = 204
    inherited BtnOK: TButton
      Left = 149
      Top = 171
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 219
      Top = 171
      TabOrder = 6
    end
    object cxLabel1: TcxLabel [2]
      Left = 23
      Top = 36
      Caption = #21208#35823#19987#29992#65292#31105#27490#28389#29992#65307#35831#35880#24910#20351#29992#65281
      ParentFont = False
    end
    object EditTruck: TcxTextEdit [3]
      Left = 87
      Top = 107
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditPValue: TcxTextEdit [4]
      Left = 87
      Top = 132
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditLID: TcxTextEdit [5]
      Left = 87
      Top = 57
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditPID: TcxTextEdit [6]
      Left = 87
      Top = 82
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21208#35823#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #30917' '#21333' '#21495':'
          Control = EditPID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721#65306
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30382#37325'('#21544'):'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
