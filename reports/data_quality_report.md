# Rapport de qualité des données : Olist Brazilian E-Commerce

**Source** : Kaggle, olistbr/brazilian-ecommerce (CC BY-NC-SA 4.0)
**Méthode** : chargement fidèle dans PostgreSQL (`raw.*`), contrôles réalisés avec pandas (`notebooks/01_data_quality.ipynb`). Aucune donnée n'a été modifiée ni supprimée à cette étape.

## 1. Volumétrie

| Table | Lignes |
|---|---|
| orders | 99 441 |
| customers | 99 441 |
| order_items | 112 650 |
| order_payments | 103 886 |
| order_reviews | 99 224 |
| products | 32 951 |
| sellers | 3 095 |
| geolocation | 1 000 163 |
| category_translation | 71 |

## 2. Synthèse

- Les clés des tables principales sont uniques et l'intégrité référentielle est respectée (0 orphelin).
- Les principaux risques analytiques sont des pièges de **modélisation** (identifiant client, paiements multiples, périodes incomplètes) plus que des erreurs de saisie.
- Les contraintes du dataset : pas de coûts (donc pas de marge), pas de remises, un seul pays (Brésil).

## 3. Constats détaillés

| # | Table | Constat | Volume | Gravité | Traitement prévu |
|---|---|---|---|---|---|
| 1 | customers | `customer_id` est généré par commande : 99 441 valeurs pour 96 096 clients réels (`customer_unique_id`) | 3 345 | Haute | Compter les clients avec `customer_unique_id` |
| 2 | customers | Seuls 3,12 % des clients ont plus d'une commande | 2 996 clients | Information | RFM : limite à documenter |
| 3 | orders | Commandes sans ligne d'items | 775 | Moyenne | À qualifier par statut (cellule 11a) |
| 4 | orders | Commande sans paiement | 1 | Faible | À examiner (cellule 11b) |
| 5 | orders | Statuts : delivered 97,02 %, shipped 1,11 %, canceled 0,63 %, unavailable 0,61 %, autres 0,63 % | n/a | Moyenne | Périmètre du CA à définir et documenter |
| 6 | orders | Période : activité réelle de janv. 2017 à août 2018 ; 2016 quasi vide, sept.-oct. 2018 quasi vides | 2016 : 329 cmd ; 2018 sept.-oct. : 20 cmd | Haute | Fenêtre d'analyse janv. 2017 - août 2018 ; YoY sur périodes comparables |
| 7 | orders | Remise au transporteur antérieure à l'approbation | 1 359 | Faible | Conserver, signaler (n'affecte pas les KPI de vente) |
| 8 | orders | Livraison antérieure à la remise au transporteur | 23 | Faible | Conserver, signaler, exclure des délais de livraison |
| 9 | orders | Statut `delivered` sans date de livraison | 8 | Faible | Conserver, signaler |
| 10 | orders | Statut autre que `delivered` avec date de livraison | 6 | Faible | Conserver, signaler |
| 11 | orders | Dates manquantes : approbation 160, transporteur 1 783, livraison 2 965 | 0,16 % / 1,79 % / 2,98 % | Faible | Attendu pour les commandes non livrées ; ne pas imputer |
| 12 | order_payments | Commandes avec plusieurs paiements | 2 961 | Haute | Agréger les paiements par commande avant jointure |
| 13 | items vs payments | Écart entre total items (prix + port) et total paiements | 303 (à confirmer) | Moyenne | Comprendre l'origine (cellule 11d) ; définir le CA à partir de `price` |
| 14 | order_payments | `payment_value` = 0 (9), `payment_type` = not_defined (3), `payment_installments` = 0 (2) | 9 / 3 / 2 | Faible | À examiner (cellule 11c) |
| 15 | order_items | `order_item_id` est un numéro de ligne : une ligne = une unité | n/a | Information | Unités vendues = nombre de lignes |
| 16 | products | Catégorie manquante (et attributs associés) | 610 (1,85 %) | Moyenne | Catégorie `unknown`, jamais supprimés |
| 17 | products | Catégories sans traduction | 13 produits, 2 catégories | Faible | Traduction manuelle documentée |
| 18 | products | Dimensions/poids manquants (2), poids = 0 (4) | 2 / 4 | Faible | Mettre à NULL, non utilisés dans les KPI |
| 19 | products | Colonnes `product_name_lenght`, `product_description_lenght` mal orthographiées dans la source | n/a | Faible | Renommage lors de la normalisation |
| 20 | order_items | Outliers IQR : prix 8 427, frais de port 12 134 | 7,5 % / 10,8 % | Information | Conservés : distribution asymétrique naturelle |
| 21 | products | Outliers IQR sur le poids | 4 551 | Information | Conservés |
| 22 | order_reviews | `review_id` répétés | 814 | Faible | Dédoublonner si les avis sont utilisés |
| 23 | order_reviews | Titre manquant 88,34 %, message manquant 58,70 % | n/a | Information | Champs facultatifs, non utilisés |
| 24 | geolocation | Lignes entièrement dupliquées | 261 831 | Moyenne | Dédoublonner |
| 25 | geolocation | Plusieurs coordonnées par code postal (19 015 codes pour 1 000 163 lignes) | 981 148 | Moyenne | Agréger par code postal (médiane lat/lng) |
| 26 | geolocation | Coordonnées hors du Brésil (rectangle approximatif) | 42 | Faible | Exclure de la table agrégée (erreurs manifestes de géocodage) |

