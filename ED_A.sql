SELECT * from layoffs_stagging

SELECT total_laid_off 
from layoffs_stagging
where TRY_CAST(total_laid_off AS INT) IS NULL
AND total_laid_off IS NOT NULL

UPDATE layoffs_stagging
set total_laid_off = NULL
where TRY_CAST(total_laid_off AS INT) IS NULL

ALTER TABLE layoffs_stagging 
ALTER COLUMN total_laid_off INT
-----------------------
-- percentage_laid_off 
SELECT percentage_laid_off 
from layoffs_stagging
where TRY_CAST(percentage_laid_off AS float) IS NULL
AND percentage_laid_off IS NOT NULL

UPDATE layoffs_stagging
set percentage_laid_off = NULL
where TRY_CAST(percentage_laid_off AS float) IS NULL

ALTER TABLE layoffs_stagging 
ALTER COLUMN percentage_laid_off float

----- funds_raised_millions

SELECT funds_raised_millions 
from layoffs_stagging
where TRY_CAST(funds_raised_millions AS float) IS NULL
AND funds_raised_millions IS NOT NULL

UPDATE layoffs_stagging
set funds_raised_millions = NULL
where TRY_CAST(funds_raised_millions AS float) IS NULL

ALTER TABLE layoffs_stagging 
ALTER COLUMN funds_raised_millions float


SELECT DISTINCT total_laid_off
FROM layoffs
WHERE ISNUMERIC(total_laid_off) = 0;
---------- date
SELECT DISTINCT [date]
FROM layoffs
WHERE TRY_CONVERT(date, [date]) IS NULL;

UPDATE layoffs_stagging
SET [date] = NULL
WHERE TRY_CONVERT(date, [date]) IS NULL;

ALTER TABLE layoffs_stagging
ALTER COLUMN [date] DATE;

----
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoffs_stagging';


UPDATE layoffs
SET total_laid_off = NULL
WHERE ISNUMERIC(total_laid_off) = 0;

ALTER TABLE layoffs
ALTER COLUMN total_laid_off INT;

-----------
EXEC sp_help 'layoffs_stagging' 
----------------
select MAX(total_laid_off) as max_laiyoff
from layoffs_stagging

--# -- Looking at Percentage to see how big these layoffs were
SELECT 
MAX(percentage_laid_off) Max_Percentage ,
MIN(percentage_laid_off) Min_Percentage
FROM layoffs_stagging
where percentage_laid_off is not null

-- Which companies had 1 which is basically 100 percent of they company laid off

select * from layoffs_stagging
where percentage_laid_off = 1
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
select * 
from layoffs_stagging
where percentage_laid_off =1
Order by funds_raised_millions DESC

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------
-- Companies with the biggest single Layoff

select TOP 5 
company , total_laid_off
FROM layoffs_stagging
order by total_laid_off DESC

-- Companies with the most Total Layoffs
SELECT TOP 10
company ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY company
ORDER BY SUM(total_laid_off) DESC

-- by location
SELECT TOP 10
location ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY location
ORDER BY SUM(total_laid_off) DESC

-- this it total in the past 3 years or in the dataset
SELECT TOP 10
country ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY country
ORDER BY SUM(total_laid_off) DESC

SELECT TOP 10
YEAR([date]) AS [Year] ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY YEAR([date])
ORDER BY [Year] ASC

SELECT 
industry ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC

SELECT  
stage ,
SUM(total_laid_off) TOTAL_LAID_OFF
from layoffs_stagging
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC

-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH COMPANY_YEAR AS
(
    SELECT 
        company,
        YEAR([date]) AS years,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_stagging
    GROUP BY company, YEAR([date])
), 
COMPANY_YEAR_RANK AS (
    SELECT 
        company,
        years,
        total_laid_off,
        DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM COMPANY_YEAR
)
SELECT 
    company,
    years,
    total_laid_off,
    ranking
FROM COMPANY_YEAR_RANK
WHERE ranking <= 3
ORDER BY years ASC, total_laid_off DESC;

-- Rolling Total of Layoffs Per Month

WITH Date_CTE AS
(
    SELECT 
        DATEFROMPARTS(YEAR([date]), MONTH([date]), 1) AS MonthStart,
        SUM(total_laid_off) AS Total_Laid_Off
    FROM layoffs_stagging
    GROUP BY DATEFROMPARTS(YEAR([date]), MONTH([date]), 1)
)
SELECT 
    CONVERT(char(7), MonthStart, 126) AS Month_Year,
    SUM(Total_Laid_Off) OVER (ORDER BY MonthStart ROWS UNBOUNDED PRECEDING) AS Rolling_Total_Layoffs
FROM Date_CTE
ORDER BY MonthStart;
