-- EDA 
select * from customer;
select * from restaurants;
select * from orders;
select * from riders;
select * from deliveries;

-- import datasets 
select count(*) from restaurants
where custo_name is null
 or 
 reg_date is null;


select count(*) from restaurants 
where 
	restaurant_name is null 
	or
	city is null
	or 
	opening_hours is null;


select * from orders
where 
	 order_item is null
	 or 
	 order_date is null
	 or 
	 order_time is null
	 or
	 order_status is null
	 or 
	 total_amount is null;

insert into orders(order_id,customer_id,restaurant_id)
values
(10002,9,54),
(10003,10,52),
(10004,10,50);


delete from orders
where 
	 order_item is null
	 or 
	 order_date is null
	 or 
	 order_time is null
	 or
	 order_status is null
	 or 
	 total_amount is null;


-- -------------------------
-- data analysis  and reports 

--Q1 write a query  to find thr top 5 most frequently ordered dishes by customer called 'Arjun Mehta' in the last 1 year 
select
customer_name,dishes ,total_orders
from
(select 
    c.customer_id,
	c.customer_name,
	o.order_item as dishes,
	count(*) as total_orders,
	dense_rank() over (order by count(*) desc) as rank 
from orders as o 
join customer as c 
on c.customer_id = o.customer_id 
where o.order_date >= current_date - interval '1 year' and customer_name = 'Arjun Mehta'
group by 1,2,3
order by 1,4 desc
 ) as T1 
 where rank <= 5


--Q2 popular time slots : 
-- identify the time slots during which the most orders are placed .based on 2-hour intervals 
select
     case 
	     when extract(hour from order_time) between 0 and 1 then '00:00 - 02:00'
	     when extract(hour from order_time) between 2 and 3 then '02:00 - 04:00'
	     when extract(hour from order_time) between 4 and 5 then '04:00 - 06:00'
	     when extract(hour from order_time) between 6 and 7 then '06:00 - 08:00'
	     when extract(hour from order_time) between 8 and 9 then '08:00 - 10:00'
	     when extract(hour from order_time) between 10 and 11 then '10:00 - 12:00'
	     when extract(hour from order_time) between 12 and 13 then '12:00 - 14:00'
	     when extract(hour from order_time) between 14 and 15 then '14:00 - 16:00'
	     when extract(hour from order_time) between 16 and 17 then '16:00 - 18:00'
	     when extract(hour from order_time) between 18 and 19 then '18:00 - 20:00'
	     when extract(hour from order_time) between 20 and 21 then '20:00 - 22:00'
	     when extract(hour from order_time) between 22 and 23 then '22:00 - 00:00'
	end as time_slot,
	count(order_id) as order_count
from orders
group by time_slot 
order by order_count desc;

-- another one solution 
select 
      floor (extract(hour from order_time)/2)*2  as start_time,
      floor (extract(hour from order_time)/2)*2 +2 as end_time,
	  count(*) as total_orders
from orders
group by 1,2 
order by 3 desc;

--Q3 Order value analysis : 
-- find the average order value per customer who has placed more than 250 orders 
-- return cusotmer_name,and aov (average order value )

select 
     c.customer_name,
	 avg(total_amount) as aov ,
	 count(order_id) as total_orders
from orders  as o 
join customer as c 
on c.customer_id = o.customer_id
group by 1 
having count(order_id) >=250 ;


--Q4 high value cusotmers 
-- list the customers who have spent more than 100k  in total on food orders.
-- return customer_name, and cusotmer_id;
select c.customer_id, 
     c.customer_name,
	 sum(total_amount) as total_spent
from orders  as o 
join customer as c 
on c.customer_id = o.customer_id
group by 1 
having sum(total_amount) >=100000;

-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered.
-- Return each restuarant name, city and number of not delivered orders
select * 
from orders as o 
left join 
restaurants as r 
on r.restaurant_id = o.restaurant_id 
left join 
deliveries as d 
on d.order_id  =o.order_id 
where d.delivery_id is null;

select r.restaurant_name,
       count(order_id) as cnt_not_delivered_orders
from orders as o 
left join 
restaurants as r 
on r.restaurant_id = o.restaurant_id 
where 
    o.order_id not in (select order_id from deliveries)
group by 1 
order by 2 desc;


-- Q6 restaurant revenue ranking 
-- rank restaurants by their revenue from the last year , including therie name, 
-- total revenue and rank within their city.
with ranking_table
as 
(
select r.city,
r.restaurant_name,
sum(o.total_amount) as revenue,
dense_rank() over(partition by r.city order by sum(o.total_amount) desc) as rank 
from orders as o 
join 
restaurants as r 
on r.restaurant_id = o.restaurant_id
where o.order_date >= current_date - interval '1 Year'
group by 1,2 

)
select * from ranking_table 
where rank = 1 ;


