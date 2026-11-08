
-- use SundorDW
-- GO

/*====================================================
Q1 - Execetive Summary KPIs

Business Question:
What are the main Insights from the data?

====================================================*/

-- IF OBJECT_ID('dbo.V_Executive_Summary', 'V') IS NOT NULL
-- DROP VIEW dbo.V_Executive_Summary;
-- GO

-- CREATE VIEW V_Executive_Summary AS

-- SELECT
-- COUNT(DISTINCT FO.Route_ID)                 AS Total_Routes,
-- COUNT(*)                                    AS Total_Operating_Days,
-- SUM(FO.Passengers)                          AS Total_Passengers,
-- SUM(FO.Flights_Operated)                    AS Total_Flights,
-- ROUND(AVG(FO.Load_Factor),2)                AS Avg_Load_Factor,
-- ROUND(AVG(FO.Delay_Minutes),1)              AS Avg_Delay_Minutes,
-- SUM(FF.Total_Revenue_USD)                   AS Total_Revenue_USD,
-- SUM(FF.Total_Operating_Cost_USD)            AS Total_Operating_Cost_USD,
-- SUM(FF.Operating_Profit_USD)                AS Total_Operating_Profit_USD,
-- ROUND(SUM(FF.Operating_Profit_USD) / NULLIF(SUM(FF.Total_Revenue_USD),0) *100 ,2)   AS Profit_Margin_PCT

-- FROM fact_operations FO
-- JOIN fact_financials FF
-- ON FO.Route_ID = FF.Route_ID
-- AND FO.Flight_Date = FF.Flight_Date

-- GO

-- SELECT * FROM V_Executive_Summary

/*====================================================
Q2 - Yearly Profit KPIs

Business Question:
How did we performe year over year?
====================================================*/

-- SELECT *
-- FROM V_Executive_Summary;
-- SELECT
--     YEAR(Flight_Date) AS Year,
--     SUM(Total_Revenue_USD) AS Revenue,
--     ROUND(SUM(Operating_Profit_USD) / NULLIF(SUM(Total_Revenue_USD),0) * 100,2) AS Profit_Margin_Pct,
--     SUM(Total_Operating_Cost_USD) AS Operating_Cost,
--     SUM(Operating_Profit_USD) AS Profit
-- FROM fact_financials
-- GROUP BY
--     YEAR(Flight_Date)
-- ORDER BY
--     Year;


/*====================================================
Q3 - Top 10 Routes by total profit 

Business Question:
What are the most profitable routes?

Insight: 
Shorter routes are the most profitable due to lower operating costs 
and high demand destenatios such as Greece and Cyprus. (with a few exceptions)
====================================================*/


-- WITH Route_breakdown AS (
--     SELECT
--         ff.Route_ID,
--         dr.City,
--         dr.Country,
--         SUM(ff.Total_Revenue_USD) AS Total_Revenue_USD,
--         SUM(ff.Total_Operating_Cost_USD) AS Total_Operating_Cost_USD,
--         SUM(ff.Operating_Profit_USD) AS Operating_Profit_USD,
--         COUNT(ff.Flight_Date) AS Operating_Days
--     FROM fact_financials ff
--     JOIN dim_route dr
--         ON ff.Route_ID = dr.Route_ID
--     GROUP BY ff.Route_ID, dr.City, dr.Country
-- )

-- SELECT TOP 10 *,
--        ROUND(Operating_Profit_USD / NULLIF(Operating_Days,0), 2) AS Profit_per_Day_USD
-- FROM Route_breakdown
-- ORDER BY Operating_Profit_USD DESC;



/*====================================================
Q4 - Routes By Profit Margin

Business Question:
What are the most profitable routes by Profit Margin?


Insights: 
The Routes of Greece and Cyprus are the best performing Routes in Profit Margin Percent.
What is the reason for that? I must breakdown the cost 

====================================================*/


-- IF OBJECT_ID('dbo.V_Route_Profit_Margin', 'V') IS NOT NULL
--     DROP VIEW dbo.V_Route_Profit_Margin;
-- GO

-- CREATE VIEW V_Route_Profit_Margin AS 
--         SELECT 
--         ff.Route_ID, 
--         dr.City, 
--         dr.Country,
--         ROUND(SUM(ff.Operating_Profit_USD)/ SUM(ff.Total_Revenue_USD)*100, 2) AS Profit_Margin_Pct, 
--         SUM(ff.Total_Revenue_USD) AS Total_Revenue_USD, 
--         SUM(ff.Total_Operating_Cost_USD) AS Total_Operating_Cost_USD , 
--         SUM(ff.Operating_Profit_USD) AS Operating_Profit_USD
--         FROM fact_financials ff
--         JOIN dim_route dr ON ff.Route_ID = dr.Route_ID
--         GROUP BY ff.Route_ID, dr.Country, dr.City
--          HAVING SUM(Total_Revenue_USD) > 1000000;

