
Select * from members;
Select * from sales;
Select * from menu;

--1. What is the total amount each customer spent at the restaurant?
Select s.customer_id, sum(m.price) as total_spent
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id


-- 2. How many days has each customer visited the restaurant?
select customer_id, COUNT(distinct order_date) as Days_visited
from sales 
group by customer_id
order by Days_visited desc




-- 3. What was the first item from the menu purchased by each customer?
with customer_first_purchase as 
	(select s.customer_id,MIN(s.order_date) as first_purchase
	from  sales s
	group by s.customer_id)
select cfp.customer_id,cfp.first_purchase,m.product_name
from customer_first_purchase cfp
join sales s on s.customer_id = cfp.customer_id
And cfp.first_purchase = s.order_date
Join menu m on m.product_id = s.product_id




-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
	
Select m.product_name , COUNT(*) as total_purchased
from sales s
join menu m on m.product_id = s.product_id
group by m.product_name
order by total_purchased desc;
-- most purchased was ramen


-- 5. Which item was the most popular for each customer?
select s.customer_id, m.product_name, count(*) as Purchase_count
from sales s 
join menu m on s.product_id = m.product_id
group by s.customer_id,m.product_name
order by s.customer_id Asc, Purchase_count DESC

-- or instead of adding order by I can add a window function
-- ROW_NUMBER() over( partition by s.customer_id order by count(*) desc) as rank



-- 6. Which item was purchased first by the customer after they became a member?
with first_purchase as 
	(Select s.customer_id, MIN(s.order_date) as First_Purchase
	from sales s
	join members mb on s.customer_id = mb.customer_id
	where s.order_date >= mb.join_date
	group by s.customer_id)
Select fp.customer_id, fp.First_Purchase, m.product_name
from first_purchase fp
join sales s on s.customer_id = fp.customer_id
and s.order_date = fp.First_Purchase
join menu m on m.product_id = s.product_id


-- 7. Which item was purchased just before the customer became a member?
with final_purchase as (
	select s.customer_id, max(s.order_date) as last_purchase
	from sales s
	join members mb on mb.customer_id = s.customer_id
	where s.order_date< mb.join_date
	group by s.customer_id)
select fin.customer_id, fin.last_purchase,m.product_name
from final_purchase fin
join sales s on fin.customer_id = s.customer_id
and s.order_date = fin.last_purchase
join menu m on s.product_id = m.product_id

-- 8. What is the total items and amount spent for each member before they became a member?
Select s.customer_id, count(*) as total_items, sum(m.price) as total_spent
from sales s
join menu m on m.product_id = s.product_id
join members mb on mb.customer_id = s.customer_id
where s.order_date < mb.join_date
group by s.customer_id


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Select s.customer_id, sum(
	case 
		when m.product_name ='sushi' then m.price *20
		else m.price * 10 end ) as total_points
From sales s 
join menu m on s.product_id = m.product_id
group by customer_id

