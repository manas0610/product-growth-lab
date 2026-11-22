from pathlib import Path
import duckdb

# -----------------------------------
# 1. Define the file locations
# -----------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]

RAW_FILE = PROJECT_ROOT / "data" / "raw" / "events.csv"

DB_FILE = PROJECT_ROOT / "data" / "product_growth.duckdb"

OUTPUT_DIR = PROJECT_ROOT / "data" / "outputs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------------
# 2. Check that the dataset exists
# -----------------------------------

if not RAW_FILE.exists():
    raise FileNotFoundError(
        f"Cannot find events.csv at: {RAW_FILE}"
    )

print("Dataset found:", RAW_FILE.name)

# -----------------------------------
# 3. Connect to the DuckDB database
# -----------------------------------

con = duckdb.connect(str(DB_FILE))
con.execute("SET TimeZone = 'UTC'")

# -----------------------------------
# 4. Import the raw CSV
# -----------------------------------

print("Importing raw events...")

con.execute("""
    CREATE OR REPLACE TABLE raw_events AS
    SELECT *
    FROM read_csv(
        ?,
        header = true,
        all_varchar = true
    )
""", [str(RAW_FILE)])

# -----------------------------------
# 5. Check the imported schema
# -----------------------------------

required_columns = {
    "timestamp",
    "visitorid",
    "event",
    "itemid",
    "transactionid"
}

actual_columns = set(
    con.execute(
        "SELECT * FROM raw_events LIMIT 0"
    ).df().columns
)

missing_columns = required_columns - actual_columns

if missing_columns:
    con.close()
    raise ValueError(
        f"Missing required columns: {missing_columns}"
    )

# -----------------------------------
# 6. Calculate basic data quality
# -----------------------------------

audit = con.execute("""
    SELECT
        COUNT(*) AS total_events,

        COUNT(DISTINCT visitorid)
            AS unique_visitors,

        COUNT(DISTINCT itemid)
            AS unique_items,

        COUNT(*) FILTER (
            WHERE visitorid IS NULL
               OR TRIM(visitorid) = ''
        ) AS missing_visitor_ids,

        COUNT(*) FILTER (
            WHERE itemid IS NULL
               OR TRIM(itemid) = ''
        ) AS missing_item_ids,

        COUNT(*) FILTER (
            WHERE timestamp IS NULL
               OR TRY_CAST(timestamp AS BIGINT) IS NULL
        ) AS invalid_timestamps,

        COUNT(*) FILTER (
            WHERE event IS NULL
               OR event NOT IN (
                   'view',
                   'addtocart',
                   'transaction'
               )
        ) AS invalid_event_types,

        COUNT(*) FILTER (
            WHERE event = 'transaction'
              AND (
                  transactionid IS NULL
                  OR TRIM(transactionid) = ''
              )
        ) AS transactions_missing_ids

    FROM raw_events
""").df()

# -----------------------------------
# 7. Count each event type
# -----------------------------------

event_summary = con.execute("""
    SELECT
        event AS event_type,
        COUNT(*) AS event_count,
        COUNT(DISTINCT visitorid) AS unique_visitors
    FROM raw_events
    GROUP BY event
    ORDER BY event_count DESC
""").df()

# -----------------------------------
# 8. Detect exact duplicate rows
# -----------------------------------

duplicate_summary = con.execute("""
    SELECT
        SUM(row_count - 1) AS duplicate_extra_rows
    FROM (
        SELECT
            timestamp,
            visitorid,
            event,
            itemid,
            transactionid,
            COUNT(*) AS row_count
        FROM raw_events
        GROUP BY ALL
        HAVING COUNT(*) > 1
    )
""").df()

# -----------------------------------
# 9. Find the dataset date range
# -----------------------------------

date_range = con.execute("""
    SELECT
        MIN(
            TRY_CAST(timestamp AS BIGINT)
        ) AS earliest_timestamp_ms,

        MAX(
            TRY_CAST(timestamp AS BIGINT)
        ) AS latest_timestamp_ms

    FROM raw_events
""").df()

# -----------------------------------
# 10. Display and export reports
# -----------------------------------

print("\\nDATA QUALITY REPORT")
print(audit.to_string(index=False))

print("\\nEVENT DISTRIBUTION")
print(event_summary.to_string(index=False))

print("\\nDUPLICATE REPORT")
print(duplicate_summary.to_string(index=False))

print("\\nTIMESTAMP RANGE")
print(date_range.to_string(index=False))

audit.to_csv(
    OUTPUT_DIR / "data_quality_report.csv",
    index=False
)

event_summary.to_csv(
    OUTPUT_DIR / "event_distribution.csv",
    index=False
)

duplicate_summary.to_csv(
    OUTPUT_DIR / "duplicate_report.csv",
    index=False
)

print("\\nAudit completed successfully!")

con.close()
