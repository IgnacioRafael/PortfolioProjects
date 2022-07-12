-- Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population From CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in the US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage From CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Total cases vs The population
-- Shows what porcentage of the population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage From CovidDeaths
Order by 1,2

-- Countries with highest infection rates compared to population

Select location, MAX(total_cases) as HighestInfectionCount, population, (MAX(total_cases)/population)*100 as PercentPopulationInfected 
From CovidDeaths
Group By location,population
Order by PercentPopulationInfected DESC


-- Countries with Highest Death Counts per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount DESC

-- Continents with Highest Death Counts per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount DESC

-- Showing Continents with Higher Death Count Per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount DESC


-- Global Numbers

Select SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as Acum_People_Vac
From CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With Popvsvac (Continent,Location,date,population,new_vaccinations,Acum_People_Vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as Acum_People_Vac
From CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, Acum_People_Vac/population*100 as VacPercentage
From Popvsvac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Acum_People_Vac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as Acum_People_Vac
From CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3
Select*, Acum_People_Vac/population*100 as VacPercentage
From #PercentPopulationVaccinated


-- Creating a view

Create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as Acum_People_Vac
From CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * from PercentPopulationVaccinated