-- Product Growth Lab
-- Seven-day chronological funnel summary

CREATE OR REPLACE TABLE funnel_summary AS

WITH funnel_counts AS (
    SELECT
        COUNT(*) AS total_visitors,
        SUM(viewed) AS view_visitors,
        SUM(activated) AS cart_visitors,
        SUM(purchased) AS purchase_visitors
    FROM funnel_visitors
),

stages AS (
    SELECT 1 AS stage_order,
           'First observed visit' AS stage,
           total_visitors AS visitors
    FROM funnel_counts

    UNION ALL

    SELECT 2,
           'Product view',
           view_visitors
    FROM funnel_counts

    UNION ALL

    SELECT 3,
           'Add to cart',
           cart_visitors
    FROM funnel_counts

    UNION ALL

    SELECT 4,
           'Transaction',
           purchase_visitors
    FROM funnel_counts
),

metrics AS (
    SELECT
        stage_order,
        stage,
        visitors,

        FIRST_VALUE(visitors) OVER (
            ORDER BY stage_order
        ) AS total_visitors,

        LAG(visitors) OVER (
            ORDER BY stage_order
        ) AS previous_visitors

    FROM stages
)

SELECT
    stage_order,
    stage,
    visitors,

    ROUND(
        100.0 * visitors /
        NULLIF(total_visitors, 0),
        2
    ) AS overall_conversion_pct,

    ROUND(
        100.0 * visitors /
        NULLIF(
            COALESCE(previous_visitors, visitors),
            0
        ),
        2
    ) AS step_conversion_pct,

    CASE
        WHEN previous_visitors IS NULL THEN NULL
        ELSE previous_visitors - visitors
    END AS dropped_visitors,

    CASE
        WHEN previous_visitors IS NULL THEN NULL
        ELSE ROUND(
            100.0 * (previous_visitors - visitors) /
            NULLIF(previous_visitors, 0),
            2
        )
    END AS step_dropoff_pct

FROM metrics
ORDER BY stage_order;


-- Display the results
SELECT *
FROM funnel_summary
ORDER BY stage_order;