alter table S_Contract
add
   C_CustName varChar(60),
   C_SFSP int not null default((0)),
   C_ContType int not null default((0)),
   C_ContQuota int not null default((0)), 
   DataAreaID varChar(3) not null default('dat')