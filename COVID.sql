SELECT *
FROM Project1..CovidDeaths
WHERE continent is not null
order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Project1..CovidDeaths
order by 1,2
WHERE continent is not null


-- Looking at total cases vs total deaths
--  Muestra la probabilidad de muerte si cotnraes Covid en tu país
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
WHERE location like '%mexico%' and WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percenage of population got COVID
SELECT Location, date, total_cases, Population,(total_cases/population)*100 as PercentageOfPopulationInfected
FROM Project1..CovidDeaths
WHERE location like '%mexico%' and WHERE continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
SELECT Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM Project1..CovidDeaths
WHERE continent is not null
Group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Project1..CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent
--Showing the contnent with the highest death count per continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Project1..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
WHERE continent is not null
Group by date
order by 1,2



--Looking at total population vs vaccinations
SELECT continent,location,new_vaccinations
FROM Project1..CovidVaccinations
WHERE new_vaccinations is null


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated --Acumula las nuevas vacunas día a día
FROM Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3


--USING CTE because we ned to use a column that we just created and since we cannot use a column at the same time we are creating it 
--to use a CTE is needed. we need to execute this whole sentence
With POPvsVAC (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 
FROM Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM POPvsVAC


--TEMP TABLE--

DROP Table if exists #PercentPopulationVaccinated --This is for getting new table every time we tun this sentencce
CREATE TABLE #PercentPopulationVaccinated
--Specify columns
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 
FROM Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--CREATIN GVIEW TO STORE DATA FOR LATER VISUALIZATIONS--
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 
FROM Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3


SELECT * 
FROM PercentPopulationVaccinated