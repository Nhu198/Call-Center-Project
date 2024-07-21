######## CALL CENTER PROJECT ##########
## Dataset from a leading call center company, I have delved into the extensive dataset, meticulously analyzing key performance indicators (KPIs)
## to provide actionable insights for informed decision-making.
## Through visually appealing dashboards and compelling storytelling, 
## I present a detailed overview of call center performance, customer segmentation, regional trends, and operator efficiency.

## The dataset has 4 tables and I have used Power Query to clean, combine, enrich & connection them for analysis and visualization.
	## Table 1: Staff (PersonalID, Firstname, Surname)	
    ## Table 2: Location (LocationID, Location Name, City, Country)																		
	## Table 3: CallRecords2022 (CallID, CallStarts, CallEnds, CustomerAcc, CustomerAge, CustomerPhone, OperatorID, LocationID, Sector, CallSatisfaction)																		
	## Table 4: CallRecords2023 (CallID, CallStarts, CallEnds, CustomerAcc, CustomerAge, CustomerPhone, OperatorID, LocationID, Sector, CallSatisfaction)																		

## I have analyzed into 2 tools:
	## Excel (Power Query, Diagram, Power Pivot, Graph for visualization)
	## SQL for analysis and Tableu for visualization
    
## BELOW IS THE SECOND TOOL, I USE SQL TO CLEAN, MERGE, ENRICH, SUMMARIZE TO ANALYSIS THE DATA. THEN, I USE TABLEAU FOR DATA VISUALIZATION

## 1. GET DATA
create table call_center_project.callrecords2022 (
	CallID int NOT NULL PRIMARY KEY ,CallStarts datetime ,CallEnds datetime,CustomerAcc varchar(255) ,
    CustomerAge int ,CustomerPhone varchar(255) ,OperatorID varchar(255) , LocationID varchar(255) ,
    Sector varchar(255) , CallSatisfaction float(24));
    
create table call_center_project.callrecords2023 (
	CallID int NOT NULL PRIMARY KEY,CallStarts datetime ,CallEnds datetime,CustomerAcc varchar(255) ,
    CustomerAge int ,CustomerPhone varchar(255) ,OperatorID varchar(255) , LocationID varchar(255) ,
    Sector varchar(255) , CallSatisfaction float(24));
    
 create table call_center_project.location (   
    LocationID varchar(255) NOT NULL PRIMARY KEY, Location_Name varchar(255), City varchar(255), Country varchar(255));
    
create table call_center_project.staff ( 
	PersonID varchar(255) NOT NULL PRIMARY KEY , FirstName varchar(255) , Surname varchar(255));
    
load data infile 'CallCenterDataset - CallRecords2022.csv' into table call_center_project.callrecords2022
fields terminated by ','
ignore 1 lines;

load data infile 'CallCenterDataset - CallRecords2023.csv' into table call_center_project.callrecords2022
fields terminated by ','
ignore 1 lines;

load data infile 'CallCenterDataset - Locations.csv' into table call_center_project.location
fields terminated by ','
ignore 1 lines;

load data infile 'CallCenterDataset - Staff.csv' into table call_center_project.staff
fields terminated by ','
ignore 1 lines;

## 2. Clean data:
# Để tạo connection cho các bảng, ta phải xác định primary key & foreign key. Nhận thấy dữ liệu trong bảng callrecords2022 có chứa dữ liệu locationID là LOC020 
# mà trong bảng location không có nên ta thêm vào, sau đó tạo các foreign key để xây connection giữa các bảng.
insert into call_center_project.location(LocationID) values
("LOC020");

ALTER TABLE call_center_project.callrecords2022
ADD CONSTRAINT staffid_2022
FOREIGN KEY(OperatorID) 
REFERENCES call_center_project.staff(PersonID);

ALTER TABLE call_center_project.callrecords2022
ADD CONSTRAINT locationid_2022
FOREIGN KEY(LocationID) 
REFERENCES call_center_project.location(LocationID);

