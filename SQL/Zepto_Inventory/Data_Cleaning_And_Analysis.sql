CREATE DATABASE zepto;
USE zepto;
CREATE TABLE zepto (
sku_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INT,
discountedSellingPrice NUMERIC(8,2),
weightInGms INT,
outOfStock VARCHAR(20),
quantity INT
);

SELECT * FROM zepto;
describe ZEPTO;
describe zepto_v2;

INSERT INTO zepto (category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity) (SELECT category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity FROM zepto_v2);

-- DATA EXPLORATION

SELECT * FROM zepto;

SELECT DISTINCT(category) FROM zepto;

SELECT * FROM zepto 
WHERE name IS NULL OR 
category IS NULL OR
mrp IS NULL OR
discountPercent IS NULL OR
availableQuantity IS NULL OR
discountedSellingPrice IS NULL OR 
weightInGms IS NULL OR
outOfStock IS NULL OR
quantity IS NULL;

SELECT outOfStock, COUNT(outOfStock) AS availablity
FROM zepto
GROUP BY outOfStock;

SELECT name, COUNT(name) AS freq
FROM zepto
GROUP BY name
HAVING freq > 1
ORDER BY freq DESC;

-- DATA CLEANING

SELECT name, mrp, discountedSellingPrice
FROM zepto 
WHERE mrp <= 0 OR discountedSellingPrice <= 0;

DELETE FROM zepto
WHERE mrp <=0 OR discountedSellingPrice <=0;

UPDATE zepto
SET mrp = mrp/100.00, discountedSellingPrice = discountedSellingPrice/100.00;

SELECT * FROM zepto;

-- ANALYSIS

-- 1) Find the top 10 best-value products based on the discount percentage.

SELECT DISTINCT(name), mrp, discountPercent
FROM zepto 
ORDER BY discountPercent DESC
LIMIT 10;

-- 2) What are the products with high mrp but out of stock.

SELECT DISTINCT(name), mrp, outOfStock 
FROM zepto 
WHERE outOfStock = "TRUE"
ORDER BY MRP DESC
LIMIT 10;

-- 3) Calculate estimated revenue fro each category.

SELECT category, SUM(discountedSellingPrice * quantity) AS Revenue
FROM zepto
GROUP BY category
ORDER BY Revenue;

-- 4) Find all products where mrp > 500 and discount < 10%.

SELECT DISTINCT(name), mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- 5) Identify the top 5 categories offering the highest average discount percentage.

SELECT category, AVG(discountPercent) AS Discount
FROM zepto 
GROUP BY category
ORDER BY Discount DESC
LIMIT 5;

-- 6) Find the price per gram for products above 100g and sort by best value.

SELECT DISTINCT(name), (discountedSellingPrice/weightInGms) AS price_per_gram
FROM zepto
WHERE weightInGms > 100
ORDER BY price_per_gram;

-- 7) Group the products into categories like low, medium, bulk.

SELECT DISTINCT(name), weightInGms,
CASE 
	WHEN weightInGms < 1000 THEN "Low"
	WHEN weightInGms < 5000 THEN "Medium"
    ELSE "Bulk"
END AS weight_category
FROM zepto;

-- 8) What is the total inventory weight per category.

SELECT category, SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight;
