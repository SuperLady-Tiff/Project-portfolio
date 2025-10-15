SELECT *
FROM ProjectLearning..CovidDeaths
ORDER BY 3,4 -- Order by column 3 and 4

SELECT location, date,new_vaccinations,total_vaccinations
FROM ProjectLearning..CovidVaccinations


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectLearning..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectLearning..CovidDeaths
WHERE location like '%China%'
ORDER BY 1,2

--Looking at Total cases vs. Population 
--Shows what pecentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM ProjectLearning..CovidDeaths
--WHERE location like '%China%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
FROM ProjectLearning..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectLearning..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Break things down by continent
-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectLearning..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM ProjectLearning..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT *
FROM ProjectLearning..CovidVaccinations

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectLearning..CovidDeaths dea
JOIN ProjectLearning..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE
WITH PopuVsVac (continent, location,date, population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectLearning..CovidDeaths dea
JOIN ProjectLearning..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopuVsVac


--Tamp table
DROP TABLE IF EXISTS #PercentPOpulationVaccinated
Create Table #PercentPOpulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO #PercentPOpulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectLearning..CovidDeaths dea
JOIN ProjectLearning..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPOpulationVaccinated


-- Create View to store data for later visualizations
CREATE VIEW PercentPOpulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectLearning..CovidDeaths dea
JOIN ProjectLearning..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPOpulationVaccinated