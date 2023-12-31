Select *
From sql_project..[covid-deaths]
where continent is not null
order by 3,4

--Select *
--From sql_project..[covid-vaccinations]
--order by 3,4

--Selecting the data that we are going to be using 

Select location, date,total_cases, new_cases, total_deaths, population
From sql_project..[covid-deaths]
where continent is not null
order by 1,2

--Analysing total_cases vs total_deaths
--Show the possibility of dying if you contract covid in India
Select location, date,total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as death_percentage
From sql_project..[covid-deaths]
where location like '%India%'
order by 1,2

--Analysing total_cases vs population
--Shows percentage of population infected by covid
Select location, date,population, total_cases, (cast(total_cases as int)/cast(population as int))*100 as infection_percentage
From sql_project..[covid-deaths]
Where location like '%India%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select location,population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_percentage
From sql_project..[covid-deaths]
where continent is not null
Group by population, location
order by infection_percentage desc 

--Showing the countries with highest death count per population
Select population, MAX(cast(total_deaths as int)) as total_death_count
From sql_project..[covid-deaths]
where continent is not null
Group by population, location
order by total_death_count desc 

--Analysisng facts by different continents (taking continent as null)
Select location, MAX(cast(total_deaths as int)) as total_death_count
From sql_project..[covid-deaths]
where continent is null
Group by location
order by total_death_count desc 

--Analysisng facts by different continents (taking continent as not null)
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From sql_project..[covid-deaths]
where continent is not null
Group by continent
order by total_death_count desc 


--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
From sql_project..[covid-deaths]
where continent is not null
order by 1,2

--Introducting joins
--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as rolling_people_vaccinated
From sql_project..[covid-deaths] as dea
Join sql_project..[covid-vaccinations] as vac
on dea.location = vac.location
and dea.date =	vac.date
where dea.continent is not null
order by 2,3


--Using CTE

With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as rolling_people_vaccinated
From sql_project..[covid-deaths] as dea
Join sql_project..[covid-vaccinations] as vac
on dea.location = vac.location
and dea.date =	vac.date
where dea.continent is not null
)
Select * , (rolling_people_vaccinated/Population)*100
From PopvsVacc

--Creating view to store data for later visualizations
CREATE VIEW Percentage_Population_Vaccinated	as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as rolling_people_vaccinated
From sql_project..[covid-deaths] as dea
Join sql_project..[covid-vaccinations] as vac
on dea.location = vac.location
and dea.date =	vac.date
where dea.continent is not null	

Select *
From Percentage_Population_Vaccinated