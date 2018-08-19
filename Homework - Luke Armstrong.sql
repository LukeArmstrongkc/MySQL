use sakila;
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name,' ',last_name)) as full_name from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor where first_name = "Joe";
-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like "%gen%";
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like "%li%" order by last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country IN ("Afghanistan","Bangladesh","China");
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor add column middle_name VARCHAR(100) after first_name;
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor modify column middle_name blob;
-- 3c. Now delete the middle_name column.
alter table actor drop column middle_name;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'count' from actor group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as 'Count' from actor group by last_name having count>=2;
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'Harpo' where first_name = 'Groucho' and last_name = 'Williams';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor set first_name = CASE when first_name = 'Harpo' then 'Groucho' else 'Mucho Groucho' end where actor_id = 172;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
-- CREATE TABLE `address` (
-- `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
-- `address` varchar(50) NOT NULL,
-- `address2` varchar(50) DEFAULT NULL,
-- `district` varchar(20) NOT NULL,
-- `city_id` smallint(5) unsigned NOT NULL,
-- `postal_code` varchar(10) DEFAULT NULL,
-- `phone` varchar(20) NOT NULL,
-- `location` geometry NOT NULL,
-- `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
-- PRIMARY KEY (`address_id`),
-- KEY `idx_fk_city_id` (`city_id`),
-- SPATIAL KEY `idx_location` (`location`),
-- CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
--  ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address from staff s left join address a on s.address_id = a.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) as 'Total Sum'
FROM staff s
left JOIN payment p
ON s.staff_id = p.staff_id
AND payment_date LIKE '2005-08%';
-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
select f.title as 'Film Title', count(actor_id) as 'Number of Actors' from film_actor fa
inner join film f
on fa.film_id = f.film_id
GROUP BY f.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? select film_id from film where title = 'Hunchback Impossible' = 439
select title, (select Count(*) from inventory where film.film_id = inventory.film_id) as 'Number of Copies'
from film where title = 'Hunchback Impossible';
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select c.last_name, c.first_name, SUM(p.amount) as 'Total Paid'
from customer c
join payment p
on c.customer_id = p.customer_id
group by last_name asc;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
--     As an unintended consequence, films starting with the letters `K` and `Q` have
--     also soared in popularity. Use subqueries to display the titles of movies
--     starting with the letters `K` and `Q` whose language is English. 
select title from film where title like 'k%' or title like 'q%'
and title in (select title from film where language_id = 1);
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name, actor_id from actor where actor_id IN
(select actor_id from film_actor where film_id IN
	(select film_id from film where title = 'Alone Trip'));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers - country_id 20. 
-- Use joins to retrieve this information.
select cu.first_name, cu.last_name, cu.email
from customer cu
join address a
on (cu.address_id = a.address_id)
join city ci
on (ci.city_id = a.city_id)
join country co
on (co.country_id = ci.country_id)
where co.country_id = 20;

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies 
--  categorized as famiy films.
select f.title, c.name from film f
join film_category fc
on (f.film_id = fc.film_id)
join category c
on (c.category_id = fc.category_id)
where name = 'Family';
-- 7e. Display the most frequently rented movies in descending order.
select count(r.rental_id) as 'Times Rented', f.title
from film f
join inventory i
on (f.film_id = i.film_id)
join rental r
on (i.inventory_id = r.inventory_id)
group by f.title
order by count(r.rental_id) desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as 'Total Payments'
from store s
join staff sf
on (s.store_id = sf.store_id)
join payment p
on (p.staff_id=sf.staff_id)
group by store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country
from store s
join address a
on (s.address_id = a.address_id)
join city c
on (a.city_id = c.city_id)
join country co
on (c.country_id = co.country_id);
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select sum(p.amount) as 'Total Revenue', c.name
from category c
join film_category fc
on (c.category_id = fc.category_id)
join inventory i
on (fc.film_id = i.film_id)
join rental r
on (i.inventory_id = r.inventory_id)
join payment p
on (r.rental_id = p.rental_id)
group by c.name
order by sum(p.amount) desc limit 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the top five genres by gross revenue. 
-- Use the solution from the -- problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
select sum(p.amount) as 'Total Revenue', c.name
from category c
join film_category fc
on (c.category_id = fc.category_id)
join inventory i
on (fc.film_id = i.film_id)
join rental r
on (i.inventory_id = r.inventory_id)
join payment p
on (r.rental_id = p.rental_id)
group by c.name
order by sum(p.amount) desc limit 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop View top_five_genres;