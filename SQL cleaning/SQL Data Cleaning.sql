/*
Data Cleaning in SQL
*/


-- check
SELECT *
FROM PortfolioProject..Nashville;


-- renaming columns
EXEC sp_rename 'Nashville.UniqueID', 'unique_id', 'COLUMN';
EXEC sp_rename 'Nashville.ParcelID', 'parcel_id', 'COLUMN';
EXEC sp_rename 'Nashville.PropertyAddress', 'property_address', 'COLUMN';
EXEC sp_rename 'Nashville.SaleDate', 'sale_date', 'COLUMN';
EXEC sp_rename 'Nashville.OwnerAddress', 'owner_address', 'COLUMN';
EXEC sp_rename 'Nashville.SoldAsVacant', 'sold_as_vacant', 'COLUMN';
EXEC sp_rename 'Nashville.SalePrice', 'sale_price', 'COLUMN';
EXEC sp_rename 'Nashville.LegalReference', 'legal_reference', 'COLUMN';



-- removing hh:mi:ss in sale_date data
ALTER TABLE Nashville
ADD sale_date_clean DATE;

UPDATE Nashville
SET sale_date_clean = CONVERT(DATE, sale_date);


-- filling/assigning values for property_address data
SELECT property_address
FROM PortfolioProject.dbo.Nashville
ORDER BY property_address; 

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, ISNULL(a.property_address, b.property_address)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id ]<> b.[unique_id ]
WHERE a.property_address IS NULL

UPDATE a
SET property_address = ISNULL(a.property_address,b.property_address)
FROM PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id ] <> b.[unique_id ]
WHERE a.property_address IS NULL


-- separating address, city and state from property_address and owner_address
SELECT property_address, owner_address
FROM PortfolioProject.dbo.Nashville

SELECT
PARSENAME(REPLACE(property_address, ',', '.'), 2) AS property_address_clean
,
PARSENAME(REPLACE(property_address, ',', '.'), 1) AS property_city_clean
,
PARSENAME(REPLACE(owner_address, ',', '.'), 3) AS owner_address_clean
,
PARSENAME(REPLACE(owner_address, ',', '.'), 2) AS owner_city_clean
,
PARSENAME(REPLACE(owner_address, ',', '.'), 1) AS owner_state_clean
FROM PortfolioProject.dbo.Nashville

-----------------------------------
ALTER TABLE Nashville
ADD property_address_clean NVARCHAR(300)

UPDATE Nashville
SET property_address_clean = PARSENAME(REPLACE(property_address, ',', '.'), 2)
------------------------------------
ALTER TABLE Nashville
ADD property_city_clean NVARCHAR(300)

UPDATE Nashville
SET property_city_clean = PARSENAME(REPLACE(property_address, ',', '.'), 1)
------------------------------------
ALTER TABLE Nashville
ADD owner_address_clean NVARCHAR(300)

UPDATE Nashville
SET owner_address_clean = PARSENAME(REPLACE(owner_address, ',', '.'), 3)
------------------------------------
ALTER TABLE Nashville
ADD owner_city_clean NVARCHAR(300)

UPDATE Nashville
SET owner_city_clean = PARSENAME(REPLACE(owner_address, ',', '.'), 2)

------------------------------------
ALTER TABLE Nashville
ADD owner_state_clean NVARCHAR(300)


UPDATE Nashville
SET owner_state_clean = PARSENAME(REPLACE(owner_address, ',', '.'), 1)


-- changing Y and N to Yes and No in sold_as_vacant column
SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant) AS count
FROM PortfolioProject..Nashville
GROUP BY sold_as_vacant
ORDER BY count DESC 

SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	 WHEN sold_as_vacant = 'N' THEN 'No'
	 ELSE sold_as_vacant 
	 END AS sold_as_vacant_cleaned
FROM PortfolioProject..Nashville

UPDATE Nashville
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
					 WHEN sold_as_vacant = 'N' THEN 'No'
				     ELSE sold_as_vacant 
					 END 


-- removing duplicates using a backup table
SELECT *
INTO Backup_Nashville
FROM
[dbo].[Nashville]

WITH backupCTE AS(
Select *, 
ROW_NUMBER() 
OVER (PARTITION BY parcel_id,
			       property_address,
				   sale_price,
				   sale_date,
				   legal_reference
				   ORDER BY unique_id) row_num

From PortfolioProject.dbo.Backup_Nashville
)
DELETE 
From backupCTE
Where row_num > 1


-- deleting property_address, owner_address and sale_date 
-- renaming cleaned columns 
ALTER TABLE Nashville
DROP COLUMN property_address, sale_date, owner_address

EXEC sp_rename 'Nashville.sale_date_clean', 'sale_date', 'COLUMN';
EXEC sp_rename 'Nashville.property_address_clean', 'property_address', 'COLUMN';
EXEC sp_rename 'Nashville.property_city_clean', 'property_city', 'COLUMN';
EXEC sp_rename 'Nashville.owner_address_clean', 'owner_address', 'COLUMN';
EXEC sp_rename 'Nashville.owner_city_clean', 'owner_city', 'COLUMN';
EXEC sp_rename 'Nashville.owner_state_clean', 'owner_state', 'COLUMN';

