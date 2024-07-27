/*
Data Exploration on Covid-19 for Emerging Asian Countries
Skills Applied: Windows Functions, Aggregate Functions, Data Type Conversion, Joins, CTE's, Temp Tables, Creating Views
*/


-- check
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
ORDER BY location, date;

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- data exploration for emerging asian countries
-- created temp table for for emerging asian countries
DROP TABLE IF EXISTS #emerging_asia
-- the query above is added to execute the whole query anytime
CREATE TABLE #emerging_asia
(
	Continent NVARCHAR(300),
	Location NVARCHAR(300),
	Date DATETIME,
	Population NUMERIC,
	Total_Cases NUMERIC,
	Total_Deaths NUMERIC,
	Life_Expectancy FLOAT,
	Gdp_Per_Capita FLOAT
)
INSERT INTO #emerging_asia
SELECT continent, location, date, population, total_cases, total_deaths, life_expectancy, gdp_per_capita
FROM PortfolioProject..CovidDeaths
WHERE location IN ('China', 'India', 'Indonesia', 'Malaysia', 'Philippines', 'Thailand', 'Vietnam') 

SELECT * 
FROM #emerging_asia


-- emerging asian countries with highest infection rate
SELECT location, population, MAX(total_cases) AS total_cases,  MAX(total_cases)/MAX(population)*100 AS infection_rate
FROM #emerging_asia
GROUP BY location, population
ORDER BY infection_rate DESC;

SELECT location, date, population, MAX(total_cases) AS total_cases,  MAX(total_cases)/MAX(population)*100 AS infection_rate
FROM #emerging_asia
GROUP BY location, date, population
ORDER BY location, date;


-- death percentage of emerging asian countries if infected with covid
SELECT location, MAX(total_cases) as total_cases, MAX(total_deaths) AS total_deaths, MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
FROM #emerging_asia
GROUP BY location
ORDER BY death_percentage DESC;


-- life expectancy of emerging asian countries
SELECT location, MAX(life_expectancy) AS life_expectancy
FROM #emerging_asia
GROUP BY location
ORDER BY life_expectancy DESC;


-- gdp per capital of emerging asian countries
SELECT location, MAX(gdp_per_capita) AS GDP
FROM #emerging_asia
GROUP BY location
ORDER BY GDP DESC;


-- total death count of emerging asian countries and continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM #emerging_asia
GROUP BY location
UNION
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Europe', 'North America', 'South America', 'Asia', 'Africa', 'Oceania')
GROUP BY location
ORDER BY total_death_count DESC


-- check
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NULL
ORDER BY location, date;

SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location, date;


-- shows new tests performed per day and the total tests performed 
-- the total tests performed should show an increasing or decreasing count depending on the new tests of the previous day
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_tests, SUM(CAST(cv.new_tests AS INT)) 
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_tests
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY location, date;


-- used CTE to show the test percentage based on the population
WITH CTE_population_vs_total_tests (continent, location, date, population, new_tests, total_tests)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_tests, SUM(CAST(cv.new_tests AS INT)) 
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_tests
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
)
SELECT *, (total_tests/population)*100 AS test_percentage
FROM CTE_population_vs_total_tests
ORDER BY location, date;


-- used temp table to show the test percentage based on the population from the previous query
DROP TABLE IF EXISTS #test_rate
CREATE TABLE #test_rate
(
	Continent NVARCHAR(300),
	Location NVARCHAR(300),
	Date DATETIME,
	Population NUMERIC,
	New_tests NUMERIC,
	Total_tests NUMERIC
);

INSERT INTO #test_rate

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_tests, SUM(CAST(cv.new_tests AS INT)) 
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_tests
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 

SELECT *, (total_tests/population)*100 AS test_percentage
FROM #test_rate
ORDER BY location, date;


-- created views 
USE PortfolioProject
GO
CREATE VIEW TestRate AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_tests, SUM(CAST(cv.new_tests AS INT)) 
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_tests
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 


USE PortfolioProject
GO 
CREATE VIEW EmergingAsiaView AS
SELECT continent, location, date, population, total_cases, total_deaths, cardiovasc_death_rate, life_expectancy, gdp_per_capita
FROM PortfolioProject..CovidDeaths
WHERE location IN ('China', 'India', 'Indonesia', 'Malaysia', 'Philippines', 'Thailand', 'Vietnam') 






