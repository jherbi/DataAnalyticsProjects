SELECT *
FROM CovidData..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM CovidData..CovidVaccinations
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData..CovidDeaths
ORDER BY 1,2


--Looking at Total cases vs Total Deaths in Poland
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 AS death_percentage
FROM CovidData..CovidDeaths
WHERE location LIKE '%Poland%'
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT location, date, Population, total_cases,(total_cases/population)*100.0 AS Percent_Population_Infected
FROM CovidData..CovidDeaths
WHERE location LIKE '%Poland%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) as HIghest_Infection_Count, MAX((total_cases/population))*100.0 AS Percent_Population_Infected
FROM CovidData..CovidDeaths
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

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100.0 AS death_percentage
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2