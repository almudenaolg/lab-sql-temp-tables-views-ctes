-- ===========================================================================================
-- Select the database
-- ===========================================================================================
USE sakila;

-- ===========================================================================================
-- 1: CREATE A VIEW
-- Create a view that summarizes rental information for each customer.
-- Include the customer's ID, name, email address, and total number of rentals (rental_count)
-- ===========================================================================================

CREATE VIEW rental_info AS
SELECT 
    r.customer_id, c.first_name, c.email, COUNT(*) AS rental_count
FROM rental AS r
JOIN customer AS c ON r.customer_id = c.customer_id
GROUP BY r.customer_id, c.first_name, c.email;

-- ===========================================================================================
-- 2: CREATE A TEMPORARY TABLE
-- Calculates the total amount paid by each customer (total_paid). 
-- Use the rental summary view created to join with the payment table and calculate the total amount paid by each customer.
-- ===========================================================================================

CREATE TEMPORARY TABLE total_paid AS
SELECT ri.customer_id, ri.first_name, ri.email, SUM(p.amount) AS total_paid
FROM rental_info AS ri
JOIN rental AS r ON ri.customer_id = r.customer_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY ri.customer_id, ri.first_name, ri.email;

-- ===========================================================================================
-- 3: CREATE A CTE AND THE CUSTOMER SUMMARY REPORT
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table
-- Using the CTE, create the query to generate the final customer summary report
-- Include: customer name, email, rental_count, total_paid and average_payment_per_rental
-- ===========================================================================================

WITH customer_summary AS (
    SELECT ri.customer_id, ri.first_name, ri.email, ri.rental_count, tp.total_paid
    FROM rental_info AS ri
    JOIN total_paid AS tp ON ri.customer_id = tp.customer_id)

SELECT 
    cs.customer_id, cs.first_name, cs.email, cs.rental_count, cs.total_paid,
    ROUND(cs.total_paid / cs.rental_count, 2) AS average_payment_per_rental
FROM customer_summary AS cs;