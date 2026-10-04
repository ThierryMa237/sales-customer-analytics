"""Contrôles de cohérence sur data/processed (lancer : pytest -q)."""
from pathlib import Path

import pandas as pd
import pytest

PROCESSED = Path("data/processed")


def load(name):
    path = PROCESSED / f"{name}.csv"
    if not path.exists():
        pytest.skip(f"{path} absent : lancer python -m src.clean")
    return pd.read_csv(path)


def test_orders_id_unique():
    assert load("orders")["order_id"].is_unique


def test_customers_id_unique():
    assert load("customers")["customer_id"].is_unique


def test_products_id_unique():
    assert load("products")["product_id"].is_unique


def test_geolocation_one_row_per_zip():
    assert load("geolocation")["zip_code_prefix"].is_unique


def test_items_keys_unique():
    items = load("order_items")
    assert not items.duplicated(subset=["order_id", "order_item_id"]).any()


def test_items_prices_positive():
    assert (load("order_items")["price"] > 0).all()


def test_items_reference_existing_orders():
    items, orders = load("order_items"), load("orders")
    assert items["order_id"].isin(orders["order_id"]).all()


def test_scope_flag_is_consistent():
    o = load("orders")
    assert (o["in_scope"] == (o["is_delivered"] & o["in_window"])).all()


def test_scope_orders_fall_in_window():
    o = load("orders")
    purchase = pd.to_datetime(o.loc[o["in_scope"], "order_purchase_timestamp"])
    assert purchase.min() >= pd.Timestamp("2017-01-01")
    assert purchase.max() < pd.Timestamp("2018-09-01")


def test_products_have_english_category():
    assert load("products")["product_category_name_english"].notna().all()


def test_no_row_lost_on_core_tables():
    # Nettoyage sans suppression de lignes sur ces tables
    assert len(load("orders")) == 99441
    assert len(load("order_items")) == 112650
    assert len(load("products")) == 32951
