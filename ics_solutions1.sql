
 -- RDBMS: SQL Server
 -- Questions
 -- Solution
 -- Output
 -- Explanations/Comments and Notes




--Q1 - Branch Sales Pivot

--Your company, a multinational retail corporation, has been storing sales data 
--from various branches worldwide in separate tables according to the year the sales were made. 
--The current data structure is proving inefficient for business analytics and 
--the management has requested your expertise to streamline the data.

--Write a query to create a pivot table that shows total sales for each branch by year.

--Note: Assume that the sales are represented by the total_sales column and 
--are in USD. Each branch is represented by its unique branch_id.

--For simplicity, consider two years: 2021 and 2022.

--Tables: sales_2021, sales_2022



SELECT COALESCE(s21.branch_id, s22.branch_id) AS branch_id, 
	   s21.total_sales AS total_sales_2021,
	   s22.total_sales AS total_sales_2022
FROM sales_2021 s21
JOIN sales_2022 s22
ON s21.branch_id = s22.branch_id;


--Expected output
--branch_id	total_sales_2021	total_sales_2022
--1	10000	12000
--2	20000	21000
--3	15000	17000







--Q2 - Department Expenses

--As part of the financial management in a large corporation, the CFO wants 
--to review the expenses in all departments for the previous financial year (2022).

--Write a SQL query to calculate the total expenditure for each department 
--in 2022. Additionally, for comparison purposes, return the average expense 
--across all departments in 2022.

--Note: The output should include the department name, the total expense, 
--and the average expense (rounded to 2 decimal places). 
--The data should be sorted in descending order by total expenditure.

--Tables: departments, expenses



WITH total_expenses AS (
    SELECT d.name AS department_name,
           SUM(e.amount) AS total_expense
    FROM departments d
    JOIN expenses e ON e.department_id = d.id
    WHERE YEAR(e.date) = 2022
    GROUP BY d.name
),
average_expense_cte AS (
    SELECT ROUND(CAST(AVG(1.0 * total_expense) AS FLOAT), 2) AS average_expense
    FROM total_expenses
)
SELECT te.department_name,
       te.total_expense,
       ae.average_expense
FROM total_expenses te, average_expense_cte ae
ORDER BY te.total_expense DESC;



-- Output:

--department_name	total_expense	average_expense
--Engineering	4000	3666.67
--Sales	4000	3666.67
--Marketing	3000	3666.67






--Q3 - Above Average Product Prices

--Given a table of transactions and products, write a query to return the product id, 
--product price, and average transaction total value (price*quantity) of each product 
--such that it has a price higher than the average transaction price.

--Notes:

-- Round the values to two decimal places.
-- The average transaction price is defined as the average amount a customer 
-- spends per transaction on a specific product.
-- A transaction can only contain one type of product

--Tables: products, transactions


-- Step 1:
-- Calculate the overall average transaction price for all products
-- Select the average (price * quantity) for all transactions
-- Use 1.0 * to ensure decimal calculations
-- Round the result to 2 decimal places
-- Join the products table to get product prices

-- Step 2:
-- Calculate the total value (price * quantity) for each product in each transaction
-- Select the product_id, product price, and average transaction value for each product
-- Use 1.0 * to ensure decimal calculations
-- Round the product price and average transaction value to 2 decimal places
-- Join the products table to get product prices
-- Group by product_id and price to get distinct product prices

-- Step 3:
-- Select products whose price is higher than the average transaction price
-- Join product transaction totals with the overall average transaction price
-- Join to filter products with a price greater than the average transaction price
-- Order the results by average transaction value in descending order


-- Calculate the overall average transaction price for all products
WITH avg_transaction_price AS (
    SELECT ROUND(CAST(AVG(1.0 * p.price * t.quantity) AS DECIMAL(5, 2)), 2) AS avg_price
    FROM transactions t
    JOIN products p ON t.product_id = p.id
),
-- Calculate the total value (price * quantity) for each product in each transaction
product_transaction_totals AS (
    SELECT t.product_id,
           ROUND(p.price, 2) AS product_price,
           ROUND(CAST(AVG(1.0 * p.price * t.quantity) AS DECIMAL(5, 2)), 2) AS avg_transaction_value
    FROM transactions t
    JOIN products p ON t.product_id = p.id
    GROUP BY t.product_id, p.price
)
SELECT atp.avg_price AS avg_price,
       ptt.product_id,
       ptt.product_price
