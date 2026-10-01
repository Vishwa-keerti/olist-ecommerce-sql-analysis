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

--understanding customer table 

select * from customers ;

--How many unique customers are there?
select count(distinct customer_id) as no_of_customer from customers ;

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
select customer_unique_id from cte  order by no_of_orders desc limit 1;

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
with cte as (select oi.order_id , p.product_category_name ,sum(price::numeric) as order_value from order_items oi join products p 
on oi.product_id = p.product_id group by oi.order_id ,p.product_category_name)
 select product_category_name , avg(order_value) as avg_order_value from cte 
 group by product_category_name order by avg_order_value desc limit 1 ;
 
 --Which products sold the most units?

 
