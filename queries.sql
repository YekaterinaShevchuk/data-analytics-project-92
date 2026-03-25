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
	TO_CHAR(s.sale_date, 'Day') AS day_of_week,
	fLOOR(SUM(p.price * s.quantity)) AS income
FROM employees e
INNER JOIN sales s
	ON e.employee_id = s.sales_person_id
INNER JOIN products p 
	ON s.product_id = p.product_id
GROUP BY day_of_week, seller
ORDER BY MIN(EXTRACT(ISODOW FROM s.sale_date)), seller