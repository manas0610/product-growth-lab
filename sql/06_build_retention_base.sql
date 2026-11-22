-- ====================================================
-- PRODUCT GROWTH LAB
-- Phase 4: Retention base tables
-- ====================================================

-- 1. One row per visitor and their first observed date

CREATE OR REPLACE TABLE visitor_cohorts AS

SELECT
    visitor_id,
    MIN(event_date) AS cohort_date,
    DATE_TRUNC(
        'week',
        MIN(event_date)
    )::DATE AS cohort_week

FROM clean_events
GROUP BY visitor_id;


-- 2. One row per visitor per active calendar day

CREATE OR REPLACE TABLE visitor_active_days AS

SELECT DISTINCT
    visitor_id,
    event_date AS active_date

FROM clean_events;


-- 3. Calculate number of days since cohort entry

CREATE OR REPLACE TABLE visitor_return_days AS

SELECT
    a.visitor_id,
    c.cohort_date,
    c.cohort_week,
    a.active_date,

    DATE_DIFF(
        'day',
        c.cohort_date,
        a.active_date
    ) AS days_since_first_seen

FROM visitor_active_days a

INNER JOIN visitor_cohorts c
    ON a.visitor_id = c.visitor_id;


-- 4. Inspect visitor journeys

SELECT *
FROM visitor_return_days
ORDER BY visitor_id, active_date
LIMIT 30;