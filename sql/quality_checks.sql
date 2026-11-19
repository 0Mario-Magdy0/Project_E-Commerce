CREATE OR REPLACE VIEW vw_dq_checks AS
SELECT 'orphan_customer_fk' AS check_name, COUNT(*) AS failed_rows,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM fact_sales f LEFT JOIN dim_customer c ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL
UNION ALL
SELECT 'orphan_product_fk', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales f LEFT JOIN dim_product p ON p.product_key = f.product_key
WHERE p.product_key IS NULL
UNION ALL
SELECT 'orphan_geography_fk', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales f LEFT JOIN dim_geography g ON g.geography_key = f.geography_key
WHERE g.geography_key IS NULL
UNION ALL
SELECT 'orphan_date_fk', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales f
LEFT JOIN dim_date d1 ON d1.date_key = f.order_date_key
LEFT JOIN dim_date d2 ON d2.date_key = f.ship_date_key
WHERE d1.date_key IS NULL OR d2.date_key IS NULL
UNION ALL
SELECT 'duplicate_row_id', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT row_id FROM fact_sales GROUP BY row_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'negative_or_null_sales', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales WHERE sales_amount IS NULL OR sales_amount < 0
UNION ALL
SELECT 'ship_date_before_order_date', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales WHERE shipping_days < 0
UNION ALL
SELECT 'staging_rows_missing_in_fact', COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM vw_stg_sales_clean v
WHERE NOT EXISTS (SELECT 1 FROM fact_sales f WHERE f.row_id = v.row_id)
UNION ALL
SELECT 'unknown_keys_over_5pct',
       NVL(SUM(CASE WHEN customer_key=-1 OR product_key=-1 OR geography_key=-1
                      OR order_date_key=-1 THEN 1 ELSE 0 END), 0),
       CASE WHEN COUNT(*) = 0 THEN 'FAIL'
            WHEN SUM(CASE WHEN customer_key=-1 OR product_key=-1 OR geography_key=-1
                            OR order_date_key=-1 THEN 1 ELSE 0 END) / COUNT(*) <= 0.05
            THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales
UNION ALL
SELECT 'fact_table_empty', CASE WHEN COUNT(*)=0 THEN 1 ELSE 0 END,
       CASE WHEN COUNT(*)>0 THEN 'PASS' ELSE 'FAIL' END
FROM fact_sales;