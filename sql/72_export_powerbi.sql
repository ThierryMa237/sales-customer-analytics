\copy (SELECT order_id, order_item_id, order_date, customer_key, product_key, geography_key, seller_id, quantity, revenue, freight_value, is_first_purchase_day::int AS is_first_purchase_day FROM bi.fact_sales ORDER BY order_id, order_item_id) TO 'powerbi/data/fact_sales.csv' WITH (FORMAT csv, HEADER true)
\copy bi.dim_customer  TO 'powerbi/data/dim_customer.csv'  WITH (FORMAT csv, HEADER true)
\copy bi.dim_product   TO 'powerbi/data/dim_product.csv'   WITH (FORMAT csv, HEADER true)
\copy bi.dim_geography TO 'powerbi/data/dim_geography.csv' WITH (FORMAT csv, HEADER true)
