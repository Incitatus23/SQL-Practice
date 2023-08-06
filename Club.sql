---BASIC #1---
SELECT *
FROM facilities;

---BASIC #2----
SELECT name, membercost
FROM facilities;

---BASIC #3---
SELECT name, membercost
FROM facilities;

---BASIC #4---
SELECT *
FROM facilities
WHERE membercost > 0.00;

---BASIC #5---
SELECT facid, name, membercost, monthlymaintenance
FROM facilities
WHERE membercost < (monthlymaintenance * 0.02) AND membercost > 0;

---BASIC #6---
SELECT *
FROM facilities
WHERE name ILIKE '%Tennis%';

SELECT *
FROM facilities
WHERE facid IN ('1', '5');

---BASIC #7----
SELECT name,
CASE
    WHEN monthlymaintenance > 100 THEN 'expensive'
    WHEN monthlymaintenance <= 100 THEN 'cheap'
END AS cost
FROM facilities;

---BASIC #8----work more with dates & time---

SELECT memid, surname, firstname, joindate
FROM members
WHERE joindate >= '2012-09-01';

---BASIC #9----
SELECT DISTINCT surname
FROM members
ORDER BY surname
LIMIT 10;

---BASIC #10---

(SELECT surname
FROM members)
UNION
(SELECT name
FROM facilities);

---BASIC #11---
SELECT joindate AS latest
FROM members
ORDER BY joindate DESC
LIMIT 1;

SELECT MAX(joindate) AS latest
FROM members;

---BASIC #12---
SELECT surname, firstname, joindate
FROM members
ORDER BY joindate DESC
LIMIT 1;

---JOINS #1---
SELECT 
FROM bookings JOIN members on bookings.memid = members.memid
WHERE surname = 'Farrell' and firstname = 'David';

---JOINS #2------
SELECT starttime, name
FROM bookings JOIN facilities ON bookings.facid = facilities.facid
WHERE DATE(starttime) = '2012-09-21' AND name IN ('Tennis Court 1', 'Tennis Court 2')
ORDER BY starttime;

----JOINS #3-----
SELECT DISTINCT T.firstname, T.surname
FROM members AS T JOIN members AS S on T.memid = S.recommendedby
ORDER BY surname, firstname;

----JOINS #4----
SELECT T.firstname AS memfname, T.surname AS memsname, S.firstname AS recfname, S.surname AS recsname
FROM members AS T LEFT OUTER JOIN members AS S on S.memid = T.recommendedby
ORDER BY T.surname, T.firstname;

---JOINS #5---
SELECT DISTINCT members.firstname || ' ' || members.surname AS member, facilities.name AS facility
FROM members JOIN bookings ON members.memid = bookings.memid JOIN facilities ON 
bookings.facid = facilities.facid
WHERE facilities.name IN ('Tennis Court 1', 'Tennis Court 2')
ORDER BY member, facility;

---JOINS-----
SELECT members.firstname || ' ' || members.surname AS member, facilities.name AS facility,
CASE
    WHEN members.memid = 0 THEN bookings.slots * facilities.guestcost
    ELSE bookings.slots * facilities.membercost
END AS COST
FROM members JOIN bookings ON members.memid = bookings.memid JOIN facilities ON 
bookings.facid = facilities.facid
WHERE DATE(bookings.starttime) = '2012-09-14' AND (guestcost) > 30 AND (membercost) > 30
ORDER BY cost DESC;








