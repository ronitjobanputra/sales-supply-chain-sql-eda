# Sales & Supply Chain SQL Exploratory Data Analysis

# Sales & Supply Chain SQL Exploratory Data Analysis

> **End-to-end SQL analysis of sales performance, customer behavior, delivery reliability, and supply-chain operations.**

## Project Overview

This project analyzes a relational sales and supply-chain dataset using **MySQL** to turn transactional data into business and operational insights.

The analysis connects **orders, customers, products, order items, and shipments** to investigate both commercial performance and supply-chain execution.

### Key Areas Analyzed

- 📊 Sales and revenue performance
- 📦 Product and category performance
- 👥 Customer value and purchasing behavior
- 🛒 Sales-channel performance
- 🚚 Shipment and delivery performance
- ⚠️ Delivery delays and delay rates
- 🌍 Regional performance
- 🏢 Customer-type performance
- 💰 Transportation costs and shipment size

### SQL Techniques

`JOIN` • `GROUP BY` • `CASE WHEN` • `CTEs` • `Subqueries` • `Window Functions` • `ROW_NUMBER()` • `COUNT()` • `SUM()` • `AVG()` • `Date Functions`

### Project Deliverables

📄 **[Visual Case Study Report](sales_supply_chain_eda_visual_case_study.pdf)**  
💻 **[SQL Analysis](sales_supply_chain_eda.sql)**

---

## Business Questions

The analysis investigates questions such as:

1. How reliable and clean is the underlying sales data?
2. Which products generate the most revenue and volume?
3. Which customers generate the most revenue and highest average order values?
4. How do sales channels compare in revenue and average order value?
5. What does the order and shipment status distribution look like?
6. Which customers, sales channels, product categories, regions, and customer types experience the highest delivery delay rates?
7. How does transportation cost vary with shipment size?
8. What operational patterns could be relevant to supply-chain decision making?

---

## Dataset Structure

The analysis works across several related tables.

### Orders
**`ssales_order2`**

Contains order-level information including:

- `order_id`
- `customer_id`
- `order_date`
- `requested_delivery_date`
- `order_status`
- `sales_channel`

### Customers
**`customers`**

Contains customer information including:

- `customer_id`
- `customer_name`
- `customer_type`
- `city`
- `region`

### Products
**`products`**

Contains product information including:

- `product_id`
- `product_name`
- `category`

### Sales Order Items
**`sales_order_items`**

Contains order-line information including:

- `order_item_id`
- `order_id`
- `product_id`
- `quantity_ordered_cases`
- `total_amount`

### Shipments
**`shipments`**

Contains logistics information including:

- `shipment_id`
- `order_id`
- `shipment_date`
- `delivery_date`
- `quantity_shipped_cases`
- `delivery_status`
- `transportation_cost`

---

## Data Cleaning & Preparation

Before performing the main analysis, the SQL workflow included several data-quality checks.

### Duplicate Records

Duplicate order records were investigated using grouped duplicate checks and `ROW_NUMBER()`.

A cleaned order table, `ssales_order2`, was created and duplicate rows were identified and removed using the generated row number.

### Missing Values

The analysis checked for NULL values across important order fields, including:

- Order ID
- Customer ID
- Order date
- Requested delivery date
- Order status
- Sales channel

### Referential Integrity

Orders were checked to determine whether their customer IDs existed in the customer table.

### Date Validation

Orders were also checked for cases where the order date occurred after the requested delivery date.

### Column Name Cleanup

Some imported column names contained encoding artifacts such as `ï»¿`. These were renamed to clean field names before analysis.

---

## SQL Analysis

The final SQL script is organized into the following analytical stages.

### 1. Initial Inspection & Duplicate Checks

The project begins by examining the raw orders table and identifying duplicate records.

### 2. Data Cleaning & Deduplication

Duplicate orders, NULL values, invalid relationships, and date inconsistencies are investigated and addressed.

### 3. Schema Checks & Column Name Cleanup

Table structures and imported column names are checked and standardized.

### 4. Dataset Overview & Basic EDA

The analysis establishes the overall scale of the dataset and examines basic order patterns.

### 5. Monthly Sales & Revenue

Orders and revenue are analyzed over time, including revenue per order.

### 6. Product Performance

Products are evaluated based on:

- Number of orders
- Cases sold
- Revenue
- Revenue per case
- Product category

Lower-performing products were also investigated further rather than simply being ranked.

### 7. Customer Performance

Customers are evaluated using:

- Number of orders
- Total revenue
- Average order value

This identifies high-value customers as well as differences in purchasing behavior.

### 8. Sales Channel Analysis

Sales channels are compared using:

- Order count
- Total revenue
- Average order value

The analysis also checks order status in relation to sales activity.

### 9. Shipment & Delivery Performance

Shipment data is used to examine:

- Delivery status
- Delayed orders
- Delivery performance by customer
- Average delivery-date difference
- Delay rates

### 10. Delay Analysis

Delivery delays are examined across several dimensions:

- Sales channel
- Product category
- Customer
- Region
- Customer type

This moves the analysis from simply measuring delays to identifying where operational problems are concentrated.

### 11. Regional Analysis

Regions are compared based on:

