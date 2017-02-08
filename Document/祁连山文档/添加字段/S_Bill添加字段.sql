alter table S_Bill
add
   P_PStation varChar(10), 
   P_MStation varChar(10), 
   L_PID varChar(15),
   L_LineNum numeric(28, 12) not null Default ((0)),
   L_LineRecID bigint,
   L_InvLocationId varChar(20),
   L_InvCenterId varChar(20),
   L_PlanQty numeric(28, 12) not null Default ((0)),
   L_CW varChar(10),
   L_Transporter varChar(20),
   L_vendpicklistid varChar(60),
   L_FYAX Char(1) not null default((0)),
   L_BDAX Char(1) not null default((0)),
   Z_ZkType int
   