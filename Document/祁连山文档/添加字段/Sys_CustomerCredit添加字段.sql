alter table Sys_CustomerCredit
add
   C_CustName varChar(50), 
   C_CashBalance Decimal(15,5), 
   C_BillBalance3M Decimal(15,5), 
   C_BillBalance6M Decimal(15,5), 
   C_PrestigeQuota Decimal(15,5), 
   C_TemporBalance Decimal(15,5), 
   C_TemporAmount Decimal(15,5), 
   C_WarningAmount Decimal(15,5), 
   C_TemporTakeEffect Decimal(15,5), 
   C_FailureDate DateTime, 
   DataAreaID varChar(3),
   C_LSCreditNum varChar(20),
   C_PrestigeStatus char(1)