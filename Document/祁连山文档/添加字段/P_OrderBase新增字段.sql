ALTER TABLE P_OrderBase
ADD
   B_RecID bigint not null default ((0)), 
   B_Blocked int not null default((0)),
   DATAAREAID varChar(3)