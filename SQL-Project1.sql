-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- 2. Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- 3. Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 4. Product Category Name Translation Table
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- 5. Geolocation Table
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- 6. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 7. Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);
-- 8. Order Payments Table
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10, 2)
);

-- 9. Order Reviews Table
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

select* from product_category_name_translation limit 10;


-- Total number of orders in the orders table.
		select count(order_id) as no_of_orders 
								from orders;

-- Calculate the total revenue generated across all payments from the order_payments table.
		select sum(payment_value) as total_revenue
									from order_payments;

-- Find the total number of unique customers using customer_unique_id from the customers table.
		select  count(distinct customer_unique_id) as unique_id 
												from customers;

-- Count how many orders exist for each order_status in the orders table
			select
			     order_status,
						count(*)
					   from orders
			      group by 1;
				  
-- Join order_items, products, and product_category_name_translation to display the top 5 English product category names by total sales value.
         
			    SELECT 
			    pct.product_category_name_english,
			    SUM(oi.price) AS total_sales
					FROM order_items oi
					JOIN products p 
					    ON oi.product_id = p.product_id
					JOIN product_category_name_translation pct 
					    ON p.product_category_name = pct.product_category_name
						GROUP BY pct.product_category_name_english
						ORDER BY total_sales DESC
						LIMIT 5; 



-- Display each payment_type along with its total number of transactions and average payment_value, sorted by highest transaction count.


			SELECT 
				    payment_type,
				    COUNT(*) AS total_transactions,
				    round(AVG(payment_value),2) AS avg_payment_value
				FROM order_payments
				GROUP BY payment_type
				ORDER BY total_transactions DESC;


-- What is the average delivery delay (order_delivered_customer_date - order_estimated_delivery_date) by customer state?

SELECT 
    c.customer_state,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)))::numeric, 2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;

-- Is there a correlation between delivery delay and review score — do late orders get lower ratings?
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late Delivery'
        ELSE 'On-Time / Early'
    END AS delivery_status,
    COUNT(r.review_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY avg_review_score ASC;

--What is total revenue by customer state, ranked highest to lowest?
SELECT 
    c.customer_state,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

--Which 10 sellers generated the highest total revenue?
SELECT 
    seller_id,
    ROUND(SUM(price)::numeric, 2) AS total_revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Monthly order volume trend, 2016–2018 — growing, flat, or declining?
SELECT 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS year_month,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_purchase_timestamp BETWEEN '2016-01-01' AND '2018-12-31'
GROUP BY TO_CHAR(order_purchase_timestamp, 'YYYY-MM')
ORDER BY year_month ASC;


