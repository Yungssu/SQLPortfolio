
SELECT *
	FROM Portfolio..NashvilleHousing


--Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
	FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
	ALTER COLUMN SaleDate Date

--Populate Property Address Data

SELECT PropertyAddress
	FROM Portfolio..NashvilleHousing
	WHERE PropertyAddress is NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
	FROM Portfolio..NashvilleHousing AS A
	JOIN Portfolio..NashvilleHousing AS B
		ON A.ParcelID = B.ParcelID
		AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE A.PropertyAddress is NULL

UPDATE A 
	SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
		FROM Portfolio..NashvilleHousing AS A
		JOIN Portfolio..NashvilleHousing AS B
		ON A.ParcelID = B.ParcelID
		AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE A.PropertyAddress is NULL

-- Breaking out Address into Individual Columns
SELECT PropertyAddress
	FROM Portfolio..NashvilleHousing

SELECT SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
		SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address 
	FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity nvarchar(255);
	
UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT OwnerAddress
	FROM Portfolio..NashvilleHousing

SELECT
	PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
	FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress nvarchar(255);
	
UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity nvarchar(255);
	
UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState nvarchar(255);
	
UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM Portfolio..NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY SoldAsVacant


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

FROM Portfolio..NashvilleHousing


UPDATE NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

-- Removing Duplicates
	
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID ) row_num
	FROM Portfolio..NashvilleHousing
	)
DELETE
	FROM RowNumCTE
	WHERE row_num > 1
	
-- Delete Unused Columns
ALTER TABLE Portfolio..NashvilleHousing
	DROP COLUMN	OwnerAddress, TaxDistrict, PropertyAddress