FROM product_transaction_totals ptt
JOIN avg_transaction_price atp
ON ptt.product_price > atp.avg_price
ORDER BY ptt.avg_transaction_value DESC;


-- Output:

--avg_price	product_id	product_price
--161.90	3	175.47
--161.90	4	172.00
--161.90	7	182.00



--Explanation:
--Calculate the Overall Average Transaction Price:

--The CTE avg_transaction_price calculates the average transaction price by 
--multiplying the product price by the quantity for each transaction, ensuring 
--decimal calculations using 1.0 *, and rounding the result to 2 decimal places.
--Calculate the Average Transaction Value for Each Product:

--The CTE product_transaction_totals calculates the average transaction value 
--for each product by multiplying the product price by the quantity for each 
--transaction. The result is grouped by product_id and price, and both the 
--product price and average transaction value are rounded to 2 decimal places.
--Filter Products with Higher Than Average Transaction Prices:

--The main query joins product_transaction_totals with avg_transaction_price to 
--filter products whose price is greater than the overall average transaction price. 
--The result is ordered by the average transaction value in descending order.





--Q4 - 7 Day Streak

--Given a table with event logs, find the percentage of users that had 
--at least one seven-day streak of visiting the same URL.

--Note: Round the results to 2 decimal places. 
--For example, if the result is 35.67% return 0.35.
 
--Table: events



WITH consecutive_visits AS (
    SELECT 
        user_id,
        url,
        created_at,
        LAG(created_at) OVER (PARTITION BY user_id, url ORDER BY created_at) AS prev_created_at
    FROM events
)
,streaks AS (
    SELECT 
        user_id,
        url,
        created_at,
        prev_created_at,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY user_id, url ORDER BY created_at), created_at) AS streak_group
    FROM consecutive_visits
),
streak_counts AS (
    SELECT 
        user_id,
        url,
        COUNT(*) AS streak_length
    FROM streaks
    GROUP BY user_id, url, streak_group
    HAVING COUNT(*) >= 7
),
users_with_streaks AS (
    SELECT DISTINCT user_id
    FROM streak_counts
),
total_users AS (
    SELECT COUNT(DISTINCT user_id) AS total_users
    FROM events
),
users_with_streaks_count AS (
    SELECT COUNT(*) AS streak_users
    FROM users_with_streaks
)
SELECT 
    ROUND(CAST(streak_users AS DECIMAL(5, 2)) / CAST(total_users AS DECIMAL(5, 2)), 2) AS percent_of_users
FROM 
    total_users,
    users_with_streaks_count;


-- Output:

--percent_of_users
--0.00



--Breakdown of the query:
--1. Consecutive Visits:
--Use the LAG window function to get the previous visit date for each user and URL.

--2. Streaks:
--Calculate a unique streak_group by subtracting the row number from the visit date. This helps group consecutive visits.

--3.Streak Counts:
--Group by user_id, url, and streak_group to count the number of consecutive days in each streak.
--Filter for streaks of at least seven days.

--4. Users with Streaks:
--Select distinct users who have at least one seven-day streak.

--5. Total Users and Users with Streaks Count:
--Count the total number of distinct users and the number of users with a streak.

--6. Calculate Percentage:
--Calculate the percentage of users with a seven-day streak and round the result to two decimal places.





--Q5 -  Friend Request Acceptance Rate

--A social media company re-designed its UI to include notifications to 
--users when they receive friend requests.

--Evaluate if this change increased the friend request acceptance rate. 
--Find the acceptance rate for friend requests sent in the four weeks prior 
--to (and including) July 2nd, 2022.

--Note: The acceptance rate is the percentage of sent requests that were accepted.*

--Assume that nobody sends or accepts the same request twice. We will consider 
--two friend requests to be duplicates when their sender and receiver are the same.

--Table: friend_requests, requests_accepted


