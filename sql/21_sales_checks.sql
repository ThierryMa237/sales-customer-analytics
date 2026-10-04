-- V1. Biais de fin de période : part des commandes non livrées par mois.
-- Si elle monte vers la fin, le CA "delivered only" sous-estime les derniers mois.
SELECT
    date_trunc('month', order_purchase_timestamp)::date          AS order_month,
    COUNT(*)                                                     AS orders_all_status,
    COUNT(*) FILTER (WHERE is_delivered)                         AS delivered,
    COUNT(*) FILTER (WHERE order_status IN
        ('shipped','processing','invoiced','approved','created')) AS in_progress,
    COUNT(*) FILTER (WHERE order_status IN ('canceled','unavailable')) AS canceled_or_unavailable,
    ROUND(100.0 * COUNT(*) FILTER (WHERE NOT is_delivered) / COUNT(*), 1) AS pct_not_delivered
FROM clean.orders
WHERE in_window
GROUP BY 1
ORDER BY 1;

-- V2. Pic de novembre 2017 : les 5 plus gros jours du mois
SELECT order_date, COUNT(*) AS orders, ROUND(SUM(revenue), 2) AS revenue
FROM analytics.v_orders
WHERE order_month = DATE '2017-11-01'
GROUP BY order_date
ORDER BY orders DESC
LIMIT 5;
