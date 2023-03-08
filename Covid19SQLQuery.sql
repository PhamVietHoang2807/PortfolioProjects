/*
Covid 19 Data Exploration 
*/

-- Select Data that I am going to start with

SELECT location
, date
, total_cases
, new_cases
, total_deaths
, population
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- The perentage of people dying if they get covid globally

SELECT location
, date
, total_cases
, total_deaths
, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- The percentage of population infected with Covid

SELECT location
, date
, Population
, total_cases
, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population (Using Aggregate Function)

SELECT location
, population
, MAX(total_cases) AS TotalInfection
, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject1.dbo.CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC;


-- Countries with the Highest number of Deaths (Converting Data Type)

SELECT Location
, MAX(CAST(total_deaths AS int)) AS TotalDeath
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath DESC;


-- Contintents with the Highest number of Deaths

SELECT continent
, MAX(CAST(total_deaths AS int)) AS TotalDeath
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC;


-- Total cases, Total deaths, and the percentage of Death across the world 

SELECT SUM(new_cases) AS total_cases
, SUM(CAST(new_deaths AS int)) AS total_deaths
, SUM(CAST(new_deaths AS int))/SUM(New_Cases) * 100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- The Number of Population that has recieved Vaccine by day (Using Window Function)

Select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS VaccinatedPeople
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- The Percentage of people vaccinated compared to the Population (Using CTE)

WITH VaccinationPer 
AS
(
Select dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS VaccinatedPeople
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *
, (VaccinatedPeople/Population)*100 AS VaccinationPercentage
FROM VaccinationPer
ORDER BY 2, 3;



-- The Percentage of people vaccinated compared to the Population (Using Temp Table)

DROP TABLE IF EXISTS #VaccinationPercentage
CREATE TABLE #VaccinationPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatedPeople numeric
)

INSERT INTO #VaccinationPercentage
SELECT dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS VaccinatedPeople
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
, (VaccinatedPeople/Population)*100 AS VaccinationPercentage
FROM #VaccinationPercentage
ORDER BY 2, 3;


-- Creating View to store data 

CREATE VIEW VaccinationRate AS
SELECT dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS VaccinatedPeople
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL