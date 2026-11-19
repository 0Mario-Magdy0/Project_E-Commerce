CREATE TABLE stg_sales (
    row_id         NUMBER,
    order_id       VARCHAR2(30),
    order_date     DATE,
    ship_date      DATE,
    ship_mode      VARCHAR2(30),
    customer_id    VARCHAR2(20),
    customer_name  VARCHAR2(200),
    segment        VARCHAR2(30),
    country        VARCHAR2(100),
    city           VARCHAR2(100),
    state          VARCHAR2(100),
    postal_code    VARCHAR2(10),
    region         VARCHAR2(30),
    product_id     VARCHAR2(30),
    category       VARCHAR2(50),
    sub_category   VARCHAR2(50),
    product_name   VARCHAR2(255),
    sales          NUMBER(14,4),
    quantity       NUMBER(8),
    discount_rate  NUMBER(5,4),
    profit         NUMBER(14,4),
    loaded_at      TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE rejected_records (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_name  VARCHAR2(50),
    record_data  CLOB,
    reason       VARCHAR2(1000),
    rejected_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE VIEW vw_stg_sales_clean AS
SELECT row_id, order_id, order_date, ship_date, ship_mode,
       customer_id, customer_name, segment,
       NVL(country,'N/A') AS country,
       NVL(state,'N/A')   AS state,
       NVL(city,'N/A')    AS city,
       CASE WHEN postal_code IS NULL THEN 'N/A'
            ELSE LPAD(TRIM(postal_code), 5, '0') END AS postal_code,
       region, product_id, product_name, category, sub_category,
       sales, quantity, discount_rate, profit, loaded_at
FROM (
    SELECT x.row_id, x.order_id, TRUNC(x.order_date) AS order_date,
           TRUNC(x.ship_date) AS ship_date, x.ship_mode,
           x.customer_id, x.customer_name, x.segment,
           x.country, x.state, x.city, x.postal_code, x.region,
           x.product_id, x.product_name, x.category, x.sub_category,
           x.sales, x.quantity, x.discount_rate, x.profit, x.loaded_at,
           ROW_NUMBER() OVER (PARTITION BY x.row_id
                              ORDER BY x.loaded_at DESC, x.ROWID DESC) AS rn
    FROM stg_sales x
    WHERE x.row_id   IS NOT NULL
      AND x.order_id IS NOT NULL
      AND x.sales    IS NOT NULL
)
WHERE rn = 1;