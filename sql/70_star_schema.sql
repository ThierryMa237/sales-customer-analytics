-- =====================================================================
-- MODÈLE EN ÉTOILE pour Power BI (schéma "bi")
-- Source : analytics.fact_sales (commandes delivered, janv. 2017 - août 2018)
-- DimDate est créée dans Power BI (DAX), pas ici.
-- =====================================================================
DROP SCHEMA IF EXISTS bi CASCADE;
CREATE SCHEMA bi;

-- DimGeography : grain = (État, ville) de la commande
CREATE TABLE bi.dim_geography AS
SELECT
    ROW_NUMBER() OVER (ORDER BY state, city)::int AS geography_key,
    state,
    city
FROM (
    SELECT DISTINCT customer_state AS state, customer_city AS city
    FROM analytics.fact_sales
) g;
ALTER TABLE bi.dim_geography ADD PRIMARY KEY (geography_key);

-- DimProduct : produits vendus dans le périmètre
CREATE TABLE bi.dim_product AS
SELECT
    p.product_id                    AS product_key,
    p.product_category_name_english AS category,
    p.product_category_name         AS category_pt,
    p.product_weight_g,
    p.product_photos_qty
FROM clean.products p
WHERE p.product_id IN (SELECT DISTINCT product_id FROM analytics.fact_sales);
ALTER TABLE bi.dim_product ADD PRIMARY KEY (product_key);

-- DimCustomer : un client réel, avec ses scores RFM (date de référence 2018-09-01)
CREATE TABLE bi.dim_customer AS
SELECT
    customer_unique_id AS customer_key,
    first_order_date,
    last_order_date,
    recency_days,
    frequency          AS orders_count,
    purchase_days,
    monetary           AS total_revenue,
    r_score,
    f_score,
    m_score,
    segment            AS rfm_segment
FROM analytics.rfm_segments;
ALTER TABLE bi.dim_customer ADD PRIMARY KEY (customer_key);

-- FactSales : une ligne par ligne de commande livrée
CREATE TABLE bi.fact_sales AS
SELECT
    f.order_id,
    f.order_item_id,
    f.order_date,
    f.customer_unique_id AS customer_key,
    f.product_id         AS product_key,
    g.geography_key,
    f.seller_id,
    f.quantity,
    f.revenue,
    f.freight_value
FROM analytics.fact_sales f
JOIN bi.dim_geography g
  ON g.state = f.customer_state AND g.city = f.customer_city;
ALTER TABLE bi.fact_sales ADD PRIMARY KEY (order_id, order_item_id);

-- Clés étrangères : PostgreSQL refuse le script si une clé de la table de faits
-- n'existe pas dans sa dimension (intégrité du modèle en étoile).
ALTER TABLE bi.fact_sales
    ADD FOREIGN KEY (customer_key)  REFERENCES bi.dim_customer(customer_key),
    ADD FOREIGN KEY (product_key)   REFERENCES bi.dim_product(product_key),
    ADD FOREIGN KEY (geography_key) REFERENCES bi.dim_geography(geography_key);
