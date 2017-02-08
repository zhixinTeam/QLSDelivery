alter table S_ZhiKaDtl
add
   D_LineNum numeric(28, 12) not null Default ((0)),
   D_RECID bigint not null default((0)),
   D_SalesStatus int not null Default((0)), 
   DATAAREAID varChar(3) not null DEFAULT ('dat'),  
   D_Blocked int not null default((0))