- Order volume
- Revenue
- Delivery delay rate

### 12. Customer Type Analysis

Customer types are evaluated based on:

- Order count
- Revenue
- Average order value
- Delay rate

### 13. Transportation Cost & Shipment Size

The final analysis examines transportation costs and shipment quantities, including shipment-size groups:

- 1–5 cases
- 6–10 cases
- 11–15 cases
- 16–20 cases
- 21+ cases

This helps assess how logistics costs change as shipment size increases.

---

## Key Findings

The analysis produced several notable findings.

### Product Performance

The strongest-performing products by revenue were concentrated among the larger Hiphop and Fleetos products, while products P012–P015 showed substantially lower revenue and were investigated separately.

The product-category analysis also showed that **Potato Crisps** represented the largest order volume among the analyzed categories.

### Customer Performance

Customer revenue varied substantially across the customer base.

The customer analysis also showed that average order value did not necessarily follow total revenue: customers with fewer orders could still generate a high average value per order.

For example, **Nile View Restaurant** had the highest average order value among the customer results analyzed.

### Sales Channels

The three main sales channels were:

- Direct Sales
- Wholesale
- Distributor

Wholesale produced the highest average order value among the three main channels, while Direct Sales had the largest order volume.

### Delivery Performance

Shipment-level analysis identified three delivery outcomes:

- Delayed
- Delivered
- Partial

Delayed shipments represented the largest category in the shipment-status result used for the analysis.

### Delay Rates

Delivery reliability varied considerably across different dimensions.

The analysis found meaningful differences in delay rates by:

- Customer
- Sales channel
- Product category
- Region
- Customer type

For example, the regional analysis showed Western having the highest delay rate among the four regions analyzed, while Eastern had the largest order volume.

### Customer Type

Average order value varied significantly by customer type.

Restaurants and Cafes showed higher average order values than several other customer types, while Supermarkets generated the highest total revenue among the customer-type results.

### Transportation Cost

Transportation cost increased with shipment size.

The shipment-size analysis showed the following average transportation costs:

| Shipment Size | Average Transportation Cost |
|---|---:|
| 1–5 | 30,428 |
| 6–10 | 36,500 |
| 11–15 | 43,347.27 |
| 16–20 | 50,506.67 |
| 21+ | 62,647.62 |

This indicates a clear positive relationship between shipment quantity and total transportation cost.

---

## Business Insights

The analysis suggests several areas that could be relevant to management.

### 1. Investigate high-delay segments

Delay rates differ significantly by region, customer type, sales channel, product category, and customer.

Management could prioritize the highest-delay segments for operational investigation rather than applying the same intervention across the entire network.

### 2. Focus on high-value customers

Customers with high average order values may warrant differentiated account-management and service strategies.

### 3. Review lower-performing products

The lower-revenue products should be evaluated for demand, pricing, distribution, or product-level factors before making decisions about inventory or product strategy.

### 4. Consider shipment-size economics

Transportation costs rise as shipment size increases. This creates an opportunity to investigate whether shipment consolidation, route optimization, or different shipment frequencies could improve logistics efficiency.

### 5. Connect sales and operations

The analysis demonstrates why sales performance should not be evaluated independently from delivery performance.

A sales channel or customer can generate strong revenue while simultaneously presenting operational challenges through higher delay rates.

---

## SQL Skills Demonstrated

This project demonstrates practical use of:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `ORDER BY`
- `HAVING`
- `COUNT()`
- `COUNT(DISTINCT ...)`
- `SUM()`
- `AVG()`
- `ROUND()`
- `CASE WHEN`
- `JOIN`
- `LEFT JOIN`
- Subqueries
- Common Table Expressions (CTEs)
- Window functions
- `ROW_NUMBER()`
- Date functions
- `DATEDIFF()`
- `DATE_FORMAT()`
- `STR_TO_DATE()`
- `CREATE TABLE`
- `INSERT INTO`
- `DELETE`
- `ALTER TABLE`

The project particularly demonstrates the ability to connect multiple relational tables and use SQL to move from raw transactional data to business-oriented insights.

---

## Project Workflow

The analytical workflow can be summarized as:

**Raw Data → Data Quality Checks → Cleaning → Relational Joins → Exploratory Analysis → Operational Analysis → Business Insights**

The project intentionally progresses from basic data validation toward more meaningful business questions rather than jumping directly into summary statistics.

---

## Files

### `sales_supply_chain_eda.sql`

Contains the organized SQL analysis, from initial inspection and data cleaning through sales, customer, product, delivery, regional, and transportation analysis.

### `sales_supply_chain_eda_report.pdf`

Contains the portfolio-friendly written report and key findings from the analysis.

### `data/`

Contains the source dataset files where appropriate.

---

## Conclusion

This project demonstrates how SQL can be used not only to query individual tables, but to combine related sales and supply-chain data into a structured analytical workflow.

The analysis connects **commercial performance** with **operational performance**, allowing revenue, customers, products, sales channels, deliveries, regions, and transportation costs to be evaluated together.

The most important takeaway is that strong sales performance does not automatically mean strong operational performance. The differences in delay rates across customers, channels, regions, product categories, and customer types highlight opportunities for more targeted supply-chain improvements.
