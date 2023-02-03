Select *
From PortolioProject..CovidDeaths
Where continent is not null
Order by 3,4



--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortolioProject..CovidDeaths
Order By 1,2;


--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contractb covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2;


--Looking at total cases vs population
--Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortolioProject..CovidDeaths
--Where location like '%states%'
Order By 1,2;


--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfection
From PortolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order By PercentPopulationInfection desc;


--Showing countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order By TotalDeathCount desc;

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc;


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NEW_CASES)*100 as DeathPercentage
From PortolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
--Group by date
Order by 1,2;


--Looking at Total Population vs Vaccination

Insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * From PercentPopulationVaccinated