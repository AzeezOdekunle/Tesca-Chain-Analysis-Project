create database TescaOltp
create database TescaStaging
create database TescaEdw
create database TescaControl

select count(*) from hr.Absent_data
select count(*) from [edw].[fact_HRAbsent]
select count(*) from [hr].[AbscentCategory]
select count(*) from [edw].[dimAbsentCategory]
select * from PurchaseTransaction
select * from SalesTransaction

select min(transDate)  MinPurTrans, max(TransDate)as maxPurTrans from purchasetransaction
select min(transDate) MinSalesTrans, max(TransDate)as maxSalesTrans from SalesTransaction


select min(OrderDate)  MinPurTrans, max(OrderDate)as maxPurTrans from purchasetransaction
select min(OrderDate) MinSalesTrans, max(OrderDate)as maxSalesTrans from SalesTransaction


select min(DeliveryDate)  MinPurTrans, max(DeliveryDate)as maxPurTrans from purchasetransaction
select min(DeliveryDate) MinSalesTrans, max(DeliveryDate)as maxSalesTrans from SalesTransaction

select min(ShipDate)  MinPurTrans, max(ShipDate)as maxPurTrans from purchasetransaction
---select min(ShipDate) MinSalesTrans, max(ShipDate)as maxSalesTrans from SalesTransaction		--  No shipDate


--select max(transdate) = dateadd(year,2,(select max(transdate) from PurchaseTransaction))

update PurchaseTransaction
set
TransDate = dateadd(year,3,transdate),
Orderdate = dateadd(year,3,orderdate),
DeliveryDate = dateadd(year,3,DeliveryDate),
ShipDate = dateadd(year,3, shipdate)

update PurchaseTransaction
set
TransDate = dateadd(year,-1,transdate),
Orderdate = dateadd(year,-1,orderdate),
DeliveryDate = dateadd(year,-1,DeliveryDate),
ShipDate = dateadd(year,-1, shipdate) where TransactionID <=50
and year(transdate) = '2016'

update SalesTransaction
set
TransDate = dateadd(year,2,transdate),
OrderDate = dateadd(year,2,Orderdate),
DeliveryDate= dateadd(year,2,DeliveryDate) 

create schema oltp
create schema oltp
create schema hr

---						PRODUCT

select p.productid, p.Product,p.ProductNumber, p.UnitPrice, d.Department, getdate() as LoadDate from Product p inner join department d on
p.DepartmentID=d.DepartmentID

select count(*) as OltpCount from Product p inner join department d on p.DepartmentID=d.DepartmentID

use TescaStaging


if object_id ('oltp.product') is not null
Truncate table oltp.product

--select object_id('oltp.product')

create table oltp.product (
ProductID int,
Product nvarchar (250),
ProductNumber nvarchar(250),
Department nvarchar (250),
UnitPrice float,
Loaddate datetime default getdate(),
constraint oltp_product_pk primary key (productid) )

select p.ProductID, p.Product, p.ProductNumber, p.Department, p.UnitPrice from oltp.product p
select count(*) as StageCount from oltp.product

select count(*) as CurrentCount from oltp.product   -- reps StageCount (Data coming from) Edw

use TescaEdw

--create schema edw


create table edw.dimProduct(
productsk int identity(1,1),
productID int,
product nvarchar (250),
ProductNumber nvarchar (250),
Department nvarchar (250),
Unitprice float,
EffectiveStartDate datetime,
EffectiveEndDate datetime,
constraint edw_dimProduct_sk primary key(productsk) )

select count(*) as PreCount from edw.dimProduct
select count(*) as PostCount from edw.dimProduct

---     STORE				Note: To rename 'StreetAddress to 'StoreAddress', to be included in STM template

use TescaOltp
select s.StoreID,s.storeName as Store, s.StreetAddress as StoreAddress, c.cityname as City,st.state, getdate() as LoadDate
from store s inner join city c on s.CityID=c.CityID inner join State st on c.StateID = st.StateID

select count(*) as OltpCount from store s inner join city c on s.CityID=c.CityID inner join State st on c.StateID = st.StateID

use TescaStaging

if object_id('oltp.Store') is not null
truncate table oltp.Store


create table oltp.Store(
StoreID int,
Store nvarchar(50),
StoreAddress nvarchar(50),
City nvarchar (50),
State nvarchar (50),
LoadDate datetime default getdate(),
constraint oltp_store_pk primary key (StoreID) )

select StoreID, Store, StoreAddress, City, State from oltp.Store 

select count(*) as StageCount from oltp.Store

use TescaEdw

create table edw.dimStore(
Storesk int identity(1,1),
StoreID int,
Store nvarchar(50),
StoreAddress nvarchar(50),
City nvarchar (50),
State nvarchar (50),
EffectiveStartDate datetime,
constraint edw_dimStore_sk primary key(Storesk) )


--         PROMOTION

select p.promotionID, p.StartDate as PromotionStartDate, p.EndDate as PromotionEndDate, pt.promotion, p.DiscountPercent, getdate() as loaddate
from promotion p
inner join promotiontype pt on p.promotiontypeid = pt.promotiontypeid

select count(*) as OltpCount from promotion p
inner join promotiontype pt on p.promotiontypeid = pt.promotiontypeid


use TescaStaging

if object_id('oltp.Promotion') is not null
truncate table oltp.Promotion

create table oltp.Promotion(
PromotionID int,
Promotion nvarchar (50),
PromotionStartDate datetime,
PromotionEndDate datetime,
DiscountPercent float,
LoadDate datetime default getdate(),
constraint oltp_promotion_pk primary key (PromotionID) )

select PromotionID, Promotion, PromotionStartDate, PromotionEndDate, DiscountPercent from oltp.Promotion

select count(*) as StageCount from oltp.Promotion


create table edw.dimPromotion(
Promotionsk int identity(1,1),
PromotionID int,
Promotion nvarchar (50),
PromotionStartDate datetime,
PromotionEndDate datetime,
DiscountPercent float,
EffectiveStartDate datetime,
constraint edw_dimPromotion_sk primary key (Promotionsk) )


----						CUSTOMER

select c.customerId, c.FirstName,c.LastName, c.CustomerAddress, ct.CityName as City, 
s.state, getdate() as LoadDate from customer c inner join city ct on c.cityID = ct.cityID inner join State s on ct.StateID = s.stateID

-- Concat - Biz rule
select c.customerId, concat(c.FirstName,',',c.LastName) as CustomerName, c.CustomerAddress, ct.CityName as City, 
s.state, getdate() as LoadDate from customer c inner join city ct on c.cityID = ct.cityID inner join State s on ct.StateID = s.stateID

