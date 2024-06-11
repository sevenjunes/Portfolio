--Review all Data
SELECT * FROM dbo.sales_data_sample
--Checking Unique Values
SELECT DISTINCT STATUS FROM dbo.sales_data_sample -- Keep
SELECT DISTINCT year_id FROM dbo.sales_data_sample -- Keep
SELECT DISTINCT PRODUCTLINE FROM dbo.sales_data_sample -- Keep
SELECT DISTINCT COUNTRY FROM dbo.sales_data_sample -- Keep
SELECT DISTINCT DEALSIZE FROM dbo.sales_data_sample -- Keep
SELECT DISTINCT TERRITORY FROM dbo.sales_data_sample -- Keep
-- Start Analysis
-- Group Sales by Product Line
SELECT PRODUCTLINE AS 'Product Line', SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC
-- Group Sales by Year
SELECT YEAR_ID AS Year, SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC
-- 2005 was a low sales year, looking into what months were bad
SELECT DISTINCT MONTH_ID AS Month
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2005
-- Discovered that they only operated for 5 months in 2005
-- Comparing to 2004
SELECT DISTINCT MONTH_ID AS Month
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004
-- Operated all 12 months with March, July and November being their best months
-- Comparing to 2003
SELECT DISTINCT MONTH_ID AS Month
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2003
-- Comparable numbers to 2004
-- Checking DEALSIZE and it's relation to sales
SELECT DEALSIZE AS Deal, SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC
-- Medium generated the most revenue
-- Cursory Analysis done

-- What was the best month for sales in a specific year?
-- How much was earned in that month?
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC
-- November was the best month in 2003 with ~1.02 Million in Revenue
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC
-- November was the best month in 2004 with ~1.08 million in Revenue
SELECT MONTH_ID AS Month, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC
-- May was the best month in 2005 with ~457K in Revenue
-- Since November seems to be the strongest month, what product sells best?
SELECT MONTH_ID AS Month, PRODUCTLINE AS Product, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2003 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC
-- Classic Cars is the best selling product in 2003
SELECT MONTH_ID AS Month, PRODUCTLINE AS Product, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC
-- Classic Cars is the best selling product in 2004
-- Checking May of 2005
SELECT MONTH_ID AS Month, PRODUCTLINE AS Product, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2005 AND MONTH_ID = 5
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC
-- Classic Cars is the best sellign product in 2005

-- Who is our best customer? (Using RFM Analysis)
-- RFM is Recency Frequency Monetary
	-- Recency (how long ago their last purchase was) Last Order Date
	-- Frequency (how often they purchase) Count of Total Orders
	-- Monetary (how much they spend) Total Monies Spent
DROP TABLE IF EXISTS #RFM
;WITH RFM AS 
(
	SELECT
		CUSTOMERNAME AS 'Customer Name',
		SUM(SALES) AS 'Monetary Value',
		AVG(SALES) AS 'AvgMonetaryValue',
		COUNT(ORDERNUMBER) AS 'Frequency',
		MAX(ORDERDATE) AS 'Last Order Date',
		(SELECT MAX(ORDERDATE) FROM dbo.sales_data_sample) AS 'Todays Date',
		DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM dbo.sales_data_sample)) AS 'Recency'
	FROM dbo.sales_data_sample
	GROUP BY CUSTOMERNAME
),
RFM_Calc AS
(
	SELECT R.*,
		NTILE(4) OVER (ORDER BY Recency DESC) AS 'RFM_Recency',
		NTILE(4) OVER (ORDER BY Frequency) AS 'RFM_Frequency',
		NTILE(4) OVER (ORDER BY AvgMonetaryValue) AS 'RFM_Monetary'
	FROM RFM AS R
)
SELECT
	C.*, RFM_Recency + RFM_Frequency + RFM_Monetary AS RFM_Cell,
	CAST(RFM_Recency AS VARCHAR) + CAST(RFM_Frequency AS VARCHAR) + CAST(RFM_Monetary AS VARCHAR) AS RFM_Cell_String
