#!/usr/bin/env bash
# Rejoue tout le pipeline, du nettoyage Python à l'export du classeur Power BI.
#
# Prérequis :
#   - CSV Olist dans data/raw/
#   - couche brute chargée une fois (sql/01_schema_raw.sql, sql/02_load_raw.sql)
#   - venv activé, PGPASSWORD exporté
#   - si PostgreSQL signale "No space left on device" :
#       export PGOPTIONS='-c max_parallel_workers_per_gather=0'
#
# Usage (depuis la racine du projet) :
#     bash run_all.sh
set -euo pipefail

PSQL="psql -h localhost -U postgres -d olist -v ON_ERROR_STOP=1"

echo "== 1. Nettoyage Python et tests"
python -m src.clean
pytest -q

echo "== 2. Couche clean (recrée le schéma et ses vues dépendantes)"
$PSQL -f sql/10_schema_clean.sql
$PSQL -f sql/11_load_clean.sql

echo "== 3. Couche analytique (vues ventes puis RFM)"
$PSQL -f sql/12_analytics_views.sql
$PSQL -f sql/60_rfm.sql
$PSQL -f sql/62_rfm_segments.sql

echo "== 4. Modèle en étoile et export Power BI"
bash sql/build_bi.sh

echo "== Terminé : powerbi/data/olist_model.xlsx"
