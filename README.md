# Retail Sales Data Analysis (Excel + SQL Project)

## Project Overview
This project focuses on analyzing a retail sales dataset using Excel and SQL Server. The goal is to clean and validate the data, design a structured database, and perform business analysis using SQL queries to generate meaningful insights.

The project demonstrates a complete data workflow including data preparation, database design, and business analysis.

---

## Tools & Technologies
- Microsoft Excel (Data Cleaning & Preprocessing)
- SQL Server (Database Design & Analysis)

---

## Dataset Description
The dataset is based on a public retail dataset and contains multiple tables such as:
- Sales
- Products
- Product Category
- Product Subcategory
- Stores
- Geography
- Calendar

### Data Size:
- Raw dataset: ~90,000 rows  
- Cleaned dataset: ~20,000 rows (after validation and preprocessing)

---

## Data Cleaning (Excel)
The following cleaning steps were performed:
- Corrected data types
- Removed duplicate records
- Handled missing values
- Standardized column formats

---

## SQL Database Design
A relational database was created with proper structure and relationships:

- Primary Keys defined for all tables
- Foreign Keys established between related tables
- Data integrity checks applied
- Duplicate and data validation checks performed

---

## Overall Business Performance
- What is the overall profit margin of the business?
- How is the overall profitability of the business performing?
- How does profit vary by year and month?
- What is the quarterly profit trend over time?
- How does profit trend across years and quarters?
- What are the total revenue and total profit for each year, and what is the year-over-year percentage change in revenue and profit?

---

## Product-Level Analysis
- How do profit and margin vary by product class?
- How do profit and margin vary by product category across months?
- Which product categories perform best and worst?
- What are the top 10 products by profit margin?
- How does profit margin vary by product category each year?

---

## Geography-Based Profit Analysis
- Which are the top 3 countries with the highest profit in each continent?
- Which product subcategory generates the most profit in each continent?

Techniques used:
## ⚙️ Techniques Used
- JOIN operations  
- GROUP BY aggregations  
- Ranking functions  
- Filtering and conditional logic  
- Window functions  
- Common Table Expressions (CTEs)  
- Views  
- Subqueries (if applicable)  
- CASE WHEN logic for conditional analysis  
- NULL handling and data validation    
- Advanced SQL analytical functions and business logic  

---

## Project Structure
Retail-SQL-Analytics-Project/
│
├── data/
│   └── cleaned_dataset.xlsx
│
├── sql/
│   ├── schema_and_data_validation.sql
│   └── business_analysis_queries.sql
│
└── README.md

---

## Author
Ayesha Batool
