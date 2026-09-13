# SQL Layoffs Data Cleaning & Exploratory Analysis

## Project Overview

This project explores global company layoff data using MySQL. The project began as a guided SQL exercise based on Alex The Analyst’s data-cleaning tutorial and was later revisited, corrected, expanded, and documented as part of strengthening my SQL and data-analysis skills.

The completed workflow includes raw data validation, duplicate removal, data standardization, missing-value handling, date conversion, exploratory analysis, window functions, ranking, conditional aggregation, and additional original analysis.

## Tools

- MySQL
- MySQL Workbench
- SQL
- GitHub

## Dataset

The dataset contains company layoff records from March 2020 through March 2023, including:

- Company
- Location
- Industry
- Total employees laid off
- Percentage laid off
- Date
- Company stage
- Country
- Funds raised

## Data Import & Validation

During the project refresh, I discovered that my original MySQL import contained only 564 records even though the source CSV contained 2,361 records.

To resolve the issue, I:

1. Compared row counts between the source data and MySQL tables.
2. Created a new project database.
3. Reloaded the complete CSV using `LOAD DATA LOCAL INFILE`.
4. Confirmed that all 2,361 records loaded successfully with no skipped records.
5. Created a staging table and verified that the raw and staging tables contained matching row counts before beginning the cleaning process.

This validation step was important because the incomplete import produced different analytical results than the complete dataset.

## Data Cleaning

The cleaning process included:

- Creating staging tables to preserve the raw dataset
- Identifying duplicate records using `ROW_NUMBER()`
- Removing 5 duplicate records
- Trimming unnecessary spaces from company names
- Standardizing inconsistent industry values
- Standardizing country names
- Converting the date column from text to a SQL `DATE` datatype
- Converting blank industry values to `NULL`
- Using a self-join to recover missing industry values when another record for the same company contained the information
- Removing 361 records where both total layoffs and percentage laid off were missing
- Performing final validation checks for duplicates, standardized values, row counts, and date range

The final cleaned dataset contained **1,995 records**.

## Exploratory Data Analysis

The analysis examined questions such as:

- Which companies had the largest individual layoff events?
- Which companies had the highest total layoffs across multiple events?
- Which industries and countries experienced the most layoffs?
- How did layoffs change by year and month?
- Which months experienced the largest spikes in layoffs?
- How did cumulative layoffs grow over time?
- Which companies had the most layoffs each year?
- Which company stages accounted for the most layoffs?
- Which companies reported laying off 100% of their workforce?
- How did reported funding levels compare with company layoff totals?

## Funding Data Validation

While analyzing company funding, I found that `funds_raised_millions` often represented a cumulative company-level value that repeated across multiple layoff records.

Using `SUM(funds_raised_millions)` would therefore double-count funding for companies appearing multiple times.

I compared the number of layoff records, distinct funding values, minimum funding, maximum funding, and summed funding for several companies. I also reviewed WeWork’s funding values over time and found that the reported amount increased cumulatively.

Based on that validation, I used MAX(funds_raised_millions) instead of SUM() when comparing company funding levels.

## Additional Analysis

To expand the original guided project, I added additional questions based on patterns identified during the analysis.

## Industries during the late-2022 / early-2023 layoff surge

After observing elevated layoffs from October 2022 through February 2023, I analyzed which industries contributed most to that period.

The highest totals were:

Consumer — 32,253
Other — 29,717
Retail — 26,019
Healthcare — 16,752
Hardware — 13,828

Healthcare and Hardware entered the top five during this period even though they were not among the top five industries across the complete dataset.

## Industry changes from 2021 to 2022

I used conditional aggregation with CASE statements to compare industry layoffs between 2021 and 2022.

The largest increases were:

Retail — +19,826
Consumer — +16,256
Healthcare — +15,058
Transportation — +15,027
Finance — +12,684

This helped identify which industries contributed most to the sharp increase in layoffs between the two years.

## Key Findings

Amazon had the highest total layoffs across all reported events.
Google had the largest single reported layoff event with 12,000 employees.
Consumer had the highest total layoffs by industry.
The United States had the highest total layoffs by country.
Among complete years, 2022 had the highest total layoffs with 160,661.
January 2023 had the highest monthly layoffs with 84,714.
Cumulative layoffs reached 383,159 by March 2023.
The company with the highest annual layoffs changed each year:
2020 — Uber
2021 — ByteDance
2022 — Meta
2023 — Google through March 6
Post-IPO companies accounted for the highest total layoffs by company stage.

## Project Files

layoffs_data_cleaning.sql — data import validation, cleaning, transformation, and quality checks
layoffs_eda.sql — exploratory analysis, rankings, trends, funding validation, and additional analysis

## Acknowledgment

This project was originally completed as a guided SQL portfolio exercise based on an Alex The Analyst tutorial. I later revisited the project to refresh my SQL skills, correct the dataset import, strengthen the cleaning and validation process, improve the analysis, document my reasoning, and add original analytical questions.