WITH sent_requests AS (
    -- Get distinct requests sent in the specified time period
    SELECT DISTINCT requester_id, receiver_id
    FROM friend_requests
    WHERE sent_at >= DATEADD(WEEK, -4, '2022-07-02') -- 4 weeks before July 2nd
      AND sent_at < '2022-07-03'
)
, accepted_requests AS (
    -- Get distinct accepted requests
    SELECT DISTINCT requester_id, accepter_id
    FROM requests_accepted
)
, request_counts AS (
    -- Count total sent and accepted requests
    SELECT
        COUNT(*) AS total_sent,
        SUM(CASE WHEN ar.requester_id IS NOT NULL THEN 1 ELSE 0 END) AS total_accepted
    FROM sent_requests sr
    LEFT JOIN accepted_requests ar
        ON sr.requester_id = ar.requester_id
        AND sr.receiver_id = ar.accepter_id
)
SELECT 
    ROUND(CAST(total_accepted AS FLOAT) / COALESCE(total_sent, 0), 2) AS acceptance_rate
FROM request_counts;


-- Output:

--acceptance_rate
--0.5




--Breakdown of the query:

--1. The first CTE, sent_requests, filters friend requests for the specified 4-week period. 
--   - DATEADD(WEEK, -4, '2022-07-02') calculates the start date (4 weeks before July 2nd).
--   - < '2022-07-03' ensures all of July 2nd is included without time component issues.
--   - DISTINCT is used to eliminate any duplicate requests.

--2. The accepted_requests CTE gets all distinct accepted requests, regardless of when they were accepted.

--3. The request_counts CTE joins sent and accepted requests to calculate totals:
--   - It counts all sent requests.
--   - It uses a CASE statement within SUM to count accepted requests.
--   - The LEFT JOIN ensures all sent requests are counted, even if not accepted.

--The ON clause specifies the conditions for matching rows 
--between the two tables:

--(a). sr.requester_id = ar.requester_id: 
--This ensures that we're matching the person who sent the request 
--in the sent_requests table with the same person in the accepted_requests table.

--(b). sr.receiver_id = ar.accepter_id: 
--This matches the person who received the request in the 
--sent_requests table with the person who accepted 
--the request in the accepted_requests table.

--By using AND between these conditions, we're ensuring that both conditions 
--must be true for a match to occur. 

-- This is crucial because:

--It prevents matching a request with an acceptance if only the 
--requester is the same but the receiver/accepter is different.

--It ensures that we're only counting acceptances for the specific 
--requests that were sent, not any other combinations.


--4. The final SELECT statement calculates the acceptance rate:
--   - CAST(total_accepted AS FLOAT) ensures decimal division.
--   - COALESCE(total_sent, 0) prevents division by zero if there were no sent requests.
--   - ROUND(..., 2) rounds the result to two decimal places.









--Q6 - Total Time in Flight

--Let’s say you work in air traffic control. You are given the 
--table below containing information on flights between two cities.

--Write a query to find out how much time, in minutes (rounded down), 
--each plane spent in the air each day.

--Note: Both cities are in the same time zone, so you do not need to 
--worry about converting time zones.
--Please give calendar_day in the format YYYY-MM-DD

--Table: flights



-- First, create a CTE to handle flights that span multiple days
WITH flight_segments AS (
    SELECT 
        id,
        plane_id,
        CAST(flight_start AS DATE) AS start_day,
        CAST(flight_end AS DATE) AS end_day,
        CASE 
            WHEN CAST(flight_start AS DATE) = CAST(flight_end AS DATE) 
                THEN DATEDIFF(MINUTE, flight_start, flight_end)  -- if flight_start = flight_end, give us the difference
            ELSE 
                DATEDIFF(MINUTE, flight_start, DATEADD(DAY, 1, CAST(flight_start AS DATE))) -- else give us the difference between (next day 0:00) and flight_start
        END AS minutes_first_day,
        CASE 
            WHEN CAST(flight_start AS DATE) = CAST(flight_end AS DATE) 
                THEN 0  -- we are looking for minutes_second_day, flight_start = flight_end, we dont want this, so give us 0
            ELSE 
                DATEDIFF(MINUTE, CAST(flight_end AS DATE), flight_end) -- else give us the difference between flight_end and flight_end 0:00
        END AS minutes_second_day
    FROM flights
)
-- UNION ALL the results to have all flights represented correctly
, all_flight_times AS (
    SELECT 
        plane_id,
        start_day AS calendar_day,
        minutes_first_day AS time_in_min
    FROM flight_segments
    WHERE minutes_first_day > 0
    
    UNION ALL
    
    SELECT 
        plane_id,
        DATEADD(DAY, 1, start_day) AS calendar_day,
        minutes_second_day AS time_in_min
    FROM flight_segments
    WHERE minutes_second_day > 0
)

