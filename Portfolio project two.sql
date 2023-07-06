use Portfolio_project
go

select * 
from [Nashville-Housing]

--look at the salesDate column
select SaleDate 
from [Nashville-Housing]

--change the SaleDate format

select SaleDate, CONVERT(Date,SaleDate) as Sales_Date
from [Nashville-Housing]

--update the nashville_housing table

update Nashville-Housing
set SaleDate = CONVERT(Date,SaleDate)

--or
ALTER TABLE [Nashville-Housing]
ALTER COLUMN SaleDate date

-- Now lets bring up the SaleDate column
select SaleDate 
from [Nashville-Housing]	

-- populate the propertyAddress column

select *
from [Nashville-Housing]	
--where PropertyAddress is NULL	
order by ParcelID

select ParcelID, count(ParcelID), PropertyAddress, count(PropertyAddress)
from [Nashville-Housing]	
--where PropertyAddress is NULL	
group by ParcelID, PropertyAddress 
having count(ParcelID) = 1

select ParcelID, PropertyAddress, count(*)
from [Nashville-Housing]
group by ParcelID, PropertyAddress
having count(*) > 1


-- join the table on to itself
	-- then populate the null a.PropertyAddress column with the b.PropertyAddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Nashville-Housing] a
join [Nashville-Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Nashville-Housing] a
join [Nashville-Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking Address into individual columns
select PropertyAddress
from[Nashville-Housing]
order by ParcelID

alter table [Nashville-Housing]
alter column PropertyAddress int

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from [Nashville-Housing]

alter table [Nashville-Housing]
add PropertySplitAddress nvarchar(1000)

alter table [Nashville-Housing]
add PropertySplitCity nvarchar(1000)

update [Nashville-Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

update [Nashville-Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

alter table [Nashville-Housing]
drop column ProertySplitAddress

select *
from [Nashville-Housing]

-- Breaking the OwnerAddress column into individual colums using the Parsename function

select
PARSENAME(replace(OwnerAddress, ',', '.') ,3) as OwmerNewAddress
,PARSENAME(replace(OwnerAddress, ',', '.') ,2) as OwnerCity
,PARSENAME(replace(OwnerAddress, ',', '.') ,1) as OwnerState
from [Nashville-Housing]

alter table [Nashville-Housing]
add OwnerSplitAddress nvarchar(1000)

alter table [Nashville-Housing]
add OwnerCity nvarchar(1000)

alter table [Nashville-Housing]
add OwnerState nvarchar(1000)

update [Nashville-Housing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

update [Nashville-Housing]
set OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

update [Nashville-Housing]
set OwnerState = PARSENAME(replace(OwnerAddress, ',', '.') ,1)

select *
from [Nashville-Housing]


--changing y and N yo yes and No

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Nashville-Housing]
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Nashville-Housing]
where SoldAsVacant = 'Y'

update [Nashville-Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

select * 
from [Nashville-Housing]

--Remove duplicates

select ParcelID, PropertyAddress, count(*)
from [Nashville-Housing]
group by ParcelID, PropertyAddress
having count(*) > 1


with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelId,	
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by uniqueID
			 ) row_num

from [Nashville-Housing]
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1

select * 
from [Nashville-Housing]

--delete columns

alter table [Nashville-Housing]
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict