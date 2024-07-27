# Analysis-on-CLV-for-Nexasat-telecom
# Telecom Growth Strategies: Unlocking Customer Lifetime Value Through Smart Segmentation
Tools used: SQL server. 
## About the project
As a Data Analyst for NexaSat, I have been tasked with implementing Customer Lifetime Value (CLV) segmentation to drive strategic revenue growth through targeted up-selling and cross-selling initiatives. The purpose of this project is to enable stakeholders to identify high-opportunity customer segments, customize service offerings, and optimize marketing strategies.
## Project overview: 
The company has also identified an untapped potential within their existing customer base, recognizing that personalized offers and bundled services could significantly increase average revenue per user (ARPU). However, the challenge lies in identifying which customers are most receptive to these opportunities, as well as crafting offers that aligns with their preferences and usage patterns. 
## About the datasets
The data consists of 7,403 rows and 14 columns which include the gender, marital status, monthly amount of bill, data usage, identity of customer (senior citizen), plan type and the churn rate of the customers in NexaSat. 
## Data cleaning and transformation: 
The dataset was already cleaned, no null values or duplicates found just little adjustment after detecting outliers from the monthly bill amount and data usage columns.
## Encounter outliers:
The outliers were detected using the +3 or -3 with the standard deviation (STDEV) function using the SQL server.  12 rows were detected and were transformed. The transformed outliers were inputted into a new table using the ‘CREATE VIEW’ alongside other columns. 
## Analysis: 
The following are the insights generated from the reports
Key performance indicators (KPI):
•	Total customers: 7,043
•	Total male customers: 3,555
•	Total female customers: 3,488
•	Prepaid customers: 2,940
•	Postpaid customers: 4,103
•	Average monthly bill amount: $149.77
•	Average data usage: 8.8GB
•	Average call duration: 240 seconds 
•	Average tenure month: 24

![](nexasat 1.Png) 

