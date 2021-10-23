/* Company Revenue is calculated from the payments table*/

SELECT printf("%.2f", SUM(amount)) as Revenue, strftime('%Y', payment_date) as Year
FROM payment
GROUP BY 2;

SELECT Revenue, case when Month = '05' then 'May'
when Month = '06' then 'June'
when Month = '07' then 'July'
else 'August' end as Month
FROM
    (SELECT printf("%.2f", SUM(amount)) as Revenue, strftime('%Y', payment_date) as Year, strftime('%m', payment_date) as Month
    FROM payment
    GROUP BY 3
    HAVING Year = '2005');

/* No of rental*/
SELECT count(rental_id) as Total_Rentals, store_id as Store_Number, a.address as Store_Address
FROM rental r
    INNER JOIN store s ON r.staff_id = s.manager_staff_id
    INNER JOIN address a ON s.address_id = a.address_id 
GROUP BY 2;

/* Revenue by store*/
SELECT printf("%.2f", SUM(amount)) as Revenue, store_id as Store_Number, a.address as Store_Address
FROM rental r
    INNER JOIN store s ON r.staff_id = s.manager_staff_id
    INNER JOIN address a ON s.address_id = a.address_id
    INNER JOIN payment p ON r.rental_id = p.rental_id 
GROUP BY 2;

/* Total Customers*/

SELECT Total_Customer, case when Activity = 1 then 'Active'
else 'Non-Active' end as Activity
FROM
    (SELECT COUNT(customer_id) as Total_Customer, active as Activity
    FROM customer
    GROUP BY 2
    ORDER BY 2 DESC);
    
/*RFM*/
SELECT customer_id,first_name || ' ' || last_name as Customer_Name, strftime('%Y-%m-%d', max(rental_date)) as Last_Purchase, 
        count(r.rental_id) as Total_Purchases, printf("%.2f", sum(amount)) as Total_Spending
FROM rental r 
    INNER JOIN payment p ON r.customer_id = p.customer_id
    INNER JOIN customer c ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 4 DESC
LIMIT 5;

/*Customers who only rented in 2005, not in 2006*/
SELECT distinct r.customer_id,first_name || ' ' || last_name as Customer_Name, strftime('%Y', rental_date) as year
FROM rental r 
    INNER JOIN payment p ON r.customer_id = p.customer_id
    INNER JOIN customer c ON p.customer_id = c.customer_id
WHERE year = '2005'
EXCEPT
SELECT distinct r.customer_id,first_name || ' ' || last_name as Customer_Name, strftime('%Y', rental_date) as year
FROM rental r 
    INNER JOIN payment p ON r.customer_id = p.customer_id
    INNER JOIN customer c ON p.customer_id = c.customer_id
WHERE year = '2006';


/* Average purchase & Spending per customer*/
SELECT avg(Total_Purchases), avg(Average_Spending)
FROM
    (SELECT r.customer_id, count(r.rental_id) as Total_Purchases, printf("%.2f", sum(amount)) as Average_Spending
    FROM rental r 
        INNER JOIN payment p ON r.customer_id = p.customer_id
    GROUP BY 1);
    
/* Customer Tenure*/
SELECT customer_id, last_update - max(rental_date)
FROM rental
GROUP BY 1;

/* Customer per Country and Sales per country*/
SELECT country, count(distinct cu.customer_id) as Total_Customer, printf("%.2f", sum(amount)) as Total_Revenue
FROM customer cu
    INNER JOIN address a ON cu.address_id = a.address_id
    INNER JOIN city ci ON a.city_id = ci.city_id
    INNER JOIN country co ON ci.country_id = co.country_id
    INNER JOIN payment p ON cu.customer_id = p.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* Most rented films*/
SELECT f.film_id as Film_Number, lower(title) as Film_Title, c.name as Film_Category, count(r.rental_id) as Times_rented
FROM rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;

/*Least Rented films*/
SELECT  name as Category, count(name) as Number_of_Movies_Below_50percentAverage
FROM
    (SELECT count(r.rental_id) as Total_rent, f.film_id, title, length, c.name
        FROM film f
            LEFT JOIN inventory i ON f.film_id = i.film_id
            LEFT JOIN rental r ON i.inventory_id = r.inventory_id
            LEFT JOIN film_category fc ON f.film_id = fc.film_id
            LEFT JOIN category c ON fc.category_id = c.category_id
        GROUP BY 2
        HAVING count(r.rental_id) < (SELECT 0.5*avg(Total_rent) FROM (SELECT count(r.rental_id) as Total_rent, f.film_id, title, length, c.name
            FROM film f
                LEFT JOIN inventory i ON f.film_id = i.film_id
                LEFT JOIN rental r ON i.inventory_id = r.inventory_id
                LEFT JOIN film_category fc ON f.film_id = fc.film_id
                LEFT JOIN category c ON fc.category_id = c.category_id
            GROUP BY 2))
        ORDER BY 1,5 ASC)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


/* Most rented category*/
SELECT  c.name as Film_Category, count(r.rental_id) as Times_rented
FROM rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

/* Employee & Store Details*/
SELECT  distinct store_id as Store_Number, st.first_name || ' ' || st.last_name as In_Store_Manager, a.address as Store_Address, country
FROM staff st
    INNER JOIN store s ON st.staff_id = s.manager_staff_id
    INNER JOIN address a ON s.address_id = a.address_id
    INNER JOIN city c ON a.city_id = c.city_id
    INNER JOIN country co ON c.country_id = co.country_id;