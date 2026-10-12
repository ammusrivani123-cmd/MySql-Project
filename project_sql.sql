CREATE DATABASE music_store;
USE music_store;


CREATE TABLE Genre (
	genre_id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(120)
);
select * from genre;
CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(120)
);
select * from mediatype;

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);
Select * from employee;

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

select * from customer;

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);
-- DROP TABLE ARTIST;
SELECT * FROM Artist;
-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
select * from album;
-- DROP TABLE ALBUM;

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY auto_increment,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
-- DROP TABLE MEDIATYPE;
-- drop table track;
select * from track;

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY auto_increment,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
select * from invoice;

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY auto_increment,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
select * from invoiceline;

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(255)
);
select * from playlist;

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
SHOW TABLES;
SELECT * FROM playlisttrack;

desc track;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);
select count(track_id) from track;

SELECT * FROM genre;
SELECT * FROM mediatype;
SELECT * FROM employee;
SELECT * FROM customer;
SELECT * FROM album;
SELECT * FROM artist;
SELECT * FROM track;
SELECT * FROM invoice;
SELECT * FROM invoiceline;
SELECT * FROM playlist;
SELECT * FROM playlisttrack;

# 1. Who is the senior most employee based on job title?

SELECT * FROM employee 
where title = 'General Manager';                            
                                                      

# 2. Which countries have the most Invoices?

SELECT 
    billing_country, COUNT(*) AS total_invoice
FROM
    invoice
GROUP BY billing_country
ORDER BY total_invoice DESC
LIMIT 1;

# 3. What are the top 3 values of total invoice?

select invoice_id,total from invoice order by total desc limit 3 ;

# 4. Which city has the best customers? - We would like to throw a promotional Music Festival in
#the city we made the most money. Write a query that returns one city that has the highest sum of
#invoice totals. Return both the city name & sum of all invoice totals'''

select billing_city,sum(total) from invoice  group by billing_city order by sum(total) desc limit 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared
-- the best customer. Write a query that returns the person who has spent the most money

select c.customer_id,concat(first_name,' ',last_name) as customer_name ,
sum(i.total) as total_spent from customer c
join invoice i 
on c.customer_id = i.customer_id
group by c.customer_id,customer_name
order by total_spent desc
limit 1;


-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email,c.first_name,c.last_name,g.name as genre_name FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoiceline il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN genre g
ON t.genre_id = g.genre_id
where g.name = 'rock'
order by c.email;


-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that
-- returns the Artist name and total track count of the top 10 rock bands

select ar.name as artist_name ,count(tr.track_id) as total_track_count from artist ar
join album al
on ar.artist_id= al.artist_id
join track tr
on al.album_id = tr.album_id
join genre g
on tr.genre_id = g.genre_id
where g.name = 'rock'
group by  ar.artist_id,ar.name 
order by total_track_count desc 
limit 10;




-- 8. Return all the track names that have a song length longer than the average song length.-
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest
-- songs listed first

SELECT name,milliseconds from track 
WHERE milliseconds >
(SELECT avg(milliseconds) from track) order by milliseconds desc ;

-- 9. Find how much amount is spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

SELECT concat(first_name,' ',last_name) as customer_name,ar.name as artist_name,SUM(i.total) as total_spent FROM customer c
JOIN invoice i 
on c.customer_id = i.customer_id
JOIN invoiceline il
on i.invoice_id = il.invoice_id
JOIN track t
on il.track_id = t.track_id
JOIN album a
ON t.album_id = a.album_id
JOIN artist ar
ON a.artist_id = ar.artist_id
GROUP BY 
customer_name,ar.name
ORDER BY total_spent desc;


-- 10. We want to find out the most popular music Genre for each country. We determine the most
-- popular genre as the genre with the highest amount of purchases. Write a query that returns
-- each country along with the top Genre. For countries where the maximum number of purchases
-- is shared, return all Genres

WITH top_genre AS(
SELECT i.billing_country as country,g.name as genre_name,SUM(i.total) as top_purchase from invoice i
JOIN invoiceline il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN genre g
ON t.genre_id = g.genre_id
GROUP BY country,genre_name),
ranked_country AS(
SELECT country,genre_name,top_purchase,
RANK() OVER (PARTITION BY country ORDER BY top_purchase desc) as rankk from top_genre)
-- select * from top_genre;
SELECT country,genre_name,top_purchase FROM ranked_country
WHERE rankk = 1
ORDER BY country;



-- 11. Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how much they
-- spent. For countries where the top amount spent is shared, provide all customers who spent this
-- amount

WITH customer_spending as (
SELECT c.country as country,
concat(first_name,' ',last_name) as customer_name ,
sum(i.total) as total_spent from customer c
join invoice i 
on i.customer_id = c.customer_id
group by c.country ,customer_name
),
customer_profile as(
select country,customer_name,total_spent,
RANK() OVER(partition by country
order by total_spent  desc) as rankk
from customer_spending)
select country,customer_name,total_spent
from customer_profile 
where rankk = 1
order by country;