-- Finally, aggregate the total time for each plane for each day
SELECT 
    plane_id,
    calendar_day,
    SUM(time_in_min) AS total_time_in_min
FROM all_flight_times
GROUP BY plane_id, calendar_day
ORDER BY plane_id, calendar_day;



-- Output:

--plane_id	calendar_day	total_time_in_min
--1	2021-06-10	270
--1	2021-06-11	150
--1	2021-06-12	270
--1	2021-06-13	150
--2	2021-06-10	290
--2	2021-06-11	170
--2	2021-06-12	290
--2	2021-06-13	170
--3	2021-06-10	170
--3	2021-06-11	290



-- Breakdown of the query:

--1. CTE flight_segments:
--This CTE calculates the minutes spent on the starting day (minutes_first_day) 
--and the ending day (minutes_second_day) for each flight. 
--If the flight starts and ends on the same day, minutes_second_day is 0.

-- understanding the case statement

-- minutes_first_day:  (Time spent on the starting day)
--If the flight starts and end on the same day, then give us the difference in minutes
--Else, (the flight does not start and end on the same day)...
-- ADD 1 day to the flight_start date and give us the difference between the beginning
-- of that day and the date time of the previous day


-- For example, (Berlin	to Paris	1	2021-06-12 23:00:00	2021-06-13 00:45:00) - 
-- **this flight does not start and end on the same day
-- minutes_first_day will be 60 minutes, this is the difference between 
--2021-06-13 0:00 and 2021-06-12 23:00


-- minutes_second_day: (Time spent on the ending day)
-- If the flight starts and end on the same day, give us 0,
-- else, give us difference between flight_end and flight end 0:00 
-- to compute the time spent on the second day


--2. CTE all_flight_times:
--This CTE creates two sets of records: one for the starting day and another 
--for the ending day (if the flight spans two days).
-- we use UNION ALL to append the (1) flights having minutes_first_day, and
-- (2) minutes_second_day, since this represents the next day minutes
-- we use DATEADD(DAY, 1, start_day) to increase the day by 1


--3. Final aggregation:
--The final SELECT statement aggregates the total time each plane spent in 
--the air for each day and orders the result by plane ID and calendar day.
--This solution ensures that flights spanning across multiple days 
--are split correctly and the time is aggregated accurately.






--Q7 - Lowest Paid

--Given tables employees, employee_projects, and projects, 
--find the 3 lowest-paid employees that have completed at least 2 projects.

--Note: incomplete projects will have an end date of NULL in the projects table.

--Table: employees, employee_projects, projects 



SELECT TOP 3 
	   COUNT(ep.project_id) AS completed_projects, 
	   ep.employee_id, 
	   e.salary 
FROM employee_projects ep
JOIN employees e
ON e.id = ep.employee_id
LEFT JOIN projects p
ON ep.project_id = p.id
WHERE p.end_date IS NOT NULL
GROUP BY ep.employee_id, e.salary
HAVING COUNT(ep.project_id) >= 2
ORDER BY e.salary;



-- Output:

--completed_projects	employee_id	salary
--3	2	30000
--2	3	40000
--4	1	50000







--Q8 - HR Salary Reporting

--The HR department in your organization wants to calculate employees’ earnings.
--Write a query to report the sum of regular salaries, overtime pay, and total compensations for each role.

--Table: q8_employees 


SELECT job_title, 
	   SUM(salary) AS total_salaries, 
	   SUM(CAST(overtime_hours AS INT) * CAST(overtime_rate AS INT)) as total_overtime_payments,
	   SUM(salary) + SUM(CAST(overtime_hours AS INT) * CAST(overtime_rate AS INT)) AS total_compensation
