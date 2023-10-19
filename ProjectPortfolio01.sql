--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

--total death percentage in nigeria
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

-- total cases vs population
--Percentage of Population that contacted Covid
select location, date, total_cases, population,(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--countries with highest infection rate compared to population
select location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as 
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by PercentagePopulationInfected DESC

--countries with highest death count per population

select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
--where continent is not null
group by location
order by TotalDeathCount desc

--countries with highest death count per population

select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--BREAK DOWN BY CONTINENT

--Continent with Highest Death Count Per Popultion

select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- this gives you a global data without filtering by location

select  date, sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

--Removing Dates
select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


--performing a join
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date

--Total amount of population that was vaccinated
-- Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 1,2,3

--LOOKING AT TOTAL POPULATION VS VACCINATION
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (PARTITION BY dea.location order by dea.location,
    dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3


-- use CTE
WITH PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (PARTITION BY dea.location order by dea.location,
    dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
)

select *,( RollingPeopleVaccinated/ population)*100
from
PopvsVac

-- TEMP TABLE
CREATE table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime ,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (PARTITION BY dea.location order by dea.location,
    dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
select *,( RollingPeopleVaccinated/ population)*100
from
#PercentPopulationVaccinated

-- DROP TABLE
DROP TABLE if exists  #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime ,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (PARTITION BY dea.location order by dea.location,
    dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null 
	--order by 2,3
select *,( RollingPeopleVaccinated/ population)*100
from
#PercentPopulationVaccinated



-- Creating views for visualization
-- Drop view
-- got an error message because percentpopulation view existed already 
DROP VIEW PercentPopulationVaccinated;

-- Views For Visualization 
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select * from
PercentPopulationVaccinated
--RETRIVE TOTAL VACCINATION IN NIGERIA

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
AND vac.new_vaccinations IS NOT NULL
AND dea.location LIKE '%nigeria'
ORDER BY dea.continent, dea.location, dea.date;


create view TotalVaccinatedInNigeria as
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
AND vac.new_vaccinations IS NOT NULL
AND dea.location LIKE '%nigeria'
--ORDER BY dea.continent, dea.location, dea.date;