inherited fFormIncInfo: TfFormIncInfo
  Left = 270
  Top = 173
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 249
  ClientWidth = 358
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 358
    Height = 249
    Align = alClient
    TabOrder = 0
    TabStop = False
    object EditName: TcxTextEdit
      Left = 84
      Top = 29
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 0
      Width = 209
    end
    object EditPhone: TcxTextEdit
      Left = 84
      Top = 56
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 1
      Width = 121
    end
    object EditWeb: TcxTextEdit
      Left = 84
      Top = 110
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 3
      Width = 121
    end
    object EditMail: TcxTextEdit
      Left = 84
      Top = 83
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 2
      Width = 121
    end
    object EditAddr: TcxTextEdit
      Left = 84
      Top = 137
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 4
      Width = 121
    end
    object EditMemo: TcxMemo
      Left = 84
      Top = 164
      Align = alClient
      ParentFont = False
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      TabOrder = 5
      Height = 40
      Width = 252
    end
    object BtnExit: TButton
      Left = 255
      Top = 223
      Width = 75
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 7
    end
    object BtnOK: TButton
      Left = 174
      Top = 223
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 6
      OnClick = BtnOKClick
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahParentManaged
      AlignVert = avTop
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        CaptionOptions.Text = #20844#21496#20449#24687
        ButtonOptions.Buttons = <>
        object dxLayoutControl1Item1: TdxLayoutItem
          CaptionOptions.Text = #20844#21496#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          CaptionOptions.Text = #20844#21496#30005#35805':'
          Control = EditPhone
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          CaptionOptions.Text = #20844#21496#37038#31665':'
          Control = EditMail
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          CaptionOptions.Text = #20844#21496#32593#22336':'
          Control = EditWeb
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          CaptionOptions.Text = #20844#21496#22320#22336':'
          Control = EditAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item6: TdxLayoutItem
          CaptionOptions.Text = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AlignHorz = ahRight
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item8: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button2'
          CaptionOptions.Visible = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AlignHorz = ahRight
          AlignVert = avBottom
          CaptionOptions.Text = 'Button1'
          CaptionOptions.Visible = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
