# Product Growth Lab

### From Product Discovery to Retention: Understanding E-commerce User Behavior

**Product Analytics | SQL | Python | DuckDB | Tableau | A/B Testing**

## Project Overview

Why do visitors browse products without converting, and what distinguishes one-time visitors from those who return?

Product Growth Lab investigates the customer journey using **2.76 million behavioral events** from the Retailrocket e-commerce dataset.

The project combines SQL-based funnel analysis, retention and cohort modeling, behavioral segmentation, Tableau dashboards, and a reproducible synthetic A/B experiment to identify product opportunities and develop an evidence-based product recommendation.

## Business Questions

1. Where do visitors drop off between product discovery and purchase?
2. How many visitors return on D1, D7 and D30?
3. How does early cart activation relate to subsequent retention?
4. Which behavioral segments represent opportunities for product improvement?
5. How could a proposed discovery feature be evaluated through controlled experimentation?

---

## 1. Conversion Funnel Analysis

A chronological seven-day funnel was constructed for **1,348,273 eligible visitors**.

| Funnel Stage | Visitors | Overall Conversion |
|---|---:|---:|
| First observed visit | 1,348,273 | 100.00% |
| Product view | 1,344,937 | 99.75% |
| Add to cart | 29,125 | 2.16% |
| Transaction | 8,531 | 0.63% |

**Key finding:** The largest drop-off occurred between product viewing and cart activation, with 97.83% of viewers not progressing to the next qualifying stage within the seven-day window.

This identifies where progression is limited, but not the underlying cause.

## 2. Retention and Cohort Analysis

Exact-day retention was measured using each visitor's first observed date as the cohort entry point.

| Retention Metric | Rate |
|---|---:|
| D1 | 2.77% |
| D7 | 0.56% |
| D30 | 0.16% |

Visitors who activated on Day 0 demonstrated approximately **3.17× higher D7 retention** than visitors who did not activate.

The relationship is observational and does not establish causation.

### Retention Dashboard

![Retention Analytics Dashboard](dashboard/retention_dashboard.png)

The dashboard presents exact-day retention, weekly cohort heatmaps and activation-based retention comparisons.

---

## 3. Behavioral Segmentation

Visitors were grouped into six mutually exclusive segments based on their first seven days of observed behavior.

| Segment | Visitors | Share |
|---|---:|---:|
| One-day low-activity browsers | 1,215,545 | 90.16% |
| Returning low-activity browsers | 50,843 | 3.77% |
| High-activity browsers | 47,149 | 3.50% |
| Cart without purchase | 24,571 | 1.82% |
| Single purchasers | 9,450 | 0.70% |
| Repeat purchasers | 715 | 0.05% |

**Key finding:** High-activity browsers averaged 8.43 product views and interacted with 5.25 unique items without observed first-week cart activity.

Among D30-eligible visitors, high-activity browsers recorded **0.745% D30 retention**, compared with 0.115% for one-day low-activity browsers.

These results support investigating improvements to product discovery and comparison functionality.

### Behavioral Segmentation Dashboard

Add your exported behavioral segmentation dashboard screenshot here once saved.

---

## 4. Synthetic A/B Experiment

A reproducible synthetic experiment was designed to illustrate how a Guided Product Discovery feature could be evaluated.

**Important: All experiment assignments and treatment outcomes are simulated. No real Retailrocket visitors were exposed to the proposed feature.**

The experiment simulated 200,000 visitors with equal allocation to control and treatment groups.

| Metric | Control | Treatment |
|---|---:|---:|
| Seven-day cart activation | 2.192% | 2.541% |
| Seven-day purchase conversion | 0.618% | 0.739% |

The simulated activation improvement was:

- **Absolute uplift:** +0.349 percentage points
- **Relative uplift:** +15.92%
- **95% confidence interval:** +0.216 to +0.482 percentage points
- **Purchase-conversion guardrail:** Passed

The simulation met its predefined statistical and guardrail decision criteria.

These results demonstrate the statistical evaluation workflow, not actual product impact.

---

## 5. Product Recommendation

### Guided Product Discovery

The proposed product improvement targets visitors who reach their fifth product view without adding an item to their cart.

The experience would include:

- Relevant product recommendations.
- Side-by-side product comparisons.
- Clear product attribute summaries.
- Direct navigation to product pages.
- A dismissible, non-intrusive interface.

**Recommendation:** Prototype the feature and evaluate it through a properly powered live randomized experiment before making a deployment decision.

The historical behavioral analysis and synthetic experiment alone do not establish that the feature will improve conversion.

**[Read the Product Requirements Document](docs/product_requirements.md)**

---

## 6. Technology Stack

| Technology | Application |
|---|---|
| SQL / DuckDB | Event processing, funnel and cohort queries, behavioral segmentation |
| Python | Data preparation, validation and experiment simulation |
| pandas / NumPy | Data manipulation and synthetic event generation |
| SciPy / statsmodels | Statistical tests and confidence intervals |
| Tableau | Product analytics dashboards |
| Git / GitHub | Version control and reproducibility |

---

## 7. Project Structure

```text
product-growth-lab/
├── data/             # Raw and generated data (excluded from Git)
├── sql/              # Analytical SQL queries
├── src/              # Python scripts
├── dashboard/        # Tableau dashboards and screenshots
├── docs/             # Analysis findings and PRD
├── tests/            # Data validation tests
├── requirements.txt
└── README.md
```

## 8. Reproducing the Analysis

1. Clone this repository.
2. Create a Python virtual environment.
3. Install packages using `pip install -r requirements.txt`.
4. Download the Retailrocket e-commerce dataset from Kaggle.
5. Place `events.csv` in `data/raw/`.
6. Run the Python import script to create the DuckDB database.
7. Run the SQL scripts in their documented dependency order.
8. Export analysis-ready CSV files for Tableau.
9. Run the synthetic experiment generator and statistical analysis scripts.
10. Open the Tableau dashboards to review the results.

The raw Retailrocket dataset is not included in the repository.

---

## 9. Limitations

- The dataset represents anonymous e-commerce events, not verified registrations or subscription activity.
- First observed activity is not necessarily a visitor's first-ever visit.
- Retention is measured using exact calendar-day activity.
- Behavioral differences are observational and do not establish causation.
- The synthetic experiment uses assumed probabilities rather than observed treatment effects.
- Acquisition-channel and device information are not available in the source event data.

---

## Project Conclusion

The analysis identified substantial product-view-to-cart drop-off, limited exact-day repeat engagement and meaningful differences across visitor behavioral segments.

These findings motivated a proposed Guided Product Discovery feature for engaged browsers.

The project demonstrates the complete product analytics workflow: **diagnosing user behavior, identifying opportunities, defining product requirements, and evaluating a hypothetical intervention through statistical experimentation.**