SELECT *
FROM CovidData..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM CovidData..CovidVaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData..CovidDeaths
ORDER BY 1,2


--Looking at Total cases vs Total Deaths in Poland
SELECT location,AVG(total_deaths/total_cases)*100.0 AS death_percentage
FROM CovidData..CovidDeaths
WHERE location LIKE '%Poland%'
GROUP BY location

SELECT AVG(total_deaths/total_cases)*100.0 AS World_death_percentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL


--Looking at Total Cases vs Population
SELECT location, date, Population, total_cases,(total_cases/population)*100.0 AS Percent_Population_Infected
FROM CovidData..CovidDeaths
WHERE location LIKE '%Poland%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) as HIghest_Infection_Count, MAX((total_cases/population))*100.0 AS Percent_Population_Infected
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY Percent_Population_Infected DESC 

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--Looking by Continent
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS group by date
SELECT cd.date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100.0 AS death_percentage --, (cv.total_vaccinations/cd.population)*100.00 AS vaccinated_population_percentage
FROM CovidData..CovidDeaths as cd
INNER JOIN CovidData..CovidVaccinations as cv
ON cd.iso_code = cv.iso_code AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location LIKE '%Poland%'
GROUP BY cd.date
ORDER BY 1,2

--Looking at total and new cases and looking for bond with number of vaccinations in Poland
SELECT cd.location, cd.date, cd.total_cases, cd.new_cases, cv.total_vaccinations, cv.new_vaccinations, cv.people_vaccinated, (people_vaccinated/ cd.population)*100.0 AS vaccinated_people_percantage
FROM CovidData..CovidDeaths AS cd
INNER JOIN CovidData..CovidVaccinations AS cv
ON cd.iso_code = cv.iso_code AND cd.date = cv.date
WHERE cd.location LIKE '%Poland%'
AND cd.continent IS NOT NULL
ORDER BY 1,2

-- Looking at total population vs Vaccinations
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100.0
FROM CovidData..CovidDeaths AS d
JOIN CovidData..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100.0
FROM CovidData..CovidDeaths AS d
JOIN CovidData..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100.0
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100.0
FROM CovidData..CovidDeaths AS d
JOIN CovidData..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100.0
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100.0
FROM CovidData..CovidDeaths AS d
JOIN CovidData..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
