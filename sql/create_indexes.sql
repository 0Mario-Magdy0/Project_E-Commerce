CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_product  ON fact_sales(product_key);
CREATE INDEX idx_fact_geo      ON fact_sales(geography_key);
CREATE INDEX idx_fact_odate    ON fact_sales(order_date_key);
CREATE INDEX idx_fact_sdate    ON fact_sales(ship_date_key);
CREATE INDEX idx_fact_order    ON fact_sales(order_id);
CREATE INDEX idx_fact_shipmode ON fact_sales(ship_mode);

CREATE INDEX idx_product_cat   ON dim_product(category, sub_category);
CREATE INDEX idx_customer_seg  ON dim_customer(segment);
CREATE INDEX idx_geo_region    ON dim_geography(region, state);
CREATE INDEX idx_date_ym       ON dim_date(year_num, month_num);