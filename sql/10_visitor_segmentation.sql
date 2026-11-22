-- =====================================================
-- PRODUCT GROWTH LAB
-- Phase 5: Visitor behavioral segmentation
-- Source: clean_events
-- Observation window: First 7 days
-- =====================================================

CREATE OR REPLACE TABLE visitor_features AS

WITH data_bounds AS (
    SELECT MAX(event_timestamp) AS last_event_at
    FROM clean_events
),

first_seen AS (
    SELECT
        visitor_id,
        MIN(event_timestamp) AS first_seen_at
    FROM clean_events
    GROUP BY visitor_id
),

eligible_visitors AS (
    SELECT
        f.visitor_id,
        f.first_seen_at,
        f.first_seen_at + INTERVAL 7 DAY AS window_end
    FROM first_seen f
    CROSS JOIN data_bounds b
    WHERE f.first_seen_at + INTERVAL 7 DAY
          <= b.last_event_at
)

SELECT
    v.visitor_id,
    v.first_seen_at,
    CAST(v.first_seen_at AS DATE) AS cohort_date,
    v.window_end,

    COUNT(*) AS total_events,

    COUNT(*) FILTER (
        WHERE e.event_type = 'view'
    ) AS product_views,

    COUNT(*) FILTER (
        WHERE e.event_type = 'addtocart'
    ) AS cart_events,

    COUNT(*) FILTER (
        WHERE e.event_type = 'transaction'
    ) AS transaction_events,

    COUNT(DISTINCT e.transaction_id) FILTER (
        WHERE e.event_type = 'transaction'
    ) AS distinct_transactions,

    COUNT(DISTINCT e.item_id) AS unique_items,

    COUNT(DISTINCT e.event_date) AS active_days,

    MIN(e.event_timestamp) FILTER (
        WHERE e.event_type = 'addtocart'
    ) AS first_cart_at,

    MIN(e.event_timestamp) FILTER (
        WHERE e.event_type = 'transaction'
    ) AS first_purchase_at

FROM eligible_visitors v

JOIN clean_events e
    ON v.visitor_id = e.visitor_id
   AND e.event_timestamp >= v.first_seen_at
   AND e.event_timestamp < v.window_end

GROUP BY
    v.visitor_id,
    v.first_seen_at,
    v.window_end;


-- Assign one segment to each visitor

CREATE OR REPLACE TABLE visitor_segments AS

SELECT
    *,

    CASE
        WHEN distinct_transactions >= 2
            THEN 'Repeat purchasers'

        WHEN distinct_transactions = 1
            THEN 'Single purchasers'

        WHEN cart_events > 0
            THEN 'Cart without purchase'

        WHEN product_views >= 5
            THEN 'High-activity browsers'

        WHEN active_days >= 2
            THEN 'Returning low-activity browsers'

        ELSE 'One-day low-activity browsers'
    END AS behavioral_segment

FROM visitor_features;


-- Segment distribution

CREATE OR REPLACE TABLE segment_summary AS

SELECT
    behavioral_segment,

    COUNT(*) AS visitors,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS visitor_share_pct,

    ROUND(AVG(product_views), 2)
        AS avg_product_views,

    ROUND(AVG(unique_items), 2)
        AS avg_unique_items,

    ROUND(AVG(active_days), 2)
        AS avg_active_days,

    ROUND(AVG(cart_events), 2)
        AS avg_cart_events

FROM visitor_segments

GROUP BY behavioral_segment;


SELECT *
FROM segment_summary
ORDER BY visitors DESC;