USE p1__world_life_expectancy;

SELECT *
FROM world_life_expectancy;

CREATE TABLE life LIKE world_life_expectancy;

INSERT INTO life
SELECT * FROM world_life_expectancy;

----------------------------------------------------------------

-- Data Cleaning

----------------------------------------------------------------

-- 1. Removing Duplicates

----------------------------------------------------------------

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

-- Creating table 'life_v1' after removing duplicates
CREATE VIEW `life_v1` AS
WITH 
CTE1 AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY Country, `Year`) AS rn
    FROM life
)
SELECT *
FROM CTE1
WHERE rn = 1;


------------------------------------------------------------------

-- 2. 

------------------------------------------------------------------

SELECT *
FROM life_v1;

-- Confirming the removal of duplicates
SELECT Country, `Year`, COUNT(*)
FROM life_v1
GROUP BY COuntry, `Year`
HAVING COUNT(*) >= 2;

