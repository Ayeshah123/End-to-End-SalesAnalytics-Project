USE SalesData
GO

-- ******************* Overall Business Performance *******************
-- Overall %Profit Margin
CREATE VIEW OverallProfitMarginPercentage AS
	SELECT
		CAST(
			ROUND(SUM(Profit) * 100.00 / SUM(Revenue), 2)
			AS DECIMAL(5,2)) AS [%Profit Margin]
	FROM Sales;
GO

SELECT * FROM OverallProfitMarginPercentage;


-- Business Profitability Performance 
CREATE VIEW YearlySummary AS
	WITH Yearly_Profitability AS(
		SELECT
			YEAR(Date_Key) AS [Year],
			SUM(Total_Cost) AS [Total Cost],
			SUM(Revenue) AS [Total Revenue],
			SUM(Profit) AS [Total Profit]
		FROM Sales
		GROUP BY YEAR(Date_Key)
		)
	SELECT
		Year,
		[Total Cost],
		[Total Revenue],
		[Total Profit],
		CAST(ROUND(([Total Profit] * 100.00 /[Total Revenue]), 2) AS DECIMAL(10,2))
			AS [%Profit Margin]
	FROM
		Yearly_Profitability;
GO

SELECT * FROM YearlySummary
ORDER BY Year;
GO

-- Profit by Year and Month
CREATE VIEW ProfitByYearAndMonth AS
	WITH FindProfitMarginbyMonth AS(
		SELECT
			c.Month_Of_Year AS Month_Number,
			c.Year AS Sales_Year,
			c.Month_Name,
			CAST(
				ROUND((SUM(Profit) * 100.00 / SUM(Revenue)), 2)
				AS DECIMAL(10,2)
				) AS [%Profit_Margin]
		FROM
			Sales s
		LEFT JOIN Calendar c
			ON s.Date_Key = c.Date_Key
		GROUP BY
			c.Month_Of_Year, c.Year, c.Month_Name
	)
	SELECT
		Month_Number,
		[Month_Name],
		[2011],
		[2012],
		[2013]
	FROM
		FindProfitMarginbyMonth
	PIVOT (
		MAX([%Profit_Margin])
		FOR Sales_Year
		IN ([2011], [2012], [2013])
	) AS PivotTable
	
GO

SELECT * FROM ProfitByYearAndMonth
ORDER BY Month_Number;
GO


-- Quarterly Profit Trend
CREATE VIEW QuarterlyProfitTrend AS
	SELECT
		c.Quarter_Of_Year,
		CAST(
			ROUND(SUM(sl.Profit) * 100.00 /SUM(sl.Revenue), 2)
			AS DECIMAL(5,2)
			) AS [%Profit Margin]
	FROM
		Sales sl
	LEFT JOIN Calendar c
		ON c.Date_Key = sl.Date_Key
	GROUP BY
		c.Quarter_Of_Year;
GO

SELECT * FROM QuarterlyProfitTrend
ORDER BY Quarter_Of_Year;
GO


-- Profit Trend across Year and Quarters
CREATE VIEW ProfitByYearAndQuarters AS
	SELECT
		[Year],
		[2] AS [Q2],
		[3] AS [Q3],
		[4] AS [Q4]
	FROM(
		SELECT
			c.Year,
			c.Quarter_Of_Year AS [Quarters],
			CAST(
				ROUND(SUM(sl.Profit) * 100.00 /SUM(sl.Revenue), 2)
				AS DECIMAL(5,2)
				) AS [%Profit Margin]
		FROM
			Sales sl
		LEFT JOIN Calendar c
			ON c.Date_Key = sl.Date_Key
		GROUP BY
			c.Year,
			c.Quarter_Of_Year) AS [Table]
		PIVOT(
			MAX([%Profit Margin])
			FOR Quarters
			IN([2], [3], [4]) ) AS [PivotTable]
GO

SELECT * FROM ProfitByYearAndQuarters;
GO

