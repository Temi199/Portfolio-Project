`SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Retrieving Useful Data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

ALTER TABLE CovidDeaths ALTER COLUMN total_cases FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT

 --Looking at Total cases VS Total deaths in Nigeria
 --shows the likelihood of dying once you get the virus

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

--Looking at the Total cases VS Population in Nigereia
--shows the percentage of the population that has contracted the virus in Nigeria

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagepopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

--Looking at the country with the highest infection rate compared to population

 SELECT location, population, MAX(total_cases) AS HigestInfectionCount, MAX(total_cases/population)*100 AS PercentagepopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagepopulationInfected DESC

--Showing countries with the highest death count per population
 
 SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing the continent with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Looking at the continent with the highest infection rate compared to population

 SELECT continent, population, MAX(total_cases) AS HigestInfectionCount, MAX(total_cases/population)*100 AS PercentageInfectionrate
FROM PortfolioProject..CovidDeaths
GROUP BY continent, population
ORDER BY PercentageInfectionrate DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Totalcases, SUM(new_deaths) AS Totaldeaths, (SUM(new_cases)/SUM (new_deaths))* 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total population VS Vaccinations

--USE CTE

With PopVSVac (Continent, Location,Date,Population, New_vaccinationa, Rollingpeoplevaccinated)
as
(
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
AND dea.date = vac.date
--ORDER BY 2,3
)
SELECT *, (Rollingpeoplevaccinated/Population)*100 AS PercentageVaccinated
FROM PopVSVac



---TEMP TABLES

DROP TABLE IF EXISTS #PercentageVaccinated
CREATE TABLE #PercentageVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentageVaccinated

SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
AND dea.date = vac.date
--ORDER BY 2,3

SELECT *, (Rollingpeoplevaccinated/Population)*100 AS PercentageVaccinated
FROM #PercentageVaccinated


--Creating Views to store data for later visualizations

CREATE VIEW PercentageVaccinated AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
AND dea.date = vac.date
--ORDER BY 2,3


CREATE VIEW ContinentTotaLDeathCount AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


CREATE VIEW TotaldeathcountCountry AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC
