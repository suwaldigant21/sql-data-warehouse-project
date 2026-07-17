# Data Warehouse & Analytics Project

Welcome to the **Data Warehouse & Analytics Project** 🚀  
This repo showcases a full data warehousing workflow from raw data ingestion to clean, business‑ready analytics.

---

## 🏗️ Architecture

We follow the **Medallion Architecture** pattern with three layers:

1. **Bronze Layer**  
   - Raw data straight from source systems (CSV files).   

2. **Silver Layer**  
   - Cleaned and standardized data.  
   - Includes trimming, normalization, and fixing invalid values.  

3. **Gold Layer**  
   - Business‑ready data modeled into a **star schema**.  
   - Dimension tables (`dim_customers`, `dim_products`) and fact tables (`fact_sales`) for analytics.  

 ## 📊 Architecture diagram 
<img width="1326" height="784" alt="data_architecture" src="https://github.com/user-attachments/assets/ec17917c-ea0b-4497-982e-39ed3aa3f813" />

---

## 📂 Dataset

- The dataset used in this project is included in the repo under the [`dataset`](./dataset) folder.  
- Source systems : **CRM** and **ERP**.  
- Data is ingested from CSV files into SQL Server Express using SQL Server Management Studio (SSMS).

---

## ⚙️ Tools Used

- **SQL Server Express** → database engine.  
- **SQL Server Management Studio (SSMS)** → development and management.  
- **Git & GitHub** → version control and collaboration.  
- **draw.io** → diagrams and architecture visuals.  

---

## 📖 Project Highlights

1. **ETL Pipelines**  
   - Scripts to load Bronze → Silver → Gold layers.  
   - Includes cleansing, normalization, and surrogate key generation.

2. **Data Modeling**  
   - Dimension tables (`dim_customers`, `dim_products`).  
   - Fact table (`fact_sales`).  
   - Surrogate keys (`*_key`) for star schema joins.

3. **Analytics & Reporting**  
   - SQL queries for foreign key integrity checks.  
   - Example reports: sales by product, sales by customer, missing dimension links.

---

### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.



### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

## License🛡️

This project is licensed under the 🛡️[MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.


