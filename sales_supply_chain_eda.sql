-- SALES & SUPPLY CHAIN EDA
-- Organized portfolio version of the original SQL analysis
-- MySQL

-- NOTE: This file reorganizes the original queries into a logical analytical flow.
-- It preserves the analyses performed in the supplied script.

-- 01 — Initial Inspection & Duplicate Checks
SELECT *
FROM ssales_order;

SELECT 
    order_id,
    customer_id,
    order_date,
    requested_delivery_date,
    order_status,
    sales_channel,
    COUNT(*) AS count
FROM ssales_order
GROUP BY 
    order_id,
    customer_id,
    order_date,
    requested_delivery_date,
    order_status,
    sales_channel
HAVING COUNT(*) > 1;

SELECT *
FROM ssales_order
WHERE order_id = 'SO00058';

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   order_id,
                   customer_id,
                   order_date,
                   requested_delivery_date,
                   order_status,
                   sales_channel
           ) AS row_num
    FROM ssales_order
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- 02 — Data Cleaning & Deduplication
CREATE TABLE `ssales_order2` (
  `order_id` text,
  `customer_id` text,
  `order_date` text,
  `requested_delivery_date` text,
  `order_status` text,
  `sales_channel` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO ssales_order2
SELECT *,
ROW_NUMBER () OVER (
    PARTITION BY order_id, customer_id, order_date,
                 requested_delivery_date, order_status, sales_channel
) AS row_num
FROM ssales_order;

SELECT *
FROM ssales_order2
WHERE row_num > 1;

DELETE 
FROM ssales_order2
WHERE row_num > 1;

SELECT *
FROM ssales_order2;

SELECT *
FROM ssales_order2
WHERE order_date > requested_delivery_date;

SELECT *
FROM ssales_order2
WHERE customer_id IS NOT NULL
AND customer_id NOT IN (
    SELECT customer_id
    FROM customers
);

SELECT *
FROM ssales_order2
WHERE order_id IS NULL
OR customer_id IS NULL
OR order_date IS NULL
OR requested_delivery_date IS NULL
OR order_status IS NULL
OR sales_channel IS NULL;


-- 03 — Schema Checks & Column Name Cleanup
ALTER TABLE products
RENAME COLUMN ï»¿product_id TO product_id;

ALTER TABLE customers
RENAME COLUMN ï»¿customer_id TO customer_id;

ALTER TABLE sales_order_items
RENAME COLUMN ï»¿order_item_id TO order_item_id;

ALTER TABLE shipments
RENAME COLUMN ï»¿shipment_id TO shipment_id;

DESCRIBE customers;


-- 04 — Dataset Overview & Basic EDA
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM ssales_order2;

SELECT
    order_status,
    COUNT(*) AS order_count
FROM ssales_order2
GROUP BY order_status
ORDER BY order_count DESC;

SELECT
    sales_channel,
    COUNT(*) AS order_count
FROM ssales_order2
GROUP BY sales_channel
ORDER BY order_count DESC;

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*) AS order_count
FROM ssales_order2
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- 05 — Monthly Sales & Revenue
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
WHERE o.order_date IS NOT NULL
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue,
    ROUND(
        SUM(i.total_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS revenue_per_order
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
WHERE o.order_date IS NOT NULL
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;


-- 06 — Product Performance
SELECT
    i.product_id,
    COUNT(DISTINCT i.order_id) AS orders,
    SUM(i.quantity_ordered_cases) AS total_cases,
    SUM(i.total_amount) AS total_revenue
FROM sales_order_items i
GROUP BY i.product_id
ORDER BY total_revenue DESC;

SELECT
    i.product_id,
    SUM(i.quantity_ordered_cases) AS total_cases,
    SUM(i.total_amount) AS total_revenue,
    ROUND(
        SUM(i.total_amount) / SUM(i.quantity_ordered_cases),
        2
    ) AS revenue_per_case
FROM sales_order_items i
GROUP BY i.product_id
ORDER BY revenue_per_case DESC;

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(i.quantity_ordered_cases) AS total_cases,
    SUM(i.total_amount) AS total_revenue
FROM sales_order_items i
JOIN products p
    ON i.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_revenue DESC;

-- Investigation of the lower-revenue products
SELECT *
FROM sales_order_items
WHERE product_id = 'P014';

SELECT *
FROM products
WHERE product_id = 'P014';

SELECT DISTINCT soi.product_id
FROM sales_order_items soi
LEFT JOIN products p
    ON soi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT *
FROM sales_order_items
WHERE product_id IN ('P012', 'P013', 'P014', 'P015');

SELECT
    product_id,
    COUNT(*) AS line_items,
    SUM(quantity_ordered_cases) AS total_cases,
    SUM(total_amount) AS total_revenue
FROM sales_order_items
WHERE product_id IN ('P012', 'P013', 'P014', 'P015')
GROUP BY product_id
ORDER BY total_revenue DESC;


-- 07 — Customer Performance
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue,
    ROUND(
        SUM(i.total_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_value_order
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY avg_value_order DESC;


-- 08 — Sales Channel Analysis
SELECT
    o.sales_channel,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue,
    ROUND(
        SUM(i.total_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
GROUP BY sales_channel
ORDER BY total_revenue DESC;

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue
FROM ssales_order2 o
JOIN sales_order_items i
    ON o.order_id = i.order_id
GROUP BY o.order_status
ORDER BY order_count DESC;


-- 09 — Shipment & Delivery Performance
SELECT
    s.delivery_status,
    COUNT(DISTINCT s.order_id) AS order_count
FROM shipments s
GROUP BY s.delivery_status
ORDER BY order_count DESC;

SELECT
    s.delivery_status,
    COUNT(DISTINCT s.order_id) AS order_count,
    ROUND(
        AVG(
            DATEDIFF(
                STR_TO_DATE(s.delivery_date, '%Y-%m-%d'),
                STR_TO_DATE(o.requested_delivery_date, '%Y-%m-%d')
            )
        ), 2
    ) AS avg_days_difference
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
WHERE s.delivery_date IS NOT NULL
AND o.requested_delivery_date IS NOT NULL
GROUP BY s.delivery_status
ORDER BY avg_days_difference DESC;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT s.order_id) AS delayed_orders
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE s.delivery_status = 'Delayed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY delayed_orders DESC;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivery_status = 'Delayed' THEN s.order_id
    END) AS delayed_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.delivery_status = 'Delayed' THEN s.order_id
        END)
        / COUNT(DISTINCT s.order_id) * 100,
        2
    ) AS delay_rate
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY delay_rate DESC;


-- 10 — Delay Analysis by Channel & Product Category
SELECT
    o.sales_channel,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivery_status = 'Delayed' THEN s.order_id
    END) AS delayed_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.delivery_status = 'Delayed' THEN s.order_id
        END)
        / COUNT(DISTINCT s.order_id) * 100,
        2
    ) AS delay_rate
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
GROUP BY o.sales_channel
ORDER BY delay_rate DESC;

