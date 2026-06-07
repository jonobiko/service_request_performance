from io import StringIO
from pathlib import Path
import os
import time

import duckdb
import pandas as pd
import requests
from dotenv import load_dotenv
from tqdm import tqdm

# load_dotenv()

DB_PATH = Path('../data/warehouse/operations.duckdb')
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

API_URL = 'https://nycopendata.socrata.com/resource/erm2-nwe9.csv'
API_TOKEN = os.getenv('SOCRATA_API_TOKEN')
BATCH_SIZE = 25000
START_DATE = '2025-01-01T00:00:00'
END_DATE = '2026-06-06T00:00:00'
COLUMNS = [
    'unique_key',
    'created_date',
    'closed_date',
    'agency',
    'agency_name',
    'complaint_type',
    'descriptor',
    'status',
    'due_date',
    'resolution_description',
    'borough',
    'incident_zip',
    'latitude',
    'longitude'
]


def get_existing_row_count(con: duckdb.DuckDBPyConnection) -> int:
    result = con.execute('SELECT count(*) FROM raw.raw_311_service_requests;').fetchone()

    return result[0]

def create_raw_table(con: duckdb.DuckDBPyConnection) -> None:
    con.execute("""
        CREATE SCHEMA IF NOT EXISTS raw;
        
        CREATE TABLE IF NOT EXISTS raw.raw_311_service_requests (
            unique_key VARCHAR,
            created_date VARCHAR,
            closed_date VARCHAR,
            agency VARCHAR,
            agency_name VARCHAR,
            complaint_type VARCHAR,
            descriptor VARCHAR,
            status VARCHAR,
            due_date VARCHAR,
            resolution_description VARCHAR,
            borough VARCHAR,
            incident_zip VARCHAR,
            latitude VARCHAR,
            longitude VARCHAR
        );
    """)

def fetch_batch(offset: int) -> pd.DataFrame:
    headers = {}

    if API_TOKEN:
        headers['X-App-Token'] = API_TOKEN

    params = {
        "$select": ",".join(COLUMNS),
        "$where": (
            f"created_date >= '{START_DATE}' "
            f"AND created_date < '{END_DATE}'"
        ),
        "$order": "created_date, unique_key",
        "$limit": BATCH_SIZE,
        "$offset": offset,
    }

    response = requests.get(
        API_URL,
        params=params,
        headers=headers,
        timeout=(10, 300),
    )

    response.raise_for_status()

    df = pd.read_csv(
        StringIO(response.text),
        dtype="string",
        keep_default_na=False,
    )

    # print(f'Columns returned by API: {df.columns.tolist()}')

    return df


def load_batch_to_duckdb(con: duckdb.DuckDBPyConnection, df: pd.DataFrame) -> None:
    con.register("batch_df", df)

    con.execute("""
        INSERT INTO raw.raw_311_service_requests
        SELECT
            unique_key,
            created_date,
            closed_date,
            agency,
            agency_name,
            complaint_type,
            descriptor,
            status,
            due_date,
            resolution_description,
            borough,
            incident_zip,
            latitude,
            longitude
        FROM batch_df;
    """)

    con.unregister("batch_df")


def main() -> None:
    con = duckdb.connect(DB_PATH)
    create_raw_table(con)

    offset = get_existing_row_count(con)
    total_rows = offset

    # offset = 0
    # total_rows = 0

    with tqdm(desc="Extracting NYC 311 data", unit=" rows") as progress:
        while True:
            df = fetch_batch(offset)

            if df.empty:
                break

            load_batch_to_duckdb(con, df)

            rows = len(df)
            total_rows += rows
            progress.update(rows)

            if rows < BATCH_SIZE:
                break

            offset += BATCH_SIZE

            time.sleep(0.5)

    con.close()

    print(f"Loaded {total_rows:,} rows into {DB_PATH}")


if __name__ == "__main__":
    main()