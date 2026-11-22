-- ====================================================
-- PRODUCT GROWTH LAB
-- Phase 4: Day-0 activation and retention
-- ====================================================

CREATE OR REPLACE TABLE day0_activation AS

WITH first_view AS (
    SELECT
        e.visitor_id,
        MIN(e.event_timestamp) AS first_view_at

    FROM clean_events e
    INNER JOIN visitor_cohorts c
        ON e.visitor_id = c.visitor_id

    WHERE e.event_type = 'view'
      AND e.event_date = c.cohort_date

    GROUP BY e.visitor_id
),

same_day_cart AS (
    SELECT DISTINCT
        e.visitor_id

    FROM clean_events e
    INNER JOIN first_view v
        ON e.visitor_id = v.visitor_id
    INNER JOIN visitor_cohorts c
        ON e.visitor_id = c.visitor_id

    WHERE e.event_type = 'addtocart'
      AND e.event_date = c.cohort_date
      AND e.event_timestamp >= v.first_view_at
)

SELECT
    c.visitor_id,
    c.cohort_date,

    CASE
        WHEN s.visitor_id IS NOT NULL
        THEN 'Activated on Day 0'
        ELSE 'Not activated on Day 0'
    END AS activation_group

FROM visitor_cohorts c

LEFT JOIN same_day_cart s
    ON c.visitor_id = s.visitor_id;


-- Calculate retention by activation group

CREATE OR REPLACE TABLE activation_retention AS

WITH
data_bounds AS (
    SELECT MAX(event_date) AS last_event_date
    FROM clean_events
),

measurement_days AS (
    SELECT 1 AS day_number
    UNION ALL SELECT 7
    UNION ALL SELECT 30
),

eligible AS (
    SELECT
        a.visitor_id,
        a.activation_group,
        d.day_number

    FROM day0_activation a
    CROSS JOIN measurement_days d
    CROSS JOIN data_bounds b

    WHERE a.cohort_date + d.day_number
          < b.last_event_date
),

retention_flags AS (
    SELECT
        e.activation_group,
        e.day_number,

        CASE
            WHEN r.visitor_id IS NOT NULL
            THEN 1 ELSE 0
        END AS retained

    FROM eligible e

    LEFT JOIN visitor_return_days r
        ON e.visitor_id = r.visitor_id
       AND e.day_number = r.days_since_first_seen
)

SELECT
    activation_group,
    day_number,
    COUNT(*) AS eligible_visitors,
    SUM(retained) AS retained_visitors,

    ROUND(
        100.0 * SUM(retained) /
        NULLIF(COUNT(*), 0),
        2
    ) AS retention_pct

FROM retention_flags

GROUP BY activation_group, day_number

ORDER BY activation_group, day_number;


SELECT *
FROM activation_retention
ORDER BY day_number, activation_group;