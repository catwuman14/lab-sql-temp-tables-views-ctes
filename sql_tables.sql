USE sakila;

-- Create a view for rental information
CREATE VIEW rental_info AS 
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    COUNT(r.rental_id) AS rentals
FROM customer c
INNER JOIN rental r ON r.customer_id = c.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Create a temporary table for total payments per customer
CREATE TEMPORARY TABLE tapc AS
SELECT 
    ri.customer_id, 
    SUM(p.amount) AS total
FROM rental_info ri
INNER JOIN payment p ON ri.customer_id = p.customer_id
GROUP BY ri.customer_id;

-- Verify the temporary table
SELECT * FROM tapc;

-- Create the customer summary report using a CTE
WITH customer_summary_report AS (
    SELECT 
        ri.customer_id, 
        ri.first_name,
        ri.last_name, 
        ri.email, 
        ri.rentals AS rental_count, 
        tapc.total AS total_paid
    FROM rental_info ri
    INNER JOIN tapc ON ri.customer_id = tapc.customer_id  
)
SELECT 
    customer_id, 
    first_name, 
    last_name, 
    email, 
    rental_count, 
    total_paid,
    ROUND(CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count 
        ELSE 0 
    END, 2) AS average_payment_per_rental
FROM customer_summary_report;
