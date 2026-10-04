\copy clean.customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) FROM 'data/processed/customers.csv' WITH (FORMAT csv, HEADER true)

\copy clean.orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date, is_delivered, in_window, in_scope, has_items, has_payment, flag_carrier_before_approval, flag_delivered_before_carrier, flag_delivered_status_no_date, flag_date_without_delivered_status) FROM 'data/processed/orders.csv' WITH (FORMAT csv, HEADER true)

\copy clean.products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, product_category_name_english) FROM 'data/processed/products.csv' WITH (FORMAT csv, HEADER true)

\copy clean.sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state) FROM 'data/processed/sellers.csv' WITH (FORMAT csv, HEADER true)

\copy clean.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, quantity, line_revenue) FROM 'data/processed/order_items.csv' WITH (FORMAT csv, HEADER true)

\copy clean.order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value, is_zero_value, is_not_defined) FROM 'data/processed/order_payments.csv' WITH (FORMAT csv, HEADER true)

\copy clean.order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp) FROM 'data/processed/order_reviews.csv' WITH (FORMAT csv, HEADER true)

\copy clean.geolocation (zip_code_prefix, lat, lng, city, state, n_points) FROM 'data/processed/geolocation.csv' WITH (FORMAT csv, HEADER true)
