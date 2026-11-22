-- ====================================================
-- PRODUCT GROWTH LAB
-- Phase 4: Weekly cohort retention
-- Exact calendar-day retention
-- ====================================================

CREATE OR REPLACE TABLE weekly_cohort_retention AS

WITH

data_bounds AS (
    SELECT MAX(event_date) AS last_event_date
    FROM clean_events
),

measurement_days AS (
    SELECT 0 AS day_number
    UNION ALL SELECT 1
    UNION ALL SELECT 7
    UNION ALL SELECT 14
    UNION ALL SELECT 30
),

-- One row for each cohort, visitor and target day
cohort_grid AS (
    SELECT
        c.visitor_id,
        c.cohort_date,
        c.cohort_week,
        d.day_number,

        CASE
            WHEN d.day_number = 0 THEN 1
            WHEN c.cohort_date + d.day_number
                 < b.last_event_date THEN 1
            ELSE 0
        END AS is_eligible

    FROM visitor_cohorts c
    CROSS JOIN measurement_days d
    CROSS JOIN data_bounds b
),

-- Identify returning visitors
return_flags AS (
    SELECT
        g.cohort_week,
        g.day_number,
        g.visitor_id,
        g.is_eligible,

        CASE
            WHEN r.visitor_id IS NOT NULL
            THEN 1
            ELSE 0
        END AS retained

    FROM cohort_grid g

    LEFT JOIN visitor_return_days r
        ON g.visitor_id = r.visitor_id
       AND g.day_number = r.days_since_first_seen
)

SELECT
    cohort_week,
    day_number,

    COUNT(*) AS total_cohort_visitors,

    SUM(is_eligible) AS eligible_visitors,

    SUM(
        CASE
            WHEN is_eligible = 1
            THEN retained
            ELSE 0
        END
    ) AS retained_visitors,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN is_eligible = 1
                THEN retained
                ELSE 0
            END
        ) / NULLIF(SUM(is_eligible), 0),
        2
    ) AS retention_pct

FROM return_flags

GROUP BY
    cohort_week,
    day_number

ORDER BY
    cohort_week,
    day_number;


-- View the resulting table
SELECT *
FROM weekly_cohort_retention
ORDER BY cohort_week, day_number;