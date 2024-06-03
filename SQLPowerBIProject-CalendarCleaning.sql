-- Cleaned DimDate
-- Selected which Columns I want
SELECT
	[DateKey],
	[FullDateAlternateKey] AS Date,
	[EnglishDayNameOfWeek] AS Day,
	[EnglishMonthName] AS Month,
	Left([EnglishMonthName], 3) AS MonthShort,
	[MonthNumberOfYear] AS MonthNo,
	[CalendarQuarter] AS Quarter,
	[CalendarYear] AS Year
FROM
 [DimDate]
WHERE
 CalendarYear >= 2019;
-- Used Code Beautify to potentially clear up unneeded code
-- Returned same