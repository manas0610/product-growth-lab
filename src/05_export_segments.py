from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "data" / "product_growth.duckdb"
OUTPUT_DIR = ROOT / "data" / "outputs"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

tables = [
    "segment_summary",
    "segment_d30_retention",
]

with duckdb.connect(
    str(DB_PATH), read_only=True
) as con:

    for table_name in tables:
        output = OUTPUT_DIR / f"{table_name}.csv"

        df = con.execute(
            f"SELECT * FROM {table_name}"
        ).df()

        df.to_csv(output, index=False)

        print(f"{table_name}: {len(df)} rows exported")

print("Phase 5 exports completed.")