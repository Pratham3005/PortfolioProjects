use PortifolioProject
/*
Cleaninng data in SQL Queries
*/
select * from NashvileHousing

-- Standardize Data Format

--select SaleDate,CONVERT(Date,SaleDate)
--from NashvileHousing

select SaledateConverted
from NashvileHousing

Update NashvileHousing
set SaleDate = CONVERT(Date,SaleDate)

Alter table NashvileHousing
Add SaleDateConverted date;

Update NashvileHousing
set SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

select * 
from NashvileHousing
--WHere PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvileHousing a
join NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvileHousing a
join NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Adress into individual Columns(Address,City,State)

select PropertyAddress
from NashvileHousing
--WHere PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from NashvileHousing

Alter table NashvileHousing
Add PropertySplitAddress nvarchar(255);

Update NashvileHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter table NashvileHousing
Add PropertySplitCity nvarchar(255);

Update NashvileHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 


select * from NashvileHousing



select OwnerAddress
from NashvileHousing

select
ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),
ParseName(Replace(OwnerAddress,',','.'),1)
from NashvileHousing


Alter table NashvileHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvileHousing
set OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'),3)

Alter table NashvileHousing
Add OwnerSplitCity nvarchar(255);

Update NashvileHousing
set OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'),2) 

Alter table NashvileHousing
Add OwnerSplitState nvarchar(255);

Update NashvileHousing
set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'),1)


select * from NashvileHousing


--Change Y and N and No in "Sold as Vacant" Field

select distinct(SoldAsVacant),count(SoldAsVacant)
From NashvileHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvileHousing


update NashvileHousing
set SoldAsVacant = 
case 
		when SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


-- Remove Duplicates
With RowNumCTE AS(
select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
	PropertyAddress,SalePrice,SaleDate,LegalReference
	Order by UniqueID) row_num
from NashvileHousing
--order by ParcelID
)


--select * 
--from RowNumCTE
--where row_num >1 
--order by PropertyAddress

delete
from RowNumCTE
where row_num >1 
--order by PropertyAddress


-- delete unused columns

select * from NashvileHousing


alter table NashvileHousing
Drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table NashvileHousing
Drop column SaleDate