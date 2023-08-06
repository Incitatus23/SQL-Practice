---all FKs should be on UPDATE CASCADE---


/* Queries */

---List the name, id, season, and award for each award winner. order by season, then award---


SELECT name, player.id, season, awardname
FROM player JOIN player_awards ON player.id = player_awards.playerid
ORDER BY season, awardname;


---List name, id, season, goals, assists, points, plusminus, posiition, mascot, for each player with stats---

SELECT name, season, assists, points, plusminus, position, mascot
FROM player JOIN player_stats ON player.id = player_stats.id
ORDER by season DESC, points DESC;

---Find the sum points, assists, and goals for players with stats. order by points, then goals---

SELECT name, SUM(points) AS total_points, SUM(assists) AS total_assists, SUM (goals) AS total_goals, mascot
FROM player JOIN player_stats ON player.id = player_stats.id
GROUP BY player.id
ORDER by SUM (points) DESC, SUM(goals) DESC;

---Find the sum points, assists, and goals for each team that has players with stats.----

SELECT mascot, season, SUM (points) AS total_points, SUM (assists) AS total_assists, SUM (goals) AS total_goals
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE season = '2021-2022'
GROUP BY player.mascot, season
ORDER BY SUM (points) DESC, SUM(goals) DESC;


---Find the differentials for each statistical category for all teams---

SELECT mascot, season
FROM team_stats
WHERE goalsfor > goalsagainst;


SELECT mascot, season, (goalsfor - goalsagainst) AS goaldifferential
FROM team_stats
ORDER BY goaldifferential DESC;

SELECT mascot, season, (hitsfor - hitsagainst) AS hitsdifferential
FROM team_stats
ORDER BY hitsdifferential DESC;

SELECT mascot, season, (faceoffwinsfor - faceoffwinsagainst) AS faceoffdifferential
FROM team_stats
ORDER BY faceoffdifferential DESC;

SELECT mascot, season, (penaltyminutesfor - penaltyminutesagainst) AS penaltydifferential
FROM team_stats
ORDER BY penaltydifferential DESC;

---SELECT all the teams with positive differentials for ALL statistical categories
(SELECT mascot, season
FROM team_stats
WHERE goalsfor > goalsagainst)
INTERSECT
(SELECT mascot, season
FROM team_stats
WHERE hitsfor > hitsagainst)
INTERSECT
(SELECT mascot, season
FROM team_stats
WHERE faceoffwinsfor > faceoffwinsagainst)
INTERSECT
(SELECT mascot, season
FROM team_stats
WHERE penaltyminutesfor > penaltyminutesagainst);

SELECT mascot, season
FROM team_stats
WHERE goalsfor > goalsagainst AND hitsfor > hitsagainst AND  faceoffwinsfor > faceoffwinsagainst
AND  penaltyminutesfor > penaltyminutesagainst;
-------LABEL WINNER FOR GAME TABLE-----
SELECT *,
    CASE
        WHEN homemascotscore > awaymascotscore THEN 'W'
        WHEN homemascotscore < awaymascotscore THEN 'L'
        WHEN homemascotscore = awaymascotscore THEN 'T'
     END AS homemascotresult
FROM game;

----SCORING LABEL FOR GAME TABLE----
SELECT *,
    CASE
        WHEN (homemascotscore + awaymascotscore) > 0 AND (homemascotscore + awaymascotscore) <= 2  THEN  'Very Low Scoring'
    END AS scoring_type
 FROM game;
        
         
---FIND GAMES WITH ONE GOAL SCORED----
SELECT id, homemascotscore, awaymascotscore
FROM game
WHERE (homemascotscore + awaymascotscore = 1);

---FIND ONE GOAL GAMES---

SELECT *
FROM game
WHERE (homemascotscore - awaymascotscore =1) OR (homemascotscore - awaymascotscore = -1);

---FIND 10 GOAL GAMES----
SELECT *
FROM game
WHERE (homemascotscore - awaymascotscore = 10) OR (homemascotscore - awaymascotscore = 10);

---Pulling Data From Two Tables, No Join -----

SELECT name, player.id, player.mascot, years, amount, aav, expires
FROM contract, player
WHERE player.id = contract.playerid AND player.mascot = contract.mascot;

SELECT name, mascot, player.id, season, awardname
FROM player, player_awards
WHERE player.id = player_awards.playerid
ORDER BY season;

SELECT player.id, name AS winner, awardname, season
FROM player, player_awards
WHERE player.id = player_awards.playerid;