-- GO
-- -- Querying the View: V_Route_Profit_Margin

-- SELECT top 10 * 
-- FROM V_Route_Profit_Margin
-- ORDER BY Profit_Margin_Pct desc




/*====================================================
Q5 - Yearly Operating Cost Breakdown 

Business Question:
What are our expenses?

Insight: 
Fuel costs are much higher since 2022, impacting factors: Russia-Ukraine War - Fuel Demand Rising.
Fuel costs has stadily went down since 2022. 
====================================================*/


-- IF OBJECT_ID('dbo.V_Operating_Cost_Breakdown', 'V') IS NOT NULL
--     DROP VIEW dbo.V_Operating_Cost_Breakdown;
-- GO

-- CREATE VIEW V_Operating_Cost_Breakdown AS 

-- SELECT 
--         YEAR(Flight_Date) as Year,
--         SUM(Total_Operating_Cost_USD) Total_Operating_Cost_USD,
--         SUM(Fuel_Cost_USD) * 100.0 / NULLIF(SUM(Total_Operating_Cost_USD), 0) Fuel_Cost_PCT_of_Total, 
--         SUM(Fuel_Cost_USD) Fuel_Cost_USD, 
--         SUM(Crew_Cost_USD) Crew_Cost_USD,
--         SUM(Airport_Fees_USD) Airport_Fees_USD,
--         SUM(Maintenance_Cost_USD) Maintenance_Cost_USD, 
--         SUM(Navigation_Fees_USD) Navigation_Fees_USD, 
--         SUM(Aircraft_Lease_Cost_USD) Aircraft_Lease_Cost_USD, 
--         SUM(Ground_Handling_Cost_USD) Ground_Handling_Cost_USD, 
--         SUM(Security_Cost_USD) Security_Cost_USD
-- FROM fact_financials
-- GROUP BY YEAR(Flight_Date);
-- GO


-- SELECT *
-- FROM V_Operating_Cost_Breakdown
-- ORDER BY [Year] ASC



/*====================================================
Q6 - Monthly Revenue Trends 

Business Question:
Which months are high/ low Season?


INSIGHTS 6.A:
High season - June - Aug  ~ 88K
Low Season - Oct - Nov ~ 61k 
All other months have roughly the same AVG_Monthly_Revenuey , 67-70k 


INSIGHTS 6.B:
Monthly profit trends align with the Monthly Revenue trends
Same High / Low / Shoulder season months a
Strengething the assumption. 
====================================================*/


-- WITH Monthly_Revenue AS (
-- SELECT
--         avg(Total_Revenue_USD) over(partition by month(Flight_Date)) as AVG_Monthly_Revenue, 
--         MONTH(Flight_Date) AS Month
-- FROM fact_financials

-- )

-- SELECT [Month], AVG(AVG_Monthly_Revenue) as AVG_Monthly_Revenue 
-- FROM Monthly_Revenue
-- GROUP by Month
-- ORDER by AVG_Monthly_Revenue desc




-- -- Q6.B Profit Trend by Month


-- with Monthly_Profit as (
-- SELECT
--         avg(Operating_Profit_USD) over(partition by month(Flight_Date)) as AVG_Monthly_Profit, 
--         MONTH(Flight_Date) AS Month
-- FROM fact_financials


-- )
-- SELECT [Month], AVG(AVG_Monthly_Profit) as AVG_Monthly_Profit
-- FROM Monthly_Profit
-- GROUP by Month
-- ORDER by AVG_Monthly_Profit desc




/*====================================================
Q7  - OPERATIONAL KPIs

Business Question:
Load Factor and demand per Route per Month.

This query is a Template of operational KPIs for each route by Month / Year,
The City can be changed in the WHERE CLAUSE.

====================================================*/


-- WITH Load_Factor_CTE as 
-- (SELECT 
--     YEAR(FO.Flight_Date) Year,
--     Month(FO.Flight_Date) Month,
--     DR.City, 
--     AVG(FO.Load_Factor) AVG_Load_Factor, 
--     AVG(FO.Demand_Index) AVG_Demand_Index

-- FROM fact_operations FO
-- JOIN dim_route DR ON FO.Route_ID = DR.Route_ID
-- GROUP BY YEAR(Flight_Date),  Month(Flight_Date), DR.City
-- )

