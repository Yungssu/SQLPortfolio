--SELECT * FROM Portfolio..NewCovidDeaths

--SELECT * FROM Portfolio..NewCovidVaccinatios


SELECT Location, continent = 'Asia', date, total_cases, new_cases, total_deaths, population 
FROM Portfolio..NewCovidDeaths

--Total Cases vs. Total Deaths WHERE continent is 'Asia'
SELECT Location, 
		continent = 'Asia', 
		date, 
		CAST(total_cases AS float) AS total_cases, 
		CAST(total_deaths AS float) AS total_deaths, 
		(CAST(total_deaths AS float)/ NULLIF(CAST(total_cases AS float), 0)) * 100 AS Death_Percentage

FROM Portfolio..NewCovidDeaths
ORDER BY location, total_cases

--Total Cases vs. population
SELECT Location, 
		continent = 'Asia', 
		date, 
		CAST(total_cases AS float) AS total_cases,
		population,
		(CAST(total_cases AS float)/ NULLIF(population, 0)) * 100 AS Percent_Of_Population_Infected

FROM Portfolio..NewCovidDeaths
ORDER BY location, total_cases


--Countries with Highest Infection Rate compared to population
SELECT Location, 
		continent = 'Asia',  
		MAX(CAST(total_cases AS float)) AS Highest_Infection_Count,
		population,
		MAX((CAST(total_cases AS float))/ NULLIF(population, 0)) * 100 AS Percent_Of_Population_Infected

FROM Portfolio..NewCovidDeaths
GROUP BY location, population
ORDER BY Percent_Of_Population_Infected DESC

--Countries with Highest Death Count per population
SELECT location,
		MAX(CAST(total_deaths AS bigint)) AS Total_Death_Count

FROM Portfolio..NewCovidDeaths
WHERE continent = 'Asia'
GROUP BY location
ORDER BY Total_Death_Count DESC


--Daily total_new_cases_count and total_death_count
SELECT date,
		location,
		SUM(new_cases) AS total_new_cases_count,
		SUM(CAST(new_deaths as bigint)) AS total_death_count,
		 CASE 
        WHEN SUM(new_cases) = 0 THEN 0  -- Check if sum of new_cases is zero
        ELSE SUM(CAST(new_deaths as bigint))/SUM(new_cases) * 100 
    END AS Death_Percentage

FROM Portfolio..NewCovidDeaths
WHERE continent = 'Asia'
GROUP BY date, location

--Joining the tables NewCovidDeaths and NewCovidVaccinations
SELECT New_Covid_Deaths.continent, 
		New_Covid_Deaths.location, 
		New_Covid_Deaths.date, 
		New_Covid_Deaths.population, 
		New_Covid_Vacs.new_vaccinations

FROM Portfolio..NewCovidDeaths AS New_Covid_Deaths
JOIN	Portfolio..NewCovidVaccinations	AS New_Covid_Vacs

ON New_Covid_Deaths.location = New_Covid_Vacs.location
	AND
	New_Covid_Deaths.date = New_Covid_Vacs.date

WHERE New_Covid_Deaths.continent = 'Asia'

--Rolling Count for Vaccinated People per Country in Asia
SELECT New_Covid_Deaths.continent, 
		New_Covid_Deaths.location, 
		New_Covid_Deaths.date, 
		New_Covid_Deaths.population, 
		New_Covid_Vacs.new_vaccinations,
		SUM(CAST(New_Covid_Vacs.new_vaccinations AS bigint)) OVER 
		(PARTITION BY New_Covid_Deaths.location ORDER BY New_Covid_Deaths.location, New_Covid_Deaths.date) AS Rolling_Count_People_Vaccinated


FROM Portfolio..NewCovidDeaths AS New_Covid_Deaths
JOIN	Portfolio..NewCovidVaccinations	AS New_Covid_Vacs

ON New_Covid_Deaths.location = New_Covid_Vacs.location
	AND
	New_Covid_Deaths.date = New_Covid_Vacs.date

WHERE New_Covid_Deaths.continent = 'Asia'

--Using CTE
WITH Population_VS_Vaccinated (continent, location, date, population, new_vaccination, Rolling_Count_People_Vaccinated)
AS (
SELECT New_Covid_Deaths.continent, 
		New_Covid_Deaths.location, 
		New_Covid_Deaths.date, 
		New_Covid_Deaths.population, 
		New_Covid_Vacs.new_vaccinations,
		SUM(CAST(New_Covid_Vacs.new_vaccinations AS bigint)) OVER 
		(PARTITION BY New_Covid_Deaths.location ORDER BY New_Covid_Deaths.location, New_Covid_Deaths.date) AS Rolling_Count_People_Vaccinated


FROM Portfolio..NewCovidDeaths AS New_Covid_Deaths
JOIN	Portfolio..NewCovidVaccinations	AS New_Covid_Vacs

ON New_Covid_Deaths.location = New_Covid_Vacs.location
	AND
	New_Covid_Deaths.date = New_Covid_Vacs.date

WHERE New_Covid_Deaths.continent = 'Asia'
)
SELECT *, (Rolling_Count_People_Vaccinated/population) * 100
FROM Population_VS_Vaccinated

--Creating TempTable if as another option
/*
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Count_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT New_Covid_Deaths.continent, 
		New_Covid_Deaths.location, 
		New_Covid_Deaths.date, 
		New_Covid_Deaths.population, 
		New_Covid_Vacs.new_vaccinations,
		SUM(CAST(New_Covid_Vacs.new_vaccinations AS bigint)) OVER 
		(PARTITION BY New_Covid_Deaths.location ORDER BY New_Covid_Deaths.location, New_Covid_Deaths.date) AS Rolling_Count_People_Vaccinated


FROM Portfolio..NewCovidDeaths AS New_Covid_Deaths
JOIN	Portfolio..NewCovidVaccinations	AS New_Covid_Vacs

ON New_Covid_Deaths.location = New_Covid_Vacs.location
	AND
	New_Covid_Deaths.date = New_Covid_Vacs.date

WHERE New_Covid_Deaths.continent = 'Asia'

SELECT *, (Rolling_Count_People_Vaccinated/population) * 100
FROM #PercentPopulationVaccinated
*/