---Comparing Data in Same Table ---
SELECT T.playerid, T.aav
FROM contract AS T, contract AS S
WHERE T.aav > S.aav AND S.mascot = 'Maple Leafs';


SELECT *
FROM team
WHERE captain IS NULL;

(SELECT id, name, draftyear
FROM player
WHERE position = 'LW')
UNION
(SELECT id, name, draftyear
FROM player
WHERE position = 'RW');

(SELECT id, name, mascot
FROM player
WHERE mascot ='Penguins')
UNION
(SELECT id, name, mascot
FROM player
WHERE mascot = 'Capitals');

(SELECT *
FROM game
WHERE homemascotscore > 5)
INTERSECT
(SELECT *
FROM game
WHERE awaymascotscore > 8);

(SELECT *
FROM game
WHERE homemascotscore > 5)
EXCEPT
(SELECT *
FROM game
WHERE homemascotscore > awaymascotscore);

----AGGREGATE------
SELECT AVG(goals)
FROM player_stats
WHERE season = '2020-2021';

SELECT ROUND (AVG (goals), 0), player.id, name
FROM player, player_stats
WHERE player.id = player_stats.id 
GROUP BY player.id
ORDER BY AVG(goals) DESC
LIMIT 5;

SELECT ROUND (AVG(points), 0), player.id, name
FROM player JOIN player_stats ON player.id = player_stats.id
GROUP BY player.id
HAVING AVG(points) > 60
ORDER BY AVG(points) DESC;

 
                
                
----WITH------

---PPG RANKED FOR ALL PLAYERS----
WITH ppg AS (SELECT CAST (SUM (points) AS float) / SUM (gamesplayed),id
            FROM player_stats
            GROUP BY id)
SELECT ppg, name
FROM ppg JOIN player ON ppg.id = player.id
ORDER BY ppg DESC;
---TOP 10 PPG RANKED FOR ALL PLAYERS----
WITH ppg AS (SELECT CAST (SUM (points) AS float) / SUM (gamesplayed),id
            FROM player_stats
            GROUP BY id)
SELECT ppg, name
FROM ppg JOIN player ON ppg.id = player.id
ORDER BY ppg DESC
LIMIT 10;

WITH pergame AS (SELECT CAST (SUM (points) AS float) / SUM (gamesplayed) AS ppg,id
            FROM player_stats
            GROUP BY id)
SELECT ppg, name
FROM pergame JOIN player ON pergame.id = player.id
ORDER BY ppg DESC
LIMIT 10;
---MOST GOALS FOR ALL PLAYERS-----
WITH goal_amount AS (SELECT SUM (goals) AS total_goals, id
                     FROM player_stats
                     GROUP BY id)
SELECT total_goals, name
FROM goal_amount JOIN player ON goal_amount.id = player.id
ORDER BY total_goals DESC;
---MOST GOALS SINCE 2016-2017 SEASON-----
WITH goal_amount AS (SELECT SUM (goals) AS total_goals, id
                     FROM player_stats
                     WHERE season NOT IN ('2015-2016')
                     GROUP BY id)
SELECT total_goals, name
FROM goal_amount JOIN player ON goal_amount.id = player.id
ORDER BY total_goals DESC;

WITH assist_amount AS (SELECT SUM (assists) AS total_assists, id
                      FROM player_stats
                      GROUP BY id)
SELECT total_assists, name
FROM assist_amount JOIN player ON assist_amount.id = player.id
ORDER BY total_assists DESC;

WITH assist_amount AS (SELECT SUM (assists) AS total_assists, id
                      FROM player_stats
                      GROUP BY id)
SELECT total_assists, name
FROM assist_amount JOIN player ON assist_amount.id = player.id
ORDER BY total_assists DESC
LIMIT 10;
---TOP 10 IN POINTS SINCE 2016-2017---
WITH points_amount AS (SELECT SUM (points) AS total_points, id
                      FROM player_stats
                      WHERE season NOT IN ('2014-2015', '2015-2016')
                      GROUP BY id)
SELECT total_points, name
FROM points_amount JOIN player ON points_amount.id = player.id
ORDER BY total_points DESC
LIMIT 10;

---SELECT ALL PLAYERS WITH HIGHER THAN AVERAGE POINTS PER SEASON----
SELECT AVG(points), player.id
FROM player JOIN player_stats ON player.id = player_stats.id
GROUP BY player.id
HAVING AVG (points) >= (SELECT AVG (points)
                       FROM player_stats)
