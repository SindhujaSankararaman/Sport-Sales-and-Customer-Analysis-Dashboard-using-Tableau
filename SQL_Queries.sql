use sportsstore;
--DELETE FROM dbo.orders where order_id is NULL
--1. KPI's for Total Revenue, profit, no_of_orders,profit_margins
select 
  sum(revenue) as total_revenue,
  sum(profit) as total_profit,
  COUNT(*) as total_orders,
  sum(profit)/sum(revenue) * 100.0 as profit_margin
from  
  dbo.orders
--2.Track Revenue, profit, no_of_orders,profit_margins for each sport
select 
  sport,
  round(sum(revenue),2) as total_revenue,
  round(sum(profit),2) as total_profit,
  COUNT(*) as total_orders,
  round(sum(profit)/sum(revenue) * 100.0,2) as profit_margin
from  
  dbo.orders
group by sport
order by profit_margin desc
select * from dbo.orders
-- 3. No of customer rating and the average rating
select 
    (select count(*) from dbo.orders where rating IS not NULL) as no_of_reviews,
	round(avg(rating),2) as average_rating
from  
    dbo.orders
-- 4. No of people for each rating and it's revenue,profit,profit-margin
select 
   rating,
	sum(revenue) as total_revenue,
  sum(profit) as total_profit,
  sum(profit)/sum(revenue) * 100.0 as profit_margin  
from  
    dbo.orders
where rating IS not NULL
group by rating
order by rating desc
-- 5. State revenue, profit and profit-margin
select 
     c.state,
	 sum(revenue) as total_revenue,
  sum(profit) as total_profit,
  sum(profit)/sum(revenue) * 100.0 as profit_margin  
from 
      dbo.orders o
join 
      dbo.customers c
on    
        o.customer_id = c.customer_id
group by state
order by total_profit desc
--5 . State revenue, profit and profit margin
select 
     c.state,
	 row_number() over(order by sum(o.revenue) desc)as revenue_rank,
	 sum(revenue) as total_revenue,
	 row_number() over(order by sum(o.profit) desc)as profit_rank,
     sum(profit) as total_profit,  
	 row_number() over(order by sum(profit)/sum(revenue) * 100.0 desc)as margin_rank,
     sum(profit)/sum(revenue) * 100.0 as profit_margin  
from 
     dbo.orders o
join 
     dbo.customers c
on    
     o.customer_id = c.customer_id
group by 
     c.state
order by margin_rank 
--6. Monthly Profits
with monthly_profit as (
select 
     month(date) as month,
	 sum(profit) as total_profit
from 
     dbo.orders
group by 
     month(date) )
select 
    month,
	total_profit,
	lag(total_profit) over (order by month) as previous_month_profit,
	total_profit - lag(total_profit) over (order by month) as profit_difference
from
    monthly_profit