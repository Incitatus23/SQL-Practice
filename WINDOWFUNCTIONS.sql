----WINDOW FUNCTION NOTES---

---calculate aggregation within subgroup----

----agg() over (partition by subcategory order by subcategory2)-----

----Examples-----

--AVERAGE POINTS BY POSITION BY TEAM---

 SELECT position, mascot, AVG(points) 
OVER (partition by mascot, position) as avg_points
from player JOIN player_stats on player.id = player_stats.id
WHERE season = '2021-2022'
ORDER BY avg_points DESC;

SELECT gamedate, AVG(homemascotscore + awaymascotscore) 
OVER (partition by gamedate) AS avg_goals
FROM game
WHERE DATE_PART('year', gamedate) = 2017 AND DATE_PART('month', gamedate)= 1;


---NO DUPLICATES---
SELECT DISTINCT position, mascot, AVG(points) 
OVER (partition by mascot, position) as avg_points
from player JOIN player_stats on player.id = player_stats.id
WHERE season = '2021-2022'
ORDER BY avg_points DESC;


---FIND PERCENTILE DISTR---
SELECT name, season, points, 
CUME_DIST() OVER (order by points) AS percentile
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY percentile DESC;

SELECT name, season, points, 
CUME_DIST() OVER (partition by season order by points) AS percentile
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY percentile DESC;

----PLACE INTO BUCKETS----

SELECT name, season, points,
NTILE(4) OVER (order by points) AS percentile
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER by points DESC;


SELECT mascot, season, (goalsfor - goalsagainst) AS goal_differential,
NTILE(4) OVER (partition by season order by (goalsfor - goalsagainst) desc) AS d_rank
FROM team_stats
ORDER by d_rank, goal_differential DESC, season;
----ADD CASE---

WITH cte AS (SELECT name, season, points,
NTILE(4) OVER (partition by season order by points) AS percentile
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY points DESC)
SELECT name, season, points,
CASE
    WHEN percentile = 4 THEN 'Elite'
    WHEN percentile = 3 THEN 'Good'
    WHEN percentile = 2 THEN 'Average'
    WHEN percentile = 1 THEN 'Mediocre'
END AS season_type
FROM cte;


WITH diff_rank AS (SELECT mascot, season, (goalsfor - goalsagainst) AS goal_differential,
NTILE(4) OVER (partition by season order by (goalsfor - goalsagainst) desc) AS d_rank
FROM team_stats
ORDER by d_rank, goal_differential DESC, season)
SELECT mascot, season, goal_differential,
CASE
WHEN d_rank = 1 THEN 'Elite'
WHEN d_rank = 2 THEN 'Solid'
WHEN d_rank = 3 THEN 'Mediocre'
WHEN d_rank = 4 THEN 'Trash'
END AS team_type
FROM diff_rank;

----PERCENT RANK-----
SELECT name, season, points, 
PERCENT_RANK() OVER (partition by season order by points) AS percentile
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY percentile DESC;

----RANK-----

SELECT name, season, points, 
RANK() OVER (order by points DESC) AS rank_number
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY rank_number;

SELECT name, season, points, 
RANK() OVER (partition by season order by points DESC) AS rank_number
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY rank_number;

---DENSE RANK (always has consecutive row numbers, even with duplicate)----

SELECT name, season, points, 
DENSE_RANK() OVER (order by points DESC) AS rank_number
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY rank_number;

-----ROW_NUMBER----

SELECT name, season, points, 
ROW_NUMBER() OVER (order by points DESC) AS rank_number
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER BY rank_number;





----FIRST_VALUE-----
SELECT name, season, points, 
FIRST_VALUE(name) OVER (partition by season order by points DESC) AS leading_scorer
FROM player JOIN player_stats ON player.id = player_stats.id;

SELECT name, mascot, points, 
FIRST_VALUE(name) OVER (partition by mascot order by points DESC) AS leading_scorer
FROM player JOIN player_stats ON player.id = player_stats.id;

SELECT name, mascot, points, season,
FIRST_VALUE(name) OVER (partition by mascot, season order by points DESC) AS team_season_leading_scorer
FROM player JOIN player_stats ON player.id = player_stats.id;


----LAST_VALUE_____

SELECT name, mascot, points, season,
LAST_VALUE(name) OVER (partition by mascot, season order by points DESC RANGE 
                       BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS team_season_lowest_scorer
FROM player JOIN player_stats ON player.id = player_stats.id;


SELECT mascot, season, goalsfor,
LAST_VALUE(mascot) OVER (partition by season order by goalsfor DESC RANGE 
                       BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS fewest_goals
FROM team_stats;


----NTH VALUE-----

SELECT mascot, season, goalsfor,
NTH_VALUE(mascot,2) OVER (partition by season order by goalsfor RANGE 
                       BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_fewest_goals
FROM team_stats;


---LAG-----

---This example uses the LAG() function to compare the sales of the current year 
---with the sales of the previous year of each product group

SELECT
	year, 
	amount,
	group_id,
	LAG(amount,1) OVER (
		PARTITION BY group_id
		ORDER BY year
	) previous_year_sales
    
    
----LEAD----

---The following statement uses the LEAD() function to compare the sales of the current
---year with sales of the next year for each product group:

SELECT
	year, 
	amount,
	group_id,
	LEAD(amount,1) OVER (
		PARTITION BY group_id
		ORDER BY year
	) next_year_sales
FROM
	sales;

----MOVING AVERAGE----

---5 GAME MOVING AVERAGE---

 SELECT gamedate, homemascot, awaymascot, (homemascotscore + awaymascotscore) AS total_goals,
       round(AVG(homemascotscore + awaymascotscore)
       OVER(ORDER BY gamedate ROWS BETWEEN 4 PRECEDING AND CURRENT ROW),2) 
       AS avg_goals
       FROM game
       WHERE DATE_PART('year', gamedate) = 2017;
---30 game moving average----
 SELECT gamedate, homemascot, awaymascot, (homemascotscore + awaymascotscore) AS total_goals,
       round(AVG(homemascotscore + awaymascotscore)
       OVER(ORDER BY gamedate ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2) 
       AS avg_goals
       FROM game
       WHERE DATE_PART('year', gamedate) = 2017;
       
       
---Testing---

 SELECT gamedate, homemascot, awaymascot, (homemascotscore + awaymascotscore) AS total_goals,
       round(AVG(homemascotscore + awaymascotscore)
       OVER(ORDER BY gamedate ROWS BETWEEN 4 PRECEDING AND CURRENT ROW),2) 
       AS avg_goals
       FROM game
       WHERE DATE_PART('year', gamedate) = 2017
       LIMIT 10;

----MEDIAN & MODE----

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY points) AS median, MODE() WITHIN GROUP
(ORDER BY points) AS mode
FROM player_stats;

SELECT *
FROM player_stats
ORDER BY points DESC;