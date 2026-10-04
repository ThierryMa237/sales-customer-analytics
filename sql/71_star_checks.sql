-- Les valeurs attendues viennent des étapes précédentes.
SELECT
    (SELECT COUNT(*) FROM bi.fact_sales)                AS fact_rows,       -- attendu 109880
    (SELECT ROUND(SUM(revenue), 2) FROM bi.fact_sales)  AS fact_revenue,    -- attendu 13181027.13
    (SELECT COUNT(*) FROM bi.dim_customer)              AS dim_customers,   -- attendu 93104
    (SELECT COUNT(*) FROM bi.dim_product)               AS dim_products,    -- attendu 32081
    (SELECT COUNT(*) FROM bi.dim_geography)             AS dim_geography;
