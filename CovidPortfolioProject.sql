/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Selecting Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if contracted covid

SELECT Location, date as Date, total_cases as TotalCases, total_deaths as TotalDeaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Finland%'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Percentage of population contracted covid

SELECT Location, date as Date, Population, total_cases as TotalCases, (total_cases/population)*100 as ContractedCovid
FROM PortfolioProject..CovidDeaths
WHERE location like '%Finland%'
and continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rate vs Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractedCovid
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Finland%'
GROUP BY Location, Population
ORDER BY ContractedCovid desc

-- Countries with Highest Death Count vs Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Finland%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- By Continent
-- Continents vs Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Finland%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Worldwide Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Finland%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total population vs Vaccinations

SELECT dea.continent as Continent, dea.location as Location, 
dea.date as Date, dea.population as Population, 
vac.new_vaccinations as NewVaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingVaccinated)
As 
(
SELECT dea.continent as Continent, dea.location as Location, 
dea.date as Date, dea.population as Population, 
vac.new_vaccinations as NewVaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent as Continent, dea.location as Location, 
dea.date as Date, dea.population as Population, 
vac.new_vaccinations as NewVaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent as Continent, dea.location as Location, 
dea.date as Date, dea.population as Population, 
vac.new_vaccinations as NewVaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
