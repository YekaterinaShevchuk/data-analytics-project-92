-- Запрос считает общее количество покупателей из таблицы customers
SELECT 
	COUNT(customer_id) AS customers_count
FROM customers

-- Запрос выводит информацию о 10 лучших продавцах, суммарной выручке с проданных товаров и количестве проведенных ими сделок
SELECT 	
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	COUNT(s.sales_id)	AS operations,
	fLOOR(SUM(p.price * s.quantity)) AS income
FROM employees e
INNER JOIN sales s
	ON e.employee_id = s.sales_person_id
INNER JOIN products p 
	ON s.product_id = p.product_id
GROUP BY seller 
ORDER BY income DESC 
LIMIT 10

-- Запрос выводит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
WITH seller_income AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        FLOOR(AVG(p.price * s.quantity)) AS average_income
    FROM employees e
    INNER JOIN sales s ON e.employee_id = s.sales_person_id
    INNER JOIN products p ON s.product_id = p.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT seller, average_income
FROM seller_income
WHERE average_income < (SELECT FLOOR(AVG(average_income)) FROM seller_income)
ORDER BY average_income;

-- Запрос выводит информацию о выручке по дням недели
SELECT 	
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
	fLOOR(SUM(p.price * s.quantity)) AS income
FROM employees e
INNER JOIN sales s
	ON e.employee_id = s.sales_person_id
INNER JOIN products p 
	ON s.product_id = p.product_id
GROUP BY day_of_week, seller
ORDER BY MIN(EXTRACT(ISODOW FROM s.sale_date)), seller

-- Количество покупателей в разных возрастных группах: 16-25, 26-40 и 40
SELECT
	(CASE 
		WHEN c.age <= 25 THEN '16-25'
		WHEN c.age > 25 AND c.age <= 40 THEN '26-40'
		WHEN c.age > 40 THEN '40+'
	END ) AS age_category,
	COUNT(*) AS age_count
FROM customers c
GROUP BY age_category
ORDER BY age_category

-- Данные по количеству уникальных покупателей и выручке, которую они принесли
SELECT 	
	TO_CHAR(DATE_TRUNC('month', s.sale_date), 'YYYY-MM') AS selling_month,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
INNER JOIN products p 
	ON p.product_id = s.product_id 
GROUP BY selling_month
ORDER BY selling_month

-- Данные о покупателях, первая покупка которых была в ходе проведения акций 
WITH customers_sellers AS (
SELECT 
	CONCAT(c.first_name, ' ', c.last_name) AS customer,
	s.sale_date,
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	p.price
FROM customers c 
INNER JOIN sales s 
	ON c.customer_id = s.customer_id 
INNER JOIN employees e 
	ON e.employee_id = s.sales_person_id
INNER JOIN products p 
	ON p.product_id = s.product_id
),
customers_sellers2 AS (
SELECT
	customer,
	sale_date,
	seller,
	price,
	ROW_NUMBER() OVER(PARTITION BY customer ORDER BY sale_date) AS rn
FROM customers_sellers
)
SELECT DISTINCT
	customer,
	sale_date,
	seller
FROM customers_sellers2
WHERE rn = 1 AND price = 0
ORDER BY customer






















