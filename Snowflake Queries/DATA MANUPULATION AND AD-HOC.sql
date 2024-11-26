---- DATA MANUPULATION AND AD-HOC ANALYSIS


-- Update Store Table so that all store has date after 1st jan 2014 - ADOC 1

Update dimstore set storeopeningdate= dateadd(Day,uniform(0,3800,random()), '2014-01-01')
commit;


-- for store id 91 to 100  update date  inlast 12 months ADOC 2

Select * from dimstore where storeid between 91 and 100;
update dimstore set storeopeningdate = dateadd(Day,uniform(0,365, random()),dateadd(year,-1,current_date));
commit;


--- UPDATE CUSTOMER TABLE SO THAT CUSTOME RIS AT LEAST 12 YEARS OLD
Select * from dimcustomer where dateofbirth >=dateadd(year,-12,current_date)
update dimcustomer set dateofbirth = dateadd(year,-12,dateofbirth)  where dateofbirth >=dateadd(year,-12,current_date)
commit;


-- orderdate from order table should be after the date of opeing date

Update factorders f
set f.dateid =
r.dateid from
( Select orderid,d.dateid from 
(
Select orderid,
dateadd(day,
datediff(day,s.storeopeningdate,current_date)*uniform(1,10,random())*0.1,s.storeopeningdate) as new_Date

from factorders as f
join dimdate d on d.dateid=f.dateid
join  dimstore s on f.storeid=s.storeid
where d.date<s.storeopeningdate) o
join dimdate d on o.new_date=d.date)r
where f.orderid = r.orderid
commit;


--Customer who has not placed any order in last 30 days
Select * from dimcustomer where customerid not in
(
Select distinct c.customerid from dimcustomer c
join factorders f on f.customerid=c.customerid 
join dimdate d on f.dateid=d.dateid
where d.date>= dateadd(month,-1,current_date)
)

--most recent opened store with its sales since 

with CTE as (
Select storeid,storeopeningdate, row_number() over(order by storeopeningdate desc) as final_rank from dimstore),
CTE2 as (
Select storeid from CTE where final_rank=1)

select o.storeid,sum(totalamount) from factorders as o join cte2 c on o.storeid=c.storeid
group by o.storeid


--customers ordered more than 3 cateogry in last 6 months

with CTE as (
Select f.customerid,p.category from factorders f join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
where d.date>= dateadd(month,-6,current_date)
group by f.customerid,p.category
)
select customerid
from cte 
group by customerid
having count(distinct category)>3

--Monthwise sales for current year
Select month,sum(totalamount) from factorders o  join dimdate d on o.dateid=d.dateid
where d.year= extract(month from current_date)
group by month
order by month 

--top 3 brand by sales in 1 year

with brand_Sales as (
select brand,sum(totalamount) as total_sales from 
factorders f join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
where d.date>= dateadd(year,-1,current_date)
group by brand
),
brand_sales_rank as (
select s.*,row_number() over(order by total_sales desc) as sales_rank from brand_sales s
)
select brand, total_sales from brand_sales_rank where sales_rank<=3


---customer and thier current loayality program

select l.programtier,count(customerid) from dimcustomer c join dimloyaltyprogram l on c.loyaltyprogramid=l.loyaltyprogramid
group by l.programtier


----  show the reign category wise total amount for last 6 month

Select region, category, sum(totalamount) from factorders f
join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid 
join dimstore s on f.storeid=s.storeid
WHERE   d.date>=dateadd(month,-6, current_date)
group by region,category


------ QUERY THE DTAGING LAYER CSV FILES
CREATE OR REPLACE FILE FORMAT CSV_SOURCE_FILE_FORMAT
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
DATE_FORMAT = 'YYYY-MM-DD';

Select $1 from 
@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
