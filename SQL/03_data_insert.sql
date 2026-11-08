use SundorDW
go


-- staging table fact_financials

DROP TABLE IF EXISTS fact_financials_stg;

CREATE TABLE fact_financials_stg (

    Date NVARCHAR(50),
    Year NVARCHAR(50),
    Quarter NVARCHAR(50),
    Month NVARCHAR(50),
    Month_Name NVARCHAR(50),
    Week_Number NVARCHAR(50),
    Day_Of_Week NVARCHAR(50),
    Is_Weekend NVARCHAR(50),
    Season NVARCHAR(50),

    Route_ID NVARCHAR(50),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    Region NVARCHAR(100),

    Distance_KM NVARCHAR(50),
    Route_Tier NVARCHAR(50),
    Seasonal_Route NVARCHAR(50),
    Launch_Date NVARCHAR(50),

    Base_Daily_Demand NVARCHAR(50),
    Fare_Low_USD NVARCHAR(50),
    Fare_High_USD NVARCHAR(50),

    Aircraft_Type NVARCHAR(100),
    Base_Daily_Flights NVARCHAR(50),
    Competition_Sensitivity NVARCHAR(50),

    Fuel_Index NVARCHAR(50),
    Security_Risk_Index NVARCHAR(50),

    Holiday_Name NVARCHAR(100),
    Demand_Impact NVARCHAR(50),

    Seats NVARCHAR(50),
    Fuel_Burn_Index NVARCHAR(50),

    Demand_Index NVARCHAR(50),
    Competition_Index NVARCHAR(50),

    Flights_Operated NVARCHAR(50),
    Seats_Offered NVARCHAR(50),

    Route_Demand_Multiplier NVARCHAR(50),
    Expected_Passengers NVARCHAR(50),
    Passengers NVARCHAR(50),

    Load_Factor NVARCHAR(50),
    Fare_Position NVARCHAR(50),
    Avg_Fare_USD NVARCHAR(50),

    Ticket_Revenue_USD NVARCHAR(50),
    Ancillary_Per_Pax NVARCHAR(50),
    Ancillary_Revenue_USD NVARCHAR(50),

    Total_Revenue_USD NVARCHAR(50),

    Aircraft_Cost_Factor NVARCHAR(50),

    Fuel_Cost_USD NVARCHAR(50),
    Crew_Cost_USD NVARCHAR(50),
    Airport_Fees_USD NVARCHAR(50),
    Maintenance_Cost_USD NVARCHAR(50),
    Navigation_Fees_USD NVARCHAR(50),
    Ground_Handling_Cost_USD NVARCHAR(50),
    Aircraft_Lease_Cost_USD NVARCHAR(50),
    Security_Cost_USD NVARCHAR(50),

    Corporate_Overhead_USD NVARCHAR(50),

    Total_Operating_Cost_USD NVARCHAR(50),
    Operating_Profit_USD NVARCHAR(50),
    Operating_Margin_Pct NVARCHAR(50)
);


-- Bulk Insert Fact Financial stage



BULK INSERT fact_financials_stg
FROM '/var/opt/mssql/import/fact_financials.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- Inserting Data into the Fact Financial Table 

INSERT INTO fact_financials (

    Flight_Date,
    Route_ID,

    Total_Revenue_USD,
    Ticket_Revenue_USD,
    Ancillary_Revenue_USD,

    Total_Operating_Cost_USD,

    Fuel_Cost_USD,
    Crew_Cost_USD,
    Airport_Fees_USD,
    Maintenance_Cost_USD,
    Navigation_Fees_USD,
    Aircraft_Lease_Cost_USD,
    Ground_Handling_Cost_USD,
    Security_Cost_USD,

    Operating_Profit_USD
)
SELECT

    TRY_CAST(Date AS DATE),
    TRY_CAST(Route_ID AS INT),

    TRY_CAST(Total_Revenue_USD AS DECIMAL(18,2)),
    TRY_CAST(Ticket_Revenue_USD AS DECIMAL(18,2)),
    TRY_CAST(Ancillary_Revenue_USD AS DECIMAL(18,2)),

    TRY_CAST(Total_Operating_Cost_USD AS DECIMAL(18,2)),

    TRY_CAST(Fuel_Cost_USD AS DECIMAL(18,2)),
    TRY_CAST(Crew_Cost_USD AS DECIMAL(18,2)),
    TRY_CAST(Airport_Fees_USD AS DECIMAL(18,2)),
    TRY_CAST(Maintenance_Cost_USD AS DECIMAL(18,2)),
    TRY_CAST(Navigation_Fees_USD AS DECIMAL(18,2)),
    TRY_CAST(Aircraft_Lease_Cost_USD AS DECIMAL(18,2)),
    TRY_CAST(Ground_Handling_Cost_USD AS DECIMAL(18,2)),
    TRY_CAST(Security_Cost_USD AS DECIMAL(18,2)),

    TRY_CAST(Operating_Profit_USD AS DECIMAL(18,2))

