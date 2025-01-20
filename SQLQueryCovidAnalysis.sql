Select *
From DataAnalysisProject..CovidDeaths

Select Location,date,total_cases,new_cases,total_deaths,population
From DataAnalysisProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths (Azerbaijan)
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
From DataAnalysisProject..CovidDeaths
Where location like '%Azerbaijan%'
order by 2

--Looking at Total Cases vs Population
--What percentage of population got Covid
Select Location,date,Population,total_cases,(total_cases/Population) * 100 as CovidPercentageInPopulation
From DataAnalysisProject..CovidDeaths
order by 1,2

--Looking at countries with highest Infection rate
Select Location,Population,date,Max(total_cases) as HighestInfection,Max((total_cases/Population)) * 100 as CovidPercentageInPopulation
From DataAnalysisProject..CovidDeaths
Group by Location,Population,date
order by CovidPercentageInPopulation desc

--Showing countries with Highest Death Count per Population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Retrieving Total Death Count by Location Excluding Continent-Level and Aggregated Data"
Select Location, Sum(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisProject..CovidDeaths
Where continent is null
and location not in ('World','European Union','International')
Group by Location
order by TotalDeathCount desc

--Showing continents with Highest Death Count per Population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select Sum(new_cases) as Totalcases,Sum(cast(new_deaths as int)) as TotalDeaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as NewDeathPercentage
From DataAnalysisProject..CovidDeaths
Where continent is not null
order by 1,2

--Vaccinations and Death Join
--Looking at Total Population and Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From DataAnalysisProject..CovidDeaths dea
Join DataAnalysisProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3

--Use CTE
With PopulationVsVaccination(Continent,Location,date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From DataAnalysisProject..CovidDeaths dea
Join DataAnalysisProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopulationVsVaccination

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_caccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From DataAnalysisProject..CovidDeaths dea
Join DataAnalysisProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View for later vizualizations
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From DataAnalysisProject..CovidDeaths dea
Join DataAnalysisProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated