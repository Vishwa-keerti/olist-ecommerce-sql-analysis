 # Brazilian E-Commerce Data Analysis | PostgreSQL

## Project Overview

This project analyses the **Brazilian E-Commerce Public Dataset by Olist** using PostgreSQL to uncover insights into customer purchasing behaviour, sales performance, product categories, seller performance, delivery efficiency, and customer satisfaction.

The objective was to use SQL to transform raw e-commerce data into meaningful business metrics and identify patterns that could support better business decisions.

## Dataset

- **Source:** [Brazilian E-Commerce Public Dataset – Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Total Orders:** 99,441
- **Unique Customers:** 96,096
- **Product Revenue:** R$13,591,643.70

The dataset contains relational tables covering customers, orders, order items, payments, reviews, products, sellers, and geolocation.

## Tools & Technologies

- PostgreSQL
- SQL
- Common Table Expressions (CTEs)
- Joins and Subqueries
- Aggregate Functions
- Window Functions
- Date and Time Functions
- Conditional Aggregation

## Analysis Performed

### 1. Order Analysis
- Annual and monthly order trends
- Order status distribution
- Cancelled and unavailable orders
- Average delivery time
- Late delivery analysis

### 2. Customer Analysis
- Unique customer identification
- Repeat customer analysis
- Customer purchase frequency
- Average order value
- Revenue per customer
- Customer distribution by state

### 3. Product & Category Analysis
- Revenue by product category
- Categories with the highest order volume
- Top-selling products
- Category-level performance

### 4. Seller Analysis
- Top sellers by revenue
- Seller order volume comparison
- Seller-level average order value
- Seller ranking within states

### 5. Customer Satisfaction & Delivery Analysis
- Average review score
- Review score distribution
- Late delivery vs. customer satisfaction
- Delivery time and review score relationship

### 6. Advanced SQL Analysis
- Customer purchasing behaviour
- Ranking using `DENSE_RANK()`
- Month-over-month revenue growth using `LAG()`
- Revenue and order comparisons using CTEs and window functions

## Key Findings

### Business Overview

| Metric | Result |
|---|---:|
| Total Orders | 99,441 |
| Unique Customers | 96,096 |
| Product Revenue | R$13.59 million |
| Product-based AOV | R$137.50 |
| Payment-based AOV | R$160.99 |
| Repeat Customers | 2,997 |
| Repeat Customer Rate | 3.11% |

### Order Performance
- 97.02% of orders were successfully delivered.
- Cancelled and unavailable orders together represented 1.24% of total orders.
- 7,827 orders were delivered late, representing 7.87% of all orders.

### Customer Behaviour
- Only 3.11% of unique customers placed more than one order.
- Repeat customers had a lower average order value per order (R$123.90) than one-time customers (R$138.60).
- Repeat customers generated higher reported revenue per customer (R$259.86 vs. R$137.63).

### Product Category Performance

The five highest-revenue categories were:

| Category | Revenue (BRL) |
|---|---:|
| beleza_saude | R$1,258,681.34 |
| relogios_presentes | R$1,205,005.68 |
| cama_mesa_banho | R$1,036,988.68 |
| esporte_lazer | R$988,048.97 |
| informatica_acessorios | R$911,954.32 |

The `cama_mesa_banho` category had the highest number of distinct orders, with 9,417 orders.

### Seller Performance
- The seller with the highest order volume was not the seller with the highest revenue.
- The highest seller-level AOV observed was R$6,729.00.

### Delivery & Customer Satisfaction
- Average delivery time was approximately 12 days and 13 hours.
- Average review score for late deliveries was 2.56/5.
- Average review score for on-time or early deliveries was 4.29/5.
- The overall average review score was 4.09/5.

Late deliveries were associated with substantially lower customer review scores.

## Repository Contents

| File | Description |
|---|---|
| [SQL Analysis](olist_ecommerce_sql_analysis_project.sql) | Complete organised SQL queries |
| [Key Findings](docs/olist_ecommerce_key_findings.md) | Detailed findings, business insights, methodology, and limitations |

## Dataset Access

[Download the original Olist dataset from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The raw dataset is not included in this repository.

## Methodology & Limitations

- Product revenue is calculated using `order_items.price` and excludes freight.
- Product-based AOV and payment-based AOV use different calculation bases.
- Repeat customers are identified using `customer_unique_id`.
- The late-order percentage uses all orders as its denominator.
- Relationships between delivery performance and review scores are observational and do not establish causation.
- Monthly revenue growth can be volatile when the previous month's revenue is very low or when a month contains incomplete data.

## Conclusion

This project demonstrates the application of PostgreSQL to real-world e-commerce data analysis. By combining customer, order, product, seller, payment, delivery, and review data, the analysis identifies important business patterns and potential areas for improvement in customer retention, sales performance, and delivery operations.

## Author

**Vishwa Keerti**

- GitHub: [Your GitHub Profile](https://github.com/Vishwa-keerti)