ORDER BY AVG(points) DESC;

---SAME AS ABOVE, BUT INCLUDE NAME
WITH avg_points_table AS (SELECT AVG(points) AS avg_points, player.id
FROM player JOIN player_stats ON player.id = player_stats.id
GROUP BY player.id
HAVING AVG (points) >= (SELECT AVG (points)
                       FROM player_stats))
SELECT name, avg_points
FROM player JOIN avg_points_table ON  player.id = avg_points_table.id
ORDER BY avg_points DESC;


WITH high_home AS (SELECT MAX(homemascotscore), homemascot
FROM game
GROUP BY (homemascot)
ORDER BY MAX (homemascotscore) DESC),
high_away AS (SELECT MAX(awaymascotscore), awaymascot
FROM game
GROUP BY (awaymascot)
ORDER BY MAX (awaymascotscore) DESC)
SELECT *
FROM high_away, high_home
WHERE high_away.awaymascot = high_home.homemascot



SELECT COUNT (DISTINCT ID)
FROM game
WHERE homemascotscore > awaymascotscore;

SELECT COUNT (DISTINCT ID)
FROM game
WHERE awaymascotscore > homemascotscore;

SELECT DISTINCT (homemascot, awaymascot)
FROM (SELECT *
FROM game
WHERE awaymascotscore > 5 AND homemascotscore > 5) AS foo

SELECT mascot, season,
    CASE
        WHEN (goalsfor - goalsagainst) > 0 THEN 'Positive Differential'
        WHEN (goalsfor - goalsagainst) < 0 THEN 'Negative Differential'
        WHEN (goalsfor - goalsagainst) = 0 THEN 'Neutral'
     END AS goal_differential
FROM team_stats;

SELECT COUNT (mascot)
FROM (SELECT mascot, season,
    CASE
        WHEN (goalsfor - goalsagainst) > 0 THEN 'Positive Differential'
        WHEN (goalsfor - goalsagainst) < 0 THEN 'Negative Differential'
        WHEN (goalsfor - goalsagainst) = 0 THEN 'Neutral'
     END AS goal_differential
FROM team_stats) AS diff_countt
WHERE goal_differential = 'Negative Differential';



SELECT mascot, season
FROM (SELECT mascot, season,
    CASE
        WHEN (goalsfor - goalsagainst) > 0 THEN 'Positive Differential'
        WHEN (goalsfor - goalsagainst) < 0 THEN 'Negative Differential'
        WHEN (goalsfor - goalsagainst) = 0 THEN 'Neutral'
     END AS goal_differential
FROM team_stats) AS diff_countt
WHERE goal_differential = 'Neutral';


SELECT *
FROM team JOIN team_stats ON team.mascot = team_stats.mascot;

----VIEWS----
CREATE VIEW player_stats_2021 AS
SELECT player.id, name, goals, assists, points, plusminus, pim, gamesplayed
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE season = '2020-2021';

CREATE VIEW player_stats_2022 AS
SELECT player.id, name, goals, assists, points, plusminus, pim, gamesplayed
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE season = '2021-2022';

CREATE VIEW contract_info AS
SELECT name, contract.mascot, position, years, amount, aav, expires
FROM contract JOIN player ON contract.mascot = player.mascot;

CREATE VIEW season_award_info AS
SELECT player_stats.season, awardname, name, points, goals, assists
FROM player_awards JOIN player_stats ON player_stats.id = player_awards.playerid AND
player_stats.season = player_awards.season JOIN player ON player.id = player_stats.id
WHERE awardname NOT IN ('Conn Symthe TRophy', 'Conn Symthe Trophy');

CREATE VIEW coaches_captains AS
SELECT city, mascot, coach, captain
FROM team;

CREATE VIEW top_ten_points AS
WITH points_amount AS (SELECT SUM (points) AS total_points, id
                      FROM player_stats
                      WHERE season NOT IN ('2014-2015', '2015-2016')
                      GROUP BY id)
SELECT total_points, name
FROM points_amount JOIN player ON points_amount.id = player.id
ORDER BY total_points DESC
LIMIT 10;

---FUNCTIONS & PROCEDURES-----

CREATE OR REPLACE FUNCTION player_ppg(namee VARCHAR (30),
                                      seasonn VARCHAR (15))
RETURNS FLOAT
LANGUAGE plpgsql
AS
$$
DECLARE
p_ppg FLOAT;
BEGIN
SELECT ROUND(CAST ( (points) AS NUMERIC) / (gamesplayed), 2) INTO p_ppg
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE player.name = namee AND player_stats.season = seasonn;
RETURN p_ppg;
END;
$$;


