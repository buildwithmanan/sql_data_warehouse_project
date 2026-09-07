
/*
===============================================================================
Stored Procedure: Load Bronze Layer
===============================================================================
Purpose:
    Load raw CSV data into the Bronze layer.

    Steps:
    1. Truncate existing Bronze tables.
    2. Load CSV files using LOAD DATA INFILE.
    3. Show loading progress and duration.
===============================================================================
*/

DELIMITER $$

CREATE PROCEDURE bronze.load_bronze()
BEGIN

    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;

    SET batch_start_time = NOW();

    SELECT '========================================' AS message;
    SELECT 'Loading Bronze Layer' AS message;
    SELECT '========================================' AS message;


    /* =========================
       CRM TABLES
       ========================= */

    SELECT 'Loading CRM Tables...' AS message;


    /* CRM CUSTOMER */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.crm_cust_info;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
    INTO TABLE bronze.crm_cust_info
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET end_time = NOW();

    SELECT CONCAT(
        'crm_cust_info loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* CRM PRODUCT */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.crm_prd_info;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
    INTO TABLE bronze.crm_prd_info
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET end_time = NOW();

    SELECT CONCAT(
        'crm_prd_info loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* CRM SALES */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.crm_sales_details;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
    INTO TABLE bronze.crm_sales_details
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (
        @ord_num,
        @prd_key,
        @cust_id,
        @order_dt,
        @ship_dt,
        @due_dt,
        @sales,
        @qty,
        @price
    )
    SET
        sls_ord_num  = NULLIF(TRIM(@ord_num), ''),
        sls_prd_key  = NULLIF(TRIM(@prd_key), ''),
        sls_cust_id  = NULLIF(TRIM(@cust_id), ''),
        sls_order_dt = NULLIF(TRIM(@order_dt), ''),
        sls_ship_dt  = NULLIF(TRIM(@ship_dt), ''),
        sls_due_dt   = NULLIF(TRIM(@due_dt), ''),
        sls_sales    = NULLIF(TRIM(@sales), ''),
        sls_quantity = NULLIF(TRIM(@qty), ''),
        sls_price    = NULLIF(TRIM(@price), '');

    SET end_time = NOW();

    SELECT CONCAT(
        'crm_sales_details loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* =========================
       ERP TABLES
       ========================= */

    SELECT 'Loading ERP Tables...' AS message;


    /* ERP LOCATION */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.erp_loc_a101;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loc_a101.csv'
    INTO TABLE bronze.erp_loc_a101
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET end_time = NOW();

    SELECT CONCAT(
        'erp_loc_a101 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ERP CUSTOMER */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.erp_cust_az12;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_az12.csv'
    INTO TABLE bronze.erp_cust_az12
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET end_time = NOW();

    SELECT CONCAT(
        'erp_cust_az12 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ERP PRODUCT CATEGORY */

    SET start_time = NOW();

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/px_cat_g1v2.csv'
    INTO TABLE bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET end_time = NOW();

    SELECT CONCAT(
        'erp_px_cat_g1v2 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* =========================
       COMPLETION
       ========================= */

    SET batch_end_time = NOW();

    SELECT '========================================' AS message;
    SELECT 'Bronze Layer Loading Completed' AS message;

    SELECT CONCAT(
        'Total Load Duration: ',
        TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time),
        ' seconds'
    ) AS message;

    SELECT '========================================' AS message;

END$$

DELIMITER ;
