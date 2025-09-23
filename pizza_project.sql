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
SELECT 
    ROUND(SUM(od.quantity * p.price)) AS Total_sales
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;


-- 3. Identify the highest-priced pizza. 
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered. 
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities. 
SELECT 
    pt.name, SUM(od.quantity) AS total_ordered
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- Intermediate: 
-- 1. Join the necessary tables to find the total quantity of each pizza category ordered. 
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 2. Determine the distribution of orders by hour of the day. 
SELECT 
    HOUR(time) AS order_hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY order_hour
ORDER BY order_hour;

-- 3. Join relevant tables to find the category-wise distribution of pizzas. 
SELECT 
    pt.category, COUNT(p.pizza_id) AS pizza_Count
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY pizza_Count DESC;

select category,count(name) from pizza_types group by category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered perday.     
SELECT 
    ROUND(AVG(daily_total)) AS avg_pizzas_per_day
FROM
    (SELECT 
        date, SUM(od.quantity) AS daily_total
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date) AS sub;

-- 5. Top 3 most ordered pizza types based on revenue
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price)) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced: 
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

select name , revenue from
(select category,name,revenue ,
rank() over (partition by category order by revenue desc) as rn
from
 (SELECT 
    pt.category,
    pt.name ,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name ) as a) as b 
where rn<=3;  
