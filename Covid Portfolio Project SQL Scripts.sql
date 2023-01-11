SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%High%'
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PERCENTAGE_DEATHS
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--TOTAL CASES VS POPULATION

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PERCENTAGE_INFECTED
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HIGHEST_INFECTION_COUNT, MAX((total_cases/population))*100 AS PERCENTAGE_POPULATION_INFECTED
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
GROUP BY location, population
ORDER BY PERCENTAGE_POPULATION_INFECTED DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATH_COUNT
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TOTAL_DEATH_COUNT DESC

--BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATH_COUNT
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TOTAL_DEATH_COUNT DESC

--GLOBAL NUMBERS
SELECT  SUM(new_cases) AS NEW_CASES_PER_DAY, SUM(CAST(new_deaths AS INT)) AS NEW_DEATHS_PER_DAY, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY DEATH_PERCENTAGE

SELECT * 
FROM PortfolioProject..CovidDeaths

--TOTAL POPULATION VS VACCINATIONS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint) ) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION, CD.DATE)	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint) ) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION, CD.DATE)	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3 
)
Select * , (RollingPeopleVaccinated/Population) as PercVaccinated
FROM PopVsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint) ) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION, CD.DATE)	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
--WHERE CD.continent IS NOT NULL
--ORDER BY 2,3
Select * , (RollingPeopleVaccinated/Population)*100 as PercVaccinated
FROM #PercentPopulationVaccinated
--where (RollingPeopleVaccinated/Population)*100 is not null
--and New_vaccinations is not null

--Create view to store data for visualizations

Create View PercentPopulationVaccinated as

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint) ) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION, CD.DATE)	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

Select * 
from PercentPopulationVaccinated
