# SQL Data Warehouse & ETL Project

## 👋 About Me

I'm **Abdul Manan**, a Computer Science student and aspiring **Data Engineer**.

I'm passionate about **SQL, ETL, Data Warehousing, and building reliable data pipelines**. I enjoy transforming raw data into clean, structured, and business-ready datasets.

Currently, I'm building real-world Data Engineering projects and strengthening my skills in **MySQL, Python, ETL pipelines, Data Warehousing, and Cloud technologies**.

---

## 🏗️ Project Architecture

```text
CSV Files
   ↓
Bronze Layer → Raw Data
   ↓
Silver Layer → Cleaned & Transformed Data
   ↓
Gold Layer → Business-Ready Data
```

## 🔧 Technologies

* MySQL 8
* SQL
* ETL / ELT
* Data Cleaning & Transformation
* Window Functions
* Stored Procedures
* Star Schema
* Git & GitHub

## 🚀 Key Work

* Loaded CRM & ERP CSV data into the **Bronze layer**
* Performed data profiling and quality checks
* Cleaned duplicates, NULLs and invalid values
* Used `ROW_NUMBER()` and `LEAD()` for transformations
* Standardized dates, prices and sales values
* Built cleaned **Silver-layer tables**
* Created **Gold-layer dimension and fact views**
* Implemented a **Star Schema**
* Automated Silver ETL using a **Stored Procedure**
* Performed data quality validation

## ⭐ Data Warehouse Model

```text
             dim_customers
                   │
                   │ customer_sk
                   ↓
               fact_sales
                   │
                   │ product_key
                   ↓
             dim_products
```

## 📊 Results

* **18,484** cleaned customers
* **397** products
* **60,398** sales records
* Customer & product surrogate keys
* Data quality validations completed

## 🎯 Purpose

This project demonstrates practical **Data Engineering fundamentals**, including data ingestion, ETL, data cleaning, transformation, dimensional modeling and data warehouse architecture.
