from pathlib import Path
import json

import numpy as np
import pandas as pd

from statsmodels.stats.proportion import (
    proportions_ztest,
    confint_proportions_2indep,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "outputs"

data = pd.read_csv(
    OUT / "synthetic_experiment.csv"
)

assert data["synthetic_visitor_id"].is_unique
assert set(data["experiment_group"]) == {
    "control", "treatment"
}
assert data["is_synthetic"].all()
assert (
    data["purchased_7d"] <= data["activated_7d"]
).all()

# Proposed decision thresholds
ALPHA = 0.05
MIN_PRACTICAL_ACTIVATION_UPLIFT = 0.002
MAX_ACCEPTABLE_PURCHASE_DECLINE = 0.002


def evaluate_binary_metric(column):
    summary = (
        data.groupby("experiment_group")[column]
        .agg(["sum", "count"])
    )

    control = summary.loc["control"]
    treatment = summary.loc["treatment"]

    count_a = int(control["sum"])
    n_a = int(control["count"])

    count_b = int(treatment["sum"])
    n_b = int(treatment["count"])

    p_a = count_a / n_a
    p_b = count_b / n_b

    absolute_diff = p_b - p_a

    relative_uplift = (
        absolute_diff / p_a
        if p_a > 0 else np.nan
    )

    # Two-sided test of equal population proportions
    statistic, p_value = proportions_ztest(
        count=[count_b, count_a],
        nobs=[n_b, n_a],
        alternative="two-sided"
    )

    # 95% confidence interval for B minus A
    ci_low, ci_high = confint_proportions_2indep(
        count1=count_b,
        nobs1=n_b,
        count2=count_a,
        nobs2=n_a,
        compare="diff",
        method="newcomb",
        alpha=ALPHA
    )

    return {
        "metric": column,
        "control_n": n_a,
        "treatment_n": n_b,
        "control_successes": count_a,
        "treatment_successes": count_b,
        "control_rate_pct": p_a * 100,
        "treatment_rate_pct": p_b * 100,
        "absolute_diff_pp": absolute_diff * 100,
        "relative_uplift_pct": relative_uplift * 100,
        "ci_lower_pp": ci_low * 100,
        "ci_upper_pp": ci_high * 100,
        "p_value": float(p_value),
        "ci_lower": float(ci_low),
        "ci_upper": float(ci_high),
        "absolute_diff": float(absolute_diff),
    }


# Evaluate primary metric and purchase guardrail
activation = evaluate_binary_metric("activated_7d")
purchase = evaluate_binary_metric("purchased_7d")

# Primary decision criterion:
# positive statistically supported uplift
# AND a minimum practical point estimate
primary_pass = (
    activation["ci_lower"] > 0
    and activation["absolute_diff"]
        >= MIN_PRACTICAL_ACTIVATION_UPLIFT
)

# Guardrail: purchase decline cannot be worse
# than -0.2 percentage points at the chosen
# confidence-bound level.
purchase_guardrail_pass = (
    purchase["ci_lower"]
    > -MAX_ACCEPTABLE_PURCHASE_DECLINE
)

# A synthetic exercise decision only
if primary_pass and purchase_guardrail_pass:
    decision = "SIMULATED_SHIP_CRITERIA_MET"
else:
    decision = "SIMULATED_NO_SHIP"

report = {
    "is_synthetic": True,
    "activation": activation,
    "purchase": purchase,
    "primary_pass": bool(primary_pass),
    "purchase_guardrail_pass": bool(
        purchase_guardrail_pass
    ),
    "decision": decision,
    "caution": (
        "This decision applies only to synthetic "
        "simulation results, not real deployment."
    ),
}

# Save machine-readable report
(OUT / "experiment_results.json").write_text(
    json.dumps(report, indent=2),
    encoding="utf-8"
)

# Create Tableau-ready metric comparison
rows = []

for result in [activation, purchase]:
    rows.append({
        "metric": result["metric"],
        "control_rate_pct": result["control_rate_pct"],
        "treatment_rate_pct": result["treatment_rate_pct"],
        "absolute_diff_pp": result["absolute_diff_pp"],
        "relative_uplift_pct": result["relative_uplift_pct"],
        "ci_lower_pp": result["ci_lower_pp"],
        "ci_upper_pp": result["ci_upper_pp"],
        "p_value": result["p_value"],
        "is_synthetic": True,
    })

results_df = pd.DataFrame(rows)

results_df.to_csv(
    OUT / "experiment_summary.csv",
    index=False
)

print("\nSYNTHETIC A/B EXPERIMENT RESULTS\n")
print(results_df.to_string(index=False))

print("\nPrimary criterion passed:", primary_pass)
print("Purchase guardrail passed:", purchase_guardrail_pass)
print("Decision:", decision)
print("\nAll outcomes are simulated.")