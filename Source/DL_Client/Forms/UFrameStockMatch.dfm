inherited fFrameStockMatch: TfFrameStockMatch
  inherited ToolBar1: TToolBar
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #22810#21697#31181#20849#29992#36947#35774#32622
      Style.IsFontAssigned = True
      AnchorX = 351
      AnchorY = 11
    end
  end
end
