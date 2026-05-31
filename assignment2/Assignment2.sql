-- create database ShopEase;
use ShopEase;

-- CREATE TABLE customers ( 
--     customer_id   INT           PRIMARY KEY, 
--     first_name    VARCHAR(50)   NOT NULL, 
--     last_name     VARCHAR(50)   NOT NULL, 
--     email         VARCHAR(100)  UNIQUE NOT NULL, 
--     city          VARCHAR(50)   NOT NULL, 
--     state         VARCHAR(50)   NOT NULL, 
--     join_date     DATE          NOT NULL, 
--     is_premium    BOOLEAN       DEFAULT FALSE 
-- );
-- CREATE INDEX idx_customers_city ON customers(city); 
-- CREATE INDEX idx_customers_state ON customers(state);


-- CREATE TABLE products ( 
--     product_id    INT           PRIMARY KEY, 
--     product_name  VARCHAR(100)  NOT NULL, 
--     category      VARCHAR(50)   NOT NULL, 
--     brand         VARCHAR(50)   NOT NULL, 
--     unit_price    DECIMAL(10,2) NOT NULL  CHECK (unit_price > 0), 
--     stock_qty     INT           NOT NULL  DEFAULT 0  CHECK (stock_qty >= 0) 
-- );
-- CREATE INDEX idx_products_category ON products(category);


-- CREATE TABLE orders ( 
--     order_id      INT           PRIMARY KEY, 
--     customer_id   INT           NOT NULL, 
--     order_date    DATE          NOT NULL, 
--     status        VARCHAR(20)   NOT NULL  DEFAULT 'Pending' 
--                   CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')), 
--     total_amount  DECIMAL(12,2) NOT NULL  CHECK (total_amount >= 0), 
--      
--     FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
-- );
-- CREATE INDEX idx_orders_date ON orders(order_date); 
-- CREATE INDEX idx_orders_status ON orders(status);


-- CREATE TABLE order_items ( 
--     item_id       INT           PRIMARY KEY, 
--     order_id      INT           NOT NULL, 
--     product_id    INT           NOT NULL, 
--     quantity      INT           NOT NULL  CHECK (quantity > 0), 
--     unit_price    DECIMAL(10,2) NOT NULL  CHECK (unit_price > 0), 
--     discount_pct  DECIMAL(5,2)  DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100), 
--      
--     FOREIGN KEY (order_id)   REFERENCES orders(order_id), 
--     FOREIGN KEY (product_id) REFERENCES products(product_id) 
-- );

-- INSERT INTO customers VALUES 
-- (101, 'Aarav',  'Sharma', 'aarav.s@email.com',  'Mumbai',    'Maharashtra', '2024-01-15', TRUE), 
-- (102, 'Priya',  'Patel',  'priya.p@email.com',  'Ahmedabad', 'Gujarat',     '2024-02-20', FALSE), 
-- (103, 'Rohan',  'Gupta',  'rohan.g@email.com',  'Delhi',     'Delhi',       '2024-03-10', TRUE), 
-- (104, 'Sneha',  'Reddy',  'sneha.r@email.com',  'Hyderabad', 'Telangana',   '2024-04-05', FALSE), 
-- (105, 'Vikram', 'Singh',  'vikram.s@email.com', 'Jaipur',    'Rajasthan',   '2024-05-12', TRUE), 
-- (106, 'Ananya', 'Iyer',   'ananya.i@email.com', 'Chennai',   'Tamil Nadu',  '2024-06-18', FALSE), 
-- (107, 'Karan',  'Mehta',  'karan.m@email.com',  'Pune',      'Maharashtra', '2024-07-22', TRUE), 
-- (108, 'Divya',  'Nair',   'divya.n@email.com',  'Kochi',     'Kerala',      '2024-08-30', FALSE);


-- INSERT INTO products VALUES 
-- (201, 'Wireless Earbuds',     'Electronics', 'BoAt',          1499.00, 250), 
-- (202, 'Cotton T-Shirt',       'Clothing',    'Levis',         799.00,  500), 
-- (203, 'Smart Watch',          'Electronics', 'Noise',         2999.00, 150), 
-- (204, 'Running Shoes',        'Clothing',    'Nike',          4599.00, 120), 
-- (205, 'Bluetooth Speaker',    'Electronics', 'JBL',           3499.00, 200), 
-- (206, 'Bedsheet Set',         'Home',        'Spaces',        1299.00, 300), 
-- (207, 'Laptop Stand',         'Electronics', 'AmazonBasics',  899.00,  180), 
-- (208, 'Cushion Covers (Set)', 'Home',        'HomeCenter',    599.00,  400);


