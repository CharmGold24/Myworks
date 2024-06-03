/* Data Analyst Portfolio Project | SQL Data Exploration 
   Analysis of Covid data - Comparision across globe with reference to Canada and India
   Used JOINS  CTE | TEMP TABLES | STORED PROCEDURES | WINDOWS FUNCTIONS | AGGREGATE FUNCTIONS | CONVERTING DATA TYPES 
*/

select * 
from [Portfolio Project Covid]..CovidDeaths
where continent is not null
order by 3,4

select Location, Date, total_cases, New_Cases, Total_deaths, Population
from [Portfolio Project Covid]..CovidDeaths
where continent is not null and location in ('china','india')
order by 1,2

--TOTAL CASES V/S TOTAL DEATHS
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project Covid]..CovidDeaths
--where location LIKE '%states' or 
where location in ('china','india') and continent is not null
order by 1,2

--Total cases v/s Population
select Location, Date, Total_cases, Population, (total_cases/population)*100 as Population_Infected
from [Portfolio Project Covid]..CovidDeaths
order by 1,2

--Countries affected the most compared to its population
select location, population, max(total_cases) as Highest_Infected, max(total_cases/population)*100 as Death_Rate
from [Portfolio Project Covid]..CovidDeaths
group by location, population
order by Death_Rate desc

--Affected rate : Canada and India
select location, population, max(total_cases) as Highest_Infected, max(total_cases/population)*100 as Death_Rate
from [Portfolio Project Covid]..CovidDeaths
where location in ('Canada','India')
group by location, population
order by Death_Rate desc

--Countries with highest Death rate
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project Covid]..CovidDeaths
where continent is null 
group by location
order by TotalDeathCount desc

--Death rates in India and Canada
select Location, max(cast(total_deaths as int)) as 'Total Death Count'
from [Portfolio Project Covid]..CovidDeaths
where location in ('Canada','India')
group by location
order by 'Total Death Count' desc

--Death rates continent wise
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project Covid]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--COUNTRIES WITH HIGHEST INFECTION RATE
select location, max(total_cases) as Highest_Infection, max((total_cases/population))*100 as Max_Percent_Affected
from [Portfolio Project Covid]..CovidDeaths
group by location
order by Max_Percent_Affected desc

--global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from [Portfolio Project Covid]..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Death Cases and its percentage
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from [Portfolio Project Covid]..CovidDeaths
where continent is not null
order by 1,2

--Canada and India Death cases compared to its population
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from [Portfolio Project Covid]..CovidDeaths
where continent is not null and location in ('Canada','India')
order by 1,2

--Total Population v/s Vaccination
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated
from [Portfolio Project Covid]..CovidDeaths as dea
join [Portfolio Project Covid]..CovidVax vax
on dea.location=vax.location and dea.date=vax.date
where dea.continent is not null and
vax.new_vaccinations is not null and vax.location in ('Canada','India')
order by 2,3

--CTE
with PopVax (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from [Portfolio Project Covid]..CovidDeaths as dea
join [Portfolio Project Covid]..CovidVax vax
on dea.location=vax.location and dea.date=vax.date
where dea.continent is not null and
vax.new_vaccinations is not null and vax.location in ('Canada','India')
)
select *, (PeopleVaccinated/population)*100 AS PercentVax
from PopVax

--TEMP TABLE
DROP TABLE IF EXISTS #PercentVax
create table #PercentVax
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
People_Vaccinated numeric
)
insert into #PercentVax
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from [Portfolio Project Covid]..CovidDeaths as dea
join [Portfolio Project Covid]..CovidVax vax
on dea.location=vax.location and dea.date=vax.date

--CREATING VIEW FOR LATER DATA VISUALISATIONS
create view PercentVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from [Portfolio Project Covid]..CovidDeaths as dea
join [Portfolio Project Covid]..CovidVax vax
on dea.location=vax.location and dea.date=vax.date
where dea.continent is not null
	
select * from PercentVaccinated
