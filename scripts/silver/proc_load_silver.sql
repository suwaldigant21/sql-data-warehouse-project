/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/


USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    /*
        @proc_start_time / @proc_end_time:
        Store start and end timestamp for the whole procedure execution.
    */
    DECLARE @proc_start_time DATETIME, @proc_end_time DATETIME;

    /*
        @table_start_time / @table_end_time:
        Store start and end timestamp for each individual table load.
    */
    DECLARE @table_start_time DATETIME, @table_end_time DATETIME;

    /*
        @rows_inserted:
        Stores number of rows inserted by the most recent INSERT INTO statement.
    */
    DECLARE @rows_inserted INT;

    /*
        SET NOCOUNT ON:
        Prevents "X rows affected" messages after each statement.
        This improves performance slightly and keeps output cleaner.
    */
    SET NOCOUNT ON;

    -- Start whole procedure timer
    SET @proc_start_time = GETDATE();

    BEGIN TRY
        PRINT '------------------------';
        PRINT 'LOADING SILVER LAYER';
        PRINT '------------------------';

        /* ==========================================================================================
              CRM Customer Info
              - Normalize names (trim spaces)
              - Normalize marital status and gender
              - Keep only the most recent record per customer
            ========================================================================================== */
        SET @table_start_time = GETDATE(); -- Start time for this table load

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id 
                       ORDER BY cst_create_date DESC
                   ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @rows_inserted = @@ROWCOUNT;   -- Rows inserted by previous INSERT INTO
        SET @table_end_time = GETDATE();   -- End time for this table load

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ==========================================================================================
              CRM Product Info
              - Derive category ID from product key
              - Normalize product line values
              - Replace null cost with 0
              - Calculate end date as day before next start date
            ========================================================================================== */
        SET @table_start_time = GETDATE();

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line)) 
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key ORDER BY prd_start_dt
                )) AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ==========================================================================================
              CRM Sales Details
              - Clean dates (set invalid to NULL)
              - Recalculate sales if invalid
              - Recalculate price if invalid
            ========================================================================================== */
        SET @table_start_time = GETDATE();

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 
                      OR sls_sales != sls_quantity * ABS(sls_price)
                 THEN sls_quantity * ABS(sls_price)
                 ELSE sls_sales END AS sls_sales,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                 THEN sls_sales / NULLIF(sls_quantity, 0)
                 ELSE sls_price END AS sls_price
        FROM bronze.crm_sales_details;

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ==========================================================================================
              ERP Customer AZ12
              - Remove NAS prefix from customer ID
              - Set future birthdates to NULL
              - Normalize gender values (strip hidden carriage returns/newlines)
            ========================================================================================== */
        SET @table_start_time = GETDATE();

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                 ELSE cid END AS cid,
            CASE WHEN bdate > GETDATE() THEN NULL
                 ELSE bdate END AS bdate,
            CASE 
                WHEN gen IS NULL THEN NULL
                -- Standard LTRIM/RTRIM/TRIM fails if raw bronze data contains hidden carriage returns (\r) or newlines (\n) from file imports.
                -- We must explicitly strip out CHAR(13) and CHAR(10) first.
                WHEN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), '')))) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), '')))) IN ('M', 'MALE')   THEN 'Male'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_cust_az12;

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ==========================================================================================
              ERP Location A101
              - Remove dashes from customer ID
              - Normalize country values
            ========================================================================================== */
        SET @table_start_time = GETDATE();

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            CASE 
                -- Stripping out hidden carriage returns (CHAR(13)) and newlines (CHAR(10)) to allow accurate country mapping
                WHEN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')))) = 'DE' 
                    THEN 'Germany'
                WHEN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')))) IN ('US', 'USA') 
                    THEN 'United States'
                WHEN cntry IS NULL 
                     OR LTRIM(RTRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) = '' 
                    THEN 'n/a'
                ELSE LTRIM(RTRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')))
            END AS cntry
        FROM bronze.erp_loc_a101;

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ==========================================================================================
              ERP PX Category G1V2
              - Direct insert (no transformations)
            ========================================================================================== */
        SET @table_start_time = GETDATE();

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        -- End whole procedure timer
        SET @proc_end_time = GETDATE();

        PRINT '========================';
        PRINT 'SILVER LOAD COMPLETED SUCCESSFULLY';
        PRINT 'Total Procedure Duration: '
              + CAST(DATEDIFF(SECOND, @proc_start_time, @proc_end_time) AS VARCHAR(20))
              + ' seconds';
        PRINT '========================';
    END TRY
    /*
        END TRY:
        Marks the end of the "normal execution" block.
        If no error occurs, CATCH block is skipped.
    */
    BEGIN CATCH
        /*
            BEGIN CATCH:
            Starts error-handling block.
            Executes only if any statement in TRY fails.
        */
        SET @proc_end_time = GETDATE();

        PRINT '------------------------';
        PRINT 'ERROR OCCURRED DURING SILVER LOAD';
        PRINT '------------------------';

        /*  ERROR_NUMBER(): Returns SQL Server error code. */
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(20));

        /*  ERROR_MESSAGE(): Returns full error message text. */
        PRINT 'Error Message : ' + ERROR_MESSAGE();

        /*  ERROR_LINE(): Returns line number where error occurred. */
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(20));

        PRINT 'Elapsed Before Failure: '
              + CAST(DATEDIFF(SECOND, @proc_start_time, @proc_end_time) AS VARCHAR(20))
              + ' seconds';

        /*  THROW: Re-raises original error so caller/job can detect failure. */
        THROW;
    END CATCH
    /*  END CATCH: Marks end of error-handling block. */
END;
GO
