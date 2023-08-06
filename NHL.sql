/* Creating Tables & Sequences */

CREATE TABLE team(
Mascot VARCHAR (25),
City VARCHAR(25) NOT NULL,
Captain VARCHAR (30),
Coach VARCHAR (30),
Current_Record VARCHAR (10) DEFAULT '0-0',
CONSTRAINT team_pkey PRIMARY KEY (Mascot));

CREATE SEQUENCE IF NOT EXISTS player_id
INCREMENT BY 1
MINVALUE 100 MAXVALUE 1000
START WITH 100;

UPDATE
    player_stats
SET
    season = LTRIM(RTRIM(season));
    
UPDATE
    team_stats
SET
    season = LTRIM(RTRIM(season));
    
CREATE TABLE player(
ID VARCHAR (4),
Mascot VARCHAR(25),
City VARCHAR (25) NOT NULL,
Name VARCHAR (30) NOT NULL,
DraftYear INTEGER,
DraftRound INTEGER,
DraftPick INTEGER,
Position VARCHAR (5) CONSTRAINT position_check CHECK (position IN 
                   ('C', 'RW', 'LW', 'G', 'D', 'LW/RW','RW/LW', 'C/LW', 'C/RW', 'LW/C', 'RW/C')),
CONSTRAINT player_pkey PRIMARY KEY(ID),
CONSTRAINT player_fkey1 FOREIGN KEY (Mascot) REFERENCES team (Mascot));

CREATE SEQUENCE IF NOT EXISTS game_id
INCREMENT BY 1
MINVALUE 1 MAXVALUE 5000
START WITH 1;

CREATE TABLE game(
ID SERIAL,
HomeMascot VARCHAR (25) NOT NULL,
AwayMascot VARCHAR(25) NOT NULL,
HomeMascotScore INTEGER  NOT NULL,
AwayMascotScore INTEGER  NOT NULL,
GameDate DATE NOT NULL,
CONSTRAINT game_pkey PRIMARY KEY (ID));

CREATE SEQUENCE IF NOT EXISTS contract_id
INCREMENT BY 1
MINVALUE 1000 MAXVALUE 10000
START WITH 1000;

DROP TABLE contract;

CREATE TABLE contract(
ID SERIAL,
PlayerID VARCHAR (4),
Mascot VARCHAR (25),
Years INTEGER CONSTRAINT years_check CHECK (Years >= 1),
Amount NUMERIC (11,2) CONSTRAINT amount_check CHECK (Amount > 0.00),
AAV NUMERIC (10,2) CONSTRAINT aav_check CHECK (AAV > 0.00),
Expires INTEGER,
CONSTRAINT contract_pkey PRIMARY KEY (ID),
CONSTRAINT contract_fkey1 FOREIGN KEY (PlayerID) REFERENCES player (ID),
CONSTRAINT contract_fkey2 FOREIGN KEY (Mascot) REFERENCES team (Mascot)
);

CREATE TABLE player_stats(
ID VARCHAR (4),
Season VARCHAR(15),
Goals INTEGER,
Assists INTEGER,
Points INTEGER CONSTRAINT points_check CHECK (Points = Goals + Assists),
PlusMinus INTEGER,
PIM INTEGER,
CONSTRAINT player_stats_pkey1 PRIMARY KEY (ID, Season),
CONSTRAINT player_stats_fkey FOREIGN KEY (ID) REFERENCES player (ID));

DROP TABLE team_stats;
CREATE TABLE team_stats(
Mascot VARCHAR (25),
Season VARCHAR(15),
goalsFor INTEGER,
penaltyMinutesFor INTEGER,
hitsFor INTEGER,
faceOffWinsFor INTEGER,
goalsAgainst INTEGER,
penaltyMinutesAgainst INTEGER,
hitsAgainst INTEGER,
faceOffWinsAgainst INTEGER,
CONSTRAINT team_stats_pkey PRIMARY KEY (Mascot, Season),
CONSTRAINT team_stats_fkey1 FOREIGN KEY (Mascot) REFERENCES team (Mascot));


