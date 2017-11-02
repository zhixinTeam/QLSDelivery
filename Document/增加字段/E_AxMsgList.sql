
GO

/****** Object:  Table [dbo].[E_AxMsgList]    Script Date: 04/26/2017 15:42:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[E_AxMsgList](
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[AX_ProcessId] [varchar](30) NULL,
	[AX_Recid] [varchar](30) NULL,
	[AX_CompanyId] [varchar](30) NULL,
	[AX_Status] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


