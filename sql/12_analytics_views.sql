CREATE SCHEMA IF NOT EXISTS analytics;

-- fact_sales : une ligne par ligne de commande (= une unité vendue),
-- restreinte au périmètre validé (commandes delivered, janv. 2017 - août 2018).
-- Jointures sûres : une commande -> un client ; une ligne -> un produit.
CREATE OR REPLACE VIEW analytics.fact_sales AS
SELECT
    i.order_id,
    i.order_item_id,
    o.order_purchase_timestamp::date                        AS order_date,
    date_trunc('month', o.order_purchase_timestamp)::date   AS order_month,
    c.customer_unique_id,                                   -- vrai client
    c.customer_state,
    c.customer_city,
    i.product_id,
    p.product_category_name_english                         AS category,
    i.seller_id,
    i.quantity,
    i.price                                                 AS revenue,       -- CA hors frais de port
    i.freight_value
FROM clean.order_items i
JOIN clean.orders    o ON o.order_id    = i.order_id
JOIN clean.customers c ON c.customer_id = o.customer_id
JOIN clean.products  p ON p.product_id  = i.product_id
WHERE o.in_scope;

-- v_orders : une ligne par commande, pour panier moyen et nombre de commandes.
-- On part de fact_sales (pas des paiements) : pas de doublonnage du CA.
CREATE OR REPLACE VIEW analytics.v_orders AS
SELECT
    order_id, order_date, order_month,
    customer_unique_id, customer_state, customer_city,
    SUM(quantity)      AS units,
    SUM(revenue)       AS revenue,
    SUM(freight_value) AS freight
FROM analytics.fact_sales
GROUP BY order_id, order_date, order_month,
         customer_unique_id, customer_state, customer_city;
