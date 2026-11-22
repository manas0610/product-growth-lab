-- =====================================================
-- Phase 5: Subsequent D30 retention by segment
-- =====================================================

CREATE OR REPLACE TABLE segment_d30_retention AS

WITH data_bounds AS (
    SELECT
        MAX(event_date) AS last_event_date
    FROM clean_events
),

eligible AS (
    SELECT
        s.visitor_id,
        s.behavioral_segment,
        s.cohort_date

    FROM visitor_segments s
    CROSS JOIN data_bounds b

    WHERE s.cohort_date + 30
          < b.last_event_date
),

visitor_outcomes AS (
    SELECT
        e.visitor_id,
        e.behavioral_segment,

        CASE
            WHEN r.visitor_id IS NOT NULL
            THEN 1 ELSE 0
        END AS retained_d30

    FROM eligible e

    LEFT JOIN visitor_return_days r
        ON e.visitor_id = r.visitor_id
       AND r.days_since_first_seen = 30
)

SELECT
    behavioral_segment,

    COUNT(*) AS eligible_visitors,

    SUM(retained_d30) AS retained_d30_visitors,

    ROUND(
        100.0 * SUM(retained_d30)
        / NULLIF(COUNT(*), 0),
        3
    ) AS d30_retention_pct

FROM visitor_outcomes

GROUP BY behavioral_segment;


SELECT *
FROM segment_d30_retention
ORDER BY d30_retention_pct DESC;