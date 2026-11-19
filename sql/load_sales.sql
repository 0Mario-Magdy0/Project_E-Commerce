MERGE INTO fact_sales f
USING (
    SELECT v.row_id, v.order_id,
           NVL(c.customer_key,  -1) AS customer_key,
           NVL(p.product_key,   -1) AS product_key,
           NVL(g.geography_key, -1) AS geography_key,
           NVL(od.date_key,     -1) AS order_date_key,
           NVL(sd.date_key,     -1) AS ship_date_key,
           v.ship_mode,
           v.sales AS sales_amount,
           v.quantity, v.discount_rate, v.profit,
           CASE WHEN v.ship_date IS NOT NULL AND v.order_date IS NOT NULL
                THEN v.ship_date - v.order_date END AS shipping_days
    FROM vw_stg_sales_clean v
    LEFT JOIN dim_customer  c  ON c.customer_id = v.customer_id
    LEFT JOIN dim_product   p  ON p.product_id  = v.product_id
    LEFT JOIN dim_geography g  ON g.country = v.country AND g.state = v.state
                              AND g.city = v.city AND g.postal_code = v.postal_code
    LEFT JOIN dim_date      od ON od.full_date = v.order_date
    LEFT JOIN dim_date      sd ON sd.full_date = v.ship_date
) s
ON (f.row_id = s.row_id)
WHEN MATCHED THEN UPDATE SET
    f.order_id = s.order_id, f.customer_key = s.customer_key,
    f.product_key = s.product_key, f.geography_key = s.geography_key,
    f.order_date_key = s.order_date_key, f.ship_date_key = s.ship_date_key,
    f.ship_mode = s.ship_mode, f.sales_amount = s.sales_amount,
    f.quantity = s.quantity, f.discount_rate = s.discount_rate,
    f.profit = s.profit, f.shipping_days = s.shipping_days,
    f.loaded_at = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT
    (row_id, order_id, customer_key, product_key, geography_key,
     order_date_key, ship_date_key, ship_mode, sales_amount,
     quantity, discount_rate, profit, shipping_days)
VALUES
    (s.row_id, s.order_id, s.customer_key, s.product_key, s.geography_key,
     s.order_date_key, s.ship_date_key, s.ship_mode, s.sales_amount,
     s.quantity, s.discount_rate, s.profit, s.shipping_days);

COMMIT;