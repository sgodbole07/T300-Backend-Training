SELECT current_database();

-- Initial data population
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(100),
    email         VARCHAR(150) UNIQUE
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id  INT NOT NULL REFERENCES products(product_id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    order_date  DATE NOT NULL
);

INSERT INTO customers (customer_id, customer_name, city, email) VALUES
    (1,  'Aarav Sharma',   'Mumbai',    'aarav.sharma@example.com'),
    (2,  'Priya Nair',     'Kochi',     'priya.nair@example.com'),
    (3,  'Rohan Mehta',    'Ahmedabad', 'rohan.mehta@example.com'),
    (4,  'Ananya Iyer',    'Chennai',   'ananya.iyer@example.com'),
    (5,  'Vikram Singh',   'Jaipur',    'vikram.singh@example.com'),
    (6,  'Sneha Patil',    'Pune',      'sneha.patil@example.com'),
    (7,  'Arjun Reddy',    'Hyderabad', 'arjun.reddy@example.com'),
    (8,  'Kavya Menon',    'Bengaluru', 'kavya.menon@example.com'),
    (9,  'Rahul Verma',    'Delhi',     'rahul.verma@example.com'),
    (10, 'Isha Banerjee',  'Kolkata',   'isha.banerjee@example.com');

INSERT INTO products (product_id, product_name, category, price) VALUES
    (1,  'Wireless Headphones',  'Electronics',     1999.00),
    (2,  'Smartphone 128GB',     'Electronics',    15999.00),
    (3,  'Laptop 15.6 inch',     'Electronics',    54999.00),
    (4,  'Bluetooth Speaker',    'Electronics',     2499.00),
    (5,  'Mixer Grinder',        'Home Appliances', 3499.00),
    (6,  'Electric Kettle',      'Home Appliances', 1299.00),
    (7,  'Cotton Kurta',         'Clothing',         899.00),
    (8,  'Running Shoes',        'Footwear',        2799.00),
    (9,  'Notebook Pack (5)',    'Stationery',       350.00),
    (10, 'Steel Water Bottle',   'Home & Kitchen',   599.00);

INSERT INTO orders (order_id, customer_id, product_id, quantity, order_date) VALUES
    (1,  1, 3, 1,  '2026-08-05'),
    (2,  2, 1, 2,  '2026-08-12'),
    (3,  3, 2, 1,  '2026-08-20'),
    (4,  4, 5, 1,  '2026-09-02'),
    (5,  5, 8, 2,  '2026-09-10'),
    (6,  6, 4, 1,  '2026-09-15'),
    (7,  7, 7, 3,  '2026-09-22'),
    (8,  8, 9, 5,  '2026-09-28'),
    (9,  9, 6, 2,  '2026-10-03'),
    (10, 1, 1, 1,  '2026-10-08'),
    (11, 2, 2, 1,  '2026-10-12'),
    (12, 3, 5, 2,  '2026-10-18'),
    (13, 4, 3, 1,  '2026-10-25'),
    (14, 5, 4, 2,  '2026-10-30'),
    (15, 6, 8, 1,  '2026-11-02'),
    (16, 7, 2, 2,  '2026-11-05'),
    (17, 8, 7, 2,  '2026-11-09'),
    (18, 9, 1, 1,  '2026-11-12'),
    (19, 1, 6, 3,  '2026-11-15'),
    (20, 3, 9, 10, '2026-11-18'),
    (21, 5, 2, 1,  '2026-11-20'),
    (22, 2, 8, 1,  '2026-11-22');

SELECT (SELECT COUNT(*) FROM customers) AS customers,
       (SELECT COUNT(*) FROM products)  AS products,
       (SELECT COUNT(*) FROM orders)    AS orders;


-- Section 1: Advanced Joins
-- Task 1: Display each customer along with the products they ordered.


SELECT c.customer_id, c.customer_name, o.order_id, o.quantity, o.order_date,
       o.product_id, p.product_name
FROM customers c
INNER JOIN orders o   ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id  = p.product_id
ORDER BY c.customer_id;


-- Task 2: Display all possible combinations of customers and products using a CROSS JOIN.
SELECT c.customer_id, c.customer_name, p.product_name , p.price , p.product_id , p.category  FROM customers c
CROSS JOIN
products p;

-- Task 3: Display all customers and their orders, including customers who have not placed any orders

SELECT 
    c.customer_name, 
    o.order_id, 
    o.order_date
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id;



-- Section 2: Subqueries
-- Task 4: Find products priced above the average product price.
SELECT p.product_name, p.price FROM products p WHERE p.price > 
	(SELECT AVG(p.price) FROM products p);



-- Task 5: Display customers whose total purchase amount is greater than the average customer purchase amount.

SELECT result.customer_id,
       result.totalOrderValue
FROM (
    SELECT c.customer_id,
           COALESCE(SUM(p.price * o.quantity), 0) AS totalOrderValue
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id
) AS result
WHERE result.totalOrderValue > (
    SELECT AVG(t.totalOrderValue)
    FROM (
        SELECT c.customer_id,
               COALESCE(SUM(p.price * o.quantity), 0) AS totalOrderValue
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN products p ON o.product_id = p.product_id
        GROUP BY c.customer_id
    ) AS t
)
ORDER BY result.totalOrderValue DESC;