select count(*) as OltpCount from customer c inner join city ct on c.cityID = ct.cityID inner join State s on ct.StateID = s.stateID

use TescaStaging

if object_id('oltp.Customer') is not null
truncate table oltp.customer

create table oltp.customer(
CustomerID int,
CustomerName nvarchar (50),
CustomerAddress nvarchar(50),
City nvarchar(50),
State nvarchar(50),
LoadDate datetime default getdate(),
constraint oltp_customer_pk primary key (customerID) )

select count(*) as StageCount from oltp.customer

select CustomerID, CustomerName, CustomerAddress, City, State from oltp.customer


use TescaEdw

create table edw.dimCustomer(
Customersk int identity(1,1),
CustomerID int,
CustomerName nvarchar (50),
CustomerAddress nvarchar(50),
City nvarchar(50),
State nvarchar(50),
EffectiveStartDate datetime,
constraint edw_dimCustomer_sk primary key (customersk) )



---				POS Channel
select p.channelID, P.ChannelNo, p.DeviceModel, p.SerialNo, p.installationDate, getdate() as LoadDate from poschannel p

select count(*) as OltpCount from poschannel p



use TescaStaging

if object_id('oltp.POSChannel') is not null
truncate table oltp.POSChannel

Create table Oltp.POSChannel(
ChannelID int,
ChannelNo nvarchar (50),
DeviceModel nvarchar(50),
SerialNo nvarchar(50),
InstallationDate Datetime,
LoadDate datetime default getdate(),
constraint oltp_POSChannel_pk primary key(ChannelID) )

select ChannelID, ChannelNo, DeviceModel, SerialNo, InstallationDate from oltp.POSChannel

select count(*) as StageCount from Oltp.POSChannel



use TescaEdw

create table edw.dimPOSChannel(
Channelsk int identity(1,1),
ChannelID int,
ChannelNo nvarchar (50),
DeviceModel nvarchar(50),
SerialNo nvarchar(50),
InstallationDate Datetime,
EffectiveStartDate datetime,
EffectiveEndDate datetime,
constraint edw_dimPOSChannel_sk primary key (Channelsk) )

select count(*) as PreCount from edw.dimPOSChannel
select count(*) as PostCount from edw.dimPOSChannel



----					 Employee

use TescaOltp

select e.EmployeeID, e.LastName, e.FirstName, e.EmployeeNo, e.DoB as DateofBirth, getdate() as loaddate
, m.MaritalStatus from Employee e
inner join MaritalStatus m on m.MaritalStatusID = e.MaritalStatus

--Concat Biz rule
select e.EmployeeID, concat(Upper (e.LastName), ' , ',e.FirstName) as EmployeeName,e.EmployeeNo, e.DoB as DateofBirth, getdate() as loaddate
, m.MaritalStatus from Employee e
inner join MaritalStatus m on m.MaritalStatusID = e.MaritalStatus

select count(*) as OltpCount from Employee e inner join MaritalStatus m on m.MaritalStatusID = e.MaritalStatus

use TescaStaging

if object_id('oltp.Employee') is not null
truncate table oltp.Employee

create table oltp.Employee(
EmployeeID int,
EmployeeName nvarchar(250),
EmployeeNo nvarchar(250),
MaritalStatus nvarchar(250),
DateofBirth date,
loadDate datetime default getdate(),
constraint oltp_Employee_pk primary key (Employeeid) )

select EmployeeID, EmployeeName, EmployeeNo, MaritalStatus, DateofBirth from oltp.Employee

select count(*) as StageCount from oltp.Employee

use TescaEdw

create table edw.dimEmployee(
Employeesk int identity(1,1),
EmployeeID int,
EmployeeName nvarchar(250),
EmployeeNo nvarchar(250),
MaritalStatus nvarchar(250),
DateofBirth date,
EffectiveStartDate datetime,
EffectiveEndDate datetime,
constraint edw_dimemployee_sk primary key(Employeesk) )


---					VENDOR


select * from vendor

use TescaOltp

SELECT v.VendorID, concat_ws(',', Upper(v.LastName), v.FirstName) as VendorName, v.vendorAddress, v.registrationNo,c.cityName as City, s.state, getdate()
as LoadDate FROM Vendor v inner join city c on v.cityID = c.cityID inner join state s on c.stateid = s.stateID


SELECT v.VendorID, concat(Upper(v.LastName), ',' , v.FirstName) as VendorName, v.vendorAddress, v.registrationNo,c.cityName as City, s.state, getdate()
as LoadDate FROM Vendor v inner join city c on v.cityID = c.cityID inner join state s on c.stateid = s.stateID

SELECT v.VendorID, Upper(v.LastName), v.FirstName as VendorName FROM Vendor v

select count(*) as OltpCount FROM Vendor v inner join city c on v.cityID = c.cityID inner join state s on c.stateid = s.stateID

use TescaStaging
select v.vendorname, v.city s.state
if object_id ('oltp.Vendor') is not null
truncate table oltp.Vendor

create table Oltp.Vendor(
VendorID int,
VendorName nvarchar(250),
City nvarchar(250),
State nvarchar (250),
VendorAddress nvarchar(250),
RegistrationNo nvarchar(250),
LoadDate datetime default getdate(),
constraint oltp_Vendor_pk primary key (VendorID) )

select VendorID, VendorName, City, state, VendorAddress, RegistrationNo from oltp.Vendor

select * from oltp.Vendor

use TescaEdw


create table edw.dimVendor(
Vendorsk int identity(1,1),
VendorID int,
VendorName nvarchar(250),
City nvarchar(250),
State nvarchar(250),
VendorAddress nvarchar(250),
RegistrationNo nvarchar (250),
EffectiveStartDate datetime,
EffectiveEndDate datetime,
constraint oltp_dimVendor_sk primary key (Vendorsk) )

select count(*) as Precount from edw.dimVendor
select count(*) as PostCount from edw.dimVendor



----						Misconduct     >> FlatFile: To be loaded directly into Staging

misconductid,miscoductdesc

use TescaStaging

if object_id('hr.misconduct') is not null
truncate table hr.misconduct

create table hr.misconduct(
id int identity(1,1),
misconductid int,
misconductdesc nvarchar(250),
LoadDate datetime default getdate(),
constraint hr_misconduct_pk primary key(id) )

select count(*)as StageCount from hr.misconduct

select id,misconductid, misconductdesc from hr.misconduct where id in (select max(id) from hr.misconduct group by misconductid) 
--Data to be loaded to the edw


use TescaEdw

