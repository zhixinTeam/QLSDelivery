inherited BaseForm1: TBaseForm1
  Left = 454
  Top = 435
  Width = 644
  Height = 453
  Caption = 'test -default'
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 15
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 636
    Height = 380
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 236
      Top = 10
      Width = 75
      Height = 25
      Caption = 'test'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 18
      Top = 12
      Width = 209
      Height = 23
      TabOrder = 1
      Text = 'Edit1'
    end
  end
end
