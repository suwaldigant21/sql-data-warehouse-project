/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

USE DataWarehouse;
GO
  
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
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
       Stores number of rows inserted by the most recent BULK INSERT.
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
        PRINT 'LOADING BRONZE LAYER';
        PRINT '------------------------';

        /* =========================
           LOADING CRM TABLES
           ========================= */
        PRINT '------------------------';
        PRINT 'LOADING CRM TABLES';
        PRINT '------------------------';

        /* ===== bronze.crm_cust_info ===== */
        SET @table_start_time = GETDATE(); -- Start time for this table load

        PRINT '>>> TRUNCATING TABLE: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>>> INSERTING DATA INTO: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,           -- Skip header row
            FIELDTERMINATOR = ',',  -- Column delimiter in CSV
            ROWTERMINATOR = '0x0A', -- End-of-line marker (LF / new line)
            TABLOCK                 -- Table-level lock for faster bulk load
        );

        SET @rows_inserted = @@ROWCOUNT;   -- Rows inserted by previous BULK INSERT
        SET @table_end_time = GETDATE();   -- End time for this table load

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ===== bronze.crm_prd_info ===== */
        SET @table_start_time = GETDATE();

        PRINT '>>> TRUNCATING TABLE: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>>> INSERTING DATA INTO: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ===== bronze.crm_sales_details ===== */
        SET @table_start_time = GETDATE();

        PRINT '>>> TRUNCATING TABLE: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>>> INSERTING DATA INTO: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* =========================
           LOADING ERP TABLES
           ========================= */
        PRINT '------------------------';
        PRINT 'LOADING ERP TABLES';
        PRINT '------------------------';

        /* ===== bronze.erp_cust_az12 ===== */
        SET @table_start_time = GETDATE();

        PRINT '>>> TRUNCATING TABLE: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>>> INSERTING DATA INTO: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ===== bronze.erp_loc_a101 ===== */
        SET @table_start_time = GETDATE();

        PRINT '>>> TRUNCATING TABLE: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>>> INSERTING DATA INTO: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        /* ===== bronze.erp_px_cat_g1v2 ===== */
        SET @table_start_time = GETDATE();

        PRINT '>>> TRUNCATING TABLE: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>>> INSERTING DATA INTO: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @rows_inserted = @@ROWCOUNT;
        SET @table_end_time = GETDATE();

        PRINT 'Rows Inserted: ' + CAST(@rows_inserted AS VARCHAR(20));
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @table_start_time, @table_end_time) AS VARCHAR(20)) + ' seconds';
        PRINT '------------------------';

        -- End whole procedure timer
        SET @proc_end_time = GETDATE();

        PRINT '========================';
        PRINT 'BRONZE LOAD COMPLETED SUCCESSFULLY';
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
        PRINT 'ERROR OCCURRED DURING BRONZE LOAD';
        PRINT '------------------------';

        /*
           ERROR_NUMBER():
           Returns SQL Server error code.
        */
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(20));

        /*
           ERROR_MESSAGE():
           Returns full error message text.
        */
        PRINT 'Error Message : ' + ERROR_MESSAGE();

        /*
           ERROR_LINE():
           Returns line number where error occurred.
        */
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(20));

        PRINT 'Elapsed Before Failure: '
              + CAST(DATEDIFF(SECOND, @proc_start_time, @proc_end_time) AS VARCHAR(20))
              + ' seconds';

        /*
           THROW:
           Re-raises original error so caller/job can detect failure.
        */
        THROW;
    END CATCH
    /*
       END CATCH:
       Marks end of error-handling block.
    */
END;
GO
