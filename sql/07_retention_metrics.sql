-- ====================================================
-- PRODUCT GROWTH LAB
-- Phase 4: D1, D7 and D30 exact-day retention
-- ====================================================

CREATE OR REPLACE TABLE retention_summary AS

WITH

-- Get the last recorded date
data_bounds AS (
    SELECT
        MAX(event_date) AS last_event_date
    FROM clean_events
),

-- Specify our retention measurement days
retention_days AS (
    SELECT 1 AS day_number
    UNION ALL SELECT 7
    UNION ALL SELECT 30
),

-- Generate eligible visitor-day combinations
eligible_visitors AS (
    SELECT
        c.visitor_id,
        c.cohort_date,
        d.day_number

    FROM visitor_cohorts c
    CROSS JOIN retention_days d
    CROSS JOIN data_bounds b

    WHERE c.cohort_date + d.day_number
          < b.last_event_date
),

-- Check whether each visitor returned on that day
retention_flags AS (
    SELECT
        e.visitor_id,
        e.day_number,

        CASE
            WHEN r.visitor_id IS NOT NULL
            THEN 1
            ELSE 0
        END AS retained

    FROM eligible_visitors e

    LEFT JOIN visitor_return_days r
        ON e.visitor_id = r.visitor_id
       AND e.day_number = r.days_since_first_seen
)

-- Aggregate visitor-level results
SELECT
    day_number,

    COUNT(*) AS eligible_visitors,

    SUM(retained) AS retained_visitors,

    ROUND(
        100.0 * SUM(retained) /
        NULLIF(COUNT(*), 0),
        2
    ) AS retention_pct

FROM retention_flags

GROUP BY day_number
ORDER BY day_number;


-- Display retention results
SELECT *
FROM retention_summary
ORDER BY day_number;