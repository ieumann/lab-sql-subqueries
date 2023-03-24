USE sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

# 2. List all films whose length is longer than the average of all the films.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length;

# To check the result I calculate the average length of all films. 
SELECT AVG(length) AS avg_length
FROM film;

# 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'))
ORDER BY last_name;

# To double-check the results, I do the same with a multiple join.
SELECT first_name, last_name
FROM actor as a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
JOIN film as f ON fa.film_id = f.film_id
WHERE title = 'Alone Trip';

# 4. Sales have been lagging among young families, and you wish to target all family movies for a 
# promotion. Identify all movies categorized as family films.
SELECT name # To see how the category is identified exactly
FROM category;

SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM film_category
WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family'))
ORDER by title;

# 5. Get name and email from customers from Canada using subqueries. Do the same with joins.
# Note that to create a join, you will have to identify the correct tables with their primary 
# keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email
FROM customer as c
JOIN address as a ON c.address_id = a.address_id
JOIN city as ci ON a.city_id = ci.city_id
JOIN country as co ON ci.country_id = co.country_id
WHERE country = 'Canada';

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city
WHERE country_id = (SELECT country_id FROM country WHERE country = 'Canada')));

# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as 
# the actor that has acted in the most number of films. First you will have to find the most 
# prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT COUNT(title) # To double-check if all respective films are listed.
FROM film
WHERE film_id IN (SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1));

SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1));

# To confirm and see the name of the actress that starred in the most amount of films.
SELECT a.first_name, a.last_name, COUNT(fa.actor_id) AS num_films
FROM actor AS a
JOIN film_actor AS fa ON a.actor_id = fa.actor_id
JOIN film AS f ON fa.film_id = f.film_id
GROUP BY a.actor_id
ORDER BY num_films DESC
LIMIT 1;

# 7. Films rented by most profitable customer. You can use the customer table and payment table 
# to find the most profitable customer ie the customer that has made the largest sum of payments.
SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM inventory
WHERE inventory_id IN (SELECT inventory_id FROM rental
WHERE customer_id = (SELECT customer_id FROM 
(SELECT customer_id, SUM(amount) AS total_payments FROM payment
GROUP BY customer_id
ORDER BY total_payments DESC
LIMIT 1) AS most_profit_customer)));

# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average
#  of the total_amount spent by each client.
SELECT  customer_id, SUM(amount) AS total_amount_spent # I suppose client_id refers to customer_id
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT AVG(total_amount_spent)
FROM (SELECT SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id) AS customer_total)
ORDER BY total_amount_spent DESC;

# To check the average.
SELECT AVG(total_amount_spent) AS avg_total_amount_spent
FROM (SELECT customer_id, SUM(amount) AS total_amount_spent FROM payment
GROUP BY customer_id) AS customer_totals;

