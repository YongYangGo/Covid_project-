use [portfolioProject]

select * 
from CovidDeaths
Order by 3, 4

--select * 
--from CovidVaccinations
--Order by 3, 4


--Select data that we are going to be using 


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,new_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths
where location like '%zealand%'
order by 1,2

--looking at total cases vs population
--Shows what percentage of population got Covid
select location,date,total_cases,population,round((total_cases/population)*100,2) as DeathPercentage
from CovidDeaths
--where location like '%zealand%'
order by 1,2

-- Looking at countried with Highest infection rate compared to Population

Select location, Population,Max(total_cases) as highest_infection_count, Max(total_cases/Population)*100 as Percent_Population_infected
from CovidDeaths
group by location,population
order by 4 desc

--Showing  Countries with Highest Death Count Per Population
-- 'where continent is not null ' remove error data
Select location, MAX(cast(total_deaths as int)) as Total_Death
from CovidDeaths
where continent is not null
group by location
order by Total_Death desc



--showing continents with the highest death country count per population
--create 2 views and then joining them together
create view  all_information as

Select location,continent, MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths
where continent is not null
group by continent,location


create view  Death as

Select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths
where continent is not null
group by continent



select all_information.location,all_information.continent, all_information.Total_Death_count from  death 
inner join all_information on all_information.Total_Death_count=Death.Total_Death_count
order by Total_Death_count desc

--looking at sum of continent

select * from all_information

select continent,SUM(Total_Death_count) as Total_Death
from all_information
where Total_Death_count is not null 
group by continent
order by Total_Death

--Global numbers 
select * 
from CovidDeaths
Order by 3, 4

select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,  round(sum(cast(new_deaths as int))/SUM(new_cases)*100,2)as Death_Percentage
from CovidDeaths
where continent is not null
order by 1 

--Looking at Total Population vs Vacinations per day

select Dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,Vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
--,Rolling_People_Vaccinated/population*100
FROM CovidDeaths AS Dea 
JOIN CovidVaccinations as Vac 
ON Dea.location=Vac.location
and dea.date=Vac.date

where Dea.continent is not null
order by 2,3

--use CTE

with PopvsVac(continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated) as
(
select Dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,Vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
--,Rolling_People_Vaccinated/population*100
FROM CovidDeaths AS Dea 
JOIN CovidVaccinations as Vac 
ON Dea.location=Vac.location
and dea.date=Vac.date

where Dea.continent is not null)

select *,round(Rolling_People_Vaccinated/population*100,2) as vaccination_percentage
from PopvsVac
order by location,date

--Use Table

drop table if exists Percent_vaccinated
Create table Percent_vaccinated
(continenet nvarchar(255),
location nvarchar(255),
date datetime,
population Numeric,
new_vaccinations Numeric,
Rolling_People_Vaccinated Numeric )

insert into Percent_vaccinated
select Dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,Vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
--,Rolling_People_Vaccinated/population*100
FROM CovidDeaths AS Dea 
JOIN CovidVaccinations as Vac 
ON Dea.location=Vac.location
and dea.date=Vac.date

where Dea.continent is not null
--order by 2,3

select *,round(Rolling_People_Vaccinated/population*100,2) as vaccination_percentage
from Percent_vaccinated
order by location,date

--Use View to store data for later visualizations 

create view  Percent_vaccinated_view as
select Dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,Vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
--,Rolling_People_Vaccinated/population*100
FROM CovidDeaths AS Dea 
JOIN CovidVaccinations as Vac 
ON Dea.location=Vac.location
and dea.date=Vac.date

where Dea.continent is not null
--order by 2,3

select  * from Percent_vaccinated_view order by 2,3