ALTER TABLE call_center_project.callrecords2023
ADD CONSTRAINT staffid_2023
FOREIGN KEY(OperatorID) 
REFERENCES call_center_project.staff(PersonID);

ALTER TABLE call_center_project.callrecords2023
ADD CONSTRAINT locationid_2023
FOREIGN KEY(LocationID) 
REFERENCES call_center_project.location(LocationID);

## merge call records of 2022 and 2023 into 1 table is callrecords.
select * from call_center_project.callrecords2022
union
select * from call_center_project.callrecords2023;
# -> export to a file that contained data of both year and fill data to below table

create table call_center_project.callrecords (
	CallID int NOT NULL PRIMARY KEY ,CallStarts varchar(255) ,CallEnds varchar(255),CustomerAcc varchar(255) ,
    CustomerAge int ,CustomerPhone varchar(255) ,OperatorID varchar(255) , LocationID varchar(255) ,
    Sector varchar(255) , CallSatisfaction float(24));
    
load data infile 'callrecords_combined.csv' into table call_center_project.callrecords
fields terminated by ','
ignore 1 lines;

ALTER TABLE call_center_project.callrecords
ADD CONSTRAINT staffid
FOREIGN KEY(OperatorID) 
REFERENCES call_center_project.staff(PersonID);

ALTER TABLE call_center_project.callrecords
ADD CONSTRAINT locationid
FOREIGN KEY(LocationID) 
REFERENCES call_center_project.location(LocationID);

select * from call_center_project.callrecords;

## 3. Analysis

# 3.1 Overview, Trend Analysis & Customer Composion

# Total of Call
select  count(distinct(CallID)) from call_center_project.callrecords;

# Total of Customer
select count(distinct(CustomerAcc)) from call_center_project.callrecords;

# Number of Customer by Countries
select * from location;

update call_center_project.location
set Country = replace(Country,'United States','USA')
where Country like '%United States%' ;

with CTE_A as (
	select callrecords.*, location.Country from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID)
select Country, count( distinct CustomerAcc) 
from CTE_A group by Country;

# Number of EU Customer
select callrecords.*,location.Country from call_center_project.callrecords
left join call_center_project.location
on callrecords.locationID = location.locationID;

with CTE3 as (
	select callrecords.*,location.Country from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.locationID = location.locationID)
select count(distinct(CustomerAcc)) as Number_of_EU_Customer from CTE3
where Country in ('Sweden\r','Germany\r','Portugal\r','Italy\r');

# Average Call Satisfaction by Years
select * from call_center_project.callrecords;

select *, substring(CallStarts,8,4) as yearofcall
from call_center_project.callrecords;

with CTE4 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords)
select yearofcall, avg(CallSatisfaction) as Average_Call_Satisfaction from CTE4 group by yearofcall;

# Total Number of Customer & Total Number of Call by years

with CTE4 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords)
select yearofcall, count(distinct CustomerAcc) as Total_number_of_customer, count(distinct CallID) as Total_number_of_call from CTE4 group by yearofcall;

## 3.2 Regional Analysis
# Number of calls by Sector
with CTE4 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords)
select Sector, count(distinct CallID) as Total_number_of_call from CTE4 group by Sector;

with CTE4 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords),
    CTE5 as	
    (select Sector, count(distinct CallID) as Total_number_of_call from CTE4 group by Sector)
select sum(Total_number_of_call) from CTE5;

with CTE4 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords),
    CTE5 as	
    (select Sector, count(distinct CallID) as Total_number_of_call from CTE4 group by Sector)
select *, sum(Total_number_of_call)*100/(select sum(Total_number_of_call) from CTE5) as Numberofcall_percent
from CTE5 group by Sector;

## Number of Customers by Sector
with CTE6 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords)
select Sector, count(distinct CustomerAcc) as Total_number_of_customer from CTE6 group by Sector;

with CTE6 as 
	(select *, substring(CallStarts,8,4) as yearofcall
	from call_center_project.callrecords),
	CTE7 as (select Sector, count(distinct CustomerAcc) as Total_number_of_customer from CTE6 group by Sector)