create table edw.dimMisconduct(
Misconductsk int identity(1,1),
Misconductid int,
Misconductdesc nvarchar(250),
EffectiveStartDate datetime,
constraint edw_dimMisconduct_sk primary key(Misconductsk) )

select count(*) as PreCount from edw.dimMisconduct
select count(*) as PostCount from edw.dimMisconduct



----				DECISION

--decision_id,decision

use TescaStaging

if object_id('hr.decision') is not null
truncate table hr.decision

create table hr.decision(
id int identity(1,1),
decision_id int, 
decision nvarchar(250),
LoadDate datetime default getdate(),
constraint hr_decision_pk primary key(id) )

select count(*) as StageCount from hr.decision
select * from hr.decision

select decision_id, decision from hr.decision where id in (select max(id) from hr.decision group by decision_id)


use TescaEdw

create table edw.dimDecision(
Decisionsk int identity(1,1),
decision_id int, 
decision nvarchar(250),
EffectiveStartDate datetime,
constraint edw_dimDecision_sk primary key(Decisionsk) )

select count(*) as PreCount from edw.dimDecision
select count(*) as PostCount from edw.dimDecision



---						ABSENT



use TescaStaging
drop table hr.AbscentCategory
if object_id('hr.AbscentCategory') is not null
truncate table hr.AbscentCategory

create table hr.AbscentCategory(
id int identity(1,1),
Categoryid int,
Category nvarchar (250),
LoadDate datetime default getdate(),
constraint hr_AbscentCategory_pk primary key(Categoryid))

select count(*) as StageCount from hr.AbscentCategory

--based on the biz rule; 'First entry is the right data to be retained'    ---Data to be loaded to the edw
select categoryid, category from hr.AbscentCategory where id in (select min(id) from hr.AbscentCategory group by categoryid)


use TescaEdw

create table edw.dimAbsentCategory(
Categorysk int identity(1,1),
Categoryid int,
Category nvarchar (250),
EffectiveStartDate datetime,
constraint edw_dimAbsentCategory_sk primary key(Categorysk))

select count(*) as PreCount from edw.dimAbsentCategory
select count(*) as PostCount from edw.dimAbsentCategory

select count(*) as PreCount from [hr].[Absent_data]
select count(*) as PreCount from [hr].[Misconduct_trans]
select count(*) as PreCount from [hr].[decision]

/*					TIME AND DATE
    Time:

Day Period:	0 - 23 hr

 0-3 >>   Midnight
 4-11 >>  Morning
 12 >>    Noon
 13-15 >> Afternoon
 16-20 >> Evening
 20-23 >> Night

 We want to iterate through this Day Period

 declare @Start int = 0
 while @start <= 23
 Begin 
 print(@start)

*/
 
 create table edw.dimTime(
 HourSk int identity(1,1),
 [Hour] int,
 DayPeriod nvarchar(50),
 EffectiveDate datetime,
 constraint edw_dimTime_sk primary key(HourSk) )


--       Variables and script to derive Time

 declare @StartHour int = 0
 select @StartHour as [Hour]
 while @StartHour <= 23
 Begin
       select CASE
			When @StartHour >= 0 and @StartHour <= 3 THEN 'Midnight'
			When @StartHour >= 4 and @StartHour <= 11 THEN 'Morning'
			When @StartHour = 12 THEN 'Noon'
			When @StartHour >= 13 and @StartHour <= 16 THEN 'Afternoon'
			When @StartHour >= 17 and @StartHour <= 20 THEN 'Evening'
			When @StartHour >= 21 and @StartHour <= 23 THEN 'Night'
			END AS DayPeriod-- getdate() as EffectiveDate,
 set @startHour = @startHour + 1 

 End


--       Insertion to dimTable   

 declare @StartHour int = 0
 select @StartHour as [Hour]
 while @StartHour <= 23
 Begin
  Insert into edw.dimTime ([Hour], DayPeriod , EffectiveDate)
       select @StartHour as [Hour], CASE
			When @StartHour >= 0 and @StartHour <= 3 THEN 'Midnight'
			When @StartHour >= 4 and @StartHour <= 11 THEN 'Morning'
			When @StartHour = 12 THEN 'Noon'
			When @StartHour >= 13 and @StartHour <= 16 THEN 'Afternoon'
			When @StartHour >= 17 and @StartHour <= 20 THEN 'Evening'
			When @StartHour >= 21 and @StartHour <= 23 THEN 'Night'
			END AS DayPeriod, getdate() as EffectiveDate
 set @startHour = @startHour + 1 

 End



 Create Procedure spGenerateTime
 as 
 Begin
 set nocount on
 declare @StartHour int = 0
 select @StartHour as [Hour]
 while @StartHour <= 23

 Begin
  Insert into edw.dimTime ([Hour], DayPeriod , EffectiveDate)
       select @StartHour as [Hour], CASE
			When @StartHour >= 0 and @StartHour <= 3 THEN 'Midnight'
			When @StartHour >= 4 and @StartHour <= 11 THEN 'Morning'
			When @StartHour = 12 THEN 'Noon'
			When @StartHour >= 13 and @StartHour <= 16 THEN 'Afternoon'
			When @StartHour >= 17 and @StartHour <= 20 THEN 'Evening'
			When @StartHour >= 21 and @StartHour <= 23 THEN 'Night'
			END AS DayPeriod, getdate() as EffectiveDate
 set @startHour = @startHour + 1 

 End
 End


 select count(*) from edw.dimTime



 /*
 select Datepart(month, getdate())
  select MONTH(getdate())
 select Year(getdate())
 select DATEPART(DW, GETDAte ())
 select DATEPART(DD, GETDAte ())
 select DATEPART(QQ, GETDAte ())
 select DATEPART(QUARTER, GETDAte ())
 select (date, GETDATE())

 select datepart(hour,getdate())
  select datepart(MINUTE,getdate())
  select MONTH(getdate())

  select DATENAME(DW, getdate())
  select datename(Quarter, getdate())
  select datename(DW, getdate())
  select datename(WEEKDAY, getdate())
  select convert(nvarchar, getdate(),103)
   select convert(nvarchar, getdate(),112)
      select convert(nvarchar(8), getdate(),112)
   select convert(date, getdate(),112)
     select convert(nvarchar(8), getdate())

	 select convert(nvarchar, getdate())
	 select convert(nvarchar, getdate(),112)
	  select convert(date , getdate(),112)

select a.transDate from
	
	(
	select  min(convert(date, getdate()) )from purchaseTrans
	Union
	select  min(convert(date, getdate()) )from SalesTrans) a
*/



--					DATE 


select * from edw.dimDate

