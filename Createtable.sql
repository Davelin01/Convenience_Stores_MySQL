-- Specify the database to use
create schema 6_12eleven ;
USE 6_12eleven;

-- Creating the MajorProductCategory table
CREATE TABLE IF NOT EXISTS MajorProductCategory (
    MajorProductCategoryID INT PRIMARY KEY,
    MajorProductCategoryDesc VARCHAR(60),
    CreatedOn DATE,
    ChangedOn DATE
);

-- Creating the ProductCategory table
CREATE TABLE IF NOT EXISTS ProductCategory (
    ProductCategoryID INT PRIMARY KEY,
    ProductCategoryDesc VARCHAR(60),
    CreatedOn DATE,
    ChangedOn DATE,
    MajorProductCategoryID INT,
    FOREIGN KEY (MajorProductCategoryID) 
    REFERENCES MajorProductCategory(MajorProductCategoryID)
);

-- Creating the ProductSubCategory table
CREATE TABLE IF NOT EXISTS ProductSubCategory (
    ProductSubCategoryID INT PRIMARY KEY,
    ProductSubCategoryDesc VARCHAR(60),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductCategoryID INT,
    FOREIGN KEY (ProductCategoryID) 
    REFERENCES ProductCategory(ProductCategoryID)
);

-- Creating the ProductGrp table
CREATE TABLE IF NOT EXISTS ProductGrp (
    ProductGrpID BIGINT PRIMARY KEY,
    ProductGrpDesc VARCHAR(80),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductSubCategoryID INT,
    FOREIGN KEY (ProductSubCategoryID) 
    REFERENCES ProductSubCategory(ProductSubCategoryID)
);

-- Creating the Product table
CREATE TABLE IF NOT EXISTS Product (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    Productnumber BIGINT,
    ProductDesc VARCHAR(60),
    UnitPrice DECIMAL(13,2),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductGrpID BIGINT,
    FOREIGN KEY (ProductGrpID) 
    REFERENCES ProductGrp(ProductGrpID)
);

-- Creating the StoreMaster table
CREATE TABLE IF NOT EXISTS StoreMaster (
    StoreID INT PRIMARY KEY,
    Region VARCHAR(10),
    CreatedOn DATE,
    ChangedOn DATE
);

-- Creating the Customer table
CREATE TABLE IF NOT EXISTS Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerPhone VARCHAR(12),
    CustomerCreditCard VARCHAR(20),
    CreatedOn DATE,
    ChangedOn DATE
);

-- Creating the SalesOrderHeader table
CREATE TABLE IF NOT EXISTS SalesOrderHeader (
    SalesOrderID INT,
    SalesItem INT,
    SalesDate DATETIME,
    StoreID INT,
    CustomerID INT,
    CreatedOn DATE,
    ChangedOn DATE,
    PRIMARY KEY (SalesOrderID, SalesItem),
    FOREIGN KEY (StoreID) REFERENCES StoreMaster(StoreID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Creating the SalesOrderItem table
CREATE TABLE IF NOT EXISTS SalesOrderItem (
    SalesOrderID INT,
    ItemNo INT,
    Qty INT,
    TotalSale DECIMAL(13,2),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductID INT,
    PRIMARY KEY (SalesOrderID, ItemNo),
    FOREIGN KEY (SalesOrderID, ItemNo) 
    REFERENCES SalesOrderHeader(SalesOrderID, SalesItem),
    FOREIGN KEY (ProductID) 
    REFERENCES Product(ProductID)
);

-- Adding indexes for foreign keys
CREATE INDEX fk_SalesOrderHeader_StoreMaster_idx ON SalesOrderHeader (StoreID);
CREATE INDEX fk_SalesOrderHeader_Customer_idx ON SalesOrderHeader (CustomerID);
CREATE INDEX fk_SalesOrderItem_SalesOrderHeader_idx ON SalesOrderItem (SalesOrderID);
CREATE INDEX fk_SalesOrderItem_Product_idx ON SalesOrderItem (ProductID);
CREATE INDEX fk_ProductGrp_ProductSubCategory_idx ON ProductGrp (ProductSubCategoryID);
