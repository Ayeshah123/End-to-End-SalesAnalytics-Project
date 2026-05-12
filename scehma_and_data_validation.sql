USE SalesData
GO

-- ********** Primary Key **********
ALTER TABLE Calendar
ADD CONSTRAINT PK_Calendar
PRIMARY KEY (Date_Key)
GO

ALTER TABLE Geography
ADD CONSTRAINT PK_Geography
PRIMARY KEY (Geography_Key)
GO

ALTER TABLE Product_Category
ADD CONSTRAINT PK_Product_Category
PRIMARY KEY (Product_Category_Key)
GO

ALTER TABLE Product_Subcategory
ADD CONSTRAINT PK_Product_Subcategory
PRIMARY KEY (Product_Subcategory_Key)
GO

ALTER TABLE Products
ADD CONSTRAINT PK_Products
PRIMARY KEY (Product_Key)
GO

ALTER TABLE Sales
ADD CONSTRAINT PK_Sales
PRIMARY KEY (Sales_Key)
GO

ALTER TABLE Stores
ADD CONSTRAINT PK_Stores
PRIMARY KEY (Store_Key)
GO

-- ********** FOREIGN KEYS **********

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Calendar
FOREIGN KEY (Date_Key)
REFERENCES Calendar(Date_Key)
GO

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Product
FOREIGN KEY (Product_Key)
REFERENCES Products(Product_Key)
GO

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Stores
FOREIGN KEY (Store_Key)
REFERENCES Stores(Store_Key)
GO

ALTER TABLE Stores
ADD CONSTRAINT FK_Stores_Geography
FOREIGN KEY (Geography_Key)
REFERENCES Geography(Geography_Key)
GO

ALTER TABLE Products
ADD CONSTRAINT FK_Product_ProductSubcategory
FOREIGN KEY (Product_Subcategory_Key)
REFERENCES Product_Subcategory(Product_Subcategory_Key)
GO

ALTER TABLE Product_Subcategory
ADD CONSTRAINT FK_ProductSubcategory_ProductCategory
FOREIGN KEY (Product_Category_Key)
REFERENCES Product_Category(Product_Category_Key)
GO

-- ********** DATA QUALITY CHECKS *********

-- Calendar Table
SELECT
	SUM(CASE
			WHEN Date_Key IS NULL THEN 1
			ELSE 0
		END) AS [DateKey_Count]
FROM Calendar


-- Geography Table
SELECT
	SUM(CASE
			WHEN Geography_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_GeographyKey_Count]
FROM Geography

-- Product Category Table
SELECT
	SUM(CASE
			WHEN Product_Category_Key IS NULL THEN 1
			ELSE 0
	END) AS [Null_ProductCategoryKey_Count]
FROM Product_Category


-- Product Subcategory Table
SELECT
	SUM(CASE
			WHEN Product_Subcategory_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_ProductSubcategoryKey_Count]
FROM Product_Subcategory

-- Products Table
SELECT
	SUM(CASE
			WHEN Product_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_ProductKey_Count],
	SUM(CASE
			WHEN Product_Subcategory_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_ProductSubcategoryKey_Count]
FROM Products

-- Sales Table
SELECT
	SUM(CASE
			WHEN Sales_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_SalesKey_Count],
	SUM(CASE
			WHEN Date_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_DateKey_Count],
	SUM(CASE
			WHEN Product_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_ProductKey_Count],
	SUM(CASE
			WHEN Store_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_StoreKey_Count]
FROM Sales

-- Store Table
SELECT
	SUM(CASE
			WHEN Store_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_StoreKey_Count],
	SUM(CASE
			WHEN Geography_Key IS NULL THEN 1
			ELSE 0
		END) AS [Null_GeographyKey_Count]
FROM Stores



-- ************** CHECKING DUPLICATES ****************

SELECT Date_Key, COUNT(Date_Key) AS [DateKey_Count]
FROM Calendar
GROUP BY Date_Key
HAVING COUNT(Date_Key) > 1

SELECT Geography_Key, COUNT(Geography_Key) AS [GeographyKey_Count]
FROM Geography
GROUP BY Geography_Key
HAVING COUNT(Geography_Key) > 1;

SELECT Product_Category_Key, COUNT(Product_Category_Key) AS [Product_CategoryKey_Count]
FROM Product_Category
GROUP BY Product_Category_Key
HAVING COUNT(Product_Category_Key) > 1;

SELECT Product_Subcategory_Key, COUNT(Product_Subcategory_Key) AS [Product_SubcategoryKey_Count]
FROM Product_Subcategory
GROUP BY Product_Subcategory_Key
HAVING COUNT(Product_Subcategory_Key) > 1;

