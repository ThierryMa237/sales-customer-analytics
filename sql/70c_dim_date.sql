-- Table calendrier : un jour par ligne sur la fenêtre d'analyse (2017-01-01 -> 2018-08-31).
-- Fenêtre identique à celle du SQL : un YoY annuel compare ainsi des périodes comparables.
DROP TABLE IF EXISTS bi.dim_date;
CREATE TABLE bi.dim_date AS
SELECT
    d::date                              AS "Date",
    EXTRACT(YEAR FROM d)::int            AS "Year",
    'Q' || EXTRACT(QUARTER FROM d)::int  AS "Quarter",
    EXTRACT(MONTH FROM d)::int           AS "Month Number",
    TO_CHAR(d, 'Mon')                    AS "Month",
    date_trunc('month', d)::date         AS "Month Start",
    TO_CHAR(d, 'YYYY-MM')                AS "Year-Month",
    EXTRACT(ISODOW FROM d)::int          AS "Weekday Number",
    TO_CHAR(d, 'Dy')                     AS "Weekday"
FROM generate_series(TIMESTAMP '2017-01-01', TIMESTAMP '2018-08-31', INTERVAL '1 day') AS g(d);
ALTER TABLE bi.dim_date ADD PRIMARY KEY ("Date");

-- Contrôles
SELECT COUNT(*) AS days, MIN("Date") AS first_day, MAX("Date") AS last_day
FROM bi.dim_date;                                   -- attendu : 608, 2017-01-01, 2018-08-31

SELECT COUNT(*) AS fact_dates_missing_in_calendar   -- attendu : 0
FROM bi.fact_sales f
LEFT JOIN bi.dim_date d ON d."Date" = f.order_date
WHERE d."Date" IS NULL;
