# Data Cleaning Project 

SELECT * 
FROM layoffs; 

-- 1. Remove duplicates 
-- 2. Standardize the data(correct any spelling issues or things of that nature). 
-- 3. Null Values or Blank Values 
-- 4. Remove any cols and rows that are not neccessary. (When doing this it's important to create a new table and 
-- leave the original as is)

CREATE TABLE layoffs_staging 
LIKE layoffs;


INSERT layoffs_staging
SELECT * 
FROM layoffs; 

SELECT * 
FROM layoffs_staging;


#Checking for duplicates -- if the row_num is > 1 that means their are duplicates.
WITH duplicate_CTE AS
(SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY  company, location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_CTE
WHERE row_num > 1;

#Deleting duplicates without the table having a unique identifier row.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY  company, location, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;


# Standardizing data: Finding issues within the data then fixing it. 
SELECT * 
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

#Update all of crypto to be Crypto instead of some of them saying Crypto Currency
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

#Fix United States. to United States
SELECT DISTINCT country 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

#Change the date column from a string to a date.

SELECT `date`, 
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs_staging2;