CREATE TABLE player_awards(
PlayerID VARCHAR (4),
AwardName VARCHAR (25) NOT NULL,
Season VARCHAR(15),
CONSTRAINT player_awards_pkey PRIMARY KEY (PlayerID, AwardName, Season),
CONSTRAINT player_awards_fkey FOREIGN KEY (PlayerID) REFERENCES player (ID));

CREATE SEQUENCE IF NOT EXISTS injury_id
INCREMENT BY 1
MINVALUE 10000 MAXVALUE 99999
START WITH 10000;

DROP TABLE injuries;
CREATE TABLE injuries(
ID VARCHAR (5),
PlayerID VARCHAR (4),
Mascot VARCHAR (25),
GameDate DATE,
InjuryDescription VARCHAR (250),
CONSTRAINT injuries_pkey PRIMARY KEY(ID),
CONSTRAINT injuries_fkey1 FOREIGN KEY(PlayerID) REFERENCES player (ID),
CONSTRAINT injuries_fkey2 FOREIGN KEY (Mascot) REFERENCES team (Mascot));


/* Inserting Data into player */

INSERT INTO player (id, mascot, city, name, draftyear, draftround, draftpick, position)
VALUES (nextval('player_id'), 'Canucks', 'Vancouver', 'Bo Horvat', '2013', '1', '9', 'C');

/* Inserting Data into PlayerStats */

ALTER TABLE player_stats ADD gamesplayed INTEGER;

DELETE FROM player_stats
WHERE ID = '100' AND season IN ('2021-2022', '2020-2021' );
INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), '2022-2023', 32, 40, 72, 5, 18, 37 );


INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), '2021-2022', 44, 79, 123, 28, 45, 80 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), '2020-2021', 33, 72, 105, 28, 45, 56 );


INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), '2022-2023', 21, 36, 57, 4, 16, 36 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), '2021-2022', 55, 55, 110, 17, 40, 80 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), '2020-2021', 31, 53, 84, 29, 22, 56 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nathan Mackinnon'), '2017-2018', 39, 58, 97, 11, 55, 74 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nathan Mackinnon'), '2016-2017', 16, 37, 53, -14, 16, 82 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nathan Mackinnon'), '2015-2016', 21, 31, 52, -4, 20, 72 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2015-2016', 30, 36, 66, 9, 30, 77 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2016-2017', 40, 45, 85, 13, 38, 74 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2017-2018', 39, 61, 100, 15, 42, 80 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2018-2019', 41, 87, 128, 24, 62, 82 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2019-2020', 33, 52, 85, 26, 38, 68 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2021-2022', 25, 44, 69, 1, 22, 47 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Nikita Kucherov'), '2022-2023', 13, 40, 53, 4, 22, 36 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), '2017-2018', 49, 38, 87, 3, 32, 82 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), '2016-2017', 33, 37, 70, 6, 50, 82 );

INSERT INTO player_stats (id, season, goals, assists, points, plusminus, pim, gamesplayed )
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), '2015-2016', 50, 20, 70, 21, 53, 79 );
/* Inserting Data into TeamStats * practice to pull record from team data */

INSERT INTO team_stats (mascot, season, record, goalsfor, goalsagainst, goaldifferential, totalpoints)
VALUES ('Maple Leafs', '2022-2023', '23-8-6', 125, 94, 31, 52);

/* Inserting Data into contracts */

INSERT INTO contract (playerid, id, mascot, years, amount, aav, expires)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), nextval('contract_id'), 'Oilers',
        8, 100000000.00, 12500000.00, '2026');

/* Inserting Data into Game */

INSERT INTO game (id, homemascot, awaymascot, homemascotscore, awaymascotscore, gamedate)
VALUES (nextval('game_id'), 'Avalanche', 'Maple Leafs', 2, 6, '2022-12-31');