FROM fact_financials_stg;


-- staging table for forecast_dataset


DELETE FROM forecast_dataset;

DROP TABLE IF EXISTS forecast_dataset_stg;

CREATE TABLE forecast_dataset_stg (
    Date NVARCHAR(50),
    Passengers NVARCHAR(50),
    Seats_Offered NVARCHAR(50),
    Flights_Operated NVARCHAR(50),
    Delay_Minutes NVARCHAR(50),
    Demand_Index NVARCHAR(50),
    Security_Risk_Index NVARCHAR(50),
    Fuel_Index NVARCHAR(50),
    Competition_Index NVARCHAR(50),
    Load_Factor NVARCHAR(50),
    Delay_Rate NVARCHAR(50),
    Total_Revenue_USD NVARCHAR(50),
    Total_Operating_Cost_USD NVARCHAR(50),
    Operating_Profit_USD NVARCHAR(50),
    Year NVARCHAR(50),
    Month NVARCHAR(50),
    Quarter NVARCHAR(50),
    Weekday NVARCHAR(50),
    Day_Of_Year NVARCHAR(50),
    Is_Summer NVARCHAR(50),
    Is_Shoulder_Season NVARCHAR(50),
    Is_Winter NVARCHAR(50),
    Passengers_Lag_1 NVARCHAR(50),
    Passengers_Lag_7 NVARCHAR(50),
    Revenue_Lag_7 NVARCHAR(50),
    Passengers_Rolling_7 NVARCHAR(50),
    Revenue_Rolling_7 NVARCHAR(50)
);

-- Bulk insert Forecast Dataset stage

BULK INSERT forecast_dataset_stg
FROM '/var/opt/mssql/import/forecast_dataset.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);


-- Inserting data into the forecast table


INSERT INTO forecast_dataset (
    Forecast_Date,
    Passengers,
    Seats_Offered,
    Flights_Operated,
    Load_Factor,
    Delay_Rate,
    Demand_Index,
    Fuel_Index,
    Competition_Index,
    Security_Risk_Index,
    Total_Revenue_USD,
    Total_Operating_Cost_USD,
    Operating_Profit_USD,
    Passengers_Lag_1,
    Passengers_Lag_7,
    Revenue_Lag_7,
    Passengers_Rolling_7,
    Revenue_Rolling_7
)
SELECT
    TRY_CAST(Date AS DATE),
    TRY_CAST(Passengers AS FLOAT),
    TRY_CAST(Seats_Offered AS FLOAT),
    TRY_CAST(Flights_Operated AS FLOAT),
    TRY_CAST(Load_Factor AS FLOAT),
    TRY_CAST(Delay_Rate AS FLOAT),
    TRY_CAST(Demand_Index AS FLOAT),
    TRY_CAST(Fuel_Index AS FLOAT),
    TRY_CAST(Competition_Index AS FLOAT),
    TRY_CAST(Security_Risk_Index AS FLOAT),
    TRY_CAST(Total_Revenue_USD AS FLOAT),
    TRY_CAST(Total_Operating_Cost_USD AS FLOAT),
    TRY_CAST(Operating_Profit_USD AS FLOAT),
    TRY_CAST(Passengers_Lag_1 AS FLOAT),
    TRY_CAST(Passengers_Lag_7 AS FLOAT),
    TRY_CAST(Revenue_Lag_7 AS FLOAT),
    TRY_CAST(Passengers_Rolling_7 AS FLOAT),
    TRY_CAST(Revenue_Rolling_7 AS FLOAT)
FROM forecast_dataset_stg;


-- Creating and Inserting Data into fact_operations_stage Table