create Table edw.dimDate( 
BusinessDateKey int,
BusinessDate Date,
BusinessYear int,
BusinessQuarter nvarchar(50),
BusinessWeekNos int,
EnglishMonthName nvarchar(50),
EnglishMonthNos int,
EnglishDayName nvarchar(50),
EnglishDayNos int,
FrenchMonthName nvarchar(50),
FrenchWeekName nvarchar(50),
EffectiveDate Datetime,
constraint edw_dimDate_sk primary key (BusinessDateKey) )

declare @generateYears int = 70
declare @startDate date =
(
select min( a.mintrans) as MinimumTrans from
(
select min(convert(date,transDate)) as Mintrans from tescaoltp.dbo.SalesTransaction
UNION
select min(convert(date,transDate)) as Mintrans from tescaoltp.dbo.PurchaseTransaction) a )

declare @endDate date = dateadd(Year, @generateYears, datefromparts(year(@startDate),12,31))
declare @nofdays int = datediff(day,@startdate,@endDate)
declare @currentday int = 0
declare @currentDate Date 
while @currentday <= @nofdays
Begin
select @currentdate = dateadd(day,@currentday,@startdate)

insert into edw.dimDate (BusinessDateKey,BusinessDate,BusinessYear,BusinessQuarter,BusinessWeekNos,EnglishMonthName,
         EnglishMonthNos,EnglishDayName,EnglishDayNos,FrenchMonthName,FrenchWeekName,EffectiveDate )

select convert(nvarchar, @currentDate,112) as BusinessDateKey, convert(Date,@currentDate) as BusinessDate, Year(@currentDate) 
as BusinessYear, concat('Q',datepart(Quarter,@currentDate)) as BusinessQuarter, datepart(weekday,@currentdate) as BusinessWeekNos
, datename(month, @currentdate) as EnglishMonthName, datepart(month,@currentdate) as EnglishMonthNos, datename(day,@currentdate)as EnglishDayName, datepart(day,@currentdate) as EnglishDayNos,
 
 case datepart(month,@currentdate)
		When 1 Then 'Janvier' When 2 Then 'Février' When 3 Then 'Mars' When 4 Then 'Avril' When 5 Then 'Mai'
		When 6 Then 'Juin' When 7 Then 'Juillet' When 8 Then 'Août' When 9 Then 'Septembre' When 10 Then 'Octobre'
		When 11 Then 'Novembre' When 12 Then 'Décembre' End as FrenchMonthName,
 case datepart(day,@currentdate)
		When 1 Then 'Lundi' When 2 Then 'Mardi' When 3 Then 'Mercredi' When 4 Then 'Jeudi' When 5 Then 'Vendredi'
		When 6 Then 'Samedi' When 7 Then 'Simanche' End FrenchWeekName, getdate() as EffectiveDate
set @currentday = @currentday + 1

End


select * from edw.dimDate
exec spGetDimDate 5


Alter Procedure spGetDimDate(@generateYears int) 
AS
Begin
set nocount on
--declare @generateYears int 
declare @startDate date =
(
select min( a.mintrans) as MinimumTrans from
(
select min(convert(date,transDate)) as Mintrans from tescaoltp.dbo.SalesTransaction
UNION
select min(convert(date,transDate)) as Mintrans from tescaoltp.dbo.PurchaseTransaction) a )

declare @endDate date = dateadd(Year, @generateYears, datefromparts(year(@startDate),12,31))
declare @nofdays int = datediff(day,@startdate,@endDate)
declare @currentday int = 0
declare @currentDate Date 
while @currentday <= @nofdays
if (select count(*) from edw.dimDate) > 0
truncate table edw.dimDate
Begin
select @currentdate = dateadd(day,@currentday,@startdate)

insert into edw.dimDate (BusinessDateKey,BusinessDate,BusinessYear,BusinessQuarter,BusinessWeekNos,EnglishMonthName,
         EnglishMonthNos,EnglishDayName,EnglishDayNos,FrenchMonthName,FrenchWeekName,EffectiveDate )

select convert(nvarchar, @currentDate,112) as BusinessDateKey, convert(Date,@currentDate) as BusinessDate, Year(@currentDate) 
as BusinessYear, concat('Q',datepart(Quarter,@currentDate)) as BusinessQuarter, datepart(weekday,@currentdate) as BusinessWeekNos
, datename(month, @currentdate) as EnglishMonthName, datepart(month,@currentdate) as EnglishMonthNos, datename(day,@currentdate)as EnglishDayName, datepart(day,@currentdate) as EnglishDayNos,
 
 case datepart(month,@currentdate)
		When 1 Then 'Janvier' When 2 Then 'Février' When 3 Then 'Mars' When 4 Then 'Avril' When 5 Then 'Mai'
		When 6 Then 'Juin' When 7 Then 'Juillet' When 8 Then 'Août' When 9 Then 'Septembre' When 10 Then 'Octobre'
		When 11 Then 'Novembre' When 12 Then 'Décembre' End as FrenchMonthName,
 case datepart(day,@currentdate)
		When 1 Then 'Lundi' When 2 Then 'Mardi' When 3 Then 'Mercredi' When 4 Then 'Jeudi' When 5 Then 'Vendredi'
		When 6 Then 'Samedi' When 7 Then 'Simanche' End FrenchWeekName, getdate() as EffectiveDate
set @currentday = @currentday + 1

End
End
		



		use tescaoltp

--				FactSales
select * from salestransaction

If (select count(*) from TescaEdw.edw.factSales) = 0
Begin
select s.TransactionId, s.TransactionNo, convert(Date,s.TransDate) as TransDate, datepart(Hour, s.Transdate) as TransHour,
convert(Date,s.OrderDate) as OrderDate, datepart(Hour, s.Orderdate) as OrderHour,convert(Date,s.DeliveryDate) as DeliveryDate,
s.ChannelID, s.customerID, s.EmployeeID, s.productID, s.StoreID, s.Quantity, s.taxAmount, s.LineAmount, s.LineDiscountAmount,
getdate() as LoadDate from salestransaction s  where convert(Date,s.transdate) <= dateadd(day,-1, convert(Date, getdate()))
 End
 else
select s.TransactionId, s.TransactionNo, convert(Date,s.TransDate) as TransDate, datepart(Hour, s.Transdate) as TransHour,
convert(Date,s.OrderDate) as OrderDate, datepart(Hour, s.Orderdate) as OrderHour,convert(Date,s.DeliveryDate) as DeliveryDate,
 s.ChannelID, s.customerID, s.EmployeeID, s.productID, s.StoreID, s.Quantity, s.taxAmount, s.LineAmount, s.LineDiscountAmount, 
