# 📘 Data Analytics SQL Assessment – README

This repository contains SQL solutions to the SQL Proficiency Assessment involving user and financial transaction data. Each of my solutions addresses a unique business use case across multiple tables and focuses on performance, readability, and correctness.

**Note:** `For the solution to questions 1, 3 and 4, I gave two formats in the code, with the first code which showed the owner_id, plan_id and customer_id in UUID formats while the second code which is commented below the first code gives the owner_id, plan_id and customer_id in the form of short numeric IDs.`

**Note:** `Although the actual IDs in the database are UUIDs (char(32)) and I ensured the outputs for the first approach were all displayed in UUIDs also, but in the second approach which is only applicable in questions 1, 3 and 4, simulated numeric IDs (like 1001, 305) are shown in the output using ROW_NUMBER() for readability and to match the expected sample format in the assessment brief.`

## Question 1: High-Value Customers with Multiple Products

**Goal:** Identify customers who have at least one funded **savings** plan and at least one funded **investment** plan, sorted by total deposits.

**Approach 1:**
- I joined `users_customuser`, `plans_plan`, and `savings_savingsaccount`.

- I then proceeded to filtering to only include records with confirmed_amount > 0.

- I then used conditional aggregation (CASE WHEN) to count the number of each plan type.

- Afterwards, I summed up all confirmed deposits, convert from **kobo to naira**.

- I used the HAVING clause to ensure each user has both plan types.

**Approach 2:**
- I joined `users_customuser`, `plans_plan`, and `savings_savingsaccount`.

- Then, I filtered for `confirmed_amount > 0` to include only **funded** transactions.

- Also, I used conditional aggregation to count distinct `savings` (`is_regular_savings = 1`) and `investment` (`is_a_fund = 1`) plans.

- Most importantly, aggregated total deposits and converted from **kobo to naira**.

- Finally I used `ROW_NUMBER()` to simulate expected `owner_id` formatting.

**Challenges:**
- The schema stores both savings and investment in one table, so I used flags (is_regular_savings and is_a_fund) to distinguish them

- Ensuring we only include "funded" plans required joining the savings transactions table and filtering for positive confirmed_amount.

- In order to display consistency, after initially seeing my output displaying the name column null, as a result of the name column in the users_customuser table being `nullable (name varchar(100) DEFAULT NULL)`, in order to rectify the final output from being null, I used the COALESCE and the CONCAT function to get the desired output.

- I avoided counting the same plan twice using DISTINCT on p.id

- Although the real `owner_id`s are UUIDs which I also showed in the outpuut of Approach 1, but in Approach 2, sample outputs used numeric IDs. I handled this using simulated IDs with `ROW_NUMBER() + 1000`.


## Question 2: Transaction Frequency Analysis

**Goal:** Categorize users by average number of monthly transactions into:
- High Frequency (≥10/month)
- Medium Frequency (3–9/month)
- Low Frequency (≤2/month)

**Approach:**
- I used a 3-step CTE pipeline:

`customer_tx_counts: Calculates total transactions and months of activity per customer using TIMESTAMPDIFF. I used GREATEST(.., 1) to ensure I never divide by zero.`

`monthly_avg: Derives the average monthly transaction count per customer.`

`categorized: Assigns each customer into a frequency category using a CASE expression.`

- In the final step, I counted the number of customers in each category and compute their average monthly transaction frequency.

- I counted total transactions per user using `savings_savingsaccount`.

- I calculated their activity span in **months** using `TIMESTAMPDIFF`.

- Also, I prevented divide-by-zero errors using `GREATEST(.., 1)`.

- Then, I grouped customers into frequency bands using a `CASE` expression.

- Finally, I calculated average frequency for each category.

**Challenges:**
- I discovered that users with only one month of activity needed correction to avoid a 0-month duration.

- Also, made sure that accurate monthly classification required tight CASE condition ranges.

- I carefully handled short time spans, for example, if a user transacts within a single month, TIMESTAMPDIFF might return 0. I protected against divide-by-zero using GREATEST(.., 1).

- I tried avoiding misclassification, I ensured that this was possible by making sure that the CASE expression needed precise boundaries to prevent overlapping or gaps.

- Finally, I worked on it's efficiency. This I did using of CTEs which tremendously helps to keep logic modular and clear without subqueries in the final SELECT.



## Question 3: Account Inactivity Alert

**Goal:** Find active accounts (savings/investments) with no deposit activity in the last **365 days**.

**Approach:**

- Most importantly, I needed to flag active accounts (savings or investment) with no inflows in over a year:

- First, I created a CTE latest_inflows that records the most recent deposit (confirmed_amount > 0) per plan.

- Then I joined this data with plans_plan and filtered for plans that:

`Are either savings or investment plans.`

`Are not archived or deleted (is_deleted = 0, is_archived = 0).`

`Have either no inflow (last_transaction_date IS NULL) or the last one occurred more than 365 days ago.`

- I then labeled each plan type and calculated the number of inactivity days using DATEDIFF.

- I isolated latest transaction date for each plan from `savings_savingsaccount` where `confirmed_amount > 0`.

- Then, I joined with `plans_plan` and filtered for `is_regular_savings = 1` or `is_a_fund = 1`.

- Also, I ensured only **active** plans (not deleted/archived) were included.

- Then, I calculated inactivity days using `DATEDIFF`.

- Conclusively, I used `ROW_NUMBER()` to simulate readable `owner_id` and `plan_id`.

**Challenges:**
- Some plans had no deposit history, so I handled `NULL` `last_transaction_date` properly.

- Some plans may have never had any inflows, so I had to allow for NULL dates in the join and filter.

- The plans_plan table contains many plan types; I filtered only on the specified two.

- As with Q1, UUID IDs were mapped to numeric format using `ROW_NUMBER()` for visual alignment.

- Accurate inactivity logic required interpreting "active" using logical fields, since no single is_active column exists.

## Question 4: Customer Lifetime Value (CLV) Estimation

**Goal:** Estimate each customer’s CLV using:  
`CLV = (transactions per month) × 12 × 0.1% of average transaction value`

**Approach:**

- This query estimates CLV using the simplified formula:

`CLV = (transactions per month) * 12 * avg_profit_per_transaction`

- The steps I employed includes:

- customer_activity CTE:

`Joins users_customuser and savings_savingsaccount to aggregate transaction counts and values per user.`

`Only includes inflow transactions with confirmed_amount > 0.`

`Converts total amount from kobo to naira.`

- clv_calculation CTE:

`Computes tenure using TIMESTAMPDIFF (with GREATEST(..., 1) to prevent division by zero).`

`Calculates avg_profit_per_transaction as 0.001 * avg_transaction_value`

`Computes the final estimated_clv and rounds it to 2 decimal places.`

- I joined `users_customuser` and `savings_savingsaccount` to gather user inflows.

- Then I calculated:
  - `tenure_months` using `TIMESTAMPDIFF` between signup date and today.
  - `total_transactions` and `total_transaction_value` (converted to naira).
  - Average profit per transaction as `0.001 * value`.
  - CLV using the provided formula.

- In order to get the expected outcome, I ensured that the output was formatted with numeric-style `customer_id` using `ROW_NUMBER()`.

**Challenges:**
- I avoided divide-by-zero by handling edge cases with tenure less than one month because some users might have less than a month’s tenure.

- I ensured the formula reflects per-month extrapolation of revenue (via * 12).

- Because the dataset might include outliers or test accounts, they can be excluded in production using appropriate flags (e.g is_active column).

- I avoided division errors when `total_transactions = 0`.

- Finally I applied fallback logic for null `name` fields using first/last name or email.