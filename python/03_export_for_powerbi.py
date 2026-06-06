from pathlib import Path
import duckdb


DB_PATH = Path("../data/warehouse/operations.duckdb")
OUTPUT_DIR = Path("../output/powerbi_exports")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

EXPORTS = {
    "fact_service_request": "mart.fact_service_request",
    "dim_date": "mart.dim_date",
    "dim_agency": "mart.dim_agency",
    "dim_request_type": "mart.dim_request_type",
    "dim_location": "mart.dim_location",
    "data_quality_results": "dq.data_quality_results",
}


def main() -> None:
    con = duckdb.connect(DB_PATH)

    for file_name, table_name in EXPORTS.items():
        output_path = OUTPUT_DIR / f"{file_name}.csv"

        con.execute(f"""
            COPY {table_name}
            TO '{output_path.as_posix()}'
            WITH (HEADER, DELIMITER ',');
        """)

        print(f"Exported {table_name} to {output_path}")

    con.close()

    print("Power BI exports complete.")


if __name__ == "__main__":
    main()