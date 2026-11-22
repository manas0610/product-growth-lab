CREATE OR REPLACE TABLE synthetic_experiment AS

SELECT *
FROM read_csv(
    '/Users/manasmitra/Documents/Projects/product-growth-lab/data/outputs/synthetic_experiment.csv',
    header = true
);

SELECT
    experiment_group,
    COUNT(*) AS visitors,
    SUM(activated_7d) AS activated,
    SUM(purchased_7d) AS purchased
FROM synthetic_experiment
GROUP BY experiment_group;