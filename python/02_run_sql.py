from pathlib import Path
import duckdb


DB_PATH = Path("../data/warehouse/operations.duckdb")
SQL_DIR = Path("../sql")


SQL_FILES = [
    "00_create_schema.sql",
    "01_stage_311_requests.sql",
    "02_dim_date.sql",
    "03_dim_agency.sql",
    "04_dim_request_type.sql",
    "05_dim_location.sql",
    "06_fact_service_request.sql",
    "07_data_quality_checks.sql",
]


def main() -> None:
    con = duckdb.connect(DB_PATH)

    for file_name in SQL_FILES:
        sql_path = SQL_DIR / file_name
        print(f"Running {sql_path}")

        sql = sql_path.read_text(encoding="utf-8")
        con.execute(sql)

    con.close()

    print("SQL model build complete")


if __name__ == "__main__":
    main()