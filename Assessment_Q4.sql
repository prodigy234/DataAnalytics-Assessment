-- Question 4: Customer Lifetime Value (CLV) Estimation
-- Estimate Customer Lifetime Value (CLV) based on transaction volume and account tenure

-- For this last question, I also prepared for two solutions depending on the format you want the customer_id(one of the columns in the final output) to be in.
-- For customer_id to be in format of UUIDs, you can run the first code below from line 9 to 39
-- And if you are okay with the customer_id being in short numeric IDs like 1001, I showed it in a second code which is below the first code below.
-- I commented the second code below the first code depending on your preference

WITH customer_activity AS (
    SELECT
        u.id AS customer_id,
        COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name), u.email) AS name,
        u.date_joined,
        COUNT(s.id) AS total_transactions,
        ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_value_naira  -- Kobo to Naira
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE s.confirmed_amount > 0
    GROUP BY u.id, u.name, u.date_joined
),
clv_calculation AS (
    SELECT
        ca.customer_id,
        ca.name,
        GREATEST(TIMESTAMPDIFF(MONTH, ca.date_joined, CURDATE()), 1) AS tenure_months,
        ca.total_transactions,
        ROUND(((ca.total_transactions / GREATEST(TIMESTAMPDIFF(MONTH, ca.date_joined, CURDATE()), 1)) * 12 * 
              (ca.total_value_naira / ca.total_transactions * 0.001)), 2) AS estimated_clv
    FROM customer_activity ca
)

SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calculation
ORDER BY estimated_clv DESC;

-- This is still on Question 4
-- For the second code commented below;
-- If you want the customer_id to be in short numeric IDs formats
-- You can uncomment the code below from line 50 to 80, then run the code to see the output
-- Estimate Customer Lifetime Value (CLV) based on transaction volume and account tenure

-- Estimate CLV based on transaction frequency and account tenure
-- Format customer_id as a simulated numeric ID

-- WITH customer_activity AS (
--     SELECT
--         u.id AS user_uuid,
--         COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name), u.email) AS name,
--         u.date_joined,
--         COUNT(s.id) AS total_transactions,
--         ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_value_naira
--     FROM users_customuser u
--     JOIN savings_savingsaccount s ON u.id = s.owner_id
--     WHERE s.confirmed_amount > 0
--     GROUP BY u.id, name, u.date_joined
-- ),
-- clv_calc AS (
--     SELECT
--         user_uuid,
--         name,
--         GREATEST(TIMESTAMPDIFF(MONTH, date_joined, CURDATE()), 1) AS tenure_months,
--         total_transactions,
--         ROUND(((total_transactions / GREATEST(TIMESTAMPDIFF(MONTH, date_joined, CURDATE()), 1)) * 12 *
--               (total_value_naira / total_transactions * 0.001)), 2) AS estimated_clv
--     FROM customer_activity
-- )

-- SELECT
--     ROW_NUMBER() OVER (ORDER BY estimated_clv DESC) + 1000 AS customer_id,
--     name,
--     tenure_months,
--     total_transactions,
--     estimated_clv
-- FROM clv_calc
-- ORDER BY estimated_clv DESC;