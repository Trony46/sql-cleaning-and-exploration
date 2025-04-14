-- *************************************************************
-- Data Cleaning Script for Layoffs Dataset
-- This script creates a working table (layoff_tempo) from the original
-- layoffs table, cleans the data, standardizes formats, handles missing
-- values, and removes duplicate records.
-- *************************************************************

-- Display all records from the original layoffs table for reference
SELECT * FROM layoffs;

-- Create a new table 'layoff_tempo' with the same structure as 'layoffs'
create table layoff_tempo
like layoffs;

-- Populate 'layoff_tempo' with all data from 'layoffs'
insert into layoff_tempo select * from layoffs;

-- Convert the 'date' column from a string to a Date type:
-- First, update the 'date' values using STR_TO_DATE with the format MM/DD/YYYY,
-- then modify the column definition to 'date'
update layoff_tempo set `date`=str_to_date(`date`,'%m/%d/%Y');
alter table layoff_tempo modify `date` date;

-- Trim extra whitespace from the 'company' column to ensure consistent data
update layoff_tempo set company=trim(company);

-- -------------------------------------------------------------
-- Standardize Industry Names
-- -------------------------------------------------------------
-- List distinct industries before making any updates
select distinct industry from layoff_tempo order by industry;

-- Update industries that start with 'Crypto...' to be exactly 'Crypto'
update layoff_tempo set industry='Crypto' where industry like 'Crypto%';

-- -------------------------------------------------------------
-- Standardize Country Names
-- -------------------------------------------------------------
-- List distinct countries to check for inconsistencies
select distinct country from layoff_tempo order by country;

-- Update countries starting with 'United States...' to exactly 'United States'
update layoff_tempo set country='United States' where country like 'United States%';

-- -------------------------------------------------------------
-- Handle Missing Values in Layoff Data
-- -------------------------------------------------------------
-- Identify rows where both 'total_laid_off' and 'percentage_laid_off' are missing
select * from layoff_tempo where total_laid_off is null and percentage_laid_off is null;

-- Remove rows where both 'total_laid_off' and 'percentage_laid_off' are missing, as they are likely unusable
delete from layoff_tempo where total_laid_off is null and percentage_laid_off is null;

-- -------------------------------------------------------------
-- Resolve Inconsistencies in Industry Data
-- -------------------------------------------------------------
-- Identify companies that have conflicting industry data (one record with null and another with a value)
select distinct a.company , a.industry, b.company , b.industry
from layoff_tempo a
join layoff_tempo b
	on a.company =b.company where a.industry is null and b.industry is not null; 

-- List records with null or empty string values for industry
select * from layoff_tempo where industry is null or industry ='';

-- Standardize empty string values to NULL for the 'industry' column
update layoff_tempo set industry = null where industry = '';

-- Update records with null 'industry' by joining with records that have non-null values for the same company
update layoff_tempo a join layoff_tempo b on a.company =b.company 
set a.industry = b.industry 
where a.industry is null and b.industry is not null;

-- -------------------------------------------------------------
-- Identify and Remove Duplicate Rows
-- -------------------------------------------------------------
-- Use a common table expression (CTE) to assign a row number (tot_row) for each
-- row partitioned by all columns; this identifies duplicates (tot_row > 1)
with ct as (select *, row_number() over(partition by company, location,industry,total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) tot_row 
from layoff_tempo)
select * from ct
where tot_row >1; 

-- Add an auto-increment primary key column to help with duplicate removal
alter table layoff_tempo add column id int auto_increment primary key;

-- Use a CTE again (ordered by id) and delete records where the duplicate row number is greater than 1
with ct as (select *, row_number() over(partition by company, location,industry,total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) tot_row 
from layoff_tempo order by id)
delete a from layoff_tempo a join ct on a.id=ct.id 
where ct.tot_row >1; 

-- Remove the temporary primary key column as it is no longer required
alter table layoff_tempo drop column id;

-- Display final cleaned data from the 'layoff_tempo' table
select * from layoff_tempo;