-- SELECT *
-- FROM Load_Factor_CTE
-- WHERE City LIKE  'Athens%' -- and YEAR = 2023 
-- ORDER BY Year, Month, AVG_Load_Factor desc



/*====================================================
Q8  - ROUTE PERFORMANCE

Business Questions:
Which routes generate the highest average daily profit? 
Insight:
Athens, Rhodes

B Question:
How do passenger volume, load factor, delays, and profit per passenger compare across routes?
Insight:
Profit per passenger is a great metric to show untapped profit.
Copenhagen and Basel operate 1 daily flight each even though they are top 3 in PPP, have a high load factor and demand.
====================================================*/


-- WITH Route_Performance AS (
--     SELECT
--         FO.Route_ID,
--         DR.City,
--         AVG(CAST(DR.Distance_KM AS FLOAT)) AS AVG_Distance_KM,
--         FLOOR(AVG(CAST(FO.Passengers AS FLOAT))) AS AVG_Daily_Passengers,
--         ROUND(AVG(CAST(FO.Delay_Minutes AS FLOAT)),1) AS AVG_Delay_Mins,
--         ROUND(AVG(CAST(FO.Load_Factor AS FLOAT)),2) AS AVG_Load_Factor,
--         ROUND(AVG(CAST(FO.Flights_Operated AS FLOAT)),2) AS AVG_Daily_Flights,
--         ROUND(SUM(FF.Operating_Profit_USD) / NULLIF(SUM(FO.Passengers), 0), 2) AS Profit_Per_Passenger_USD,
--         SUM(FF.Operating_Profit_USD) AS Total_Op_Profit_USD,
--         MIN(FO.Flight_Date) AS Start_Date,
--         MAX(FO.Flight_Date) AS End_Date
--     FROM fact_operations FO
--     JOIN dim_route DR 
--         ON FO.Route_ID = DR.Route_ID
--     JOIN fact_financials FF 
--         ON FO.Route_ID = FF.Route_ID
--        AND FO.Flight_Date = FF.Flight_Date
--     GROUP BY FO.Route_ID, DR.City
-- )
-- SELECT
--     Route_ID,
--     City,
--     AVG_Distance_KM,
--     AVG_Daily_Passengers,
--     AVG_Delay_Mins,
--     AVG_Load_Factor,
--     AVG_Daily_Flights,
--     Profit_Per_Passenger_USD,
--     CAST(ROUND(Total_Op_Profit_USD / NULLIF(DATEDIFF(DAY, Start_Date, End_Date)+1, 0),0) AS INT) AVG_Daily_Profit_USD
-- FROM Route_Performance
-- ORDER BY Profit_Per_Passenger_USD DESC;


/*====================================================
Q9 — Operational KPI Pivot

 Business Question:
 How do key operational KPIs vary across months and years?

-- Purpose:
-- Visualize operational KPIs across months and years to
-- identify seasonality and long-term trends.

-- Examples:
-- - AVG(Delay_Minutes)
-- - AVG(Load_Factor)
-- - SUM(Passengers)
-- - SUM(Flights_Operated)
-- - AVG(Fuel_Index)
======================================================*/

-- SELECT *
-- FROM 
-- (     SELECT 
--       DT.[Year] AS Year, DT.[Month_Name] AS Month, FO.Delay_Minutes 
--       FROM dim_date DT
--       JOIN fact_operations FO ON FO.Flight_Date = DT.[Date]
-- ) as subq

-- PIVOT( AVG(Delay_Minutes)
--        FOR Month IN (
--         [January],
--         [February],
--         [March],
--         [April],
--         [May],
--         [June],
--         [July],
--         [August],
--         [September],
--         [October],
--         [November],
--         [December]
--     )
-- ) pvt 

-- ORDER BY Year


/*====================================================
Q10 - Flight Reliability by Route

Business Question:
Which routes have the best operational reliability,
measured by on-time, delayed and cancelled flights?

Insight:
AVG on_time is ~72% of all flights,
2.5% cancelled, and the avg delay is ~12 mintues.
====================================================*/

