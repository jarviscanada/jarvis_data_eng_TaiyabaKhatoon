
--- Modifying Data 

--Question 1: Insert Spa facility

INSERT INTO cd.facilities (
   facid, name, membercost, guestcost,
   initialoutlay, monthlymaintenance
  )
VALUES
  (9, 'Spa', 20, 30, 100000, 800);

-- Question 2: Insert Spa facility with calculated facid

INSERT INTO cd.facilities
SELECT
  MAX(facid) + 1,
  'Spa',
  20,
  30,
  100000,
  800
FROM
   cd.facilities;

-- Question 3: Correct initial outlay for Tennis Court 2

UPDATE
  cd.facilities
SET
  initialoutlay = 10000
WHERE
  name = 'Tennis Court 2';

-- Question 4: Update Tennis Court 2 prices based on Tennis Court 1

UPDATE cd.facilities
SET
  membercost = (
    SELECT membercost * 1.1
    FROM cd.facilities
    WHERE name = 'Tennis Court 1'
  ),
  guestcost = (
    SELECT guestcost * 1.1
    FROM cd.facilities
    WHERE name = 'Tennis Court 1'
  )
WHERE name = 'Tennis Court 2';

-- Question 5: Delete all bookings

DELETE FROM
  cd.bookings;

-- Question 6: Delete member with no bookings

DELETE FROM
  cd.members
WHERE
  memid = 37;


--- Basics

-- Question 1: Control which rows are retrieved - part 2

SELECT
  facid,
  name,
  membercost,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  membercost > 0
  AND membercost < monthlymaintenance / 50.0;

-- Question 2: Basic string searches

SELECT
  facid,
  name,
  membercost,
  guestcost,
  initialoutlay,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  name LIKE '%Tennis%';

-- Question 3: Matching against multiple possible values

SELECT
  facid,
  name,
  membercost,
  guestcost,
  initialoutlay,
  monthlymaintenance
FROM
  cd.facilities
WHERE
  facid IN (1, 5);

-- Question 4: Working with dates

SELECT
  memid,
  surname,
  firstname,
  joindate
FROM
  cd.members
WHERE
  joindate >= '2012-09-01';

-- Question 5: Combining results from multiple queries

SELECT
  surname
FROM
  cd.members
UNION
SELECT
  name
FROM
  cd.facilities;


--- Join

-- Question 1:  Retrieve the start times of members' bookings

SELECT
  b.starttime
FROM
  cd.bookings b
  JOIN cd.members m ON b.memid = m.memid
WHERE
  m.firstname = 'David'
  AND m.surname = 'Farrell';

-- Question 2: Work out the start times of bookings for tennis courts

SELECT
  b.starttime AS start,
  f.name
FROM
  cd.bookings b
  JOIN cd.facilities f ON b.facid = f.facid
WHERE
  f.name LIKE 'Tennis Court%'
  AND b.starttime >= '2012-09-21'
  AND b.starttime < '2012-09-22'
ORDER BY
  b.starttime;

-- Question 3: Produce a list of all members, along with their recommender

SELECT
  m.firstname AS memfname,
  m.surname AS memsname,
  r.firstname AS recfname,
  r.surname AS recsname
FROM
  cd.members m
  LEFT JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY
  m.surname,
  m.firstname;

-- Question 4: Produce a list of all members who have recommended another member

SELECT
  DISTINCT r.firstname,
  r.surname
FROM
  cd.members m
  JOIN cd.members r ON m.recommendedby = r.memid
ORDER BY
  r.surname,
  r.firstname;

-- Question 5: Produce a list of all members, along with their recommender, using no joins

SELECT
  DISTINCT mems.firstname || ' ' || mems.surname AS member,
  (
    SELECT
      recs.firstname || ' ' || recs.surname
    FROM
      cd.members recs
    WHERE
      recs.memid = mems.recommendedby
  ) AS recommender
FROM
  cd.members mems
ORDER BY
  member;


--- Aggregation

-- Question 1: Count the number of recommendations each member makes 

SELECT
  recommendedby,
  COUNT(*) AS count
FROM
  cd.members
WHERE
  recommendedby IS NOT NULL
GROUP BY
  recommendedby
ORDER BY
  recommendedby;

-- Question 2: List the total slots booked per facility

SELECT
  facid,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
GROUP BY
  facid
ORDER BY
  facid;

-- Question 3: List the total slots booked per facility in September 2012

SELECT
  facid,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY
  facid
ORDER BY
  "Total Slots";

-- Question 4: List the total slots booked per facility per month in 2012

SELECT
  facid,
  EXTRACT(
    month
    FROM
      starttime
  ) AS month,
  SUM(slots) AS "Total Slots"
FROM
  cd.bookings
WHERE
  starttime >= '2012-01-01'
  AND starttime < '2013-01-01'
GROUP BY
  facid,
  month
ORDER BY
  facid,
  month;

-- Question 5: Find the count of members who have made at least one booking

SELECT
  COUNT(DISTINCT memid) AS count
FROM
  cd.bookings;

-- Question 6: List each member's first booking after September 1st 2012

SELECT
  m.surname,
  m.firstname,
  b.memid,
  MIN(b.starttime) AS starttime
FROM
  cd.bookings b
  JOIN cd.members m ON m.memid = b.memid
WHERE
  b.starttime >= '2012-09-01'
GROUP BY
  m.surname,
  m.firstname,
  b.memid
ORDER BY
  b.memid;

-- Question 7: Produce a list of member names with the total member count on each row

SELECT
  COUNT(*) OVER () AS count,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Question 8: Produce a numbered list of members ordered by join date

SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      joindate
  ) AS row_number,
  firstname,
  surname
FROM
  cd.members
ORDER BY
  joindate;

-- Question 9: Output the facility with the highest total number of slots booked (including ties)

SELECT
  facid,
  SUM(slots) AS total
FROM
  cd.bookings
GROUP BY
  facid
HAVING
  SUM(slots) = (
    SELECT
      MAX(total_slots)
    FROM
      (
        SELECT
          SUM(slots) AS total_slots
        FROM
          cd.bookings
        GROUP BY
          facid
      ) sub
  );

