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



-- counts cutomers in age groups: 16-25, 26-40, 40+
SELECT
	CASE
		WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
		WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
		WHEN c.age > 40 THEN '40+'
	END AS age_category,
	COUNT(*) AS age_count
FROM customers c 
GROUP BY age_category 
ORDER BY age_category;



-- counts unique customers and revenue by months
SELECT
	to_char(s.sale_date, 'YYYY-MM') AS selling_month,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	floor(SUM(s.quantity * p.price)) AS income
FROM sales s 
LEFT JOIN products p 
	ON p.product_id = s.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;



-- CTE that returns purchases for every customer numerated by purchase date ASC
WITH numerated_purchases AS (
  SELECT 
    s.customer_id,
    s.sale_date AS sale_date,
    p.price AS price,
    s.sales_person_id,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id 
      ORDER BY s.sale_date ASC
    ) AS purchase_order
  FROM sales s
  LEFT JOIN products p 
    ON p.product_id = s.product_id
)
-- main query return info about purchases that were made for the 0 price
SELECT 
  (c.first_name || ' ' || c.last_name) AS customer,
  TO_CHAR(np.sale_date, 'YYYY-MM-DD') AS sale_date,
  (e.first_name || ' ' || e.last_name) AS seller
FROM numerated_purchases np
LEFT JOIN customers c 
  ON c.customer_id = np.customer_id
LEFT JOIN employees e 
  ON e.employee_id = np.sales_person_id
WHERE 
  np.purchase_order = 1
  AND np.price = 0
ORDER BY c.customer_id ASC;
