
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select customer_id,sum(price) as total_amount 
from sales s join menu me on s.product_id = me.product_id
group by 1 order by 1


-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) from sales group by 1


-- 3. What was the first item from the menu purchased by each customer?


------------METHOD 1-----------------
select customer_id, order_date, s.product_id, product_name
from menu m join sales s on s.product_id = m.product_id 
where order_date = (select min(distinct(order_date)) from sales) 
order by 1 


------------METHOD 2-----------------
with cte as(
select customer_id, order_date, s.product_id, product_name,
rank() over(partition by customer_id order by order_date asc) as rnk
from menu m join sales s on s.product_id = m.product_id )
select * from cte where rnk =1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select s.product_id, product_name, count(*) as number_of_orders 
from sales s join menu m on s.product_id=m.product_id 
group by 1,2
order by 3 desc
limit 1


-- 5. Which item was the most popular for each customer?

with cte1 as(
select customer_id, product_name, count(order_date) as number_of_orders, rank() over(partition by customer_id order by count(order_date) desc) as rnk
from sales s join menu m on s.product_id=m.product_id 
group by 1,2
order by 1, 3 desc)

select customer_id, product_name, number_of_orders from cte1 where rnk=1


-- 6. Which item was purchased first by the customer after they became a member?

with cte as(
select s.*, m.join_date, me.product_name,
rank() over(partition by s.customer_id order by order_date asc) as rnk
from members m join sales s on m.customer_id=s.customer_id
join menu me on me.product_id = s.product_id
where order_date >= join_date)

select customer_id, product_name from cte where rnk = 1


-- 7. Which item was purchased just before the customer became a member?

with cte as(
select s.*, m.join_date, me.product_name,
rank() over(partition by s.customer_id order by order_date desc) as rnk
from members m join sales s on m.customer_id=s.customer_id
join menu me on me.product_id = s.product_id
where order_date < join_date)

select customer_id, product_name from cte where rnk = 1


-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(distinct me.product_name) as total_items, sum(me.price) as amount_spent
from members m join sales s on m.customer_id=s.customer_id
join menu me on me.product_id = s.product_id
where order_date < join_date
group by 1


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as(
select s.customer_id, me.product_name, sum(me.price) as tot,
case
	when product_name = 'sushi' then (20*sum(me.price))
	else (sum(me.price)*10)
	end as points
from sales s join menu me on me.product_id = s.product_id
group by 1,2
order by 1)

select customer_id, sum(points) as total_points from cte group by 1


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with cte as(
select s.customer_id, me.product_name,price,
case
	when (order_date >= join_date and order_date <= (join_date+7)) then (20*price)
	when product_name = 'sushi' then (20*price)
	else (price*10)
	end as points
from sales s join menu me on me.product_id = s.product_id
join members m on m.customer_id=s.customer_id
where order_date < '2021-02-01')

select customer_id, sum(points) as total_points from cte group by 1



-- BONUS QUESTIONS

-- JOIN ALL THE THINGS

select s.customer_id, order_date, product_name, price,
case 
	when (order_date >= join_date) then 'Y'
	else 'N'
	end as member
from sales s left join members m on m.customer_id=s.customer_id
join menu me on me.product_id=s.product_id
order by 1,2, 4 desc


-- RANK ALL THE THINGS

with cte as(
select s.customer_id, order_date, product_name, price,
case 
	when (order_date >= join_date) then 'Y'
	else 'N'
end as member
from sales s left join members m on m.customer_id=s.customer_id
join menu me on me.product_id=s.product_id
order by 1,2, 4 desc)


select *,
case 
	when member = 'Y' then rank() over(partition by customer_id,member order by order_date)
	else Null
end as ranking
from cte 


