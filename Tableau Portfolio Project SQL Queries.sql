/*
Queries used for Tableau Project
*/

--1. Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM ProjectLearning..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--2. Take these out as they are not inclued in the above queries and keep it consistent
--   European Union is part of Europe
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM ProjectLearning..CovidDeaths
WHERE continent is NULL
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3.Looking at Countries with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM ProjectLearning..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- 4.
SELECT location,population,date,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM ProjectLearning..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc