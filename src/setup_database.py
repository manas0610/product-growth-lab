from pathlib import Path
import duckdb

# Project root folder
PROJECT_ROOT = Path(__file__).resolve().parents[1]

# Database file location
DB_PATH = PROJECT_ROOT / "data" / "product_growth.duckdb"

# Connect to DuckDB
con = duckdb.connect(str(DB_PATH))

# Create a sample table
con.execute("""
    CREATE OR REPLACE TABLE setup_test (
        user_id INTEGER,
        event_type VARCHAR
    )
""")

# Insert sample records
con.execute("""
    INSERT INTO setup_test VALUES
    (101, 'view'),
    (102, 'addtocart'),
    (103, 'transaction')
""")

# Display the records
print(con.execute("SELECT * FROM setup_test").df())

con.close()

print("DuckDB database created successfully!")
