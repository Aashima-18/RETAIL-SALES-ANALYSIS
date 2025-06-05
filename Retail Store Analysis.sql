create database retail;
use retail;

select count(*) from order_items;
select count(*) from delivery_performance;
select count(*) from products;
select count(*) from inventory;

desc orders;
desc order_items;
desc order_date;
desc customers;
select count(*) from order_date;

-- DATA CLEANING:
select * from orders 
where
order_id IS NULL
OR
order_date IS NULL
OR
customer_id IS NULL;

SELECT 
  SUM(order_id IS NULL) AS order_id_nulls,
  SUM(product_id IS NULL) AS product_name_nulls,
  SUM(quantity IS NULL) AS quantity_nulls,
  SUM(unit_price IS NULL) AS price_nulls
FROM order_items;

DELETE FROM order_items
WHERE order_id IS NULL 
   OR product_id IS NULL 
   OR quantity IS NULL 
   OR unit_price IS NULL;

SELECT 
  SUM(customer_id IS NULL) AS customer_id_nulls,
  SUM(phone IS NULL) AS phone_nulls,
  SUM(pincode IS NULL) AS pincode_nulls,
  SUM(total_orders IS NULL) AS total_orders_nulls,
  SUM(avg_order_value IS NULL) AS avg_order_value_nulls
FROM customers;


-- disabling safe mode
SET SQL_SAFE_UPDATES = 0;

delete from category
where category IS NULL;

delete from products
where product_id IS NULL;

delete from customers
where customer_Id is null;

-- DATA EXPLORATION:

-- total orders:
select count(*) from orders;

-- total customers:
select count(*) from customers;
-- total unique customers:
select count(distinct customer_id)  AS Total_customers from customers;

-- total sales revenue:
select
sum(quantity * unit_price) as total_sales_revenue
from order_items;

-- Daily
SELECT 
  o.order_date,
  oi.order_id,
  (oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- Monthly, Quarterly, Yearly Sales
SELECT
  DATE_FORMAT(o.order_date, '%Y-%m') AS sale_month,
  QUARTER(o.order_date) AS sale_quarter,
  YEAR(o.order_date) AS sale_year,
  SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY sale_year, sale_quarter, sale_month
ORDER BY sale_year, sale_month;

-- Total sales by products
 SELECT
  p.product_name,
  DATE_FORMAT(o.order_date, '%Y-%m') AS sale_month,
  QUARTER(o.order_date) AS sale_quarter,
  YEAR(o.order_date) AS sale_year,
  SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name, sale_year, sale_quarter, sale_month
ORDER BY p.product_name, sale_year, sale_month
LIMIT 10;

-- total sales by category
SELECT 
  category,
  SUM(total_revenue) AS total_category_sales
FROM (
  SELECT 
    (quantity * unit_price) AS total_revenue,
    (SELECT category FROM products WHERE products.product_id = oi.product_id) AS category
  FROM order_items oi
) AS sub
WHERE category is not null
GROUP BY category
ORDER BY total_category_sales DESC;

