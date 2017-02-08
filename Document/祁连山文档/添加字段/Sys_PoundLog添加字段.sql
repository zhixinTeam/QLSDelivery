ALTER TABLE Sys_PoundLog
ADD
   P_KWDate datetime,
   P_HisPValue decimal(15,5),
   P_HisTruck varchar(15)
   
ALTER TABLE Sys_PoundBak
ADD
   P_KWDate datetime,
   P_HisPValue decimal(15,5),
   P_HisTruck varchar(15)
   