-- =====================================================================
-- VENTES : KPI globaux, évolution mensuelle, MoM, YoY
-- Source unique : analytics.fact_sales / analytics.v_orders
-- =====================================================================

-- Q1. KPI globaux sur le périmètre validé
SELECT
    ROUND(SUM(revenue), 2)                   AS revenue,
    COUNT(*)                                 AS orders,
    SUM(units)                               AS units_sold,
    ROUND(SUM(revenue) / COUNT(*), 2)        AS avg_order_value,
    ROUND(SUM(freight), 2)                   AS freight_total
FROM analytics.v_orders;


-- Q2. Évolution mensuelle du CA, commandes, unités, panier moyen
SELECT
    order_month,
    ROUND(SUM(revenue), 2)                   AS revenue,
    COUNT(*)                                 AS orders,
    SUM(units)                               AS units_sold,
    ROUND(SUM(revenue) / COUNT(*), 2)        AS avg_order_value
FROM analytics.v_orders
GROUP BY order_month
ORDER BY order_month;


-- Q3. Croissance MoM (LAG) et classement des mois (RANK)
WITH monthly AS (
    SELECT order_month, SUM(revenue) AS revenue
    FROM analytics.v_orders
    GROUP BY order_month
),
with_prev AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue
    FROM monthly
)
SELECT
    order_month,
    ROUND(revenue, 2)                                              AS revenue,
    ROUND(prev_revenue, 2)                                         AS prev_month_revenue,
    ROUND(100.0 * (revenue - prev_revenue) / NULLIF(prev_revenue, 0), 1) AS mom_growth_pct,
    RANK() OVER (ORDER BY revenue DESC)                            AS revenue_rank
FROM with_prev
ORDER BY order_month;


-- Q4. Croissance YoY mois par mois (jointure sur le même mois un an avant)
WITH monthly AS (
    SELECT order_month, SUM(revenue) AS revenue
    FROM analytics.v_orders
    GROUP BY order_month
)
SELECT
    cur.order_month,
    ROUND(cur.revenue, 2)                                           AS revenue,
    ROUND(prev.revenue, 2)                                          AS revenue_same_month_last_year,
    ROUND(100.0 * (cur.revenue - prev.revenue) / NULLIF(prev.revenue, 0), 1) AS yoy_growth_pct
FROM monthly cur
LEFT JOIN monthly prev
       ON prev.order_month = (cur.order_month - INTERVAL '1 year')::date
ORDER BY cur.order_month;


-- Q5. Évolution annuelle sur période comparable (janvier-août de chaque année)
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::int   AS year,
        SUM(revenue)                         AS revenue,
        COUNT(*)                             AS orders,
        SUM(units)                           AS units_sold
    FROM analytics.v_orders
    WHERE EXTRACT(MONTH FROM order_date) <= 8
    GROUP BY 1
),
with_prev AS (
    SELECT *, LAG(revenue) OVER (ORDER BY year) AS prev_revenue,
              LAG(orders)  OVER (ORDER BY year) AS prev_orders
    FROM yearly
)
SELECT
    year,
    ROUND(revenue, 2)                                         AS revenue,
    orders,
    units_sold,
    ROUND(revenue / orders, 2)                                AS avg_order_value,
    ROUND(100.0 * (revenue - prev_revenue) / prev_revenue, 1) AS revenue_yoy_pct,
    ROUND(100.0 * (orders  - prev_orders)  / prev_orders,  1) AS orders_yoy_pct
FROM with_prev
ORDER BY year;


-- Q6. CONTRÔLES DE COHÉRENCE (à exécuter avant d'utiliser les chiffres)
-- 6a. Le CA de la vue = le CA calculé directement sur les tables
SELECT
    (SELECT ROUND(SUM(i.price), 2)
       FROM clean.order_items i
       JOIN clean.orders o ON o.order_id = i.order_id
      WHERE o.in_scope)                                    AS revenue_direct,
    (SELECT ROUND(SUM(revenue), 2) FROM analytics.fact_sales) AS revenue_view;

-- 6b. Aucune ligne perdue par les jointures de la vue
SELECT
    (SELECT COUNT(*) FROM clean.order_items i
       JOIN clean.orders o ON o.order_id = i.order_id
      WHERE o.in_scope)                                    AS lines_direct,
    (SELECT COUNT(*) FROM analytics.fact_sales)            AS lines_view;

-- 6c. Commandes dans le périmètre mais sans ligne d'items (hors du CA)
SELECT COUNT(*) AS in_scope_orders_without_items
FROM clean.orders
WHERE in_scope AND NOT has_items;
