ALTER TABLE S_Bill
ADD
  L_EOUTAX Char(1) not null default((0)),
  L_EOUTNUM int not null default((0))
  
ALTER TABLE S_BillBak
ADD
  L_EOUTAX Char(1) not null default((0)),
  L_EOUTNUM int not null default((0))
  