/* Inserting Data into injury */

INSERT INTO injuries (playerid, id, mascot, gamedate, injurydescription)
VALUES ((SELECT ID FROM player WHERE name = 'Nathan Mackinnon'), nextval('injury_id'), 'Avalanche',
        '2022-12-31', 'Lower Body Injury; Day-to-Day');
        
        
/* Inserting Data into Awards */
INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Auston Matthews'), 'Hart Trophy', '2021-2022');


INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Auston Matthews'), 'Ted Lindsay Trophy', '2021-2022');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Auston Matthews'), 'Maurice Richard Trophy', '2021-2022');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Art Ross Trophy', '2021-2022');


INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Cale Makar'), 'Norris Trophy', '2021-2022');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Patrice Bergeron'), 'Selke Trophy', '2021-2022');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Auston Matthews'), 'Maurice Richard Trophy', '2020-2021');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Hart Trophy', '2020-2021');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Ted Lindsay Trophy', '2020-2021');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Art Ross Trophy', '2020-2021');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Art Ross Trophy', '2020-2021');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), 'Art Ross Trophy', '2019-2020');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), 'Hart Trophy', '2019-2020');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Leon Draisaitl'), 'Ted Lindsay Trophy', '2019-2020');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), 'Maurice Richard Trophy', '2014-2015');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), 'Maurice Richard Trophy', '2018-2019');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), 'Maurice Richard Trophy', '2017-2018');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Alexander Ovechkin'), 'Maurice Richard Trophy', '2015-2016');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Art Ross Trophy', '2017-2018');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Ted Lindsay', '2017-2018');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Art Ross Trophy', '2016-2017');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Connor McDavid'), 'Hart Trophy', '2016-2017');

INSERT INTO player_awards (playerid, awardname, season)
VALUES ((SELECT ID FROM player WHERE name = 'Auston Matthews'), 'Calder Trophy', '2016-2017');


/* Inserting Data into Teams from CSV */

copy team(City, Mascot, Captain, Coach)
FROM 'C:\Users\adaml\Downloads\teamdata2.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM team;

/* Inserting Data into Game from CSV */

copy game(homemascot, awaymascot, awaymascotscore, homemascotscore, gamedate)
FROM 'C:\Users\adaml\Downloads\gameinfo.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM game;

/* Adding Kraken to Team */

INSERT INTO team (mascot, city, coach, current_record)
VALUES ('Kraken', 'Seattle', 'Dave Hakstol', '19-12-4');



/* Inserting Data into team_stats from CSV */

copy team_stats(mascot, season, goalsfor, penaltyminutesfor, hitsfor,
                faceoffwinsfor, goalsagainst, penaltyminutesagainst, hitsagainst,
                faceoffwinsagainst)
FROM 'C:\Users\adaml\Downloads\teamstats1.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM team_stats;


copy player_stats(gamesplayed, goals, assists, points, plusminus, pim, season, id)
FROM 'C:\Users\adaml\Downloads\p2017.csv'
DELIMITER ','
CSV HEADER;


copy player_stats(season, gamesplayed, points, goals, pim, assists, id)
FROM 'C:\Users\adaml\Downloads\p2020.csv'
DELIMITER ','
CSV HEADER;

copy player_stats(season, gamesplayed, points, goals, pim, assists, id)
FROM 'C:\Users\adaml\Downloads\p2021.csv'
DELIMITER ','
CSV HEADER;

copy player_stats(season, gamesplayed, points, goals, pim, assists, id)
FROM 'C:\Users\adaml\Downloads\p2023.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM player_stats;


copy contract(playerid, mascot, years, amount, aav, expires)
FROM 'C:\Users\adaml\Downloads\contract.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM contract;

copy player_awards(playerid, awardname, season)
FROM 'C:\Users\adaml\Downloads\awards.csv'
DELIMITER ','
CSV HEADER;