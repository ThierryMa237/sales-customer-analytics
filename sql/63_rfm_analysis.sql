-- C1. Contrôles : 93 104 clients, CA total 13 181 027,13, aucun client sans segment
SELECT
    COUNT(*)                              AS customers,
    ROUND(SUM(monetary), 2)               AS total_revenue,
    COUNT(*) FILTER (WHERE segment IS NULL) AS customers_without_segment
FROM analytics.rfm_segments;

-- C2. Distribution des trois scores (les groupes ne sont pas égaux à cause des égalités)
SELECT 'R' AS dimension, r_score AS score, COUNT(*) AS customers FROM analytics.rfm_segments GROUP BY r_score
UNION ALL
SELECT 'F', f_score, COUNT(*) FROM analytics.rfm_segments GROUP BY f_score
UNION ALL
SELECT 'M', m_score, COUNT(*) FROM analytics.rfm_segments GROUP BY m_score
ORDER BY dimension, score;

-- C3. Analyse de chaque segment : taille, poids dans le CA, panier, récence
SELECT
    segment,
    COUNT(*)                                                         AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)               AS pct_customers,
    ROUND(SUM(monetary), 2)                                          AS revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1)     AS pct_revenue,
    ROUND(AVG(monetary), 2)                                          AS avg_revenue_per_customer,
    ROUND(SUM(monetary) / SUM(frequency), 2)                         AS avg_order_value,
    ROUND(AVG(frequency), 2)                                         AS avg_orders,
    ROUND(AVG(purchase_days), 2)                                     AS avg_purchase_days,
    ROUND(AVG(recency_days), 0)                                      AS avg_recency_days
FROM analytics.rfm_segments
GROUP BY segment
ORDER BY revenue DESC;
