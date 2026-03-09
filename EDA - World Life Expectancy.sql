SELECT *
FROM life;

-- Min & Max life expectancy for each country over the last 15 years
SELECT Country,
    MIN(`Life expectancy`) AS min_life,
    MAX(`Life expectancy`) AS max_life
FROM life
GROUP BY Country
HAVING MIN(`Life expectancy`) != 0 AND MAX(`Life expectancy`) != 0;

-- Top 10 countries with highest increase in life expectancy from 2007 - 2022
SELECT Country,
    MIN(`Life expectancy`) AS min_life,
    MAX(`Life expectancy`) AS max_life,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_inc
FROM life
GROUP BY Country
ORDER BY life_inc DESC
LIMIT 10;

-- Top 10 countries with highest life expectancy in 2022
SELECT Country,
    MAX(`Life expectancy`) AS max_life
FROM life
WHERE `Year` = 2022
GROUP BY Country
ORDER BY max_life DESC
LIMIT 10;

-- Correlation between life expectancy and GDP

-- Avg life expectancy for countries with low avg GDP
SELECT Country, 
    ROUND(AVG(`Life expectancy`), 1) AS avg_life, 
    ROUND(AVG(GDP), 1) AS avg_gdp
FROM life
GROUP BY Country
HAVING AVG(`Life expectancy`) != 0 AND AVG(GDP) != 0
ORDER BY avg_gdp ASC;

-- Avg life expectancy for countries with high avg GDP
SELECT Country, 
    ROUND(AVG(`Life expectancy`), 1) AS avg_life, 
    ROUND(AVG(GDP), 1) AS avg_gdp
FROM life
GROUP BY Country
HAVING AVG(`Life expectancy`) != 0 AND AVG(GDP) != 0
ORDER BY avg_gdp DESC;

------------------------------------------------------------------------------------
-- Note: Looks like positive correlation between life expectancy & GDP of country
------------------------------------------------------------------------------------

-- Country's life expectancy & GDP compared to Avg Global life expectancy & GDP
SELECT Country,
    `Life expectancy` AS life_exp,
    IF(`Life expectancy` <= AVG(`Life expectancy`) OVER(), '<= Avg Global Life', '> Avg Global Life') AS life_exp_category,
    GDP,
    IF(GDP <= AVG(GDP) OVER(), '<= Avg Global GDP', '> Avg Global GDP') AS GDP_category
FROM life
WHERE `Year` = 2022 AND `Life expectancy` != 0 AND GDP != 0
ORDER BY GDP_category ASC;

-- Avg global life expectancy & GDP
SELECT ROUND(AVG(`Life expectancy`), 1) AS avg_life, ROUND(AVG(GDP), 1) AS avg_gdp
FROM life
WHERE `Year` = 2022 AND `Life expectancy` IS NOT NULL AND GDP IS NOT NULL;

-- Countries with life expectancy below or equal to global average
WITH 
CTE1 AS (
    SELECT Country,
        `Life expectancy` AS life_exp,
        ROUND(AVG(`Life expectancy`) OVER(), 1) AS avg_global_life,
        IF(`Life expectancy` <= ROUND((AVG(`Life expectancy`) OVER())), '<= Avg Global Life', '> Avg Global Life') AS life_exp_category,
        GDP,
        ROUND(AVG(GDP) OVER(), 1) AS avg_global_gdp,
        IF(GDP <= ROUND((AVG(GDP) OVER())), '<= Avg Global GDP', '> Avg Global GDP') AS GDP_category
    FROM life
    WHERE `Year` = 2022 AND `Life expectancy` IS NOT NULL AND GDP IS NOT NULL
)
SELECT *
FROM CTE1
WHERE life_exp_category = '<= Avg Global Life';

-- Countries with GDP greater than global average
WITH 
CTE1 AS (
    SELECT Country,
        `Life expectancy` AS life_exp,
        ROUND(AVG(`Life expectancy`) OVER(), 1) AS avg_global_life,
        IF(`Life expectancy` <= ROUND((AVG(`Life expectancy`) OVER())), '<= Avg Global Life', '> Avg Global Life') AS life_exp_category,
        GDP,
        ROUND(AVG(GDP) OVER(), 1) AS avg_global_gdp,
        IF(GDP <= ROUND((AVG(GDP) OVER())), '<= Avg Global GDP', '> Avg Global GDP') AS GDP_category
    FROM life
    WHERE `Year` = 2022 AND `Life expectancy` IS NOT NULL AND GDP IS NOT NULL
)
SELECT *
FROM CTE1
WHERE GDP_category = '> Avg Global GDP';

-- Countries with GDP > global avg but life expectancy <= global avg
WITH 
CTE1 AS (
    SELECT Country,
        `Life expectancy` AS life_exp,
        ROUND(AVG(`Life expectancy`) OVER(), 1) AS avg_global_life,
        IF(`Life expectancy` <= ROUND((AVG(`Life expectancy`) OVER())), '<= Avg Global Life', '> Avg Global Life') AS life_exp_category,
        GDP,
        ROUND(AVG(GDP) OVER(), 1) AS avg_global_gdp,
        IF(GDP <= ROUND((AVG(GDP) OVER())), '<= Avg Global GDP', '> Avg Global GDP') AS GDP_category
    FROM life
    WHERE `Year` = 2022 AND `Life expectancy` IS NOT NULL AND GDP IS NOT NULL
)
SELECT *
FROM CTE1
WHERE GDP_category = '> Avg Global GDP' AND life_exp_category = '<= Avg Global Life';

