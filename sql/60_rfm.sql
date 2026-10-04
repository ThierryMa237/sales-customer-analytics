-- =====================================================================
-- RFM : récence, fréquence, montant par client (customer_unique_id)
-- Périmètre : commandes delivered, janv. 2017 - août 2018 (analytics.v_orders)
-- =====================================================================

-- Base : une ligne par client
CREATE OR REPLACE VIEW analytics.rfm_base AS
WITH params AS (
    SELECT DATE '2018-09-01' AS snapshot_date   -- lendemain de la fin du périmètre
),
cust AS (
    SELECT
        customer_unique_id,
        MIN(order_date)            AS first_order_date,
        MAX(order_date)            AS last_order_date,
        COUNT(*)                   AS frequency,        -- nombre de commandes
        COUNT(DISTINCT order_date) AS purchase_days,    -- jours d'achat distincts
        SUM(revenue)               AS monetary          -- CA hors frais de port
    FROM analytics.v_orders
    GROUP BY customer_unique_id
)
SELECT
    c.customer_unique_id,
    c.first_order_date,
    c.last_order_date,
    (p.snapshot_date - c.last_order_date) AS recency_days,
    c.frequency,
    c.purchase_days,
    c.monetary
FROM cust c
CROSS JOIN params p;


-- Scores : seuils de percentiles pour R et M (les égalités reçoivent le même score),
-- seuils explicites pour F.
CREATE OR REPLACE VIEW analytics.rfm_scores AS
WITH bounds AS (
    SELECT
        PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY recency_days) AS r20,
        PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY recency_days) AS r40,
        PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY recency_days) AS r60,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY recency_days) AS r80,
        PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY monetary)     AS m20,
        PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY monetary)     AS m40,
        PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY monetary)     AS m60,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY monetary)     AS m80
    FROM analytics.rfm_base
)
SELECT
    b.customer_unique_id,
    b.first_order_date,
    b.last_order_date,
    b.recency_days,
    b.frequency,
    b.purchase_days,
    b.monetary,
    -- Récence : 5 = achat le plus récent
    CASE WHEN b.recency_days <= x.r20 THEN 5
         WHEN b.recency_days <= x.r40 THEN 4
         WHEN b.recency_days <= x.r60 THEN 3
         WHEN b.recency_days <= x.r80 THEN 2
         ELSE 1 END AS r_score,
    -- Fréquence : 1, 2 ou 3 commandes et plus
    CASE WHEN b.frequency = 1 THEN 1
         WHEN b.frequency = 2 THEN 2
         ELSE 3 END AS f_score,
    -- Montant : 5 = dépense la plus élevée
    CASE WHEN b.monetary <= x.m20 THEN 1
         WHEN b.monetary <= x.m40 THEN 2
         WHEN b.monetary <= x.m60 THEN 3
         WHEN b.monetary <= x.m80 THEN 4
         ELSE 5 END AS m_score
FROM analytics.rfm_base b
CROSS JOIN bounds x;