SELECT
    p.category,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivery_status = 'Delayed' THEN s.order_id
    END) AS delayed_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.delivery_status = 'Delayed' THEN s.order_id
        END)
        / COUNT(DISTINCT s.order_id) * 100,
        2
    ) AS delay_rate
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
JOIN sales_order_items i
    ON s.order_id = i.order_id
JOIN products p
    ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY delay_rate DESC;

SELECT
    s.delivery_status,
    AVG(s.transportation_cost) AS avg_transportation_cost
FROM shipments s
GROUP BY s.delivery_status
ORDER BY avg_transportation_cost DESC;


-- 11 — Regional Analysis
SELECT
    c.region,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue
FROM customers c
JOIN ssales_order2 o
    ON c.customer_id = o.customer_id
JOIN sales_order_items i
    ON o.order_id = i.order_id
GROUP BY c.region
ORDER BY total_revenue;

SELECT
    c.region,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivery_status = 'Delayed'
        THEN s.order_id
    END) AS delayed_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.delivery_status = 'Delayed'
            THEN s.order_id
        END)
        / COUNT(DISTINCT s.order_id) * 100,
        2
    ) AS delay_rate
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY delay_rate DESC;


-- 12 — Customer Type Analysis
SELECT
    c.customer_type,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue
FROM customers c
JOIN ssales_order2 o
    ON c.customer_id = o.customer_id
JOIN sales_order_items i
    ON o.order_id = i.order_id
GROUP BY c.customer_type
ORDER BY total_revenue DESC;

SELECT
    c.customer_type,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.total_amount) AS total_revenue,
    ROUND(
        SUM(i.total_amount) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM customers c
JOIN ssales_order2 o
    ON c.customer_id = o.customer_id
JOIN sales_order_items i
    ON o.order_id = i.order_id
GROUP BY c.customer_type
ORDER BY avg_order_value DESC;

SELECT
    c.customer_type,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivery_status = 'Delayed'
        THEN s.order_id
    END) AS delayed_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN s.delivery_status = 'Delayed'
            THEN s.order_id
        END)
        / COUNT(DISTINCT s.order_id) * 100,
        2
    ) AS delay_rate
FROM shipments s
JOIN ssales_order2 o
    ON s.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY delay_rate DESC;


-- 13 — Transportation Cost & Shipment Size
SELECT
    SUM(quantity_shipped_cases) AS total_cases_shipped,
    SUM(transportation_cost) AS total_transportation_cost,
    AVG(transportation_cost) AS avg_transportation_cost_per_shipment
FROM shipments;

SELECT
    CASE
        WHEN quantity_shipped_cases <= 5 THEN '1-5'
        WHEN quantity_shipped_cases <= 10 THEN '6-10'
        WHEN quantity_shipped_cases <= 15 THEN '11-15'
        WHEN quantity_shipped_cases <= 20 THEN '16-20'
        ELSE '21+'
    END AS quantity_group,
    COUNT(*) AS shipment_count,
    SUM(quantity_shipped_cases) AS total_cases,
    AVG(transportation_cost) AS avg_transportation_cost
FROM shipments
GROUP BY quantity_group
ORDER BY quantity_group;

