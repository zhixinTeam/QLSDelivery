inherited fFormOptions: TfFormOptions
  Left = 348
  Top = 164
  Caption = #31995#32479#36873#39033
  ClientHeight = 359
  ClientWidth = 500
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 500
    Height = 359
    inherited BtnOK: TButton
      Left = 354
      Top = 326
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 424
      Top = 326
      TabOrder = 2
    end
    object wPage: TcxPageControl [2]
      Left = 23
      Top = 36
      Width = 289
      Height = 193
      ActivePage = cxSheet1
      ParentColor = False
      ShowFrame = True
      Style = 9
      TabOrder = 0
      TabSlants.Kind = skCutCorner
      OnChange = wPageChange
      ClientRectBottom = 192
      ClientRectLeft = 1
      ClientRectRight = 288
      ClientRectTop = 19
      object cxSheet1: TcxTabSheet
        Caption = #22522#26412#21442#25968
        ImageIndex = 5
        object Label5: TLabel
          Left = 10
          Top = 22
          Width = 54
          Height = 12
          Caption = #24433#23376#37325#37327':'
        end
        object Label1: TLabel
          Left = 166
          Top = 24
          Width = 12
          Height = 12
          Caption = #21544
        end
        object EditShadow: TcxTextEdit
          Left = 67
          Top = 20
          ParentFont = False
          Properties.OnChange = EditShadowPropertiesChange
          TabOrder = 0
          Width = 98
        end
      end
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21442#25968#35774#32622
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'cxPageControl1'
          ShowCaption = False
          Control = wPage
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