DROP TABLE IF EXISTS fact_operations_stg;

CREATE TABLE fact_operations_stg (

    Date NVARCHAR(50),
    Year NVARCHAR(50),
    Quarter NVARCHAR(50),
    Month NVARCHAR(50),
    Month_Name NVARCHAR(50),
    Week_Number NVARCHAR(50),
    Day_Of_Week NVARCHAR(50),
    Is_Weekend NVARCHAR(50),
    Season NVARCHAR(50),

    Route_ID NVARCHAR(50),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    Region NVARCHAR(100),

    Distance_KM NVARCHAR(50),
    Route_Tier NVARCHAR(50),
    Seasonal_Route NVARCHAR(50),
    Launch_Date NVARCHAR(50),

    Base_Daily_Demand NVARCHAR(50),
    Fare_Low_USD NVARCHAR(50),
    Fare_High_USD NVARCHAR(50),

    Aircraft_Type NVARCHAR(100),
    Base_Daily_Flights NVARCHAR(50),
    Competition_Sensitivity NVARCHAR(50),

    Fuel_Index NVARCHAR(50),
    Security_Risk_Index NVARCHAR(50),

    Holiday_Name NVARCHAR(100),
    Demand_Impact NVARCHAR(50),

    Seats NVARCHAR(50),
    Fuel_Burn_Index NVARCHAR(50),

    Demand_Index NVARCHAR(50),
    Competition_Index NVARCHAR(50),

    Flights_Operated NVARCHAR(50),
    Seats_Offered NVARCHAR(50),

    Route_Demand_Multiplier NVARCHAR(50),
    Expected_Passengers NVARCHAR(50),
    Passengers NVARCHAR(50),

    Load_Factor NVARCHAR(50),
    Fare_Position NVARCHAR(50),
    Avg_Fare_USD NVARCHAR(50),

    Ticket_Revenue_USD NVARCHAR(50),
    Ancillary_Per_Pax NVARCHAR(50),
    Ancillary_Revenue_USD NVARCHAR(50),

    Total_Revenue_USD NVARCHAR(50),

    Operational_Risk NVARCHAR(50),
    Delay_Probability NVARCHAR(50),
    Cancel_Probability NVARCHAR(50),

    Flight_Status NVARCHAR(50),
    Delay_Minutes NVARCHAR(50),
    Delay_Reason NVARCHAR(100),
    Cancellation_Reason NVARCHAR(100)
);


-- Bulk insert 

BULK INSERT fact_operations_stg
FROM '/var/opt/mssql/import/fact_operations_stage2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);


-- Inserting Data into the FACT OPERATIONS Table
INSERT INTO fact_operations (

    Flight_Date,
    Route_ID,
    Aircraft_Type,

    Passengers,
    Seats_Offered,
    Flights_Operated,

    Load_Factor,

    Demand_Index,
    Fuel_Index,
    Competition_Index,
    Security_Risk_Index,

    Flight_Status,
    Delay_Minutes
)
SELECT

    TRY_CAST(Date AS DATE),

    TRY_CAST(Route_ID AS INT),

    Aircraft_Type,

    TRY_CAST(TRY_CAST(Passengers AS FLOAT) AS INT),
    TRY_CAST(Seats_Offered AS INT),
    TRY_CAST(Flights_Operated AS INT),

    TRY_CAST(Load_Factor AS DECIMAL(10,4)),

    TRY_CAST(Demand_Index AS DECIMAL(10,2)),
    TRY_CAST(Fuel_Index AS DECIMAL(10,2)),
    TRY_CAST(Competition_Index AS DECIMAL(10,2)),
    TRY_CAST(Security_Risk_Index AS DECIMAL(10,2)),

    Flight_Status,

    TRY_CAST(Delay_Minutes AS INT)

FROM fact_operations_stg;


-- VALIDATION OF PROPER INSERT -- 

SELECT 'dim_route' AS TableName, COUNT(*) AS Row_Count FROM dim_route
UNION ALL
SELECT 'dim_aircraft', COUNT(*) FROM dim_aircraft
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_financials', COUNT(*) FROM fact_financials
UNION ALL
SELECT 'forecast_dataset', COUNT(*) FROM forecast_dataset
UNION ALL
SELECT 'fact_operations', COUNT(*) FROM fact_operations;
