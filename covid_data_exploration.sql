/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

-- Select Data that we are starting with
SELECT location
	,	date
	,	total_cases
	,	new_cases
	,	total_deaths
	,	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location
	,	date
	,	total_deaths
	,	total_cases
	,	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;


-- Total Cases vs Population
-- shows what percentage of population infected with covid

SELECT location
	,	date
	,	population
	,	total_cases
	,	(total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%poland%'
ORDER BY 1, 2;


-- Countries with highest infection rate compared to population

SELECT Location
	,	Population
	,	MAX(total_cases) as HighestInfectionCount
	,	(MAX(total_cases)/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Population > 10000000
GROUP BY Location, Population
ORDER BY 4 DESC;


-- Countries with Highest Death Count per Population

SELECT Location
	,	MAX(Total_Deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent != '' 
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

SELECT continent   -- select location ... where continent = '' and location like '%income%'
	,	MAX(Total_Deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent != '' 
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS

SELECT	date
	,	SUM(new_cases) AS dail_cases
	,	SUM(CAST(new_deaths AS INT)) AS daily_deaths
	,	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
GROUP BY date
ORDER BY 1, 2;



-- Total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2, 3
;



-- data for later visualizations

-- 1.
-- worldwide deaths, cases, death rate
SELECT SUM(new_cases) AS total_cases
	, SUM(cast(new_deaths AS int)) AS total_deaths
	, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent != '';


-- 2.
-- population, cases, deaths per continent 
SELECT Location
	, Population
	, SUM(cast(new_cases AS int)) AS TotalCasesCount
	, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = '' 
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income%'
GROUP BY location, population;
--ORDER BY TotalDeathCount DESC



-- 3.
-- population infected, deathrate per country
SELECT Location
	, Continent
	, Population
	, MAX((total_cases/population))*100 AS PercentPopulationInfected
	, (MAX(total_deaths)/MAX(total_cases))*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Continent, Population;
--ORDER BY PercentPopulationInfected DESC



-- 4.
-- new_cases per day per country 
SELECT Location
	, CAST(date as date) AS date
	, new_cases
FROM PortfolioProject..CovidDeaths
WHERE continent != '';

-- 5. 
-- people vaccinated (vaccination rate per country)
SELECT dea.continent
	, dea.location
	, CAST(dea.date AS DATE) AS date
	, dea.population
	, vac.new_vaccinations
	, vac.people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '';
