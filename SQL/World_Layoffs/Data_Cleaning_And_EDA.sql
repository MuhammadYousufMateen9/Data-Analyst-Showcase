USE WORLD_LAYOFFS;
SELECT * FROM LAYOFFS;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values 
-- 4. Remove any Columns

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM LAYOFFS_STAGING;

INSERT LAYOFFS_STAGING
SELECT *
FROM LAYOFFS;

SELECT *, 
ROW_NUMBER() OVER (PARTITION BY COMPANY, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`) AS ROW_NUM
FROM LAYOFFS_STAGING;

WITH DUPLICATE_CTE AS(
	SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,
    STAGE, COUNTRY, FUNDS_RAISED_MILLIONS) AS ROW_NUM
	FROM LAYOFFS_STAGING
)
SELECT *
FROM DUPLICATE_CTE
WHERE ROW_NUM>=2;

CREATE TABLE layoffs_staging2 (
`company` text,
`location` text,
`industry` text,
`total_laid_off` INT DEFAULT NULL,
`percentage_laid_off` text,
`date` text,
`stage` text,
`country` text,
`funds_raised_millions` INT DEFAULT NULL,
`row_num` INT
);


SELECT * 
FROM LAYOFFS_STAGING2 
WHERE ROW_NUM>1;

INSERT INTO LAYOFFS_STAGING2
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`,
    STAGE, COUNTRY, FUNDS_RAISED_MILLIONS) AS ROW_NUM
	FROM LAYOFFS_STAGING;
    
DELETE
FROM LAYOFFS_STAGING2
WHERE ROW_NUM > 1;

SELECT * 
FROM LAYOFFS_STAGING2 ;


-- STANDARDIZING DATA

SELECT COMPANY, TRIM(COMPANY)
FROM LAYOFFS_STAGING2;

UPDATE LAYOFFS_STAGING2
SET COMPANY = TRIM(COMPANY);

SELECT *
FROM LAYOFFS_STAGING2
WHERE INDUSTRY LIKE 'CRYPTO%';

SELECT DISTINCT COUNTRY
FROM LAYOFFS_STAGING2
ORDER BY 1;

UPDATE LAYOFFS_STAGING2
SET COUNTRY = 'United States'
WHERE COUNTRY LIKE 'United States%';

UPDATE LAYOFFS_STAGING2
SET INDUSTRY = 'Crypto' 
WHERE INDUSTRY LIKE 'CRYPTO%';

SELECT distinct location
FROM LAYOFFS_STAGING2
order by 1;

SELECT *
FROM LAYOFFS_STAGING2;

UPDATE LAYOFFS_STAGING2
SET `DATE` = str_to_date(`DATE`, '%m/%d/%Y');

ALTER TABLE LAYOFFS_STAGING2
MODIFY COLUMN `date` DATE;


-- Null And Blank Values

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; 

SELECT DISTINCT INDUSTRY 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE INDUSTRY IS NULL
OR INDUSTRY = "";

SELECT * 
FROM layoffs_staging2
WHERE COMPANY = 'AIRBNB';



SELECT t1.company, t1.location, t1.industry AS T1, t2.industry AS T2 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
AND t2.industry <> '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
AND t2.industry <> '';

SELECT * 
FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- EDA (Exploratory Data Analysis)

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2 
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company 
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY industry 
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY country 
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY YEAR(`date`) 
ORDER BY 1 DESC;

SELECT *
FROM layoffs_staging2; 

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)

SELECT `MONTH`, total, SUM(total) OVER (ORDER BY `MONTH`)
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY company, YEAR(`date`)
), Company_Year_Ranking AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS rnk
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Ranking
WHERE rnk <= 5;