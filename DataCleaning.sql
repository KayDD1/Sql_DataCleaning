/*
Cleaning Data In SQL Queries
*/

Select * 
From NashvilleHousing..Nashville

-- STANDARDIZE DATE FORMAT

Select SaleDate, CONVERT(date, SaleDate) as NewSaleDate
From NashvilleHousing..Nashville

Update Nashville
Set SaleDate = CAST(SaleDate as date) 

-- Created another Column to the right date
Alter Table Nashville
Add SaleDateConverted Date;
-- updated the new table with the previuos date
Update Nashville
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(date, SaleDate) as NewSaleDate
From NashvilleHousing..Nashville

-- POPULATE PROPERTY ADDRESS DATA

Select *
From NashvilleHousing..Nashville
--Where PropertyAddress IS NULL
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..Nashville a
Join NashvilleHousing..Nashville b
	On a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..Nashville a
Join NashvilleHousing..Nashville b
	On a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

--Splitting out strings with substring
-- Separating Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing..Nashville
--Where PropertyAddress IS NULL
--Order By ParcelID

Select SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as State
From NashvilleHousing..Nashville

Alter Table Nashville
Add PropertySplitAddress NVARCHAR(255);

Update Nashville
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table Nashville
Add PropertySplitState NVARCHAR(255);

Update Nashville
Set PropertySplitState = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * From Nashville

--OWNER ADDRESS: Splitting out strings with parsename

Select OwnerAddress
From Nashville

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',','.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
From Nashville

Alter Table Nashville
Add OwnerSplitAddress NVARCHAR(255)

Update Nashville
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table Nashville
Add OwnerSplitCity NVARCHAR(255)


Update Nashville
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table Nashville
Add OwnerSplitState NVARCHAR(255)


Update Nashville
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select * From Nashville

-- CHANGE Y and N TO YES and NO in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End 
From Nashville

Update Nashville
Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End 

-- REMOVE DUPLICATES
-- Visualize duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
				 UniqueID
				 ) row_num
From Nashville
)
Select * From RowNumCTE
Where row_num > 1
Order By PropertyAddress


-- Delete Duplicates
-- It is not advisable to delete data from database
-- instead, add it to a temp table

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
				 UniqueID
				 ) row_num
From Nashville
)
Delete From RowNumCTE
Where row_num > 1

-- DELETE UNUSED COLUMNS
-- Columns are usually not deleted from raw data instead it's deleted in views

Select * 
From Nashville


Alter Table Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Nashville
Drop Column SaleDate









































