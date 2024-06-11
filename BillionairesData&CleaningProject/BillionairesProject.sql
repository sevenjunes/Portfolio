-- From billionaires-by-country-2024 data sheet
-- (Source: https://www.kaggle.com/datasets/rafsunahmad/billionaires-data-by-country-2024)

-- 1. How many Billionaires are there?
SELECT
	COUNT(DISTINCT BillionairesRichestBillionaire2023),
    COUNT(BillionairesRichestBillionaire2023),
    SUM(BillionairesTotalNetWorth2023) AS total_networth
    FROM billionaires_by_country.`billionaires-by-country-2024`;
-- 72 total billionaires

-- 2. What is the Count and Average Net Worth of Billionaires by Region (Continent)
SELECT
	region,
		COUNT(BillionairesRichestBillionaire2023) AS no_of_billionaires,
        ROUND(AVG(BillionairesTotalNetWorth2023),2) AS avg_networth,
        ROUND(SUM(BillionairesTotalNetWorth2023),2) AS total_networth
	FROM billionaires_by_country.`billionaires-by-country-2024`
    Group BY 1
    ORDER BY 4 DESC;
-- region   no_of_billionaires   avg_networth   total_networth    
-- North America	5	981.5	4907.5
-- Asia	22	170.97	3761.4
-- Europe	29	102.64	2976.5
 -- South America	6	40.5	243
-- Oceania	2	98.1	196.2
-- Africa	8	11.31	90.5

-- 3. What are the African billionaires net worth as a percentage to the whole world, and other couttries too?
WITH DATA AS (
SELECT
	region,
		COUNT(BillionairesRichestBillionaire2023) AS no_of_billionaires,
        ROUND(AVG(BillionairesTotalNetWorth2023),2) AS avg_networth,
        ROUND(SUM(BillionairesTotalNetWorth2023),2) AS total_networth
FROM billionaires_by_country.`billionaires-by-country-2024`
Group BY 1
ORDER BY 4 DESC
)
SELECT
	SUM(CASE WHEN region = 'Africa' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 AS pct_africa,
    SUM(CASE WHEN region = 'North America' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 AS pct_NAmerica,
    SUM(CASE WHEN region = 'Asia' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 AS pct_asia,
    SUM(CASE WHEN region = 'Europe' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 AS pct_europe,
    SUM(CASE WHEN region = 'South America' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 pct_SAmerica,
    SUM(CASE WHEN region = 'Oceania' THEN total_networth ELSE 0 END)/SUM(total_networth)*100 pct_oceania,
    SUM(total_networth) as total_networth
FROM DATA;
-- Africa 0.74%, North America 40.30%, Asia 30.89%, South America 1.99%, Oceania 1.61% Total Net Worth 12.175 trillion

-- 4. Who are the Top 5 Billionaires?
SELECT
	BillionairesRichestBillionaire2023, BillionairesTotalNetWorth2023, country, region
FROM billionaires_by_country.`billionaires-by-country-2024`
ORDER BY 2 DESC
LIMIT 5
-- 'Elon Musk', '4490.8', 'United States', 'North America'
-- 'Zhong Shanshan', '1644.7', 'China', 'Asia'
-- 'Mukesh Ambani', '669.2', 'India', 'Asia'
-- 'Bernard Arnault & family', '590', 'France', 'Europe'
-- 'Dieter Schwarz', '583', 'Germany', 'Europe'

-- 5. Is there a relation between the region with the highest number of billionaires AND a)populartion growth rate and b) population density
SELECT
	region,
		ROUND(AVG(BillionairesRichestNetWorth2023),2) AS avg_networth,
        ROUND(AVG(population_densityMi),2) AS avg_popdensity,
        ROUND(AVG(Population_growthRate),2) AS avg_popgrowth
FROM billionaires_by_country.`billionaires-by-country-2024`
GROUP BY 1
ORDER BY 2 DESC;
--  region   avg_networth   avg_popdensity   avg_popgrowth
-- 'North America', '66.02', '491.5', '0'
-- 'Europe', '21.37', '2035.82', '0'
-- 'Oceania', '17.8', '30.41', '0.01'
-- 'Asia', '17.03', '4972.59', '0'
-- 'South America', '9.48', '76.36', '0.01'

-- 6. Average New Worth by UN Member Status
SELECT
	unMember,
		ROUND(AVG(BillionairesTotalNetWorth2023),2) AS avg_networth,
        ROUND(SUM(BillionairesTotalNetWorth2023),2) AS total_networth
FROM billionaires_by_country.`billionaires-by-country-2024`
GROUP BY 1;
-- unMember   avg_networth   total_networth
-- TRUE	      171.59	     11668.1
-- FALSE	  126.75	     507

