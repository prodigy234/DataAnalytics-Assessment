-- Question 1: Transaction Frequency Analysis
-- Analyze average monthly transaction frequency per customer
-- Categorize customers as High, Medium, or Low frequency users

WITH customer_tx_counts AS (
    SELECT
        s.owner_id,
        COUNT(*) AS total_transactions,
        -- Determine how many months between first and last transaction (minimum = 1 month)
        GREATEST(
            TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)),
            1
        ) AS active_months
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
),
monthly_avg AS (
    SELECT
        c.owner_id,
        ROUND(c.total_transactions / c.active_months, 2) AS avg_tx_per_month
    FROM customer_tx_counts c
),
categorized AS (
    SELECT
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_tx_per_month
    FROM monthly_avg
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
