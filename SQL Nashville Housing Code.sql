--Simple data cleaning with the excel file
Select *
From NashvilleHousing


--Converting the SaleDate column to remove the empty space
Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate) 

Select SaleDateConverted, Convert(Date,SaleDate)
From NashvilleHousing


--We find that ParcelID and PropertyAddress are parallel values
Select *
From NashvilleHousing
Order By ParcelID


--Making sure that there are unique IDs before we populate property address
--We will add the non null values from property address in b to a 
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID And
	a.[UniqueID ] <> b.[UniqueID ]	
Where a.PropertyAddress Is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID And
	a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null


--Separating the information in property address
Select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) As Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) As City
From NashvilleHousing

--Adding the separated information above as new columns to the table
Alter Table NashvilleHousing
Add PropertyAddressSplit nvarchar(255);

Update NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) 

Alter Table NashvilleHousing
Add PropertyCitySplit nvarchar(255);

Update NashvilleHousing
Set PropertyCitySplit = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))


--Changing "SoldAsVacant" values into either Yes or No to streamline responses
Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End 
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End

