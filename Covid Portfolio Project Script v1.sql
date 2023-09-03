Select *
From ProjectCovid2..Covid_deaths$
order by 3,4

--Select * 
--From ProjectCovid2..['Covid_Vaccinations']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From ProjectCovid2..Covid_deaths$
order by 1,2

--Looking at total deaths vs total cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases) as DeathPercentage
From ProjectCovid2..Covid_deaths$
order by 1,2

--I need to alter the datatypes of the columns as there was some issue with the data import process

ALTER TABLE Covid_deaths$ alter column total_cases NUMERIC(18,0);
ALTER TABLE Covid_deaths$ alter column total_deaths NUMERIC(18,0);

-- Retrying the previous query
-- Looking at total cases vs total deaths and the likelihood of dyiing if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectCovid2..Covid_deaths$
where location = 'Nigeria'
order by 1,2


-- Looking at total cases vs population
-- shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
From ProjectCovid2..Covid_deaths$
--where location = 'Nigeria'
order by 1,2


-- Looking at countries  with Highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAx((total_cases/population))*100 as PercentOfPopluationInfected
From ProjectCovid2..Covid_deaths$
--where location = 'Nigeria'
Group by location, population 
order by PercentOfPopluationInfected desc


-- Showing countries with the Highest death count per populations

select location, Max(total_deaths) as TotalDeathCount
From ProjectCovid2..Covid_deaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT v1

select location, Max(total_deaths) as TotalDeathCount
From ProjectCovid2..Covid_deaths$
where continent is null and location not like '%income'
Group by location
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT v1
-- shoing the continents with the highest death count per population

select continent, Max(total_deaths) as TotalDeathCount
From ProjectCovid2..Covid_deaths$
where continent is null and location not like '%income'
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

--SET ARITHABORT OFF;
--SET ANSI_WARNINGS OFF;
select sum(new_cases) AS total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From ProjectCovid2..Covid_deaths$
--where loaction = 'Nigeria'
where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location,dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vacc
From ProjectCovid2..Covid_deaths$ dea
Join ProjectCovid2..['Covid_Vaccinations'] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%occo'
order by 2,3


-- Including a rolling count into the total populations Vs Vaccinations view

-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From ProjectCovid2..Covid_deaths$ dea
Join ProjectCovid2..['Covid_Vaccinations'] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%occo'
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid2..Covid_deaths$ dea
Join ProjectCovid2..['Covid_Vaccinations'] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%occo'
--order by 2,3
)

Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

Drop Table if exist #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationvaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid2..Covid_deaths$ dea
Join ProjectCovid2..['Covid_Vaccinations'] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%occo'
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationvaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From ProjectCovid2..Covid_deaths$ dea
Join ProjectCovid2..['Covid_Vaccinations'] vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like '%occo'
--order by 2,3
