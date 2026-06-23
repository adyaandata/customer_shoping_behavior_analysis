SELECT * FROM customer;

-- 1.Total revenue by gender
SELECT gender, SUM(purchase_amount) as revenue
FROM customer
GROUP BY gender;

-- 2.Customers who used discount but still spent more than the average purchase amount
SELECT customer_id, purchase_amount 
FROM customer
WHERE discount_applied = 'Yes' AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);

-- 3.Top 5 products with highest average review rating
SELECT item_purchased, ROUND(AVG(review_rating)::NUMERIC,2) AS avg_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY 2 DESC LIMIT 5;

-- 4.Avg purchase amount between Standard and Express Shipping
SELECT shipping_type, ROUND(AVG(purchase_amount),2) AS avg_purchase_amout
FROM customer
WHERE shipping_type IN ('Express', 'Standard')
GROUP BY shipping_type;

-- 5.Do subscribed customers spend more? Comparing average spend and total revenue between subscribers and non-subscribers
SELECT subscription_status, COUNT(customer_id) AS total_customers,
	   ROUND(SUM(purchase_amount),2) AS total_revenue, ROUND(AVG(purchase_amount),2) AS avg_spend
	   
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend DESC;

-- 6.Top 5 products with highest percentage of purchases with discounts applied
SELECT item_purchased, 
	   ROUND(100 * SUM(CASE WHEN discoUnt_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) , 2) AS discount_rate

FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC LIMIT 5;

-- 7.Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each segment
WITH customer_type AS(
	SELECT customer_id, previous_purchases, 
	CASE
		WHEN previous_purchases = 1 THEN 'New'
		WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
		ELSE 'Loyal'
		END AS customer_segment
FROM customer
)

SELECT customer_segment, COUNT(*) AS no_of_customers
FROM customer_type
GROUP BY customer_segment;

-- 8.Top 3 most purchased products within each category
SELECT category, item_purchased, total_purchasing
FROM (
SELECT category, item_purchased, COUNT(customer_id) AS total_purchasing,
	   RANK() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS rn
FROM customer
GROUP BY 1,2
)
WHERE rn <= 3;

-- 9.Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status, COUNT(customer_id)
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 10.Revenue Contribution by age group
SELECT age_group, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY age_group
ORDER BY revenue DESC;