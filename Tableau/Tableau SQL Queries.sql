/*
Tableau Queries - Data Exploration on Covid 19
*/


DROP TABLE IF EXISTS #emerging_asia
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


-- emerging asian countries with highest infection rate
SELECT location, population, MAX(total_cases) AS total_cases,  MAX(total_cases)/MAX(population)*100 AS infection_rate
FROM #emerging_asia
GROUP BY location, population
ORDER BY infection_rate DESC;


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
SELECT location, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
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