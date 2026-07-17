# Naming Conventions 

This repo follows a clear naming style across Bronze, Silver, and Gold layers.

---

## General Rules
- Use **snake_case** (lowercase + underscores).
- Names are always in **English**.
- Avoid SQL reserved words.

---

## Bronze Layer
- Tables keep the **original source system name + entity**.
- Pattern: `<source>_<entity>`
- Example: `crm_cust_info`, `erp_loc_a101`

---

## Silver Layer
- Same pattern as Bronze: `<source>_<entity>`
- Tables here are **cleaned versions** of Bronze data.
- Example: `silver.crm_cust_info`, `silver.erp_px_cat_g1v2`

---

## Gold Layer
- Tables/views use **business‑friendly names** with prefixes:
  - `dim_` → Dimension tables
  - `fact_` → Fact tables
- Pattern: `<category>_<entity>`
- Examples:
  - `dim_customers` → Customer dimension
  - `dim_products` → Product dimension
  - `fact_sales` → Sales fact table

---

## Columns
- **Surrogate keys**: always end with `_key`  
  Example: `customer_key`, `product_key`
- **Business IDs**: keep original names (`cst_id`, `prd_id`)
- **Technical columns**: start with `dwh_`  
  Example: `dwh_load_date`

---

## Procedures
- ETL stored procedures follow: `load_<layer>`  
  Examples: `load_bronze`, `load_silver`, `load_gold`

---

