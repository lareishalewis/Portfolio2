-- ============================================
-- SQL Layoffs Data Cleaning Project
-- Guided project based on Alex The Analyst
-- Revisited and expanded with additional validation
-- ============================================

USE world_layoffs_portfolio;

-- ============================================
-- 1. Create and Validate a Staging Table
-- ============================================

-- Create a working copy so the raw table remains unchanged.
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Validate that the raw and staging tables contain the same number of rows.
SELECT COUNT(*) AS raw_row_count
FROM layoffs;

SELECT COUNT(*) AS staging_row_count
FROM layoffs_staging;


-- ============================================
-- 2. Identify Duplicate Records
-- ============================================

WITH duplicate_cte AS
(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Five duplicate rows were identified in the full 2,361-row dataset.


-- ============================================
-- 3. Remove Duplicate Records
-- ============================================

-- Create a second staging table so row_num can be stored and used for deletion.
DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

ALTER TABLE layoffs_staging2
ADD COLUMN row_num INT;

INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Validate row count and duplicate rows before deletion.
SELECT COUNT(*) AS staging2_row_count
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Validate duplicate removal.
SELECT COUNT(*) AS rows_after_duplicate_removal
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ============================================
-- 4. Standardize Text Values
-- ============================================

-- Remove leading and trailing spaces from company names.
SELECT company, TRIM(company) AS trimmed_company
FROM layoffs_staging2
WHERE company <> TRIM(company);

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Validate company-name standardization.
SELECT company
FROM layoffs_staging2
WHERE company <> TRIM(company);

-- Standardize Crypto industry labels.
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Remove the trailing period from United States country values.
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';


-- ============================================
-- 5. Convert the Date Column
-- ============================================

-- Check for non-null dates that cannot be converted from MM/DD/YYYY.
SELECT `date`
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND STR_TO_DATE(`date`, '%m/%d/%Y') IS NULL;

-- Convert date strings and change the column to the DATE data type.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Validate the converted date range.
SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM layoffs_staging2;


-- ============================================
-- 6. Handle Missing Values
-- ============================================

-- Standardize blank industry values as NULL.
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR TRIM(industry) = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Use another record for the same company to fill recoverable missing industries.
SELECT DISTINCT
    t1.company,
    t1.industry AS missing_industry,
    t2.industry AS matching_industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Validate remaining missing industry values.
SELECT company, industry
FROM layoffs_staging2
WHERE industry IS NULL;

-- Bally's Interactive remains NULL because the dataset does not provide
-- another record with a known industry for that company.


-- ============================================
-- 7. Remove Rows Without a Layoff Measure
-- ============================================

-- Rows with neither a total layoff count nor a layoff percentage cannot
-- contribute a measurable layoff amount to this analysis.
SELECT COUNT(*) AS rows_without_layoff_data
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Validate removal.
SELECT COUNT(*) AS rows_after_null_removal
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ============================================
-- 8. Final Cleanup and Validation
-- ============================================

-- row_num was created only for duplicate removal and is no longer needed.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Confirm the final table structure.
DESCRIBE layoffs_staging2;

-- Final cleaned row count.
SELECT COUNT(*) AS final_row_count
FROM layoffs_staging2;

-- Recheck for duplicate records.
WITH duplicate_check AS
(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging2
)
SELECT *
FROM duplicate_check
WHERE row_num > 1;

-- Confirm standardized industry and country values.
SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- Confirm the final date range.
SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- Final cleaning results:
-- 2,361 raw rows imported and validated.
-- 5 duplicate rows removed.
-- 361 rows with neither total_laid_off nor percentage_laid_off removed.
-- 1,995 cleaned rows remained for exploratory analysis.
-- Final date range: 2020-03-11 through 2023-03-06.
