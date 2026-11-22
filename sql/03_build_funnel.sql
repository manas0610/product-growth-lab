-- ======================================================
-- PRODUCT GROWTH LAB
-- Phase 3: Chronological visitor-level funnel
-- Window: 7 days from first observed event
-- Source: clean_events
-- ======================================================

CREATE OR REPLACE TABLE funnel_visitors AS

WITH

-- STEP 1: Find when each visitor was first observed
first_seen AS (
    SELECT
        visitor_id,
        MIN(event_timestamp) AS first_seen_at
    FROM clean_events
    GROUP BY visitor_id
),

-- STEP 2: Identify the latest timestamp in our data
data_end AS (
    SELECT
        MAX(event_timestamp) AS last_event_at
    FROM clean_events
),

-- STEP 3: Keep visitors with a full 7-day window
eligible_visitors AS (
    SELECT
        f.visitor_id,
        f.first_seen_at,

        f.first_seen_at + INTERVAL 7 DAY
            AS window_end

    FROM first_seen f
    CROSS JOIN data_end d

    WHERE f.first_seen_at + INTERVAL 7 DAY
          <= d.last_event_at
),

-- STEP 4: First product view inside the window
first_view AS (
    SELECT
        e.visitor_id,
        MIN(e.event_timestamp) AS first_view_at

    FROM clean_events e
    INNER JOIN eligible_visitors v
        ON e.visitor_id = v.visitor_id

    WHERE e.event_type = 'view'
      AND e.event_timestamp >= v.first_seen_at
      AND e.event_timestamp < v.window_end

    GROUP BY e.visitor_id
),

-- STEP 5: First add-to-cart after the first view
first_cart AS (
    SELECT
        e.visitor_id,
        MIN(e.event_timestamp) AS first_cart_at

    FROM clean_events e
    INNER JOIN eligible_visitors v
        ON e.visitor_id = v.visitor_id
    INNER JOIN first_view fv
        ON e.visitor_id = fv.visitor_id

    WHERE e.event_type = 'addtocart'
      AND e.event_timestamp >= fv.first_view_at
      AND e.event_timestamp < v.window_end

    GROUP BY e.visitor_id
),

-- STEP 6: First transaction after the first cart
first_purchase AS (
    SELECT
        e.visitor_id,
        MIN(e.event_timestamp) AS first_purchase_at

    FROM clean_events e
    INNER JOIN eligible_visitors v
        ON e.visitor_id = v.visitor_id
    INNER JOIN first_cart fc
        ON e.visitor_id = fc.visitor_id

    WHERE e.event_type = 'transaction'
      AND e.event_timestamp >= fc.first_cart_at
      AND e.event_timestamp < v.window_end

    GROUP BY e.visitor_id
)

-- STEP 7: Combine the stages into one visitor table
SELECT
    v.visitor_id,
    v.first_seen_at,
    CAST(v.first_seen_at AS DATE) AS cohort_date,
    v.window_end,

    fv.first_view_at,
    fc.first_cart_at,
    fp.first_purchase_at,

    -- Funnel stage flags
    CASE WHEN fv.first_view_at IS NOT NULL
         THEN 1 ELSE 0 END AS viewed,

    CASE WHEN fc.first_cart_at IS NOT NULL
         THEN 1 ELSE 0 END AS activated,

    CASE WHEN fp.first_purchase_at IS NOT NULL
         THEN 1 ELSE 0 END AS purchased

FROM eligible_visitors v

LEFT JOIN first_view fv
    ON v.visitor_id = fv.visitor_id

LEFT JOIN first_cart fc
    ON v.visitor_id = fc.visitor_id

LEFT JOIN first_purchase fp
    ON v.visitor_id = fp.visitor_id;


-- Verify the finished table
SELECT *
FROM funnel_visitors
LIMIT 20;