getdate() as LoadDate from salestransaction s where convert(Date,s.transdate) = dateadd(day,-1, convert(Date,  getdate()) )


If (select count(*) from TescaEdw.edw.factSales) = 0
Begin
select count(*) as OltpCount from salestransaction s  where convert(Date,s.transdate) <= dateadd(day,-1, convert(Date, getdate()))
End
 else
select count(*) as OltpCount from salestransaction s where convert(Date,s.transdate) = dateadd(day,-1, convert(Date,  getdate()) )



use TescaStaging
 drop table oltp.FactSales
if object_id('oltp.FactSales') is not null
truncate table oltp.FactSales

Create table oltp.factsales (

TransactionID int,
TransactionNo nvarchar(250),
TransDate Date,
TransHour int,
OrderDate Date,
OrderHour int,
DeliveryDate Date,
ChannelID int,
CustomerID int,
EmployeeID int,
ProductID int,
StoreID int,
Quantity float,
TaxAmount float,
LineAmount float,
LineDiscountAmount float,
LoadDate Datetime default getDate(),
constraint oltp_factsales_pk primary key (TransactionID) )

select TransactionId, TransactionNo, TransDate, TransHour, OrderDate, OrderHour, DeliveryDate, ChannelID, CustomerID, EmployeeID,
ProductID, StoreID, Quantity, taxAmount, LineAmount, LineDiscountAmount,  getdate() as LoadDate from oltp.FactSales


select TransactionNo, TransDate, TransHour, OrderDate, OrderHour, DeliveryDate, ChannelID, CustomerID, EmployeeID,
ProductID, StoreID, Quantity, taxAmount, LineAmount, LineDiscountAmount,  getdate() as LoadDate from oltp.FactSales


select count(*) as StageCount from oltp.FactSales 
select * from oltp.FactSales


use TescaEdw

--drop table edw.factSales
drop table edw.factSales
create table edw.factSales(
SalesSk bigint identity(1,1),
TransactionNo nvarchar(250),
TransDatesk int,
TransHoursk int,
OrderDatesk int,
OrderHoursk int,
DeliveryDatesk int,
ChannelSk int,
CustomerSk int,
EmployeeSk int,
ProductSk int,
StoreSk int,
Quantity float,
TaxAmount float,
LineAmount float,
LineDiscountAmount float,
LoadDate Datetime default getdate(),
constraint edw_factSales_sk primary key (SalesSk),
constraint edw_factSales_TransDateSk_dimDate foreign key (TransDatesk) references edw.dimDate(BusinessDateKey),
constraint edw_factsales_TransHoursk_dimTime foreign key (TransHoursk) references  edw.dimTime(Hoursk),
constraint edw_factsales_OrderDateSk_dimDate foreign key (OrderDateSk) references edw.dimDate(BusinessDateKey),
constraint edw_factsales_OrderHoursk_dimTime foreign key (orderHourSk) references edw.dimTime(HourSk),
constraint edw_factsales_DeliveryDateSk_dimDate foreign key (DeliveryDateSk) references edw.dimDate(BusinessDateKey),
constraint edw_factsales_ChannelSk_dimPOSChannel foreign key (ChannelSk) references edw.dimPOSChannel(ChannelSk),
constraint edw_factsales_CustomerSk_dimCustomer foreign key (CustomerSk) references edw.dimCustomer(CustomerSk),
constraint edw_factsales_EmployeeSk_dimEmployee foreign key (EmployeeSk) references edw.dimEmployee(EmployeeSk),
constraint edw_factsales_ProductSk_dimProduct foreign key (ProductSk) references edw.dimProduct(ProductSk),
constraint edw_factsales_StoreSk_dimStore foreign key (StoreSk) references edw.dimStore(StoreSk) )

select count(*) as PreCount from edw.factSales
select count(*) as PostCount from edw.factSales

--					FactPurchase


if (select count(*) from TescaEdw.edw.factpurchase) = 0 
Begin
select p.transactionID, p.transactionNo, convert(Date,p.transDate) as TransDate, convert(Date,p.orderDate) as OrderDate, 
convert(Date,p.DeliveryDate) as DeliveryDate, convert(Date,p.shipDate) as ShipDate, vendorID, EmployeeID, ProductID, StoreID, Quantity, 
TaxAmount, LineAmount,datediff(day, orderdate,DeliveryDate) as Deliveryefficiency, getDate() as LoadDate from purchaseTransaction p where p.transDate <= dateadd(day,-1,convert(date,getdate()))
end
else
select p.transactionID, p.transactionNo, convert(Date,p.transDate) as TransDate, convert(Date,p.orderDate) as OrderDate, 
convert(Date,p.DeliveryDate) as DeliveryDate, convert(Date,p.shipDate) as ShipDate, vendorID, EmployeeID, ProductID, StoreID, Quantity, 
TaxAmount, LineAmount, datediff(day, orderdate,DeliveryDate) as Deliveryefficiency, getDate() as LoadDate
from purchaseTransaction p where p.transDate = dateadd(day,-1, convert(date,getdate()))

if (select count(*) from TescaEdw.edw.factpurchase) = 0 
Begin
select count(*) as OltpCount from purchaseTransaction p where p.transDate <= dateadd(day,-1,convert(date,getdate()))
end
else
select count(*) as OltpCount from purchaseTransaction p where p.transDate = dateadd(day,-1, convert(date,getdate()))


--alter column [TransactionID] int null

alter table oltp.purchase 
alter column [TransactionID] int null


use TescaStaging
select * from oltp.purchase
if object_id('oltp.purchase') is not null


create table oltp.purchase (
TransactionID int,
TransactionNo nvarchar(250),
TransDate Date,
OrderDate Date,
DeliveryDate Date,
ShipDate Date,
VendorID int,
EmployeeID int,
ProductID int,
StoreID int,
Quantity float,
TaxAmount float,
LineAmount float,
DeliveryEfficiency int,
LoadDate Datetime default getdate(),
constraint oltp_purchase_pk primary key (transactionID) )

select TransactionNo,TransDate,OrderDate, DeliveryDate, ShipDate,VendorID, EmployeeID, ProductID, StoreID, Quantity,
TaxAmount, LineAmount, DeliveryEfficiency, GetDate() as LoadDate from oltp.purchase

select count(*) as StageCount from oltp.purchase

select * from edw.factpurchase

use TescaEdw

