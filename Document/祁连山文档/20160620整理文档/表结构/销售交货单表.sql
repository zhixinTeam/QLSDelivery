
GO

/****** Object:  Table [dbo].[S_Bill]    Script Date: 06/20/2016 23:11:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[S_Bill](
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[L_ID] [varchar](20) NULL,
	[L_Card] [varchar](16) NULL,
	[L_ZhiKa] [varchar](15) NULL,
	[L_Project] [varchar](100) NULL,
	[L_Area] [varchar](50) NULL,
	[L_CusID] [varchar](15) NULL,
	[L_CusName] [varchar](80) NULL,
	[L_CusPY] [varchar](80) NULL,
	[L_CusAccount] [varchar](30) NULL,
	[L_SaleID] [varchar](15) NULL,
	[L_SaleMan] [varchar](32) NULL,
	[L_Type] [char](1) NULL,
	[L_StockNo] [varchar](20) NULL,
	[L_StockName] [varchar](80) NULL,
	[L_Value] [decimal](15, 5) NULL,
	[L_Price] [decimal](15, 5) NULL,
	[L_ZKMoney] [char](1) NULL,
	[L_Truck] [varchar](15) NULL,
	[L_Status] [char](1) NULL,
	[L_NextStatus] [char](1) NULL,
	[L_InTime] [datetime] NULL,
	[L_InMan] [varchar](32) NULL,
	[L_PValue] [decimal](15, 5) NULL,
	[L_PDate] [datetime] NULL,
	[L_PMan] [varchar](32) NULL,
	[L_MValue] [decimal](15, 5) NULL,
	[L_MDate] [datetime] NULL,
	[L_MMan] [varchar](32) NULL,
	[L_LadeTime] [datetime] NULL,
	[L_LadeMan] [varchar](32) NULL,
	[L_LadeLine] [varchar](15) NULL,
	[L_LineName] [varchar](32) NULL,
	[L_DaiTotal] [int] NULL,
	[L_DaiNormal] [int] NULL,
	[L_DaiBuCha] [int] NULL,
	[L_TransID] [varchar](32) NULL,
	[L_TransName] [varchar](32) NULL,
	[L_Searial] [varchar](32) NULL,
	[L_OutFact] [datetime] NULL,
	[L_OutMan] [varchar](32) NULL,
	[L_Lading] [char](1) NULL,
	[L_IsVIP] [varchar](1) NULL,
	[L_Seal] [varchar](100) NULL,
	[L_HYDan] [varchar](15) NULL,
	[L_Man] [varchar](32) NULL,
	[L_Date] [datetime] NULL,
	[L_DelMan] [varchar](32) NULL,
	[L_DelDate] [datetime] NULL,
	[L_NewSendWx] [char](1) NULL,
	[L_DelSendWx] [char](1) NULL,
	[L_OutSendWx] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


