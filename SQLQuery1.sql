SELECT * FROM layoffs

SELECT * 
INTO layoffs_stagging 
FROM layoffs

SELECT * FROM layoffs_stagging

-- 1. check duplicates and remove them
-- 2. Standardize Data

-- check for duplicates:
SELECT * , 
ROW_NUMBER() OVER(
                  PARTITION BY company , location ,
                               industry , total_laid_off,
                               percentage_laid_off,
                               [date] , stage,
                               country, funds_raised_millions
                ORDER BY company
                   ) AS row_num
FROM layoffs_stagging
-- display duplicates 

WITH DUPLICATES_CTE AS (
SELECT * , 
ROW_NUMBER() OVER(
                  PARTITION BY company , location ,
                               industry , total_laid_off,
                               percentage_laid_off,
                               [date] , stage,
                               country, funds_raised_millions
                ORDER BY company
                   ) AS row_num
FROM layoffs_stagging
)
SELECT * FROM DUPLICATES_CTE 
WHERE row_num >1

ALTER TABLE layoffs_stagging 
ADD id INT identity(1,1) primary key 

select * from layoffs_stagging 

-- delete duplicates 

WITH DELETE_DUPLICATE_CTE AS
( 
SELECT * , 
ROW_NUMBER() OVER(
                  PARTITION BY company , location ,
                               industry , total_laid_off,
                               percentage_laid_off,
                               [date] , stage,
                               country, funds_raised_millions
                ORDER BY company
                ) as row_num
FROM layoffs_stagging
)
DELETE FROM DELETE_DUPLICATE_CTE WHERE row_num >1


-- 
WITH check_cte AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions,
           COUNT(*) AS count_rows
    FROM layoffs_stagging
    GROUP BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
    HAVING COUNT(*) > 1
)
SELECT * FROM check_cte;
-- NOW , DUPLICATES ARE REMOVED 

-- 2. Standardize Data
SELECT * FROM layoffs_stagging

SELECT DISTINCT[industry]
from layoffs_stagging
order by industry

UPDATE layoffs_stagging 
SET industry = NULL
WHERE LTRIM(RTRIM(industry)) = ''

SELECT *
FROM layoffs_stagging
WHERE [industry] IS NULL;

---------------------------

WITH CompanyIndustry AS (
    SELECT 
        company,
        MAX(LTRIM(RTRIM([industry]))) AS industry_non_null
    FROM layoffs_stagging
    WHERE [industry] IS NOT NULL
      AND LTRIM(RTRIM([industry])) <> ''
    GROUP BY company
)
UPDATE t
SET t.[industry] = c.industry_non_null
FROM layoffs_stagging t
JOIN CompanyIndustry c
  ON t.company = c.company
WHERE (t.[industry] IS NULL OR LTRIM(RTRIM(t.[industry])) = '');

SELECT *
FROM layoffs_stagging
WHERE [industry] IS NULL
   OR LTRIM(RTRIM([industry])) = '';
--------------------
select industry from layoffs_stagging
group by industry

UPDATE layoffs_stagging 
SET industry = 'Crypto'
WHERE LTRIM(RTRIM(industry)) IN ('CryptoCurrency', 'Crypto Currency', 'CryptoCurrencies');

SELECT DISTINCT [industry]
FROM layoffs_stagging
ORDER BY [industry];

UPDATE layoffs_stagging
set country =
         Case 
         WHEN country IS NOT NULL AND RIGHT(RTRIM(country) , 1) = '.'
         THEN LEFT(RTRIM(country),len(RTRIM(country)) -1)
         WHEN country IS NOT NULL THEN RTRIM(country)
         ELSE NULL 
         END 
   
SELECT DISTINCT [country]
FROM layoffs_stagging
ORDER BY [country];

ALTER TABLE layoffs_stagging
ADD date_clean DATE

select * from layoffs_stagging

UPDATE layoffs_stagging
SET date_clean= TRY_CONVERT(date , [date] , 101)

select * from layoffs_stagging
where [date] is not null 
          and date_clean is null 

alter table layoffs_stagging
drop column [date]
exec sp_rename 'layoffs_stagging.date_clean' , 'date' ,'COLUMN'

UPDATE layoffs_stagging
SET country = UPPER(TRIM(country)),
location = UPPER(TRIM(location))

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_stagging AS t1
INNER JOIN layoffs_stagging AS t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_stagging
WHERE industry IS NULL 
   OR industry = ''
ORDER BY industry;

SELECT *
FROM layoffs_stagging
where total_laid_off is null
and percentage_laid_off is null

delete
FROM layoffs_stagging
where total_laid_off is null
and percentage_laid_off is null

