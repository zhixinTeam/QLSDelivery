inherited fFormServiceURL: TfFormServiceURL
  Left = 397
  Top = 290
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #26381#21153#22320#22336
  ClientHeight = 319
  ClientWidth = 444
  OldCreateOrder = True
  Position = poDesktopCenter
  PixelsPerInch = 120
  TextHeight = 15
  object Bevel1: TBevel
    Left = 5
    Top = 276
    Width = 432
    Height = 6
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 68
    Height = 15
    Caption = #26412#22320#26381#21153':'
  end
  object Label2: TLabel
    Left = 8
    Top = 155
    Width = 68
    Height = 15
    Caption = #36828#31243#26381#21153':'
  end
  object BtnExit: TButton
    Left = 357
    Top = 285
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 3
  end
  object BtnOK: TButton
    Left = 277
    Top = 285
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 2
    OnClick = BtnOKClick
  end
  object MemoLocal: TMemo
    Left = 8
    Top = 38
    Width = 423
    Height = 102
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssVertical
    TabOrder = 0
    OnChange = MemoLocalChange
  end
  object MemoRemote: TMemo
    Left = 8
    Top = 172
    Width = 423
    Height = 102
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssVertical
    TabOrder = 1
    OnChange = MemoLocalChange
  end
end
