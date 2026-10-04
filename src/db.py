"""Connexion PostgreSQL via variables d'environnement."""
import os
from sqlalchemy import create_engine
from sqlalchemy.engine import URL


def get_engine():
    url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        database=os.getenv("PGDATABASE", "olist"),
    )
    return create_engine(url)
