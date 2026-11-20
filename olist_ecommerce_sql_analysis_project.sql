-- OLIST E-COMMERCE SQL ANALYSIS


-- 01 — TABLE CREATION AND DATA IMPORT

--creating tables and importing data from csv files 

create table customers (customer_id	varchar(100) primary key ,
customer_unique_id	varchar(100)  ,
customer_zip_code_prefix	varchar(5) ,
customer_city	varchar(100),
customer_state	varchar(10)
);
select * from customers ;
create TABLE GEOLOCATIONS (geolocation_zip_code_prefix	varchar(5),
geolocation_lat	decimal ,
geolocation_lng	decimal ,
geolocation_city	varchar(100),
geolocation_state	varchar(5)
);
create table order_items (order_id	varchar(100),
order_item_id	int,
product_id	varchar(100),
seller_id	varchar(100),
shipping_limit_date	timestamp,
price	decimal,
freight_value	decimal
);
create table order_payments(order_id	varchar(100),
payment_sequential	varchar(10),
payment_type	varchar(50),
payment_installments	varchar(10),
payment_value	varchar(10)
);
create table order_reviews (review_id	varchar(100)  ,
order_id	varchar(100),
review_score	int check(review_score between 1 and 5),
review_comment_title  text,
review_comment_message	text,
review_creation_date	timestamp,
review_answer_timestamp	timestamp
);
select * from order_reviews ;
create table orders (order_id	varchar(100)	primary key ,
customer_id	varchar(100),	
order_status	varchar(50),	
order_purchase_timestamp	timestamp,	
order_approved_at	timestamp,	
order_delivered_carrier_date	timestamp,	
order_delivered_customer_date	timestamp,	
order_estimated_delivery_date	timestamp	
) ;
create table products(product_id	varchar(100)	primary key,
product_category_name	varchar(100),	
product_name_lenght	int,	
product_description_lenght	int,	
product_photos_qty	int,	
product_weight_g	int,	
product_length_cm	int,	
product_height_cm	int,	
product_width_cm	int	
);
create table sellers (seller_id	varchar(100)	primary key ,
seller_zip_code_prefix	varchar(5),	
seller_city	varchar(50),	
seller_state	varchar(5)	
);
create table product_name_translation(product_category_name	varchar(100),
product_category_name_english	varchar(100)
);

-- 02 — ORDER ANALYSIS

--understanding the orders 

--How many orders were placed each year?
select * from orders  ;
with cte as (select * , extract('Year' from order_purchase_timestamp) as year_of_order from orders)
select year_of_order ,count(order_id) as no_of_orders from cte group by year_of_order;

--How many orders were placed each month?
with cte as (select * ,  to_char (order_purchase_timestamp , 'yyyy-mm') as month_of_order from orders)
select month_of_order ,count(order_id) as no_of_orders from cte group by month_of_order;

--Which month had the highest number of orders?
with cte as (select * ,  to_char (order_purchase_timestamp , 'yyyy-mm') as month_of_order from orders)
select month_of_order ,count(order_id) as no_of_orders from cte group by month_of_order order by no_of_orders desc limit 1;

--What percentage of orders were delivered, cancelled, unavailable, shipped, etc.?
select order_status , round(count(order_id)::numeric/(select count(*) from orders)*100 ,2) as percentage from orders group by order_status ;

--How many orders are currently not delivered?
select count(*) as total_not_delivered_orders from orders where order_status != 'delivered';

--What is the average time between an order being purchased and being delivered?
with cte as (select age( order_delivered_customer_date ,order_purchase_timestamp)
as time_taken from orders where order_delivered_customer_date is not null)
select avg(time_taken) as avg_time_taken from cte;

--How many orders were delivered later than the estimated delivery date? 
select count(*) as no_of_late_orders from orders where order_delivered_customer_date is not null and
order_delivered_customer_date > order_estimated_delivery_date ;

--Which month had the highest number of cancelled orders?
with cte as ( select * , to_char(order_purchase_timestamp , 'yyyy-mm') as month from orders)
select month , count(order_id) as no_of_canl_orders from cte group by month order by no_of_canl_orders desc limit 1 ;

-- 03 — CUSTOMER ANALYSIS

--understanding customer table 

select * from customers ;

--How many unique customers are there?
select count(distinct customer_unique_id) as no_of_customer from customers ;

--How many customers placed more than one order?
with cte as (select customer_unique_id from customers group by customer_unique_id having count(customer_unique_id) > 1 )
select count(distinct customer_unique_id) as no_of_cust from cte ;
--or
select * from orders;
with cte as (select  c.customer_unique_id from orders o left join customers c on
o.customer_id = c.customer_id group by customer_unique_id having count( order_id) > 1)
select count(distinct customer_unique_id) as no_of_cust from cte ;

