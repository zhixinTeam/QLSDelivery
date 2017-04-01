inherited fFormWeixinBind: TfFormWeixinBind
  Left = 628
  Top = 406
  Caption = #21333#20215
  ClientHeight = 116
  ClientWidth = 313
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 313
    Height = 116
    inherited BtnOK: TButton
      Left = 167
      Top = 83
      Caption = #30830#23450
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 237
      Top = 83
      TabOrder = 2
    end
    object EditMobileNo: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      OnKeyPress = EditMobileNoKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25163#26426#21495#30721':'
          Control = EditMobileNo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
