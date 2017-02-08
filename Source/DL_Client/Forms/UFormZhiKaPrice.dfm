inherited fFormZKPrice: TfFormZKPrice
  Left = 296
  Top = 302
  ClientHeight = 218
  ClientWidth = 366
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 366
    Height = 218
    inherited BtnOK: TButton
      Left = 220
      Top = 185
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 290
      Top = 185
      TabOrder = 6
    end
    object EditStock: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditPrice: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditNew: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 2
      Width = 121
    end
    object Check1: TcxCheckBox [5]
      Left = 23
      Top = 111
      Caption = #26032#21333#20215#29983#25928#21518#35299#20923#32440#21345'.'
      ParentFont = False
      State = cbsChecked
      TabOrder = 3
      Transparent = True
      Width = 121
    end
    object Check2: TcxCheckBox [6]
      Left = 23
      Top = 137
      Caption = #22312#21407#21333#20215#22522#30784#19978#24212#29992#26032#21333#20215'.'
      ParentFont = False
      TabOrder = 4
      Transparent = True
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36873#39033
        object dxLayout1Item3: TdxLayoutItem
          Caption = #27700#27877#21697#31181':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #38144#21806#20215#26684':'
          Control = EditPrice
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #26032' '#21333' '#20215':'
          Control = EditNew
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
