USE [ZXDB]
GO

/****** Object:  StoredProcedure [dbo].[OutputData]    Script Date: 04/20/2017 10:45:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_InOutFactoryTotal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_InOutFactoryTotal]
GO

USE [ZXDB]
GO

/****** Object:  StoredProcedure [dbo].[SP_InOutFactoryTotal]    Script Date: 04/20/2017 10:45:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--by lih 2017-4-20 进出厂量统计
CREATE PROCEDURE   [dbo].[SP_InOutFactoryTotal]     
  @nType varchar(10),
  @nStartDate varchar(50),
  @nEndDate varchar(50)      
AS      
begin
 if @nType = 'S' --销售出厂
 begin
   select L_StockName as StockName,
            Count(R_ID) as TruckCount,
            SUM(L_Value) as StockValue from S_Bill
            where L_OutFact >=@nStartDate and L_OutFact <=@nEndDate and L_IfNeiDao='N' group by L_StockName
   union
   select '内部倒运' as StockName,
            Count(R_ID) as TruckCount,
            SUM(L_Value) as StockValue from S_Bill
            where L_OutFact >=@nStartDate and L_OutFact <=@nEndDate 
            and L_IfNeiDao='Y'
 end
 if @nType = 'SZ' --销售过磅中
 begin
   select L_StockName as StockName,
            Count(R_ID) as TruckCount,
            SUM(L_Value) as StockValue from S_Bill
            where L_InTime >=@nStartDate and L_InTime <=@nEndDate 
            and L_IfNeiDao='N' and L_Status <> 'O' 
            group by L_StockName
   union
   select '内部倒运' as StockName,
            Count(R_ID) as TruckCount,
            SUM(L_Value) as StockValue from S_Bill
            where L_Date >=@nStartDate and L_Date <=@nEndDate 
            and L_IfNeiDao='Y' and L_Status <> 'O'
 end
 
 if @nType = 'P' --采购出厂
 begin
   select D_StockName as StockName,
            Count(R_ID) as TruckCount,
            SUM(D_Value) as StockValue from P_OrderDtl
            where D_OutFact >=@nStartDate and D_OutFact <=@nEndDate 
            group by D_StockName
 end
 
 if @nType = 'PZ' --采购未出厂
 begin
   select D_StockName as StockName,
            Count(R_ID) as TruckCount,
            SUM(D_Value) as StockValue from P_OrderDtl
            where D_InTime >=@nStartDate and D_InTime <=@nEndDate 
            and D_Status <> 'O'
            group by D_StockName
 end
end    

  

GO