--Total revenue and Total Profit in each year - % change rate for each year
CREATE VIEW ChangeRatePerYear AS
	WITH Find_ChangeRate AS(
		SELECT
			YEAR(Date_Key) AS [Year],
			SUM(Revenue) AS [Total Revenue],
			SUM(Profit) AS [Total Profit]
		FROM
			Sales
		GROUP BY
			YEAR(Date_Key)),
	
	Find_PreviousProfitAndRevenue AS(
		SELECT
			[Year],
			[Total Revenue],
			LAG(
				[Total Revenue]) OVER(ORDER BY Year) AS [Prev_Total_Revenue],
			[Total Profit],
			LAG(
				[Total Profit]) OVER(ORDER BY Year) AS [Prev_Total_Profit]
		FROM
			Find_ChangeRate)

	SELECT
		Year,
		[Total Revenue],
		Prev_Total_Revenue,
		[Total Profit], 
		CAST(
			ROUND((([Total Revenue] - [Prev_Total_Revenue]) * 100/Prev_Total_Revenue), 1) AS DECIMAL(10,2))
			AS [RevenueChangeRate],
		CAST(
			ROUND((([Total Profit] - [Prev_Total_Profit]) * 100/Prev_Total_Profit), 1) AS DECIMAL(10,2)) AS [%ProfitChangeRate]
	FROM Find_PreviousProfitAndRevenue;
GO

SELECT * FROM ChangeRatePerYear;
GO

-- ********************* Profit by Dimensions *********************
-- Profit & Margin by Product class
CREATE VIEW ProfitMarginByProductClass AS
	WITH ProfitByProductClass AS(
		SELECT
			p.Class_Name AS [Product Class],
			SUM(s.Profit) AS [Total Profit],
			CAST(
				ROUND(
					SUM(s.Profit) * 100.00 / SUM(s.Revenue), 2)
					AS DECIMAL(5,2)) AS [%Profit Margin]
		FROM
			Sales s
		LEFT JOIN Products p
			ON s.Product_Key = p.Product_Key
		GROUP BY
			p.Class_Name)
	SELECT * FROM ProfitByProductClass
	GO

SELECT * FROM ProfitMarginByProductClass
ORDER BY [%Profit Margin] DESC;
GO

-- Profit & Margin by Product Category across months
CREATE VIEW ProfitByProductAndMonths AS
	WITH Find_Profit AS(
		SELECT Product_Category, [2] AS [Q2], [3] AS [Q3], [4] AS [Q4]
		FROM (
			SELECT
				pc.Product_Category AS Product_Category,
				c.Quarter_Of_Year AS 'Quarters',
				CAST(ROUND(SUM(s.Profit) * 100.00 / SUM(s.Revenue), 2) AS DECIMAL(5,2)) AS [%Profit Margin]
			FROM
				Sales s
			LEFT JOIN Products p
				ON s.Product_Key = p.Product_Key
			LEFT JOIN Product_Subcategory ps
				ON ps.Product_Subcategory_Key = p.Product_Subcategory_Key
			LEFT JOIN Product_Category pc
				ON pc.Product_Category_Key = ps.Product_Category_Key
			LEFT JOIN Calendar c
				ON c.Date_Key = s.Date_Key
			GROUP BY
				pc.Product_Category,
				c.Quarter_Of_Year) AS TotalProfitByCategory
		PIVOT(
			MAX([%Profit Margin])
			FOR Quarters
			IN([2], [3], [4])
		) AS [Pivot Table] )

	SELECT * FROM Find_Profit;
GO

SELECT * FROM ProfitByProductAndMonths
GO

-- ******************* Product-level Profitability *****************
-- Category Performance Table
CREATE VIEW CategoryPerformanceTable AS
	WITH Find_SalesSummaryByCategory AS(
		SELECT
			pc.Product_Category AS Category,
			SUM(s.Sales_Quantity) AS Quantity_Sold,
			SUM(s.Total_Cost) AS Total_Cost,
			SUM(s.Revenue) AS Total_Revenue,
			SUM(s.Profit) AS Total_Profit,
			CAST(
				ROUND(SUM(s.Profit) * 100.00 / SUM(s.Revenue), 2) AS DECIMAL(10,2) )
				AS [%Profit Margin]
		FROM
			Sales s
		LEFT JOIN Products p
			ON s.Product_Key = p.Product_Key
		LEFT JOIN Product_Subcategory ps
			ON ps.Product_Subcategory_Key = p.Product_Subcategory_Key
		LEFT JOIN Product_Category pc
			ON pc.Product_Category_Key = ps.Product_Category_Key
		GROUP BY
			pc.Product_Category) 

	SELECT
		Category,
		Quantity_Sold,
		Total_Cost,
		Total_Revenue,
		Total_Profit,
		[%Profit Margin],
		ROW_NUMBER() OVER(ORDER BY [%Profit Margin] DESC) AS Ranking_by_Profit_Margin
	FROM
		Find_SalesSummaryByCategory
