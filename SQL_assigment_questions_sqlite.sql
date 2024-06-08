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

-- Question 7: Top 3 chargers with longer sessions

-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)

-- Question 9: Top 3 users with more chargers being used




-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both

-- Question 11: Monthly average number of users per charger

-- Question 12: Top 3 users per charger (for each charger, number of sessions)




-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
