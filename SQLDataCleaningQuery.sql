/*
Cleaning Data
*/

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing;


-- Standardize Date Format

SELECT SaleDate
, CAST(SaleDate AS date)
FROM PortfolioProject2.dbo.NashvilleHousing;

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SaleDate = CAST(SaleDate AS date);

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD SalesDate date;

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SalesDate = CAST(SaleDate AS date);


-- Populate the Property Address

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT nas1.ParcelID
, nas1.PropertyAddress
, nas2.ParcelID
, nas2.PropertyAddress
, ISNULL(nas1.PropertyAddress, nas2.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing nas1
JOIN PortfolioProject2.dbo.NashvilleHousing nas2
ON nas1.ParcelID = nas2.ParcelID
AND nas1.[UniqueID ] <> nas2.[UniqueID ]
WHERE nas1.PropertyAddress IS NULL;

UPDATE nas1
SET PropertyAddress = ISNULL(nas1.PropertyAddress, nas2.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing nas1
JOIN PortfolioProject2.dbo.NashvilleHousing nas2
ON nas1.ParcelID = nas2.ParcelID
AND nas1.[UniqueID ] <> nas2.[UniqueID ]
WHERE nas1.PropertyAddress IS NULL;


-- Split the PropertyAddress and OwnerAddress into different smaller columns (address, city, and state)

-- PropertyAddress

SELECT PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress, 1)) AS City
FROM PortfolioProject2.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertyStreetAddress nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1);

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertyCityAddress nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress, 1));

-- OwnerAddress
-- Cach 1
SELECT OwnerAddress
, SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress, 1) - 1) AS Address
, SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, 1) + 2, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress, 1) - 5) AS City
, RIGHT(OwnerAddress, 2) AS State
FROM PortfolioProject2.dbo.NashvilleHousing;

--Cach 2
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerStreetAddress nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerCityAddress nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerStateAddress nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Change the value 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' field

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject2.dbo.NashvilleHousing;

SELECT CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END
, SoldAsVacant
FROM PortfolioProject2.dbo.NashvilleHousing;

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END;


-- Remove Duplicate

WITH CTE1 AS
(
SELECT *
, ROW_NUMBER() OVER (
	PARTITION BY ParcelID
	, LandUse
	, PropertyAddress
	, SalesDate
	, SalePrice
	, LegalReference
	, SoldAsVacant
	, OwnerName
	 ORDER BY UniqueID) AS rownum
FROM PortfolioProject2.dbo.NashvilleHousing
)
DELETE
FROM CTE1
WHERE rownum > 1;


-- Delete Unused Columns

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate;

 

