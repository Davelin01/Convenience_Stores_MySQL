# Database Designs and Sales Data Analytics for Convenience Stores in MySQL




## 📌 Project Overview

This project involves designing a MySQL database for a chain of convenience stores, aimed at tracking sales data and generating business insights to support decision-making.

## 🏗️ Database Schema
Logical Data Model
The logical data model for the StoreMaster database is represented by the Entity-Relationship (ER) diagram below. It illustrates the entities (tables), their attributes, primary keys, and the relationships between them, ensuring data integrity and efficiency.

🔹Create a structured and normalized relational database for tracking products, sales, inventory, stores, and employees.

🔹Ensure scalability and efficient querying for business intelligence.  


  🔍 **ERD (Entity-Relationship Diagram)**
   
![image](https://github.com/user-attachments/assets/2a46601f-084f-453a-9d64-991475ec631d)


The following SQL CREATE TABLE statements were used to define the schema:
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

Run SQL commands to display the data from each of the tables.

Data was loaded from CSV files using LOAD DATA INFILE commands. A temporary table strategy was employed for initial loading and cleaning before inserting into the final tables. This process involved extensive data cleaning and transformation to address various issues identified in the raw data.

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
```sql
-- Image: image_52acb4.png
-- Table Customer
INSERT INTO Customer (Customerphone, CustomerCreditCard, CreatedOn, Changedon)
SELECT DISTINCT
CONCAT(SUBSTRING(StoreSales.Customerphone, 1, 5), REPLACE(REPLACE(SUBSTRING(StoreSales.Customerphone, 7), ' ', ''), '-', '')),
StoreSales.CustomerCreditCard,
COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
COALESCE(NULLIF(@Changedon, ''), CURDATE())
FROM
StoreSales;
```


Data Cleaning Challenges and Solutions
The raw Excel data received from the franchise was indeed "dirty" and posed several challenges:

Negative Values in Sales Data: SLS_QTY and EXT_SLS_AMT fields contained illogical negative values. These were handled during the data loading process, likely by setting them to zero or excluding them, though the exact SQL for this specific fix isn't shown in the provided snippets.

Date Format Issues: Dates in the dataset were not compatible with MySQL. The COALESCE(NULLIF(@column, ''), CURDATE()) function was used to handle missing or incorrectly formatted dates by converting them to the current date if invalid.

Null or Missing Values in Critical Fields: Columns that should not have nulls were missing data. COALESCE was used to replace nulls with default values (e.g., CURDATE() for dates, or 0000/9999 for specific IDs).

Duplicate Records: Identified and addressed during the loading and INSERT DISTINCT processes to prevent data inflation.

Inconsistent Product Information: Some PROD_NBR had different descriptions, and identical descriptions were tied to multiple product numbers. This was a challenge in establishing unique product identifiers and was mitigated by careful joins and data mapping during product table population.

Incorrect Data Types: IDs or quantities were stored as text. CASE statements and IF conditions were used to convert these to appropriate numeric types (INT, BIGINT).

Data Beyond Expected Ranges: Certain ID fields exceeded INT limitations. These were converted to BIGINT to accommodate larger values. Credit card numbers were also stored as VARCHAR to prevent scientific notation conversion and data loss.

5. SQL Queries and Business Analytics
SQL queries were developed to extract meaningful insights and support business critical decisions.

Data Verification Queries (Counts)
Counts of entries in each table were performed to verify data integrity after loading:

Table

Count

SQL Query

Customer

9015

SELECT COUNT(*) AS NumberOfEntries FROM Customer;

MajorProductCategory

24

SELECT COUNT(*) AS NumberOfEntries FROM MajorProductCategory;

Product

4196

SELECT COUNT(*) AS NumberOfEntries FROM Product;

ProductCategory

92

SELECT COUNT(*) AS NumberOfEntries FROM ProductCategory;

ProductGrp

62

SELECT COUNT(*) AS NumberOfEntries FROM ProductGrp;

ProductSubCategory

62

SELECT COUNT(*) AS NumberOfEntries FROM ProductSubCategory;

SalesOrderHeader

28042

SELECT COUNT(*) AS NumberOfEntries FROM SalesOrderHeader;

SalesOrderItem

28042

SELECT COUNT(*) AS NumberOfEntries FROM SalesOrderItem;

StoreMaster

72

SELECT COUNT(*) AS NumberOfEntries FROM StoreMaster;

Business Critical Decisions and Analytics
A. Top Products to Always Have in Stock (Descending Priority)
Recommendation: Stores in the "SOUTH" region should prioritize stocking these top-selling products by quantity.

SELECT ProductDescription, SUM(SLS_QTY) AS TotalQuantitySold
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(SLS_QTY) DESC
LIMIT 3;

Results:
| ProductDescription | TotalQuantitySold |
| :----------------- | :---------------- |
| MIDWEST EASTENER   | 361               |
| CARO BIRTHDAY CROWN| 356               |
| IBOCOMBO           | 320               |

B. Top Products to Consider Not Carrying (Descending Priority for Elimination)
Recommendation: Stores in the "SOUTH" region should consider eliminating these products due to very low sales volume.

SELECT ProductDescription, SUM(SLS_QTY) AS TotalQuantitySold
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(SLS_QTY) ASC
LIMIT 3;

Results:
| ProductDescription             | TotalQuantitySold |
| :----------------------------- | :---------------- |
| KOI LIGHTLY CANDY BAG SIE CHOCLMINT 17.5 OZ | 3                 |
| ARROW ROLL ON REGULAR 1.75 OZ  | 3                 |
| LINDEMAN'S WINE BASE           | 3                 |

C. Additional Business Critical Decisions
Top Customers by Purchase Frequency
Recommendation: Identify and engage these high-frequency customers with loyalty programs and targeted marketing campaigns to enhance retention.

SELECT c.CustomerID, COUNT(DISTINCT soh.SalesOrderID) AS PurchaseCount
FROM Customer c
LEFT JOIN SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY PurchaseCount DESC
LIMIT 10;

Results:
| CustomerID | PurchaseCount |
| :--------- | :------------ |
| 466        | 42            |
| 358        | 39            |
| 379        | 38            |
| 442        | 37            |
| 497        | 36            |
| 305        | 34            |
| 330        | 32            |
| 454        | 32            |
| 443        | 32            |
| 186        | 32            |

Top-Selling Products by Total Sales Amount
Recommendation: Optimize inventory and marketing efforts around these high-revenue products.

SELECT ProductDescription, SUM(EXT_SLS_AMT) AS TotalSalesAmount
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(EXT_SLS_AMT) DESC
LIMIT 3;

Results:
| ProductDescription | TotalSalesAmount |
| :----------------- | :--------------- |
| CARO BIRTHDAY CROWN| 2195.49          |
| MANBORO BOX        | 1389.98          |
| NEWPORT WINE       | 1494.48          |

Top-Selling Product Categories by Sales Quantity
Recommendation: Focus on product categories that drive high sales volume for inventory management and broad marketing strategies.

SELECT pc.ProductCategoryDesc, SUM(ss.SLS_QTY) AS TotalCategoryQuantitySold
FROM storesales ss
LEFT JOIN product p ON ss.PROD_NBR = p.Productnumber
LEFT JOIN productgrp pg ON p.ProductGrpID = pg.ProductGrpID
LEFT JOIN productsubcategory psc ON pg.ProductSubCategoryID = psc.ProductSubCategoryID
LEFT JOIN productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryDesc
ORDER BY SUM(ss.SLS_QTY) DESC
LIMIT 3;

Results:
| ProductCategoryDesc | TotalCategoryQuantitySold |
| :------------------ | :------------------------ |
| COLD & ALLERGY      | 64394                     |
| CONVENIENCE         | 25985                     |
| SMOKING & CRAFTS    | 18030                     |

6. Project Summary
6.1. Project Timeline
Project Initiation and Data Preparation (11.10 - 11.12)

EER Diagram Creation: Analyzed dataset to design the ER diagram.

CSV Splitting: Divided main CSV into normalized files.

Table Creation: Created tables with CREATE TABLE scripts, including temporary table logic for cleaning.

Database Import and Verification Phase (11.13 - 11.15)

11.13: Imported basic tables (MajorProductCategory, ProductCategory), performed initial integrity checks and foreign key testing.

11.14 - 11.15: Imported remaining tables (StoreSales), implemented dynamic field conversion (e.g., COALESCE, CASE), verified foreign key constraints, ran JOIN queries, and used SELECT COUNT(*) for data validation.

SQL Query Development and Business Analysis Phase (11.16 - 11.19)

Developed queries for inventory recommendations (top/bottom sales).

Developed analytical queries for product categories, customers, and revenue sources.

Generated business recommendations based on query results (inventory optimization, loyalty programs, promotion adjustments).

Final Inspection and Report Preparation Phase (11.20 - 11.21)

11.20: Collated query results, updated documentation (final ERD, physical design).

11.21: Completed project summary report (business analysis, suggestions), and prepared presentation materials.

6.2. Dirty Data Indications
Several indications of dirty data were encountered in the Excel dataset:

Negative Values: Sales quantity (SLS_QTY) and amount (EXT_SLS_AMT) fields contained negative values, which are logically impossible.

Date Format Issues: Inconsistent and incompatible date formats that required conversion for MySQL.

Null or Missing Values: Critical fields that should not have nulls contained missing data, violating primary key and data integrity principles.

Duplicate Records: Presence of identical rows potentially inflating sales or inventory figures.

Inconsistent Product Information:

Same product numbers (PROD_NBR) associated with different descriptions.

Identical descriptions associated with multiple product numbers.

Incorrect Data Types: IDs or quantities stored as text, necessitating type conversion for proper operations.

Data Beyond Expected Ranges: Some ID fields exceeded typical integer data type limits (e.g., credit card numbers converted to scientific notation), requiring BIGINT or VARCHAR types.

6.3. Loading Regional Sales Data
To load sales data specifically for our region ("SOUTH"), a WHERE clause was used during the insertion process from the temporary table to the final StoreMaster table:

INSERT INTO StoreMaster
SELECT * FROM TempStoreMaster
WHERE Region = 'SOUTH';

This ensured that only relevant regional data was populated into the database.

6.4. Foreseen Challenges in Future Projects
In a later industry database conversion project, several challenges might be faced that were not fully encountered here:

Data Format Issues (Advanced): Beyond simple date conversions, complex or highly varied data formats (e.g., JSON blobs in CSVs, non-standard delimiters, nested structures) would require more sophisticated parsing and transformation tools (ETL pipelines) rather than simple LOAD DATA INFILE and SQL functions. Credit card number scientific notation conversion was an early indicator of this.

Duplicate Data (Complex Scenarios): While duplicates were handled, large-scale industrial systems might have subtle duplicates arising from data synchronization issues, delayed transactions, or mergers, requiring advanced deduplication algorithms and business rules.

Foreign Key Integrity (Distributed Systems): Maintaining foreign key integrity across distributed databases or microservices would be significantly more challenging than in a single relational database. It would require distributed transaction management, eventual consistency models, or stricter application-level enforcement.

Schema Evolution: In an evolving system, managing schema changes (e.g., adding columns, modifying data types, refactoring tables) without downtime or data loss would be a major challenge.

Performance at Scale: Handling petabytes of data and millions of transactions per second would necessitate different database technologies (NoSQL, data warehouses), indexing strategies, and query optimization techniques.

6.5. Top Two Project Takeaways
Data Cleaning and Normalization Are Critical for Ensuring Database Integrity:
Thorough data cleaning and normalization (to 3NF) are foundational for any industrial-strength database. Issues like negative values, inconsistent product information, and null entries directly impact query accuracy and analytical processes. Proper constraints (primary and foreign keys) are essential for data consistency and redundancy reduction.

Iterative Design and Testing Reduce Errors in Large-Scale Database Projects:
An iterative approach to database design, building, and testing each table proved invaluable. Validating the data model, testing connections with JOIN queries, and verifying data counts early helped identify and resolve potential issues (incorrect relationships, missing data) proactively. This step-by-step methodology ensures a robust design and reduces the high cost of failure in complex, large-scale database projects.




Table of Contents
1. Project Overview

2. Logical Data Model

3. Database Schema

4. Data Loading and Cleaning

5. SQL Queries and Business Analytics

6. Project Summary

6.1. Project Timeline

6.2. Dirty Data Indications

6.3. Loading Regional Sales Data

6.4. Foreseen Challenges in Future Projects

6.5. Top Two Project Takeaways
