
GO

/****** Object:  Table [dbo].[P_Order]    Script Date: 06/20/2016 23:09:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[P_Order](
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[O_ID] [varchar](20) NULL,
	[O_BID] [varchar](20) NULL,
	[O_Card] [varchar](16) NULL,
	[O_CType] [varchar](1) NULL,
	[O_Value] [decimal](15, 5) NULL,
	[O_Area] [varchar](50) NULL,
	[O_Project] [varchar](100) NULL,
	[O_ProID] [varchar](32) NULL,
	[O_ProName] [varchar](80) NULL,
	[O_ProPY] [varchar](80) NULL,
	[O_SaleID] [varchar](32) NULL,
	[O_SaleMan] [varchar](80) NULL,
	[O_SalePY] [varchar](80) NULL,
	[O_Type] [char](1) NULL,
	[O_StockNo] [varchar](32) NULL,
	[O_StockName] [varchar](80) NULL,
	[O_Truck] [varchar](15) NULL,
	[O_OStatus] [char](1) NULL,
	[O_Man] [varchar](32) NULL,
	[O_Date] [datetime] NULL,
	[O_DelMan] [varchar](32) NULL,
	[O_DelDate] [datetime] NULL,
	[O_Memo] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


