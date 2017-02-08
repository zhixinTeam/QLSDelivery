alter table S_ContractExt
add
   E_RecID bigint not null default ((0)),
   DataAreaID varChar(3) not null default ('dat')