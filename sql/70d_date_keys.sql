-- Clé de date entière (AAAAMMJJ) : relation fait -> calendrier sans ambiguïté de type.
ALTER TABLE bi.dim_date ADD COLUMN "Date Key" INTEGER;
UPDATE bi.dim_date SET "Date Key" = TO_CHAR("Date", 'YYYYMMDD')::int;
ALTER TABLE bi.dim_date ALTER COLUMN "Date Key" SET NOT NULL;
ALTER TABLE bi.dim_date ADD UNIQUE ("Date Key");

ALTER TABLE bi.fact_sales ADD COLUMN date_key INTEGER;
UPDATE bi.fact_sales SET date_key = TO_CHAR(order_date, 'YYYYMMDD')::int;
ALTER TABLE bi.fact_sales ALTER COLUMN date_key SET NOT NULL;

-- Contrôles
SELECT COUNT(*) AS fact_keys_missing_in_calendar          -- attendu : 0
FROM bi.fact_sales f
LEFT JOIN bi.dim_date d ON d."Date Key" = f.date_key
WHERE d."Date Key" IS NULL;

SELECT MIN("Date Key") AS first_key, MAX("Date Key") AS last_key   -- attendu : 20170101, 20180831
FROM bi.dim_date;
