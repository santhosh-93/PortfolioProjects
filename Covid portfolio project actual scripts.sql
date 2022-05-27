 Select *
 From portfolioProject..covidDeaths$
 order by 3,4

 
 --Select *
 --From portfolioProject..CovidVaccinations$
 --order by 3,4

 -- select data that we are going to be using
 Select location, date , total_cases, new_cases, total_deaths, population
 From portfolioProject..covidDeaths$
 order by 1,2

 -- Looking at the Total Cases vs Total Deaths i.e DeathPercentage
 -- shows likelihood of dying if you contract covid in India

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From portfolioProject..covidDeaths$
 where location like '%India%'
 order by 1,2

 --Looking at Total Cases vs Population
 --shows what percentage of population got covid
 
 Select location, date,population, total_cases, total_deaths,  (total_cases/population)*100 as PercentPopulationInfected
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 order by 1,2

 

 --Looking at countries with Highest Infection Rate compared to population

 Select location,population, MAX(total_cases) as HighestInfectionCount,   MAX((total_cases/population))*100 as PercentPopulationInfected
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 Group by location, population
 order by PercentPopulationInfected desc


 -- Showing countries with Highest Death Count per population
 --total deaths in varchar so converting it to int by cast
 --when asia is present in both continent and location and when contient is null,it takes world,asia as location so make continent not null

 Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc

 Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 where continent is  null
 Group by location
 order by TotalDeathCount desc

-- Lets break things by continent
-- Showing the continent with highest death count per population

 Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 where continent is  not null
 Group by continent
 order by TotalDeathCount desc


 -- Global Numbers
 Select  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases )*100 
 as DeathPercentage
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 where continent is not null
 Group by date
 order by 1,2

 --global numbers not by data
 Select   SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases )*100 
 as DeathPercentage
 From portfolioProject..covidDeaths$
 --where location like '%India%'
 where continent is not null
 --Group by date
 order by 1,2

-- joining both tables with alias name as dea and vac

 select * 
 from portfolioProject..covidDeaths$ dea
 join portfolioProject..CovidVaccinations$ vac
    on dea.location= vac.location
	and dea.date = vac. date
 
 -- looking at total population vs Vaccinations

 --A PARTITION BY clause is used to partition rows of table into groups. 
 --It is useful when we have to perform a calculation on individual rows of a group using other rows of that group.
 --here partition is done through location

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date rows UNBOUNDED PRECEDING) 
 as RollingPeopleVaccinated
 from portfolioProject..covidDeaths$ dea
 join portfolioProject..CovidVaccinations$ vac
    on dea.location= vac.location
	and dea.date = vac. date
 where dea.continent is not null
order by 2,3

--Common Table Expression (CTE) is the result set of a query which exists temporarily and for use only within the context of a larger query. 
--Much like a derived table, the result of a CTE is not stored and exists only for the duration of the query.
 
 with popvsvac(continent, location,date, population,New_Vaccinations, RollingpeopleVaccinated) as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
 dea.date rows UNBOUNDED PRECEDING) 
 as RollingPeopleVaccinated
 from portfolioProject..covidDeaths$ dea
 join portfolioProject..CovidVaccinations$ vac
    on dea.location= vac.location
	and dea.date = vac. date
where dea.continent is not null
--order by 2,3
)
select *,(RollingpeopleVaccinated/population)*100
from popvsvac



-- Temp Table
--have drop table at the top so it will be easy if we have to drop the table

DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
 dea.date rows UNBOUNDED PRECEDING) 
 as RollingPeopleVaccinated
 from portfolioProject..covidDeaths$ dea
 join portfolioProject..CovidVaccinations$ vac
    on dea.location= vac.location
	and dea.date = vac. date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated



--Creating view to store data for later visualization
--view is a virtual table based on the result-set of an SQL statement. A view contains rows and columns, just like a real table. 
--The fields in a view are fields from one or more real tables in the database

Create view 
percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
 dea.date rows UNBOUNDED PRECEDING) 
 as RollingPeopleVaccinated
 from portfolioProject..covidDeaths$ dea
 join portfolioProject..CovidVaccinations$ vac
    on dea.location= vac.location
	and dea.date = vac. date
where dea.continent is not null
--order by 2,3

select *
from percent_Population_Vaccinated