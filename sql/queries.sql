
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
