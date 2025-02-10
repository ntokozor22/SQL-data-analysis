use Portfolio_project
go

select * 
from Raw_Nashville_Housing_Data

select PropertyAddress, OwnerAddress
from Raw_Nashville_Housing_Data

--lets change the SaleDate Format

alter table Raw_Nashville_Housing_Data
alter column SaleDate date

--select *
--from Raw_Nashville_Housing_Data

--now to populate the null values of the PropertyAddress columns

select ParcelID, PropertyAddress, COUNT(ParcelID) as number_of_Appeareances
from Raw_Nashville_Housing_Data
group by ParcelID, PropertyAddress
having COUNT(ParcelID) > 1;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Raw_Nashville_Housing_Data a
join Raw_Nashville_Housing_Data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
--where b.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(b.PropertyAddress,a.PropertyAddress)
from Raw_Nashville_Housing_Data a
join Raw_Nashville_Housing_Data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where b.PropertyAddress is null

update b
set PropertyAddress = ISNULL(b.PropertyAddress,a.PropertyAddress)
from Raw_Nashville_Housing_Data a
join Raw_Nashville_Housing_Data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where b.PropertyAddress is null
------------------------------


--remove any unwanted spaces in the data if there exist
UPDATE Raw_Nashville_Housing_Data
SET ParcelID = TRIM(ParcelID) , 
    LandUse = TRIM(LandUse), 
    PropertyAddress = TRIM(PropertyAddress), 
    LegalReference = TRIM(LegalReference), 
    SoldAsVacant = TRIM(SoldAsVacant), 
    OwnerAddress = TRIM(OwnerAddress), 
    OwnerName = TRIM(OwnerName),
    TaxDistrict = TRIM(TaxDistrict)

-- split the PropertyAdddress column into Address,City and State

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 
from Raw_Nashville_Housing_Data

alter table Raw_Nashville_Housing_Data
add Address nvarchar(1000)

alter table Raw_Nashville_Housing_Data
add City nvarchar(1000)

update Raw_Nashville_Housing_Data
set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

update Raw_Nashville_Housing_Data
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--split the OwnerAddress column
select
PARSENAME(replace(OwnerAddress, ',', '.') ,3) as OwmerNewAddress
,PARSENAME(replace(OwnerAddress, ',', '.') ,2) as OwnerCity
,PARSENAME(replace(OwnerAddress, ',', '.') ,1) as OwnerState
from Raw_Nashville_Housing_Data

alter table Raw_Nashville_Housing_Data
add OwnerSplitAddress nvarchar(1000)

alter table Raw_Nashville_Housing_Data
add OwnerCity nvarchar(1000)

alter table Raw_Nashville_Housing_Data
add State nvarchar(1000)

update Raw_Nashville_Housing_Data
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

update Raw_Nashville_Housing_Data
set OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

update Raw_Nashville_Housing_Data
set State = PARSENAME(replace(OwnerAddress, ',', '.') ,1)


-- change N to No and Y to yes in the SoldAsVacant column

select distinct(SoldAsVacant)
from Raw_Nashville_Housing_Data

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from Raw_Nashville_Housing_Data
where SoldAsVacant = 'Y'

update Raw_Nashville_Housing_Data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-- Remove duplicates from the data
select ParcelID, PropertyAddress, count(*)
from Raw_Nashville_Housing_Data
group by ParcelID, PropertyAddress
having count(*) > 1


with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelID,	
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by uniqueID
			 ) row_num

from Raw_Nashville_Housing_Data
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1

select * 
from Raw_Nashville_Housing_Data

--delete columns

alter table Raw_Nashville_Housing_Data
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table Raw_Nashville_Housing_Data
drop column OwnerName

alter table Raw_Nashville_Housing_Data
drop column YearBuilt


-- calculating some basics statistics for the Acreage column
select MIN(LandValue), MAX(LandValue),AVG(LandValue),STDEV(LandValue), (MAX(LandValue) - MIN(LandValue)) as rangee
from Raw_Nashville_Housing_Data

select MIN(Acreage), MAX(Acreage),AVG(Acreage),STDEV(Acreage), (MAX(Acreage) - MIN(Acreage)) as rangee
from Raw_Nashville_Housing_Data

select MIN(SalePrice), MAX(SalePrice),AVG(SalePrice),STDEV(SalePrice), (MAX(SalePrice) - MIN(SalePrice)) as rangee
from Raw_Nashville_Housing_Data

--replacing null values in Acreage column with average
select ROUND(avg(Acreage),2)
from Raw_Nashville_Housing_Data

update Raw_Nashville_Housing_Data
set Acreage = 0.5
where Acreage is null
 

-- replacing null values of the landValue columns with the
-- mean value of the landvalue of each city
UPDATE  RNHD
SET RNHD.LandValue = subquery.mean_value
FROM Raw_Nashville_Housing_Data RNHD
JOIN (
    SELECT City, AVG(LandValue) AS mean_value
    FROM Raw_Nashville_Housing_Data
    WHERE LandValue IS NOT NULL
    GROUP BY City
) AS subquery ON RNHD.City = subquery.City
WHERE RNHD.LandValue IS NULL;

select * from Raw_Nashville_Housing_Data
where LandValue is null

--deleting the remaining two rows wilth null values in the LandValue columns
delete from  Raw_Nashville_Housing_Data
where LandValue is null

-- replacing null values of the landValue columns with the
-- mean value of the landvalue of each city

UPDATE  RNHD
SET RNHD.TotalValue = subquery.mean_value
FROM Raw_Nashville_Housing_Data RNHD
JOIN (
    SELECT City, round(AVG(TotalValue),2) AS mean_value
    FROM Raw_Nashville_Housing_Data
    WHERE TotalValue IS NOT NULL
    GROUP BY City
) AS subquery ON RNHD.City = subquery.City
WHERE RNHD.TotalValue IS NULL;

--converting decimals to whole numbers

update Raw_Nashville_Housing_Data
set LandValue = ROUND(LandValue,0)

update Raw_Nashville_Housing_Data
set TotalValue = ROUND(TotalValue,0)

select *
from Raw_Nashville_Housing_Data

-- replacing null values in BuildingValues column with the mean
update Raw_Nashville_Housing_Data
set BuildingValue = (Select ROUND(AVG(BuildingValue),0)
from Raw_Nashville_Housing_Data
where BuildingValue is not null)
where BuildingValue is null

--replacing null values in the Bedrooms column with its mode

WITH ModeValue AS (
    SELECT TOP 1 Bedrooms
    FROM Raw_Nashville_Housing_Data
	where Bedrooms is not null
    GROUP BY Bedrooms
    ORDER BY COUNT(*) DESC
)
UPDATE Raw_Nashville_Housing_Data
SET Bedrooms = (SELECT Bedrooms FROM ModeValue)
WHERE Bedrooms IS NULL;