GO

SELECT * FROM CategoryPerformanceTable
GO


-- Top 10 products by Profit Margin
CREATE VIEW ProfitMarginByProductName AS
	WITH Find_Top5Products AS(
		SELECT
			p.Product_Name,
			CAST(
				ROUND(
					SUM(s.Profit) * 100.00 / SUM(s.Revenue), 2)
					AS DECIMAL(10,2) )
				AS [%Profit Margin]
		FROM
			Sales s
		LEFT JOIN Products p
			ON s.Product_Key = p.Product_Key
		GROUP BY
			p.Product_Name)

	SELECT TOP 10 * FROM Find_Top5Products
	ORDER BY [%Profit Margin] DESC
	GO

SELECT * FROM ProfitMarginByProductName
GO

-- Profit Margin by Product Category per year
CREATE VIEW ProfitMarginByCategory AS
	WITH Find_ProfitsbyProducts AS(
		SELECT *
		FROM(
			SELECT
				YEAR(s.Date_Key) AS [Year], 
				pc.Product_Category AS 'Product_Category',
				CAST(
					ROUND(
						SUM(s.Profit) * 100.00 / SUM(s.Revenue), 2)
						AS DECIMAL(10,2) ) AS [%Profit Margin]
			FROM
				Sales s
			LEFT JOIN Products p
				ON s.Product_Key = p.Product_Key
			LEFT JOIN Product_Subcategory ps
				ON p.Product_Subcategory_Key = ps.Product_Subcategory_Key
			LEFT JOIN Product_Category pc
				ON pc.Product_Category_Key = ps.Product_Category_Key
			GROUP BY
				YEAR(s.Date_Key), pc.Product_Category
			) AS Profit_per_SalesID
		PIVOT(
			MAX([%Profit Margin])
			FOR Year
			IN ([2011], [2012], [2013])) AS col )

	SELECT * FROM Find_ProfitsbyProducts
	GO

SELECT * FROM ProfitMarginByCategory
GO

-- ****************** Geography Profit Analysis ******************

-- Top 3 countries with Highest Profit in each continent
CREATE VIEW HighestProfit AS
	WITH Find_Top3Countries AS(
		SELECT
			g.Country,
			SUM(sl.Profit) AS Total_Profit
		FROM
			Sales sl
		LEFT JOIN Stores st
			ON sl.Store_Key = st.Store_Key
		LEFT JOIN Geography g
			ON g.Geography_Key = st.Geography_Key
		GROUP BY
			g.Country)

	SELECT TOP 3 *
	FROM
		Find_Top3Countries
	ORDER BY
		Total_Profit DESC
	GO

SELECT * FROM HighestProfit
GO


-- Which product subategory generated most profit in ever Continent?
CREATE VIEW ProfitByContinentAndProductCategory AS
	WITH Find_ProfitbyContinent AS(
		SELECT
			ps.Product_Subcategory,
			g.Continent_Name,
			CAST(
				ROUND(SUM(sl.Profit) * 100.00 / SUM(sl.Revenue), 2) AS DECIMAL(10,2) )
				AS [%Profit Margin]
		FROM
			Sales sl
		LEFT JOIN Products p
			ON sl.Product_Key = p.Product_Key
		LEFT JOIN Product_Subcategory ps
			ON ps.Product_Subcategory_Key = p.Product_Subcategory_Key
		LEFT JOIN Stores st
			ON st.Store_Key = sl.Store_Key
		LEFT JOIN Geography g
			ON g.Geography_Key = st.Geography_Key
		GROUP BY
			ps.Product_Subcategory,
			g.Continent_Name
		),
	Find_Ranking AS(
		SELECT
			Product_Subcategory,
			Continent_Name,
			[%Profit Margin],
			ROW_NUMBER() OVER(
				PARTITION BY Continent_Name ORDER BY [%Profit Margin] DESC)
				AS [Ranking]
		FROM
			Find_ProfitbyContinent)

	SELECT
		Product_Subcategory,
		Continent_Name,
		[%Profit Margin]
	FROM
		Find_Ranking
	WHERE
		Ranking = 1
	GO

SELECT * FROM ProfitByContinentAndProductCategory
ORDER BY [%Profit Margin] DESC
GO
