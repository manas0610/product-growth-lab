from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parents[1]

DB_PATH = PROJECT_ROOT / "data" / "product_growth.duckdb"
SQL_PATH = PROJECT_ROOT / "sql" / "01_clean_events.sql"

# Check required files
if not DB_PATH.exists():
    raise FileNotFoundError("Database not found. Run the import first.")

if not SQL_PATH.exists():
    raise FileNotFoundError("SQL cleaning script not found.")

# Connect to the existing database
con = duckdb.connect(str(DB_PATH))
con.execute("SET TimeZone = 'UTC'")

# Read and execute the SQL script
sql_code = SQL_PATH.read_text(encoding="utf-8")
con.execute(sql_code)

# Validate record reconciliation
result = con.execute("""
    SELECT
        (SELECT COUNT(*) FROM raw_events) AS raw_rows,
        (SELECT COUNT(*) FROM clean_events) AS clean_rows,
        (SELECT COUNT(*) FROM rejected_events) AS rejected_rows
""").fetchone()

raw_rows, clean_rows, rejected_rows = result

assert raw_rows == clean_rows + rejected_rows, (
    "Reconciliation failed: row counts do not match."
)

print("Raw events:", raw_rows)
print("Clean events:", clean_rows)
print("Rejected events:", rejected_rows)
print("Reconciliation passed!")

con.close()