drop table edw.factpurchase 
create table edw.factpurchase (
PurchaseSk bigint identity(1,1),
TransactionID int,
TransactionNo nvarchar(250),
TransDatesk int,
OrderDatesk int,
DeliveryDatesk int,
ShipDatesk int,
Vendorsk int,
Employeesk int,
Productsk int,
Storesk int,
Quantity float,
TaxAmount float,
LineAmount float,
DeliveryEfficiency int,
LoadDate Datetime default getDate () ,
constraint edw_factpurchase_sk primary key (purchaseSk),
constraint edw_factPurchase_TransDateSk_dimDate foreign key (TransDateSk) references edw.dimDate(BusinessDateKey),
constraint edw_factPurchase_OrderDateSk_dimDate foreign key (OrderDateSk) references edw.dimDate(BusinessDateKey),
constraint edw_factPurchase_DeliveryDateSk_dimDate foreign key (DeliveryDateSk) references edw.dimDate(BusinessDateKey),
constraint edw_factPurchase_ShipDateSk_dimDate foreign key(ShipDatesk) references edw.dimDate (BusinessDateKey),
constraint edw_factPurchase_VendorSk_dimVendor foreign key (VendorSk) references edw.dimVendor(VendorSk),
constraint edw_factPurchase_EmployeeSk_dimEmployee foreign key (EmployeeSk) references edw.dimEmployee(EmployeeSk),
constraint edw_factpurchase_ProductSk_dimProduct foreign key (ProductSk) references edw.dimProduct(ProductSk),
Constraint edw_factpurchase_StoreSk_dimStore foreign key (StoreSk) references edw.dimStore(StoreSk) )

select count(*) as PostCount from edw.factpurchase
select count(*) as PreCount from edw.factpurchase


-----		FACTS				Absent Analysis      >> FlatFile
---empid,store,absent_date,absent_hour,absent_category



use TescaStaging

if object_id ('hr.Absent_data') is not null
truncate table hr.Absent_data

create table hr.Absent_data(
AbsentID int identity(1,1),
empid int,
Store int,
Absent_date date,
Absent_hour int,
Absent_Category int,
LoadDate datetime default getdate(),
constraint hr_Absent_data_pk primary key (AbsentID) ) 

select count(*) as StageCount from hr.Absent_data

select AbsentID, EmpID, Store, Absent_Date, Absent_Hour,Absent_Category, getdate() as loadDate from hr.Absent_data
where AbsentID in (select min(AbsentID) from hr.Absent_data Group by empID,Absent_Date,Store)

use TescaEdw

create table edw.fact_HRAbsent(						
Absentsk int identity(1,1),
employeesk int,
Storesk int,
Absentdatesk int,
Absent_hour int,
AbsentCategorysk int,
LoadDate datetime default Getdate(),
constraint edw_fact_HRAbsent_Absent_sk primary key(Absentsk),
constraint edw_fact_HRAbsent_Employeesk foreign key (employeesk) references edw.dimEmployee(Employeesk),
constraint edw_fact_HRAbsent_Storesk foreign key(storesk) references edw.dimStore(Storesk),
constraint edw_fact_HRAbsent_Absentdatesk foreign key (Absentdatesk) references edw.dimDate(Businessdatekey),
constraint edw_fact_HRAbsent_Absentcategorysk foreign key (absentcategorysk) references edw.dimAbsentCategory(categorysk) )


SELECT count(*) as PreCount from edw.fact_HRAbsent
SELECT count(*) as PostCount from edw.fact_HRAbsent


---									MISCONDUCT ANALYSIS
select count(*) as EdwCount from edw.fact_HRMisconduct

use TescaStaging
if object_id('hr.misconduct_trans') is not null
truncate table hr.misconduct_trans

create table hr.Misconduct_trans(
Misconduct_transid int identity(1,1),
EmpID int,
Storeid int,
Misconduct_date date,
Misconduct_id int,
Decision_id int,
LoadDate datetime default getdate(),
constraint hr_Misconduct_trans_pk primary key(misconduct_transid) )

 select count(*) as StageCount from hr.Misconduct_trans

select Misconduct_transid, Empid, storeid,Misconduct_date, Misconduct_id, decision_id, getdate() as LoadDate from hr.Misconduct_trans
where Misconduct_transid in (select max(misconduct_transid) from hr.Misconduct_trans group by EmpID,Storeid,Misconduct_date)


use TescaEdw
--drop table edw.fact_HRMisconduct
select * from edw.fact_HRMisconduct


create table edw.fact_HRMisconduct(				
MisconductTransSk int identity(1,1),
Employeesk int,
Storesk int,
MisconductDatesk int,
Misconductsk int,
Decisionsk int,
LoadDate datetime,
constraint edw_fact_HRMisconduct_sk primary key (MisconductTransSk),
constraint edw_fact_HRMisconduct_EmployeeSk foreign key(EmployeeSk) references edw.dimEmployee(EmployeeSk),
constraint edw_fact_HRMisconduct_Storesk foreign key(Storesk) references edw.dimStore(Storesk),
constraint edw_fact_HRMisconduct_MisconductDatesk foreign key(MisconductDatesk) references edw.dimDate(BusinessDateKey),
constraint edw_fact_HRMisconduct_Misconductsk foreign key (misconductsk) references edw.dimMisconduct(Misconductsk),
constraint edw_fact_HRMisconduct_Decisionsk foreign key (Decisionsk) references edw.dimDecision(decisionsk) )


select count(*) as PreCount from edw.fact_HRMisconduct
select count(*) as CurrentCount from edw.fact_HRMisconduct
select count(*) as PostCount from edw.fact_HRMisconduct

----					OVERTIME
select count(*) as EdwCount from edw.fact_Overtime

use TescaStaging

if object_id('hr.Overtime') is not null
truncate table hr.Overtime

/*
alter table  hr.Overtime
alter column StartOvertime Datetime
alter column EndOvertime Datetime
*/


create table hr.Overtime(
Overtimepk int identity(1,1),
OvertimeID int,
EmployeeNo nvarchar(250),
FirstName nvarchar(250),
LastName nvarchar(250),
StartOvertime Datetime,
EndOverTime Datetime,
LoadDate datetime default getdate(),
constraint hr_Overtime_pk primary key (Overtimepk) )

select * from hr.Overtime
 
--There are duplicates in overtime data. So we need to retain the minimum entry of the duplicate : Removed First & LastName

select overtimeid, employeeno, convert(date,StartOvertime) as OvertimeStartDate, convert(date,EndOvertime) as OvertimeEndDate, 
datediff(hour, StartOverTime, EndOvertime) as OvertimeHour, datepart(hour,startovertime) as OvertimeStartHour, datepart(hour,endovertime)
as OvertimeEndHour, getdate() as LoadDate from hr.Overtime where Overtimepk in (select min(Overtimepk) from hr.Overtime group by employeeno, 
StartOvertime)

