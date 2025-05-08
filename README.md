# 🛒 Retail Sales Data Analysis Project

## 📌 Project Overview

This project explores a synthetic retail sales dataset using SQL. It involves data cleaning, exploration, and comprehensive analysis to derive insights on customer behavior, product performance, and temporal sales trends. The SQL queries are written and executed in PostgreSQL.

## 🎯 Objectives

* Clean and validate the dataset.
* Explore and understand the data.
* Solve common business questions using SQL.

## 🗃️ Dataset Schema

```
transactions_id INT PRIMARY KEY,
sale_date DATE,
sale_time TIME,
customer_id INT,
gender VARCHAR(10),
age INT,
category VARCHAR(20),
quantity INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sale FLOAT
```

---

## 🧼 1. Data Cleaning

### 🔍 Check for NULLs

```sql
SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

### 🧹 Delete NULLs

```sql
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

## 🔎 2. Data Exploration

### 🛍️ View all records

```sql
SELECT * FROM retail_sales;
```

### 💰 Total sales amount

```sql
SELECT SUM(total_sale) FROM retail_sales;
```

### 👥 Number of unique customers

```sql
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
```

### 📦 Total categories

```sql
SELECT COUNT(DISTINCT category) FROM retail_sales;
```

### 📋 List of categories

```sql
SELECT DISTINCT category FROM retail_sales;
```

## 📊 3. Data Analysis & Business Questions

### Q1. Sales on 2022-11-05

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

### Q2. Clothing transactions with quantity >= 4 in Nov 2022

```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
AND quantity >= 4
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
```

### Q3. Total sales and order count per category

```sql
SELECT category, SUM(total_sale) AS net_sale, COUNT(*) AS orders
FROM retail_sales
GROUP BY category;
```

### Q4. Average age of customers who purchased from 'Beauty'

```sql
SELECT ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';
```

### Q5. Transactions with total\_sale > 1000

```sql
SELECT * FROM retail_sales WHERE total_sale > 1000;
```

### Q6. Transaction count by gender per category

```sql
SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### Q7. Best selling month (avg sale) in each year

```sql
SELECT * FROM (
  SELECT EXTRACT(YEAR FROM sale_date) as year,
         EXTRACT(MONTH FROM sale_date) as month,
         AVG(total_sale) AS Average_Sale,
         RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
  FROM retail_sales
  GROUP BY 1, 2
) AS T1
WHERE rank = 1;
```

### Q8. Top 5 customers by total sales

```sql
SELECT customer_id, SUM(total_sale) AS Total_Sales,
       RANK() OVER(ORDER BY SUM(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY customer_id
ORDER BY Total_Sales DESC
LIMIT 5;
```

### Q9. Number of unique customers per category

```sql
SELECT category, COUNT(DISTINCT customer_id) AS no_of_customers
FROM retail_sales
GROUP BY category;
```

### Q10. Shift-wise order count

```sql
WITH hourly_sales AS (
  SELECT *,
         CASE
           WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
           WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
         END AS shift
  FROM retail_sales
)
SELECT shift, COUNT(*)
FROM hourly_sales
GROUP BY shift;
```

## 👤 4. Customer Behavior

### Q11. Customers with purchases in more than 2 categories

```sql
SELECT customer_id, COUNT(DISTINCT category) AS purchase_count
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) > 2;
```

### Q12. Customers with average spend > ₹500

```sql
SELECT customer_id, AVG(total_sale) AS average_spend_per_order
FROM retail_sales
GROUP BY customer_id
HAVING AVG(total_sale) > 500;
```

### Q13. Gender-wise average purchase amount

```sql
SELECT gender, AVG(total_sale) AS avg_purchase_amt
FROM retail_sales
GROUP BY gender;
```

## 📦 5. Product & Category Performance

### Q14. Category with highest avg revenue per transaction

```sql
WITH T1 AS (
  SELECT category, AVG(total_sale) AS average_rev_per_transaction,
         RANK() OVER(ORDER BY AVG(total_sale) DESC) AS ranks
  FROM retail_sales
  GROUP BY category
)
SELECT * FROM T1 WHERE ranks = 1;
```

### Q15. Categories with sales every month

```sql
SELECT category
FROM retail_sales
GROUP BY category
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM sale_date)) = 12;
```

## 📅 6. Time-Based Analysis

### Q16. Month with highest quantity sold

```sql
WITH T1 AS (
  SELECT TO_CHAR(sale_date, 'YYYY-MM') AS year_month,
         SUM(quantity) AS total_qty,
         RANK() OVER(ORDER BY SUM(quantity) DESC) AS ranks
  FROM retail_sales
  GROUP BY year_month
)
SELECT year_month FROM T1 WHERE ranks = 1;
```

### Q17. Weekday vs Weekend average sales

```sql
SELECT CASE
         WHEN EXTRACT(DOW FROM sale_date) BETWEEN 1 AND 5 THEN 'weekday'
         ELSE 'weekend'
       END AS day_type,
       ROUND(AVG(total_sale)::numeric, 2) AS avg_sales
FROM retail_sales
GROUP BY day_type;
```

### Q18. Most popular day of the week

```sql
WITH T1 AS (
  SELECT TRIM(TO_CHAR(sale_date, 'Day')) AS day,
         COUNT(transactions_id) AS total_transactions,
         RANK() OVER(ORDER BY COUNT(transactions_id) DESC) AS ranks
  FROM retail_sales
  GROUP BY day
)
SELECT * FROM T1 WHERE ranks = 1;
```

## 🛍️ 7. Basket Analysis

### Q19. Common category combinations bought on same day by same customer

```sql
SELECT a.category AS category_1,
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


## 👨‍💻 Author

**Yashwanth Ramesh**


---

🔚 **Thanks for reading!** If you liked this project, feel free to ⭐️ the repo and connect with me on [LinkedIn](https://www.linkedin.com/in/yashwanth-s-r/)!