--What percentage of customers are repeat customers?
with cte as (select  c.customer_unique_id from orders o left join customers c on
o.customer_id = c.customer_id group by customer_unique_id having count( order_id) > 1)
select count(distinct customer_unique_id)::numeric/(select count(distinct customer_unique_id) from customers)*100
as  per_of_repeat_cust from cte ;

--What is the average number of orders per customer?
select (select count(order_id) from orders)::numeric/(select count(distinct customer_unique_id) from customers) as avg_order_per_cust ;

--Which customers have placed the most orders?
with cte as (select  c.customer_unique_id , count(order_id) as no_of_orders from orders o left join customers c on
o.customer_id = c.customer_id group by customer_unique_id )
select customer_unique_id ,no_of_orders from cte  order by no_of_orders desc limit 10;

--Which states have the most customers?
select customer_state , count(distinct customer_unique_id) as no_of_cust from customers group by customer_state 
order by no_of_cust desc limit 1 ;

--Which states have the highest average order value?
select * from order_payments;
select * from customers;
select * from orders;
with cte as (select order_id , sum(payment_value::numeric) as order_value from order_payments group by order_id),
     cte1 as ( select  ct.order_value , c.customer_state from  cte ct join orders o on ct.order_id = o.order_id
join customers c on o.customer_id = c.customer_id )
select customer_state , round(avg(order_value),2) as avg_order_value 
from cte1 group by customer_state order by avg_order_value desc limit 1 ;

--payment AOV
with cte as (select order_id , sum( payment_value::numeric)  as order_value 
from order_payments group by order_id)
select sum(order_value)/(select count(distinct order_id) as AOV from order_payments ) from cte ;

-- 04 — REVENUE AND PRODUCT CATEGORY ANALYSIS

--What is the total revenue generated from products?
select * from products ;
select * from order_payments ;
select * from order_items ;
select sum(price) as total_revenue from order_items ; 

--Which product categories generate the most revenue?
select p.product_category_name , sum(ot.price) as total_cat_wise_revenue from products p join order_items ot on p.product_id = ot.product_id
group by p.product_category_name order by total_cat_wise_revenue desc limit 1 ;

--Which product categories have the highest number of orders?
select * from orders ;
select p.product_category_name , count(distinct oi.order_id) as no_of_orders from products p join order_items oi 
on p.product_id = oi.product_id group by p.product_category_name order by no_of_orders desc limit 1 ;

--Which product categories have the highest average order value?
select p.product_category_name ,round(sum(oi.price)::numeric/nullif(count(p.product_category_name),0), 2) as  AOV from order_items oi join products p 
on oi.product_id = p.product_id group by p.product_category_name order by aov desc limit 10 

--Which products sold the most units?
select product_id , count(*) as no_of_units from order_items group by product_id order by no_of_units desc limit 1 ;

-- 05 — SELLER ANALYSIS

--Which sellers generate the most revenue?
select * from sellers ; 
select seller_id , sum(price) as revenue from order_items group by seller_id order by revenue desc limit 1 ;

--Are sellers with the highest number of orders also the sellers with the highest revenue?
select seller_id , count(order_id) as no_of_orders from order_items group by seller_id order by no_of_orders desc limit 1 ;
--The seller with the highest number of orders is not the seller with the highest revenue.

-- 06 — REVIEW AND CUSTOMER SATISFACTION ANALYSIS

--What is the average review score across all orders?
select * from order_reviews ;
select round(avg(review_score),2) as avg_review_score from order_reviews ;

--What percentage of reviews received each score (1, 2, 3, 4, and 5)?
select review_score , round(count(review_score)::numeric/(select count(*) from order_reviews)*100 ,2) as percentage from order_reviews 
group by review_score order by review_score asc ;

--Which product categories have the highest average review score?
select * from products ;
select * from order_items ;
select p.product_category_name , round(avg(os.review_score) , 2) as avg_score from order_items oi join products p on oi.product_id = p.product_id 
join order_reviews os on oi.order_id = os.order_id group by p.product_category_name order by avg_score desc limit 1 ;

--Do late deliveries tend to receive lower review scores?
select * from orders ;
select  avg(os.review_score) as avg_score from orders o join order_reviews os on o.order_id = os.order_id 
where o.order_delivered_customer_date is not null and o.order_delivered_customer_date > o.order_estimated_delivery_date ;
select  avg(os.review_score) as avg_score from orders o join order_reviews os on o.order_id = os.order_id 
where o.order_delivered_customer_date is not null and o.order_delivered_customer_date <= o.order_estimated_delivery_date ;
--yes , late deliveries tend to recieve lower review scores 