select count(*) as StageCount from hr.Overtime where Overtimepk in (select min(Overtimepk) from hr.Overtime group by employeeno, 
StartOvertime)


/*
select count(*)  as OvertimeCount2 from hr.Overtime
select convert(nvarchar,getdate(),112)
select convert(nvarchar, @currentDate,112)

alter table edw.fact_Overtime add OvertimeHour int
drop table edw.fact_Overtime
*/
select * from edw.fact_Overtime
select * from edw.dimTime
use TescaEdw

create table edw.fact_Overtime(					
Overtimesk int identity(1,1),
Employeesk int,								 --- firstName and LastName not included. They are considered as redundant. SA z they can be gotten based on d EmpNo
OvertimeStartDatesk int,									--Note: The columns datatype is gonna be integers bcos they are Surrogate key 
OvertimeEndDatesk int,
OvertimeHour int,
OvertimeStartHoursk int,
OvertimeEndHoursk int,
LoadDate datetime,
constraint edw_fact_Overtime_sk primary key(Overtimesk),
constraint edw_fact_overtime_employeesk foreign key(employeesk) references edw.dimemployee(employeesk),
constraint edw_fact_overtime_StartDatesk foreign key(overtimestartdatesk) references edw.dimdate(businessDateKey),
constraint edw_fact_overtime_EndDatesk foreign key(overtimeEndDatesk) references edw.dimdate(businessDateKey),
constraint edw_fact_overtime_StartHoursk foreign key(overtimestartHoursk) references edw.dimTime(HourSk),
constraint edw_fact_overtime_EndHoursk foreign key(overtimeEndHoursk) references edw.dimTime(HourSk))

select count(*) as PreCount from edw.fact_Overtime
select count(*) as PostCount from edw.fact_Overtime
select * from edw.fact_Overtime





/*
                    CONTROL
It helps to control the activity flow of data during Data migration process. It is responsible for the audit information proce
ssing. It helps to process meta data in the data migration management. It also to trace any failure of data that may occur 
during the ETL pipeline processes.
			
					Types of Control needed:
control.Package
control.PackageType
control.Metrics
control.Environment
control.Anomalies 

*/



create schema control


create table control.Environment (
EnvironmentID int,
Environment nvarchar(50),
constraint control_Environment_pk primary key (EnvironmentID) )

insert into control.Environment(EnvironmentID, Environment)
values (1, 'Staging'), (2, 'Edw')


Create table control.PackageType (
PackageTypeID int,
PackageName nvarchar(50),
constraint control_packagetype_pk primary key(PackageTypeID) )
select * from control.PackageType
insert into control.PackageType (PackageTypeID, PackageName)
values (1, 'Dimension') , (2, 'Fact') 



create table control.Package (
PackageID int,
PackageName nvarchar(50),
EnvironmentID int,
PackageTypeID int,
SequenceID int,
StartDate Date ,
EndDate Date ,
Active bit,
LastRunDate Datetime,
constraint control_Package_pk primary key (PackageID),
constraint control_package_Environment_fk foreign key(EnvironmentID) references control.Environment(EnvironmentID),
constraint control_package_Packagetype_fk foreign key(PackageTypeID) references control.PackageType(PackagetypeID),
constraint control_Package_endate_ck check (enddate >= startDate) )


-- Metrics


create table control.metrics (
MetricsID int identity (1,1),
PackageID int,
oltpCount int,
StageCount int,
Precount int,
currentcount int,
PostCount int,
Type1Count int,
Type2Count int,
RunDate Datetime,
Constraint control_metrics_pk primary key (MetricsID),
Constraint control_metrics_Package_fk foreign key (PackageID) references control.Package(PackageID) )

declare @PackageID int = ?
declare @PreCount int = ?
declare @CurrentCount int = ?
declare @Type1Count int = ?
declare @Type2Count int =  ?
declare @PostCount int = ?
update control.package set lastrundate = getDate() where PackageID = @PackageID
insert into control.metrics (PackageID, Precount, CurrentCount, Type1Count, Type2Count, PostCount, RunDate)
values (@PackageID, @Precount, @CurrentCount, @Type1Count, @Type2Count, @PostCount, GetDate())
select * from control.metrics
update control.package set packageName = 'FactOvertimeAnalysis.dtsx' where PackageID = 30

insert into control.package (PackageID, PackageName, PackageTypeID, EnvironmentID, SequenceID,StartDate, EndDate, Active,LoadName)
values (30, 'FactOvertimeAnalysis.dtsx', 2, 2, 3000, getDate(), '2090-01-01', 1, 'FactHROvertime Edw'),
values (29, 'FactHRMisconductAnalysis.dtsx', 2, 2, 2900, getDate(), '2090-01-01', 1, 'FactHRMisconduct Edw'),
values (28, 'FactHRAbsentAnalysis.dtsx', 2, 2, 2800, getDate(), '2090-01-01', 1, 'FactHRAbsent Edw'),
values (27, 'FactPurchaseAnalysis.dtsx', 2, 2, 2700, getDate(), '2090-01-01', 1, 'FactPurchase Edw'),
values (26, 'FactSalesAnalysis.dtsx', 2, 2, 2600, getDate(), '2090-01-01', 1, 'FactSales Edw'),

values (25, 'dimMisconduct.dtsx', 1, 2, 2500, getDate(), '2090-01-01', 1),
values (24, 'dimAbsentCategory.dtsx', 1, 2, 2400, getDate(), '2090-01-01', 1),
values (23, 'dimDecision.dtsx', 1, 2, 2300, getDate(), '2090-01-01', 1),
values (22, 'dimVendor.dtsx', 1, 2, 2200, getDate(), '2090-01-01', 1),
values (21, 'dimEmployee.dtsx', 1, 2, 2100, getDate(), '2090-01-01', 1),
values (20, 'dimPOSChannel.dtsx', 1, 2, 2000, getDate(), '2090-01-01', 1),
values (19, 'dimCustomer.dtsx', 1, 2, 1900, getDate(), '2090-01-01', 1),
values (18, 'dimPromotion.dtsx', 1, 2, 1800, getDate(), '2090-01-01', 1),
values (17, 'dimStore.dtsx', 1, 2, 1700, getDate(), '2090-01-01', 1),
values (16, 'dimProduct.dtsx', 1, 2, 1600, getDate(), '2090-01-01', 1)


