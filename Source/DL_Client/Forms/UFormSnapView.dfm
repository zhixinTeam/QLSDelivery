inherited fFormSnapView: TfFormSnapView
  Left = 196
  Top = 32
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #25235#25293#39044#35272
  ClientHeight = 606
  ClientWidth = 807
  OldCreateOrder = True
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 807
    Height = 606
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 721
      Top = 570
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 1
      OnClick = BtnOKClick
    end
    object ImageTruck: TcxImage
      Left = 75
      Top = 36
      Align = alTop
      AutoSize = True
      Properties.ReadOnly = True
      TabOrder = 0
      Height = 522
      Width = 820
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        AutoAligns = []
        AlignHorz = ahClient
        Caption = #36710#36742#20449#24687
        object dxLayoutControl1Item9: TdxLayoutItem
          Caption = #36710#36742#22270#29255
          Control = ImageTruck
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Item8: TdxLayoutItem
        AutoAligns = [aaVertical]
        AlignHorz = ahRight
        Caption = 'Button2'
        ShowCaption = False
        Control = BtnOK
        ControlOptions.ShowBorder = False
      end
    end
  end
end
