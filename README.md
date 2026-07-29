# SQL Data Analysis - Brazilian E-Commerce Project

## Overview
This project contains a collection of SQL queries written to explore and analyze an e-commerce dataset from Brazil (Olist dataset). The goal of this project is to practice writing core SQL queries to answer practical business questions regarding sales, customers, shipping, and seller performance.

---

## Database Tables Used
* `orders` - Information about order status and delivery dates.
* `order_items` - Product details, item prices, and freight values for each order.
* `order_payments` - Payment types and payment amounts.
* `customers` - Customer locations and unique customer IDs.
* `products` - Product details and category names.
* `product_category_name_translation` - English translation for product categories.
* `order_reviews` - Review scores given by customers.

---

## Business Questions & SQL Queries

### 1. View Product Category Translations
**Question:** Display the first 10 rows of the category translation table.
```sql
SELECT * FROM product_category_name_translation LIMIT 10;

1] What is the total count of orders placed?
      SELECT COUNT(order_id) AS no_of_orders 
       FROM orders;
2] What is the overall total revenue from all payment transactions?
         SELECT SUM(payment_value) AS total_revenue 
      FROM order_payments;

3] What is the overall total revenue from all payment transactions?
          SELECT SUM(payment_value) AS total_revenue 
      FROM order_payments;
4] How many unique customers placed orders?
          SELECT COUNT(DISTINCT customer_unique_id) AS unique_id 
      FROM customers;
5] How many orders fall into each order status?
                SELECT 
            order_status,
            COUNT(*) AS total_orders
        FROM orders
        GROUP BY 1
        ORDER BY total_orders DESC;
6] What are the top 5 product categories by total sales amount (in English)?
          SELECT 
            pct.product_category_name_english,
            SUM(oi.price) AS total_sales
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
        GROUP BY pct.product_category_name_english
        ORDER BY total_sales DESC
        LIMIT 5;
7] What are the total transactions and average amount for each payment type?
          SELECT 
            payment_type,
            COUNT(*) AS total_transactions,
            ROUND(AVG(payment_value), 2) AS avg_payment_value
        FROM order_payments
        GROUP BY payment_type
        ORDER BY total_transactions DESC;

8] What is the average delay in delivery (actual delivery date minus estimated date) for each customer state?
              SELECT 
            c.customer_state,
            ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)))::numeric, 2) AS avg_delay_days
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.order_delivered_customer_date IS NOT NULL
        GROUP BY c.customer_state
        ORDER BY avg_delay_days DESC;

9] Do late deliveries get lower customer review ratings compared to on-time deliveries?
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

10] Which states generate the most revenue?
          SELECT 
              c.customer_state,
              ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
          FROM orders o
          JOIN customers c ON o.customer_id = c.customer_id
          JOIN order_items oi ON o.order_id = oi.order_id
          GROUP BY c.customer_state
          ORDER BY total_revenue DESC;
11] Which 10 sellers made the highest total sales?
        SELECT 
            seller_id,
            ROUND(SUM(price)::numeric, 2) AS total_revenue
        FROM order_items
        GROUP BY seller_id
        ORDER BY total_revenue DESC
        LIMIT 10;

12] How did the number of orders change month by month between 2016 and 2018?
          SELECT 
            TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS year_month,
            COUNT(order_id) AS total_orders
        FROM orders
        WHERE order_purchase_timestamp BETWEEN '2016-01-01' AND '2018-12-31'
        GROUP BY TO_CHAR(order_purchase_timestamp, 'YYYY-MM')
        ORDER BY year_month ASC;
