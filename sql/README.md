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

