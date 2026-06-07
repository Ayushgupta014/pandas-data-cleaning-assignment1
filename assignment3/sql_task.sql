use superstore;
DROP TABLE IF EXISTS superstore_raw;

CREATE TABLE superstore_raw (
    row_id        INT,
    order_id      VARCHAR(50),
    order_date    DATE,           
    ship_date     DATE,           
    ship_mode     VARCHAR(50),
    customer_id   VARCHAR(50),
    customer_name VARCHAR(100),
    segment       VARCHAR(50),
    country       VARCHAR(50),
    city          VARCHAR(50),
    state         VARCHAR(50),
    postal_code   VARCHAR(20),
    region        VARCHAR(50),
    product_id    VARCHAR(50),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    product_name  VARCHAR(255),
    sales         DECIMAL(10,4),
    quantity      INT,
    discount      DECIMAL(5,4),
    profit        DECIMAL(10,4)
);
show tables;


-- CUSTOMERS TABLE
-- ----------------------------
DROP TABLE IF EXISTS customers;
 
CREATE TABLE customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM superstoreraw;

SELECT customer_id, COUNT(*) 
FROM customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1;

ALTER TABLE customers
MODIFY customer_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (customer_id);

SELECT * FROM customers LIMIT 5;


-- Step 1: Drop existing table
DROP TABLE IF EXISTS products;

-- Step 2: Recreate using MIN() to pick one name per product_id
CREATE TABLE products AS
SELECT 
    product_id,
    MIN(product_name)  AS product_name,  
    MIN(category)      AS category,
    MIN(sub_category)  AS sub_category
FROM superstoreraw
GROUP BY product_id;                    

-- Step 3: Verify no duplicates
SELECT product_id, COUNT(*) 
FROM products 
GROUP BY product_id 
HAVING COUNT(*) > 1;
-- ✅ Should return empty

-- Step 4: Add Primary Key safely
ALTER TABLE products
MODIFY product_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (product_id);

-- Step 5: Verify
SELECT * FROM products LIMIT 5;



DROP TABLE IF EXISTS orders;

CREATE TABLE orders AS
SELECT 
    order_id,
    MIN(customer_id)  AS customer_id,
    MIN(order_date)   AS order_date,
    MIN(ship_date)    AS ship_date,
    MIN(ship_mode)    AS ship_mode
FROM superstoreraw
GROUP BY order_id;

ALTER TABLE orders
MODIFY order_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (order_id);




-- Check exact columns of orders table
DESC orders;

-- Check exact columns of customers table  
DESC customers;

-- Check exact columns of products table
DESC products;



-- 4A. Orders with ABOVE AVERAGE sales
-- sales comes from superstore_raw
-- ----------------------------
SELECT
    sr.order_id,
    sr.product_id,
    ROUND(sr.sales, 2) AS sales
FROM superstoreraw sr
WHERE sr.sales > (
    SELECT AVG(sr2.sales)
    FROM superstoreraw sr2
)
ORDER BY sr.sales DESC;
 
 
-- ----------------------------
-- 4B. Highest sale order per customer
-- ----------------------------
SELECT
    o.customer_id,
    c.customer_name,
    o.order_id,
    ROUND(sr.sales, 2) AS sales
FROM orders o
JOIN superstoreraw sr ON o.order_id    = sr.order_id
JOIN customers c       ON o.customer_id = c.customer_id
WHERE sr.sales = (
    SELECT MAX(sr2.sales)
    FROM superstoreraw sr2
    JOIN orders o2 ON sr2.order_id = o2.order_id
    WHERE o2.customer_id = o.customer_id
)
ORDER BY sr.sales DESC;




-- 5A. Total sales per customer using CTE
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(sr.sales), 2)    AS total_sales,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT * FROM customer_sales
ORDER BY total_sales DESC;
 
 
-- ----------------------------
-- 5B. Top 10 customers by sales using CTE
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        c.segment,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name, c.segment
)
SELECT * FROM customer_sales
ORDER BY total_sales DESC
LIMIT 10;
 
 
-- ----------------------------
-- 5C. Bottom 10 customers by sales using CTE
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT * FROM customer_sales
ORDER BY total_sales ASC
LIMIT 10;

