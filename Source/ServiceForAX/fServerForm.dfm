object ServerForm: TServerForm
  Left = 372
  Top = 277
  BorderStyle = bsDialog
  Caption = 'WebService'#26381#21153#31471
  ClientHeight = 316
  ClientWidth = 503
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblport: TLabel
    Left = 16
    Top = 37
    Width = 246
    Height = 17
    AutoSize = False
    Caption = #36816#34892#31471#21475#65306
  end
  object mmo1: TMemo
    Left = 15
    Top = 56
    Width = 473
    Height = 249
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object chkShowLog: TCheckBox
    Left = 384
    Top = 37
    Width = 103
    Height = 17
    Caption = #26174#31034#36816#34892#26085#24535
    TabOrder = 1
  end
  object ChkModel: TCheckBox
    Left = 275
    Top = 37
    Width = 97
    Height = 17
    Caption = #22312#32447#27169#24335
    TabOrder = 2
    OnClick = ChkModelClick
  end
  object BtnConn: TButton
    Left = 403
    Top = 6
    Width = 75
    Height = 25
    Caption = #25968#25454#36830#25509
    TabOrder = 3
    Visible = False
  end
  object ROMessage: TROSOAPMessage
    Envelopes = <>
    SerializationOptions = [xsoSendUntyped, xsoStrictStructureFieldOrder, xsoDocument, xsoSplitServiceWsdls]
    Left = 36
    Top = 8
  end
  object ROServer: TROIndyHTTPServer
    Dispatchers = <
      item
        Name = 'ROMessage'
        Message = ROMessage
        Enabled = True
        PathInfo = 'SOAP'
      end>
    IndyServer.Bindings = <>
    IndyServer.DefaultPort = 8099
    Port = 8099
    Left = 8
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 72
    Top = 8
  end
  object tmrRestart: TTimer
    Enabled = False
    OnTimer = tmrRestartTimer
    Left = 120
    Top = 8
  end
end
