CREATE TABLE IF NOT EXISTS retail_sales
                           (
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
                           );
SELECT * FROM retail_sales;

--DATA CLEANING
--CHECKING FOR NULL VALUES

SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id is NULL
    OR
    gender is NULL
    OR
    age is NULL
    OR
    category is NULL
    OR
    quantity is NULL
    OR
    price_per_unit is NULL
    OR
    cogs is NULL
    OR
    total_sale is NULL
    ;

--DELETE NULL VALUES
DELETE FROM retail_sales
WHERE
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id is NULL
    OR
    gender is NULL
    OR
    age is NULL
    OR
    category is NULL
    OR
    quantity is NULL
    OR
    price_per_unit is NULL
    OR
    cogs is NULL
    OR
    total_sale is NULL
    ;


--DATA EXPLORATION
SELECT * FROM retail_sales;

-- 1. Total sales amount
SELECT SUM(total_sale) FROM retail_sales;


-- 2, Number of unique customers

SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

--3, Total categories

SELECT COUNT(DISTINCT category) FROM retail_sales;

--4, Categories

SELECT DISTINCT category FROM retail_sales;


--DATA ANALYSIS & KEY BUSINESS PROBLEMS AND SOLUTIONS


--1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

--2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022: 

SELECT *
FROM retail_sales
WHERE
    category = 'Clothing'
AND
    quantity >= 4
AND
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' ;

--3. Write a SQL query to calculate the total sales (total_sale) for each category.:

SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS orders
FROM retail_sales
GROUP BY 1;

--4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT * FROM retail_sales;

SELECT
    ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';

--5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT * FROM retail_sales;

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

--6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT * FROM retail_sales;

    SELECT 
        category,
        gender,
        COUNT(transactions_id) AS total_transactions
    FROM retail_sales
    GROUP BY
        category,
        gender
    ORDER BY
        1;

--7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT * FROM retail_sales;

SELECT * FROM
    (SELECT
        EXTRACT(YEAR FROM sale_date) as year,
        EXTRACT(MONTH FROM sale_date) as month,
        AVG(total_sale) AS Average_Sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY 1, 2) AS T1
WHERE rank = 1;

--8 Write a SQL query to find the top 5 customers based on the highest total sales      
SELECT * FROM retail_sales;

SELECT 
    customer_id,
    SUM(total_sale) AS Total_Sales,
    RANK() OVER(ORDER BY SUM(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; 

--9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT * FROM retail_sales;

SELECT
    category,
    COUNT(DISTINCT customer_id) AS no_of_customers
FROM retail_sales
GROUP BY 1;

--10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
 
WITH hourly_sales 
  AS 
    (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift 
    FROM retail_sales  
    ) 

SELECT
    shift,
    COUNT(*)
FROM hourly_sales
GROUP BY shift;

--Customer Behavior & Segmentation

--1. Which customers made purchases in more than 2 different categories?

SELECT 
    customer_id, COUNT(DISTINCT category) AS purchase_count
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) > 2;

--2. Customers with average spending per order > 500

SELECT 
    customer_id, AVG(total_sale) AS average_spend_per_order
FROM retail_sales
GROUP BY customer_id
HAVING AVG(total_sale) > 500;


--3. Gender-wise average purchase amount
SELECT * FROM retail_sales;

SELECT
    gender, AVG(total_sale) AS avg_purchase_amt
FROM retail_sales
GROUP BY gender;

--📦 Product & Category Performance

--4. Category with highest average revenue per transaction

WITH T1
AS
    (
        SELECT
            category, AVG(total_sale) AS average_rev_per_transaction,
            RANK() OVER(ORDER BY AVG(total_sale) DESC) AS ranks
        FROM retail_sales
        GROUP BY Category
    )

SELECT *
FROM T1
WHERE ranks = 1;

--5. Categories with sales every month

SELECT category
FROM retail_sales
GROUP BY category
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM sale_date)) = 12;

--📅 Time-Based Analysis

--6. Month with highest total quantity sold

WITH T1 AS
    (
        SELECT
            TO_CHAR(sale_date, 'YYYY-MM') AS year_month,
            SUM(quantity) AS total_qty,
            RANK() OVER(ORDER BY SUM(quantity) DESC) AS ranks
        FROM retail_sales
        GROUP BY year_month
    )
SELECT year_month
FROM T1
WHERE ranks = 1;

--7 Weekday vs Weekend average sales

SELECT 
    CASE
        WHEN EXTRACT(DOW FROM sale_date) BETWEEN 1 AND 5 THEN 'weekday'
        ELSE
            'weekend'
    END AS day_type,
    ROUND(AVG(total_sale)::numeric, 2) AS avg_sales
FROM retail_sales
GROUP BY day_type;

--8 Most popular day of the week

WITH T1 AS
    (
        SELECT 
            TRIM(TO_CHAR(sale_date, 'Day')) AS day,
            COUNT(transactions_id) AS total_transactions,
            RANK() OVER(ORDER BY COUNT(transactions_id) DESC) AS ranks
        FROM retail_sales
        GROUP BY day
    )
SELECT * FROM T1 WHERE ranks = 1;

--🛍️ Basket Analysis

--Common category combinations bought by same customer on same day

SELECT * FROM retail_sales;

SELECT
    a.category AS category_1,
    b.category AS category_2,
    COUNT(*) AS pair_count
FROM retail_sales a
JOIN retail_sales b
    ON a.customer_id = b.customer_id
    AND a.sale_date = b.sale_date
    AND a.category < b.category  -- avoid self-pairs and duplicates
GROUP BY category_1, category_2
ORDER BY pair_count DESC;

 --end of project