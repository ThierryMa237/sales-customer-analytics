-- =====================================================================
-- RFM : scores finaux et segments
-- Décision : la fréquence est mesurée en jours d'achat distincts
-- (784 clients ont plusieurs commandes le même jour uniquement).
-- =====================================================================

-- Scores : même vue qu'avant, seul f_score change (purchase_days au lieu de frequency)
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
    CASE WHEN b.recency_days <= x.r20 THEN 5
         WHEN b.recency_days <= x.r40 THEN 4
         WHEN b.recency_days <= x.r60 THEN 3
         WHEN b.recency_days <= x.r80 THEN 2
         ELSE 1 END AS r_score,
    CASE WHEN b.purchase_days = 1 THEN 1
         WHEN b.purchase_days = 2 THEN 2
         ELSE 3 END AS f_score,
    CASE WHEN b.monetary <= x.m20 THEN 1
         WHEN b.monetary <= x.m40 THEN 2
         WHEN b.monetary <= x.m60 THEN 3
         WHEN b.monetary <= x.m80 THEN 4
         ELSE 5 END AS m_score
FROM analytics.rfm_base b
CROSS JOIN bounds x;


-- Segments : l'ordre des WHEN compte, la première règle vérifiée l'emporte.
-- Les noms sont des étiquettes analytiques, pas des catégories business établies.
CREATE OR REPLACE VIEW analytics.rfm_segments AS
SELECT
    s.*,
    CASE
        WHEN s.f_score >= 2 AND s.r_score >= 4 AND s.m_score >= 4 THEN 'Champions'
        WHEN s.f_score >= 2 AND s.r_score >= 3                    THEN 'Loyal Customers'
        WHEN s.r_score <= 2 AND (s.f_score >= 2 OR s.m_score >= 4) THEN 'At Risk'
        WHEN s.f_score = 1  AND s.r_score >= 4                    THEN 'Potential Loyalists'
        WHEN s.f_score = 1  AND s.r_score <= 2 AND s.m_score <= 3 THEN 'Lost Customers'
        ELSE 'Occasional Customers'
    END AS segment
FROM analytics.rfm_scores s;
