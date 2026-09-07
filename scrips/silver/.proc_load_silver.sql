/*
===============================================================================
Stored Procedure: Load Silver Layer
===============================================================================
Purpose:
    Load cleaned and transformed data from Bronze into Silver.

    Flow:
        Bronze
           ↓
        Cleaning
           ↓
        Transformation
           ↓
        Silver
===============================================================================
*/

USE silver;

DROP PROCEDURE IF EXISTS silver.load_silver;

DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN

    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time   DATETIME;
    DECLARE start_time       DATETIME;
    DECLARE end_time         DATETIME;


    SET batch_start_time = NOW();


    SELECT '========================================' AS message;
    SELECT 'Loading Silver Layer' AS message;
    SELECT '========================================' AS message;


    /* ========================================================================
       CRM TABLES
       ======================================================================== */

    SELECT 'Loading CRM Tables...' AS message;


    /* ------------------------------------------------------------------------
       CRM CUSTOMER
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info
    (
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
        TRIM(cst_key),
        NULLIF(TRIM(cst_firstname), ''),
        NULLIF(TRIM(cst_lastname), ''),

        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S'
                THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M'
                THEN 'Married'
            ELSE 'n/a'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F'
                THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M'
                THEN 'Male'
            ELSE 'n/a'
        END,

        cst_create_date

    FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last

        FROM bronze.crm_cust_info

        WHERE cst_id IS NOT NULL

    ) AS t

    WHERE flag_last = 1;


    SET end_time = NOW();

    SELECT CONCAT(
        'crm_cust_info loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ------------------------------------------------------------------------
       CRM PRODUCT
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info
    (
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

        REPLACE(
            SUBSTRING(prd_key, 1, 5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTRING(prd_key, 7) AS prd_key,

        TRIM(prd_nm),

        COALESCE(prd_cost, 0),

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M'
                THEN 'Mountain'

            WHEN UPPER(TRIM(prd_line)) = 'R'
                THEN 'Road'

            WHEN UPPER(TRIM(prd_line)) = 'S'
                THEN 'Other Sales'

            WHEN UPPER(TRIM(prd_line)) = 'T'
                THEN 'Touring'

            ELSE 'n/a'
        END AS prd_line,

        DATE(prd_start_dt),

        DATE_SUB(
            LEAD(prd_start_dt) OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ),
            INTERVAL 1 DAY
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;


    SET end_time = NOW();

    SELECT CONCAT(
        'crm_prd_info loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ------------------------------------------------------------------------
       CRM SALES
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details
    (
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


        /* Order Date */

        CASE
            WHEN sls_order_dt = 0 THEN NULL

            WHEN sls_order_dt BETWEEN 19000101 AND 20991231
                THEN STR_TO_DATE(
                    CAST(sls_order_dt AS CHAR),
                    '%Y%m%d'
                )

            ELSE NULL
        END,


        /* Ship Date */

        CASE
            WHEN sls_ship_dt = 0 THEN NULL

            WHEN sls_ship_dt BETWEEN 19000101 AND 20991231
                THEN STR_TO_DATE(
                    CAST(sls_ship_dt AS CHAR),
                    '%Y%m%d'
                )

            ELSE NULL
        END,


        /* Due Date */

        CASE
            WHEN sls_due_dt = 0 THEN NULL

            WHEN sls_due_dt BETWEEN 19000101 AND 20991231
                THEN STR_TO_DATE(
                    CAST(sls_due_dt AS CHAR),
                    '%Y%m%d'
                )

            ELSE NULL
        END,


        /* Sales */

        CASE

            WHEN sls_sales IS NULL
                 OR sls_sales <= 0

                THEN sls_quantity *
                     CASE
                         WHEN sls_price < 0
                             THEN ABS(sls_price)
                         ELSE sls_price
                     END

            ELSE sls_sales

        END,


        sls_quantity,


        /* Price */

        CASE

            WHEN sls_price IS NULL
                THEN sls_sales /
                     NULLIF(sls_quantity, 0)

            WHEN sls_price < 0
                THEN ABS(sls_price)

            ELSE sls_price

        END


    FROM bronze.crm_sales_details;


    SET end_time = NOW();

    SELECT CONCAT(
        'crm_sales_details loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ========================================================================
       ERP TABLES
       ======================================================================== */

    SELECT 'Loading ERP Tables...' AS message;


    /* ------------------------------------------------------------------------
       ERP CUSTOMER
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )

    SELECT

        CASE
            WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4)
            ELSE cid
        END,

        CASE
            WHEN bdate > CURDATE()
                THEN NULL
            ELSE bdate
        END,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'

            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'

            ELSE 'n/a'
        END

    FROM bronze.erp_cust_az12;


    SET end_time = NOW();

    SELECT CONCAT(
        'erp_cust_az12 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ------------------------------------------------------------------------
       ERP LOCATION
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )

    SELECT

        REPLACE(cid, '-', ''),

        CASE

            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'

            WHEN TRIM(cntry) IN ('US', 'USA')
                THEN 'United States'

            WHEN TRIM(cntry) = ''
                 OR cntry IS NULL
                THEN 'n/a'

            ELSE TRIM(cntry)

        END

    FROM bronze.erp_loc_a101;


    SET end_time = NOW();

    SELECT CONCAT(
        'erp_loc_a101 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ------------------------------------------------------------------------
       ERP PRODUCT CATEGORY
       ------------------------------------------------------------------------ */

    SET start_time = NOW();

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2
    (
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


    SET end_time = NOW();

    SELECT CONCAT(
        'erp_px_cat_g1v2 loaded in ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    /* ========================================================================
       COMPLETION
       ======================================================================== */

    SET batch_end_time = NOW();

    SELECT '========================================' AS message;

    SELECT 'Silver Layer Loading Completed' AS message;

    SELECT CONCAT(
        'Total Load Duration: ',
        TIMESTAMPDIFF(
            SECOND,
            batch_start_time,
            batch_end_time
        ),
        ' seconds'
    ) AS message;

    SELECT '========================================' AS message;


END$$

DELIMITER ;
