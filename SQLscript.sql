
#Q1: Who is the senior most employee based on jobtitle? 
SELECT first_name,last_name FROM employee
ORDER BY levels DESC
LIMIT 1; 

#Q2: Which countries have the most invoices?
SELECT billing_country, COUNT(*) as totalinvoices
FROM invoice 
GROUP BY billing_country
ORDER BY totalinvoices DESC
LIMIT 5; 

#Q3: What are the top 3 values of total invoice? 
SELECT ROUND(total,2) AS total FROM invoice
ORDER BY total DESC
LIMIT 3;

#Q4: Which city has the highest sum of invoice totals?
SELECT * FROM invoice; 
SELECT billing_city,ROUND(SUM(total)) tot
FROM invoice
GROUP BY billing_city
ORDER BY tot DESC
LIMIT 1; 

#Q5: Who is the best customer? In this case determined by highest amount spent. 
SELECT c.customer_id,c.first_name,c.last_name,ROUND(SUM(i.total)) AS totalspending,
DENSE_RANK() OVER (ORDER BY ROUND(SUM(i.total)) DESC) AS spendingrank
FROM customer c
JOIN  invoice i ON c.customer_id = i.customer_id
GROUP BY  c.customer_id, c.first_name, c.last_name
ORDER BY  totalspending DESC;

#Q6: Write a query to return the email, first name, last name of all Rock Music listeners, 
#return your list ordered alphabetically by email starting with A.

SELECT DISTINCT first_name,last_name,email FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id 
WHERE track_id IN(
SELECT track_id FROM track t
JOIN genre g 
ON t.genre_id = g.genre_id 
WHERE g.name = 'rock')
ORDER BY email ASC; 

#Q7: Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name,milliseconds 
FROM track
WHERE milliseconds >
(SELECT AVG(milliseconds) AS avgtracklength
FROM track)
ORDER BY milliseconds DESC; 

#Q8: Find how much amount spent by each customer on artists? 
# Write a query to return customer name, artist name and total spent.

WITH best_selling_artists AS 
(SELECT artist.artist_id,artist.name AS artist_name,a.title, 
        SUM(il.unit_price * il.quantity) AS totalsales
FROM invoice_line il
JOIN 
track t ON il.track_id = t.track_id
JOIN 
album2 a ON t.album_id = a.album_id
JOIN 
artist ON artist.artist_id = a.artist_id
GROUP BY 
artist.artist_id, artist.name, a.title
ORDER BY 
totalsales DESC
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name, 
SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c         
	ON c.customer_id = i.customer_id
JOIN invoice_line il 
	ON il.invoice_id = i.invoice_id
JOIN track t        
	ON t.track_id = il.track_id
JOIN album2 alb
	ON alb.album_id = t.album_id
JOIN best_selling_artists bsa
	ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

#Q8: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
# with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
# the maximum number of purchases is shared return all Genres.

WITH popular_genre AS
(
SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS rownumber 
FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country,genre.name,genre.genre_id
	ORDER BY 2 ASC, 1 DESC
    )
SELECT * FROM popular_genre 
WHERE rownumber <= 1 
ORDER BY purchases DESC; 

#Q9: Write a query that determines the customer that has spent the most on music for each country. 
# Write a query that returns the country along with the top customer and how much they spent. 
# For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_with_country AS 
(
SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rownumber 
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,first_name,last_name,billing_country
ORDER BY billing_country ASC,SUM(total) DESC)
	SELECT * FROM customer_with_country
	WHERE rownumber <= 1;








