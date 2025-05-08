
# 🛍️ Retail Sales Analysis using SQL (PostgreSQL)

## 📌 Project Overview

This project explores a **retail sales dataset** using SQL in PostgreSQL to derive valuable business insights. It mimics real-world retail scenarios, answering questions like *Which products sell best? Who are the top customers? What times are busiest?* The dataset includes customer demographics, purchase details, and sales metrics across multiple product categories.
---

## 🎯 Objectives

- Perform **data cleaning and validation** to prepare the dataset for analysis.
- Use **SQL aggregation, window functions, CTEs, and case statements** to solve real business questions.
- Analyze **customer behavior, product performance, and time-based trends**.
- Practice **SQL storytelling** suitable for dashboards and client reporting.
---

## 📊 Dataset Summary

Assume the table is named `retail_sales` and has the following structure:

| Column            | Type        | Description                            |
|------------------|-------------|----------------------------------------|
| `transactions_id`| INT         | Unique transaction ID                  |
| `sale_date`      | DATE        | Date of transaction                    |
| `sale_time`      | TIME        | Time of transaction                    |
| `customer_id`    | INT         | Unique customer ID                     |
| `gender`         | VARCHAR     | Gender of customer                     |
| `age`            | INT         | Age of customer                        |
| `category`       | VARCHAR     | Product category                       |
| `quantity`       | INT         | Number of units sold                   |
| `price_per_unit` | FLOAT       | Unit price                             |
| `cogs`           | FLOAT       | Cost of goods sold                     |
| `total_sale`     | FLOAT       | Total revenue per transaction          |

---

## 🧱 Project Structure

The project is structured into sections:

1. [Data Cleaning](#1-data-cleaning)  
2. [Exploratory Data Analysis](#2-exploratory-data-analysis)  
3. [Business Insight Queries](#3-business-insight-queries)  
4. [Customer Analysis](#4-customer-analysis)  
5. [Product & Category Performance](#5-product--category-performance)  
6. [Time-based Trends](#6-time-based-trends)  
7. [Basket Analysis](#7-basket-analysis)  

---

## 1. 🧹 Data Cleaning

```sql
-- Check for NULL values
SELECT * FROM retail_sales
WHERE transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL
  OR customer_id IS NULL OR gender IS NULL OR age IS NULL
  OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL
  OR cogs IS NULL OR total_sale IS NULL;

-- Optional: remove NULLs
DELETE FROM retail_sales
WHERE transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL
  OR customer_id IS NULL OR gender IS NULL OR age IS NULL
  OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL
  OR cogs IS NULL OR total_sale IS NULL;
```

---

## 2. 📊 Exploratory Data Analysis

```sql
-- Q1: Total Sales Amount
SELECT SUM(total_sale) FROM retail_sales;

-- Q2: Unique Customers
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- Q3: Total Categories
SELECT COUNT(DISTINCT category) FROM retail_sales;

-- Q4: List of Product Categories
SELECT DISTINCT category FROM retail_sales;
```

---

## 3. 💼 Business Insight Queries

```sql
-- Q5: Sales on a Specific Day
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';

-- Q6: Clothing Sales with Quantity >= 4 in Nov 2022
SELECT * FROM retail_sales
WHERE category = 'Clothing' AND quantity >= 4
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Q7: Total Sales per Category
SELECT category, SUM(total_sale) AS net_sale, COUNT(*) AS orders
FROM retail_sales
GROUP BY category;

-- Q8: Avg Age of 'Beauty' Category Buyers
SELECT ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q9: High Value Transactions (Total > 1000)
SELECT * FROM retail_sales WHERE total_sale > 1000;

-- Q10: Transaction Count by Gender and Category
SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

---

## 4. 🧑‍🤝‍🧑 Customer Analysis

```sql
-- Q11: Top Customer(s) by Sales
SELECT customer_id, SUM(total_sale) AS total_sales,
       RANK() OVER (ORDER BY SUM(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY customer_id
LIMIT 5;

-- Q12: Customers Who Bought from > 2 Categories
SELECT customer_id, COUNT(DISTINCT category) AS purchase_count
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) > 2;

-- Q13: High Spending Customers (Avg Spend > 500)
SELECT customer_id, AVG(total_sale) AS average_spend_per_order
FROM retail_sales
GROUP BY customer_id
HAVING AVG(total_sale) > 500;

-- Q14: Avg Purchase by Gender
SELECT gender, AVG(total_sale) AS avg_purchase_amt
FROM retail_sales
GROUP BY gender;
```

---

## 5. 📦 Product & Category Performance

```sql
-- Q15: Category with Highest Avg Revenue
SELECT * FROM (
    SELECT category, AVG(total_sale) AS avg_revenue,
           RANK() OVER (ORDER BY AVG(total_sale) DESC) AS ranks
    FROM retail_sales
    GROUP BY category
) T1
WHERE ranks = 1;

-- Q16: Categories with Sales in Every Month
SELECT category
FROM retail_sales
GROUP BY category
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM sale_date)) = 12;
```

---

## 6. 🗓️ Time-based Trends

```sql
-- Q17: Busiest Month by Quantity
WITH T1 AS (
    SELECT TO_CHAR(sale_date, 'YYYY-MM') AS year_month,
           SUM(quantity) AS total_qty,
           RANK() OVER (ORDER BY SUM(quantity) DESC) AS ranks
    FROM retail_sales
    GROUP BY year_month
)
SELECT year_month FROM T1 WHERE ranks = 1;

-- Q18: Weekday vs Weekend Sales
SELECT 
    CASE WHEN EXTRACT(DOW FROM sale_date) BETWEEN 1 AND 5 THEN 'Weekday'
         ELSE 'Weekend'
    END AS day_type,
    ROUND(AVG(total_sale), 2) AS avg_sales
FROM retail_sales
GROUP BY day_type;

-- Q19: Most Popular Day of the Week
WITH T1 AS (
    SELECT TRIM(TO_CHAR(sale_date, 'Day')) AS day,
           COUNT(transactions_id) AS total_transactions,
           RANK() OVER (ORDER BY COUNT(transactions_id) DESC) AS ranks
    FROM retail_sales
    GROUP BY day
)
SELECT * FROM T1 WHERE ranks = 1;

-- Q20: Sales by Time Shift
WITH hourly_sales AS (
    SELECT *, CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) FROM hourly_sales GROUP BY shift;
```

---

## 7. 🧺 Basket Analysis

```sql
-- Q21: Common Category Combinations Bought Together
SELECT
    a.category AS category_1,
    b.category AS category_2,
    COUNT(*) AS pair_count
FROM retail_sales a
JOIN retail_sales b
  ON a.customer_id = b.customer_id
  AND a.sale_date = b.sale_date
  AND a.category < b.category
GROUP BY category_1, category_2
ORDER BY pair_count DESC;
```

---

## 🚀 Next Steps (Suggestions)

- Add **data visualizations** using Tableau, Power BI, or Matplotlib.
- Run **RFM (Recency, Frequency, Monetary)** analysis for customer segmentation.
- Predict customer lifetime value using machine learning.
- Build an **interactive dashboard** with Streamlit or Dash.
- Convert queries into **stored procedures** or **views** for production.