--Which sellers have the worst average review scores?
select * from sellers ;
select * from order_reviews ;
select * from order_items ;
with cte as (select oi.seller_id , round(avg(os.review_score) , 2) as avg_score from order_items oi join order_reviews os on oi.order_id = os.order_id 
group by oi.seller_id )
select seller_id , avg_score from cte where avg_score = (select min(avg_score)  from cte ); 

--What is the relationship between delivery time and review score?
select * from orders ;
with cte as ( select o.order_id , o.order_delivered_customer_date - o.order_purchase_timestamp as time_taken , os.review_score from 
 orders o join order_reviews os on o.order_id = os.order_id where o.order_delivered_customer_date is not null )
 select extract('Day' from time_taken) as t_taken , avg(review_score) as avg_score from cte group by t_taken order by t_taken asc;
--as the time duration increases there is a drop in reviews 

--What factors have the strongest relationship with customer satisfaction?
--we have already seen lesser the delivery time stronger is the review score 
-- also if the delivery is late there is a drop in review score 

-- 07 — REPEAT PURCHASE AND CUSTOMER VALUE ANALYSIS

--What factors affect repeat purchasing?
--Customer state
select * from customers ;
with cte as ( select  c.customer_state , c.customer_unique_id , count(o.order_id) as no_of_orders 
from customers c join orders o on c.customer_id = o.customer_id group by c.customer_state , c.customer_unique_id order by no_of_orders desc )
select customer_state , round(sum(case when no_of_orders > 1 then 1 else 0 end)::numeric/count(customer_unique_id) ,3) as repeat_cust_rate from
cte group by customer_state order by repeat_cust_rate desc;
--Average order value
--Do repeat customers spend more per order than one-time customers?
select * from order_items ;
select * from orders ;
with cte as (select o.order_id , c.customer_unique_id , sum(oi.price) as order_value from 
orders o join order_items oi on o.order_id = oi.order_id join customers c on o.customer_id = c.customer_id 
group by c.customer_unique_id ,o.order_id ),
     cte1 as (select customer_unique_id , count(order_id) as no_of_orders from cte group by customer_unique_id )
--for repeat customer
select avg(c.order_value) as AOV from cte c join cte1 c1 on c.customer_unique_id = c1.customer_unique_id where c1.no_of_orders > 1 ;
--for no repeat customer
select avg(c.order_value) as AOV from cte c join cte1 c1 on c.customer_unique_id = c1.customer_unique_id where c1.no_of_orders = 1 
--AOV for repeat customer is 123.9 , for non repeat customer it is 138.6
--repeat customers spend about 10.6% less per order than one-time customers

-------------------------------------------------------------------------------------------------------------------------
--Do repeat customers generate more total revenue per customer than one-time customers?
--total revenue generated by repeat customers
with cte as (select c.customer_unique_id , count(o.order_id) as no_of_orders from customers c join orders o 
              on c.customer_id = o.customer_id group by c.customer_unique_id),
		cte1 as (select c.customer_unique_id , sum(oi.price) as revenue_per_cust from customers c join orders o on
		c.customer_id = o.customer_id join order_items oi on o.order_id = oi.order_id group by c.customer_unique_id)
select sum(c1.revenue_per_cust) as total_revenue from cte1 c1 join cte c on c1.customer_unique_id = c.customer_unique_id
where c.no_of_orders > 1
--total_revenue = 778821.97
--for single time customers 
select sum(c1.revenue_per_cust) as total_revenue from cte1 c1 join cte c on c1.customer_unique_id = c.customer_unique_id
where c.no_of_orders = 1
--total_revenue =12812821.73

--total_revenue_per_customer(repeat_cust)
select round(sum(c1.revenue_per_cust)::numeric/(select count(customer_unique_id)from cte where no_of_orders >1) ,3)  as total_revenue_per_cust 
from cte1 c1 join cte c on c1.customer_unique_id = c.customer_unique_id
where c.no_of_orders > 1
--total_revenue_per_cust=259.861
--total_revenue_per_customer(single_time_cust)
select round(sum(c1.revenue_per_cust)::numeric/(select count(customer_unique_id) from cte where no_of_orders =1),3)  as total_revenue_per_cust 
from cte1 c1 join cte c on c1.customer_unique_id = c.customer_unique_id
where c.no_of_orders = 1
--total_revenue_per_cust=137.626

---------------------------------------------------------------------------------------------------------------------------------------

-- 08 — ADVANCED PRODUCT AND SELLER ANALYSIS

-- Product and seller analysis
select * from customers ;
select * from products ;
select * from orders ;
select * from order_items ;
select * from sellers ;

