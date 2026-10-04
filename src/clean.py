"""
Pipeline de nettoyage Olist : data/raw/*.csv  ->  data/processed/*.csv

Principes :
  - les données brutes ne sont jamais modifiées ;
  - rien n'est supprimé sans être journalisé (reports/cleaning_log.csv) ;
  - le périmètre d'analyse (livrées, jan. 2017 - août 2018) est porté par
    des colonnes indicatrices, pas par des suppressions.

Usage (depuis la racine du projet) :
    python -m src.clean
"""
from pathlib import Path

import pandas as pd

RAW_DIR = Path("data/raw")
OUT_DIR = Path("data/processed")
LOG_PATH = Path("reports/cleaning_log.csv")

# Périmètre d'analyse validé
WINDOW_START = pd.Timestamp("2017-01-01")
WINDOW_END = pd.Timestamp("2018-09-01")  # borne exclusive
IN_SCOPE_STATUS = "delivered"

# Rectangle approximatif du Brésil, pour repérer les coordonnées aberrantes
BRAZIL_LAT = (-34.0, 6.0)
BRAZIL_LNG = (-74.0, -34.0)

FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

# Codes postaux lus en texte pour ne pas perdre les zéros de tête
ZIP_COLS = {
    "customers": ["customer_zip_code_prefix"],
    "sellers": ["seller_zip_code_prefix"],
    "geolocation": ["geolocation_zip_code_prefix"],
}

# Catégories absentes de la table de traduction (constat du rapport qualité).
# Traduction manuelle, à valider.
MANUAL_CATEGORY_TRANSLATIONS = {
    "pc_gamer": "pc_gamer",
    "portateis_cozinha_e_preparadores_de_alimentos":
        "portable_kitchen_and_food_preparers",
}

# Fautes d'orthographe présentes dans la table de traduction officielle,
# repérées à l'étape 6 dans les résultats par catégorie.
CATEGORY_TYPO_FIXES = {
    "fashio_female_clothing": "fashion_female_clothing",
    "costruction_tools_garden": "construction_tools_garden",
    "costruction_tools_tools": "construction_tools_tools",
}


# --------------------------------------------------------------------------
# Journal de nettoyage
# --------------------------------------------------------------------------
class CleaningLog:
    """Enregistre chaque règle appliquée, son volume et sa justification."""

    def __init__(self):
        self.rows = []

    def add(self, table, rule, action, n_affected, justification):
        self.rows.append({
            "table": table,
            "rule": rule,
            "action": action,  # supprimé / modifié / signalé (flag)
            "n_affected": int(n_affected),
            "justification": justification,
        })

    def save(self, path):
        path.parent.mkdir(parents=True, exist_ok=True)
        pd.DataFrame(self.rows).to_csv(path, index=False)


# --------------------------------------------------------------------------
# Outils communs
# --------------------------------------------------------------------------
def normalize_columns(df):
    """Noms de colonnes : minuscules, sans espaces, orthographe corrigée."""
    df = df.copy()
    df.columns = (df.columns.str.strip().str.lower().str.replace(" ", "_"))
    return df.rename(columns={
        "product_name_lenght": "product_name_length",
        "product_description_lenght": "product_description_length",
    })


def normalize_zip(series):
    """Code postal en texte sur 5 caractères."""
    return series.astype("string").str.strip().str.zfill(5)


def load_raw():
    """Lit les CSV bruts sans aucune transformation de contenu."""
    raw = {}
    for name, filename in FILES.items():
        dtype = {c: "string" for c in ZIP_COLS.get(name, [])}
        raw[name] = pd.read_csv(RAW_DIR / filename, dtype=dtype)
    return raw


# --------------------------------------------------------------------------
# Nettoyage table par table
# --------------------------------------------------------------------------
def clean_customers(df, log):
    df = normalize_columns(df)
    df["customer_zip_code_prefix"] = normalize_zip(df["customer_zip_code_prefix"])
    df["customer_city"] = df["customer_city"].str.strip().str.lower()
    df["customer_state"] = df["customer_state"].str.strip().str.upper()

    n_dup = df.duplicated().sum()
    if n_dup:
        df = df.drop_duplicates()
        log.add("customers", "lignes entièrement dupliquées", "supprimé", n_dup,
                "doublon exact sans information supplémentaire")
    return df


