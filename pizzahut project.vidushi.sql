-- Retreieve the total number of orders placed-- 

use pizzahut;
Select count(order_id) as total_sales from orders;

-- calculate the total revenue generated from pizza sales-- 

 Select round(sum(orders_details.quantity * pizzas.price),2)as total_sales
 from orders_details 
 join pizzas on
 pizzas.pizza_id = orders_details.pizza_id;
 
-- Identify the highest priced pizzas-- 

Select pizza_types.name ,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1 ;
 -- list the top 5 most orderd pizzas types along with their quantites--
 
 Select pizza_types.name, sum(orders_details.quantity) as quantity
 from pizza_types
 join
 pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join
 orders_details on orders_details.pizza_id = pizzas.pizza_id
 group by pizza_types.name
 order by quantity
 DESC limit 5;
 
 -- join the necessary tables to find the total quantity of each pizza category ordered--
 
 Select pizza_types.category,sum(orders_details.quantity) as quantity
 from
 pizza_types
 join
 pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join
 orders_details on orders_details.pizza_id = pizzas.pizza_id
 group by pizza_types.category
 order by quantity
 DESC ;
 
 -- determine the disrtribution of orders by hour of the day--
  
 
Select Hour(TIME) as hour,COUNT(order_id) as order_count
from orders
group by Hour(TIME);

-- --join relevanant tables to find the category-wise distribution of pizzas--  

select category,count(name) from pizza_types
group by category;

-- group the orders by date and calculate the average numbers of pizzas orderd per day--

select round(avg(quantity),0)from
(select orders.date, sum(orders_details.quantity) as quantity
from orders join orders_details
on orders_details.order_id = orders.order_id
group by orders.date) as order_quantity;

-- determine the top 3 most ordered pizza types based on revenue-- 

select pizza_types.name,
sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue
desc limit 3;

-- calculate the percentage contribution of each pizza type of total revenue-- 

select pizza_types.category,
(sum(orders_details.quantity * pizzas.price)/
 (Select round(sum(orders_details.quantity * pizzas.price),2)as total_sales
 from orders_details 
 join pizzas on
 pizzas.pizza_id = orders_details.pizza_id))*100 as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue
desc limit 3;

-- analayse the cumulaitive revenue generted over time-- 

select  order_date,
sum(revenue) over( order by order_date) as cum_revenue
from
(select orders.order_date,
sum(orders_details.quantity * pizzas.price)as revenue
 from orders_details 
 join pizzas
 on
 pizzas.pizza_id = orders_details.pizza_id
 join orders_details
on orders_details.order_id = orders.order_id
group by  orders.order_date) as sales;



-- determine the top 3 most ordered pizza types based on revenue for each category--


select name,revenue from(select category,name,revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category ,pizza_types.name,
sum(orders_details.quantity * pizzas.price)as revenue
from pizza_types join pizzas
 on pizzas.pizza_type_id = pizza_types.pizza_type_id
 join orders_details
 on orders_details.pizza_id = pizzas.pizza_id
 group by pizza_types.category,pizza_types.name) as a) as b
 where rn>=3;





 