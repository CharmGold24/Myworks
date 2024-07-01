/* Analysis of Covid data - Comparision across globe with reference to Canada and India */

select * 
from CovidDeaths
where continent is not null and location in ('china','india')
order by 3,4

--Affected rate
select location, population, max(total_cases) as Highest_Infected, max(total_cases/population)*100 as Death_Rate
from CovidDeaths
where location in ('Canada','India')
group by location, population
order by Death_Rate desc

--Death rates
select Location, max(cast(total_deaths as int)) as 'Total Death Count'
from CovidDeaths
where location in ('Canada','India')
group by location
order by 'Total Death Count' desc

--Death cases compared to its population
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from [Portfolio Project Covid]..CovidDeaths
where continent is not null and location in ('Canada','India')
order by 1,2

--Total Population v/s Vaccination
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated
from CovidDeaths as dea
join CovidVax vax
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
from CovidDeaths as dea
join CovidVax vax
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
from CovidDeaths as dea
join CovidVax vax
on dea.location=vax.location and dea.date=vax.date

--CREATING VIEW FOR LATER DATA VISUALISATIONS
create view PercentVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
sum(convert(int, vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from CovidDeaths as dea
join CovidVax vax
on dea.location=vax.location and dea.date=vax.date
where dea.continent is not null