def clean_orders(df, items, payments, log):
    df = normalize_columns(df)
    df["order_status"] = df["order_status"].str.strip().str.lower()

    # Typage des dates : les valeurs illisibles deviendraient NaT, on les compte
    date_cols = [c for c in df.columns if c.startswith("order_") and
                 (c.endswith("_at") or c.endswith("_date") or c.endswith("_timestamp"))]
    for col in date_cols:
        before = df[col].isna().sum()
        df[col] = pd.to_datetime(df[col], errors="coerce")
        lost = df[col].isna().sum() - before
        if lost:
            log.add("orders", f"{col} : valeurs illisibles", "modifié", lost,
                    "converties en NaT")

    purchase = df["order_purchase_timestamp"]

    # Périmètre d'analyse (décisions validées) : indicateurs, pas de suppression
    df["is_delivered"] = df["order_status"].eq(IN_SCOPE_STATUS)
    df["in_window"] = (purchase >= WINDOW_START) & (purchase < WINDOW_END)
    df["in_scope"] = df["is_delivered"] & df["in_window"]
    df["has_items"] = df["order_id"].isin(items["order_id"])
    df["has_payment"] = df["order_id"].isin(payments["order_id"])

    # Anomalies chronologiques : conservées et signalées
    df["flag_carrier_before_approval"] = (
        df["order_delivered_carrier_date"] < df["order_approved_at"])
    df["flag_delivered_before_carrier"] = (
        df["order_delivered_customer_date"] < df["order_delivered_carrier_date"])
    df["flag_delivered_status_no_date"] = (
        df["is_delivered"] & df["order_delivered_customer_date"].isna())
    df["flag_date_without_delivered_status"] = (
        ~df["is_delivered"] & df["order_delivered_customer_date"].notna())

    log.add("orders", "hors fenêtre janv. 2017 - août 2018", "signalé (flag)",
            (~df["in_window"]).sum(),
            "périodes quasi vides (2016, sept.-oct. 2018) ; conservées en base")
    log.add("orders", "statut différent de delivered", "signalé (flag)",
            (~df["is_delivered"]).sum(),
            "le CA est calculé sur les commandes livrées uniquement")
    log.add("orders", "commandes sans ligne d'items", "signalé (flag)",
            (~df["has_items"]).sum(), "aucun CA calculable ; conservées")
    log.add("orders", "commandes sans paiement", "signalé (flag)",
            (~df["has_payment"]).sum(), "conservées")
    for flag, why in [
        ("flag_carrier_before_approval", "remise transporteur avant approbation"),
        ("flag_delivered_before_carrier", "livraison avant remise transporteur"),
        ("flag_delivered_status_no_date", "statut delivered sans date de livraison"),
        ("flag_date_without_delivered_status", "date de livraison sans statut delivered"),
    ]:
        log.add("orders", why, "signalé (flag)", df[flag].sum(),
                "incohérence conservée ; n'affecte pas le CA")
    return df


def clean_order_items(df, log):
    df = normalize_columns(df)
    df["shipping_limit_date"] = pd.to_datetime(df["shipping_limit_date"], errors="coerce")

    n_dup = df.duplicated(subset=["order_id", "order_item_id"]).sum()
    if n_dup:
        df = df.drop_duplicates(subset=["order_id", "order_item_id"])
        log.add("order_items", "doublons sur (order_id, order_item_id)", "supprimé",
                n_dup, "clé censée être unique")

    n_bad = (df["price"] <= 0).sum()
    if n_bad:
        log.add("order_items", "price <= 0", "signalé (flag)", n_bad,
                "conservées, à examiner")

    # order_item_id est un numéro de ligne : une ligne = une unité vendue
    df["quantity"] = 1
    df["line_revenue"] = df["price"]
    return df


def clean_order_payments(df, log):
    df = normalize_columns(df)
    df["is_zero_value"] = df["payment_value"].eq(0)
    df["is_not_defined"] = df["payment_type"].eq("not_defined")
    log.add("order_payments", "payment_value = 0", "signalé (flag)",
            df["is_zero_value"].sum(), "conservés ; non utilisés pour le CA")
    log.add("order_payments", "payment_type = not_defined", "signalé (flag)",
            df["is_not_defined"].sum(), "conservés ; non utilisés pour le CA")
    return df


def clean_products(df, translation, log):
    df = normalize_columns(df)
    df["product_category_name"] = df["product_category_name"].str.strip().str.lower()

    # Catégories manquantes : conservées sous une valeur explicite
    n_null = df["product_category_name"].isna().sum()
    df["product_category_name"] = df["product_category_name"].fillna("unknown")
    log.add("products", "catégorie manquante", "modifié", n_null,
            "remplacée par 'unknown' ; produits conservés")

    # Poids nul : physiquement impossible
    n_zero = (df["product_weight_g"] == 0).sum()
    df.loc[df["product_weight_g"] == 0, "product_weight_g"] = pd.NA
    log.add("products", "product_weight_g = 0", "modifié", n_zero,
            "remplacé par une valeur manquante")

    # Traduction : table officielle + compléments manuels documentés
    tr = normalize_columns(translation)
    extra = pd.DataFrame({
        "product_category_name": list(MANUAL_CATEGORY_TRANSLATIONS),
        "product_category_name_english": list(MANUAL_CATEGORY_TRANSLATIONS.values()),
    })
    tr = (pd.concat([tr, extra]).drop_duplicates("product_category_name"))
    df = df.merge(tr, on="product_category_name", how="left")
    df.loc[df["product_category_name"] == "unknown",
           "product_category_name_english"] = "unknown"

    n_untranslated = df["product_category_name_english"].isna().sum()
    if n_untranslated:
        df["product_category_name_english"] = (
            df["product_category_name_english"].fillna(df["product_category_name"]))
        log.add("products", "catégorie sans traduction", "modifié", n_untranslated,
                "nom portugais conservé")
    log.add("products", "traduction manuelle de 2 catégories", "modifié",
            df["product_category_name"].isin(MANUAL_CATEGORY_TRANSLATIONS).sum(),
            "absentes de la table de traduction officielle")

    n_typo = df["product_category_name_english"].isin(CATEGORY_TYPO_FIXES).sum()
    df["product_category_name_english"] = (
        df["product_category_name_english"].replace(CATEGORY_TYPO_FIXES))
    log.add("products", "fautes d'orthographe dans les noms de catégories (EN)",
            "modifié", n_typo,
            "corrigées (fashio_, costruction_) ; défaut de la table de traduction source")
    return df


