# 🚀 Database Designs and Sales Data Analytics for Convenience Stores in MySQL

This project involves designing a MySQL database for a chain of convenience stores, aimed at tracking sales data and generating business insights to support decision-making.

---

## 🏗️ Database Schema

### ERD (Entity-Relationship Diagram)
![ERD](https://github.com/user-attachments/assets/2a46601f-084f-453a-9d64-991475ec631d)

---

### 🔍 Data Snapshots & Entry Counts

**Storemaster Table:**

![Storemaster Table](https://github.com/user-attachments/assets/fca7fd48-878d-48f3-9ad6-50f5f2020dca)

![Storemaster Count](https://github.com/user-attachments/assets/553c09c5-ae2e-4a16-9ddc-5e4bfb208937)

**Salesorderheader:**

![Salesorderheader Table](https://github.com/user-attachments/assets/157674e2-9a2f-4db7-9912-4657be95f129)

![Salesorderheader Count](https://github.com/user-attachments/assets/6a754ecf-18c9-49f2-9f71-4e11d62545b7)

**Customer:**

![Customer Table](https://github.com/user-attachments/assets/2fd66bfa-cc06-4cda-8348-d60876819113)

![Customer Count](https://github.com/user-attachments/assets/227f3235-2d71-44c5-9c6d-52d3e39f218d)

**Product:**

![Product Table](https://github.com/user-attachments/assets/d2cb608a-e3c8-4b13-8288-effe1c5de8e7)

![Product Count](https://github.com/user-attachments/assets/70ac68ec-d73b-4810-8284-81a82c1e08f3)

**SalesOrderItem:**

![SalesOrderItem Table](https://github.com/user-attachments/assets/e34c0b65-d69d-41a7-86b3-0672e9b6a35c)

![SalesOrderItem Count](https://github.com/user-attachments/assets/ae37ac5e-1c04-4555-a2fa-4b5dc94a9780)

**Productgrp:**

![Productgrp Table](https://github.com/user-attachments/assets/58796596-5d4d-4c9d-b9a4-9960c7976de5)

![Productgrp Count](https://github.com/user-attachments/assets/4dc4d7f6-cffe-40f2-95f9-fb0a135ec082)

**MajorProductCategory:**


![MajorProductCategory Table](https://github.com/user-attachments/assets/f765a857-d474-435e-b46c-2ef0ad410721)

![MajorProductCategory Count](https://github.com/user-attachments/assets/95308451-fae2-49b5-9d63-0f214c9c46d9)

**ProductCategory:**


![ProductCategory Table](https://github.com/user-attachments/assets/5d486ee1-a456-4b02-a2b2-198151e46e2a)

![ProductCategory Count](https://github.com/user-attachments/assets/4b54eab9-8c85-4348-92f3-8eaf6532cf31)

**ProductSubCategory:**


![ProductSubCategory Table](https://github.com/user-attachments/assets/a93d5d68-00ba-46c4-9d8e-e93638969928)

![ProductSubCategory Count](https://github.com/user-attachments/assets/f0f6ca0b-8559-41e5-8ef0-2ac71b4edd1f)

---

## 💡 SQL Queries and Business Analytics

### ⓵ Top Three Products to Always Stock

```sql
SELECT ProductDescription, SUM(SLS_QTY)
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(SLS_QTY) ASC
LIMIT 3;
```
![Top 3 by Sales Quantity](https://github.com/user-attachments/assets/eecae107-d79c-4a97-acd8-e34f6623cd25)

**Business Insights**
- These three products have proven, consistent demand. They should always be kept in stock to meet customer need and maximize sales.

---

### ⓶ Top Three Products to Eliminate

```sql
SELECT ProductDescription, SUM(SLS_QTY)
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(SLS_QTY) ASC
LIMIT 3;
```
![Bottom 3 by Sales Quantity](https://github.com/user-attachments/assets/bf0dab10-4ed9-4324-b867-8a0a3eb33816)

**Business Insights**
- Negative sales suggest more returns or adjustments than purchases, signaling poor performance or possible inventory/data issues.
- We should reviewe these items for discontinuation or a strategy adjustment if there's no data issues.

---

### ⓷ Top 10 Customers by Purchase Frequency

```sql
SELECT
    c.CustomerID,
    COUNT(DISTINCT soh.SalesOrderID) AS PurchaseCount
FROM customer c
LEFT JOIN salesorderheader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY PurchaseCount DESC
LIMIT 10;
```
![Top 10 Customers](https://github.com/user-attachments/assets/486eea09-be74-4333-aeab-b39fe7f3193a)

**Business Insights**
- These high-frequency buyers are prime candidates for loyalty programs, exclusive offers, and targeted communications to increase retention and spending.

---

### ⓸ Top 3 Products by Sales Revenue

```sql
SELECT ProductDescription, SUM(EXT_SLS_AMT)
FROM storesales
GROUP BY ProductDescription
ORDER BY SUM(EXT_SLS_AMT) DESC
LIMIT 3;
```
![Top 3 by Revenue](https://github.com/user-attachments/assets/178eb131-874a-4829-9259-82604ee3f9b0)

**Business Insights**
- **MARLBORO BOX ** and **NEWPORT 100'S** (tobacco) are crucial for overall profitability and should be prioritized in inventory decisions.

---

### ⓹ Top 3 Product Categories by Sales Quantity

```sql
SELECT ProductCategory.ProductCategoryDesc, SUM(storesales.SLS_QTY)
FROM storesales
LEFT JOIN product on storesales.PROD_NBR = product.Productnumber
LEFT JOIN productgrp on product.ProductGrpID = productgrp.ProductGrpID
LEFT JOIN productsubcategory ON productgrp.ProductsubcategoryID = productsubcategory.ProductsubcategoryID
LEFT JOIN productcategory ON productsubcategory.ProductcategoryID = productcategory.ProductcategoryID
GROUP BYProductCategory.ProductCategoryDesc
ORDER BYsum(storesales.SLS_QTY) DESC
LIMIT 3;
```
![Top 3 Categories by Sales Quantity](https://github.com/user-attachments/assets/ba8c72ab-c67c-4c58-94ac-9b36c63f03bd)

**Business Insights**
- **COLD & ALLERGY** is the highest-selling category by a significant margin. Prioritize inventory and promotions here for steady turnover.
- **CONFECTIONS** is a reliably popular impulse-buy and repeat-purchase category. Keep shelves well-stocked and consider seasonal promotions.
- **SEWING & CRAFTS** shows unexpectedly high engagement and has potential for niche marketing, community events, or further product expansion.

---
