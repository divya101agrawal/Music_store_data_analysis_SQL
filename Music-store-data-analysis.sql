--Q1 Who is the most senior employee based on job title?

select concat(first_name,' ',last_name) as Name 
from employee
order by levels desc
limit 1

--Q2 Which countries have the most invoices?

select billing_country as country, count(*) as invoice_count
from invoice 
group by billing_country
order by invoice_count desc
limit 1

--Q3 What are the top 3 values of total invoice
select total as top_3_total
from invoice
order by total desc
limit 3

-- Q4 Which city has the best customers? We would like to throw a promotional Music Festival 
--in the city we made the most money.write a query that returns one city that has the highest
--sum of invoice totals. return both the city name and sum of all invoice totals

select * from invoice
select * from customer

select billing_city, sum(total) as total_invoice
from invoice
group by billing_city 
order by total_invoice desc
limit 1


--Q5 Who is the best customer? The customer who has spent the most money is called the 
--best customer. write a query to return the best customer

with cte as (
select customer_id, sum(total) as invoice_total
from invoice
group by customer_id
order by invoice_total desc
limit 1)

select concat(first_name,' ', last_name) as Name
from customer
where customer_id =(select customer_id from cte)

--Q6 Write a query to return the email, first name,last name and genre of all rock music
--listeners. Return the list ordered alphabatically by email starting with A

select distinct email, first_name, last_name
from
customer c join invoice i on c.customer_id= i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
where track_id in(select track_id from track join genre on track.genre_id= genre.genre_id
				 where genre.name like 'Rock')
order by email


--Q7 Let's invite the artists who have written the most rock music in our dataset.
--Write the query to return the artist name and total track count of the top 10 rock bands.

select artist.artist_id,artist.name,  count(artist.artist_id) as track_count
from artist join album on artist.artist_id= album.artist_id
join Track on Track.album_id= album.album_id

where track.genre_id in(select genre_id from genre where name like 'Rock')

group by artist.artist_id
order by track_count desc
limit 10

--Q8 Return all the track names that have a song length longer than the avg song length.
--Return the name and miliseconds for each track. order by the song length with the longest 
--songs listed first

select name, milliseconds
from track
where milliseconds>(select avg(milliseconds) avg_length from track)
order by milliseconds desc


--Q9 Find how much amount spent by each customer on artists? Write a query to return 
--customer name, artist name, total spent

select c.first_name, c.last_name, at.name as artist_name, sum(il.quantity*il.unit_price) as total_spent
from customer c left join invoice i on c.customer_id= i.customer_id
left join invoice_line il on i.invoice_id=il.invoice_id
left join track t on il.track_id= t.track_id
left join album a on t.album_id=a.album_id
left join artist at on a.artist_id=at.artist_id

group by c.first_name, c.last_name, at.name

--Q10 We want to find out the most popular music genre for each country.We determine the most popular 
--genre as the genre with highest amount of purchases. Write the query that returns each country
--along with the top genre. For countries where the maximum number of purchases is shared, return all 
--genres


with cte as(
select  i.billing_country as Country, t.genre_id as genre_id, g.name as genre_name, 
sum(quantity) as total_purchases
from invoice i 
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id= t.track_id
join genre g on t.genre_id= g.genre_id

group by i.billing_country, t.genre_id, g.name 
)	


select  Country, genre_name , total_purchases from
(select *,
dense_rank() over(partition by Country 
				  order by total_purchases desc) as rank
from cte )
where rank=1


--Q11 Write a query that determines the customer that has spent the most on music for each country.
--write a query that returns the country along with the top customer and how much they spent.
--for countries where the spent amount is shared, provide all customers who spent this amount.

with cte as
(select country, c.customer_id, c.first_name,c.last_name, sum(il.quantity*il.unit_price) total_spent

from customer c  join invoice i on c.customer_id= i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id 
group by c.country, c.customer_id, c.first_name,c.last_name
order by total_spent desc)


select country, first_name,last_name,total_spent
from
(select *, dense_rank() over(partition by country order by total_spent desc) as rank
from cte)
where rank=1







































