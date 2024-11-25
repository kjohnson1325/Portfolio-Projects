/*

Covid 19 Tableau Tables Query

*/


-- TABLE 1. GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;


-- TABLE 2. Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- TABLE 3. Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;


-- Table 4. 

SELECT Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc;

