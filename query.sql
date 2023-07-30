
--  check the rate of deaths as a proportion to the cases in Australia
 select location, date, total_cases, total_deaths, population,
 (total_deaths/total_cases)*100 as DeathPercentage, (total_cases/ population)*100 as CovidInfectedPercentage
  from CovidProject.dbo.CovidDeaths where location like '%australia%'


-- check which countries has the highest covid infection rate
  select location, population,  max(total_cases) as HighestCovidInfection
  , max(total_cases/ population)*100 as CovidInfectedPercentage 
   from CovidProject.dbo.CovidDeaths 
   group by [location], population
   order by CovidInfectedPercentage desc



-- check which country has the most death count and death rate 
  select location, population,  max(total_deaths) as HighestDeathCount
  , max(total_deaths/ population)*100 as DeathRate 
   from CovidProject.dbo.CovidDeaths 
   group by [location], population
   order by DeathRate desc


-- check which CONTINENT has the most death count and death rate
     select continent, sum(population) as population,  max(total_deaths) as HighestDeathCount
  , max(total_deaths/ population)*100 as DeathRate 
   from CovidProject.dbo.CovidDeaths 
    where continent is not null
   group by [continent] 
   order by HighestDeathCount desc


--check the number of vaccinations in each countries
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
    From CovidProject.dbo.CovidDeaths dea
    Join CovidProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac. date
where dea.continent is not null 
order by 2,3


--check the cumulative sum of vaccinations by date and countries
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by dea.location order by cast(dea.location as nvarchar(50)), dea.date)
as cumulative_vaccinations
    From CovidProject.dbo.CovidDeaths dea
    Join CovidProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac. date
where dea.continent is not null order by 2,3



--in addition, check the cumulative percentage of new vaccinations in proportion to the population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by dea.location order by cast(dea.location as nvarchar(50)), dea.date)
as cumulative_vaccinations
into #tmp1
    From CovidProject.dbo.CovidDeaths dea
    Join CovidProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac. date
where dea.continent is not null order by 2,3

select *, (cumulative_vaccinations/population)*100 as cumulative_vacc_rate from #tmp1

drop table #tmp1
 

-- create a view to store the query for further analysis or data visualization
create view CovidVaccinationResults as 
    select *, (cumulative_vaccinations/population)*100 as cumulative_vacc_rate from
        (
            Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
            sum(cast(new_vaccinations as float)) 
            over (partition by dea.location order by cast(dea.location as nvarchar(50)), dea.date)
            as cumulative_vaccinations
                From CovidProject.dbo.CovidDeaths dea
                Join CovidProject.dbo.CovidVaccinations vac
                On dea.location = vac.location
                and dea.date = vac. date
            where dea.continent is not null
        ) as s