FROM q8_employees
GROUP BY job_title
ORDER BY total_compensation DESC;


-- Output:

--job_title	total_salaries	total_overtime_payments	total_compensation
--Software Developer	14200	400	14600
--Graphic Designer	10100	540	10640
--Sales Associate	9100	90	9190
--Human Resources	4500	0	4500







--Q9 - Payments Received

--You’re given two tables, payments and users. The payments table holds all 
--payments between users with the payment_state column consisting 
--of either "success" or "failed". 

--How many customers that signed up in January 2020 had a combined 
--(successful) sending and receiving volume greater than $100 in their first 30 days?

--Note: The sender_id and recipient_id both represent the user_id.

--Table: payments, users



-- CTE to get users who signed up in January 2020
WITH jan_users AS (
SELECT id, created_at
FROM users
WHERE DATEPART(MONTH, created_at) = 1
AND DATEPART(YEAR, created_at) = 2020
)
-- CTE to get transactions that occurred within the first 30 days of user's sign-up
, jan_transactions AS (
SELECT (amount_cents / 100) AS amount,
		recipient_id,
		sender_id, 
		u.id AS user_id,
		u.created_at
FROM payments p
JOIN jan_users u
ON p.recipient_id = u.id OR p.sender_id = u.id
WHERE p.payment_state = 'success'
AND p.created_at <= DATEADD(DAY, 30, u.created_at) -- ensures the transaction is within the first 30 days of customer sign up
)
-- CTE to get the combined total transaction of users (sent and received)
, users_cte AS (
SELECT user_id,
	   SUM(CASE WHEN user_id = recipient_id THEN amount ELSE 0 END) +
	   SUM(CASE WHEN user_id = sender_id THEN amount ELSE 0 END) AS combined_total
FROM jan_transactions
GROUP BY user_id
)
-- Final query to count the users above $100
SELECT COUNT(user_id) AS num_customers
FROM users_cte
WHERE combined_total > 100;



--Output:

--num_customers
--1



--Explanation:
-- Using OR in the join condition:
--p.recipient_id = u.id: This condition ensures that we include transactions where the user is the recipient.
--p.sender_id = u.id: This condition ensures that we include transactions where the user is the sender.
--To properly capture all transactions involving the user (either as a sender or recipient), we need to use OR. 
--This ensures that any transaction where the user is either the sender or the recipient is included in the results.







-- Q10 - Flight Records

--Write a query to create a new table, named flight routes, that 
--displays unique pairs of two locations.

--Note: Duplicate pairs from the flights table, such as 
--Dallas to Seattle and Seattle to Dallas, should have one 
--entry in the flight routes table.

--Table: q10_flights 



WITH unique_routes AS (
    -- Select unique pairs of locations, ensuring each pair appears only once
    SELECT 
        CASE 
            WHEN source_location < destination_location 
            THEN source_location 
            ELSE destination_location 
        END AS location1,
        CASE 
            WHEN source_location < destination_location 
            THEN destination_location 
            ELSE source_location 
        END AS location2
    FROM q10_flights
)
SELECT DISTINCT location1, location2
INTO flight_routes
FROM unique_routes
WHERE location1 < location2
ORDER BY location1, location2;

SELECT * FROM flight_routes;


-- Output:

--location1	location2
--Dallas, TX	San Francisco, CA
--Dallas, TX	Seattle, WA
--Los Angeles, CA	San Francisco, CA
--Portland, OR	San Francisco, CA
--San Francisco, CA	Seattle, WA



-- Query breakdown:

--1. We start by creating a Common Table Expression (CTE) named unique_routes.

--2. Inside the CTE, we use CASE statements to ensure that for each pair of locations, 
--the alphabetically smaller location name is always in location1, and the 
--larger one in location2. This handles the requirement to treat pairs like 
--"Dallas to Seattle" and "Seattle to Dallas" as the same route.

--3. We then select DISTINCT pairs from this CTE, further filtering to ensure 
--location1 is always alphabetically smaller than location2. 
--This eliminates any remaining duplicates.

--4. The results are ordered by location1 and then location2 for consistency.

--5. Finally, we create the new flight_routes table with these unique, 
--ordered pairs of locations.







--