-- WITH Flight_Status_CTE AS 
--       (SELECT
--       DR.Route_ID, 
--       DR.City, 
--       COUNT(*) Total_Flights,
--       SUM(CASE WHEN FO.Flight_Status = 'On Time' THEN 1 ELSE 0 END) AS On_Time_Flights,
--       SUM(CASE WHEN FO.Flight_Status = 'Delayed' THEN 1 ELSE 0 END) AS Delayed_Flights,
--       SUM(CASE WHEN FO.Flight_Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Flights
--       FROM dim_route DR
--       JOIN fact_operations FO ON FO.Route_ID = DR.Route_ID
--       GROUP BY DR.Route_ID, DR.City) 


-- SELECT 
-- Route_ID,
-- City,
-- Total_Flights,
-- On_Time_Flights,
-- Delayed_Flights,
-- Cancelled_Flights,
-- ROUND(On_Time_Flights * 100.0 / NULLIF(Total_Flights,0),2) AS On_Time_PCT,
-- ROUND(Delayed_Flights * 100.0 / NULLIF(Total_Flights,0),2) AS Delay_PCT,
-- ROUND(Cancelled_Flights * 100.0 / NULLIF(Total_Flights,0),2) AS Cancellation_PCT
-- FROM Flight_Status_CTE
-- ORDER BY On_Time_PCT DESC 



-- AVG_DELAY PER ROUTE

-- SELECT 
--       DR.Route_ID, 
--       DR.City, 
--       AVG(FO.Delay_Minutes) AVG_Delay_Minutes
--       FROM dim_route DR
--       JOIN fact_operations FO ON FO.Route_ID = DR.Route_ID
--       GROUP BY DR.Route_ID, DR.City
--       ORDER BY AVG(FO.Delay_Minutes) DESC



/*====================================================
Q11 - Route Revenue vs Cost

Business Question:
Which routes generate high revenue but also incur disproportionately high operating costs?

Insight:
The higher the Cost_Ratio_PCT the less profitable the Route is. 
High Cost_Ratio_PCT = BAD
Low Cost_Ratio_PCT  = GOOD

Shorter Destinations such as Greece, Cyprus and Georgia are profitable due to lower operating costs.
Copenhagen and Basel are some of the best medium distance routes in Performance and Cost_Ratio_PCT.
We should look into developing these routes. 
====================================================*/


-- SELECT
--     dr.City,
--     SUM(ff.Total_Revenue_USD) AS Revenue_USD,
--     SUM(ff.Total_Operating_Cost_USD) AS Operating_Cost_USD,
--     SUM(ff.Operating_Profit_USD) AS Profit_USD,
--     ROUND(
--         SUM(ff.Total_Operating_Cost_USD) *100.0 /
--         NULLIF(SUM(ff.Total_Revenue_USD),0),2
--     ) AS Cost_Ratio_PCT
-- FROM fact_financials ff
-- JOIN dim_route dr
-- ON ff.Route_ID = dr.Route_ID
-- GROUP BY dr.City
-- ORDER BY Cost_Ratio_PCT DESC;




/*====================================================
Q12 - Aircraft Utilization per Flight

Business Question:
Which aircraft type generates the highest utilization?

Insight: 
B737-900ER is the biggest aircraft of the 3 in our fleet, this makes it the best cost per seat option.
====================================================*/

-- SELECT

--     Aircraft_Type,
--     ROUND(SUM(Passengers) * 1.0 / NULLIF(SUM(Flights_Operated),0),1) AS Avg_Passengers_Per_Flight,
--     ROUND(AVG(Load_Factor),2) AS Avg_Load_Factor,
--     ROUND(AVG(Delay_Minutes),1) AS Avg_Delay_Minutes,
--     SUM(Flights_Operated) AS Total_Flights

-- FROM fact_operations
-- GROUP BY Aircraft_Type
-- ORDER BY Avg_Load_Factor DESC;



/*====================================================
Q13 - Long-haul vs Short-haul Performance

Business Question:
Route Performance by Distance Groups.

Insight:
2/3 of the Routes are categorized as Medium haul, 
the higher veraity in routes causes the lower PP passenger and PP flight.
====================================================*/

-- SELECT
--     CASE
--         WHEN DR.Distance_KM < 1000 THEN 'Short Haul'
--         WHEN DR.Distance_KM < 2500 THEN 'Medium Haul'
--         ELSE 'Long Haul'
--     END AS Route_Category,
--     COUNT(DISTINCT DR.Route_ID) AS Routes,
--     ROUND(AVG(FO.Load_Factor),2) AS Avg_Load_Factor,
--     ROUND(
--         SUM(FF.Operating_Profit_USD) /
--         NULLIF(SUM(FO.Passengers),0),2
--     ) AS Profit_Per_Passenger_USD,
--     ROUND(
--         SUM(FF.Operating_Profit_USD) /
--         NULLIF(SUM(FO.Flights_Operated),0),2
--     ) AS Profit_Per_Flight_USD,
--     ROUND(AVG(FO.Delay_Minutes),1) AS Avg_Delay

-- FROM fact_operations FO
-- JOIN fact_financials FF
-- ON FO.Route_ID = FF.Route_ID
-- AND FO.Flight_Date = FF.Flight_Date
-- JOIN dim_route DR
-- ON DR.Route_ID = FO.Route_ID
-- GROUP BY
-- CASE
--     WHEN DR.Distance_KM < 1000 THEN 'Short Haul'
--     WHEN DR.Distance_KM < 2500 THEN 'Medium Haul'
--     ELSE 'Long Haul'
-- END

-- ORDER BY Profit_Per_Flight_USD DESC;


/*====================================================
Q14 - Delay Impact

Business Question:
Are delayed routes less profitable?

there is no direct correlation between PP Flight to the avg delay time of the routes,
as the avg delay time is very similar in most routes. 
====================================================*/

-- SELECT

-- dr.City,
-- AVG(fo.Delay_Minutes) AS Avg_Delay,
-- AVG(fo.Load_Factor) AS Avg_Load,
-- SUM(ff.Operating_Profit_USD) / SUM(fo.Flights_Operated) AS Profit_per_flight

-- FROM fact_operations fo
-- JOIN fact_financials ff
-- ON fo.Route_ID=ff.Route_ID
-- AND fo.Flight_Date=ff.Flight_Date
-- JOIN dim_route dr
-- ON dr.Route_ID=fo.Route_ID
-- GROUP BY dr.City
-- ORDER BY Avg_Delay DESC;



/*====================================================
Q15 - Revenue Per Flight

Top Airline KPI

Insight:
Copenhagen and Basel are the top 2 destinations in Revenue Per Flight.
this coresponds with the earlier insights we learnt during the analysis, 
These 2 destinations can be developed to increase Revenue. 
====================================================*/

-- SELECT
-- dr.City,
-- ROUND(SUM(ff.Total_Revenue_USD)/SUM(fo.Flights_Operated),2) AS Revenue_Per_Flight

-- FROM fact_financials ff
-- JOIN fact_operations fo
-- ON ff.Route_ID=fo.Route_ID
-- AND ff.Flight_Date=fo.Flight_Date
-- JOIN dim_route dr
-- ON dr.Route_ID=ff.Route_ID
-- GROUP BY dr.City
-- ORDER BY Revenue_Per_Flight DESC;



/*====================================================
Q16 - Yearly KPIs

Business Question:
Yearly KPI's performance compared to last year.
====================================================*/

-- WITH Yearly_KPIs AS (

-- SELECT
--     YEAR(Flight_Date) AS Year,
--     SUM(Total_Revenue_USD) AS Revenue,
--     SUM(Operating_Profit_USD) AS Profit
-- FROM fact_financials
-- GROUP BY YEAR(Flight_Date)
-- )

-- SELECT
--     Year,
--     Revenue,
--     Profit,
--     LAG(Revenue) OVER(ORDER BY Year) AS Previous_Revenue,
--     ROUND(
--         (Revenue -
--         LAG(Revenue) OVER(ORDER BY Year))
--         *100.0
--         / NULLIF(LAG(Revenue) OVER(ORDER BY Year),0),2) AS Revenue_Growth_PCT,

--     LAG(Profit) OVER(ORDER BY Year) AS Previous_Profit,
--     ROUND(
--         (Profit - LAG(Profit) OVER(ORDER BY Year)) *100.0
--          / NULLIF(LAG(Profit) OVER(ORDER BY Year),0) ,2) AS Profit_Growth_PCT

-- FROM Yearly_KPIs

-- ORDER BY Year;



/*====================================================
Q17 — Route Ranking by Annual Profit

Business Question:
How does each route rank annually based on operating
profit?

Business Value:
Identifies the airline's strongest and weakest routes
while demonstrating SQL window functions.
====================================================*/

-- WITH Route_Profit AS (

-- SELECT
-- YEAR(FF.Flight_Date) AS Year,
-- DR.City,
-- SUM(FF.Operating_Profit_USD) AS Operating_Profit_USD

-- FROM fact_financials FF
-- JOIN dim_route DR
-- ON FF.Route_ID = DR.Route_ID
-- GROUP BY
-- YEAR(FF.Flight_Date), DR.City
-- )

-- SELECT

-- Year,
-- City,
-- Operating_Profit_USD,
-- RANK() OVER(PARTITION BY Year ORDER BY Operating_Profit_USD DESC) AS Profit_Rank

-- FROM Route_Profit
-- ORDER BY Year, Profit_Rank;