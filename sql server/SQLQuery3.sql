
-- STEP 1: One view that joins the 3 tables (run it once)

CREATE OR ALTER VIEW v_sales AS
SELECT
    o.order_id,
    o.order_date,
    YEAR(o.order_date) AS order_year,
    o.ship_mode,
    o.quantity,
    o.discount,
    o.sales,
    o.profit,
    o.returned,
    c.customer_id,
    c.customer_name,
    c.segment,
    c.region,
    p.product_name,
    p.category
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN products  AS p ON p.product_id  = o.product_id;
GO


-- Q1. What are the overall business numbers (orders, customers, sales, profit, profit margin)?

SELECT
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales)                  AS total_sales,
    SUM(profit)                 AS total_profit,
    CAST(100.0 * SUM(profit) / SUM(sales) AS DECIMAL(5,2)) AS profit_margin_pct
FROM v_sales;


-- Q2. How do sales and profit change from year to year?

SELECT
    order_year,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales)               AS total_sales,
    SUM(profit)              AS total_profit
FROM v_sales
GROUP BY order_year
ORDER BY order_year;


-- Q3. Which product category brings the most sales and profit?

SELECT
    category,
    SUM(quantity) AS units_sold,
    SUM(sales)    AS total_sales,
    SUM(profit)   AS total_profit,
    CAST(100.0 * SUM(profit) / SUM(sales) AS DECIMAL(5,2)) AS profit_margin_pct
FROM v_sales
GROUP BY category
ORDER BY total_profit DESC;



-- Q4. What are the top 5 most profitable products?

SELECT TOP 5
    product_name,
    category,
    SUM(quantity) AS units_sold,
    SUM(sales)    AS total_sales,
    SUM(profit)   AS total_profit
FROM v_sales
GROUP BY product_name, category
ORDER BY total_profit DESC;



-- Q5. Who are the top 10 customers by sales?

SELECT TOP 10
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales)               AS total_sales
FROM v_sales
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC;



-- Q6. Which region sells the most, and which customer segment
--     is the strongest inside each region?

SELECT
    region,
    segment,
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit
FROM v_sales
GROUP BY region, segment
ORDER BY region, total_sales DESC;



-- Q7. How many returned items are there in each category?
--     (returned is a BIT column: 1 = returned)
SELECT
    category,
    COUNT(*) AS returned_items
FROM v_sales
WHERE returned = 1
GROUP BY category
ORDER BY returned_items DESC;


-- Q8. Which shipping mode is used the most, and how much does it sell?

SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 0)     AS total_sales
FROM v_sales
GROUP BY ship_mode
ORDER BY total_orders DESC;