select Sector, sum(Total_number_of_customer)*100/(select sum(Total_number_of_customer) from CTE7) as Customer_percent
from CTE7 group by Sector;

## Number of Customers by Age Group

select * from call_center_project.callrecords;

select *, case
			when callrecords.CustomerAge > 60 then 'More than 60'
            when callrecords.CustomerAge >= 41 and callrecords.CustomerAge <=60 then '41-60'
            when callrecords.CustomerAge >= 30 and callrecords.CustomerAge <= 40 then '30-40'
            when callrecords.CustomerAge < 30 then 'less than 30' else '' end as AgeGroup
from call_center_project.callrecords;

with CTE8 as (
	select *, case
			when callrecords.CustomerAge > 60 then 'More than 60'
            when callrecords.CustomerAge >= 41 and callrecords.CustomerAge <=60 then '41-60'
            when callrecords.CustomerAge >= 30 and callrecords.CustomerAge <= 40 then '30-40'
            when callrecords.CustomerAge < 30 then 'less than 30' else '' end as AgeGroup
	from call_center_project.callrecords)
select AgeGroup, count( distinct CustomerAcc) as Total_number_of_customer
from CTE8
group by AgeGroup;

# Number of Customer, Number of Call, Avg of Call Satisfaction, AHT by country

select callrecords.*, location.Country 
from call_center_project.callrecords
left join call_center_project.location
on callrecords.LocationID = location.LocationID;

use call_center_project;
with CTE9 as (
	select callrecords.*, location.Country 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID),
	CTE10 as (select *,
		cast(concat(substring(CallEnds,8,4), '-' , substring(CallEnds,5,2) , '-' , substring(CallEnds,2,2) ,' ', substring(CallEnds,13,8)) as datetime) as Endformatted,
		cast(concat(substring(CallStarts,8,4) , '-' , substring(CallStarts,5,2) , '-' , substring(CallStarts,2,2) , ' ' ,substring(CallStarts,13,8)) as datetime) as Startformatted
	from CTE9),
    CTE11 as (select *, timediff(Endformatted, Startformatted) as Handling_time
    from CTE10),
	CTE12 as (select *, (hour(Handling_time)*60 + minute(Handling_time) + second(Handling_time)/60) as Handlingtime_minute
	from CTE11)
select Country, avg(Handlingtime_minute) as AHT, count( distinct CallID) as Number_of_call, avg(CallSatisfaction)*100 as CSAT_percent
from CTE12
where Country is not null
group by Country;

## 3.3 Correlation Analysis

# AHT & CSAT by Sector
with CTE9 as (
	select callrecords.*, location.Country 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID),
	CTE10 as (select *,
		cast(concat(substring(CallEnds,8,4), '-' , substring(CallEnds,5,2) , '-' , substring(CallEnds,2,2) ,' ', substring(CallEnds,13,8)) as datetime) as Endformatted,
		cast(concat(substring(CallStarts,8,4) , '-' , substring(CallStarts,5,2) , '-' , substring(CallStarts,2,2) , ' ' ,substring(CallStarts,13,8)) as datetime) as Startformatted
	from CTE9),
    CTE11 as (select *, timediff(Endformatted, Startformatted) as Handling_time
    from CTE10),
	CTE12 as (select *, (hour(Handling_time)*60 + minute(Handling_time) + second(Handling_time)/60) as Handlingtime_minute
	from CTE11)
    select Sector, avg(Handlingtime_minute) as AHT, avg(CallSatisfaction)*100 as CSAT_percent
    from CTE12
    where Country is not null
    group by Sector;
    
## 3.4. Country and Operator Performance

# Average of CallSatisfaction

select avg(CallSatisfaction)*100 as Avg_CSAT from call_center_project.callrecords;

# AHT, CSAT, Number of Calls by Staff

select * from call_center_project.staff;

alter table call_center_project.staff
add column Fullname varchar(255);

update call_center_project.staff
set Fullname = concat(FirstName,' ',Surname);

