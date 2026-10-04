-- =====================================================================
-- GÉOGRAPHIE : analyse par État et ville (le dataset ne couvre qu'un pays, le Brésil)
-- La localisation est celle du CLIENT. Source : analytics.v_orders
-- =====================================================================

-- G1. Par État : CA, commandes, clients, panier moyen, part du CA, poids des frais de port
SELECT
    RANK() OVER (ORDER BY SUM(revenue) DESC)                    AS rnk,
    customer_state,
    ROUND(SUM(revenue), 2)                                      AS revenue,
    COUNT(*)                                                    AS orders,
    COUNT(DISTINCT customer_unique_id)                          AS customers,
    ROUND(SUM(revenue) / COUNT(*), 2)                           AS avg_order_value,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2)  AS pct_of_revenue,
    ROUND(100.0 * SUM(freight) / SUM(revenue), 1)               AS freight_pct_of_revenue
FROM analytics.v_orders
GROUP BY customer_state
ORDER BY rnk;


-- G2. Top 10 villes par CA (ROW_NUMBER)
SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(revenue) DESC) AS position,
    customer_city,
    customer_state,
    ROUND(SUM(revenue), 2)                         AS revenue,
    COUNT(*)                                       AS orders,
    ROUND(SUM(revenue) / COUNT(*), 2)              AS avg_order_value
FROM analytics.v_orders
GROUP BY customer_city, customer_state
ORDER BY position
LIMIT 10;


-- G3. Évolution par État : janvier-août 2017 vs janvier-août 2018
WITH state_year AS (
    SELECT customer_state,
           SUM(revenue) FILTER (WHERE EXTRACT(YEAR FROM order_date) = 2017) AS rev_2017,
           SUM(revenue) FILTER (WHERE EXTRACT(YEAR FROM order_date) = 2018) AS rev_2018
    FROM analytics.v_orders
    WHERE EXTRACT(MONTH FROM order_date) <= 8
    GROUP BY customer_state
)
SELECT
    customer_state,
    ROUND(rev_2017, 2)                                              AS rev_2017,
    ROUND(rev_2018, 2)                                              AS rev_2018,
    ROUND(100.0 * (rev_2018 - rev_2017) / NULLIF(rev_2017, 0), 1)   AS growth_pct
FROM state_year
ORDER BY rev_2018 DESC NULLS LAST
LIMIT 10;
