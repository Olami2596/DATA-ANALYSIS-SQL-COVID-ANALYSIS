select * 
from coviddeaths
where continent is not null
order by 3,4

select * 
from covidvaccinations
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

-- total cases vs total deaths
-- the cast was to make sure that the output was in decimal format
-- shows likelihood of dying if you contract covid
select location, date, total_cases,total_deaths, CAST(total_deaths AS decimal) / total_cases  * 100 as DeathPercentage
from coviddeaths
where continent is not null and
location like 'nigeria' 
order by 1,2

--looking at total cases vs population
--percentage of population that got covid
select location, date, total_cases,population, CAST(total_cases AS decimal) / population  * 100 as SickPercentage
from coviddeaths
where continent is not null and
location like 'nigeria' 
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount,max(cast(total_cases AS decimal)) / population  * 100 as Percentpopulationinfected
from coviddeaths
where continent is not null
group by location, population
order by Percentpopulationinfected desc

-- showing countries with highest death count per population
select location,max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by location
order by totaldeathcount desc


-- showing continents
select continent,max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


-- showing continents with highest death count per population
select continent,max(total_deaths) as totaldeathcount
from coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers by dates 
select date, sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(cast(new_deaths as decimal))/sum(new_cases) * 100 as deathpercentage
from coviddeaths
where continent is not null
group by date
order by 1,2

-- global numbers total
select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(cast(new_deaths as decimal))/sum(new_cases) * 100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2


-- joining the coviddeaths and covidvaccinations table by date and locations
select * 
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 -- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3


 -- use cte
 with popvsvac  (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as
(
-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
)
select *, (cast(rollingpeoplevaccinated as decimal) /population)*100  
from popvsvac



--temp table
-- use the drop table if exists before creating a temp table so as to allow you to rerun the temp table query multiple times

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *, (cast(rollingpeoplevaccinated as decimal) /population)*100  
from #percentpopulationvaccinated


-- creating view to store data for later visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3