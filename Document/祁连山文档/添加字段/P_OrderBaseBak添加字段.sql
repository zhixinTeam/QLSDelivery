ALTER TABLE P_OrderBaseBak
ADD
   B_RecID bigint not null default ((0)), 
   B_Blocked int not null default((0)),
   DATAAREAID varChar(3)