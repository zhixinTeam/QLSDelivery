inherited fFormSiteConfirm: TfFormSiteConfirm
  Left = 402
  Top = 256
  Caption = #29616#22330#35013#36710#20449#24687#30830#35748
  ClientHeight = 364
  ClientWidth = 386
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 386
    Height = 364
    inherited BtnOK: TButton
      Left = 240
      Top = 331
      Caption = #25552#20132
      TabOrder = 11
    end
    inherited BtnExit: TButton
      Left = 310
      Top = 331
      TabOrder = 12
    end
    object EditCard: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object EditLID: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      Width = 121
    end
    object EditTruck: TcxTextEdit [4]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 121
    end
    object EditStockName: TcxTextEdit [5]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 121
    end
    object EditPlanWeight: TcxTextEdit [6]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 6
      Width = 121
    end
    object cbxSampleID: TcxComboBox [7]
      Left = 81
      Top = 261
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 9
      Width = 121
    end
    object cxLabel1: TcxLabel [8]
      Left = 23
      Top = 286
      Caption = #24050#35013#21544#25968#65306
      ParentFont = False
      Style.HotTrack = False
    end
    object EditType: TcxTextEdit [9]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Width = 121
    end
    object cbxWorkSet: TcxComboBox [10]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.Items.Strings = (
        #30002
        #20057
        #19993)
      TabOrder = 7
      Width = 121
    end
    object cbxKw: TcxComboBox [11]
      Left = 81
      Top = 236
      ParentFont = False
      TabOrder = 8
      Width = 121
    end
    object EditCustomer: TcxTextEdit [12]
      Left = 81
      Top = 86
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #30913#21345#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #25552#36135#21333#20301':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #27700#27877#21697#31181':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #21253#35013#31867#22411':'
          Control = EditType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #31080#37325'('#21544'):'
          Control = EditPlanWeight
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #29677'    '#21035':'
          Control = cbxWorkSet
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #24211'    '#20301':'
          Control = cbxKw
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #35797#26679#32534#21495':'
          Control = cbxSampleID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    OnRxChar = ComPort1RxChar
    Left = 344
    Top = 16
  end
end
