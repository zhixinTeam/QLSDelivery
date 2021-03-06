USE [AX20160530]
GO

/****** Object:  Table [dbo].[INVENTTABLE]    Script Date: 2016/6/20 10:50:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[INVENTTABLE](
	[ITEMGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[ITEMID] [nvarchar](20) NOT NULL DEFAULT (''),
	[ITEMNAME] [nvarchar](60) NOT NULL DEFAULT (''),
	[ITEMTYPE] [int] NOT NULL DEFAULT ((0)),
	[PURCHMODEL] [int] NOT NULL DEFAULT ((0)),
	[HEIGHT] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[WIDTH] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SALESMODEL] [int] NOT NULL DEFAULT ((0)),
	[DEL_COSTGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[REQGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[EPCMANAGER] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[PRIMARYVENDORID] [nvarchar](20) NOT NULL DEFAULT (''),
	[NETWEIGHT] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[DEPTH] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[UNITVOLUME] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[BOMUNITID] [nvarchar](20) NOT NULL DEFAULT (''),
	[DENSITY] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[DIMENSION] [nvarchar](20) NOT NULL DEFAULT (''),
	[DIMENSION2_] [nvarchar](20) NOT NULL DEFAULT (''),
	[DIMENSION3_] [nvarchar](20) NOT NULL DEFAULT (''),
	[DIMENSION4_] [nvarchar](20) NOT NULL DEFAULT (''),
	[COSTMODEL] [int] NOT NULL DEFAULT ((0)),
	[USEALTITEMID] [int] NOT NULL DEFAULT ((0)),
	[ALTITEMID] [nvarchar](20) NOT NULL DEFAULT (''),
	[PRODFLUSHINGPRINCIP] [int] NOT NULL DEFAULT ((0)),
	[PBAITEMAUTOGENERATED] [int] NOT NULL DEFAULT ((0)),
	[BOMMANUALRECEIPT] [int] NOT NULL DEFAULT ((0)),
	[STOPEXPLODE] [int] NOT NULL DEFAULT ((0)),
	[PHANTOM] [int] NOT NULL DEFAULT ((0)),
	[BOMLEVEL] [int] NOT NULL DEFAULT ((0)),
	[BATCHNUMGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[AUTOREPORTFINISHED] [int] NOT NULL DEFAULT ((0)),
	[PRODPOOLID] [nvarchar](20) NOT NULL DEFAULT (''),
	[ABCTIEUP] [int] NOT NULL DEFAULT ((0)),
	[ABCREVENUE] [int] NOT NULL DEFAULT ((0)),
	[ABCVALUE] [int] NOT NULL DEFAULT ((0)),
	[ABCCONTRIBUTIONMARGIN] [int] NOT NULL DEFAULT ((0)),
	[SALESPERCENTMARKUP] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SALESCONTRIBUTIONRATIO] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SALESPRICEMODELBASIC] [int] NOT NULL DEFAULT ((0)),
	[MINAVERAGESETTLE] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[NAMEALIAS] [nvarchar](60) NOT NULL DEFAULT (''),
	[PRODGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[PROJCATEGORYID] [nvarchar](10) NOT NULL DEFAULT (''),
	[GROSSDEPTH] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[GROSSWIDTH] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[GROSSHEIGHT] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SORTCODE] [int] NOT NULL DEFAULT ((0)),
	[SERIALNUMGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[DIMGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[MODELGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[ITEMBUYERGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[TAXPACKAGINGQTY] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[DEL_STOPEXPLODEPRICE] [int] NOT NULL DEFAULT ((0)),
	[WMSPICKINGQTYTIME] [int] NOT NULL DEFAULT ((0)),
	[TARAWEIGHT] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SCRAPVAR] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[SCRAPCONST] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[ITEMDIMCOMBINATIONAUTOCREATE] [int] NOT NULL DEFAULT ((0)),
	[ITEMDIMCOSTPRICE] [int] NOT NULL DEFAULT ((0)),
	[ITEMIDCOMPANY] [nvarchar](20) NOT NULL DEFAULT (''),
	[BOMCALCGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[QCGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[QCUNITID] [nvarchar](20) NOT NULL DEFAULT (''),
	[WEIGHNING] [int] NOT NULL DEFAULT ((0)),
	[PACKTYPE] [int] NOT NULL DEFAULT ((0)),
	[TOLERANCERIVISEGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[PACKUNIT] [nvarchar](20) NOT NULL DEFAULT (''),
	[DETUCHWEIGHT] [int] NOT NULL DEFAULT ((0)),
	[DEFUALTMOISTURERATE] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[CMT_TOLERANCEREVISEGROUPID] [nvarchar](20) NOT NULL DEFAULT (''),
	[CMT_PURCHUNIT] [nvarchar](20) NOT NULL DEFAULT (''),
	[CMT_REMOVEWATERRATE] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[CMT_COUNTPROD] [int] NOT NULL DEFAULT ((0)),
	[CMT_TRADEGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[CMT_OLDNAME] [nvarchar](60) NOT NULL DEFAULT (''),
	[CMT_OLDACCOUNTNUM] [nvarchar](20) NOT NULL DEFAULT (''),
	[CMT_TYPECODE] [nvarchar](40) NOT NULL DEFAULT (''),
	[CMT_INTENSIONRATE] [nvarchar](10) NOT NULL DEFAULT (''),
	[CMT_SYMBOL] [nvarchar](10) NOT NULL DEFAULT (''),
	[CMT_PRODJORDANPARM] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[CMT_ITEMMATERIAL] [nvarchar](16) NOT NULL DEFAULT (''),
	[CMT_CONSIGNDEPARTMENT] [nvarchar](20) NOT NULL DEFAULT (''),
	[PROQTY_THISMONTHPHYSICAL] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[PROQTY_THISYEARACCUMULATE] [numeric](28, 12) NOT NULL DEFAULT ((0)),
	[CMT_APPROVEDBY] [nvarchar](10) NOT NULL DEFAULT (''),
	[CMT_APPROVED] [int] NOT NULL DEFAULT ((0)),
	[CMT_WF_APPROVEDSTATUS] [int] NOT NULL DEFAULT ((0)),
	[CMT_QCGROUPID] [nvarchar](10) NOT NULL DEFAULT (''),
	[CMT_QCUNITID] [nvarchar](20) NOT NULL DEFAULT (''),
	[CMT_CKWZ] [nvarchar](60) NOT NULL DEFAULT (''),
	[XTCONSOLIDATEDCODE] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTMODELTYPE] [nvarchar](60) NOT NULL DEFAULT (''),
	[XTTECHNICALREQUEST] [nvarchar](60) NOT NULL DEFAULT (''),
	[XTMATERIAL] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTCATEGORYLV1] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTCATEGORYLV2] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTCATEGORYLV3] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTSIGMENTIDLV1] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTSIGMENTIDLV2] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTSIGMENTIDLV3] [nvarchar](20) NOT NULL DEFAULT (''),
	[XTCONSOLIDATEDNAME] [nvarchar](60) NOT NULL DEFAULT (''),
	[XTITEMUSAGESTATUS] [int] NOT NULL DEFAULT ((0)),
	[XTPURPOSE] [nvarchar](60) NOT NULL DEFAULT (''),
	[MODIFIEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[MODIFIEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT ('1900-01-01 00:00:00.000'),
	[CREATEDBY] [nvarchar](5) NOT NULL DEFAULT ('?'),
	[DATAAREAID] [nvarchar](3) NOT NULL DEFAULT ('dat'),
	[RECVERSION] [int] NOT NULL DEFAULT ((1)),
	[RECID] [bigint] NOT NULL,
 CONSTRAINT [I_175ITEMIDX] PRIMARY KEY CLUSTERED 
(
	[DATAAREAID] ASC,
	[ITEMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[INVENTTABLE]  WITH CHECK ADD CHECK  (([RECID]<>(0)))
GO

