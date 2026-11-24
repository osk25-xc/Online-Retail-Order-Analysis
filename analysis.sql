-- Online Retail Order Analysis | PostgreSQL
-- Synthetic practice dataset.
DROP TABLE IF EXISTS retail_orders;
CREATE TABLE retail_orders (
 order_id INT PRIMARY KEY, order_date DATE, customer_id INT, product_category VARCHAR(35),
 quantity INT, unit_price NUMERIC(10,2), discount_pct NUMERIC(5,2),
 order_status VARCHAR(20), delivery_days INT
);
INSERT INTO retail_orders VALUES
(501,'2026-01-02',11,'Electronics',1,15999,5,'Delivered',3),
(502,'2026-01-03',12,'Fashion',2,1499,10,'Delivered',5),
(503,'2026-01-05',13,'Home',1,4999,0,'Returned',8),
(504,'2026-01-08',11,'Beauty',3,599,5,'Delivered',2),
(505,'2026-01-12',14,'Electronics',1,8999,8,'Cancelled',NULL),
(506,'2026-02-01',15,'Fashion',2,2199,10,'Delivered',4),
(507,'2026-02-04',12,'Home',1,3299,0,'Delivered',6),
(508,'2026-02-10',16,'Electronics',1,22999,5,'Delivered',3),
(509,'2026-02-14',13,'Beauty',4,499,0,'Returned',7),
(510,'2026-03-02',17,'Fashion',1,2999,15,'Delivered',2),
(511,'2026-03-08',14,'Home',2,1899,5,'Pending',NULL),
(512,'2026-03-12',15,'Electronics',1,11999,10,'Delivered',5);
-- 1. Net sales after discounts
SELECT SUM(quantity*unit_price*(1-discount_pct/100.0)) AS net_sales FROM retail_orders
WHERE order_status <> 'Cancelled';
-- 2. Order funnel by status
SELECT order_status, COUNT(*) AS orders FROM retail_orders GROUP BY 1 ORDER BY orders DESC;
-- 3. Category sales and units
SELECT product_category, SUM(quantity) AS units,
 ROUND(SUM(quantity*unit_price*(1-discount_pct/100.0)),2) AS net_sales
FROM retail_orders WHERE order_status NOT IN ('Cancelled','Returned')
GROUP BY 1 ORDER BY net_sales DESC;
-- 4. Monthly sales
SELECT DATE_TRUNC('month',order_date)::date AS month,
 SUM(quantity*unit_price*(1-discount_pct/100.0)) AS net_sales
FROM retail_orders WHERE order_status='Delivered' GROUP BY 1 ORDER BY 1;
-- 5. Delivery speed
SELECT ROUND(AVG(delivery_days),2) AS avg_delivery_days,
 COUNT(*) FILTER (WHERE delivery_days > 5) AS deliveries_over_5_days
FROM retail_orders WHERE order_status='Delivered';
-- 6. Return rate by category
SELECT product_category, COUNT(*) FILTER (WHERE order_status='Returned') AS returns,
 COUNT(*) AS placed_orders,
 ROUND(100.0*COUNT(*) FILTER (WHERE order_status='Returned')/COUNT(*),2) AS return_rate_pct
FROM retail_orders GROUP BY 1;
-- 7. Customer order frequency
SELECT customer_id, COUNT(*) AS orders,
 SUM(quantity*unit_price*(1-discount_pct/100.0)) AS gross_value
FROM retail_orders GROUP BY customer_id ORDER BY gross_value DESC;
-- 8. Discount impact by discount band
SELECT CASE WHEN discount_pct=0 THEN 'No discount' WHEN discount_pct<=5 THEN '1-5%'
 WHEN discount_pct<=10 THEN '6-10%' ELSE 'Above 10%' END AS discount_band,
 COUNT(*) AS orders, AVG(quantity*unit_price*(1-discount_pct/100.0)) AS avg_net_order
FROM retail_orders GROUP BY 1 ORDER BY 1;
