inherited fFormRFIDCard: TfFormRFIDCard
  Caption = #20851#32852#30005#23376#26631#31614
  ClientHeight = 171
  ClientWidth = 347
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 347
    Height = 171
    inherited BtnOK: TButton
      Left = 201
      Top = 138
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 271
      Top = 138
      TabOrder = 7
    end
    object edtTruck: TcxTextEdit [2]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object edtRFIDCard: TcxTextEdit [3]
      Left = 87
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      Style.HotTrack = False
      TabOrder = 1
      Width = 191
    end
    object chkValue: TcxCheckBox [4]
      Left = 11
      Top = 138
      Caption = #21551#29992#30005#23376#26631#31614
      ParentFont = False
      State = cbsChecked
      Style.HotTrack = False
      TabOrder = 5
      Transparent = True
      Width = 105
    end
    object BtnReadCard1: TButton [5]
      Left = 283
      Top = 61
      Width = 40
      Height = 21
      Caption = #35835#21345
      TabOrder = 2
      OnClick = BtnReadCard1Click
    end
    object edtRFIDCard2: TcxTextEdit [6]
      Left = 87
      Top = 87
      TabOrder = 3
      Width = 191
    end
    object BtnReadCard2: TButton [7]
      Left = 283
      Top = 87
      Width = 40
      Height = 21
      Caption = #35835#21345
      TabOrder = 4
      OnClick = BtnReadCard2Click
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = edtTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #30005#23376#26631#31614'1:'
            Control = edtRFIDCard
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            Caption = 'Button1'
            ShowCaption = False
            Control = BtnReadCard1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            Caption = #30005#23376#26631#31614'2:'
            Control = edtRFIDCard2
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            Caption = 'Button2'
            ShowCaption = False
            Control = BtnReadCard2
            ControlOptions.ShowBorder = False
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem [0]
          Control = chkValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object tmrReadCard: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrReadCardTimer
    Left = 288
    Top = 16
  end
end
