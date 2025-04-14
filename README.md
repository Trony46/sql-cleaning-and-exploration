# SQL Data Cleaning and Data Exploration: Layoffs Dataset

This project demonstrates how to clean, and explore a layoffs dataset using SQL queries. The repository includes a CSV file with raw layoffs data and two SQL scripts: one for data cleaning and another for data exploration. It serves as an example project for building data pipelines and performing analysis with SQL.


## Project Overview

This project works with a layoffs dataset that includes the following fields:
- **company:** Company name.
- **location:** Geographical location.
- **industry:** Industry of the company.
- **total_laid_off:** Number of employees laid off.
- **percentage_laid_off:** Layoffs as a percentage of total workforce.
- **date:** Date of the layoff event.
- **stage:** Stage of the company at the time of layoff .
- **country:** Country where the layoff occurred.
- **funds_raised_millions:** Amount of funding raised (in millions) by company.

The project is divided into two main parts:
1. **Data Cleaning:** Standardizes dates, trims text, handles missing values, and removes duplicates.
2. **Data Exploration:** Provides queries to analyze trends over time, compare industries, and identify top layoff events and companies.
