--Proyecto limpieda de Datos en SQL Queries

SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville


---------------------------------------------------------------------------
--Estandarizar el formato (cambiarlo)

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM ProyectoPortafolio..ViviendasDeNashville;

--No funciono asi que lo intentamos con alter table
UPDATE ViviendasDeNashville
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE ViviendasDeNashville
ADD SaleDateConvertido Date;

UPDATE ViviendasDeNashville
SET SaleDateConvertido = CONVERT(Date, SaleDate);

SELECT SaleDateConvertido, CONVERT(Date, SaleDate)
FROM ProyectoPortafolio..ViviendasDeNashville;

---------------------------------------------------------------------------

--Arrglar los valores nulos de la direcciòn de la vivienda, diciendo que debe ser la misma que comparta el numero de parcela

SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT uno.ParcelID, uno.PropertyAddress, dos.ParcelID, dos.PropertyAddress, 
ISNULL(uno.PropertyAddress, dos.PropertyAddress)
FROM ProyectoPortafolio..ViviendasDeNashville uno
JOIN ProyectoPortafolio..ViviendasDeNashville dos
	ON uno.ParcelID = dos.ParcelID
	AND uno.[UniqueID ] <> dos.[UniqueID ]
WHERE uno.PropertyAddress IS NULL


UPDATE uno
SET PropertyAddress = ISNULL(uno.PropertyAddress, dos.PropertyAddress)
FROM ProyectoPortafolio..ViviendasDeNashville uno
JOIN ProyectoPortafolio..ViviendasDeNashville dos
	ON uno.ParcelID = dos.ParcelID
	AND uno.[UniqueID ] <> dos.[UniqueID ]
WHERE uno.PropertyAddress IS NULL


SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville
WHERE PropertyAddress is null


---------------------------------------------------------------------------

-- Separar la direcciòn en columnas inviduales (direcciòn, ciudad, estado)

SELECT PropertyAddress
FROM ProyectoPortafolio..ViviendasDeNashville


SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) As Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) As Ciudad
FROM ProyectoPortafolio..ViviendasDeNashville


ALTER TABLE ViviendasDeNashville
ADD OnlyAddress nvarchar(255);

UPDATE ViviendasDeNashville
SET OnlyAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE ViviendasDeNashville
ADD OnlyCity nvarchar(255);

UPDATE ViviendasDeNashville
SET OnlyCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))


SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville;


--Otra forma de hacerlo

SELECT OwnerAddress
FROM ProyectoPortafolio..ViviendasDeNashville;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM ProyectoPortafolio..ViviendasDeNashville


ALTER TABLE ViviendasDeNashville
ADD OnlyOwnerAddress nvarchar(255);

UPDATE ViviendasDeNashville
SET OnlyOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE ViviendasDeNashville
ADD OnlyOwnerCity nvarchar(255);

UPDATE ViviendasDeNashville
SET OnlyOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE ViviendasDeNashville
ADD OnlyOwnerState nvarchar(255);

UPDATE ViviendasDeNashville
SET OnlyOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville;


---------------------------------------------------------------------------

--Cambiar Y por yes y N por No en el campo "Sold as vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProyectoPortafolio..ViviendasDeNashville
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProyectoPortafolio..ViviendasDeNashville



UPDATE ViviendasDeNashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


---------------------------------------------------------------------------

-- Quitar los duplicados

WITH RownumCTE AS (
SELECT *,
ROW_NUMBER() OVER
(PARTITION BY ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
				UniqueID) as row_num

FROM ProyectoPortafolio..ViviendasDeNashville
--ORDER BY ParcelID
)

--Aca eliminamos los que tenian duplicados primero lo tuvimos con select para verificar
DELETE
FROM RownumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Aca revisamos simplemente que haya funcionado viendo que ya no no salen columnas con doble conteo

WITH RownumCTE AS (
SELECT *,
ROW_NUMBER() OVER
(PARTITION BY ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
				UniqueID) as row_num

FROM ProyectoPortafolio..ViviendasDeNashville
--ORDER BY ParcelID
)


SELECT *
FROM RownumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




---------------------------------------------------------------------------


--Eliminamos columnas que no se usan (solo en view no en data cruda)


SELECT *
FROM ProyectoPortafolio..ViviendasDeNashville

ALTER TABLE ProyectoPortafolio..ViviendasDeNashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProyectoPortafolio..ViviendasDeNashville
DROP COLUMN SaleDate









