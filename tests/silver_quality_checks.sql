USE DataWarehouse;
GO

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--Check for unwanted Spaces
--Expectation: No Results
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--Check for unwanted Spaces
--Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_firstname)

--Check for unwanted Spaces
--Expectation: No Results
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_gndr)

--Data Standardization & Consistency
--check we have what values expected M,F AND NULL
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

SELECT * FROM silver.crm_cust_info

-- Check For Nulls or Duplicates in Primary Key
--Expectation: No Result
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for NULLs or Negative Numbers
--Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

--Check for Invalid Date Orders
SELECT*
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT DISTINCT
    sls_sales AS old_sls_sales,          -- original sales value
    sls_quantity,
    sls_price AS old_sls_price,          -- original price value

    CASE 
        WHEN sls_sales IS NULL 
             OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)   -- recalculate sales if invalid
        ELSE sls_sales
    END AS sls_sales,

    CASE 
        WHEN sls_price IS NULL 
             OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)  -- recalc price if invalid
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

--Check for Invalid Dates
SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT * FROM silver.crm_sales_details

SELECT * FROM silver.erp_cust_az12

SELECT DISTINCT gen FROM silver.erp_cust_az12
SELECT DISTINCT gen FROM bronze.erp_cust_az12
