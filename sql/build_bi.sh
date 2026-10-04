#!/usr/bin/env bash
# Reconstruit tout le schéma bi, contrôle les valeurs, puis exporte le classeur Power BI.
# Usage (depuis la racine du projet, venv activé, PGPASSWORD exporté) :
#     bash sql/build_bi.sh
set -euo pipefail

PSQL="psql -h localhost -U postgres -d olist -v ON_ERROR_STOP=1"

$PSQL -f sql/70_star_schema.sql     # tables du modèle en étoile (recrée le schéma bi)
$PSQL -f sql/70b_fact_flags.sql     # indicateur is_first_purchase_day
$PSQL -f sql/70c_dim_date.sql       # table calendrier
$PSQL -f sql/70d_date_keys.sql      # clés de date entières
$PSQL -f sql/71_star_checks.sql     # volumes et CA
python -m src.export_powerbi        # classeur Excel pour Power BI Service
