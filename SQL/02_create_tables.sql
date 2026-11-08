USE SundorDW;
GO

/* ==========================
   DIM_DATE
========================== */

CREATE TABLE dim_date (

    Date_Key DATE PRIMARY KEY,

    [Year] INT,
    Quarter_Number INT,
    [Month] INT,
    Month_Name VARCHAR(20),
    Week_Number INT,
    Day_Of_Week INT,
    Is_Weekend BIT,
    Season VARCHAR(20)

);

GO


/* ==========================
   DIM_ROUTE
========================== */

CREATE TABLE dim_route (

    Route_ID INT PRIMARY KEY,

    City VARCHAR(100),
    Country VARCHAR(100),
    Region VARCHAR(100),

    Distance_KM INT,

    Route_Tier VARCHAR(50),

    Seasonal_Route BIT,

    Launch_Date DATE,

    Base_Daily_Demand INT,

    Fare_Low_USD DECIMAL(10,2),
    Fare_High_USD DECIMAL(10,2),

    Aircraft_Type VARCHAR(50),

    Base_Daily_Flights INT,

    Competition_Sensitivity DECIMAL(10,2)

);

GO


/* ==========================
   DIM_AIRCRAFT
========================== */

CREATE TABLE dim_aircraft (

    Aircraft_Type VARCHAR(50) PRIMARY KEY,

    Seats INT,

    Fuel_Burn_Index DECIMAL(10,2)

);

GO


/* ==========================
   FACT_OPERATIONS
========================== */

CREATE TABLE fact_operations (

    Operation_ID INT IDENTITY(1,1) PRIMARY KEY,

    Flight_Date DATE,

    Route_ID INT,

    Aircraft_Type VARCHAR(50),

    Passengers INT,

    Seats_Offered INT,

    Flights_Operated INT,

    Load_Factor DECIMAL(10,4),

    Demand_Index DECIMAL(10,2),

    Fuel_Index DECIMAL(10,2),

    Competition_Index DECIMAL(10,2),

    Security_Risk_Index DECIMAL(10,2),

    Flight_Status VARCHAR(20),

    Delay_Minutes INT,

    FOREIGN KEY (Route_ID)
        REFERENCES dim_route(Route_ID),

    FOREIGN KEY (Aircraft_Type)
        REFERENCES dim_aircraft(Aircraft_Type)

);

GO


/* ==========================
   FACT_FINANCIALS
========================== */

CREATE TABLE fact_financials (

    Financial_ID INT IDENTITY(1,1) PRIMARY KEY,

    Flight_Date DATE,

    Route_ID INT,

    Total_Revenue_USD DECIMAL(18,2),

    Ticket_Revenue_USD DECIMAL(18,2),

    Ancillary_Revenue_USD DECIMAL(18,2),

    Total_Operating_Cost_USD DECIMAL(18,2),

    Fuel_Cost_USD DECIMAL(18,2),

    Crew_Cost_USD DECIMAL(18,2),

    Airport_Fees_USD DECIMAL(18,2),

    Maintenance_Cost_USD DECIMAL(18,2),

    Navigation_Fees_USD DECIMAL(18,2),

    Aircraft_Lease_Cost_USD DECIMAL(18,2),

    Ground_Handling_Cost_USD DECIMAL(18,2),

    Security_Cost_USD DECIMAL(18,2),

    Operating_Profit_USD DECIMAL(18,2),

    FOREIGN KEY (Route_ID)
        REFERENCES dim_route(Route_ID)

);

GO


/* ==========================
   FORECAST_DATASET
========================== */

CREATE TABLE forecast_dataset (

    Forecast_Date DATE PRIMARY KEY,

    Passengers FLOAT,

    Seats_Offered FLOAT,

    Flights_Operated FLOAT,

    Load_Factor FLOAT,

    Delay_Rate FLOAT,

    Demand_Index FLOAT,

    Fuel_Index FLOAT,

    Competition_Index FLOAT,

    Security_Risk_Index FLOAT,

    Total_Revenue_USD FLOAT,

    Total_Operating_Cost_USD FLOAT,

    Operating_Profit_USD FLOAT,

    Passengers_Lag_1 FLOAT,

    Passengers_Lag_7 FLOAT,

    Revenue_Lag_7 FLOAT,

    Passengers_Rolling_7 FLOAT,

    Revenue_Rolling_7 FLOAT

);

GO