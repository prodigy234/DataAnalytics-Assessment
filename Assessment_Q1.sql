-- Question 1: High-Value Customers with Multiple Products

-- I prepared for two solutions depending on the format you want the owner_id (one of the columns in the output) to be in.
-- For the owner_id to be in format of UUIDs, you can run the code below
-- And if you are okay with the owner_id being in short numeric IDs like 1001, I showed it in a second code which is below the first code below.
-- I commented the second code below the first code depending on your preference

-- For the owner_id to be in UUID formats, then run the code below from line 9 to 23
SELECT
    u.id AS owner_id,  -- UUID format is accurate per schema
    COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name), u.email) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    ROUND(SUM(COALESCE(s.confirmed_amount, 0)) / 100, 2) AS total_deposits
FROM users_customuser u
JOIN plans_plan p ON u.id = p.owner_id
JOIN savings_savingsaccount s ON s.plan_id = p.id
WHERE s.confirmed_amount > 0
GROUP BY u.id, name
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) >= 1 AND
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) >= 1
ORDER BY total_deposits DESC;


-- This is still on Question 1
-- For the second code commented below;
-- If you want the owner_id to be in short numeric IDs formats
-- You can uncomment the code below from line 34 to 58, then run the code to see the output

-- Identify high-value customers with both funded savings and investment plans
-- Format owner_id as a simulated numeric ID

-- WITH base_data AS (
--     SELECT
--         u.id AS user_uuid,
--         COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name), u.email) AS name,
--         COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
--         COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
--         ROUND(SUM(COALESCE(s.confirmed_amount, 0)) / 100, 2) AS total_deposits
--     FROM users_customuser u
--     JOIN plans_plan p ON u.id = p.owner_id
--     JOIN savings_savingsaccount s ON s.plan_id = p.id
--     WHERE s.confirmed_amount > 0
--     GROUP BY u.id, name
--     HAVING
--         COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) >= 1 AND
--         COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) >= 1
-- )

-- SELECT
--     ROW_NUMBER() OVER (ORDER BY total_deposits DESC) + 1000 AS owner_id,
--     name,
--     savings_count,
--     investment_count,
--     total_deposits
-- FROM base_data
-- ORDER BY total_deposits DESC;
