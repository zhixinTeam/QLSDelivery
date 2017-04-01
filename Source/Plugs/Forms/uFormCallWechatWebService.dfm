object FrmCallWechatWebService: TFrmCallWechatWebService
  Left = 425
  Top = 270
  Width = 359
  Height = 310
  Caption = 'FrmCallWechatWebService'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object rspmsg1: TROSOAPMessage
    Envelopes = <>
    SerializationOptions = [xsoSendUntyped, xsoStrictStructureFieldOrder, xsoDocument, xsoSplitServiceWsdls]
    Left = 8
    Top = 8
  end
  object rwnthtpchnl1: TROWinInetHTTPChannel
    UserAgent = 'RemObjects SDK'
    TargetURL = 'http://localhost:8088/SOAP'
    TrustInvalidCA = False
    ServerLocators = <>
    DispatchOptions = []
    Left = 48
    Top = 8
  end
  object rmtsrvc1: TRORemoteService
    Message = rspmsg1
    Channel = rwnthtpchnl1
    ServiceName = 'SrvWebchat'
    Left = 88
    Top = 8
  end
end
