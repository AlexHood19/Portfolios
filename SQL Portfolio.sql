SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
-- BY 3,4

--Data Used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2

-- Total Cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Kingdom%'
and  continent is not null 
ORDER BY 1, 2

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_deaths/population)*100 AS PopulationCases
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Kingdom%'
ORDER BY 1, 2

-- Infection Rates

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 AS PopulationCases
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Kingdom%'
GROUP BY location, population
ORDER BY PopulationCases desc

-- Countries with highest death count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%Kingdom%'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc

-- Differences in Continents

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Kingdom%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Kingdom%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Kingdom%'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac

-- Temp Table
DROP TABLE if exists  #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
DATE datetime,
Population numeric, 
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view for visualisation 

Create View  PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
