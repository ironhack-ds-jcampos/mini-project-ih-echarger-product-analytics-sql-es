-- LEVEL 1

-- Question 1: Number of users with sessions
SELECT
COUNT(DISTINCT u.id) FROM users u
INNER JOIN sessions s ON s.user_id = u.id;

-- Question 2: Number of chargers used by user with id 1
SELECT COUNT(DISTINCT c.id)
FROM chargers c
INNER JOIN sessions s ON s.charger_id = c.id AND s.user_id = 1;



-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):
SELECT c."type", COUNT(DISTINCT s.id) AS 'count'
FROM sessions s
INNER JOIN chargers c ON s.charger_id = c.id
GROUP BY c."type";

-- Question 4: Chargers being used by more than one user
SELECT *
FROM chargers c
WHERE c.id IN (
	SELECT s.charger_id
	FROM sessions s
	GROUP BY s.charger_id
	HAVING COUNT(s.charger_id) > 1
);

-- Question 5: Average session time per charger
SELECT c.id, AVG(ROUND(JULIANDAY(s.start_time), JULIANDAY(s.end_time) * 86400)) AS 'average time'
FROM chargers c
INNER JOIN sessions s ON s.charger_id = c.id
GROUP BY c.id;



-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)
SELECT CONCAT(u.name, ' ', u.surname) AS 'Full username'
FROM users u
INNER JOIN (
	SELECT STRFTIME('%d', s.start_time) as 'day', s.user_id, COUNT(DISTINCT c.id) AS 'count'
	FROM sessions s
	INNER JOIN chargers c ON s.charger_id = c.id
	GROUP BY 1,2
) sess ON sess.count > 1 AND sess.user_id = u.id;

-- Question 7: Top 3 chargers with longer sessions
SELECT *
FROM chargers c2
WHERE c2.id IN (
	SELECT DISTINCT c.id
	FROM chargers c
	INNER JOIN sessions s ON s.charger_id = c.id
	ORDER BY ROUND(JULIANDAY(s.start_time), JULIANDAY(s.end_time) * 86400) DESC
	LIMIT 3
);

-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)
SELECT AVG(co.count) AS 'average'
FROM (
	SELECT COUNT(DISTINCT u.id) AS 'count'
	FROM users u
	INNER JOIN sessions s ON s.user_id = u.id
	INNER JOIN chargers c ON c.id = s.charger_id
	GROUP BY c."type"
) co;

-- Question 9: Top 3 users with more chargers being used
SELECT *
FROM users u2
INNER JOIN (
	SELECT u.id AS 'user_id', COUNT(DISTINCT s.charger_id) AS 'chargers_amount'
	FROM users u
	INNER JOIN sessions s ON s.user_id = u.id
	GROUP BY u.id
	ORDER BY 2 DESC
	LIMIT 3
) uc ON uc.user_id = u2.id;



-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both
WITH charger_usage AS (
    SELECT user_id, MIN(type) AS min_type, MAX(type) AS max_type
    FROM sessions
    JOIN chargers ON sessions.charger_id = chargers.id
    GROUP BY user_id
)
SELECT 
    (SELECT COUNT(*) FROM charger_usage WHERE min_type = 'AC' AND max_type = 'AC') AS ac_only_users,
    (SELECT COUNT(*) FROM charger_usage WHERE min_type = 'DC' AND max_type = 'DC') AS dc_only_users,
    (SELECT COUNT(*) FROM charger_usage WHERE min_type != max_type) AS both_ac_dc_users;


-- Question 11: Monthly average number of users per charger
WITH monthly_usage AS (
    SELECT 
        s.charger_id,
        strftime('%Y-%m', s.start_time) AS month,
        COUNT(DISTINCT user_id) AS unique_users
    FROM sessions s
    GROUP BY charger_id, month
),
av AS (
    SELECT 
        mu.charger_id,
        AVG(mu.unique_users) AS avg_users
    FROM monthly_usage mu
    GROUP BY charger_id
)
SELECT 
    AVG(avg_users) AS 'average'
FROM av;

-- Question 12: Top 3 users per charger (for each charger, number of sessions)
WITH user_sessions AS (
    SELECT
        s.charger_id,
        s.user_id,
        COUNT(*) AS session_count
    FROM sessions s
    GROUP BY s.charger_id, s.user_id
),
ranked_users AS (
    SELECT
        us.charger_id,
        us.user_id,
        us.session_count,
        RANK() OVER (PARTITION BY us.charger_id ORDER BY us.session_count DESC) AS rank
    FROM user_sessions us
)
SELECT
    ru.charger_id,
    ru.user_id,
    ru.session_count
FROM ranked_users ru
WHERE rank <= 3
ORDER BY charger_id, rank
LIMIT 3;



-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
WITH session_durations AS (
    SELECT 
        s.user_id,
        strftime('%Y-%m', start_time) AS month,
        (julianday(s.end_time) - julianday(s.start_time)) * 24 * 60 AS session_duration_minutes
    FROM sessions s
    WHERE s.end_time IS NOT NULL
),
monthly_user_durations AS (
    SELECT 
        sd.user_id,
        sd.month,
        SUM(session_duration_minutes) AS total_duration
    FROM session_durations sd
    GROUP BY user_id, month
),
ranked_users AS (
    SELECT 
        mud.user_id,
        mud.month,
        mud.total_duration,
        RANK() OVER (PARTITION BY month ORDER BY mud.total_duration DESC) AS rank
    FROM monthly_user_durations mud
)
SELECT 
    ru.month,
    ru.user_id,
    ru.total_duration
FROM ranked_users ru
WHERE rank <= 3
ORDER BY month, rank;
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
WITH session_times AS (
    SELECT 
        s.charger_id,
        strftime('%Y-%m', s.start_time) AS month,
        s.start_time
    FROM sessions s
),
lagged_sessions AS (
    SELECT
        st.charger_id,
        st.month,
        st.start_time,
        LAG(st.start_time) OVER (PARTITION BY st.charger_id, month ORDER BY start_time) AS previous_start_time
    FROM session_times st
),
time_differences AS (
    SELECT
        ls.charger_id,
        ls.month,
        (julianday(ls.start_time) - julianday(ls.previous_start_time)) * 24 * 60 AS time_diff_minutes
    FROM lagged_sessions ls
    WHERE ls.previous_start_time IS NOT NULL
)
SELECT
    td.charger_id,
    td.month,
    AVG(td.time_diff_minutes) AS avg_time_between_sessions
FROM time_differences td
GROUP BY td.charger_id, month
ORDER BY td.charger_id, month;
