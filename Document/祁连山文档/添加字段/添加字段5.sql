ALTER TABLE S_Bill
ADD
   L_JXSTHD varchar(20),
   L_HYPrint int not null default 0,
   L_BDPrint int not null default 0
 
ALTER TABLE S_BillBak
ADD
   L_JXSTHD varchar(20),
   L_HYPrint int not null default 0,
   L_BDPrint int not null default 0
    
      