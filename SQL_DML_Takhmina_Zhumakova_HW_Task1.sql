--Task 1
--Choose your top-3 favorite movies and add them to the 'film' table (films with the title Film1, Film2, etc - will not be taken into account and grade will be reduced)
--Fill in rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively.

INSERT INTO film (film_id, title, description, release_year, language_id, original_language_id,
    rental_duration, rental_rate, length, replacement_cost, rating,
    last_update, special_features, fulltext)
values (1001, 'Kurmanjan Datka', 'A historical drama about the fate and bravery of a Kyrgyz national heroine.', 2014, 1, NULL,
 1, 4.99, 135, 14.99, 'PG',
 CURRENT_TIMESTAMP, '{Behind the Scenes,Trailers}', 'Kurmanjan Datka Kyrgyz heroine history'),
(1002, 'Sayakbay', 'A biographical film about the famous Kyrgyz Manas narrator Sayakbay Karalaev.', 2018, 1, NULL,
 2, 9.99, 120, 12.99, 'G',
 CURRENT_TIMESTAMP, '{Trailers}', 'Sayakbay Karalaev Manas Kyrgyz culture'),
(1003, 'Er Toshtuk', 'A fantasy film based on a legendary Kyrgyz epic.', 2022, 1, NULL,
 3, 19.99, 90, 9.99, 'PG', CURRENT_TIMESTAMP, '{Commentary}', 'Er Töshtük epic Kyrgyz legend hero');


--Add the actors who play leading roles in your favorite movies to the 'actor' and 'film_actor' tables (6 or more actors in total).  Actors with the name Actor1, Actor2, etc - will not be taken into account and grade will be reduced.
INSERT INTO actor (actor_id, first_name, last_name, last_update)
VALUES
(201, 'Nazira', 'Raiymbekova', '2010-06-15'),
(202, 'Asanbek', 'Urmanov', '2010-10-02'),
(203, 'Alyshbek', 'Alykulov', '2010-03-28'),
(204, 'Ermek', 'Tursunov', '2011-11-22'),
(205, 'Tashpolat', 'Tursunov', '2015-08-13'),
(206, 'Samat', 'Kadyrov', '2019-04-05');

INSERT INTO film_actor ( actor_id, film_id, last_update)
VALUES
(201, 1001, CURRENT_TIMESTAMP),  
(202, 1003, CURRENT_TIMESTAMP),
(204, 1002, CURRENT_TIMESTAMP),
(205, 1001, CURRENT_TIMESTAMP),
(203, 1003, CURRENT_TIMESTAMP),
(206, 1002, CURRENT_TIMESTAMP),
(206, 1001, CURRENT_TIMESTAMP);



--Add your favorite movies to any store's inventory.
INSERT INTO inventory (film_id, store_id, last_update)
VALUES
    ((SELECT film_id FROM film WHERE title = 'Kurmanjan Datka'limit 1), 1, CURRENT_DATE),  -- Inception
    ((SELECT film_id FROM film WHERE title = 'Sayakbay'limit 1), 2, CURRENT_DATE),  -- The Dark Knight
    ((SELECT film_id FROM film WHERE title = 'Er Töshtük'limit 1), 1, CURRENT_DATE);



--Alter any existing customer in the database with at least 43 rental and 43 payment records. Change their personal data to yours (first name, last name, address, etc.). You can use any existing address from the "address" table. Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count, COUNT(p.payment_id) AS payment_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) >= 43 AND COUNT(p.payment_id) >= 43
LIMIT 1;

UPDATE customer
SET first_name = 'Takhmina', 
    last_name = 'Zhumakova', 
    email = 'takhminazhumakova@gmail.com', 
    address_id = (SELECT address_id FROM address LIMIT 1)  
WHERE customer_id = 1;  
select * from customer c 

--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
DELETE from rental
WHERE customer_id = 1;
DELETE from payment
WHERE customer_id = 1;

--Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
 --(Note: to insert the payment_date into the table payment, you can create a new partition (see the scripts to install the training database ) or add records for the first half of 2017)

SELECT film_id, title FROM film
WHERE title IN ('Sayakbay', 'Kurmanjan Datka', 'Er Töshtük');

SELECT inventory_id, film_id FROM inventory
WHERE film_id IN (
    SELECT film_id FROM film
    WHERE title IN ('Sayakbay', 'Kurmanjan Datka', 'Er Töshtük')
);
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES 
('2017-04-01 12:00:00', 4582, 1, '2017-04-05 12:00:00', 1),
('2017-04-01 13:00:00', 4583, 1, '2017-04-05 13:00:00', 1),
('2017-04-01 14:00:00', 4584, 1, '2017-04-05 14:00:00', 1);

SELECT rental_id FROM rental
WHERE customer_id = 1
AND rental_date BETWEEN '2017-04-01 00:00:00' AND '2017-04-01 23:59:59';

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES
(1, 1, 32295, 2.99, '2017-04-01 12:05:00'),
(1, 1, 32296, 2.99, '2017-04-01 13:05:00'),
(1, 1, 32297, 2.99, '2017-04-01 14:05:00');

commit