values (15, 'StgOvertime Analysis.dtsx', 2, 1, 1500, getdate(), '2090-01-01', 1)
values (14, 'StgHRMisconduct.dtsx', 2, 1, 1400, getdate(), '2090-01-01', 1)
values (13, 'StgHRAbsentAnaysis.dtsx', 2, 1, 1300, getdate(), '2090-01-01', 1)
values (12, 'StgPurchase.dtsx', 2, 1, 1200, getdate(), '2090-01-01', 1),
values (11, 'StgfactSales.dtsx', 2, 1, 1100, getdate(), '2090-01-01', 1)

select packageName from control.package
values (10, 'StgAbsent.dtsx', 1, 1, 1000, getdate(), '2090-01-01', 1)
values (9, 'StgDecision.dtsx', 1, 1, 900, getdate(), '2090-01-01', 1),
values (8, 'StgMisconduct.dtsx', 1, 1, 800, getdate(), '2090-01-01', 1),
values (7, 'StgVendor.dtsx', 1, 1, 700, getdate(), '2090-01-01', 1)
values (6, 'StgEmployee.dtsx', 1, 1, 600, getdate(), '2090-01-01', 1),
values (5, 'StgPOSChannel.dtsx', 1, 1, 500, getdate(), '2090-01-01', 1),
values (4, 'StgCustomer', 1, 1, 400, getdate(), '2090-01-01', 1)
values (3, 'StgPromotion', 1, 1, 300, getdate(), '2090-01-01', 1)
values (2, 'StgStore', 1, 1, 200, getdate(), '2090-01-01', 1)
values (1, 'StgProduct', 1, 1, 100, getDate(), '2090-01-01',1 )

 select * from control.Package
 
 -- Metrics for Oltp to staging Dimension

 declare @PackageID int = ?
 declare @OltpCount int = ?
 declare @StageCount int = ?
update control.Package set lastrundate = getdate() where packageID = @PackageID     --Update for lastrundate means to have & know the exact time the package was loaded
insert into control.Metrics (PackageID, OltpCount, StageCount, RunDate)
 values (@packageID, @OltpCount, @StageCount, getdate() ) 


 -- Metrics for Oltp to staging Facts : Where is this ? - Ans: Same as Oltp to staging

  -- Metrics for staging to edwDimensions  
																
  declare @PackageID int = ?
  declare @Precount int = ?
  declare @CurrentCount int = ?
  declare @type1Count int = ?
  declare @type2Count int = ?
   declare @PostCount int = ?
update control.Package set lastrundate = getdate where packageID = @PackageID
insert into control.Metrics (PackageID, Precount, CurrentCount,Type1Count, Type2Count, PostCount)
values (@PackageID, @Precount, @CurrentCount, @type1Count, @type2Count, @PostCount)


 -- Metrics for staging to edwFacts

 declare @PackageID int = ?
 declare @StageCount int = ?
 declare @PreCount int = ?
 declare @CurrentCount int = ?
 declare @PostCount int = ?
update control.Package set lastrundate = getdate where packageID = @PackageID
insert into control.Metrics (PackageID, Precount, CurrentCount, PostCount, RunDate)
values (@PackageID, @Precount, @CurrentCount, @PostCount, GetDate())


-- Look up scripts for the load of Dimensions into the Warehouse

select BusinessDateKey, BusinessDate from edw.dimDate
select CategorySk, CategoryID from edw.dimAbsentCategory
select CustomerSk, CustomerID from edw.dimCustomer
select DecisionSk, decision_id from edw.dimDecision
select EmployeeSk, EmployeeID from edw.dimEmployee where EffectiveEndDate is Null
select EmployeeSk, EmployeeNo from edw.dimEmployee where EffectiveEndDate is Null
select MisconductSk, MisconductID from edw.dimMisconduct
select ChannelSk, ChannelID from edw.dimPOSChannel where EffectiveEndDate is Null
select ProductSk, ProductID from edw.dimProduct where EffectiveEndDate is Null
select PromotionSk, PromotionID from edw.dimPromotion
select StoreSk, StoreID from edw.dimStore 
select HourSk, Hour from edw.dimTime
select VendorSk, VendorID from edw.dimVendor
select OvertimeSk, OvertimeID from edw.fact_Overtime

/*						Anomalies Control
To check for the data failure and accountability during the load of Dimensions in the fact table into the warehouse
*/

create table Control.Anomalies (
AnomaliesSk int identity(1,1),
PackageID int,
ColumnName nvarchar(250),
ColumnValue nvarchar(250),
AuditDate Datetime default getDate(),
Constraint control_Anomalies_pk Primary key (AnomaliesSk),
Constraint control_Anomalies_Package_fk foreign key(PackageID) references Control.Package(PackageID) )
select * from  Control.Anomalies


  
--Script to truncate the fact tables, metrics and anomalies

--select 'truncate table' +table_Schema+'.'+Table_name from information_Schema.tables



  --Anomalies script
  select a.AnomaliesSk, a.ColumnValue,p.PackageID, p.PackageName, 
  t.PackageName, e.Environment, p.LastRunDate from control.package p inner join control.anomalies 
  a on p.PackageID = a.PackageID
  inner join control.environment e on p.EnvironmentID = e.EnvironmentID
  inner join control.packagetype t on p.PackageTypeID = t.PackageTypeID

--ControlMetrics script 

  select m.metricsID,P.packageName, m.oltpCount, m.stagecount, m.currentcount, m.Precount,
  m.type1count, m.type2count, m.PostCount,m.rundate,
case 
   when p.packagetypeID = 1 and e.environmentID = 1 and m.oltpcount <> m.stagecount then 'Data Fail'
   when p.packagetypeID = 1 and e.environmentID = 2 and m.oltpcount <> m.stagecount then 'Data Fail'
   when p.packagetypeID = 1 and e.environmentID = 2 and m.precount + m.currentcount +m.type1count + m.type2count <> Postcount then 'Data Fail'
   when p.packagetypeID = 2 and e.environmentID = 2 and stagecount<>currentcount and currentcount+precount<>postcount then 'Data Fail'
else 'Data Pass' end as Indicator
  from control.metrics m inner join control.Package p on
  m.packageID = p.PackageID inner join control.packagetype t on
  p.packagetypeID = t.PackageTypeID inner join control.environment e on
  e.environmentID = p.environmentID


 --    How the control of Data flows from oltp to staging : This script is as well to be supplied in the 'GET FULL PACKAGE'of d Control in SSIS

 select packageID, packageName from control.package where environmentid = 1 and startdate <= convert (date, getdate())
and enddate >= convert(date, getdate()) and active = 1 order by sequenceID asc

--    How the control of Data flows from staging to edw

select p.packageID, p.packageName from control.package p where environmentid = 2 and active = 1  and startdate <= convert(Date, getdate()) 
and enddate >= convert(Date, getdate()) 
order by sequenceID desc























