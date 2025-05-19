-- Question 3: Account Inactivity Alert
-- Identify active accounts (savings or investments) with no inflows in the last 365 days

-- I prepared for two solutions depending on the format you want the plan_id and owner_id (two of the columns in the output) to be in.
-- For both the plan_id and owner_id to be in format of UUIDs, you can run the code below
-- And if you are okay with the plan_id and owner_id being in short numeric IDs like 1001, I showed it in a second code which is below the first code below.
-- I commented the second code below the first code depending on your preference

-- For the plan_id and owner_id to be in UUID formats, then run the code below from line 10 to 39
WITH latest_inflows AS (
    SELECT
        s.plan_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0
    GROUP BY s.plan_id
)

SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    li.last_transaction_date,
    DATEDIFF(CURDATE(), li.last_transaction_date) AS inactivity_days
FROM plans_plan p
LEFT JOIN latest_inflows li ON p.id = li.plan_id
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    AND p.is_deleted = 0
    AND p.is_archived = 0
    AND (
        li.last_transaction_date IS NULL
        OR li.last_transaction_date < CURDATE() - INTERVAL 365 DAY
    )
ORDER BY inactivity_days DESC;


-- This is still on Question 3
-- For the second code commented below;
-- If you want the plan_id & owner_id to be in short numeric IDs formats
-- You can uncomment the code below from line 50 to 88, then run the code to see the output

-- Flag active savings/investment accounts with no inflows in the last 365 days
-- Format owner_id and plan_id as simulated numeric IDs

-- WITH latest_inflows AS (
--     SELECT
--         s.plan_id,
--         MAX(s.transaction_date) AS last_transaction_date
--     FROM savings_savingsaccount s
--     WHERE s.confirmed_amount > 0
--     GROUP BY s.plan_id
-- ),
-- filtered_plans AS (
--     SELECT
--         p.id AS plan_uuid,
--         p.owner_id AS user_uuid,
--         CASE
--             WHEN p.is_regular_savings = 1 THEN 'Savings'
--             WHEN p.is_a_fund = 1 THEN 'Investment'
--             ELSE 'Unknown'
--         END AS type,
--         li.last_transaction_date,
--         DATEDIFF(CURDATE(), li.last_transaction_date) AS inactivity_days
--     FROM plans_plan p
--     LEFT JOIN latest_inflows li ON p.id = li.plan_id
--     WHERE
--         (p.is_regular_savings = 1 OR p.is_a_fund = 1)
--         AND p.is_deleted = 0
--         AND p.is_archived = 0
--         AND (
--             li.last_transaction_date IS NULL
--             OR li.last_transaction_date < CURDATE() - INTERVAL 365 DAY
--         )
-- )

-- SELECT
--     ROW_NUMBER() OVER (ORDER BY plan_uuid) + 1000 AS plan_id,
--     ROW_NUMBER() OVER (ORDER BY user_uuid) + 300 AS owner_id,
--     type,
--     last_transaction_date,
--     inactivity_days
-- FROM filtered_plans
-- ORDER BY inactivity_days DESC;