--Task 1. Create a view
--Create a view called 'sales_revenue_by_category_qtr' that shows the film category and total sales 
--revenue for the current quarter and year. The view should only display categories with at least
--one sale in the current quarter. 
--Note: when the next quarter begins, it will be considered as the current quarter.



DO $$
BEGIN
    
    IF EXISTS (
        SELECT 1 FROM information_schema.views
        WHERE table_name = 'sales_revenue_by_category_qtr'
    ) THEN
        DROP VIEW sales_revenue_by_category_qtr;
    END IF;

    
    CREATE VIEW sales_revenue_by_category_qtr AS
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_revenue
    FROM
        payment p
        JOIN rental r ON p.rental_id = r.rental_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN film_category fc ON f.film_id = fc.film_id
        JOIN category c ON fc.category_id = c.category_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)
        AND EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
    GROUP BY
        c.name;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating view: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;








--Task 2. Create a query language functions
--Create a query language function called 'get_sales_revenue_by_category_qtr' that accepts one parameter representing the current quarter and year and returns the same result as the 'sales_revenue_by_category_qtr' view.


CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(qtr_yr TEXT)
RETURNS TABLE (
    category TEXT,
    total_revenue NUMERIC
)
AS $$
DECLARE
    qtr INT;
    yr INT;
BEGIN
    
    qtr := CAST(SUBSTRING(qtr_yr FROM 2 FOR 1) AS INTEGER);
    yr := CAST(SUBSTRING(qtr_yr FROM 4) AS INTEGER);

   
    RETURN QUERY
    SELECT
        c.name,
        SUM(p.amount)
    FROM
        payment p
        JOIN rental r ON p.rental_id = r.rental_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN film_category fc ON f.film_id = fc.film_id
        JOIN category c ON fc.category_id = c.category_id
    WHERE
        EXTRACT(YEAR FROM p.payment_date) = yr
        AND EXTRACT(QUARTER FROM p.payment_date) = qtr
    GROUP BY
        c.name;
END;
$$ LANGUAGE plpgsql;


--Task 3. Create procedure language functions
--Create a function that takes a country as an input parameter and returns the most popular film in that specific country. 
--The function should format the result set as follows:
                    --Query (example):select * from core.most_popular_films_by_countries(array['Afghanistan','Brazil','United States’]);



CREATE OR REPLACE FUNCTION most_popular_films_by_countries()
RETURNS TABLE(
    country_name TEXT,
    most_popular_film TEXT,
    popularity_score NUMERIC
)
AS $$
BEGIN
 
    RETURN QUERY
    SELECT 
        c.name AS country_name,
        f.title AS most_popular_film,
        SUM(p.amount) AS popularity_score
    FROM
        payment p
        JOIN rental r ON p.rental_id = r.rental_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN film_category fc ON f.film_id = fc.film_id
        JOIN category cat ON fc.category_id = cat.category_id
        JOIN store s ON i.store_id = s.store_id
        JOIN address a ON s.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country c ON ci.country_id = c.country_id
    WHERE
        c.name IN (SELECT name FROM country) -- Fetch all country names from the 'country' table
    GROUP BY
        c.name, f.title
    ORDER BY
        popularity_score DESC;
END;
$$ LANGUAGE plpgsql;





--Task 4. Create procedure language functions
--Create a function that generates a list of movies available in stock based on a partial title match (e.g., movies containing the word 'love' in their title). 
--The titles of these movies are formatted as '%...%', and if a movie with the specified title is not in stock, return a message indicating that it was not found.
--The function should produce the result set in the following format (note: the 'row_num' field is an automatically generated counter field, starting from 1 and incrementing for each entry, e.g., 1, 2, ..., 100, 101, ...).

                    --Query (example):select * from core.films_in_stock_by_title('%love%’);


CREATE OR REPLACE FUNCTION films_in_stock_by_title(partial_title TEXT)
RETURNS TEXT
AS $$
DECLARE
    films_found INT;
BEGIN
   
    SELECT COUNT(*)
    INTO films_found
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    WHERE f.title LIKE partial_title
    GROUP BY f.title
    HAVING COUNT(i.inventory_id) > 0;

   
    IF films_found = 0 THEN
        RETURN 'No films found in stock with the specified title.';
    END IF;

  
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY f.title) AS row_num,
        f.title AS film_title,
        COUNT(i.inventory_id) AS inventory_count
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    WHERE f.title LIKE partial_title
    GROUP BY f.title
    HAVING COUNT(i.inventory_id) > 0;
END;
$$ LANGUAGE plpgsql;





--Task 5. Create procedure language functions
---Create a procedure language function called 'new_movie' that takes a movie title as a parameter and inserts a new movie with the given title in the film table. The function should generate a new unique film ID, set the rental rate to 4.99, the rental duration to three days, the replacement cost to 19.99. The release year and language are optional and by default should be current year and Klingon respectively. The function should also verify that the language exists in the 'language' table. Then, ensure that no such function has been created before; if so, replace it.


DROP FUNCTION IF EXISTS new_movie(TEXT, INTEGER, TEXT);


CREATE OR REPLACE FUNCTION new_movie(
    movie_title TEXT,
    release_year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE), 
    language TEXT DEFAULT 'Klingon'  
)
RETURNS VOID
AS $$
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM language WHERE name = language) THEN
        RAISE EXCEPTION 'Language "%" does not exist in the language table.', language;
    END IF;

    INSERT INTO film (title, release_year, language_id, rental_rate, rental_duration, replacement_cost)
    VALUES (
        movie_title, 
        release_year, 
        (SELECT language_id FROM language WHERE name = language),  
        4.99,  -- Rental rate
        3,     -- Rental duration (3 days)
        19.99  -- Replacement cost
    );
END;
$$ LANGUAGE plpgsql;


-