def clean_sellers(df, log):
    df = normalize_columns(df)
    df["seller_zip_code_prefix"] = normalize_zip(df["seller_zip_code_prefix"])
    df["seller_city"] = df["seller_city"].str.strip().str.lower()
    df["seller_state"] = df["seller_state"].str.strip().str.upper()
    return df


def clean_order_reviews(df, log):
    df = normalize_columns(df)
    for col in ["review_creation_date", "review_answer_timestamp"]:
        df[col] = pd.to_datetime(df[col], errors="coerce")

    # On déduplique sur la paire (review_id, order_id) : un même review_id peut
    # légitimement être lié à plusieurs commandes, sa suppression ferait perdre le lien.
    df = df.sort_values("review_answer_timestamp")
    n_dup = df.duplicated(subset=["review_id", "order_id"]).sum()
    df = df.drop_duplicates(subset=["review_id", "order_id"], keep="last")
    log.add("order_reviews", "doublons sur (review_id, order_id)", "supprimé", n_dup,
            "on conserve l'avis le plus récent")
    log.add("order_reviews", "review_id partagé entre plusieurs commandes", "signalé (flag)",
            df["review_id"].duplicated().sum(),
            "conservé : lien avec la commande préservé")
    return df


def clean_geolocation(df, log):
    df = normalize_columns(df)
    df["geolocation_zip_code_prefix"] = normalize_zip(df["geolocation_zip_code_prefix"])
    df["geolocation_city"] = df["geolocation_city"].str.strip().str.lower()
    df["geolocation_state"] = df["geolocation_state"].str.strip().str.upper()

    n_dup = df.duplicated().sum()
    df = df.drop_duplicates()
    log.add("geolocation", "lignes entièrement dupliquées", "supprimé", n_dup,
            "doublon exact sans information supplémentaire")

    outside = ~(df["geolocation_lat"].between(*BRAZIL_LAT)
                & df["geolocation_lng"].between(*BRAZIL_LNG))
    df = df[~outside]
    log.add("geolocation", "coordonnées hors du Brésil", "supprimé", outside.sum(),
            "erreurs manifestes de géocodage")

    # Une ligne par code postal : médiane des coordonnées, valeur la plus fréquente
    # pour la ville et l'État
    n_before = len(df)
    agg = (df.groupby("geolocation_zip_code_prefix")
             .agg(lat=("geolocation_lat", "median"),
                  lng=("geolocation_lng", "median"),
                  city=("geolocation_city", lambda s: s.mode().iat[0]),
                  state=("geolocation_state", lambda s: s.mode().iat[0]),
                  n_points=("geolocation_lat", "size"))
             .reset_index()
             .rename(columns={"geolocation_zip_code_prefix": "zip_code_prefix"}))
    log.add("geolocation", "agrégation par code postal", "modifié",
            n_before - len(agg),
            "une ligne par code postal (médiane lat/lng) pour éviter les jointures multipliantes")
    return agg


# --------------------------------------------------------------------------
# Orchestration
# --------------------------------------------------------------------------
def run():
    log = CleaningLog()
    raw = load_raw()

    clean = {
        "customers": clean_customers(raw["customers"], log),
        "order_items": clean_order_items(raw["order_items"], log),
        "order_payments": clean_order_payments(raw["order_payments"], log),
        "products": clean_products(raw["products"], raw["category_translation"], log),
        "sellers": clean_sellers(raw["sellers"], log),
        "order_reviews": clean_order_reviews(raw["order_reviews"], log),
        "geolocation": clean_geolocation(raw["geolocation"], log),
    }
    clean["orders"] = clean_orders(raw["orders"], clean["order_items"],
                                   clean["order_payments"], log)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, df in clean.items():
        df.to_csv(OUT_DIR / f"{name}.csv", index=False)
        print(f"{name:18s} {len(df):>9,} lignes -> data/processed/{name}.csv")

    log.save(LOG_PATH)
    print(f"\nJournal de nettoyage : {LOG_PATH}")


if __name__ == "__main__":
    run()