SELECT Product_Key, COUNT(Product_Key) AS [ProductKey_Count]
FROM Products
GROUP BY Product_Key
HAVING COUNT(Product_Key) > 1;

SELECT Sales_Key, COUNT(Sales_Key) AS [SalesKey_Count]
FROM Sales
GROUP BY Sales_Key
HAVING COUNT(Sales_Key) > 1;

SELECT Store_Key, COUNT(Store_Key) AS [StoreKey_Count]
FROM Stores
GROUP BY Store_Key
HAVING COUNT(Store_Key) > 1;


-- ************ Data Validation ***********
-- Date Key (Sales Table)
SELECT s.Date_Key
FROM Sales s
LEFT JOIN Calendar c
	ON s.Date_Key = c.Date_Key
WHERE c.Date_Key IS NULL;

--Store Key (Sales Table)
SELECT sl.Store_Key
FROM Sales sl
LEFT JOIN Stores st
	ON sl.Store_Key = st.Store_Key
WHERE st.Store_Key IS NULL;
 
 -- Product Key (Sales Table)
SELECT s.Product_Key
FROM Sales s
LEFT JOIN Products p
	ON s.Product_Key = s.Product_Key
WHERE p.Product_Key IS NULL;

-- Product Subcategory (Products Table)
SELECT p.Product_Subcategory_Key
FROM Products p
LEFT JOIN Product_Subcategory ps
	ON p.Product_Subcategory_Key = ps.Product_Subcategory_Key
WHERE ps.Product_Subcategory_Key IS NULL;

--  Product Category (Product Subcategory Table)
SELECT
	pc.Product_Category_Key
FROM
	Product_Subcategory ps
LEFT JOIN Product_Category pc
	ON ps.Product_Category_Key = pc.Product_Category_Key
WHERE
	pc.Product_Category_Key IS NULL;

-- Geography (Store Table)
SELECT s.Geography_Key
FROM Stores s
LEFT JOIN Geography g
	ON s.Geography_Key = g.Geography_Key
WHERE s.Geography_Key IS NULL;


-- Changed Continent Name from 'Asia' to 'Australia
UPDATE Geography
SET Continent_Name = 'Australia'
WHERE Country = 'Australia';

-- Replaced Nulls in Country column with most frequent countries under each Continent Name
WITH Find_Count AS(
	SELECT 
		Continent_Name, Country,
		ROW_NUMBER() OVER(PARTITION BY Continent_Name ORDER BY COUNT(*) DESC) AS Ranking 
	FROM Geography
	WHERE Continent_Name IN ('Europe', 'Asia', 'North America')
	GROUP BY Continent_Name, Country
	)

UPDATE Geography
SET Country = (SELECT Country FROM Find_Count WHERE Ranking = 1 AND Continent_Name = 'North America')
WHERE Country IS NULL AND Continent_Name = 'North America';


WITH Find_Count AS(
	SELECT 
		Continent_Name, Country,
		ROW_NUMBER() OVER(PARTITION BY Continent_Name ORDER BY COUNT(*) DESC) AS Ranking 
	FROM Geography
	WHERE Continent_Name IN ('Europe', 'Asia', 'North America')
	GROUP BY Continent_Name, Country
	)

UPDATE Geography
SET Country = (SELECT Country FROM Find_Count WHERE Ranking = 1 AND Continent_Name = 'Europe')
WHERE Country IS NULL AND Continent_Name = 'Europe';

WITH Find_Count AS(
	SELECT 
		Continent_Name, Country,
		ROW_NUMBER() OVER(PARTITION BY Continent_Name ORDER BY COUNT(*) DESC) AS Ranking 
	FROM Geography
	WHERE Continent_Name IN ('Europe', 'Asia', 'North America')
	GROUP BY Continent_Name, Country
	)

UPDATE Geography
SET Country = (SELECT Country FROM Find_Count WHERE Ranking = 1 AND Country = 'Asia')
WHERE Country IS NULL AND Continent_Name = 'Asia';

-- Adde Revenue and Profit columns in Sales table
-- Revenue Column
ALTER TABLE Sales
ADD Revenue DECIMAL(10,2)

UPDATE Sales
SET Revenue = Unit_Price * Sales_Quantity;

-- Profit Column
ALTER TABLE Sales
ADD Profit DECIMAL(10,2)

UPDATE Sales
SET Profit = Revenue - Total_Cost;

-- Profit Margin Column
ALTER TABLE Sales
ADD Profit_Margin DECIMAL(10, 2)

UPDATE Sales
SET Profit_Margin = Profit/Revenue;