-- 6A. ROW_NUMBER — Unique number to every customer
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_sales,
    ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num
FROM customer_sales;
 
 
-- ----------------------------
-- 6B. RANK & DENSE_RANK comparison
-- RANK       → same sales = same rank, gaps appear after
-- DENSE_RANK → same sales = same rank, NO gaps
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_sales,
    RANK()       OVER (ORDER BY total_sales DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_rank_num
FROM customer_sales;
 
 
-- ----------------------------
-- 6C. RANK within each Region using PARTITION BY
-- region comes from superstore_raw
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        MIN(sr.region)          AS region,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    region,
    total_sales,
    RANK() OVER (
        PARTITION BY region
        ORDER BY total_sales DESC
    ) AS region_rank
FROM customer_sales
ORDER BY region, region_rank;


-- STEP 7: JOIN + CTE + WINDOW FUNCTION COMBINED
--         Final Result: Customer, Total Sales, Rank
-- ============================================================
 
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        c.segment,
        MIN(sr.region)             AS region,
        ROUND(SUM(sr.sales), 2)    AS total_sales,
        ROUND(SUM(sr.profit), 2)   AS total_profit,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name, c.segment
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        region,
        total_sales,
        total_profit,
        total_orders,
        RANK()       OVER (ORDER BY total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_ranker,
        ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num
    FROM customer_sales
)
SELECT * FROM ranked_customers
ORDER BY sales_rank;

-- STEP 8: BUSINESS QUERIES
-- ============================================================
 
-- ----------------------------
-- 8A. Top 5 customers by total sales
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        c.segment,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name, c.segment
)
SELECT
    customer_name,
    segment,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
ORDER BY sales_rank
LIMIT 5;
 
 
-- ----------------------------
-- 8B. Bottom 5 customers by total sales
-- ----------------------------
WITH customer_sales AS (
    SELECT
        o.customer_id,
        c.customer_name,
        ROUND(SUM(sr.sales), 2) AS total_sales
    FROM orders o
    JOIN superstoreraw sr ON o.order_id    = sr.order_id
    JOIN customers c       ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales,
    RANK() OVER (ORDER BY total_sales ASC) AS low_rank
FROM customer_sales
ORDER BY low_rank
LIMIT 5;
 
 
-- ----------------------------
-- 8C. Customers with only ONE order (single-order customers)
-- ----------------------------
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1
ORDER BY c.customer_name;
 
 
-- ----------------------------
-- 8D. Orders with ABOVE AVERAGE sales (using CTE)
-- ----------------------------
WITH avg_sales AS (
    SELECT AVG(sr.sales) AS avg_sale
    FROM superstoreraw sr
)
SELECT
    sr.order_id,
    sr.product_id,
    p.product_name,
    ROUND(sr.sales, 2)   AS sales,
    ROUND(a.avg_sale, 2) AS avg_sales
FROM superstoreraw sr
JOIN avg_sales a ON sr.sales      > a.avg_sale
JOIN products p  ON sr.product_id = p.product_id
ORDER BY sr.sales DESC;
 
 
-- ----------------------------
-- 8E. Sales and Profit by Category
-- ----------------------------
SELECT
    p.category,
    ROUND(SUM(sr.sales), 2)      AS total_sales,
    ROUND(SUM(sr.profit), 2)     AS total_profit,
    COUNT(DISTINCT sr.order_id)  AS total_orders
FROM superstoreraw sr
JOIN products p ON sr.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;
 
 
-- ----------------------------
-- 8F. Top 10 Best Selling Sub-Categories
-- ----------------------------
SELECT
    p.sub_category,
    ROUND(SUM(sr.sales), 2) AS total_sales,
    SUM(sr.quantity)        AS total_quantity
FROM superstoreraw sr
JOIN products p ON sr.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_sales DESC
LIMIT 1;
 

 