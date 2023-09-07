Select *
From CovidDeaths
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

Select Location, date, total_cases, total_deaths, population
From CovidDeaths
Order By 1,2

--Shows us the death percentage for those who have COVID-19 in Spain
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As [Death Percentage]
From CovidDeaths
Where Location Like '%Spain%'
Order By 1,2

--Tells us the percentage of the population that contracted COVID-19 over time
Select Location, date, total_cases, total_deaths, population, (total_cases/population)*100 As [Percentage with COVID-19]
From CovidDeaths
Where Location Like '%Spain%'
Order By 1,2

--Finding which country had the highest cases
Select Location, population, Max(total_cases) as [Highest Recorded Cases], Max((total_cases/population))*100 As [Percentage with COVID-19]
From CovidDeaths
Group By location, population
Order By [Percentage with COVID-19] desc

--Finding the countries with the highest death count per population
--We cast total_deaths as an int to have proper descending results
Select Location, Max(cast(total_deaths as int)) As [Death Count]
From CovidDeaths
Where continent Is Not Null
Group By Location
Order By [Death Count] desc

--Similar to above, we can see the death count throughout the world with greater focus on continents
Select Location, Max(cast(total_deaths as int)) as [Death Count]
From CovidDeaths
Where continent Is Null
Group By Location
Order By [Death Count] desc

--Looking at the total population and how many specifically are vaccinated
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
--Partition By allows us to sum up the differing locations' unique vaccination numbers 
Sum(cast(va.new_vaccinations as int)) Over (Partition By de.location Order By de.Location, de.date) as [People Vaccinated per Country]
From CovidDeaths de
Join CovidVaccinations va
	On de.location = va.location and
	de.date = va.date 
Where de.continent Is Not Null
Order By 2,3

--Utilizing a CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, [People Vaccinated per Country])
as (
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
Sum(cast(va.new_vaccinations as int)) Over (Partition By de.location Order By de.Location, de.date) as [People Vaccinated per Country]
From CovidDeaths de
Join CovidVaccinations va
	On de.location = va.location and
	de.date = va.date 
Where de.continent Is Not Null
)
Select *, ([People Vaccinated per Country]/population)*100 
From PopVsVac

--Using a temp table with a drop statement
Drop Table if exists #PercentVaccinated
Create Table #PercentVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinatedperCountry numeric
)

Insert into #PercentVaccinated
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
Sum(cast(va.new_vaccinations as int)) Over (Partition By de.location Order By de.Location, de.date) As [People Vaccinated per Country]
From CovidDeaths de
Join CovidVaccinations va
	On de.location = va.location and
	de.date = va.date 

Select *, (PeopleVaccinatedperCountry/population)*100 
From #PercentVaccinated


--Creating a view to store our data
Create View PercentVaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
Sum(cast(va.new_vaccinations as int)) Over (Partition By de.location Order By de.Location, de.date) as [People Vaccinated per Country]
From CovidDeaths de
Join CovidVaccinations va
	On de.location = va.location and
	de.date = va.date 
Where de.continent Is Not Null
Select *
From PercentVaccinated

Create View CountryDeaths as
Select Location, Max(cast(total_deaths as int)) As [Death Count]
From CovidDeaths
Where continent Is Not Null
Group By Location
Select *
From CountryDeaths

Create View WorldwideDeaths as
Select Location, Max(cast(total_deaths as int)) As [Death Count]
From CovidDeaths
Where continent Is Null
Group By Location
Select *
From WorldwideDeaths

Create View ContractionOfCovid as
Select Location, date, total_cases, total_deaths, population, (total_cases/population)*100 As [Percentage with COVID-19]
From CovidDeaths
Where Location Like '%Spain%'
Select *
From ContractionOfCovid

Create View HighestCases as
Select Location, population, Max(total_cases) As [Highest Recorded Cases], Max((total_cases/population))*100 As [Percentage with COVID-19]
From CovidDeaths
Group By location, population
Select *
From HighestCases


