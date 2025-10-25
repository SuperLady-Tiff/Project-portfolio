/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM ProjectLearning..NashvilleHousing;

-------------------------------------------------------------------------------------------------------------------
-- 1.Standardize Data Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM ProjectLearning..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

-- It doesn¡¯t update properly. The SaleDate column in the table is originally of type datetime.
-- So when you do CONVERT(Date, SaleDate), it becomes something like 2021-08-01,
-- but SQL Server automatically converts it back to datetime (because the column¡¯s data type hasn¡¯t changed).
-- As a result, it looks like nothing has changed.

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

SELECT SaleDate
FROM ProjectLearning..NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------
-- 2.Populate Property Adderss data
SELECT *
FROM ProjectLearning..NashvilleHousing
--WHERE propertyaddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectLearning..NashvilleHousing a
JOIN ProjectLearning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectLearning..NashvilleHousing a
JOIN ProjectLearning..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


---------------------------------------------------------------------------------------------------------------------
-- 3.Breaking out Address into Individual columns (Address, City, State)
SELECT PropertyAddress
FROM ProjectLearning..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM ProjectLearning..NashvilleHousing

ALTER TABLE ProjectLearning..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE ProjectLearning..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE ProjectLearning..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE ProjectLearning..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM ProjectLearning..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM ProjectLearning..NashvilleHousing

ALTER TABLE ProjectLearning..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE ProjectLearning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE ProjectLearning..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE ProjectLearning..NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE ProjectLearning..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE ProjectLearning..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


---------------------------------------------------------------------------------------------------------------------
-- 4.Change Y and N to Yes and No in "Sold As Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectLearning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProjectLearning..NashvilleHousing

UPDATE ProjectLearning..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


---------------------------------------------------------------------------------------------------------------------
-- 5.Remove Duplicates
-- (Not a standard practice to delete data in the database)
WITH RownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM ProjectLearning..NashvilleHousing
)
DELETE
FROM RownumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------------------
-- 6.Delete Unused Columns  

ALTER TABLE ProjectLearning..NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

