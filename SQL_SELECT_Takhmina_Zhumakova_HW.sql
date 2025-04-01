--Top-5 actors by number of movies (released after 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)
SELECT
    a.first_name, -- select full name
    a.last_name,
    COUNT(fa.film_id) AS number_of_movies --count number of moviews with fil id
FROM
    actor a --take data from actor table
inner JOIN
    film_actor fa ON a.actor_id = fa.actor_id --inner join actor_id from actor and film_actor tables
inner JOIN
    film f ON fa.film_id = f.film_id --inner join film_id from film and film_actor tables
WHERE
    f.release_year > 2015 --release year should be after 2015
GROUP BY
    a.actor_id, a.first_name, a.last_name --- group by so that rows will coincide
ORDER BY
    number_of_movies DESC --- list in descending order
LIMIT 5; --- limit only 5

--Number of Drama, Travel, Documentary per year (columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order. Dealing with NULL values is encouraged)
SELECT
    f.release_year,
    SUM(CASE WHEN c.name = 'Drama' THEN 1 ELSE 0 END) AS number_of_drama_movies,--- count drama
    SUM(CASE WHEN c.name = 'Travel' THEN 1 ELSE 0 END) AS number_of_travel_movies,---count travel
    SUM(CASE WHEN c.name = 'Documentary' THEN 1 ELSE 0 END) AS number_of_documentary_movies--count documentary
FROM
    film f
inner JOIN
    film_category fc ON f.film_id = fc.film_id --- join film category to fil by film id
inner JOIN
    category c ON fc.category_id = c.category_id--- join category to film by category id
GROUP BY
    f.release_year --- remove duplicates
ORDER BY
    f.release_year DESC;--- sort in descending order
	
	--All animation movies released between 2017 and 2019 with rate more than 1, alphabetical

SELECT
    f.title
FROM
    film f
INNER JOIN
    film_category fc ON f.film_id = fc.film_id --join film category to film with common film_id
INNER JOIN
    category c ON fc.category_id = c.category_id --join category with category id
WHERE
    c.name = 'Animation' ---- search for animation from name
    AND f.release_year BETWEEN 2017 AND 2019 --- realease year between 2017 and 2019
    AND f.rental_rate > 1 --- take rate from 1 
ORDER BY
    f.title; -- sort by title
	
	
 ---The revenue earned by each rental store after March 2017 (columns: address and address2 – as one column, revenue)
SELECT
    CONCAT(a.address, ' ', COALESCE(a.address2, '')) AS address,---to write together in one line
    SUM(p.amount) AS revenue--- add amount and write as revenue
FROM
    payment p--take data from payement
JOIN
    rental r ON p.rental_id = r.rental_id --- join rental to payment with common rental id
JOIN
    inventory i ON r.inventory_id = i.inventory_id---join inventory
JOIN
    store s ON i.store_id = s.store_id---join store
JOIN
    address a ON s.address_id = a.address_id---join adress
WHERE
   r.rental_date >= '2017-04-01'  -- After March 2017
GROUP BY
    a.address, a.address2  -- Group by both address fields
ORDER BY
    revenue DESC;  -- Order by revenue (optional)
	
	
--Which three employees generated the most revenue in 2017? They should be awarded a bonus for their outstanding performance. 


--staff could work in several stores in a year, please indicate which store the staff worked in (the last one);
--if staff processed the payment then he works in the same store; 
--take into account only payment_date
SELECT
    sf.first_name,
    sf.last_name,
    s.store_id,
    SUM(p.amount) AS revenue ---add all amount and write it as revenue
FROM
    payment p--- data from payement
JOIN
    staff sf ON p.staff_id = sf.staff_id--join staff
JOIN
    store s ON sf.store_id = s.store_id --join store
WHERE
    EXTRACT(YEAR FROM p.payment_date) = '2017' --extract year from date
GROUP BY
    sf.staff_id, sf.first_name, sf.last_name, s.store_id --- group 
ORDER BY
    revenue DESC --- order in descending order
LIMIT 3; limit with 3



--2. Which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies? To determine expected age please use 'Motion Picture Association film rating system

SELECT
    f.title,
    COUNT(r.rental_id) AS rental_count, ---count rental id which can be repeated after each payment of one person
    CASE f.rating --- determine the expected audience with explanation
        WHEN 'G' THEN 'All Ages'
        WHEN 'PG' THEN 'General Audience'
        WHEN 'PG-13' THEN 'Ages 13+'
        WHEN 'R' THEN 'Mature'
        WHEN 'NC-17' THEN 'Adults Only'
        ELSE 'Unknown'
    END AS expected_audience
FROM
    film f
JOIN
    inventory i ON f.film_id = i.film_id ---join inventory table
JOIN
    rental r ON i.inventory_id = r.inventory_id --join rental table
GROUP BY
    f.film_id, f.title, f.rating ---group result
ORDER BY
    rental_count DESC--- sort in DESC order
LIMIT 5;--- limit with 5 result


--Part 3. Which actors/actresses didn't act for a longer period of time than the others?
--V1: gap between the latest release_year and current year per each actor;
--V2: gaps between sequential films per each actor;

SELECT
    a.first_name,--- select full name of the actors 
    a.last_name,
    (EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year)) AS gap-- exctract maximum gap by subtructing release yer from current date
FROM
    actor a
JOIN
    film_actor fa ON a.actor_id = fa.actor_id ---join actor id from two tables
JOIN
    film f ON fa.film_id = f.film_id --- join actor id from two tables
GROUP BY
    a.actor_id, a.first_name, a.last_name --- coincide the result
ORDER BY
    gap DESC-- sort in descending order

