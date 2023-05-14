SELECT*
FROM ProyectoPortafolio..MuertesCovid
WHERE continent IS NOT NULL
order by 3,4;


--SELECT*
--FROM VacunasCovid
--ORDER BY 3,4


--Seleccionar la info que usare

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProyectoPortafolio..MuertesCovid
ORDER BY 1,2;


-- Buscando el total de casos vs el total de las muertes
-- Muestra la probabilidad de morir si contraes covid en tu pais

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PorcentajeDeMuerte
FROM ProyectoPortafolio..MuertesCovid
Where location like '%Chile%'
and continent IS NOT NULL
ORDER BY 1,2;


--Buscar el total del casos vs la poblaciòn
--Muestra que porcentaje de la poblacion se enfermo con covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PorcentajePoblacionInfectada
FROM ProyectoPortafolio..MuertesCovid
Where location like '%Chile%'
and continent IS NOT NULL
ORDER BY 1,2;


--Buscar paises con la tasa de infeccion mas alta

SELECT location, population, max(total_cases) as MayorConteoInfeccion, max((total_cases/population))*100 as PorcentajePoblacionInfectada
FROM ProyectoPortafolio..MuertesCovid
--Where location like '%Chile%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 desc;


--Buscar paises con el conteo de muertes mas alto

SELECT location, MAX(cast(total_deaths as int)) as MuertesTotales
FROM ProyectoPortafolio..MuertesCovid
--Where location like '%Chile%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MuertesTotales desc;


--Dividirlos por continentes
--Mostrar los continentes con la tasa de muerte mas alta por pais

SELECT continent, MAX(cast(total_deaths as int)) as MuertesTotales
FROM ProyectoPortafolio..MuertesCovid
--Where location like '%Chile%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MuertesTotales desc;


--Numeros Mundiales por fecha

SELECT date, sum(new_cases) as CasosTotales, sum(cast(new_deaths as int)) as MuertesTotales, sum(cast(new_deaths as int))/sum(new_cases)*100 as PorcentajeMuerteMundial
FROM ProyectoPortafolio..MuertesCovid
--Where location like '%Chile%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--Numeros Mundiales sin filtro

SELECT sum(new_cases) as CasosTotales, sum(cast(new_deaths as int)) as MuertesTotales, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PorcentajeMuerteMundial
FROM ProyectoPortafolio..MuertesCovid
--Where location like '%Chile%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


--Vamos con la tabla de Vacunas y a unirlas

SELECT *
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date

	
--Revisando el total de la poblacion vs el total de los vacunados

SELECT Mue.continent, mue.location, Mue.date, population, vac.new_vaccinations
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date
WHERE mue.continent IS NOT NULL
ORDER BY 2,3;


--Revisando el total de la poblacion vs el total de los vacunados

SELECT Mue.continent, mue.location, Mue.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY mue.location 
ORDER BY mue.location, mue.date) as SumaVacunasPorDia
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date
WHERE mue.continent IS NOT NULL
ORDER BY 2,3;


-- USAR un CTE para el porcentaje de las personas vacunadas

WITH PoblacionVacunas (continent, location, date, population, new_vaccinations, SumaVacunasPorDia)
as
(
SELECT Mue.continent, mue.location, Mue.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY mue.location 
ORDER BY mue.location, mue.date) as SumaVacunasPorDia
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date
WHERE mue.continent IS NOT NULL
--ORDER BY 2,3);
)


SELECT *, (SumaVacunasPorDia/population)*100 as PorcentajeVacunados
FROM PoblacionVacunas


-- Otra forma de hacerlo Tabla temporal

DROP TABLE if exists #PorcentajePoblacionVacunada
CREATE TABLE #PorcentajePoblacionVacunada
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumaVacunasPorDia numeric)

INSERT INTO #PorcentajePoblacionVacunada
SELECT Mue.continent, mue.location, Mue.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY mue.location 
ORDER BY mue.location, mue.date) as SumaVacunasPorDia
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date
WHERE mue.continent IS NOT NULL
--ORDER BY 2,3);


SELECT *, (SumaVacunasPorDia/population)*100 as PorcentajeVacunados
FROM #PorcentajePoblacionVacunada


--Creando vista para visualizadiones de datos posteriores

CREATE VIEW PorcentajePoblacionVacunada as
SELECT Mue.continent, mue.location, Mue.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY mue.location 
ORDER BY mue.location, mue.date) as SumaVacunasPorDia
FROM ProyectoPortafolio..MuertesCovid Mue
JOIN ProyectoPortafolio..VacunasCovid Vac
	ON  Mue.location = Vac.location
	and Mue.date = Vac.date
WHERE mue.continent IS NOT NULL
--ORDER BY 2,3);

Select * 
FROM PorcentajePoblacionVacunada
