-- ============================================
-- SQL Layoffs Exploratory Data Analysis
-- Guided project based on Alex The Analyst
-- Revisited and expanded with additional validation and original analysis
-- ============================================

USE world_layoffs_portfolio;


-- ============================================
-- 1. Dataset Overview
-- ============================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT company) AS unique_companies,
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- The cleaned dataset contains 1,995 records across 1,628 unique companies
-- and covers 2020-03-11 through 2023-03-06.


-- ============================================
-- 2. Largest Individual Layoff Events
-- ============================================

SELECT
    company,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    country
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

-- Google had the largest single reported layoff event in the dataset,
-- with 12,000 employees laid off in one event.


-- ============================================
-- 3. Companies With the Highest Total Layoffs
-- ============================================

SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Amazon had the highest total layoffs across all reported events.
-- This differs from the single event ranking because some companies had
-- multiple layoff rounds that increased their cumulative total.


-- ============================================
-- 4. Layoffs by Industry
-- ============================================

SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE industry IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Consumer had the highest total layoffs by industry, followed by Retail,
-- Other, Transportation, and Finance.


-- ============================================
-- 5. Layoffs by Country
-- ============================================

SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_layoffs DESC;

-- The United States had the highest total layoffs by country, followed by
-- India, the Netherlands, Sweden, and Brazil.


-- ============================================
-- 6. Annual Layoff Trends
-- ============================================

SELECT
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY year;

-- Layoffs were highest in 2022 among the complete years in the dataset.
-- By March 6, 2023, reported layoffs had already reached 125,677,
-- indicating a high concentration of layoffs early in the year.
-- Total layoffs drastically increased from 15,823 in 2021 to 160,661 in 2022. 


-- ============================================
-- 7. Monthly Layoff Trends
-- ============================================

SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY month;

-- January 2023 had the highest monthly layoffs with 84,714.
-- Layoffs were consistently elevated from October 2022 through February 2023,
-- with another noticeable spike in April and May 2020.


-- ============================================
-- 8. Cumulative Layoffs Over Time
-- ============================================

WITH monthly_layoffs AS
(
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
      AND total_laid_off IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT
    month,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER(
        ORDER BY month
    ) AS rolling_total
FROM monthly_layoffs
ORDER BY month;

-- The cumulative total reached 383,159 layoffs by March 2023.
-- This matches the sum of the annual totals, confirming consistency between
-- the monthly and yearly aggregations.


-- ============================================
-- 9. Top Companies by Year
-- ============================================

WITH company_year AS
(
    SELECT
        company,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
      AND total_laid_off IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
company_year_rank AS
(
    SELECT *,
        DENSE_RANK() OVER(
            PARTITION BY year
            ORDER BY total_layoffs DESC
        ) AS ranking
    FROM company_year
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5
ORDER BY year, ranking, company;

-- The company with the highest total layoffs changed each year:
-- Uber led in 2020, ByteDance in 2021, Meta in 2022, and Google in 2023.
-- The 2023 data is partial and extends only through March 6.


-- ============================================
-- 10. Layoffs by Company Stage
-- ============================================

SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE stage IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_layoffs DESC;

-- Post-IPO companies accounted for the highest total layoffs by company stage.
-- "Unknown" ranked second, followed by Acquired, Series C, and Series D.


-- ============================================
-- 11. Companies Reporting 100% Layoffs
-- ============================================

SELECT
    company,
    industry,
    percentage_laid_off,
    funds_raised_millions,
    `date`
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY
    funds_raised_millions IS NULL,
    funds_raised_millions DESC;

-- Among companies reporting 100% layoffs, Britishvolt had the highest reported
-- funding amount at $2.4 billion, followed by Quibi, Deliveroo Australia,
-- Katerra, and BlockFi. The five companies represented different industries.


-- ============================================
-- 12. Validate the Funding Metric
-- ============================================

-- Check whether funding values repeat across multiple layoff records.
SELECT
    company,
    COUNT(*) AS layoff_records,
    COUNT(DISTINCT funds_raised_millions) AS distinct_funding_values,
    MIN(funds_raised_millions) AS min_funding,
    MAX(funds_raised_millions) AS max_funding,
    SUM(funds_raised_millions) AS summed_funding
FROM layoffs_staging2
WHERE company IN ('Netflix', 'Meta', 'Uber', 'WeWork', 'Twitter')
GROUP BY company;

-- Inspect WeWork because its reported funding value changed over time.
SELECT
    company,
    `date`,
    total_laid_off,
    funds_raised_millions
FROM layoffs_staging2
WHERE company = 'WeWork'
ORDER BY `date`;

-- Funding values are cumulative company-level figures that may repeat across
-- multiple layoff records. MAX() is therefore used instead of SUM() below to
-- avoid double counting repeated cumulative values.


-- ============================================
-- 13. Highly Funded Companies and Layoffs
-- ============================================

SELECT
    company,
    MAX(funds_raised_millions) AS max_reported_funding_millions,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY company
ORDER BY max_reported_funding_millions DESC
LIMIT 10;

-- Netflix, Meta, Uber, WeWork, and Twitter had the highest reported funding
-- amounts among companies in the dataset. Their layoff totals varied widely,
-- so this simple comparison does not show an obvious relationship between
-- higher reported funding and the number of employees laid off.


-- ============================================
-- 14. Original Analysis: Industries Driving the Late-2022 / Early-2023 Surge
-- ============================================

SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE `date` BETWEEN '2022-10-01' AND '2023-02-28'
  AND industry IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC;

-- During the elevated layoff period from October 2022 through February 2023,
-- Consumer had the highest total layoffs with 32,253, followed by Other,
-- Retail, Healthcare, and Hardware.
-- Healthcare and Hardware ranked in the top five during this surge even though
-- they were not among the top five industries across the full dataset.


-- ============================================
-- 15. Original Analysis: Industry Increases From 2021 to 2022
-- ============================================

WITH industry_year_comparison AS
(
    SELECT
        industry,
        SUM(
            CASE
                WHEN YEAR(`date`) = 2021 THEN total_laid_off
                ELSE 0
            END
        ) AS layoffs_2021,
        SUM(
            CASE
                WHEN YEAR(`date`) = 2022 THEN total_laid_off
                ELSE 0
            END
        ) AS layoffs_2022
    FROM layoffs_staging2
    WHERE industry IS NOT NULL
      AND total_laid_off IS NOT NULL
    GROUP BY industry
)
SELECT
    industry,
    layoffs_2021,
    layoffs_2022,
    layoffs_2022 - layoffs_2021 AS increase_in_layoffs
FROM industry_year_comparison
ORDER BY increase_in_layoffs DESC;

-- Retail experienced the largest increase in reported layoffs from 2021 to
-- 2022, increasing by 19,826, followed by Consumer, Healthcare,
-- Transportation, and Finance.
-- Healthcare and Finance had no layoffs recorded in the cleaned dataset for
-- 2021 but recorded substantial layoffs in 2022.
-- This supports the drastic increase in layoffs at 15,823 in 2021 to 160,661 in 2022. 

