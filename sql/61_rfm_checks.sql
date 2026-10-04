-- 7a. Contrôle de base : 93 104 clients attendus
SELECT COUNT(*) AS customers,
       MAX(last_order_date) AS last_order_in_scope,
       MIN(recency_days)    AS min_recency_days,
       MAX(recency_days)    AS max_recency_days
FROM analytics.rfm_base;

-- 7b. Seuils réels de récence (jours) et de montant (BRL)
SELECT
    ROUND(PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY recency_days)::numeric, 1) AS r_p20,
    ROUND(PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY recency_days)::numeric, 1) AS r_p40,
    ROUND(PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY recency_days)::numeric, 1) AS r_p60,
    ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY recency_days)::numeric, 1) AS r_p80,
    ROUND(PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY monetary)::numeric, 2)     AS m_p20,
    ROUND(PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY monetary)::numeric, 2)     AS m_p40,
    ROUND(PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY monetary)::numeric, 2)     AS m_p60,
    ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY monetary)::numeric, 2)     AS m_p80
FROM analytics.rfm_base;

-- 7c. Distribution de chaque score (les groupes ne seront pas égaux à cause des égalités)
SELECT 'R' AS dimension, r_score AS score, COUNT(*) AS customers FROM analytics.rfm_scores GROUP BY r_score
UNION ALL
SELECT 'F', f_score, COUNT(*) FROM analytics.rfm_scores GROUP BY f_score
UNION ALL
SELECT 'M', m_score, COUNT(*) FROM analytics.rfm_scores GROUP BY m_score
ORDER BY dimension, score;

-- 7d. Croisement récence x fréquence
SELECT r_score, f_score, COUNT(*) AS customers
FROM analytics.rfm_scores
GROUP BY r_score, f_score
ORDER BY r_score DESC, f_score;

-- 7e. Fréquence en commandes vs en jours d'achat distincts
SELECT
    COUNT(*) FILTER (WHERE frequency     >= 2) AS repeat_by_orders,
    COUNT(*) FILTER (WHERE purchase_days >= 2) AS repeat_by_distinct_days
FROM analytics.rfm_base;
