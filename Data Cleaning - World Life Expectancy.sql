USE p1__world_life_expectancy;

-- Original table
SELECT *
FROM world_life_expectancy;

-- Creating a copy table for data cleaning
CREATE TABLE life LIKE world_life_expectancy;

INSERT INTO life
SELECT * FROM world_life_expectancy;

-- Data cleaning table
SELECT *
FROM life;

----------------------------------------------------------------

-- Data Cleaning

----------------------------------------------------------------

-- 1. Removing Duplicates

----------------------------------------------------------------

SELECT *
FROM life;

-- Finding the duplicates
SELECT Country, `Year`, COUNT(*)
FROM life
GROUP BY COuntry, `Year`
HAVING COUNT(*) >= 2;

-- Identifying the duplicates for removal
WITH 
CTE1 AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY Country, `Year`) AS rn
    FROM life
)
SELECT *
FROM CTE1
WHERE rn >= 2;

-- Deleting the duplicate records
WITH 
CTE1 AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY Country, `Year`) AS rn
    FROM life
)
DELETE
FROM life
WHERE Row_ID IN (
    SELECT Row_ID
    FROM CTE1
    WHERE rn > 1
)


------------------------------------------------------------------

-- 2. Handlying blank / NULL values

------------------------------------------------------------------

SELECT *
FROM life;

-- Confirming the removal of duplicates
SELECT Country, `Year`, COUNT(*)
FROM life
GROUP BY COuntry, `Year`
HAVING COUNT(*) >= 2;


---------------------------------------------------------------
-- 1. Populating the blank values in 'Status' column
---------------------------------------------------------------

SELECT COUNT(*)
FROM life
WHERE `Status` = '';

-- Identifying the blank values
SELECT *
FROM life
WHERE `Status` = '';

-- Converting blanks to NULL
UPDATE life
SET `Status` = NULL
WHERE `Status` = '';

SELECT COUNT(*)
FROM life
WHERE `Status` IS NULL;

-- Checking if a value is available for populating the null values
SELECT Country, GROUP_CONCAT(DISTINCT `Status`) AS `values`
FROM life
GROUP BY Country;

-- Identifying the values that can be used for populating the null values
SELECT t1.Country, t1.`Status`, t1.`Year`, t2.`Status`, t2.`Year`
FROM life t1 INNER JOIN life t2
    ON t1.Country = t2.Country
WHERE t1.`Status` IS NULL AND t2.`Status` IS NOT NULL;

-- pouplating the null values
UPDATE life t1 INNER JOIN (
        SELECT Country, MAX(Status) AS `Status`
        FROM life
        WHERE `Status` IS NOT NULL
        GROUP BY Country
    ) t2
ON t1.Country = t2.Country
SET t1.Status = t2.Status
WHERE t1.Status IS NULL;

-- Confirming that 'Status' column was populated successfully
SELECT COUNT(*)
FROM life
WHERE `Status` IS NULL;

SELECT Country, GROUP_CONCAT(DISTINCT `Status`) AS `values`
FROM life
GROUP BY Country;


---------------------------------------------------------------
-- 2. Populating the blanks in 'Life expectancy' column
---------------------------------------------------------------

SELECT *
FROM life;

-- Checking for blank values
SELECT Country, `Year`, `Life expectancy`
FROM life
WHERE `Life expectancy` = ''; 

-- Converting blanks to null
UPDATE life
SET `Life expectancy` = NULL
WHERE `Life expectancy` = '';

SELECT Country, `Year`, `Life expectancy`
FROM life
WHERE `Life expectancy` IS NULL; 

-- Identifying the values to use to populate the null values
SELECT t1.Row_ID,
    t1.Country, 
    t1.`Year` AS t1_year, 
    t1.`Life expectancy` AS t1_val,
    t2.`Year` AS t2_year,
    t2.`Life expectancy` AS t2_val,
    t3.`Year` AS t3_year,
    t3.`Life expectancy` AS t3_val
FROM life t1 INNER JOIN life t2
    ON t1.Country = t2.Country AND t1.`Year` = t2.`Year`-1
    INNER JOIN life t3
    ON t1.Country = t3.Country AND t1.`Year` = t3.`Year`+1
WHERE t1.`Life expectancy` IS NULL; 

-- Type-casting 'Life expectancy' from String to Float type
UPDATE life
SET `Life expectancy` = CAST(`Life expectancy` AS DECIMAL(3,1));

-- Populating the null values
UPDATE life t1 INNER JOIN life t2
    ON t1.Country = t2.Country AND t1.`Year` = t2.`Year`-1
    INNER JOIN life t3
    ON t1.Country = t3.Country AND t1.`Year` = t3.`Year`+1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` IS NULL;


---------------------------------------------------------------


SELECT *
FROM life;
