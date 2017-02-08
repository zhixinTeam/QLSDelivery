alter table S_Bill
add
   L_FYDEL Char(1) not null default((0)),
   L_FYDELNUM int not null default((0))
   
alter table S_BillBak
add
   L_FYDEL Char(1) not null default((0)),
   L_FYDELNUM int not null default((0))
   