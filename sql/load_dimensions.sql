MERGE INTO dim_customer t
USING (
    SELECT customer_id, customer_name, segment FROM (
        SELECT customer_id, customer_name, segment,
               ROW_NUMBER() OVER (PARTITION BY customer_id
                                  ORDER BY loaded_at DESC, row_id DESC) rn
        FROM vw_stg_sales_clean WHERE customer_id IS NOT NULL)
    WHERE rn = 1
) s
ON (t.customer_id = s.customer_id)
WHEN MATCHED THEN UPDATE SET
    t.customer_name = s.customer_name,
    t.segment       = s.segment,
    t.updated_at    = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT (customer_id, customer_name, segment)
VALUES (s.customer_id, s.customer_name, s.segment);

MERGE INTO dim_product t
USING (
    SELECT product_id, product_name, category, sub_category FROM (
        SELECT product_id, product_name, category, sub_category,
               ROW_NUMBER() OVER (PARTITION BY product_id
                                  ORDER BY loaded_at DESC, row_id DESC) rn
        FROM vw_stg_sales_clean WHERE product_id IS NOT NULL)
    WHERE rn = 1
) s
ON (t.product_id = s.product_id)
WHEN MATCHED THEN UPDATE SET
    t.product_name = s.product_name,
    t.category     = s.category,
    t.sub_category = s.sub_category,
    t.updated_at   = SYSTIMESTAMP
WHEN NOT MATCHED THEN INSERT (product_id, product_name, category, sub_category)
VALUES (s.product_id, s.product_name, s.category, s.sub_category);

MERGE INTO dim_geography t
USING (
    SELECT country, state, city, postal_code, region FROM (
        SELECT country, state, city, postal_code, region,
               ROW_NUMBER() OVER (PARTITION BY country, state, city, postal_code
                                  ORDER BY row_id DESC) rn
        FROM vw_stg_sales_clean)
    WHERE rn = 1
) s
ON (t.country = s.country AND t.state = s.state
    AND t.city = s.city AND t.postal_code = s.postal_code)
WHEN MATCHED THEN UPDATE SET t.region = s.region
WHEN NOT MATCHED THEN INSERT (country, state, city, postal_code, region)
VALUES (s.country, s.state, s.city, s.postal_code, s.region);

COMMIT;