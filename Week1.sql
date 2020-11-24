SELECT * FROM mmm.test;

DROP TABLE mmm.test;

CREATE TABLE mmm.test
(
	MarTechApe INT,
    MMM DOUBLE,
    Bootcamp TEXT,
    `Data Processing` TEXT
)
;

INSERT INTO mmm.test
VALUES
(666,666,'666','666'),
(777,777,'777',777),
(888,888,888,'888')
;

/*WRONG DATA TYPE*/
INSERT INTO mmm.test
VALUES
('aaa',666,'666','666')
;

SELECT
MarTechApe,
`Data Processing`
FROM mmm.test
WHERE MMM = 888
;

UPDATE mmm.test
SET MarTechApe = 888
WHERE MarTechApe = 777
;

Select * from MMM.test;

Delete From mmm.test
Where MarTechApe = 888 AND MMM = 777
;

Create Table mmm.test2
(
	select * from mmm.test
    where MarTechApe=888
)
;

Select * from mmm.test;
Select * From mmm.test2;

Select * from mmm.test
Union All
Select * from mmm.test2;

Alter Table mmm.test2
Add Column `Name` Text;

Select * From mmm.test2;

Update mmm.Test2
SET `Name` = 'Boss'
;

Select * 
From mmm.test
INNER JOIN mmm.test2
ON mmm.test.MarTechApe = mmm.test2.MarTechApe;

select * from mmm.testgroupby;

select `Month`, sum(sales) from mmm.testgroupby
group by `Month`;

select region, avg(sales) from mmm.testgroupby
group by region;

create table mmm.pivot
(
select 
`Month`,
sum(if(Region = 'East', Sales, NULL)) as EastSales,
sum(if(Region = 'South', Sales, NULL)) as SouthSales,
sum(if(Region = 'West', Sales, NULL)) as WestSales,
sum(if(Region = 'North', Sales, NULL)) as NorthSales
from mmm.testgroupby
group by `Month`
);

create table mmm.unpivot
(
select `Month`, 'East' as Region, EastSales as Sales from mmm.pivot
union all
select `Month`, 'South' as Region, SouthSales as Sales from mmm.pivot
union all
select `Month`, 'West' as Region, WestSales as Sales from mmm.pivot
union all
select `Month`, 'North' as Region, NorthSales as Sales from mmm.pivot
);

select * from mmm.mmm_sales_raw;

select * from mmm.mmm_date_metadata;

create table mmm.mmm_sales_transformed
(
select b.`Week`, round(sum(Sales), 2) as sales
from mmm.mmm_sales_raw as a
left join mmm.mmm_date_metadata as b
on a.`Order Date`  = b.`Day`
group by b.`Week`
);

select sum(sales) from mmm.mmm_sales_raw;
select sum(sales) from mmm.mmm_sales_transformed;

select * from mmm.mmm_sales_transformed;

/* Week 1 Homework 
Problem 1*/

select * from mmm.mmm_comp_media_spend;

select * from mmm.mmm_date_metadata;

create table mmm.mmm_comp_transformed
(
select `Week`, Round(Sum(`Competitive Media Spend`), 2) as total_comp_spend
from mmm.mmm_comp_media_spend
group by `Week`
);

select * from mmm.mmm_comp_transformed;

/* Week 1 Homework 
Problem 2*/

select * from mmm.mmm_event;

create table mmm.mmm_event_transformed
(
select `Week`, max(if(`Sales Event`=1, 1, 0)) as `sales_event`
from mmm.mmm_date_metadata as a
left join mmm.mmm_event as b
on a.`Day` = b.`Day`
group by `Week`
);

select * from mmm.mmm_event_transformed;

/* Week 1 Homework 
Problem 3*/

select * from mmm.mmm_econ;
select * from mmm.mmm_date_metadata;

create table mmm.mmm_econ_transformed
(
select b.`WEEK`, CPI from mmm.mmm_econ as a
left join mmm.mmm_date_metadata as b
on a.`MONTH`=b.`MONTH`
group by b.`week`, CPI
);

/* Week 1 Homework 
Problem 4-ab*/

select * from mmm.mmm_sales_transformed;

select `Week`, sales from mmm.mmm_sales_transformed
where sales > 250000;

/* Week 1 Homework 
Problem 4-c*/

select * from mmm.mmm_sales_transformed a
left join mmm.mmm_sales_transformed b
on a.`Week` = date_add(b.`Week`, interval 7 day)
where a.sales > b.sales;

/* Week 1 Homework 
Problem 4-d*/

select * from mmm.mmm_sales_transformed;

create table mmm.mmm_quarterly_sales
(select year(b.`Month`) as `Year`, quarter(b.`Month`) as `Quarter`, round(sum(sales), 2) as QuarterlySales
from mmm.mmm_sales_raw a
left join mmm.mmm_date_metadata b
on a.`Order Date` = b.`Day`
group by year(b.`Month`), quarter(b.`Month`)
);

select a.`Year`, CONCAT('Q',a.`Quarter`) AS `Quarter`, a.`QuarterlySales` from mmm.mmm_quarterly_sales a
inner join
			(select `Year`, max(QuarterlySales) as MaxQuarterlySales
             from mmm.mmm_quarterly_sales
             group by `Year`
             ) b
on a.`Year` = b.`Year` and a.QuarterlySales = b.MaxQuarterlySales
;
            