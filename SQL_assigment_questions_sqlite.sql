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

-- Question 11: Monthly average number of users per charger

-- Question 12: Top 3 users per charger (for each charger, number of sessions)




-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
