GO

/****** Object:  Table [dbo].[E_AxPlanInfo]    Script Date: 09/15/2017 11:06:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[E_AxPlanInfo](
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[AX_PLANQTY] [decimal](15, 5) NULL,
	[AX_VEHICLEId] [varchar](30) NULL,
	[AX_ITEMID] [varchar](30) NULL,
	[AX_ITEMNAME] [varchar](50) NULL,
	[AX_ITEMTYPE] [varchar](10) NULL,
	[AX_ITEMPRICE] [decimal](15, 5) NULL,
	[AX_CUSTOMERID] [varchar](30) NULL,
	[AX_CUSTOMERNAME] [varchar](400) NULL,
	[AX_TRANSPORTER] [varchar](50) NULL,
	[AX_TRANSPLANID] [varchar](50) NULL,
	[AX_SALESID] [varchar](50) NULL,
	[AX_SALESLINERECID] [bigint] NULL,
	[AX_COMPANYID] [varchar](30) NULL,
	[AX_Destinationcode] [varchar](32) NULL,
	[AX_WMSLocationId] [varchar](32) NULL,
	[AX_FYPlanStatus] [varchar](32) NULL,
	[AX_InventLocationId] [varchar](32) NULL,
	[AX_xtDInventCenterId] [varchar](32) NULL,
PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


