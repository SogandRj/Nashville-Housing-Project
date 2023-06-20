SELECT * 
FROM PortfolioProject2..NashvilleHousing


-------------------------------------Standardize Date Format:
SELECT SaleDate
FROM PortfolioProject2..NashvilleHousing

--*This didnt work
--SELECT SaleDate, CONVERT(date,SaleDate) as SaleDateEdited
--FROM PortfolioProject2..NashvilleHousing

--*Instead I tried this:
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE


------------------------------------- Populate Property Adress Data:
SELECT * 
FROM PortfolioProject2..NashvilleHousing
where PropertyAddress is null
order by ParcelID 


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------- breaking out Adresses into individual columns(Address , City, State)

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1) as address , 
SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) ) as City
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--* Easier Way To Split Adress Parts:

SELECT OwnerAddress
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)


------------------------------------- Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant Field:
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------- Remove Duplicates:
WITH RowNumCTE AS (
SELECT * , ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY uniqueID
						) row_num
FROM PortfolioProject2..NashvilleHousing
)

SELECT * 
FROM RowNumCTE
where row_num > 1

DELETE
FROM RowNumCTE
where row_num > 1

------------------------------------- Delete Unused Columns:
ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COlUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT * 
FROM PortfolioProject2..NashvilleHousing
