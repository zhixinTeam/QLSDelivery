alter table S_ZhiKa
add 
   Z_SalesStatus int not null Default ((0)),
   Z_SalesType int not null Default ((0)),
   Z_TriangleTrade int not null Default ((0)), 
   Z_OrgAccountNum varChar(20),
   Z_XSQYBM varChar(10) ,
   DataAreaID varChar(3) not null DEFAULT ('dat'),
   D_Blocked int not null default((0)),
   Z_IntComOriSalesId varChar(20),
   Z_PurchType int,
   Z_CompanyId varchar(3),
   Z_OrgAccountName varChar(120),
   Z_OrgXSQYMC varChar(20)