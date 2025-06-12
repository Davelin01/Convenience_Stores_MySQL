# 🚀 Database Designs and Sales Data Analytics for Convenience Stores in MySQL
This project involves designing a MySQL database for a chain of convenience stores, aimed at tracking sales data and generating business insights to support decision-making.

## 🏗️ Database Schema

### ERD (Entity-Relationship Diagram)
   
![image](https://github.com/user-attachments/assets/2a46601f-084f-453a-9d64-991475ec631d)


### The following SQL CREATE TABLE statements were used to define the schema:
```SQL
-- Use specified schema
CREATE SCHEMA IF NOT EXISTS `6_12eleven`;
USE `6_12eleven`;

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
    FOREIGN KEY (MajorProductCategoryID) REFERENCES MajorProductCategory(MajorProductCategoryID)
);

-- Creating the ProductSubCategory table
CREATE TABLE IF NOT EXISTS ProductSubCategory (
    ProductSubCategoryID INT PRIMARY KEY,
    ProductSubCategoryDesc VARCHAR(60),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductCategoryID INT,
    FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategory(ProductCategoryID)
);

--Creating the ProductGroup table
CREATE TABLE IF NOT EXISTS ProductGrp (
    ProductGrpID BIGINT PRIMARY KEY,
    ProductGrpDesc VARCHAR(80),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductSubCategoryID INT,
    FOREIGN KEY (ProductSubCategoryID) REFERENCES ProductSubCategory(ProductSubCategoryID)
);

-- Creating the Product table
CREATE TABLE IF NOT EXISTS Product (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductNumber BIGINT,
    ProductDesc VARCHAR(60),
    UnitPrice DECIMAL(13,2),
    CreatedOn DATE,
    ChangedOn DATE,
    ProductGrpID BIGINT,
    FOREIGN KEY (ProductGrpID) REFERENCES ProductGrp(ProductGrpID)
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
    FOREIGN KEY (SalesOrderID, ItemNo) REFERENCES SalesOrderHeader(SalesOrderID, SalesItem),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Adding indexes for foreign keys
CREATE INDEX fk_SalesOrderHeader_StoreMaster_idx ON SalesOrderHeader (StoreID);
CREATE INDEX fk_SalesOrderHeader_Customer_idx ON SalesOrderHeader (CustomerID);
CREATE INDEX fk_SalesOrderItem_SalesOrderHeader_idx ON SalesOrderItem (SalesOrderID);
CREATE INDEX fk_SalesOrderItem_Product_idx ON SalesOrderItem (ProductID);
CREATE INDEX fk_ProductGrp_ProductSubCategory_idx ON ProductGrp (ProductSubCategoryID);
```

## 💻 Data Loading and Cleaning

We ran SQL commands to display the data from each table after loading it from CSV files using the LOAD DATA INFILE command. To make sure the data was clean and ready, we first used temporary tables to load and clean everything before inserting it into the final tables. 

During this process, we had to do quite a bit of data cleaning and transformation to fix problems in the raw data.

``` SQL
CREATE TEMPORARY TABLE TempStoreMaster LIKE StoreMaster;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/StoreMaster.csv'
INTO TABLE TempStoreMaster
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(StoreID, Region, @CreatedOn, @Changedon)
SET
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
Changedon = COALESCE(NULLIF(@Changedon, ''), CURDATE());

INSERT INTO StoreMaster
SELECT * FROM TempStoreMaster
WHERE Region = 'SOUTH';

DROP TEMPORARY TABLE TempStoreMaster;

-- Table StoreSales
CREATE TABLE IF NOT EXISTS 6_12eleven.StoreSales (
SalesOrder INT,
SalesItem INT,
PROD_NBR BIGINT,
ProductDescription VARCHAR(60),
UnitPrice DECIMAL(10,2),
SLS_QTY INT,
EXT_SLS_AMT DECIMAL(10,2),
OrderDate DATETIME,
CustomerPhone VARCHAR(15),
CustomerCreditCard VARCHAR(20),
StoreNo INT
);


CREATE TEMPORARY TABLE TempStoreSales LIKE StoreSales;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/StoreSales.csv'
INTO TABLE TempStoreSales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Salesorder, Salesitem, PROD_NBR, ProductDescription, @UnitPrice, SLS_QTY, EXT_SLS_AMT, OrderDate)
SET
UnitPrice = IF(@UnitPrice = '#DIV/0!', 0, @UnitPrice);

INSERT INTO StoreSales
SELECT * FROM TempStoreSales
WHERE StoreNo IN (SELECT StoreID FROM StoreMaster);

DROP TEMPORARY TABLE TempStoreSales;

-- Table ProductByGroup
CREATE TABLE IF NOT EXISTS 6_12eleven.ProductByGroup (
    PROD_NBR BIGINT,
    PROD_DESC VARCHAR(80),
    ProductGroup BIGINT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductByGroup.csv'
INTO TABLE ProductByGroup
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(PROD_NBR, PROD_DESC, ProductGroup);


-- Table MajorProductCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MajorProductCategory.csv'
INTO TABLE MajorProductCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@MajorProductCategoryID, MajorProductCategoryDesc, @CreatedOn, @Changedon)
SET
MajorProductCategoryID = IF(@MajorProductCategoryID = 'Z', 0000, @MajorProductCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
Changedon = COALESCE(NULLIF(@Changedon, ''), CURDATE());


-- Table ProductCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductCategory.csv'
INTO TABLE ProductCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductCategoryID, ProductCategoryDesc, @CreatedOn, @Changedon, @MajorProductCategoryID)
SET
ProductCategoryID = CASE
    WHEN @ProductCategoryID = 'Z' THEN 0000
    WHEN @ProductCategoryID = 'RX' THEN 9999
    ELSE @ProductCategoryID
END,
MajorProductCategoryID = IF(@MajorProductCategoryID = 'Z', 0000, @MajorProductCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
Changedon = COALESCE(NULLIF(@Changedon, ''), CURDATE());


-- Table ProductSubCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductSubCategory.csv'
INTO TABLE ProductSubCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductSubCategoryID, ProductSubCategoryDesc, @CreatedOn, @Changedon, @ProductCategoryID)
SET
ProductSubCategoryID = IF(@ProductSubCategoryID = 'Z', 0000, @ProductSubCategoryID),
ProductCategoryID = CASE
    WHEN @ProductCategoryID = 'Z' THEN 0000
    WHEN @ProductCategoryID = 'RX' THEN 9999
    ELSE @ProductCategoryID
END,
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
Changedon = COALESCE(NULLIF(@Changedon, ''), CURDATE());


-- Table ProductGrp
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductGrp.csv'
INTO TABLE ProductGrp
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductGrpID, ProductGrpDesc, @CreatedOn, @Changedon, @ProductSubCategoryID)
SET
ProductGrpID = IF(@ProductGrpID = 'Z', 0000, @ProductGrpID),
ProductSubCategoryID = IF(@ProductSubCategoryID = 'Z', 0000, @ProductSubCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
Changedon = COALESCE(NULLIF(@Changedon, ''), CURDATE());

-- Table Product
INSERT INTO Product (Productnumber, ProductDesc, UnitPrice, CreatedOn, Changedon, ProductGrpID)
SELECT DISTINCT
StoreSales.PROD_NBR,
StoreSales.ProductDescription,
StoreSales.UnitPrice,
COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
COALESCE(NULLIF(@Changedon, ''), CURDATE()),
ProductByGroup.ProductGroup
FROM
StoreSales
LEFT JOIN
ProductByGroup ON StoreSales.PROD_NBR = ProductByGroup.PROD_NBR;

-- Table Customer
INSERT INTO Customer (Customerphone, CustomerCreditCard, CreatedOn, Changedon)
SELECT DISTINCT
CONCAT(SUBSTRING(StoreSales.Customerphone, 1, 5), REPLACE(REPLACE(SUBSTRING(StoreSales.Customerphone, 7), ' ', ''), '-', '')),
StoreSales.CustomerCreditCard,
COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
COALESCE(NULLIF(@Changedon, ''), CURDATE())
FROM
StoreSales;

--Table SalesOrderHeader
INSERT INTO SalesOrderHeader ( SalesOrderID , SalesItem , SalesDate , StoreID , Customer ID , CreatedOn , Changedon)

SELECT
  StoreSales.SalesOrder ,
  StoreSales.SalesItem ,
  StoreSales.OrderDate ,
  StoreSales.StoreNo ,
  Customer.CustomerID ,
  COALESCE(NULLIF ( @ CreatedOn , ' ' ) , CURDATE ( ) ) ,
  COALESCE(NULLIF ( @ Changedon , ' ' ) , CURDATE ( ) )
FROM
  StoreSales
LEFT JOIN
Customer ON StoreSales.CustomerCreditCard Customer.CustomerCreditCard


--Table SalesOrderItem

INSERT INTO SalesOrderItem ( SalesOrderID , ItemNo , Qty , TotalSale , CreatedOn , Changedon , ProductID )

SELECT
  StoreSales . SalesOrder ,
  StoreSales.SalesItem ,
  StoreSales.SLS_QTY ,
  StoreSales.EXT_SLS_AMT ,
  COALESCE(NULLIF ( @ CreatedOn , ' ' ) , CURDATE ( ) ) ,
  COALESCE(NULLIF ( @ Changedon , " ) , CURDATE ( ) ) ,
  Product.ProductID
FROM
  StoreSales
JOIN
  Product ON StoreSales . PROD_NBR Product.Productnumber AND StoreSales . UnitPrice Product . UnitPrice ;                  


```
 ### 🔍Results showing the data and the total number of entries from each table

Storemaster table:

![image](https://github.com/user-attachments/assets/fca7fd48-878d-48f3-9ad6-50f5f2020dca)

![image](https://github.com/user-attachments/assets/553c09c5-ae2e-4a16-9ddc-5e4bfb208937)



Salesorderheader:

![image](https://github.com/user-attachments/assets/157674e2-9a2f-4db7-9912-4657be95f129)

![image](https://github.com/user-attachments/assets/6a754ecf-18c9-49f2-9f71-4e11d62545b7)


Customer:

![image](https://github.com/user-attachments/assets/2fd66bfa-cc06-4cda-8348-d60876819113)

![image](https://github.com/user-attachments/assets/227f3235-2d71-44c5-9c6d-52d3e39f218d)

Product:

![image](https://github.com/user-attachments/assets/d2cb608a-e3c8-4b13-8288-effe1c5de8e7)

![image](https://github.com/user-attachments/assets/70ac68ec-d73b-4810-8284-81a82c1e08f3)

SalesOrderItem:

![image](https://github.com/user-attachments/assets/e34c0b65-d69d-41a7-86b3-0672e9b6a35c)


![image](https://github.com/user-attachments/assets/ae37ac5e-1c04-4555-a2fa-4b5dc94a9780)

Productgrp:

![image](https://github.com/user-attachments/assets/58796596-5d4d-4c9d-b9a4-9960c7976de5)

![image](https://github.com/user-attachments/assets/4dc4d7f6-cffe-40f2-95f9-fb0a135ec082)


MajorProductCategory:

![image](https://github.com/user-attachments/assets/f765a857-d474-435e-b46c-2ef0ad410721)

![image](https://github.com/user-attachments/assets/95308451-fae2-49b5-9d63-0f214c9c46d9)

ProductCategory:

![image](https://github.com/user-attachments/assets/5d486ee1-a456-4b02-a2b2-198151e46e2a)


![image](https://github.com/user-attachments/assets/4b54eab9-8c85-4348-92f3-8eaf6532cf31)

ProductSubCategory:

![image](https://github.com/user-attachments/assets/a93d5d68-00ba-46c4-9d8e-e93638969928)


![image](https://github.com/user-attachments/assets/f0f6ca0b-8559-41e5-8ef0-2ac71b4edd1f)


## 💡 SQL Queries and Business Analytics
### ⓵ Rrecommend top three specific products should always have in stock.

``` SQL
select ProductDescription, sum(SLS_QTY)
from storesales
group by ProductDescription
order by sum(SLS_QTY) desc;
```
![image](https://github.com/user-attachments/assets/eecae107-d79c-4a97-acd8-e34f6623cd25)
### 🧠 Business Insights

🔹 These products have the highest sales volume, indicating consistent customer demand.

🔹 CARD BRTHDAY CROWN is a strong performer in both quantity and revenue.

🔹 MIDWEST FASTENER's high quantity suggests recurring or utility-based purchases.

### ⓶ Recommend the top three products, in descending priority, that should be eliminated.

``` SQL
select ProductDescription, sum(SLS_QTY)
from storesales
group by ProductDescription
order by sum(SLS_QTY) asc;
```
![image](https://github.com/user-attachments/assets/bf0dab10-4ed9-4324-b867-8a0a3eb33816)
### 🧠 Business Insights

🔹 All listed products have net negative quantities sold, meaning they were returned more than purchased, or had inventory adjustments that reduced total sales.

🔹 These products may be suffering from low demand, customer dissatisfaction, or data integrity issues.

###  ⓷ By analyzing customer purchase frequency, we identify the customers with the highest purchase counts to design more effective customer management strategies, enhance customer loyalty, and increase sales. Below are the top 10 customers with the highest purchase frequency.

``` SQL
SELECT
    c.CustomerID,
    COUNT(DISTINCT soh.SalesOrderID) AS PurchaseCount
FROM customer c
LEFT JOIN salesorderheader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY PurchaseCount DESC
LIMIT 10;
```
![image](https://github.com/user-attachments/assets/486eea09-be74-4333-aeab-b39fe7f3193a)

### 🧠 Business Insights

🔹 Customer 486 is the most active, making 42 purchases.

🔹 Customers in the 30+ purchase range likely represent the store's most loyal and engaged users.

🔹 These high-frequency customers are ideal candidates for rewards, personalized promotions, or VIP programs.

🔹 Use this list to prioritize customer service and retention efforts.


### ⓸  By analyzing the total sales amount of products, we identify the top-selling products to optimize inventory management and focus marketing efforts. Below are the top 3 products with the highest sales amounts.

``` SQL
select ProductDescription, sum(EXT_SLS_AMT)
from storesales
group by ProductDescription
order by sum(EXT_SLS_AMT) desc;
```
![image](https://github.com/user-attachments/assets/178eb131-874a-4829-9259-82604ee3f9b0)

### 🧠 Business Insights

🔹 These products generate the highest sales revenue and are essential to overall profitability.

🔹 CARD BRTHDAY CROWN likely has a higher unit price, making it a top revenue item even with lower volume.

🔹 Tobacco products like MARLBORO BOX and NEWPORT 100'S show consistent revenue through regular purchases.

###  ⓹ By analyzing the total sales quantity of product categories, we identify the top-selling product categories to optimize inventory management and marketing strategies. Below are the top 3 product categories ranked by sales quantity.

``` SQL
select ProductCategory.ProductCategoryDesc, sum(storesales.SLS_QTY)
from storesales
left join product on storesales.PROD_NBR = product.Productnumber
left join productgrp on product.ProductGrpID = productgrp.ProductGrpID
left join productsubcategory on productgrp.ProductsubcategoryID = productsubcategory.ProductsubcategoryID
left join productcategory on productsubcategory.ProductcategoryID = productcategory.ProductcategoryID
group by ProductCategory.ProductCategoryDesc
order by sum(storesales.SLS_QTY) desc;
```
![image](https://github.com/user-attachments/assets/ba8c72ab-c67c-4c58-94ac-9b36c63f03bd)

### 🧠 Business Insights

🔹 COLD & ALLERGY leads all categories in total quantity sold, indicating consistent demand.

🔹 CONFECTIONS performs strongly, likely due to its broad consumer appeal and frequent purchases.

🔹 SEWING & CRAFTS ranking third suggests a niche but high-engagement customer base.