CREATE OR REPLACE FUNCTION cap_hit (namee VARCHAR (30))
RETURNS NUMERIC
LANGUAGE plpgsql
AS
$$
DECLARE
cap_hit_amount NUMERIC;
BEGIN
SELECT aav INTO cap_hit_amount
FROM contract JOIN player ON contract.playerid = player.id
WHERE player.name = namee;
RETURN cap_hit_amount;
END;
$$;



SELECT cap_hit('Connor McDavid');

SELECT player_ppg('Sidney Crosby', '2021-2022');


SELECT name, season
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE player_ppg(name, season) >= 1.1;

SELECT name, season
FROM player JOIN player_stats ON player.id = player_stats.id
WHERE player_ppg(name, season) < 1.0;


DROP FUNCTION season_awards;
CREATE OR REPLACE FUNCTION season_awards(season2 VARCHAR (15))
RETURNS TABLE (seasonn VARCHAR (15),
              namee VARCHAR (30),
              awardnamee VARCHAR (25))
LANGUAGE plpgsql
AS
$$

BEGIN
RETURN QUERY
SELECT player_awards.season, name, awardname
FROM player_awards JOIN player ON player_awards.playerid = player.id
WHERE player_awards.season = season2;
END;
$$;

CREATE OR REPLACE FUNCTION contract_info (name2 VARCHAR (30))
RETURNS TABLE (namee VARCHAR (30),
              mascot VARCHAR (25),
              yearss INTEGER,
              amountt NUMERIC (11,2),
              aavv NUMERIC (10,2),
              expiress INTEGER)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
SELECT name, contract.mascot, years, amount, aav, expires
FROM contract JOIN player ON contract.playerid = player.id
WHERE player.name = name2;
END;
$$;

CREATE OR REPLACE FUNCTION game_score (homemascot2 VARCHAR (25),
                                      awaymascot2 VARCHAR (25),
                                      gamedate2 DATE)
RETURNS TABLE (homemascott VARCHAR (25),
               homemascotscoree INTEGER,
               awaymascott VARCHAR (25),
              awaymascotscoree INTEGER)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
SELECT homemascot, homemascotscore, awaymascot, awaymascotscore
FROM game
WHERE game.gamedate = gamedate2 AND game.homemascot = homemascot2
AND game.awaymascot = awaymascot2;
END;
$$;

SELECT game_score('Maple Leafs', 'Red Wings', '2017-04-01');






SELECT contract_info('Sidney Crosby');


SELECT season_awards('2021-2022')

SELECT *
FROM player_awards
WHERE season = '2021-2022';

CREATE OR REPLACE PROCEDURE addAward(playerid VARCHAR (4), 
                                     awardname VARCHAR (25), 
                                     season VARCHAR (15))
LANGUAGE plpgsql
AS
$$
BEGIN
INSERT INTO player_awards 
VALUES (playerid, awardname, season);
END;
$$;

CALL addAward('129', 'Hart Trophy', '2015-2016');

SELECT *
FROM player_awards;


CREATE OR REPLACE PROCEDURE addPlayerStats(id INTEGER,
                                          season VARCHAR (15),
                                          goals INTEGER,
                                          assists INTEGER,
                                          points INTEGER,
                                          plusminus INTEGER,
                                          pim INTEGER,
                                          gamesplayed INTEGER)
LANGUAGE plpgsql
AS 
$$
BEGIN
INSERT INTO player_stats
VALUES (id, season, goals, assists, points, plusminus, pim, gamesplayed);
END;
$$;

CALL addPlayerStats('129', '2015-2016', 46, 60, 106, 17, 30, 82);

Select *
FROM player_stats
WHERE id = '129';




------TRIGGERS------

CREATE OR REPLACE FUNCTION changeMascot()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    mascott VARCHAR (25);
BEGIN
SELECT mascot INTO mascott
FROM player
WHERE player.id = NEW.id;

UPDATE contract
SET mascot = player.mascot
FROM player
WHERE player.id = contract.playerid;
RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER updateMascotTrigger
AFTER UPDATE ON player
FOR EACH ROW
EXECUTE PROCEDURE changeMascot();


UPDATE player_stats
SET
goals = 55,
assists = 55,
points = 110
WHERE id = '100';



SELECT *
FROM contract;


SELECT *
FROM contract;

----INDEX----