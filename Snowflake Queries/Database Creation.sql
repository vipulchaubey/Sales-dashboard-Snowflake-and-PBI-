TEST_DB.TEST_DB_SCHEMA.TESTSTAGE
Create database test_db;
create schema test_db_schema;

CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,
    Date DATE,
    DayOfWeek VARCHAR(10),
    Month VARCHAR(10),
    Quarter INT,
    Year INT,
    IsWeekend BOOLEAN
);

CREATE OR REPLACE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY autoincrement start 1 increment 1,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    DateOfBirth DATE,
    Email VARCHAR(100),
    PhoneNumber VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    LoyaltyProgramID INT
);

-- Dimension Table: DimProduct
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY autoincrement start 1 increment 1,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Brand VARCHAR(50),
    UnitPrice DECIMAL(10, 2)
);

CREATE or REPLACE TABLE DimStore (
    StoreID INT PRIMARY KEY autoincrement start 1 increment 1,
    StoreName VARCHAR(100),
    StoreType VARCHAR(50),
	StoreOpeningDate DATE,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Region varchar(200),
    ManagerName VARCHAR(100)
);

-- Dimension Table: DimLoyaltyProgram
CREATE TABLE DimLoyaltyProgram (
    LoyaltyProgramID INT PRIMARY KEY,
    ProgramName VARCHAR(100),
    ProgramTier VARCHAR(50),
    PointsAccrued INT
);


-- Fact Table: FactOrders
CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY autoincrement start 1 increment 1,
    DateID INT,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    QuantityOrdered INT,
    OrderAmount DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    ShippingCost DECIMAL(10, 2),
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (StoreID) REFERENCES DimStore(StoreID)
);


CREATE OR REPLACE FILE FORMAT CSV_SOURCE_FILE_FORMAT
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
DATE_FORMAT = 'YYYY-MM-DD';

CREATE OR REPLACE STAGE TESTSTAGE;




COPY INTO DimLoyaltyProgram
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimLoyaltyInfo.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')

update DIMLOYALTYPROGRAM set pointsaccrued=pointsaccrued>300;
commit;


COPY  INTO DimCustomer(FirstName,LastName,Gender,DateOfBirth,Email,PhoneNumber,Address,City,State,ZipCode,Country,LoyaltyProgramId)
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')

Select * from DimCustomer;

COPY INTO DimProduct (ProductName,Category,Brand,UnitPrice)
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimProductData.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')


COPY INTO DimDate (DateId,Date,DayOfWeek,Month,Quarter,Year,IsWeekend)
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimDate.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')


COPY INTO DimStore (StoreName,StoreType,StoreOpeningDate,Address,City,State,Country,Region,ManagerName)
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimStoreData.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')


COPY INTO FactOrders (DateID,CustomerId,ProductId,StoreId,QuantityOrdered,OrderAmount,DiscountAmount,ShippingCost,TotalAmount )
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/factorders.csv
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')



COPY INTO FactOrders (DateID,CustomerId,ProductId,StoreId,QuantityOrdered,OrderAmount,DiscountAmount,ShippingCost,TotalAmount )
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/
FILE_FORMAT = (FORMAT_NAME= 'CSV_SOURCE_FILE_FORMAT')


--Create User
Create or Replace User Test_PowerBI_User
        Password = 'Test_PowerBI_User'
    Login_Name = 'PowerBI User'
    Default_Role = 'ACCOUNTADMIN'
    Default_Warehouse = 'COMPUTE_WH'
    Must_change_password = TRUE;

    --grant admin access

grant role accountadmin to user Test_PowerBI_User;
