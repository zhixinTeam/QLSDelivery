inherited fFormWorkSet: TfFormWorkSet
  Caption = 'fFormWorkSet'
  ClientHeight = 222
  ClientWidth = 349
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 349
    Height = 222
    inherited BtnOK: TButton
      Left = 203
      Top = 189
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 273
      Top = 189
      TabOrder = 3
    end
    object DBGridWorkSet: TDBGrid [2]
      Left = 24
      Top = 37
      Width = 301
      Height = 100
      BorderStyle = bsNone
      DataSource = DataSource1
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = #23435#20307
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'Z_WorkOrder'
          Title.Caption = #29677#21035
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Z_StartTime'
          Title.Caption = #24320#22987#26102#38388
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Z_EndTime'
          Title.Caption = #32467#26463#26102#38388
          Width = 100
          Visible = True
        end>
    end
    object DBNavigator1: TDBNavigator [3]
      Left = 23
      Top = 143
      Width = 240
      Height = 25
      DataSource = DataSource1
      TabOrder = 1
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #29677#21035#35774#32622
        object dxLayout1Item3: TdxLayoutItem
          Control = DBGridWorkSet
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = DBNavigator1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object QryWorkSet: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 40
    Top = 88
  end
  object DataSource1: TDataSource
    DataSet = QryWorkSet
    Left = 72
    Top = 88
  end
end
