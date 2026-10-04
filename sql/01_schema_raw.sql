-- Couche brute : copie fidèle des CSV Olist, sans transformation ni contrainte.
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.customers (
    customer_id               TEXT,
    customer_unique_id        TEXT,
    customer_zip_code_prefix  TEXT,
    customer_city             TEXT,
    customer_state            TEXT
);

CREATE TABLE raw.orders (
    order_id                       TEXT,
    customer_id                    TEXT,
    order_status                   TEXT,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP
);

CREATE TABLE raw.order_items (
    order_id             TEXT,
    order_item_id        INTEGER,
    product_id           TEXT,
    seller_id            TEXT,
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC(10,2),
    freight_value        NUMERIC(10,2)
);

CREATE TABLE raw.order_payments (
    order_id              TEXT,
    payment_sequential    INTEGER,
    payment_type          TEXT,
    payment_installments  INTEGER,
    payment_value         NUMERIC(10,2)
);

CREATE TABLE raw.order_reviews (
    review_id                 TEXT,
    order_id                  TEXT,
    review_score              INTEGER,
    review_comment_title      TEXT,
    review_comment_message    TEXT,
    review_creation_date      TIMESTAMP,
    review_answer_timestamp   TIMESTAMP
);

CREATE TABLE raw.products (
    product_id                  TEXT,
    product_category_name       TEXT,
    product_name_lenght         INTEGER,
    product_description_lenght  INTEGER,
    product_photos_qty          INTEGER,
    product_weight_g            INTEGER,
    product_length_cm           INTEGER,
    product_height_cm           INTEGER,
    product_width_cm            INTEGER
);

CREATE TABLE raw.sellers (
    seller_id               TEXT,
    seller_zip_code_prefix  TEXT,
    seller_city             TEXT,
    seller_state            TEXT
);

CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix  TEXT,
    geolocation_lat              DOUBLE PRECISION,
    geolocation_lng              DOUBLE PRECISION,
    geolocation_city             TEXT,
    geolocation_state            TEXT
);

CREATE TABLE raw.category_translation (
    product_category_name          TEXT,
    product_category_name_english  TEXT
);
