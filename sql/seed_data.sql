INSERT INTO dim_date (date_key, full_date, day_num, month_num, month_name,
                      quarter_num, year_num, week_of_year, day_of_week,
                      day_name, is_weekend)
SELECT TO_NUMBER(TO_CHAR(s.d,'YYYYMMDD')), s.d,
       EXTRACT(DAY FROM s.d), EXTRACT(MONTH FROM s.d),
       TRIM(TO_CHAR(s.d,'Month','NLS_DATE_LANGUAGE=ENGLISH')),
       TO_NUMBER(TO_CHAR(s.d,'Q')), EXTRACT(YEAR FROM s.d),
       TO_NUMBER(TO_CHAR(s.d,'IW')),
       (s.d - TRUNC(s.d,'IW')) + 1,
       TRIM(TO_CHAR(s.d,'Day','NLS_DATE_LANGUAGE=ENGLISH')),
       CASE WHEN (s.d - TRUNC(s.d,'IW')) >= 5 THEN 1 ELSE 0 END
FROM (SELECT DATE '2010-01-01' + LEVEL - 1 AS d
      FROM dual
      CONNECT BY LEVEL <= (DATE '2030-12-31' - DATE '2010-01-01' + 1)) s
WHERE NOT EXISTS (SELECT 1 FROM dim_date x WHERE x.full_date = s.d);

INSERT INTO dim_customer (customer_key, customer_id, customer_name, segment)
SELECT -1,'UNKNOWN','Unknown Customer','Unknown' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM dim_customer WHERE customer_key = -1);

INSERT INTO dim_product (product_key, product_id, product_name, category, sub_category)
SELECT -1,'UNKNOWN','Unknown Product','Unknown','Unknown' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM dim_product WHERE product_key = -1);

INSERT INTO dim_geography (geography_key, country, state, city, postal_code, region)
SELECT -1,'Unknown','Unknown','Unknown','N/A','Unknown' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM dim_geography WHERE geography_key = -1);

INSERT INTO dim_date (date_key, full_date, day_num, month_num, month_name,
                      quarter_num, year_num, is_weekend)
SELECT -1, DATE '1900-01-01', 1, 1, 'Unknown', 1, 1900, 0 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM dim_date WHERE date_key = -1);

COMMIT;