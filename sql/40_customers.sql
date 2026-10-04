-- =====================================================================
-- CLIENTS : acquisition, activité, fréquence, valeur
-- Un client = customer_unique_id (jamais customer_id, qui est par commande).
-- Source : analytics.v_orders (une ligne par commande du périmètre)
-- =====================================================================

-- C1. Nombre de clients du périmètre
SELECT COUNT(DISTINCT customer_unique_id) AS customers
FROM analytics.v_orders;


-- C2. Nouveaux clients par mois (mois de la première commande dans le périmètre)
-- Limite : un client ayant commandé en 2016 (hors périmètre) serait compté "nouveau" en 2017.
WITH first_order AS (
    SELECT customer_unique_id, MIN(order_month) AS first_month
    FROM analytics.v_orders
    GROUP BY customer_unique_id
)
SELECT first_month AS order_month, COUNT(*) AS new_customers
FROM first_order
GROUP BY first_month
ORDER BY first_month;


-- C3. Clients actifs par mois, répartis entre nouveaux et récurrents
WITH first_order AS (
    SELECT customer_unique_id, MIN(order_month) AS first_month
    FROM analytics.v_orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT o.order_month, o.customer_unique_id, f.first_month
    FROM analytics.v_orders o
    JOIN first_order f USING (customer_unique_id)
)
SELECT
    order_month,
    COUNT(DISTINCT customer_unique_id)                                        AS active_customers,
    COUNT(DISTINCT customer_unique_id) FILTER (WHERE first_month = order_month) AS new_customers,
    COUNT(DISTINCT customer_unique_id) FILTER (WHERE first_month < order_month) AS returning_customers
FROM activity
GROUP BY order_month
ORDER BY order_month;


-- C4. Fréquence d'achat : distribution du nombre de commandes par client
WITH per_customer AS (
    SELECT customer_unique_id, COUNT(*) AS orders
    FROM analytics.v_orders
    GROUP BY customer_unique_id
)
SELECT
    orders                                                    AS orders_per_customer,
    COUNT(*)                                                  AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)        AS pct_of_customers
FROM per_customer
GROUP BY orders
ORDER BY orders;


-- C5. Délai entre deux commandes consécutives d'un même client (LEAD)
WITH ordered AS (
    SELECT
        customer_unique_id,
        order_date,
        LEAD(order_date) OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_date, order_id
        ) AS next_order_date
    FROM analytics.v_orders
)
SELECT
    COUNT(*)                                                           AS repeat_intervals,
    COUNT(*) FILTER (WHERE next_order_date = order_date)               AS same_day_orders,
    ROUND(AVG(next_order_date - order_date), 1)                        AS avg_days_between,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY next_order_date - order_date))::numeric, 1)        AS median_days_between
FROM ordered
WHERE next_order_date IS NOT NULL;


-- C6. Valeur client : CA par client, clients à achat unique vs récurrents
WITH cust AS (
    SELECT customer_unique_id,
           COUNT(*)      AS orders,
           SUM(revenue)  AS revenue
    FROM analytics.v_orders
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*)                                                                     AS customers,
    ROUND(AVG(revenue), 2)                                                       AS avg_revenue_per_customer,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue))::numeric, 2)    AS median_revenue_per_customer,
    ROUND(AVG(revenue) FILTER (WHERE orders = 1), 2)                             AS avg_revenue_one_time,
    ROUND(AVG(revenue) FILTER (WHERE orders > 1), 2)                             AS avg_revenue_repeat,
    ROUND(100.0 * SUM(revenue) FILTER (WHERE orders > 1) / SUM(revenue), 1)      AS pct_revenue_from_repeat
FROM cust;


-- C7. Les 10 clients de plus forte valeur (ROW_NUMBER)
SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(revenue) DESC) AS position,
    customer_unique_id,
    COUNT(*)                                       AS orders,
    ROUND(SUM(revenue), 2)                         AS revenue
FROM analytics.v_orders
GROUP BY customer_unique_id
ORDER BY position
LIMIT 10;