## 4. Décisions de périmètre (à finaliser après contrôles complémentaires)

- **Fenêtre d'analyse** : janvier 2017 à août 2018.
- **Clients** : comptés via `customer_unique_id`.
- **Chiffre d'affaires** : somme de `price` des lignes d'items (hors frais de port, suivis séparément), sur le périmètre de statuts à valider.
- **Marge** : non calculable (aucun coût dans les données). Les mesures de marge sont déclarées non applicables.

## 5. Limites

- Données historiques d'une seule place de marché brésilienne, jusqu'en 2018.
- Pas de coûts, pas de remises.
- Faible récurrence client, ce qui limite la portée de l'analyse de fidélité.
- Les seuils d'outliers (IQR) sont des critères statistiques et non des règles métier.

Précision sur le constat n°26 : 42 coordonnées hors du Brésil avant dédoublonnage, 33 après (9 étaient des doublons exacts, déjà supprimés). Le journal `reports/cleaning_log.csv` fait foi pour les volumes réellement traités.

## 6. Résultats du pipeline de nettoyage (`src/clean.py`)

- Décisions de périmètre **validées** : CA calculé sur les commandes `delivered`, fenêtre d'analyse janvier 2017 - août 2018, portées par les indicateurs `is_delivered`, `in_window`, `in_scope` (aucune commande supprimée).
- `order_reviews` : aucun doublon sur (`review_id`, `order_id`) ; les `review_id` répétés correspondent à des commandes différentes et sont conservés.
- `geolocation` : agrégée à 19 010 codes postaux (5 codes exclus car uniquement des coordonnées hors du Brésil).
- 11 tests automatiques réussis (`tests/test_clean.py`), dont l'absence de perte de lignes sur `orders`, `order_items` et `products`.
- Écart de 303 commandes entre total items et total paiements : non investigué. Le CA est calculé à partir de `price`, donc sans impact, mais l'écart reste une limite documentée.

## 7. Constat complémentaire (étape 6)

Constat n°27 : la table de traduction officielle contient des fautes d'orthographe (`fashio_female_clothing`, `costruction_tools_garden`, `costruction_tools_tools`). Corrigées dans `src/clean.py` (dictionnaire `CATEGORY_TYPO_FIXES`) et journalisées. Les catégories `home_confort` et `home_comfort_2`, ainsi que `home_appliances` et `home_appliances_2`, sont distinctes dans la source et ne sont pas fusionnées : le regroupement serait une décision métier non justifiable à partir des données.
