SELECT *
FROM AwatefProject..DEATHS
where continent is not null 
ORDER BY location,date;
--the continent is not null to excute the continnent data 
--SELECT *
--FROM AwatefProject..Vaccine
--ORDER BY 3,4
--select data that we are going to be using 
select location,date,total_cases ,new_cases,total_deaths,POPULATION 
FROM AwatefProject..DEATHS
ORDER BY 1,2 ;
  
--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--shows the likelihood of dying if you contract covid in your country 
select location,date,total_cases ,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM AwatefProject..DEATHS
WHERE location LIKE '%israel%'
--for example 
ORDER BY 1,2 ;


-- looking at the total cases vs population
--shows what percentage of population got covid
select location,date,total_cases ,population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM AwatefProject..DEATHS
WHERE location LIKE '%israel%'
--for example 
ORDER BY 1,2 ;

--finding the countries with the highest InfectionRate compared to Population 
 select location,population, max(total_cases ) as HighetInfectionCount,max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS Covidpercentage
FROM AwatefProject..DEATHS
group by location,population 
ORDER BY Covidpercentage desc SELECT *
FROM AwatefProject..DEATHS
ORDER BY location,date

--SELECT *
--FROM AwatefProject..Vaccine
--ORDER BY 3,4
--select data that we are going to be using 
select location,date,total_cases ,new_cases,total_deaths,POPULATION 
FROM AwatefProject..DEATHS
ORDER BY 1,2 
  
--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--shows the likelihood of dying if you contract covid in your country 
select location,date,total_cases ,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM AwatefProject..DEATHS
WHERE location LIKE '%israel%'
--for example 
ORDER BY 1,2 


-- looking at the total cases vs population
--shows what percentage of population got covid
select location,date,total_cases ,population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM AwatefProject..DEATHS
WHERE location LIKE '%israel%'
--for example 
ORDER BY 1,2 ;

--finding the countries with the highest InfectionRate compared to Population 
 select location,population, max(total_cases ) as HighetInfectionCount,max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS Covidpercentage
FROM AwatefProject..DEATHS
group by location,population 
ORDER BY Covidpercentage DESC ;


--showing countries with highest per population
 select location,max(cast(total_deaths as int)) as TotalDeathCount
 from AwatefProject..DEATHS
 where continent is not null
group by location 
ORDER BY TotalDeathCount ;
 



 --lets break things down by contint 
 --showing contintents with the highest  death count per population 
 
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM AwatefProject..DEATHS
WHERE continent IS NULL 
  AND location NOT IN ('High-income countries', 'Low-income countries', 'Upper-middle-income countries', 'Lower-middle-income countries')
GROUP BY location
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From AwatefProject..DEATHS
where continent is not null 
    
--the alias make it easir to tybe the name  in join 

select *
from AwatefProject..DEATHS DE join
 AwatefProject..VACCINE VA on de.location=va.location and de.date=va.date


---looking at total populatin vs vaccinations 
----we need to spcify any coulmn that appears in both 
-- OVER (PARTITION BY de.location): Calculates the running total of vaccinations for each location separately.
-- SUM function operates over the partitioned data without collapsing the rows.
--
SELECT 
    de.continent, 
    de.location, 
    de.date, 
    de.population, 
    va.new_vaccinations,
    SUM(CONVERT(bigint, va.new_vaccinations)) 
    OVER (PARTITION BY de.location ORDER BY de.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
    AwatefProject..Deaths de
JOIN 
    AwatefProject..VACCINE va
    ON de.location = va.location AND de.date = va.date
WHERE 
    de.continent IS NOT NULL 
ORDER BY 
    de.location, de.date;


--use CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    de.continent, 
    de.location, 
    de.date, 
    de.population, 
    va.new_vaccinations,
    SUM(CONVERT(bigint, va.new_vaccinations)) 
    OVER (PARTITION BY de.location ORDER BY de.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
    AwatefProject..Deaths de
JOIN 
    AwatefProject..VACCINE va
    ON de.location = va.location AND de.date = va.date
WHERE 
    de.continent IS NOT NULL 
ORDER BY 
    de.location, de.date

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table 
-- Drop the temp table if it exists
drop table if exists #percentpopulationVaccinated
-- Step 1: Create the table
CREATE TABLE #percentpopulationVaccinated 
(
    Continent nvarchar(255), 
    Location nvarchar(255), 
    Date datetime, 
    Population numeric, 
    New_Vaccinations numeric, 
    RollingPeopleVaccinated numeric,
    Percentage numeric
);

-- Step 2: Insert data into the table
INSERT INTO #percentpopulationVaccinated 
SELECT 
    de.continent, 
    de.location, 
    de.date, 
    de.population, 
    va.new_vaccinations,
    SUM(CONVERT(bigint, va.new_vaccinations)) 
    OVER (PARTITION BY de.location ORDER BY de.date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(bigint, va.new_vaccinations)) 
    OVER (PARTITION BY de.location ORDER BY de.date) / de.population) * 100 AS Percentage
FROM 
    AwatefProject..Deaths de
JOIN 
    AwatefProject..VACCINE va
    ON de.location = va.location AND de.date = va.date
WHERE 
    de.continent IS NOT NULL 
ORDER BY 
    de.location, de.date;

-- Step 3: Query the table
SELECT *
FROM #percentpopulationVaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From AwatefProject..Deaths de
Join AwatefProject..VACCINE va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null ;
--Countries with Lowest Death Rate:
CREATE VIEW LowestDeathRate AS
SELECT 
    location, 
    MAX(total_cases) AS TotalCases, 
    MAX(total_deaths) AS TotalDeaths,
    (MAX(CAST(total_deaths AS float)) / NULLIF(MAX(CAST(total_cases AS float)), 0)) * 100 AS DeathRate
FROM AwatefProject..DEATHS
WHERE continent IS NOT NULL
GROUP BY location;


--CREATE VIEW IncreasingCaseTrends AS
WITH DailyIncrease AS (
    SELECT 
        location, 
        date, 
        new_cases,
        LAG(new_cases) OVER (PARTITION BY location ORDER BY date) AS PreviousDayCases
    FROM AwatefProject..DEATHS
    WHERE continent IS NOT NULL
)
SELECT 
    location, 
    COUNT(*) AS DaysWithIncrease
FROM DailyIncrease
WHERE new_cases > PreviousDayCases
GROUP BY location
HAVING COUNT(*) > 0
ORDER BY DaysWithIncrease DESC;

--Monthly Summary of COVID Impact
GO

CREATE VIEW MonthlyCovidSummary AS
SELECT 
    de.location, 
    FORMAT(CAST(de.date AS datetime), 'yyyyMM') AS Month,  -- Cast 'date' to datetime
    SUM(CONVERT(bigint, de.new_cases)) AS MonthlyCases,    -- Convert 'new_cases' to bigint
    SUM(CONVERT(bigint, de.new_deaths)) AS MonthlyDeaths,  -- Convert 'new_deaths' to bigint
    SUM(CONVERT(bigint, va.new_vaccinations)) AS MonthlyVaccinations  -- Convert 'new_vaccinations' to bigint
FROM AwatefProject..DEATHS de
JOIN AwatefProject..VACCINE va ON de.location = va.location AND CAST(de.date AS datetime) = CAST(va.date AS datetime)
WHERE de.continent IS NOT NULL
GROUP BY de.location, FORMAT(CAST(de.date AS datetime), 'yyyyMM');

GO



