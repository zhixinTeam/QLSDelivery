inherited fFormHYPrint: TfFormHYPrint
  Left = 383
  Top = 268
  BorderStyle = bsNone
  Caption = #25171#21360#21270#39564#21333
  ClientHeight = 247
  ClientWidth = 563
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 563
    Height = 247
    inherited BtnOK: TButton
      Left = 298
      Top = 192
      Width = 129
      Height = 44
      Caption = #30830#23450
      Font.Height = -32
      ParentFont = False
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 433
      Top = 192
      Width = 119
      Height = 44
      Font.Height = -24
      ParentFont = False
      TabOrder = 4
    end
    object editWebOrderNo: TcxTextEdit [2]
      Left = 24
      Top = 29
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -32
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.HotTrack = False
      Style.IsFontAssigned = True
      TabOrder = 0
      OnKeyPress = editWebOrderNoKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [3]
      Left = 319
      Top = 76
      Caption = #65288#35831#24405#20837#25552#36135#21333#21495#65289
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -24
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.HotTrack = False
      Style.IsFontAssigned = True
      Transparent = True
    end
    object btnClear: TcxButton [4]
      Left = 11
      Top = 192
      Width = 129
      Height = 44
      Caption = #28165#38500#36755#20837
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnClearClick
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #25552#36135#21333#21495
        object dxLayout1Item5: TdxLayoutItem
          Control = editWebOrderNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem [0]
          Control = btnClear
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
