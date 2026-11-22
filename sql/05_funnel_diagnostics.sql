SELECT
    CASE
        WHEN purchased = 1
            THEN 'Completed purchase'

        WHEN activated = 1
            THEN 'Added to cart, no purchase'

        WHEN viewed = 1
            THEN 'Viewed, no add-to-cart'

        ELSE 'No observed product view'
    END AS furthest_stage,

    COUNT(*) AS visitors,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_visitors

FROM funnel_visitors

GROUP BY furthest_stage

ORDER BY visitors DESC;