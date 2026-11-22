from pathlib import Path
import json

import numpy as np
import pandas as pd

# ====================================================
# Product Growth Lab
# SYNTHETIC EXPERIMENT - NOT REAL RETAILROCKET DATA
# ====================================================

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "outputs"
OUT.mkdir(parents=True, exist_ok=True)

SEED = 2026
N_PER_GROUP = 100_000

ASSUMPTIONS = {
    "control_activation_probability": 0.0216,
    "treatment_activation_probability": 0.0250,
    "purchase_probability_given_activation": 0.29,
}

rng = np.random.default_rng(SEED)

# 1. Create hypothetical visitor IDs
n_total = 2 * N_PER_GROUP

visitor_ids = np.arange(1, n_total + 1)

# 2. Random assignment
groups = np.array(
    ["control"] * N_PER_GROUP
    + ["treatment"] * N_PER_GROUP
)

rng.shuffle(groups)

# 3. Choose assumed activation probabilities
activation_prob = np.where(
    groups == "control",
    ASSUMPTIONS["control_activation_probability"],
    ASSUMPTIONS["treatment_activation_probability"],
)

# 4. Generate synthetic activation outcomes
activated = rng.binomial(
    n=1,
    p=activation_prob,
    size=n_total
)

# 5. Generate synthetic purchases
# Purchase is only possible after activation
purchase_after_activation = rng.binomial(
    n=1,
    p=ASSUMPTIONS[
        "purchase_probability_given_activation"
    ],
    size=n_total
)

purchased = activated * purchase_after_activation

# 6. Construct the synthetic experiment table
experiment = pd.DataFrame({
    "synthetic_visitor_id": visitor_ids,
    "experiment_group": groups,
    "activated_7d": activated,
    "purchased_7d": purchased,
    "is_synthetic": True,
})

# 7. Validate basic properties
assert experiment["synthetic_visitor_id"].is_unique
assert len(experiment) == n_total
assert experiment.groupby(
    "experiment_group"
).size().eq(N_PER_GROUP).all()

assert (
    experiment["purchased_7d"]
    <= experiment["activated_7d"]
).all()

assert experiment["is_synthetic"].all()

# 8. Save generated records
csv_path = OUT / "synthetic_experiment.csv"

experiment.to_csv(csv_path, index=False)

# 9. Save generation settings
metadata = {
    "synthetic": True,
    "seed": SEED,
    "n_per_group": N_PER_GROUP,
    "assumptions": ASSUMPTIONS,
    "description": (
        "Hypothetical randomized experiment. "
        "No real treatment exposure or causal "
        "effect was observed."
    ),
}

metadata_path = OUT / "experiment_metadata.json"

metadata_path.write_text(
    json.dumps(metadata, indent=2),
    encoding="utf-8"
)

# 10. Print initial summary
print(
    experiment.groupby("experiment_group")[
        ["activated_7d", "purchased_7d"]
    ].agg(["count", "sum", "mean"])
)

print("Saved:", csv_path)
print("Saved:", metadata_path)