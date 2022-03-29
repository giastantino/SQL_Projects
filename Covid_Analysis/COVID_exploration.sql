
-- Select Data that we are going to be using
SELECT location
	,	date
	,	total_cases
	,	new_cases
	,	total_deaths
	,	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location
	,	date
	,	total_deaths
	,	total_cases
	,	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;


-- Looking at total cases vs the population
-- shows what percentage of population got covid

SELECT location
	,	date
	,	population
	,	total_cases
	,	(total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%poland%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT Location
	,	Population
	,	MAX(total_cases) as HighestInfectionCount
	,	(MAX(total_cases)/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Population > 10000000
GROUP BY Location, Population
ORDER BY 4 DESC;


-- Showing Countries with Highest Death Count per Population
SELECT Location
	,	MAX(Total_Deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent != '' 
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count per population
SELECT continent   -- select location ... where continent = '' and location like '%income%'
	,	MAX(Total_Deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent != '' 
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS

SELECT	date
	,	SUM(new_cases) as dail_cases
	,	SUM(new_deaths) as daily_deaths
	,	(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
GROUP BY date
ORDER BY 1, 2;



-- Looking at total population vs vaccinations


-- use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
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
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- temp table
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

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
ORDER BY 2, 3;


-- VIEWS --
-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
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
WHERE dea.continent != '';


SELECT *
FROM PercentPopulationVaccinated