INTO #RFM
FROM RFM_Calc AS C

SELECT [Customer Name], RFM_Recency, RFM_Frequency, RFM_Monetary,
	CASE
		WHEN RFM_Cell_String IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost Customer'
		WHEN RFM_Cell_String IN (133, 134, 143, 144, 244, 334, 343, 344) THEN 'Fading Away'
		WHEN RFM_Cell_String IN (311, 411, 331) THEN 'New Customer'
		WHEN RFM_Cell_String IN (222, 223, 233, 322) THEN 'Potential Churners'
		WHEN RFM_Cell_String IN (323, 333, 321, 422, 332, 432) THEN 'Active'
		WHEN RFM_Cell_String IN (433, 434, 443, 444) THEN 'Loyal'
		ELSE 'Undefined'
	END RFM_Segment
FROM #RFM
-- Segmented list into 7 types of customers

-- What products are most often sold together?
-- SELECT * FROM dbo.sales_data_sample (Commented out)
-- First row showed Order Number 10411 having 9 Items
-- SELECT * FROM dbo.sales_data_sample WHERE ORDERNUMBER = 10411 (Commented out)
-- Looked at all data pertaining to Order Number 10411 to get idea of what information will look like
SELECT ORDERNUMBER
FROM (
	SELECT ORDERNUMBER, COUNT(*) AS rn
	FROM dbo.sales_data_sample
	WHERE STATUS = 'Shipped'
	GROUP BY ORDERNUMBER
) AS M
WHERE rn = 2
-- Returned 19 rows for orders with 2 items
-- Writing subquery
SELECT PRODUCTCODE
FROM dbo.sales_data_sample
	WHERE ORDERNUMBER IN
	(
			SELECT ORDERNUMBER
			FROM (
			SELECT ORDERNUMBER, COUNT(*) AS rn
			FROM dbo.sales_data_sample
			WHERE STATUS = 'Shipped'
			GROUP BY ORDERNUMBER
		) AS M
		WHERE rn = 2
	)
-- Returned 38 rows (19 x 2) Good so far
-- Appending

SELECT ',' + PRODUCTCODE
FROM dbo.sales_data_sample
	WHERE ORDERNUMBER IN
	(
			SELECT ORDERNUMBER
			FROM (
			SELECT ORDERNUMBER, COUNT(*) AS rn
			FROM dbo.sales_data_sample
			WHERE STATUS = 'Shipped'
			GROUP BY ORDERNUMBER
		) AS M
		WHERE rn = 2
	)
	FOR XML PATH ('')
-- Returned Single Line XML Path
-- Remove leading comma
SELECT STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM dbo.sales_data_sample
		WHERE ORDERNUMBER IN
		(
				SELECT ORDERNUMBER
				FROM (
				SELECT ORDERNUMBER, COUNT(*) AS rn
				FROM dbo.sales_data_sample
				WHERE STATUS = 'Shipped'
				GROUP BY ORDERNUMBER
			) AS M
			WHERE rn = 2
		)
		FOR XML PATH (''))
		, 1, 1, '')
-- Converted Results from XML to String
-- Find Order Number for the Product Codes
SELECT DISTINCT ORDERNUMBER, STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM dbo.sales_data_sample p
		WHERE ORDERNUMBER IN
		(
				SELECT ORDERNUMBER
				FROM (
				SELECT ORDERNUMBER, COUNT(*) AS rn
				FROM dbo.sales_data_sample
				WHERE STATUS = 'Shipped'
				GROUP BY ORDERNUMBER
			) AS M
			WHERE rn = 2
		)
		AND p.ORDERNUMBER = s.ORDERNUMBER
		FOR XML PATH ('')) 
		, 1, 1, '') AS 'Product Codes'
FROM dbo.sales_data_sample s
ORDER BY 2 DESC
-- Returned 19 rows with 2 product codes










