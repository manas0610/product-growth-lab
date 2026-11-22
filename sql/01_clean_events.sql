-- PRODUCT GROWTH LAB
-- Phase 2: Event cleaning
-- Source: raw_events
-- Time zone: UTC

-- Step 1: Standardize raw column types

CREATE OR REPLACE TABLE typed_events AS
SELECT
    TRY_CAST(timestamp AS BIGINT) AS timestamp_ms,
    TRY_CAST(visitorid AS BIGINT) AS visitor_id,
    TRIM(event) AS event_type,
    TRY_CAST(itemid AS BIGINT) AS item_id,
    TRY_CAST(transactionid AS BIGINT) AS transaction_id,

    -- Preserve original values for auditing
    timestamp AS raw_timestamp,
    visitorid AS raw_visitor_id,
    event AS raw_event,
    itemid AS raw_item_id,
    transactionid AS raw_transaction_id

FROM raw_events;


-- Step 2: Identify invalid records

CREATE OR REPLACE TABLE rejected_events AS
SELECT *
FROM typed_events
WHERE timestamp_ms IS NULL
   OR timestamp_ms < 0
   OR timestamp_ms > 253402300799999
   OR visitor_id IS NULL
   OR item_id IS NULL
   OR event_type NOT IN (
       'view',
       'addtocart',
       'transaction'
   )
   OR (
       event_type = 'transaction'
       AND transaction_id IS NULL
   );


-- Step 3: Create the cleaned events table

CREATE OR REPLACE TABLE clean_events AS
SELECT
    timestamp_ms,

    -- Convert Unix milliseconds to timestamps
    epoch_ms(timestamp_ms) AS event_timestamp,

    CAST(epoch_ms(timestamp_ms) AS DATE) AS event_date,

    visitor_id,
    event_type,
    item_id,
    transaction_id

FROM typed_events
WHERE timestamp_ms IS NOT NULL
  AND timestamp_ms BETWEEN 0 AND 253402300799999
  AND visitor_id IS NOT NULL
  AND item_id IS NOT NULL
  AND event_type IN (
      'view',
      'addtocart',
      'transaction'
  )
  AND (
      event_type <> 'transaction'
      OR transaction_id IS NOT NULL
  );


-- Step 4: Verify how many rows remain

SELECT
    (SELECT COUNT(*) FROM raw_events) AS raw_rows,
    (SELECT COUNT(*) FROM clean_events) AS clean_rows,
    (SELECT COUNT(*) FROM rejected_events) AS rejected_rows;