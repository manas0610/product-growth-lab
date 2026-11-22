# Product Growth Lab — Behavioral Segmentation Findings

## Business Question

Which visitor behavior patterns are associated with meaningful engagement and repeat activity, and which groups warrant further product investigation?

## Methodology

Visitors were classified into six mutually exclusive behavioral groups using events recorded during their first seven days of observed activity.

The analysis included **1,348,273 eligible visitors**.

## Segment Distribution

| Segment | Visitors | Share |
|---|---:|---:|
| One-day low-activity browsers | 1,215,545 | 90.16% |
| Returning low-activity browsers | 50,843 | 3.77% |
| High-activity browsers | 47,149 | 3.50% |
| Cart without purchase | 24,571 | 1.82% |
| Single purchasers | 9,450 | 0.70% |
| Repeat purchasers | 715 | 0.05% |

## Key Findings

### 1. Limited Initial Engagement

Approximately 90.16% of eligible visitors were classified as one-day low-activity browsers, with an average of 1.25 product views during the seven-day observation window.

### 2. High-Activity Browsers Represent a Discovery Opportunity

The high-activity browsing segment contained 47,149 visitors, averaging 8.43 product views and 5.25 unique items viewed.

This group demonstrated substantial product exploration without observed cart or purchase activity during the initial seven-day window.

### 3. Engagement Is Associated With Subsequent Retention

Among D30-eligible visitors, high-activity browsers recorded 0.745% exact-day retention compared with 0.115% among one-day low-activity browsers.

The approximately 6.5× difference is observational and does not establish a causal relationship.

## Product Recommendation

Investigate a guided product discovery experience for visitors reaching their fifth product view without a cart event.

Potential features include product comparisons, contextual recommendations, and clearer product information.

A live randomized experiment would be required to determine whether the intervention improves subsequent cart activation or purchase conversion.

## Limitations

- Behavioral segmentation is rule-based rather than predictive.
- Browsing intensity does not establish purchasing intent.
- Visitor identities are anonymous and may not correspond to registered accounts.
- Exact-day D30 retention is not subscription retention.
- Segment associations are observational.
- Historical segment membership uses seven days of behavior; real-time experiment eligibility must be determined using events observed up to the triggering moment.