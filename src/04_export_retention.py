from pathlib import Path
import duckdb

# Project directory
PROJECT_ROOT = Path(__file__).resolve().parents[1]

# Database location
DB_PATH = PROJECT_ROOT / "data" / "product_growth.duckdb"

# Output location
OUTPUT_DIR = PROJECT_ROOT / "data" / "outputs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Connect in read-only mode
con = duckdb.connect(str(DB_PATH), read_only=True)

# Tables to export
tables = [
    "retention_summary",
    "weekly_cohort_retention",
    "activation_retention"
]

for table_name in tables:

    # Read the table into a pandas DataFrame
    df = con.execute(
        f"SELECT * FROM {table_name}"
    ).df()

    # Save the DataFrame as a CSV
    output_file = OUTPUT_DIR / f"{table_name}.csv"

    df.to_csv(output_file, index=False)

    print(
        f"Exported {table_name}: {len(df)} rows"
    )

con.close()

print("All retention exports completed!")
