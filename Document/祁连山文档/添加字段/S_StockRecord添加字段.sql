alter table S_StockRecord
add
   R_BatQuaStart decimal(15,5),
   R_BatQuaEnd decimal(15,5),
   R_BatValid char(1) not null default('N')