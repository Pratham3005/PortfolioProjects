select * from CovidDeaths
where continent is not null
order by 3 , 4


-- select * from CovidVaccinations
-- order by 3 , 4


-- select data that we are going to be using

select Location,date,total_cases, new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1 , 2


-- looking at the total cases VS total deaths
-- Shows likelihood of dying if you interact with covid in your country
select Location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
and location like '%states%'
order by 1 , 2


-- looking at the total cases vs population
-- shows what pecentage of population got coivd
select Location,date,Population,total_cases,(total_cases/population) * 100 as CasesPercentage
from CovidDeaths
where continent is not null
and location like '%states%'
order by 1 , 2


-- looking at countries with highest infection rate compared to population

select Location,Population,max(total_cases) as HighestinfectionCount,max((total_cases/population)) * 100 as InfectionPercentage
from CovidDeaths
where continent is not null
group by Location,Population
order by InfectionPercentage desc


-- looking at countries with highest death count compared to population

select Location,Population,max(total_deaths) as HighestdeathCount,max((total_deaths/population)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by Location,Population
order by DeathPercentage desc

-- looking at countries with highest death count --/ cast data type change krta h jaise totaldeath varchar h vo int ho gaya

select Location,max(cast(total_deaths as int)) as TotaldeathCount
from CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- let;s break things down by continent
select continent,max(cast(total_deaths as int)) as TotaldeathCount
from CovidDeaths
where continent is not null
--where continent is null
Group by continent
--group by location
order by TotalDeathCount desc


-- showing the contintents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotaldeathCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- global numbers

select sum(new_cases)as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
--where location like '%states%'
--group by date
order by 1 , 2


-- looking at  total population vs total vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as
from CovidDeaths dea
	join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as
from CovidDeaths dea
	join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population) *100  as VaccinatedPercentage
from PopvsVac






--temp tables
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as
from CovidDeaths dea
	join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * , (RollingPeopleVaccinated/population) *100  as VaccinatedPercentage
from #percentpopulationvaccinated



--creating views to store data for visualization


create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as
from CovidDeaths dea
	join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated
