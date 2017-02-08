inherited fFormWeixinReg: TfFormWeixinReg
  ClientHeight = 213
  ClientWidth = 366
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 366
    Height = 213
    inherited BtnOK: TButton
      Left = 219
      Top = 180
      Caption = #25552#20132
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 290
      Top = 180
      TabOrder = 2
    end
    object cxTextEditPhone: TcxTextEdit [2]
      Left = 90
      Top = 29
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #25163#26426#21495#30721#65306
          Control = cxTextEditPhone
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