-- Task 6: Find the highest-priced product in each category using a correlated subquery.

SELECT p.category, p.product_name, p.price
FROM products p
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products p2
    WHERE p2.category = p.category
)
ORDER BY p.category;



-- Section 3: Set Operations

-- Task 7: Combine products from two different categories using UNION.

(SELECT p.product_id , p.product_name , p.category , p.price  FROM products p WHERE p.category = 'Electronics') UNION ALL 
(SELECT p.product_id , p.product_name , p.category , p.price FROM products p WHERE p.category = 'Home Appliances');

-- Task 8: Write MySQL alternatives for INTERSECT and EXCEPT using INNER JOIN and LEFT JOIN.

SELECT c.customer_id  FROM customers c 
INTERSECT 
SELECT o.customer_id FROM orders o;


SELECT DISTINCT(c.customer_id) FROM customers c 
INNER JOIN orders o
ON c.customer_id = o.customer_id 


-- Section 4: Window Functions
-- Task 9: Rank products by price within each category.
SELECT category,
       product_name,
       price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM products
ORDER BY category, price_rank;

-- Task 10: Display the previous product price (LAG) and a running total of product prices using
-- window functions.
SELECT product_id,
       product_name,
       price,
       LAG(price) OVER (ORDER BY product_id) AS previous_price,
       SUM(price) OVER (ORDER BY product_id
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM products
ORDER BY product_id;


-- Section 5: Common Table Expressions (CTEs)


-- Task 11: Create a CTE to display customers whose total purchase amount is above the average.

	WITH customer_totals AS (
    SELECT c.customer_id,
           COALESCE(SUM(p.price * o.quantity), 0) AS total_order_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id
)
SELECT customer_id,
       total_order_value
FROM customer_totals
WHERE total_order_value > (SELECT AVG(total_order_value) FROM customer_totals)
ORDER BY total_order_value DESC;



-- Task 12: Create a recursive CTE to generate a sequence of numbers from 1 to 10.

WITH RECURSIVE numbers AS (
    SELECT 1 AS n             
    UNION ALL
    SELECT n + 1              
    FROM numbers
    WHERE n < 10
)
SELECT n FROM numbers;


-- Section 6: Views
-- Task 13: Create a view that displays products priced above ₹1,000 and retrieve data from the view.

CREATE VIEW costly_products AS 
SELECT p.product_name, p.product_id, p.price, p.category
FROM products p 
WHERE p.price > 1000 
ORDER BY p.price;


SELECT * FROM costly_products;

-- Section 7: Indexes and Query Performance
-- Task 14: Create an index on the category column of the Products
CREATE INDEX index_products_category ON products (category);

SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'products';

-- Task 15: Use EXPLAIN to analyze a query that filters products by category.
EXPLAIN SELECT * FROM products WHERE category = 'Electronics';

-- Section 8: Stored Procedures and Functions

CREATE OR REPLACE FUNCTION get_product_by_category(product_category VARCHAR(50))
RETURNS SETOF products
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM products AS p
    WHERE p.category = product_category;
END;
$$;

SELECT * FROM get_product_by_category('Electronics');


-- Task 17: Create a function to calculate the total price of an order (price × quantity).
-- USING ORDER id TO GET the price ad quantity details
	
	
CREATE OR REPLACE FUNCTION total_price_of_order(orderID int)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    total_amount NUMERIC;
BEGIN 

    SELECT COALESCE(SUM(p.price * o.quantity), 0)
    INTO total_amount
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    WHERE o.order_id = orderID;
    
    RETURN total_amount;
END
$$

SELECT total_price_of_order(8);

-- Section 9: Transactions
-- Task 18: Write a transaction that updates a product's price and demonstrate the use of COMMIT
-- and ROLLBACK.


-- COMMIT usage
BEGIN ;
	
	UPDATE products SET price = 5000 WHERE product_id = 1; 
	SELECT product_id, product_name, price FROM products WHERE product_id = 1;

	COMMIT;
END;

SELECT product_id, product_name, price FROM products WHERE product_id = 1;

-- ROLLBACK usage


BEGIN;
	
	UPDATE products SET price = 3000 WHERE product_id = 1; 
	SELECT product_id, product_name, price FROM products WHERE product_id = 1;

ROLLBACK;


SELECT product_id, product_name, price FROM products WHERE product_id = 1;



-- Section 10: SQL Triggers
-- Task 19: Create a trigger that automatically records new orders in an Order_Audit table whenever
-- a new order is inserted.

CREATE TABLE order_Audit (
    order_id    INT PRIMARY KEY,
    quantity    INT NOT NULL CHECK (quantity > 0),
    product_id  INT NOT NULL REFERENCES products(product_id)
);


CREATE OR REPLACE FUNCTION handle_new_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_Audit(order_id, quantity, product_id)
    VALUES(NEW.order_id, NEW.quantity, NEW.product_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_order_inserted
AFTER INSERT ON "orders"
FOR EACH ROW
EXECUTE FUNCTION handle_new_order();

INSERT INTO orders (order_id, customer_id, product_id, quantity, order_date) VALUES
(23, 6, 3, 1,  '2026-08-17');

SELECT * FROM order_Audit;







