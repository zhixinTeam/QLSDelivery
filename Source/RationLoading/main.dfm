object FormMain: TFormMain
  Left = 389
  Top = 144
  Width = 665
  Height = 453
  Caption = #25955#35013#23450#21046#35013#36710
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 483
    Top = 0
    Width = 166
    Height = 415
    Align = alRight
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object wPanel: TScrollBox
    Left = 0
    Top = 0
    Width = 483
    Height = 415
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 1
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 5051
    OnExecute = IdTCPServer1Execute
    Left = 40
    Top = 8
  end
end
