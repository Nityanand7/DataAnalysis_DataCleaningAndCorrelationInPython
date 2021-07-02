/*
SQL Queries for Data Cleaning
*/

Select *
From PortfolioProj..NashvilleHousing

----------------------------------------------------

-- Standardized Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProj..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

----------------------------------------------------

-- Populate Property address

Select *
From PortfolioProj..NashvilleHousing
order by ParcelID


Select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, isNull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProj..NashvilleHousing a
JOIN PortfolioProj..NashvilleHousing b
	on a.ParcelId = b.ParcelId
	AND a.[UniqueId] <> b.[UniqueID]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = isNull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProj..NashvilleHousing a
JOIN PortfolioProj..NashvilleHousing b
	on a.ParcelId = b.ParcelId
	AND a.[UniqueId] <> b.[UniqueID]
Where a.PropertyAddress is null

----------------------------------------------------

-- Breadking down the address

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
From PortfolioProj..NashvilleHousing


ALTER Table NashvilleHousing
Add PropertySpiltAddress nvarchar(255)

Update NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER Table NashvilleHousing
Add PropertySpiltCity nvarchar(255)

Update NashvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))



Select * 
From PortfolioProj..NashvilleHousing



Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProj..NashvilleHousing


ALTER Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select * 
From PortfolioProj..NashvilleHousing

----------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProj..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProj..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
				   When SoldAsVacant = 'N' Then 'No'
				   Else SoldAsVacant
				   END


----------------------------------------------------------------------------------

-- Removing Duplicates

With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueId
				 ) row_num

From PortfolioProj..NashvilleHousing
)

Delete 
From RowNumCTE
Where row_num > 1


With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueId
				 ) row_num

From PortfolioProj..NashvilleHousing
)

Select * 
From RowNumCTE
Where row_num > 1


----------------------------------------------------------------------------------

-- Deleting Unusused Columns

Select *
From PortfolioProj..NashvilleHousing

Alter Table PortfolioProj..NashvilleHousing
Drop Column SaleDate, OwnerAddress, PropertyAddress, TaxDistrict