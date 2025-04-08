--1 Retrieve the total number of orders placed.
select count(order_id) as No_of_ from order_details

--2 Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(O.quantity * P.price) AS Total_Revenue
FROM 
    order_details O
INNER JOIN 
    pizzas P 
ON 
    O.pizza_id = P.pizza_id

	--3 Identify the highest-priced pizza.

SELECT TOP 1 
    pizza_type_id AS Name, 
    MAX(price) AS Expensive_one 
FROM 
    pizzas 
GROUP BY 
    pizza_type_id 
ORDER BY 
    Expensive_one DESC;
	--4 Identify the most common pizza size ordered.

SELECT TOP 1 
    P.size, 
    COUNT(P.size) AS Total_no_of_orders
FROM 
    order_details O
INNER JOIN 
    pizzas P 
ON 
    O.pizza_id = P.pizza_id
GROUP BY 
    P.size
ORDER BY 
    Total_no_of_orders DESC;
	--5 List the top 5 most ordered pizza Name  along with their quantities.
SELECT TOP 5 
    A.name, 
    SUM(O.quantity) AS Total_Orders
FROM 
    order_details O
INNER JOIN  
    (SELECT 
         P1.name, 
         P2.pizza_id 
     FROM 
         pizza_types P1 
     INNER JOIN  
         pizzas P2 
     ON 
         P1.pizza_type_id = P2.pizza_type_id
    ) AS A 
ON 
    A.pizza_id = O.pizza_id
GROUP BY 
    A.name 
ORDER BY 
    Total_Orders DESC;
	--6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, 
    SUM(order_details.quantity) AS quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    quantity DESC;
	--7 Determine the distribution of orders by hour of the day.
SELECT 
    DATEPART(HOUR, O1.time) AS Hour_of_order, 
    COUNT(O1.order_id) AS Count_of_order
FROM 
    orders O1
GROUP BY 
    DATEPART(HOUR, O1.time)
ORDER BY 
    DATEPART(HOUR, O1.time);
	--8 Join relevant tables to find the category-wise distribution of pizzas.
select category,count(*) as Total_count from pizza_types group by category
--9 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Total_Quantity), 0) AS Avg_of_Quantity_order_per_day 
FROM 
    (SELECT 
        O2.date, 
        SUM(O1.quantity) AS Total_Quantity 
     FROM 
        order_details O1 
     INNER JOIN 
        orders O2 
     ON 
        O1.order_id = O2.order_id
     GROUP BY 
        O2.date
    ) AS A;
	--10 Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 
    name, 
    SUM(Total_Sales) AS Total_Revenue 
FROM (
    SELECT 
        P2.name, 
        P.price * O.quantity AS Total_Sales 
    FROM order_details O
    INNER JOIN pizzas P ON O.pizza_id = P.pizza_id
    INNER JOIN pizza_types P2 ON P.pizza_type_id = P2.pizza_type_id
) AS SalesData
GROUP BY name 
ORDER BY Total_Revenue DESC;
--11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    P2.category, 
    SUM(Total_Sales) AS Total_Revenue,
    (SUM(Total_Sales) / 
        (SELECT SUM(O.quantity * P.price) 
         FROM order_details O 
         INNER JOIN pizzas P ON O.pizza_id = P.pizza_id) 
    ) * 100 AS Percentage_Contribution
FROM 
    pizza_types P2 
INNER JOIN 
    (SELECT 
         P1.pizza_type_id, 
         (O.quantity * P1.price) AS Total_Sales 
     FROM 
         order_details O 
     INNER JOIN 
         pizzas P1 ON O.pizza_id = P1.pizza_id
    ) AS A 
ON 
    A.pizza_type_id = P2.pizza_type_id
GROUP BY 
    P2.category 
ORDER BY 
    Total_Revenue DESC;
	--12 Analyze the cumulative revenue generated over time.
SELECT 
    O1.date, 
    SUM(A.Total_Revenue) AS Total_Revenue,
    SUM(SUM(A.Total_Revenue)) OVER (ORDER BY O1.date ASC) AS Cumulative_Sum
FROM orders O1 
INNER JOIN (
    SELECT 
        O.order_id, 
        (O.quantity * P.price) AS Total_Revenue 
    FROM order_details O 
    INNER JOIN pizzas P ON O.pizza_id = P.pizza_id
) AS A ON O1.order_id = A.order_id
GROUP BY O1.date
ORDER BY O1.date;
--13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * 
FROM (
    SELECT 
        A.category, 
        A.name, 
        SUM(O.quantity * A.price) AS Total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY A.category 
            ORDER BY SUM(O.quantity * A.price) DESC
        ) AS Rn
    FROM order_details O 
    INNER JOIN (
        SELECT 
            P2.pizza_id, 
            P1.category, 
            P1.name, 
            P2.price 
        FROM pizza_types P1 
        INNER JOIN pizzas P2 
        ON P1.pizza_type_id = P2.pizza_type_id
    ) AS A 
    ON O.pizza_id = A.pizza_id
    GROUP BY A.category, A.name
) AS B 
WHERE Rn <= 3;