create database pizza_db;
use pizza_db;

show tables;
select * from order_details;
select * from orders;
select * from  pizza_types;
select * from pizzas;

select * from pizza_types where ingredients like '%Red Peppers%'; 

-- 1. Retrieve the total number of orders placed. 
select count(order_id) from orders;

-- 2. Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity * p.price))
as Total_sales 
from order_details od join pizzas p on od.pizza_id = p.pizza_id;


-- 3. Identify the highest-priced pizza. 
select pt.name ,p.price from pizza_types pt join 
pizzas p on pt.pizza_type_id = p.pizza_type_id 
order by p.price desc;

-- 4. Identify the most common pizza size ordered. 
select p.size,count(*) as order_count from pizzas p join 
order_details od on p.pizza_id = od.pizza_id 
group by p.size order by order_count desc limit 1;

-- 5. List the top 5 most ordered pizza types along with their quantities. 
select pt.name , sum(od.quantity) as total_ordered 
from pizzas p join order_details od on od.pizza_id = p.pizza_id 
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id 
group by pt.name order by total_ordered desc limit 5;

-- Intermediate: 
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered. 
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 2. Determine the distribution of orders by hour of the day. 
SELECT HOUR(time) AS order_hour, 
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- 3. Join relevant tables to find the category-wise distribution of pizzas. 
select pt.category , count(p.pizza_id) as pizza_Count 
from  pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id 
group by pt.category 
order by pizza_Count desc;

-- 4. Group the orders by date and calculate the average number of pizzas ordered perday.     
select ROUND(AVG(daily_total)) AS avg_pizzas_per_day
FROM (
    SELECT date, SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date
) AS sub;

-- 5. Top 3 most ordered pizza types based on revenue
SELECT pt.name, ROUND(SUM(od.quantity * p.price)) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 1. Calculate the percentage contribution of each pizza type to total revenue. 
SELECT 
    pt.name AS pizza_type,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue,
    ROUND(100 * SUM(od.quantity * p.price) / 
          (SELECT SUM(od2.quantity * p2.price)
           FROM order_details od2
           JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;

-- 2. Analyze the cumulative revenue generated over time. 
SELECT 
    o.date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
    ROUND(SUM(SUM(od.quantity * p.price)) 
          OVER (ORDER BY o.date), 2) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza 
-- category. 
WITH pizza_revenue AS (
    SELECT 
        pt.category,
        pt.name AS pizza_type,
        SUM(od.quantity * p.price) AS revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
),
ranked_pizzas AS (
    SELECT 
        category,
        pizza_type,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM pizza_revenue
)
SELECT category, pizza_type, ROUND(revenue, 2) AS revenue
FROM ranked_pizzas
WHERE rn <= 3
ORDER BY category, revenue DESC;

