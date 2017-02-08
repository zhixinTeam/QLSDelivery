inherited fFormWeiXinBindUser: TfFormWeiXinBindUser
  ClientHeight = 158
  ClientWidth = 284
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 284
    Height = 158
    inherited BtnOK: TButton
      Left = 138
      Top = 125
      Caption = #25552#20132
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 208
      Top = 125
      TabOrder = 3
    end
    object cxTextEditPhone: TcxTextEdit [2]
      Left = 87
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object cxRadioGroupBind: TcxRadioGroup [3]
      Left = 23
      Top = 61
      ParentFont = False
      Properties.Columns = 2
      Properties.Items = <
        item
          Caption = #35299#32465#29992#25143
        end
        item
          Caption = #32465#23450#29992#25143
        end>
      ItemIndex = 1
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Height = 49
      Width = 236
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = #21457#36865#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #25163#26426#21495#30721#65306
          Control = cxTextEditPhone
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = 'cxRadioGroup1'
          CaptionOptions.Visible = False
          Control = cxRadioGroupBind
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
