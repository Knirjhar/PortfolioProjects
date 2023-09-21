SELECT *
FROM Location

-- Looking at the TRI Forms Totals vs. by State: 

-- Total TRI forms in 2021
SELECT COUNT(ID) AS TotalTriForms2021
FROM Location 

-- States that submitted the most TRI forms
SELECT ST, COUNT(ID) AS NumOfTriForms
FROM Location
GROUP BY ST
ORDER BY NumOfTriForms DESC

-- Industry that submitted the most TRI forms
SELECT [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
GROUP BY [INDUSTRY SECTOR]
ORDER BY NumOfTriForms DESC 

-- Industry that submitted the most TRI forms by state
SELECT ST, [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
GROUP BY ST, [INDUSTRY SECTOR]
ORDER BY ST, NumOfTriForms DESC 

-- Percentage of TRI forms were from federal facilities
SELECT((SELECT CAST(COUNT([FEDERAL FACILITY]) AS numeric)
FROM Location 
WHERE [FEDERAL FACILITY] = 'YES')/
(SELECT CAST(COUNT([FEDERAL FACILITY]) AS numeric)
FROM Location) *100) AS PercentTriFedFacility

-- Percentage of TRI forms from federal facilities in each state
WITH CTE_StateFedFacility (ST, FedFacilityCount) AS
(SELECT ST, CAST(COUNT([FEDERAL FACILITY]) AS numeric)
FROM Location 
WHERE [FEDERAL FACILITY] = 'YES'
GROUP BY ST)

SELECT location.ST, FedFacilityCount/ COUNT(ID) *100 AS PercentFedFacilSt 
FROM CTE_StateFedFacility
JOIN Location 
ON CTE_StateFedFacility.ST = Location.ST
GROUP BY Location.ST, FedFacilityCount 
ORDER BY PercentFedFacilSt DESC

-- Taking a closer look at the ST with largest percentage of federal facility
SELECT COUNT (ID) as TriFormCount, [INDUSTRY SECTOR]
FROM Location
WHERE ST = 'DC'
GROUP BY [INDUSTRY SECTOR]

--Industry sector with most TRI forms from Federal Facilities
SELECT [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
WHERE [FEDERAL FACILITY] = 'YES'
GROUP BY [INDUSTRY SECTOR]
ORDER BY NumOfTriForms DESC

--Industry sector with most TRI forms from Federal Facilities by State
SELECT ST, [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
WHERE [FEDERAL FACILITY] = 'YES'
GROUP BY ST, [INDUSTRY SECTOR]
ORDER BY ST, NumOfTriForms DESC

--Industry sector with most TRI forms from non-fedral facilities
SELECT [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
WHERE [FEDERAL FACILITY] = 'NO'
GROUP BY [INDUSTRY SECTOR]
ORDER BY NumOfTriForms DESC

--Industry sector with most TRI forms from non-fedral facilities
SELECT ST, [INDUSTRY SECTOR], COUNT(ID) AS NumOfTriForms
FROM Location
WHERE [FEDERAL FACILITY] = 'NO'
GROUP BY ST, [INDUSTRY SECTOR]
ORDER BY NumOfTriForms DESC

--Looking at ChemicalClass
SELECT * 
FROM ChemicalClass
ORDER BY ID

--Number of distinct chemicals reported
SELECT COUNT(DISTINCT CAS#) as NumOfChem
FROM ChemicalClass

-- State with largest number of distinct chemicals reported
SELECT ST, COUNT(DISTINCT CAS#) as NumOfChem
FROM ChemicalClass
JOIN Location
ON Location.ID = ChemicalClass.ID
GROUP BY ST 
ORDER BY NumOfChem DESC

-- Chemicals most reported on 
SELECT CHEMICAL, COUNT(ID) AS NumOfTriForms
FROM ChemicalClass
GROUP BY CHEMICAL
ORDER BY NumOfTriForms DESC

-- Chemicals most reported on by State 
SELECT ST, CHEMICAL, COUNT(ChemicalClass.ID) AS NumOfTriForms
FROM ChemicalClass
JOIN Location
ON ChemicalClass.ID = Location.ID
GROUP BY ST, CHEMICAL
ORDER BY NumOfTriForms DESC

-- Closer look at the chemical characteristics of toxic waste

-- Number of lead related TRI forms 
SELECT COUNT(CHEMICAL)
FROM ChemicalClass
WHERE CHEMICAL LIKE '%Lead%' OR CHEMICAL LIKE '%lead%'

-- Percentage of reports submitted in refrence to metals
SELECT((SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass 
WHERE METAL = 'YES')/
(SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass) *100) AS PercentOfTriForms

-- Pecentage of reports on carcinogens
SELECT((SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass 
WHERE CARCINOGEN = 'YES')/
(SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass) *100) AS PercentOfTriForms

-- Pecentage of reports submitted for chemicals both metal and carcinogen
SELECT((SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass 
WHERE CARCINOGEN = 'YES' AND METAL = 'YES')/
(SELECT CAST(COUNT(ID) AS numeric)
FROM ChemicalClass) *100) AS PercentOfTriForms

-- Metal category with most carcinogen compunds
SELECT [METAL CATEGORY], COUNT(ID) AS NumOfTriForms
FROM ChemicalClass
WHERE CARCINOGEN = 'Yes'
GROUP BY [METAL CATEGORY]
ORDER BY NumOfTriForms DESC

-- Chemicals not clean air chemicals and carcinogens
SELECT((SELECT CAST(COUNT(DISTINCT CAS#) AS numeric)
FROM ChemicalClass 
WHERE CARCINOGEN = 'YES' AND [CLEAN AIR ACT CHEMICAL] = 'NO')/
(SELECT CAST(COUNT(DISTINCT CAS#) AS numeric)
FROM ChemicalClass) *100) AS PercentOfTriForms

-- Looking at waste production 
SELECT * 
FROM Waste

-- Data Dictionary indicates different Units of Measurement for Waste Release
-- Cheking Units used to measure toxic release
SELECT [UNIT OF MEASURE], COUNT([UNIT OF MEASURE]) AS NumOfTriForms
FROM Waste
GROUP BY [UNIT OF MEASURE]

--Convert evrything to same unit of measure 
CREATE TABLE #TotalReleasesPounds
(ID int, 
TotalReleasesPounds float)

INSERT INTO #TotalReleasesPounds
SELECT ID,
CASE 
WHEN [UNIT OF MEASURE] = 'Grams' THEN [TOTAL RELEASES]/453.6
ELSE [TOTAL RELEASES]
END AS TotalReleasesPounds
FROM Waste

SELECT* 
FROM #TotalReleasesPounds
ORDER BY ID

-- Looking at total waste production totals and by State:  

-- Total amount of toxic chemicals released in 2021
SELECT SUM(TotalReleasesPounds) AS TotalPoundsRelease2021
FROM #TotalReleasesPounds 

-- Total amount of toxic chemcials released by State
SELECT ST, SUM(TotalReleasesPounds) AS TotalPoundsRelease2021
FROM #TotalReleasesPounds 
JOIN Location
ON Location.ID = #TotalReleasesPounds.ID
GROUP BY ST
ORDER BY TotalPoundsRelease2021 DESC

-- Total vs. average amonut of Toxic chemical relased for each TRI form submitted by State
SELECT ST, COUNT(Location.ID) AS NumofTriForms, SUM(TotalReleasesPounds) as StateTotalRelease, AVG(TotalReleasesPounds) as AvgRelease
FROM Location
JOIN #TotalReleasesPounds
ON Location.ID = #TotalReleasesPounds.ID
GROUP BY ST
ORDER BY ST

-- Looking at largest release toxic waste and chemical classification by state
SELECT ST, ChemicalClass.ID, CHEMICAL, [ELEMENTAL METAL INCLUDED], CLASSIFICATION, METAL, CARCINOGEN,TotalReleasesPounds 
FROM ChemicalClass
JOIN #TotalReleasesPounds
ON ChemicalClass.ID = #TotalReleasesPounds.ID
JOIN Location
ON ChemicalClass.ID = Location.ID
ORDER BY ST, TotalReleasesPounds DESC

-- Toxic waste release methods by state
SELECT Location.ID, ST, [UNIT OF MEASURE], [FUGITIVE AIR], [STACK AIR],[UNDERGROUND CL I], [UNDERGROUND C II-V],[RCRA SURFACE IM], 
[LAND TREATMENT], [OTHER SURFACE I], [TotalReleasesPounds]
FROM Waste
JOIN Location
ON Location.ID = Waste.ID
JOIN #TotalReleasesPounds
ON #TotalReleasesPounds.ID = Location.ID
ORDER BY ST, TotalReleasesPounds DESC