--Which products generate the highest revenue?
select product_id , sum(price) as product_revenue from order_items 
group by product_id order by product_revenue desc limit 1 

--Which sellers have the highest number of distinct orders?
 with cte as (select oi.seller_id , count(distinct o.order_Id) as d_order_count from order_items oi join orders o on
              oi.order_id = o.order_id group by oi.seller_id )
select seller_id , d_order_count from cte where d_order_count = (select max(d_order_count) from cte)


--Which sellers have the highest average order value (AOV)?
with cte as (select seller_id , round(sum(price)::numeric/count(distinct order_id) , 2) as AOV from order_items group by seller_id)
       select seller_id , AOV from cte where AOV = (select max(AOV) from cte)

--Which customer states have the highest revenue per customer?
with cte as ( select c.customer_state , round(sum(oi.price)::numeric/count(distinct c.customer_unique_id) ,2) as revenue_per_cust 
from customers c join orders o on c.customer_id = o.customer_id join order_items oi on o.order_id = oi.order_id group by c.customer_state )
select customer_state , revenue_per_cust from cte where revenue_per_cust = (select max(revenue_per_cust) from cte )

--	What percentage of orders are cancelled or unavailable?
select distinct order_status from orders 
with cte as ( select order_status , count(*) as num_of_orders from orders where order_status in ('canceled' , 'unavailable') 
group by order_status)
select order_status , round(num_of_orders::numeric/(select count(*) from orders)*100 ,3) as pct_of_tota_orders from cte

--Which product categories have the highest cancellation rate?
with cte as (select p.product_category_name , count(distinct o.order_id) as num_of_canl from orders o join order_items oi on 
o.order_id = oi.order_id join products p on oi.product_id = p.product_id where o.order_status = 'canceled'
group by p.product_category_name ),
cte1 as (select p.product_category_name , count(distinct oi.order_id) as total_order from order_items oi join products p  on oi.product_id =
p.product_Id group by p.product_category_name  )
select c.product_category_name , c.num_of_canl::numeric/c1.total_order as canl_rate from cte c join cte1 c1
on c.product_category_name = c1.product_category_name order by canl_rate  desc


--Find the top 5 product categories by revenue using window functions.
select distinct p.product_category_name , sum(oi.price) over(partition by p.product_category_name) as 
revenue from order_items oi join products p on oi.product_id = p.product_id order by revenue  desc limit 5
--or
with cte as (select p.product_category_name , sum(oi.price) as revenue  from order_items oi 
join products p on oi.product_id = p.product_id group by p.product_category_name ),
cte1 as (select product_category_name , revenue , dense_rank() over(order by revenue desc) d_rank from cte ) 
select product_category_name , revenue  from cte1 where d_rank <=5


--Rank sellers by revenue within each state.
with cte as (select s.seller_id ,s.seller_state, sum(oi.price) as revenue from sellers s join order_items oi on
              s.seller_id = oi.seller_id group by s.seller_state , s.seller_id),
cte1 as (select seller_state ,seller_id , revenue , dense_rank() over(partition by seller_state order by revenue desc) as rank from cte )
 select seller_state ,seller_id , revenue ,  rank from cte1 where rank <=3


-- 09 — ADVANCED CUSTOMER AND MONTHLY REVENUE ANALYSIS

--Identify the top 10 customers who have placed the highest number of orders.
select c.customer_unique_id , count(distinct o.order_id) as num_of_orders from customers c join orders o 
on c.customer_id = o.customer_id group by c.customer_unique_id order by num_of_orders desc limit 10 

-- Calculate the month-over-month (MoM) revenue growth percentage for the e-commerce business.

-- Requirements:
-- 1. Calculate total revenue for each month using order_purchase_timestamp.
-- 2. Use LAG() to retrieve the previous month's revenue.
-- 3. Calculate monthly revenue growth:
-- \[
-- \text{MoM Growth (\%)}=\frac{\text{Current Revenue}-\text{Previous Revenue}}{\text{Previous Revenue}}\times100
-- \]

-- 4. Return the month, current month's revenue, previous month's revenue, and growth percentage.
-- 5. Sort chronologically.
with cte as (select date_trunc('year', order_purchase_timestamp) as year ,date_trunc(  'month', order_purchase_timestamp) as month  ,
sum(oi.price) as revenue from orders o join order_items oi 
on o.order_id = oi.order_id group by year,month order by month)
select month ,revenue ,lag(revenue) over(order by year , month) as previous_m_revenue,  
round((revenue - lag(revenue) over( order by year , month) )*100/nullif((lag(revenue) over(order by year , month)), 0),2) as growth_pct
from cte