-- INSERT INTO orders VALUES 
-- (1001, 101, '2024-08-01', 'Delivered',  4498.00), 
-- (1002, 102, '2024-08-03', 'Delivered',  799.00), 
-- (1003, 103, '2024-08-05', 'Shipped',    7498.00), 
-- (1004, 101, '2024-08-10', 'Delivered',  3499.00), 
-- (1005, 104, '2024-08-12', 'Cancelled',  2999.00), 
-- (1006, 105, '2024-08-15', 'Delivered',  5898.00), 
-- (1007, 106, '2024-08-18', 'Pending',    1299.00), 
-- (1008, 103, '2024-08-20', 'Delivered',  899.00), 
-- (1009, 107, '2024-08-25', 'Shipped',    6098.00), 
-- (1010, 108, '2024-08-28', 'Delivered',  1598.00); 


-- INSERT INTO order_items VALUES 
-- (5001, 1001, 201, 2, 1499.00, 0), 
-- (5002, 1001, 207, 1, 899.00,  10), 
-- (5003, 1002, 202, 1, 799.00,  0), 
-- (5004, 1003, 203, 1, 2999.00, 0), 
-- (5005, 1003, 204, 1, 4599.00, 5), 
-- (5006, 1004, 205, 1, 3499.00, 0), 
-- (5007, 1005, 203, 1, 2999.00, 0), 
-- (5008, 1006, 201, 1, 1499.00, 10), 
-- (5009, 1006, 204, 1, 4599.00, 5), 
-- (5010, 1007, 206, 1, 1299.00, 0), 
-- (5011, 1008, 207, 1, 899.00,  0), 
-- (5012, 1009, 205, 1, 3499.00, 0), 
-- (5013, 1009, 208, 2, 599.00,  15), 
-- (5014, 1010, 206, 1, 1299.00, 0), 
-- (5015, 1010, 208, 1, 599.00,  0);

-- Section A — SQL Basics (SELECT, Constraints, Primary Keys) 
-- Question 1
-- select * from customers;
-- Question 2
-- select first_name, last_name,city from customers;
-- Question 3
-- select distinct category from products;
-- Question 4
-- desc customers;
-- desc order_items;
-- desc orders;
-- desc products;
-- select * from products ;
-- SHOW CREATE TABLE products;
-- A primary key is there to uniquely identify every single row in a table. If it weren't unique, you could have two customers with the exact same ID. The database would get confused, and you might end up updating or deleting the wrong person's data by mistake
-- In SQL, NULL means "unknown" or missing information. If you allow a primary key to be NOT NULL, you’re essentially creating a row with no identity. You can't search for, update, or connect a record if its identifier doesn't exist.
 -- Question 5
--  `email` varchar(100) NOT NULL,
-- NOT NULL only checks to make sure the column is not left blank or empty. It forces a user to enter something when creating a record.
-- Since only "not null" is applied on email attribute so we can insert duplicate data in email column.
-- Question 6
-- insert into products values(206,"Bluetooth headset","Electronics",'JBL',-50.0,250);
-- we have applied  CONSTRAINT `products_chk_1` CHECK ((`unit_price` > 0)) during creation of our table which prevent any invalid input in our table


-- Section B — Filtering & Optimization (WHERE, Indexes) 
-- Question 7
select * from orders where status='delivered';
-- Question 8
select * from products where category ='electronics' and unit_price>2000;
--  Question 9
select * from customers where join_date between "2024-01-01" and "2024-12-31" and state='maharashtra';
-- Question 10
select * from orders where order_date between '2024-08-10' and '2024-08-25' and status !='cancelled';




-- Section C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX)
-- Question 11
-- Fetch all orders placed in 2024
SELECT order_id, customer_id, total_amount
FROM orders
WHERE order_date = '2024-08-01';
-- Without Index
-- It scans each and every row present in the table one by one
-- Becomes very slow when the table has large amount of data
-- Uses Full Table Scan method to find the results
-- With Index
-- It directly jumps to the matching rows instead of reading all rows
-- Stays fast and efficient even when table has millions of records
-- Uses Index Seek method which is much smarter and quicker 

-- Question 12
-- No , index is not used,because we wrapped the column inside a function YEAR(join_date)
SELECT * FROM customers WHERE YEAR(join_date) = 2024;
-- index-friendly-query
SELECT * FROM customers
WHERE join_date >= '2024-01-01' 
AND   join_date <  '2025-01-01';

-- Question 13
select count(*) from orders;

-- Question 14
select sum(total_amount) as total_revenue from orders where status='delivered';

