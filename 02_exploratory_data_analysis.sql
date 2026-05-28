-- Exploratory Data Analysis
-- Dataset: Layoffs data after cleaning
-- Goal: Explore layoff patterns by company, industry, country, time, and yearly ranking


-- 1. Companies with 100% layoffs, sorted by funding raised
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- 2. Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

-- 3. Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;


-- 4. Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- 5. Date range of the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;

-- 6. Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

-- 7. Total layoffs by month
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
SUM(total_laid_off)
FROM layoffs_staging2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY month
ORDER BY 1 
;

-- 8. Rolling total of layoffs by month
WITH monthly_total AS
(
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY month
ORDER BY 1  
)
SELECT month, laid_off, SUM(laid_off) OVER(ORDER BY month) AS rolling_total
FROM monthly_total
;

-- 9. Total layoffs by company and year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC
;

-- 10. Top 5 companies with the most layoffs in each year
WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE ranking <= 5
;

-- 11. Average layoffs by industry
SELECT industry, 
ROUND(AVG(total_laid_off), 2) AS avg_layoff
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY avg_layoff DESC
;

-- 12. Total layoffs by stage
SELECT stage, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total DESC
;

-- 13. Number of layoff events by year
SELECT YEAR(`date`) AS year,
COUNT(*) AS layoff_events, 
SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY year
;