from pathlib import Path
import duckdb

# Project locations
PROJECT_ROOT = Path(__file__).resolve().parents[1]

DB_PATH = PROJECT_ROOT / "data" / "product_growth.duckdb"

OUTPUT_DIR = PROJECT_ROOT / "data" / "outputs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Connect to DuckDB
con = duckdb.connect(str(DB_PATH), read_only=True)

# Export funnel summary
funnel_summary = con.execute("""
    SELECT *
    FROM funnel_summary
    ORDER BY stage_order
""").df()

funnel_summary.to_csv(
    OUTPUT_DIR / "funnel_summary.csv",
    index=False
)

# Export drop-off segmentation
dropoff = con.execute("""
    SELECT
        CASE
            WHEN purchased = 1
                THEN 'Completed purchase'
            WHEN activated = 1
                THEN 'Added to cart, no purchase'
            WHEN viewed = 1
                THEN 'Viewed, no add-to-cart'
            ELSE 'No observed product view'
        END AS furthest_stage,

        COUNT(*) AS visitors

    FROM funnel_visitors
    GROUP BY furthest_stage
""").df()

dropoff.to_csv(
    OUTPUT_DIR / "funnel_dropoff.csv",
    index=False
)

print("Export complete!")
print(funnel_summary)

con.close()