-- Question 15
select avg(unit_price) as avg_unit_price from products group by category;

-- Question 16
select
count(order_id),sum(total_amount) as total_revenue 
from orders group by status 
order by  total_revenue desc;

-- Question 17
select max(unit_price) as most_expensive,min(unit_price) as cheapest,category from products group by category;

-- Question 18
select category from products group by category having avg(unit_price)>2000;



-- Section D — Joins & Relationships 
-- Question 19 
select 
	customers.first_name,
    customers.last_name,
    orders.order_id,
    orders.order_date,
    orders.total_amount
from customers
inner join  orders
on customers.customer_id=orders.customer_id;

-- Question 20 
select
	customers.customer_id,
    customers.first_name,
    customers.last_name,
    orders.order_id,
    orders.order_date,
    orders.total_amount
from customers left join orders
on customers.customer_id=orders.customer_id;

-- Question 21
select
	orders.order_id,
    products.product_name,
    products.stock_qty,
    products.unit_price,
    order_items.discount_pct
from orders inner join 
	order_items on orders.order_id=order_items.order_id
inner join 
	products on products.product_id=order_items.product_id;
    
-- Question 22
-- Left Join
SELECT c.customer_id, c.first_name, o.order_id, o.total_amount
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;
-- Right Join
SELECT c.customer_id, c.first_name, o.order_id, o.total_amount
FROM customers c
RIGHT JOIN orders o
ON c.customer_id = o.customer_id;
-- We use Full Outer join when we want to fetch the unmatched data from different tables
SELECT 
    c.customer_id, 
    c.first_name, 
    o.order_id, 
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT 
    c.customer_id, 
    c.first_name, 
    o.order_id, 
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;
-- Question 23
-- • Table 'orders' links to 'customers' via foreign key (customer_id)
-- • Table 'order_items' links to 'orders' via foreign key (order_id)
-- • Table 'order_items' links to 'products' via foreign key (product_id)
-- Attempting to insert an order for a non-existent customer (ID: 999)

INSERT INTO orders (order_id, customer_id, order_date) 
VALUES (5005, 999, '2026-05-30');


/* Foreign keys enforce referential integrity. Because customer_id '999' 
   does not exist in the parent 'customers' table, the database system 
   strictly blocks this insert.
*/
-- Question 24 
select product_name, unit_price,
case
	when unit_price<1000 then 'budget'
    when unit_price between 1000 and 3000 then 'Mid Range'
    when unit_price>3000 then 'Premium'
end as price_tier
from products;
-- Question 25
select 
	count(case when status='delivered' then 1 end)as Delivered_Order,
    count(case when status!='delivered' then 1 end)as Not_Delivered_Ordee
from orders;
-- Question 26
/* ===================================================================
THE ACID PROPERTIES OF DATABASE TRANSACTIONS (BANK TRANSFER EXAMPLE)
===================================================================
A Transaction is a single unit of work (e.g., Transfer $100 from A to B).

• ATOMICITY ("All or Nothing")
  - Meaning: All SQL statements must succeed, or the entire transaction fails.
  - Why it matters: If power cuts after deducting $100 from A but before 
    adding to B, the database rolls back to prevent money from vanishing.

• CONSISTENCY ("Data Integrity")
  - Meaning: A transaction must follow all database rules and constraints.
  - Why it matters: If Account A only has $20, a constraint rule blocks 
    the $100 transfer to prevent an illegal negative balance.

• ISOLATION ("Concurrency Control")
  - Meaning: Concurrent transactions cannot interfere or see each other's midway data.
  - Why it matters: If a salary deposit happens at the exact same millisecond 
    as the transfer, they run in bubbles to prevent overwriting each other's calculations.

• DURABILITY ("Permanent Storage")
  - Meaning: Once committed, data changes are permanent and survive system crashes.
  - Why it matters: The instant a "Success" message shows, the data is written 
    to the hard drive, so a sudden server crash won't erase the transaction records.
===================================================================
*/
START TRANSACTION;
	UPDATE accounts SET balance = balance - 100 WHERE account_id = 'A';
	UPDATE accounts SET balance = balance + 100 WHERE account_id = 'B';
COMMIT;
-- Question 27
begin;
	insert into orders(order_id,customer_id,order_date,status,total_amount)
	values(1011,101,current_date,'pending',1590.0);
    INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price)
    VALUES (1, 1011, 501, 2, 499.00);  
    INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price)
    VALUES (2, 1011, 502, 1, 600.00);
    UPDATE products SET stock_qty = stock_qty - 2 WHERE product_id = 501;
    UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 502;
commit;
rollback;

