-- =====================================================================
-- PRODUITS : top/flop, catégories, Pareto, évolution
-- Source : analytics.fact_sales (commandes delivered, janv. 2017 - août 2018)
-- =====================================================================

-- P1. Top 10 produits par CA, avec contribution au CA total (RANK + fenêtre)
WITH product_rev AS (
    SELECT product_id, category,
           SUM(revenue)  AS revenue,
           SUM(quantity) AS units
    FROM analytics.fact_sales
    GROUP BY product_id, category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC)                 AS rnk,
    product_id,
    category,
    ROUND(revenue, 2)                                   AS revenue,
    units,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)    AS pct_of_total_revenue
FROM product_rev
ORDER BY rnk
LIMIT 10;


-- P2. Produits les moins performants.
-- Seuil analytique choisi : au moins 10 unités vendues. Sans seuil, le "bas du classement"
-- serait uniquement des produits vendus une fois, ce qui n'a pas de sens business.
WITH product_rev AS (
    SELECT product_id, category,
           SUM(revenue)  AS revenue,
           SUM(quantity) AS units
    FROM analytics.fact_sales
    GROUP BY product_id, category
    HAVING SUM(quantity) >= 10
)
SELECT
    ROW_NUMBER() OVER (ORDER BY revenue ASC) AS position_from_bottom,
    product_id, category, ROUND(revenue, 2) AS revenue, units
FROM product_rev
ORDER BY position_from_bottom
LIMIT 10;

-- P2b. Contexte : combien de produits n'ont été vendus qu'une seule fois ?
SELECT
    COUNT(*)                                            AS products_sold,
    COUNT(*) FILTER (WHERE units = 1)                   AS sold_once,
    ROUND(100.0 * COUNT(*) FILTER (WHERE units = 1) / COUNT(*), 1) AS pct_sold_once
FROM (SELECT product_id, SUM(quantity) AS units
        FROM analytics.fact_sales GROUP BY product_id) t;


-- P3. CA par catégorie, part, part cumulée (Pareto) et rang
WITH cat AS (
    SELECT category,
           SUM(revenue)             AS revenue,
           SUM(quantity)            AS units,
           COUNT(DISTINCT order_id) AS orders
    FROM analytics.fact_sales
    GROUP BY category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC)                                        AS rnk,
    category,
    ROUND(revenue, 2)                                                          AS revenue,
    units,
    orders,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)                           AS pct_of_revenue,
    ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC)
                / SUM(revenue) OVER (), 2)                                     AS cumulative_pct
FROM cat
ORDER BY rnk;


-- P4. MARGE PAR CATÉGORIE : non calculable (aucun coût dans les données Olist).
-- Indicateur logistique à la place (ce n'est PAS une marge) :
-- poids des frais de port rapportés au CA, par catégorie.
SELECT
    category,
    ROUND(SUM(revenue), 2)                                  AS revenue,
    ROUND(SUM(freight_value), 2)                            AS freight,
    ROUND(100.0 * SUM(freight_value) / SUM(revenue), 1)     AS freight_pct_of_revenue
FROM analytics.fact_sales
GROUP BY category
HAVING SUM(revenue) >= 100000     -- seuil analytique : catégories significatives
ORDER BY freight_pct_of_revenue DESC
LIMIT 15;


-- P5. Évolution des catégories : janvier-août 2017 vs janvier-août 2018
-- (période comparable), avec le rang de chaque année.
WITH cat_year AS (
    SELECT category,
           EXTRACT(YEAR FROM order_date)::int AS year,
           SUM(revenue)                       AS revenue
    FROM analytics.fact_sales
    WHERE EXTRACT(MONTH FROM order_date) <= 8
    GROUP BY category, year
),
pivoted AS (
    SELECT category,
           SUM(revenue) FILTER (WHERE year = 2017) AS rev_2017,
           SUM(revenue) FILTER (WHERE year = 2018) AS rev_2018
    FROM cat_year
    GROUP BY category
)
SELECT
    category,
    ROUND(rev_2017, 2)                                                    AS rev_2017,
    ROUND(rev_2018, 2)                                                    AS rev_2018,
    ROUND(100.0 * (rev_2018 - rev_2017) / NULLIF(rev_2017, 0), 1)         AS growth_pct,
    RANK() OVER (ORDER BY rev_2017 DESC NULLS LAST)                       AS rank_2017,
    RANK() OVER (ORDER BY rev_2018 DESC NULLS LAST)                       AS rank_2018
FROM pivoted
ORDER BY rev_2018 DESC NULLS LAST
LIMIT 15;
