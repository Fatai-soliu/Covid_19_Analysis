

-- Select data to view columns
SELECT * FROM CovidDeath cd;

-- Select specific columns
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeath cd 
order by 1,2;

-- Select Total cases vs Total death and % of death to cases
-- Shows the chance of dying if you contract Covid at a particular time in your country

select Location, date, total_cases, total_deaths, ROUND((1.0 * total_deaths/total_cases),4)*100 AS 'death %'
FROM CovidDeath cd
WHERE location like '%Nigeria%'
order by 1,2;

-- Look at total cases by population
-- First case of COVID in Nigeria was Feb 29,2020
SELECT Location, date, total_cases, population, ROUND((1.0*total_cases/population),4)*100 AS 'transmission %'
FROM CovidDeath cd 
WHERE location like '%Nigeria%';

-- Looking at Countries with Highest transmission rate compared to Population

SELECT Location, MAX(CAST(total_cases AS INT)) AS Highestcases, population, ROUND(MAX((1.0*total_cases/population))*100,2) AS 'transmissionrate'
FROM CovidDeath cd
GROUP BY Location, population 
ORDER BY transmissionrate DESC;

-- Looking at countries with most death rate 

SELECT Location, MAX(CAST(total_deaths AS INT)) AS Deathcount, total_cases, ROUND(MAX((1.0*total_cases/total_deaths)),2) AS 'Deathrate'
FROM CovidDeath cd
WHERE continent <> ''
GROUP BY Location
ORDER BY Deathcount DESC;

-- Looking at continent with Maximum death rate

SELECT continent,MAX(CAST(total_deaths AS INT)) AS Deathcount 
FROM CovidDeath cd
WHERE continent <> ''
AND continent is not NULL 
GROUP BY continent
ORDER BY Deathcount DESC;

- Showing the continents with the Highest deathcount

SELECT continent,Location,MAX(CAST(total_deaths AS INT)) AS Deathcount 
FROM CovidDeath cd
WHERE continent <> ''
AND continent is not null
GROUP BY continent
ORDER BY Deathcount DESC;


-- Creating View to plugged into Tableau
-- Que: How do I visualise this?

-- Global Numbers (by day)

Select date, IFNULL(SUM(total_cases), 0) AS Total_cases_, SUM(total_deaths) AS Total_death, SUM(total_deaths)/SUM(total_cases)*100 AS 'DeathPercentage'
FROM CovidDeath cd
WHERE continent <> ''
AND continent is not NULL
GROUP BY date
ORDER BY 1,2;

-- Global Numbers (ALL)
Select IFNULL(SUM(total_cases), 0) AS Total_cases_, SUM(total_deaths) AS Total_death, SUM(total_deaths)/SUM(total_cases)*100 AS 'DeathPercentage'
FROM CovidDeath cd
WHERE continent <> ''
AND continent is not NULL
--GROUP BY date
ORDER BY 1,2;

-- Let's look at the Vaccination dataset

--CTE (Common table expression to get)

-- Fix Date
SELECT date, CAST(date AS VARCHAR(8)) AS 'converteddate'
FROM CovidDeath cd;

--CAST ( expression AS data_type [ ( length ) ] )  


WITH PopvsVac (continent, location, date,population,new_vaccinations,total_vaccinations, Rollingpeoplevaccinated)
AS
(
SELECT cd2.continent, cd2.location, cd2.date, cd2.population,cv.new_vaccinations, cv.total_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd2.location order by cd2.location,CAST(cd2.date AS ) AS 'Rollingpeoplevaccinated'
FROM CovidDeath cd2 
JOIN CovidVaccinations cv
	ON cd2.location = cv.location 
	AND cd2.date = cv.date
where cd2.continent <> ''
AND cd2.continent is not null
--AND cd2.location = 'United States'
order by 2 
)
SELECT *,ROUND((Rollingpeoplevaccinated/population),3)*100 AS 'peoplevaccinated %'

FROM PopvsVac;

-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric,
)
Insert into
SELECT cd2.continent, cd2.location, cd2.date, cd2.population,cv.new_vaccinations, cv.total_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd2.location order by cd2.location, cd2.date) AS 'Rollingpeoplevaccinated'
FROM CovidDeath cd2 
JOIN CovidVaccinations cv
	ON cd2.location = cv.location 
	AND cd2.date = cv.date
where cd2.continent <> ''
AND cd2.continent is not null
--order by 2

SELECT *,(Rollingpeoplevacinnated/population)

FROM #PercentPopulationVaccinated;
 

-- Creating View to be connected to Tableau

Create View Percentpopulationvacccinated as

SELECT cd2.continent, cd2.location, cd2.date, cd2.population,cv.new_vaccinations, cv.total_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd2.location order by cd2.location, cd2.date) AS 'Rollingpeoplevaccinated'
FROM CovidDeath cd2 
JOIN CovidVaccinations cv
	ON cd2.location = cv.location 
	AND cd2.date = cv.date
where cd2.continent <> ''
AND cd2.continent is not null
--order by 2 

DROP VIEW Fact 
Create View Fact as

SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,cv.total_vaccinations,  
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS 'Rollingpeoplevaccinated'
FROM CovidDeath cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent <> ''
AND cd.continent is not null;

--Select VIEWS 
SELECT * FROM Percentpopulationvacccinated p; 
SELECT * FROM Fact f; 






