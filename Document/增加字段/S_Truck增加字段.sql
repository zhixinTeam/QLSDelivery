ALTER TABLE S_Truck
ADD
   T_SaleID varChar(20), T_RecID bigint not null default ((0)),
   T_MatePID varChar(15), T_MateID varChar(15), T_MateName varChar(80),
   T_SrcAddr varChar(150), T_DestAddr varChar(150),
   T_Card2 varChar(32)