-- counts number of customers from table customers
SELECT COUNT(customers) AS customers_count FROM customers;


-- joins tables sales, products and employees, counts number of sales and sum of revenue, grouping them by sellers, and shows top-10 sellers with highest revenue
SELECT
	(e.first_name || ' ' || e.last_name) AS seller,
	COUNT(s.sales_id) AS operations,
	FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
LEFT JOIN products p
	ON p.product_id = s.product_id
LEFT JOIN employees e 
	ON s.sales_person_id = e.employee_id
GROUP BY (e.first_name || ' ' || e.last_name)
ORDER BY income DESC
LIMIT 10;



-- finds sellers with average revenue per sale smaller than global average revenue per sale
SELECT
	(e.first_name || ' ' || e.last_name) AS seller,
	FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales s
LEFT JOIN products p
	ON p.product_id = s.product_id
LEFT JOIN employees e 
	ON s.sales_person_id = e.employee_id
GROUP BY (e.first_name || ' ' || e.last_name)
-- filtering grouped results by comparing to global average revenue per sale using subquery
HAVING AVG(s.quantity * p.price) < (SELECT AVG(sal.quantity * prod.price) FROM sales sal LEFT JOIN products prod ON prod.product_id = sal.product_id)
ORDER BY average_income  ASC;



-- aggregates revenue by days of week and sellers
SELECT
	(e.first_name || ' ' || e.last_name) AS seller,
	-- extracts day of week name from data, deletes spaces, makes lower-case
	LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
	FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
LEFT JOIN products p
	ON p.product_id = s.product_id
LEFT JOIN employees e 
	ON s.sales_person_id = e.employee_id
GROUP BY 
	(e.first_name || ' ' || e.last_name),
	EXTRACT(ISODOW FROM s.sale_date),
	day_of_week
ORDER BY 
	EXTRACT(ISODOW FROM s.sale_date) ASC,
	seller ASC;

