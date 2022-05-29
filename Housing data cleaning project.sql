/*

Cleaning Data in SQL Queries

*/

select *
from portfolioProject..NashvillleHousing

--Standardize Date format

select SaleDate , CONVERT(Date,SaleDate)
from portfolioProject..NashvillleHousing

update NashvillleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvillleHousing
add SalesDateConverted Date;

update NashvillleHousing
SET SalesDateConverted = CONVERT(Date,SaleDate)

select SalesDateConverted , CONVERT(Date,SaleDate)
from portfolioProject..NashvillleHousing

--Populate Property Address data

--In second query, we have joined the same exact table to itself and we said parcel id is same but not the same row by unique id
--for populating null spaces, use isnull(from column,to column).It creates a seperate column.
--now update the column(make sure use alias name not original name ex:a,b)


select PropertyAddress
from portfolioProject..NashvillleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress , b.PropertyAddress)
from portfolioProject..NashvillleHousing a
join portfolioProject..NashvillleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
from portfolioProject..NashvillleHousing a
join portfolioProject..NashvillleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Adress into Individual Columns (Address , City, State)

--In property adress, we have address and city, so we have take out adress seperately(there is comma seperator between)
--Using SubString (The SUBSTRING() function extracts some characters from a string) 
--Using character index (CHARINDEX() function searches for a substring in a string, and returns the position.)
-- minus 1(-1) is done bcoz in the below query it takes value until comma(,),so to obtain value before by initiating -1.
--Plus 1(+1) is done to start value after comma and specicifying the end value by using Length ()
--we cannot seperate 2 values from one column without creating 2 other columns so alter and update table


select PropertyAddress
from portfolioProject..NashvillleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress) )as Address
from portfolioProject..NashvillleHousing



Alter Table NashvillleHousing
add PropertySplitAddress Nvarchar(255);
 
update NashvillleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

Alter Table NashvillleHousing
add PropertySplitCity Nvarchar(255);

update NashvillleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress) )


select *
from portfolioProject..NashvillleHousing

--now for owner address

--instead of using substring which is a long process, use Parse name
--parse name-to delimite data by specific value and it takes value from the last which is odd

select OwnerAddress
from portfolioProject..NashvillleHousing

select
Parsename(replace(OwnerAddress, ',','.'),3)
,Parsename(replace(OwnerAddress, ',','.'),2)
,Parsename(replace(OwnerAddress, ',','.'),1)
from portfolioProject..NashvillleHousing


Alter Table NashvillleHousing
add OwnerSplitAddress Nvarchar(255);
 
update NashvillleHousing
SET OwnerSplitAddress = Parsename(replace(OwnerAddress, ',','.'),3)

Alter Table NashvillleHousing
add OwnerSplitCity Nvarchar(255);

update NashvillleHousing
SET OwnerSplitCity = Parsename(replace(OwnerAddress, ',','.'),2)

Alter Table NashvillleHousing
add OwnerSplitState Nvarchar(255);

update NashvillleHousing
SET OwnerSplitState = Parsename(replace(OwnerAddress, ',','.'),1)

select *
from portfolioProject..NashvillleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

--The CASE command is used is to create different output based on conditions.

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolioProject..NashvillleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant 
	   end
from portfolioProject..NashvillleHousing

update NashvillleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant 
	   end


--Remove Duplicates

--Write as CTE and do some windows functions to find the duplacte value places 
--The ROW_NUMBER() is a window function that assigns a sequential integer to each row within the partition of a result set. 

with RowNumCTE as(
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 ) row_num

from portfolioProject..NashvillleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

--above the query is to find duplicates,now delete it

with RowNumCTE as(
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 ) row_num

from portfolioProject..NashvillleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Deleted 104 duplicate rows ,recheck them

with RowNumCTE as(
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 ) row_num

from portfolioProject..NashvillleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete unused columns like owner name,owner address


select *
from portfolioProject..NashvillleHousing

ALTER table portfolioProject..NashvillleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER table portfolioProject..NashvillleHousing
drop column SaleDate