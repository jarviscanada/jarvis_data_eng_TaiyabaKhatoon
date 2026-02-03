# Introduction

# SQL Queries

###### Modifying Data ######

### Insert some data into a table

```sql
INSERT INTO cd.facilities
  (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
  (9, 'Spa', 20, 30, 100000, 800);
```

Explanation:
This query adds a new facility called Spa into the facilities table.
All required values are explicitly provided so the row is inserted with the correct costs and identifiers.


### Insert calculated data into a table

```sql
INSERT INTO cd.facilities
SELECT
  MAX(facid) + 1,
  'Spa',
  20,
  30,
  100000,
  800
FROM cd.facilities;
```

Explanation:
This query inserts a new facility by calculating the next available facid using the current maximum value.


### Update some existing data

```sql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```

Explanation: 
This query updates the initial cost of Tennis Court 2 to correct the previously entered value.


### Update a row based on the contents of another row

```sql
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
```

Explanation: 
This query updates Tennis Court 2s member and guest prices to be 10% higher than Tennis Court 1 using subqueries.


### Delete all bookings

```sql
DELETE FROM cd.bookings;
```

Explanation:
This query removes all records from the bookings table to clear existing booking data.

### Delete a member from the cd.members table

```sql
DELETE FROM cd.members
WHERE memid = 37;
```

Explanation:
This query deletes the member with ID 37 from the members table since they have no bookings.


###### Basics ######

### Control which rows are retrieved - part 2

```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost < monthlymaintenance / 50.0;
```

Explanation: 
This query returns facilities that charge members a fee but where the fee is less than 1/50 of monthly maintenance.

### Basic string searches

```sql
SELECT facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
FROM cd.facilities
WHERE name LIKE '%Tennis%';
```

Explanation: 
This query lists all facilities whose names contain the word Tennis.

### Matching against multiple possible values

```sql
SELECT facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
FROM cd.facilities
WHERE facid IN (1, 5);
```

Explanation:
This query retrieves facility details for IDs 1 and 5 using the IN clause instead of OR.

### Working with dates

```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';
```

Explanation:
This query lists members who joined on or after the start of September 2012.

### Combining results from multiple queries

```sql
SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;
```

Explanation:
This query combines member surnames and facility names into a single result set using UNION.


###### Join ######

### Retrieve the start times of members' bookings

```sql
SELECT b.starttime
FROM cd.bookings b
JOIN cd.members m
  ON b.memid = m.memid
WHERE m.firstname = 'David'
  AND m.surname = 'Farrell';
```

Explanation:
This query joins bookings with members to list booking start times for the member named David Farrell.

### Work out the start times of bookings for tennis courts

```sql
SELECT b.starttime AS start, f.name
FROM cd.bookings b
JOIN cd.facilities f
  ON b.facid = f.facid
WHERE f.name LIKE 'Tennis Court%'
  AND b.starttime >= '2012-09-21'
  AND b.starttime < '2012-09-22'
ORDER BY b.starttime;
```

Explanation:
This query lists tennis court booking start times for a specific date and orders them chronologically.

### Produce a list of all members, along with their recommender

```sql
SELECT
  m.firstname AS memfname,
  m.surname   AS memsname,
  r.firstname AS recfname,
  r.surname   AS recsname
FROM cd.members m
LEFT JOIN cd.members r
  ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;
```

Explanation:
This query self-joins the members table to show each member alongside their recommender when available.

### Produce a list of all members who have recommended another member

```sql
SELECT DISTINCT r.firstname, r.surname
FROM cd.members m
JOIN cd.members r
  ON m.recommendedby = r.memid
ORDER BY r.surname, r.firstname;
```

Explanation:
This query lists members who have recommended others by self-joining the members table and removing duplicates.

### Produce a list of all members, along with their recommender, using no joins

```sql
SELECT DISTINCT
  mems.firstname || ' ' || mems.surname AS member,
  (
    SELECT recs.firstname || ' ' || recs.surname
    FROM cd.members recs
    WHERE recs.memid = mems.recommendedby
  ) AS recommender
FROM cd.members mems
ORDER BY member;
```

Explanation:
This query uses a correlated subquery to list each member with their recommender without using joins.

