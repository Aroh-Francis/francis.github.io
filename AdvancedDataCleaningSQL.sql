

-- data Cleaning in SQL es

*/


SELECT *
FROM Francis_Portfolio_Project..NashvilleHousing     

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Our column is a date/time format, standardize it by eliminating the time and leaving just the date

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM Francis_Portfolio_Project..NashvilleHousing    


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Alternatively

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address 
-- There are properties with missing address. 

SELECT *
FROM Francis_Portfolio_Project..NashvilleHousing 
--Where PropertyAddress is null
order by ParcelID



Select Adem.ParcelID, Adem.PropertyAddress, Bem.ParcelID, Bem.PropertyAddress, ISNULL(Adem.PropertyAddress,Bem.PropertyAddress)
FROM Francis_Portfolio_Project..NashvilleHousing Adem
JOIN Francis_Portfolio_Project..NashvilleHousing Bem
	on Adem.ParcelID = Bem.ParcelID
	AND Adem.[UniqueID ] <> Bem.[UniqueID ]
Where Adem.PropertyAddress is null





UPDATE Adem
SET PropertyAddress = ISNULL(Adem.PropertyAddress,Bem.PropertyAddress)
FROM Francis_Portfolio_Project..NashvilleHousing Adem 
JOIN Francis_Portfolio_Project..NashvilleHousing Bem
	ON Adem.ParcelID = Bem.ParcelID
	AND Adem.[UniqueID ] <> Bem.[UniqueID ]
WHERE Adem.PropertyAddress is null


--SELECT *
--FROM Francis_Portfolio_Project..NashvilleHousing 

--------------------------------------------------------------------------------------------------------------------------

-- The Address contains multiple information that can be split into small columns of Address, City, and State


SELECT PropertyAddress
FROM Francis_Portfolio_Project..NashvilleHousing 
--WHERE PropertyAddress is null
--ORDER by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM Francis_Portfolio_Project..NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))










SELECT OwnerAddress
FROM Francis_Portfolio_Project..NashvilleHousing 


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Francis_Portfolio_Project..NashvilleHousing 



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
FROM Francis_Portfolio_Project..NashvilleHousing 




--------------------------------------------------------------------------------------------------------------------------


-- Update Table and Set Y to be Yes and N to be No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Francis_Portfolio_Project..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Francis_Portfolio_Project..NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- It is not advicable to delete from your databade but for sample purpose we will remove all Duplicates in this dataset.
--Setup CTE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Francis_Portfolio_Project..NashvilleHousing 
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM Francis_Portfolio_Project..NashvilleHousing 




---------------------------------------------------------------------------------------------------------

-- Also not recommended but to knowledge and education purposes I will delete unused columns, 



SELECT *
FROM Francis_Portfolio_Project..NashvilleHousing 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


