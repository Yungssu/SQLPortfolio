
SELECT *
	FROM Portfolio..CovidDeaths
	ORDER BY 3,4

--SELECT *
--	FROM Portfolio..CovidVaccinatios
--	ORDER BY 3,4

-- SELECT Data thats going to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM Portfolio..CovidDeaths
	ORDER BY 1,2

--total_cases vs total_deaths
SELECT location, date, total_cases, total_deaths, 
	(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases), 0)) * 100 AS DeathPercentage
	FROM Portfolio..CovidDeaths
	WHERE location LIKE '%Philippines%'
	ORDER BY 1,2

--total_cases vs population
SELECT location, date, total_cases, population, 
	(CONVERT(float,total_cases)/NULLIF(CONVERT(float, population), 0)) * 100 AS PercentOfPopulationInfected
	FROM Portfolio..CovidDeaths
	WHERE location LIKE '%Philippines%'
	ORDER BY 1,2

--Countries with Highest Infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX(CONVERT (float,total_cases)/NULLIF(CONVERT(float, population), 0)) * 100 AS PercentOfPopulationInfected
	FROM Portfolio..CovidDeaths
	GROUP BY location, population
	ORDER BY PercentOfPopulationInfected DESC

--Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths as BIGint)) as TotalDeathCount 
	FROM Portfolio..CovidDeaths
	WHERE continent is NOT NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC

--continent
SELECT location, MAX(CAST(total_deaths as BIGint)) as TotalDeathCount 
	FROM Portfolio..CovidDeaths
	WHERE continent is NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC


--continent with Highest Deatch Count
SELECT continent, MAX(CAST(total_deaths as BIGint)) as TotalDeathCount 
	FROM Portfolio..CovidDeaths
	WHERE continent is NOT NULL
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, total_cases, total_deaths, 
	(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases), 0)) * 100 AS DeathPercentage
	FROM Portfolio..CovidDeaths
	WHERE continent is NOT NULL
	ORDER BY 1,2

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
	FROM Portfolio..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1, 2

--TOTAL population vs Vaccinations
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacs.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(CovidVacs.new_vaccinations, 0))) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS TotalVaccinations,
	--(TotalVaccinations/population) * 100
	FROM Portfolio..CovidDeaths AS CovidDeaths
	JOIN Portfolio..CovidVaccinatios AS CovidVacs
	ON CovidDeaths.location = CovidVacs.location AND CovidDeaths.date = CovidVacs.date
	WHERE CovidDeaths.continent IS NOT NULL
	ORDER BY 2, 3

--USING CTE
WITH PupolationVSVaccination (continent, location, date, population, new_vaccinations, TotalVaccinations)
	AS ( SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacs.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(CovidVacs.new_vaccinations, 0))) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS TotalVaccinations
	FROM Portfolio..CovidDeaths AS CovidDeaths
	JOIN Portfolio..CovidVaccinatios AS CovidVacs
	ON CovidDeaths.location = CovidVacs.location AND CovidDeaths.date = CovidVacs.date
	WHERE CovidDeaths.continent IS NOT NULL )

SELECT *, (TotalVaccinations/population) * 100
	FROM PupolationVSVaccination

--TEMP Table
	--DROP TABLE IF EXIST "#TEMPTableName"
	CREATE Table #PercentPopulationVaccinated
		(continent nvarchar(255),
		location nvarchar(255),
		date datetime,
		population numeric,
		new_vaccinations numeric,
		TotalVaccinations numeric )
		
	INSERT INTO #PercentPopulationVaccinated
	SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacs.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(CovidVacs.new_vaccinations, 0))) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS TotalVaccinations
	FROM Portfolio..CovidDeaths AS CovidDeaths
	JOIN Portfolio..CovidVaccinatios AS CovidVacs
	ON CovidDeaths.location = CovidVacs.location AND CovidDeaths.date = CovidVacs.date
	WHERE CovidDeaths.continent IS NOT NULL 

	SELECT *, (TotalVaccinations/population) * 100
		FROM #PercentPopulationVaccinated


-- Creating VIEW
CREATE VIEW PercentPopulationVaccinated AS 
	SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVacs.new_vaccinations,
    SUM(CONVERT(bigint, ISNULL(CovidVacs.new_vaccinations, 0))) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS TotalVaccinations
	FROM Portfolio..CovidDeaths AS CovidDeaths
	JOIN Portfolio..CovidVaccinatios AS CovidVacs
	ON CovidDeaths.location = CovidVacs.location AND CovidDeaths.date = CovidVacs.date
	WHERE CovidDeaths.continent IS NOT NULL 

SELECT *
	FROM PercentPopulationVaccinated