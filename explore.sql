-- *************************************************************
-- Data Exploration Script for Cleaned Layoff Data
-- This script performs a series of queries to analyze the cleaned
-- layoffs dataset stored in the 'layoff_tempo' table.
-- *************************************************************

-- Display all records from the cleaned dataset
select * from layoff_tempo;

-- -------------------------------------------------------------
-- Analysis 1: Top 10 Company & Stage Combinations
-- -------------------------------------------------------------
-- Aggregate the total number of employees laid off by 'company' and 'stage'
-- and display the top 10 combinations ordered by highest layoffs.
select stage ,company ,sum(total_laid_off) employee_laid from layoff_tempo 
group by company , stage order by employee_laid desc
limit 10;

-- -------------------------------------------------------------
-- Analysis 2: Total Layoffs by Industry
-- -------------------------------------------------------------
-- Sum the total layoffs per industry and display them in descending order.
select industry , sum(total_laid_off) laid from layoff_tempo group by industry order by laid desc;

-- -------------------------------------------------------------
-- Analysis 3: Yearly Layoff Trends
-- -------------------------------------------------------------
-- Calculate the total number of layoffs per year by extracting the year from the 'date' field.
select Year(`date`) `year`, sum(total_laid_off) laid from layoff_tempo where Year(`date`) is not null  group by Year(`date`) order by Year(`date`);

-- -------------------------------------------------------------
-- Analysis 4: Extreme Layoffs in High-Funded Companies
-- -------------------------------------------------------------
-- Identify companies (labeled as 'bankrupt_company') that raised significant funds 
-- and had nearly 100% of their workforce laid off, labeling those layoffs appropriately.
select company as bankrupt_company  ,`date` ,funds_raised_millions, industry,
 case when percentage_laid_off =1 then 'All employees' end as laid 
 from layoff_temp where funds_raised_millions > 999 and percentage_laid_off >0.99 order by `date`;

-- -------------------------------------------------------------
-- Analysis 5: Top Layoff-Causing Companies per Country and country wise layoffs
-- -------------------------------------------------------------
-- For each country, sum the total layoffs and identify the company with the highest layoffs 
-- using a subquery, displaying the top 10 countries by total layoffs.
SELECT country , SUM(total_laid_off) AS total ,
        (SELECT b.company FROM layoff_tempo b
        WHERE b.country = a.country
        ORDER BY b.total_laid_off DESC LIMIT 1 ) AS top_layers
FROM layoff_tempo a
GROUP BY country ORDER BY total DESC LIMIT 10;

-- -------------------------------------------------------------
-- Analysis 6: Time Series Analysis with Rolling Sum and Percentage Change
-- -------------------------------------------------------------
-- Calculate monthly layoffs and compute a rolling sum. Then, calculate the percentage change 
-- compared to the previous month using window functions.
with ct as(
 select substring(`date`,1,7) `time`, sum(total_laid_off) laid
from layoff_tempo where substring(`date`,1,7) is not null group by `time` order by `time`)
,ct2 as(
select `time` , laid , sum(laid) over(order by substring(`time`,1,7)) rolling_sum
from ct)
,ct3 as (
select `time` ,  laid , rolling_sum , lag(rolling_sum) over() as`prev`
from ct2)
select `time` ,  laid , rolling_sum , concat(round( ((rolling_sum -`prev`)/`prev`)*100,1),' %')
from ct3 ;

-- -------------------------------------------------------------
-- Analysis 7: Top 3 Companies by Layoffs per Year
-- -------------------------------------------------------------
-- Using window functions, rank companies based on the total layoffs per year and extract 
-- the top 3 companies (dense_rank < 4) for each year.
with ct as (select  company, year(`date`) yr , sum(total_laid_off) laid
from layoff_tempo group by company,yr order by laid desc)
, ct2 as (select *, dense_rank() over(partition by yr order by laid desc) rnk 
from ct where yr is not null)
select * from ct2 where rnk <4;
