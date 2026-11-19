CREATE OR REPLACE VIEW vw_daily_sales AS
SELECT d.full_date,
       COUNT(DISTINCT f.order_id) AS orders_count,
       ROUND(SUM(f.sales_amount),2) AS revenue
FROM fact_sales f JOIN dim_date d ON d.date_key = f.order_date_key
GROUP BY d.full_date;

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT d.year_num, d.month_num, d.month_name,
       ROUND(SUM(f.sales_amount),2) AS revenue,
       COUNT(DISTINCT f.order_id)   AS orders_count,
       ROUND(SUM(f.sales_amount) / NULLIF(COUNT(DISTINCT f.order_id),0), 2) AS avg_order_value
FROM fact_sales f JOIN dim_date d ON d.date_key = f.order_date_key
GROUP BY d.year_num, d.month_num, d.month_name;

CREATE OR REPLACE VIEW vw_sales_by_category AS
SELECT p.category, p.sub_category,
       COUNT(DISTINCT f.order_id)   AS orders_count,
       ROUND(SUM(f.sales_amount),2) AS revenue
FROM fact_sales f JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.category, p.sub_category;

CREATE OR REPLACE VIEW vw_top_products AS
SELECT p.product_id, p.product_name, p.category,
       ROUND(SUM(f.sales_amount),2) AS revenue,
       RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM fact_sales f JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.product_id, p.product_name, p.category;

CREATE OR REPLACE VIEW vw_customer_value AS
SELECT c.customer_id, c.customer_name, c.segment,
       COUNT(DISTINCT f.order_id)   AS orders_count,
       ROUND(SUM(f.sales_amount),2) AS lifetime_value,
       MIN(d.full_date) AS first_order,
       MAX(d.full_date) AS last_order
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
JOIN dim_date d     ON d.date_key     = f.order_date_key
GROUP BY c.customer_id, c.customer_name, c.segment;

CREATE OR REPLACE VIEW vw_sales_by_region AS
SELECT g.region, g.state,
       COUNT(DISTINCT f.order_id)   AS orders_count,
       ROUND(SUM(f.sales_amount),2) AS revenue
FROM fact_sales f JOIN dim_geography g ON g.geography_key = f.geography_key
GROUP BY g.region, g.state;

CREATE OR REPLACE VIEW vw_shipping_performance AS
SELECT f.ship_mode,
       COUNT(*)                       AS lines_count,
       ROUND(AVG(f.shipping_days),2)  AS avg_shipping_days,
       MAX(f.shipping_days)           AS max_shipping_days
FROM fact_sales f
GROUP BY f.ship_mode;