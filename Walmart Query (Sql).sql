--Walmart Business Problems


-- 1. Analyze Payment Methods and Sales--

-- ● Question: What are the different payment methods, and how many transactions and
--      items were sold with each method?
-- ● Purpose: This helps understand customer preferences for payment methods, aiding in
--    payment optimization strategies.

select 
payment_method,
COUNT(*) no_payment,
round(SUM(quantity),2) total_quantity
from Walmart
group by payment_method

--  2. Identify the Highest-Rated Category in Each Branch

--  ● Question: Which category received the highest average rating in each branch?
--  ● Purpose: This allows Walmart to recognize and promote popular categories in specific
--      branches, enhancing customer satisfaction and branch-specific marketing.

select 
    Branch,
	category,
	round(AVG(rating),1) avg_rating
	from Walmart
	group by Branch,category
	order by Branch,round(AVG(rating),1) desc


--  3. Determine the Busiest Day for Each Branch
--   ● Question: What is the busiest day of the week for each branch based on transaction volume?
--  ● Purpose: This insight helps in optimizing staffing and inventory management to accommodate peak days.


select*from( 
select Branch,
cast(datename(WEEKDAY,date) AS varchar) days,
COUNT(*) no_transitions,
RANK() over(partition by Branch order by COUNT(*) desc) ranking
from Walmart
group by Branch,datename(WEEKDAY,date)) t
where ranking=1

--    4. Calculate Total Quantity Sold by Payment Method
--    ● Question: How many items were sold through each payment method?
--    ● Purpose: This helps Walmart track sales volume by payment type, providing insights into customer purchasing habits.

select 
payment_method,
cast(round(SUM(quantity),2) AS int) total_quantity_sold
from walmart
group by payment_method


--  5. Analyze Category Ratings by City
--  ● Question: What are the average, minimum, and maximum ratings for each category in each city?
--  ● Purpose: This data can guide city-level promotions, allowing Walmart to address 
--     regional preferences and improve customer experiences.

select
City,
category,
round(AVG(rating),1) avg_ratings,
round(min(rating),1) min_rating,
round(MAX(rating),1) max_rating
from walmart
group by City,category
order by City asc

--  6. Calculate Total Profit by Category
--  ● Question: What is the total profit for each category, ranked from highest to lowest?
--  ● Purpose: Identifying high-profit categories helps focus efforts on expanding these
--     products or managing pricing strategies effectively.

select 
	category,
	round(SUM(quantity*unit_price),2) total_revenue,
	round(sum((quantity*unit_price)*profit_margin),2) total_profit
	from Walmart
	group by category
	order by round(sum((quantity*unit_price)*profit_margin),2) desc


-- 7. Determine the Most Common Payment Method per Branch
--    ● Question: What is the most frequently used payment method in each branch?
--   ● Purpose: This information aids in understanding branch-specific payment preferences,
--    potentially allowing branches to streamline their payment processing systems.

with common as 
(
	select 
	Branch,
	payment_method,
	COUNT(*) total_count,
	RANK() over(partition by Branch order by COUNT(*) desc) ranking 
	from walmart group by 
	Branch,payment_method 
)

select*from common
where ranking=1


-- 8. Analyze Sales Shifts Throughout the Day
--  ● Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
--  ● Purpose: This insight helps in managing staff shifts and stock replenishment schedules,
--        especially during high-sales periods.

with hours as 
(
	select
	Branch,
	datepart(HOUR,time) hour 
	from Walmart
),
shifts as 
(
select 
Branch,hour,
case
when hour<12 then 'Morning'
when hour between 12 and 17 then 'Evening'
else 'Night'
end Shift
from hours
)

select 
Branch,
Shift,COUNT(*) Transitions_By_Shifts
from shifts 
group by Branch,Shift


-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
--  ● Question: Which branches experienced the largest decrease in revenue compared to the previous year?
--  ● Purpose: Detecting branches with declining revenue is crucial for understanding
--       possible local issues and creating strategies to boost sales or mitigate losses.

select*from Walmart


WITH RevenueComparison AS (
    SELECT 
        Branch, 
        datepart(Year,date) year,
        round(SUM(unit_price*quantity),2) AS TotalRevenue,
        LAG(round(SUM(unit_price*quantity),2)) OVER (PARTITION BY Branch ORDER BY datepart(Year,date)) AS PreviousYearRevenue
    FROM Walmart
    GROUP BY Branch,datepart(Year,date)
)
SELECT 
    distinct Branch,
	year,
    TotalRevenue, 
    PreviousYearRevenue, 
    round((PreviousYearRevenue - TotalRevenue),2) AS RevenueDecrease
FROM RevenueComparison
WHERE PreviousYearRevenue IS NOT NULL 
order by  round((PreviousYearRevenue - TotalRevenue),2) desc