-- Q7
-- most popular dish by city :
-- identify the most popular dish in each city based on the number of orders 
select * 
from 
(select r.city ,
       o.order_item ,
	   count(order_id)as total_orders,
	   dense_rank() over(partition by r.city order by count(order_id) desc) as rank 
	   
from orders as o 
join 
restaurants as r 
on r.restaurant_id = o.restaurant_id
group by 1,2
) as T1 
where rank = 1 


-- Q8 Customer Churn 
-- Find cusotmers who have'nt places an order in 2024 but did in 2023.


--1 fint  customers who has done orders in 2023 
--2 find cx(customers) who has not done in 2024
-- compare 1 and 2
select distinct customer_id from orders 
where
	extract (year from order_date) = 2023 
	and 
	customer_id not in 
			(select distinct customer_id from orders
			where extract (year from order_date)=2024)




-- Q9 Cancelllation Rate Comparison :
-- calculate and compare the order cancellation raet for each restaurant between the 
-- cuurent year and thee previous year.

WITH cancel_ratio_23 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o
    LEFT JOIN deliveries d 
        ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM order_date) = 2023
    GROUP BY o.restaurant_id
),

cancel_ratio_2024 AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o
    LEFT JOIN deliveries d 
        ON o.order_id = d.order_id
    WHERE EXTRACT(YEAR FROM order_date) = 2024
    GROUP BY o.restaurant_id
),

last_year_data AS (
    SELECT	
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(not_delivered::numeric / total_orders::numeric * 100, 2) AS cancel_ratio
    FROM cancel_ratio_23
),

current_year_data AS (
    SELECT	
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(not_delivered::numeric / total_orders::numeric * 100, 2) AS cancel_ratio
    FROM cancel_ratio_2024
)

SELECT 
    c.restaurant_id AS rest_id,
    c.cancel_ratio AS cs_ratio,
    l.cancel_ratio AS ls_l_ratio
FROM current_year_data c
JOIN last_year_data l
    ON c.restaurant_id = l.restaurant_id;


-- 10 Rider Average delivery time ;
-- Detemine each rider's average delivery time .
SELECT 
    d.rider_id,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    d.delivery_time - o.order_time +
                    CASE 
                        WHEN d.delivery_time < o.order_time 
                        THEN INTERVAL '1 day'
                        ELSE INTERVAL '0 day'
                    END
                )
            ) / 60
        ), 2
    ) AS avg_delivery_time_minutes
FROM orders o
JOIN deliveries d 
    ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY d.rider_id;

--  Q11 : Monthly restaurant growth ration:
--  calculate eachh restaurants growth ration based on the total number of delivered orders since its joining 

WITH monthly_orders AS (
    SELECT
        o.restaurant_id,
        DATE_TRUNC('month', o.order_date) AS month_date,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    GROUP BY
        o.restaurant_id,
        DATE_TRUNC('month', o.order_date)
),
growth_ratio AS (
    SELECT
        restaurant_id,
        TO_CHAR(month_date, 'MM-YY') AS month,
        total_orders AS current_month_orders,
        LAG(total_orders) OVER (
            PARTITION BY restaurant_id
            ORDER BY month_date
        ) AS prev_month_orders
    FROM monthly_orders
)
SELECT
    restaurant_id,
    month,
    current_month_orders,
    prev_month_orders,
    ROUND(
        (current_month_orders - prev_month_orders)
        / NULLIF(prev_month_orders, 0)::numeric * 100,
        2
    ) AS growth_percentage
FROM growth_ratio
ORDER BY restaurant_id, month;
	 

--  Q12 customer segmentation 
-- customer segmentation : segement customers into 'Gold' or 'silver' groups on their total spending 
-- compared to thee average order value (AOV). IF a customer's total spending exceeds the AOV,
-- label them  as 'gold' ; otherwise , label them as 'silver'.write an SQl query too determine each segment,s 
-- total number of orders and otal revenue 


-- cx total spend 
-- aov
-- gold
-- silver 
-- each categoyr and total orders and total revenue 
select Cx_category,
		sum(total_orders) as total_orders ,
		sum(total_spent) as total_revenue
	
	from (
select 
	 customer_id,
	 sum(total_amount) as total_spent,
	 count(order_id) as total_orders,
	 case when sum(total_amount) > (select avg(total_amount) from orders) then 'Gold' else 'Silver' end as Cx_category
	
from orders
group by 1 
) as T1
group by 1 


select avg(total_amount) from orders --375

