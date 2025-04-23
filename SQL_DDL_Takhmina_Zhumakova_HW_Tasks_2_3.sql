---Task 2. Implement role-based authentication model for dvd_rental database

---Create a new user with the username "rentaluser" and the password "rentalpassword". Give the user the ability to connect to the database but no other permissions.

CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser; 


---Grant "rentaluser" SELECT permission for the "customer" table. Сheck to make sure this permission works correctly—write a SQL query to select all customers.

GRANT SELECT ON table customer TO rentaluser;
SELECT * FROM customer;
--Create a new user group called "rental" and add "rentaluser" to the group. 

CREATE ROLE rental;
GRANT rental TO rentaluser;
SELECT rolname 
FROM pg_roles 
WHERE pg_has_role('rentaluser', oid, 'member');

---Grant the "rental" group INSERT and UPDATE permissions for the "rental" table. Insert a new row and update one existing row in the "rental" table under that role. 

GRANT INSERT, UPDATE ON TABLE rental TO rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (CURRENT_TIMESTAMP, 1, 1, NULL, 1);

UPDATE rental
SET return_date = CURRENT_TIMESTAMP

---Revoke the "rental" group's INSERT permission for the "rental" table. Try to insert new rows into the "rental" table make sure this action is denied.

REVOKE INSERT ON rental FROM rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (CURRENT_TIMESTAMP, 1, 1, NULL, 1);

--Create a personalized role for any customer already existing in the dvd_rental database. The name of the role name must be client_{first_name}_{last_name} (omit curly brackets). The customer's payment and rental history must not be empty. 

SELECT c.first_name, c.last_name, c.customer_id
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM payment p WHERE p.customer_id = c.customer_id
)
AND EXISTS (
    SELECT 1 FROM rental r WHERE r.customer_id = c.customer_id
)
LIMIT 1;

CREATE ROLE client_Patricia_Johnson;
CREATE ROLE client_Patricia_Johnson LOGIN PASSWORD 'someStrongPassword';


--Task 3. Implement row-level security
Read about row-level security (https://www.postgresql.org/docs/12/ddl-rowsecurity.html) 
Configure that role so that the customer can only access their own data in the "rental" and "payment" tables. Write a query to make sure this user sees only their own data.

GRANT CONNECT ON DATABASE dvdrental TO client_Patricia_Johnson;
GRANT USAGE ON SCHEMA public TO client_Patricia_Johnson;
GRANT SELECT ON rental, payment TO client_Patricia_Johnson;


ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

-- RENTAL table policy
CREATE POLICY rental_customer_policy ON rental
FOR SELECT TO client_Patricia_Johnson
USING (customer_id = 2); 

-- PAYMENT table policy
CREATE POLICY payment_customer_policy ON payment
FOR SELECT TO client_Patricia_Johnson
USING (customer_id = 2);

SET ROLE client_Patricia_Johnson;


SELECT * FROM rental;
SELECT * FROM payment;

RESET ROLE;





