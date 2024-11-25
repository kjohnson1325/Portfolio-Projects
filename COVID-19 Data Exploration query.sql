/*

Covid 19 Data Exploration 

Skills Used: Load data into MYSQL, Query from Local Database, Aggregate Functions, Converting Data Types, Modify Tables, Joins, CTE's, Windows Functions, Creating Views

*/

-- Created coviddeaths table using wizard and deleted contents but kept headers using "DELETE FROM table_name;"
-- This query below inserts data from CovidDeaths.csv file into coviddeaths table in portfolioproject SCHEMA, then does that same process for covidvaccinations

Delete From portfolioproject.coviddeaths;

LOAD DATA LOCAL INFILE 'C:/Users/kjohn/Downloads/CovidDeaths.csv'
INTO TABLE portfolioproject.coviddeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT * FROM portfolioproject.coviddeaths;

Delete From portfolioproject.covidvaccinations;

LOAD DATA LOCAL INFILE 'C:/Users/kjohn/OneDrive/Data Analysis/Covid Project/Covid Vaccinations.csv'
INTO TABLE portfolioproject.covidvaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT * FROM portfolioproject.covidvaccinations;

-- Convert date column from text to date format in both tables

UPDATE CovidDeaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');
ALTER TABLE CovidDeaths
MODIFY COLUMN date date;

UPDATE CovidVaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');
ALTER TABLE CovidVaccinations
MODIFY COLUMN date date;


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE location like '%states%'
AND continent is not null 
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with COVID

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinations
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP VIEW IF EXISTS PercentPopulationVaccinated;
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent char(255),
Location char(255),
Date date,
Population numeric,
New_vaccinations char(255),
RollingPeopleVaccinated char(255)
)
;
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,char)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;

