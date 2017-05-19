object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 192
  Top = 130
  Height = 217
  Width = 251
  object ADOCLoc: TADOConnection
    LoginPrompt = False
    Left = 32
    Top = 8
  end
  object ADOCRem: TADOConnection
    LoginPrompt = False
    Left = 32
    Top = 64
  end
  object qryLoc: TADOQuery
    Connection = ADOCLoc
    Parameters = <>
    Left = 96
    Top = 8
  end
  object qryRem: TADOQuery
    Connection = ADOCRem
    Parameters = <>
    Left = 96
    Top = 64
  end
end
