drop database if exists music;
create database music ;
use music;

create table employee(
employee_id int  NOT NULL auto_increment primary key,
last_name varchar(50),
first_name varchar(50),
title varchar(100),
reports_to INT,
levels varchar(20),
birthdate varchar(50),
hire_date varchar(50),
address varchar(100),
city varchar(50),
state varchar(20),
country varchar(50),
postal_code varchar (50),
phone varchar(50) ,
fax varchar(50),
email varchar(100));

update employee
set reports_to = Null 
where employee_id = 9;

alter table employee
add constraint fk_reports_to
foreign key (reports_to)
references employee(employee_id);

create table customer(
customer_id int auto_increment primary key,
first_name varchar(50),
last_name varchar(50),
company varchar(100),
address varchar(100),
city varchar(50),
state varchar(30),
country varchar(30),
postal_code varchar(50),
phone varchar(50),
fax varchar(50),
email varchar(100),
support_rep_id int,
foreign key (support_rep_id)
references employee(employee_id));

create table artist(
artist_id int primary key,
name varchar(200));

create table album(
album_id int primary key,
title varchar(100),
artist_id int,
foreign key(artist_id)
references artist(artist_id));


create table invoice(
invoice_id int  NOT NULL auto_increment primary key,
customer_id int,
invoice_date varchar(200),
billing_address varchar(200),
billing_city varchar(200),
billing_state varchar(200),
billing_country varchar(200),
billing_postal_code varchar(200),
total int,
foreign key(customer_id)
references customer(customer_id));

create table invoice_line(
invoice_line_id int  NOT NULL auto_increment primary key,
invoice_id int,
track_id int,
unit_price float,
quantity int,
foreign key(invoice_id)
references invoice(invoice_id),
foreign key(track_id)
references track(track_id));

create table track(
track_id int  NOT NULL auto_increment primary key,
name varchar(200),
album_id int,
media_type_id int,
genre_id int,
composer varchar(1000) default null,
milliseconds varchar(100),
bytes varchar(100),
unit_price varchar(100),
foreign key (album_id)
references album(album_id),
foreign key (media_type_id)
references media_type(media_type_id),
foreign key (genre_id)
references genre(genre_id));
 select count(*) from track;
create table playlist(
playlist_id int primary key,
name varchar(50));

create table playlist_track(
playlist_id int ,
track_id int,
foreign key (playlist_id)
references playlist(playlist_id),
foreign key (track_id)
references track(track_id));


create table media_type(
media_type_id int  NOT NULL auto_increment primary key,
Name varchar(100));

create table genre(
genre_id int  NOT NULL auto_increment primary key,
Name varchar(100));
 
 select * from customer;
 # 1.Who is the senior most employee based on job title?
SELECT MAX(title) AS max_title, CONCAT(first_name, ' ', last_name) AS employee_name
FROM employee
WHERE title = (SELECT MAX(title) FROM employee)
GROUP BY employee_name;
 
 select * from invoice_line;
# 2.Which countries have the most Invoices?
select billing_country,sum(total) as sum_total from invoice group by billing_country;


# 3.What are top 3 values of total invoice?
select billing_country,total from invoice order by total desc limit 3;

-- 4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
# Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select city,sum(total) as total_sum 
from customer join invoice on customer.customer_id=invoice.customer_id
group by city
order by total_sum desc;


# 5.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
# Write a query that returns the person who has spent the most money\*
select * from customer;
select invoice.customer_id,concat(customer.first_name," ",customer.last_name) as customer_name,
count(invoice.total) as total,sum(invoice_line.unit_price*invoice_line.quantity) as total_amount
from invoice join customer on invoice.customer_id = customer.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by invoice.customer_id order by total_amount desc limit 1;

select * from employee;
-- Question Set 2 – Moderate
-- 1.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with 'A'
 select distinct email,concat(first_name,' ',last_name) as name,genre.name 
 from customer 
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice.invoice_id =invoice_line.invoice_id
 join track on invoice_line.track_id=track.track_id
 join genre on track.genre_id=genre.genre_id
 where genre.name = 'Rock' and customer.email like 'a%'
 order by email Asc;
 

select * from track;
-- 2.Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select artist.name as artist_name,count(*) as track_count,genre.name
FROM artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by track_count desc 
limit 10;
select * from track;
-- 3.Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name,milliseconds from track 
where milliseconds>(select avg(milliseconds) from track) 
order by milliseconds desc limit 1;

-- Question Set 3 – Advance
-- 1.Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
select distinct concat(customer.first_name,' ',customer.last_name) as customer_name,
artist.name as artist_name ,sum(invoice_line.unit_price*invoice_line.quantity) as total_spent
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by customer.customer_id,artist.artist_id
order by customer_name,artist_name,total_spent desc;

-- 2.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the 
-- highest amount of purchases. Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
with top_genre as (select cu.country,g.name as tg,sum(il.quantity) as total_quantity
from customer cu
join invoice i on cu.customer_id=i.customer_id
join invoice_line  il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
group by cu.country,g.name
order by cu.country,total_quantity desc)
select country,coalesce(max(tg),'unknown') as top_gen
from top_genre group by country;
 
 -- 3.Write a query that determines the customer that has spent the most on music for each country. 
 -- Write a query that returns the country along with the top customer and how much they spent. 
 -- For countries where the top amount spent is shared, provide all customers who spent this amount
 
 
 WITH customer_spending AS (
SELECT c.country,CONCAT(c.first_name, ' ', c.last_name) AS top_customer,SUM(il.unit_price * il.quantity) AS total_spent
FROM customer AS c 
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id)
SELECT country,top_customer,total_spent
FROM customer_spending
WHERE (country, total_spent) IN (
SELECT country, MAX(total_spent) AS total_spent
FROM customer_spending 
GROUP BY country)
ORDER BY country;

