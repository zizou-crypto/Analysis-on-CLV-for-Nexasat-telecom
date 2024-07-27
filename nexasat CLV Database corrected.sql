Create database telecomN

exec sp_rename	nexasat_data, nexasat

select * from nexasat 

--- checking for duplicates 
select customer_id, gender, partner, dependents, senior_citizen, call_duration,
data_usage, plan_type, plan_level, monthly_bill_amount, tenure_months, multiple_lines, 
tech_support, churn, count(*) 
from nexasat
group by customer_id, gender, partner, dependents, senior_citizen, call_duration,
data_usage, plan_type, plan_level, monthly_bill_amount, tenure_months, multiple_lines, 
tech_support, churn
having count(*) > 1

---checking for null values
select * from nexasat
where customer_id is null or 
gender is null or
partner is null or 
dependents is null or 
senior_citizen is null or 
call_duration is null or 
data_usage is null or 
plan_type is null or 
monthly_bill_amount is null or 
tenure_months is null or 
multiple_lines is null or 
tech_support is null or 
churn is null

---view table 
select * from nexasat 

---checking for outliers
select * from nexasat
where monthly_bill_amount > (select avg (monthly_bill_amount) + 3 * STDEV(monthly_bill_amount)  from nexasat)
or  monthly_bill_amount < (select avg (monthly_bill_amount) - 3 * STDEV(monthly_bill_amount)  from nexasat)

select * from nexasat 
where call_duration > (select avg(call_duration) + 3 * STDEV(call_duration) from nexasat) or
call_duration < (select avg(call_duration) - 3 * STDEV(call_duration) from nexasat) 

---average tenure months
select AVG(tenure_months) avg_month from nexasat 

--- avg call duration 
select AVG (call_duration) avg_duration from nexasat 

--- avg monthly bill
select round (AVG (monthly_bill_amount), 2) avg_bill from nexasat 

--average tenure by plan level
select plan_level, AVG(tenure_months) avg from nexasat 
group by plan_level

--- count of plan level
select plan_level, COUNT(*) count from nexasat 
group by plan_level 

--- number of active customers 
select count (customer_id) active_customers from nexasat 
where churn = 0 

---create table for existing users 
select * into new_nexasat 
from nexasat
where churn = 0

---view table 
select * from new_nexasat

---CALCULATE the existing ARPU 
SELECT ROUND (AVG(monthly_bill_amount), 2) ARPU FROM new_nexasat

--- Average month and bill for plan level
SELECT plan_level, AVG(tenure_months) avg_months,
round (AVG(monthly_bill_amount),2) avg_bill FROM new_nexasat
group by plan_level 

--- Customers with multiple lines with their level
select COUNT(customer_id) count, plan_level from new_nexasat
where multiple_lines = 1
group by plan_level 

--- plan type with most revenue 
select plan_type, round (SUM (monthly_bill_amount), 2) revenue from new_nexasat
group by plan_type 
order by revenue desc

--- calculate CLV 
ALTER TABLE New_nexasat
add clv float 

update new_nexasat
set clv = monthly_bill_amount * tenure_months 

--- add clv score to nexasat table: 0.4 = Monthlybillamount, 0.1 = datausage, duration = 0.1, tenure = 0.3, premium = 0.1 
alter table new_nexasat
add clv_score numeric (10,2)

update new_nexasat
set clv_score = (0.4 * monthly_bill_amount) + 
                         (0.1 * data_usage) + (0.3 * tenure_months) +
						 (0.1 * case when plan_level = 'premium' then 1 else 0 end) 

---view table 
select * from new_nexasat

---group clv score into segment 
alter table new_nexasat
add clv_segment1 varchar (50)

update new_nexasat
set clv_segment1 = case when clv_score > 80 then 'High value customers'
                       when clv_score between 50 and 79 then 'Medium value customers'
					   when clv_score between 20 and 49 then 'low value customers'
					   else 'churn risk' 
					   end

--- view plantype and clv segment
select plan_type, clv_segment1, COUNT(*) count from new_nexasat
group  by plan_type, clv_segment1
order by count desc

--- number of dependents customers on each segments
select clv_segment1, dependents, COUNT(*) count from new_nexasat
where dependents = 1 
group by clv_segment1, dependents 
order by count desc

--- segment with most bill monthly
select clv_segment1, round (SUM (monthly_bill_amount), 1) revenue,  multiple_lines 
from new_nexasat
where multiple_lines = 1
group by clV_segment1, multiple_lines

--- count of segment 
select clv_segment1, count(*) from new_nexasat
group by clv_segment1

--- avg bill and tenure
select clv_segment1, round (AVG(monthly_bill_amount), 2) avgbill, AVG (tenure_months) avgtenure
from new_nexasat
group by clv_segment1

select clv_segment1, round (avg (case when tech_support = 1 then 1 else 0 end), 2) percentcount,  
                     cast (avg (case when multiple_lines = 1 then 1 else 0 end) as decimal (15,2)) 
from new_nexasat
group by clv_segment1 

---clv with most revenue 
select clv_segment1,
       cast (SUM (monthly_bill_amount * tenure_months) as numeric(10,2)) revenue 
from new_nexasat
group by clv_segment1 

--- cross selling: customers, tech support to senior citizens and dependents
select customer_id 
from new_nexasat
where senior_citizen = 1 and 
dependents = 0 and 
tech_support = 0 and 
(clv_segment1 = 'churn risk' or
clv_segment1 = 'low vaue customer')

---cross selling for multiple lines to partners with dependents(children) on basic level
select customer_id from new_nexasat
where partner = 1 
and dependents = 1
and multiple_lines = 0
and plan_level = 'basic'

---cross selling : from low to medium value customers on prepaid
select * from new_nexasat

select customer_id from new_nexasat
where senior_citizen = 0 
and plan_type = 'prepaid' 
and clv_segment1 = 'low value customers' 

---
select gender, clv_segment1, count(*) count_customers from new_nexasat
where partner = 1
and dependents = 1
group by gender, clv_segment1 

---up selling high clv customers from basic to premium
select customer_id 
from new_nexasat
where clv_segment1 = 'high value customers' and
plan_level = 'basic'

---ARPU 
SELECT SUM(Monthly_bill_amount)/COUNT(*) ARPU from new_nexasat