-- Indicateur : la ligne appartient-elle au premier jour d'achat du client ?
ALTER TABLE bi.fact_sales ADD COLUMN is_first_purchase_day BOOLEAN;

UPDATE bi.fact_sales f
SET is_first_purchase_day = (f.order_date = c.first_order_date)
FROM bi.dim_customer c
WHERE c.customer_key = f.customer_key;

ALTER TABLE bi.fact_sales ALTER COLUMN is_first_purchase_day SET NOT NULL;

-- Contrôles
SELECT COUNT(DISTINCT customer_key) AS new_customers_total          -- attendu 93104
FROM bi.fact_sales WHERE is_first_purchase_day;

SELECT COUNT(DISTINCT customer_key) AS new_customers_nov_2017       -- attendu 7061 (requête C2)
FROM bi.fact_sales
WHERE is_first_purchase_day
  AND order_date >= DATE '2017-11-01' AND order_date < DATE '2017-12-01';

SELECT COUNT(DISTINCT state) AS states FROM bi.dim_geography;       -- attendu 27 (requête G1)