with CTE9 as (
	select callrecords.*, location.Country 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID),
	CTE10 as (select *,
		cast(concat(substring(CallEnds,8,4), '-' , substring(CallEnds,5,2) , '-' , substring(CallEnds,2,2) ,' ', substring(CallEnds,13,8)) as datetime) as Endformatted,
		cast(concat(substring(CallStarts,8,4) , '-' , substring(CallStarts,5,2) , '-' , substring(CallStarts,2,2) , ' ' ,substring(CallStarts,13,8)) as datetime) as Startformatted
	from CTE9),
    CTE11 as (select *, timediff(Endformatted, Startformatted) as Handling_time
    from CTE10),
	CTE12 as (select *, (hour(Handling_time)*60 + minute(Handling_time) + second(Handling_time)/60) as Handlingtime_minute
	from CTE11),
    CTE13 as (
	select OperatorID, avg(Handlingtime_minute) as AHT, avg(CallSatisfaction)*100 as CSAT_percent , count( distinct CallID) as numberofcalls
	from CTE12
	group by OperatorID)    
select staff.Fullname, CTE13.AHT, CTE13.CSAT_percent, CTE13.numberofcalls
from CTE13
left join call_center_project.staff
on CTE13.OperatorID = staff.PersonID;

## 3.5. Geographical and Sectorial Insights

# Number of Calls by Sector and Country.
with CTE9 as (
	select callrecords.*, location.Country 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID)
select Sector, Country, count( distinct CallID) as numberofcall
from CTE9 where Country is not null
group by Sector, Country;

# Number of Calls by Region
select * from location;

alter table call_center_project.location
add column Region varchar(255);

update call_center_project.location
set Region = case 
				when Country in ('Sweden\r','Germany\r','Portugal\r','Italy\r') then 'EU'
                else Country 
			end;

with CTE14 as (
	select callrecords.*, location.Region
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID)
select Region, count( distinct CallID) as numberofcalls
from CTE14 where Region is not null group by Region;

# CSAT by Country
with CTE9 as (
	select callrecords.*, location.Country 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID),
	CTE10 as (select *,
		cast(concat(substring(CallEnds,8,4), '-' , substring(CallEnds,5,2) , '-' , substring(CallEnds,2,2) ,' ', substring(CallEnds,13,8)) as datetime) as Endformatted,
		cast(concat(substring(CallStarts,8,4) , '-' , substring(CallStarts,5,2) , '-' , substring(CallStarts,2,2) , ' ' ,substring(CallStarts,13,8)) as datetime) as Startformatted
	from CTE9),
    CTE11 as (select *, timediff(Endformatted, Startformatted) as Handling_time
    from CTE10),
	CTE12 as (select *, (hour(Handling_time)*60 + minute(Handling_time) + second(Handling_time)/60) as Handlingtime_minute
	from CTE11)
select Country, avg(CallSatisfaction)*100 as CSAT_percent
from CTE12
where Country is not null
group by Country;


## Export below table to visualize on Tableau
with CTE9 as (
	select callrecords.*, location.Country, location.Region 
	from call_center_project.callrecords
	left join call_center_project.location
	on callrecords.LocationID = location.LocationID),
	CTE10 as (select *,
		cast(concat(substring(CallEnds,8,4), '-' , substring(CallEnds,5,2) , '-' , substring(CallEnds,2,2) ,' ', substring(CallEnds,13,8)) as datetime) as Endformatted,
		cast(concat(substring(CallStarts,8,4) , '-' , substring(CallStarts,5,2) , '-' , substring(CallStarts,2,2) , ' ' ,substring(CallStarts,13,8)) as datetime) as Startformatted
	from CTE9),
    CTE11 as (select *, timediff(Endformatted, Startformatted) as Handling_time
    from CTE10),
	CTE12 as (select *, (hour(Handling_time)*60 + minute(Handling_time) + second(Handling_time)/60) as Handlingtime_minute
	from CTE11)
select * from CTE12;