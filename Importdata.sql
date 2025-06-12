USE 6_12eleven;


-- Table StoreMaster

CREATE TEMPORARY TABLE TempStoreMaster LIKE StoreMaster;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/StoreMaster.csv'
INTO TABLE TempStoreMaster
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(StoreID, Region, @CreatedOn, @ChangedOn)
SET
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
ChangedOn = COALESCE(NULLIF(@ChangedOn, ''), CURDATE());

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
(Salesorder, Salesitem, PROD_NBR, ProductDescription, @UnitPrice, SLS_QTY, EXT_SLS_AMT, OrderDate, CustomerPhone, CustomerCreditCard, StoreNo)
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
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(PROD_NBR, PROD_DESC, ProductGroup);


-- Table MajorProductCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MajorProductCategory.csv'
INTO TABLE MajorProductCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@MajorProductCategoryID, MajorProductCategoryDesc, @CreatedOn, @ChangedOn)
SET
MajorProductCategoryID = IF(@MajorProductCategoryID = 'Z', 0000, @MajorProductCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
ChangedOn = COALESCE(NULLIF(@ChangedOn, ''), CURDATE());


-- Table ProductCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductCategory.csv'
INTO TABLE ProductCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductCategoryID, ProductCategoryDesc, @CreatedOn, @ChangedOn, @MajorProductCategoryID)
SET
ProductCategoryID = CASE
    WHEN @ProductCategoryID = 'Z' THEN 0000
    WHEN @ProductCategoryID = 'RX' THEN 9999
    ELSE @ProductCategoryID
END,
MajorProductCategoryID = IF(@MajorProductCategoryID = 'Z', 0000, @MajorProductCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
ChangedOn = COALESCE(NULLIF(@ChangedOn, ''), CURDATE());


-- Table ProductSubCategory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductSubCategory.csv'
INTO TABLE ProductSubCategory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductSubCategoryID, ProductSubCategoryDesc, @CreatedOn, @ChangedOn, @ProductCategoryID)
SET
ProductSubCategoryID = IF(@ProductSubCategoryID = 'Z', 0000, @ProductSubCategoryID),
ProductCategoryID = CASE
    WHEN @ProductCategoryID = 'Z' THEN 0000
    WHEN @ProductCategoryID = 'RX' THEN 9999
    ELSE @ProductCategoryID
END,
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
ChangedOn = COALESCE(NULLIF(@ChangedOn, ''), CURDATE());


-- Table ProductGrp
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ProductGrp.csv'
INTO TABLE ProductGrp
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@ProductGrpID, ProductGrpDesc, @CreatedOn, @ChangedOn, @ProductSubCategoryID)
SET
ProductGrpID = IF(@ProductGrpID = 'Z', 0000, @ProductGrpID),
ProductSubCategoryID = IF(@ProductSubCategoryID = 'Z', 0000, @ProductSubCategoryID),
CreatedOn = COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
ChangedOn = COALESCE(NULLIF(@ChangedOn, ''), CURDATE());


-- Table Product
INSERT INTO Product (Productnumber, ProductDesc, UnitPrice, CreatedOn, ChangedOn, ProductGrpID)
SELECT DISTINCT
    StoreSales.PROD_NBR, 
    StoreSales.ProductDescription, 
    StoreSales.UnitPrice, 
    COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
    COALESCE(NULLIF(@ChangedOn, ''), CURDATE()),
    ProductByGroup.ProductGroup
FROM 
    StoreSales
LEFT JOIN 
    ProductByGroup ON StoreSales.PROD_NBR = ProductByGroup.PROD_NBR;


-- Table Customer    
INSERT INTO Customer (Customerphone, CustomerCreditCard, CreatedOn, ChangedOn)
SELECT DISTINCT
    CONCAT(SUBSTRING(StoreSales.Customerphone, 1, 5), REPLACE(REPLACE(SUBSTRING(StoreSales.Customerphone, 7), ' ', ''), '-', '')),
    StoreSales.CustomerCreditCard, 
    COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
    COALESCE(NULLIF(@ChangedOn, ''), CURDATE())
FROM 
    StoreSales;


-- Table SalesOrderHeader  
INSERT INTO SalesOrderHeader (SalesOrderID, SalesItem, SalesDate, StoreID, CustomerID, CreatedOn, ChangedOn)
SELECT 
    StoreSales.SalesOrder, 
    StoreSales.SalesItem,
    StoreSales.OrderDate,
    StoreSales.StoreNo,
    Customer.CustomerID,
    COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
    COALESCE(NULLIF(@ChangedOn, ''), CURDATE())
FROM 
    StoreSales
LEFT JOIN
    Customer ON StoreSales.CustomerCreditCard = Customer.CustomerCreditCard;


-- Table SalesOrderItem 
INSERT INTO SalesOrderItem (SalesOrderID, ItemNo, Qty, TotalSale, CreatedOn, ChangedOn, ProductID)
SELECT 
    StoreSales.SalesOrder, 
    StoreSales.SalesItem,
    StoreSales.SLS_QTY,
    StoreSales.EXT_SLS_AMT,
    COALESCE(NULLIF(@CreatedOn, ''), CURDATE()),
    COALESCE(NULLIF(@ChangedOn, ''), CURDATE()),
    Product.ProductID
FROM
	StoreSales
JOIN
	Product ON StoreSales.PROD_NBR = Product.Productnumber AND StoreSales.UnitPrice = Product.UnitPrice;