--  Q13 rider monthly earnings :
-- calcualte each rider,s total monthly earnings ,assuming they earn 8% of the order amount 
select d.rider_id,
	to_char(o.order_date,'mm-yy') as month ,
	sum (total_amount) as revenue,
	sum (total_amount)*0.08 as riders_monthly_earnings 
from orders as o
join deliveries as d
on d.order_id= o.order_id 
group by 1,2 
order by 1,2;


-- Q14 rider ratings analysis :
-- find the number of 5 -star ,4-star , and 3-star ratings each rider has. 
-- riders recevie this rating based on delivery time .
-- if orders are delivered less than 15 minutes of order received time the rider  get 5 star rating,
-- if thery orders 15 and 20 min they get 4 star rating .
-- if they deliver after 20 min they get 3 star rating .
select 
	rider_id ,
	stars,
	count(*) as  total_stars
from 
(

select rider_id,
	delivery_took_time,
	case 
		when delivery_took_time < 15   then '5 Star'  
		when delivery_took_time between  15 and 20 then '4 Star'
		else  '3 Star'
		end as stars 
from 

(

select 
	o.order_id,
	o.order_time,
	d.delivery_time,
	ROUND(EXTRACT(EPOCH FROM (
           d.delivery_time - o.order_time +
                    CASE 
                        WHEN d.delivery_time < o.order_time 
                        THEN INTERVAL '1 day'
                        ELSE INTERVAL '0 day'
                    END
               ))/60, 2) AS delivery_took_time,
    d.rider_id
	
FROM orders as o 
join deliveries as d 
on o.order_id = d.order_id 
where delivery_status = 'Delivered'
) as T1 
) as T2 
group by 1,2 
order by 1,3 desc;



-- Q15. order frequency by day:
-- analysis order frequency per day of the week  and identify the peak day for each restaurant 
select *  
from
(
select 
r.restaurant_name,
to_char(o.order_date, 'Day')as Day ,
count(o.order_id) as total_orders,
rank() over(partition by r.restaurant_name order by count(o.order_id) desc) as rank 
from 
 orders as o
join restaurants as r 
on o.restaurant_id = r.restaurant_id
group by  1,2 
order by 1, 3 desc 
) as T1
where rank =1 ;

-- Q 16 customer lifestyle value (CLV):
-- CALCULATE the revenue genrated by each customer over all orders.

select 
	o.customer_id ,
	c.customer_name,
	sum(o.total_amount) as ClV
from orders o 
join customer as c
on o.customer_id = c.customer_id 
group by 1,2 ;

--Q 17 Monthly Sales Trends :
-- identify sales trends by comapring each month's total sales to the previoyus month .
select 
	extract(year from order_date) as year,
	extract(month from order_date) as month,
	sum(total_amount) as total_sale ,
	lag(sum(total_amount),1) over(order by extract(year from order_date),  extract(month from order_date))  as pre_month_sale
from orders
group by 1,2 
order by 1,2


-- rider efficiency :
-- Evaluate rider efficeincy by determining average delivery  times and identifying those with the lowest  and highest averages


with new_table 
as 
(
select 
	d.rider_id as riders_id ,
	EXTRACT( EPOCH FROM ( d.delivery_time - o.order_time +
     CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE 
	 INTERVAL '0 day' END ))/60 as time_deliver 
from 
orders as o 
join deliveries as d 
on o.order_id = d.order_id 
where d.delivery_status = 'Delivered'
),
rider_time  
as (
select 
	riders_id,
	avg(time_deliver) as avg_time
from new_table 
group by 1
)
	
select 
	min(avg_time),
	max(avg_time)
from rider_time;	


-- Q19 order Item popularity :
-- Track the popularity of specific order items over time and identify seasonal demand spikes
select
order_item,
seasons,
count(order_id) as total_orders
from 
(
select
	*,
	Extract (month from order_date) as month ,
	case 	
		when extract(month from order_date ) between 3  and 6 then 'Summer'
		when extract(month from order_date ) >  6  and  
		extract(month from order_date )  < 9 then 'Monsoon' 
		else 'Winter'
	End as seasons 		
from orders	
) as t1 
group by 1,2
order by 1,  3 desc;

-- Q20 Rank each city based on total revenue for the last year 2023

select  r.city ,
	sum(total_amount) as total_revenue,
	rank()over(order by sum(total_amount)desc) as city_rank 
from orders as o 
join 
restaurants as r 
on o.restaurant_id = r.restaurant_id 
group by 1;


--------------------------------- end of the project--------------------------------------





select * from customer;
select * from restaurants;
select * from orders;
select * from riders;
select * from deliveries;