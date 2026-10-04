-- Couche "clean" : données issues de src/clean.py, avec types et contraintes.
DROP SCHEMA IF EXISTS clean CASCADE;
CREATE SCHEMA clean;

CREATE TABLE clean.customers (
    customer_id               TEXT PRIMARY KEY,
    customer_unique_id        TEXT NOT NULL,   -- vrai identifiant client
    customer_zip_code_prefix  TEXT,
    customer_city             TEXT,
    customer_state            TEXT
);

CREATE TABLE clean.orders (
    order_id                       TEXT PRIMARY KEY,
    customer_id                    TEXT NOT NULL REFERENCES clean.customers(customer_id),
    order_status                   TEXT,
    order_purchase_timestamp       TIMESTAMP,
    order_approved_at              TIMESTAMP,
    order_delivered_carrier_date   TIMESTAMP,
    order_delivered_customer_date  TIMESTAMP,
    order_estimated_delivery_date  TIMESTAMP,
    is_delivered                   BOOLEAN,
    in_window                      BOOLEAN,
    in_scope                       BOOLEAN,        -- delivered ET janv. 2017 - août 2018
    has_items                      BOOLEAN,
    has_payment                    BOOLEAN,
    flag_carrier_before_approval        BOOLEAN,
    flag_delivered_before_carrier       BOOLEAN,
    flag_delivered_status_no_date       BOOLEAN,
    flag_date_without_delivered_status  BOOLEAN
);

CREATE TABLE clean.products (
    product_id                   TEXT PRIMARY KEY,
    product_category_name        TEXT,
    product_name_length          NUMERIC,
    product_description_length   NUMERIC,
    product_photos_qty           NUMERIC,
    product_weight_g             NUMERIC,
    product_length_cm            NUMERIC,
    product_height_cm            NUMERIC,
    product_width_cm             NUMERIC,
    product_category_name_english TEXT
);

CREATE TABLE clean.sellers (
    seller_id               TEXT PRIMARY KEY,
    seller_zip_code_prefix  TEXT,
    seller_city             TEXT,
    seller_state            TEXT
);

CREATE TABLE clean.order_items (
    order_id             TEXT    NOT NULL REFERENCES clean.orders(order_id),
    order_item_id        INTEGER NOT NULL,   -- numéro de ligne, pas une quantité
    product_id           TEXT    NOT NULL REFERENCES clean.products(product_id),
    seller_id            TEXT    NOT NULL REFERENCES clean.sellers(seller_id),
    shipping_limit_date  TIMESTAMP,
    price                NUMERIC(10,2) NOT NULL,
    freight_value        NUMERIC(10,2),
    quantity             INTEGER NOT NULL,
    line_revenue         NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE clean.order_payments (
    order_id              TEXT    NOT NULL REFERENCES clean.orders(order_id),
    payment_sequential    INTEGER NOT NULL,
    payment_type          TEXT,
    payment_installments  INTEGER,
    payment_value         NUMERIC(10,2),
    is_zero_value         BOOLEAN,
    is_not_defined        BOOLEAN,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE clean.order_reviews (
    review_id                TEXT NOT NULL,
    order_id                 TEXT NOT NULL REFERENCES clean.orders(order_id),
    review_score             INTEGER,
    review_comment_title     TEXT,
    review_comment_message   TEXT,
    review_creation_date     TIMESTAMP,
    review_answer_timestamp  TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);

CREATE TABLE clean.geolocation (
    zip_code_prefix  TEXT PRIMARY KEY,
    lat              DOUBLE PRECISION,
    lng              DOUBLE PRECISION,
    city             TEXT,
    state            TEXT,
    n_points         INTEGER
);
