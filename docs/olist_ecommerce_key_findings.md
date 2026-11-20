# Olist E-Commerce SQL Analysis

## Key Findings and Business Insights

### 1. Project overview

This project uses PostgreSQL to analyse the Olist Brazilian e-commerce
public dataset. The analysis covers orders, customers, product
categories, sellers, delivery performance, customer reviews, and monthly
revenue.

### 2. Business overview

  Metric                                                   Result
  -------------------------------------------- ------------------
  Total orders                                             99,441
  Unique customers                                         96,096
  Product revenue (`SUM(order_items.price)`)     R\$13,591,643.70
  Reported average order value (AOV)                    R\$137.50
  Repeat customers                                          2,997
  Repeat-customer rate                                      3.11%

Product revenue is calculated from item prices and excludes freight. The
AOV is the value reported from the analysis; its precise calculation
basis should be confirmed before directly comparing it with product
revenue divided by order count.

### 3. Order analysis

#### Order status distribution

  Status           Share
  ------------- --------
  Delivered       97.02%
  Shipped          1.11%
  Cancelled        0.63%
  Unavailable      0.61%
  Invoiced         0.32%
  Processing       0.30%
  Created          0.01%
  Approved         0.00%

Delivered orders account for 97.02% of all orders. Cancelled and
unavailable orders together account for 1.24%. Percentages are rounded
to two decimal places.

The monthly order query returned 25 months, from September 2016 through
October 2018. The supplied screenshots did not show every monthly count,
so no single peak month is asserted here.

### 4. Customer analysis

The analysis identified 2,997 repeat customers among 96,096 unique
customers, giving a reported repeat-customer rate of 3.11%. This
suggests that repeat purchasing is relatively uncommon in the observed
dataset and merits further investigation.

The analysis reported:

  Customer group         Average order value
  -------------------- ---------------------
  Repeat customers                 R\$123.90
  One-time customers               R\$138.60

It also reported revenue per customer of R\$259.861 for repeat customers
and R\$137.626 for one-time customers. Thus, repeat customers had a
lower average spend per order but higher total revenue per customer in
the reported analysis.

`customer_unique_id` is used as the person-level identifier for
repeat-customer analysis; `customer_id` identifies the customer record
associated with an order.

### 5. Product and category analysis

#### Top five categories by product revenue

    Rank Category                       Revenue (BRL)
  ------ -------------------------- -----------------
       1 `beleza_saude`               R\$1,258,681.34
       2 `relogios_presentes`         R\$1,205,005.68
       3 `cama_mesa_banho`            R\$1,036,988.68
       4 `esporte_lazer`                R\$988,048.97
       5 `informatica_acessorios`       R\$911,954.32

`beleza_saude` generated the highest product revenue among the
categories shown. `cama_mesa_banho` had the highest number of distinct
orders, with 9,417. The difference demonstrates that the category with
the greatest order volume is not necessarily the category with the
greatest revenue.

Category names are retained in Portuguese as they appear in the source
data.

### 6. Seller analysis

#### Top five sellers by product revenue

    Rank Seller ID (abbreviated)     Revenue (BRL)
  ------ ------------------------- ---------------
       1 `4869f7a5...`               R\$229,472.63
       2 `53243585...`               R\$222,776.05
       3 `4a3ca931...`               R\$200,472.92
       4 `fa1c13f2...`               R\$194,042.03
       5 `7c67e144...`               R\$187,923.89

The seller with the highest number of orders was not the seller with the
highest revenue. The highest seller-level AOV returned was R\$6,729.00.
This unusually high value should be interpreted alongside that seller's
order count; a small number of high-value orders may influence the
average.

### 7. Delivery performance and customer satisfaction

  Metric                                                                              Result
  ------------------------------------------------------ -----------------------------------
  Late orders                                                                          7,827
  Late orders as a share of all orders                                                 7.87%
  Average delivery time                                    12 days, 13 hours (approximately)
  Average review score --- late deliveries                                          2.56 / 5
  Average review score --- on-time or early deliveries                              4.29 / 5
  Overall average review score                                                      4.09 / 5

Late orders as a share of all orders is calculated as:

`7,827 / 99,441 × 100 = 7.87%`

This is not the late-delivery rate among delivered orders; that
calculation requires the exact delivered-order count.

The average review score for late deliveries was 1.73 points lower than
for on-time or early deliveries. This is an association in the observed
data, not proof that delivery delay alone caused lower scores. Product
quality, seller performance, and customer expectations may also affect
reviews.

#### Review-score distribution

    Review score   Share of reviews
  -------------- ------------------
               1             11.51%
               2              3.18%
               3              8.24%
               4             19.29%
               5             57.78%

More than half of the reviews were five-star reviews (57.78%), while
14.69% were one- or two-star reviews.

### 8. Monthly revenue analysis

Monthly product revenue was calculated by aggregating
`order_items.price` by `order_purchase_timestamp` month. `LAG()` was
used to retrieve the preceding month's revenue and calculate
month-over-month (MoM) growth.

Selected rows visible in the supplied query output:

| Month | Revenue (BRL) | Previous-month revenue (BRL) | MoM growth |
|---|---:|---:|---:|
| Sep 2016 | 267.36 | — | — |
| Oct 2016 | 49,507.66 | 267.36 | 18,417.23% |
| Dec 2016 | 10.90 | 49,507.66 | -99.98% |
| Jan 2017 | 120,312.87 | 10.90 | 1,103,687.80% |
| Feb 2017 | 247,303.02 | 120,312.87 | 105.55% |
| Mar 2017 | 374,344.30 | 247,303.02 | 51.37% |
| Apr 2017 | 359,927.23 | 374,344.30 | -3.85% |
| May 2017 | 506,071.14 | 359,927.23 | 40.60% |
| Feb 2018 | 844,178.71 | 950,030.36 | -11.14% |
| Mar 2018 | 983,213.44 | 844,178.71 | 16.47% |
| Apr 2018 | 996,647.75 | 983,213.44 | 1.37% |
| May 2018 | 996,517.68 | 996,647.75 | -0.01% |
| Jun 2018 | 865,124.31 | 996,517.68 | -13.19% |
| Jul 2018 | 895,507.22 | 865,124.31 | 3.51% |
| Aug 2018 | 854,686.33 | 895,507.22 | -4.56% |
| Sep 2018 | 145.00 | 854,686.33 | -99.98% |

The visible 2018 results show monthly revenue close to R\$1 million from
March through May, followed by lower values in June and August. Very
large growth rates in the early months result from very small
previous-month revenue bases. September 2018's R\$145.00 appears to be a
partial final month in the available data and should not be interpreted
as a full-month collapse.

The screenshot did not expose all 24 rows of the monthly revenue result;
the table above reproduces selected visible rows only.

### 9. Business implications

1.  **Customer retention:** The reported repeat-customer rate is 3.11%.
    Further analysis by acquisition cohort, state, and category could
    help identify where repeat purchasing is stronger or weaker.
2.  **Delivery reliability:** Late deliveries are associated with lower
    review scores. Investigate delays by seller, customer state,
    carrier, and estimated delivery window.
3.  **Category strategy:** Compare revenue, distinct order count, and
    average order value rather than relying on a single category
    ranking.
4.  **Seller monitoring:** Assess sellers using revenue, distinct
    orders, AOV, delivery performance, and review scores together.
5.  **Revenue monitoring:** Interpret monthly revenue and MoM growth
    with care when months are partial or the previous month's revenue is
    very small.

These are directions for further investigation, not guarantees that a
particular intervention will improve business performance.

### 10. Methodology and limitations

-   Analysis was performed in PostgreSQL using joins, CTEs,
    aggregations, subqueries, date functions, window functions, and
    conditional expressions.
-   Product revenue uses `SUM(order_items.price)` and excludes freight.
-   Payment value and item-price revenue are different measures. The
    reported AOV should be labelled with its exact calculation basis
    before publication.
-   Repeat customers are identified using `customer_unique_id`.
-   The late-order share of 7.87% uses all orders as the denominator;
    the delivered-order-only late rate was not supplied.
-   Review-score comparisons are descriptive and do not establish
    causation.
-   Monthly growth percentages can be volatile when the previous month
    has very low revenue.
-   The supplied monthly revenue screenshot did not show all 24 rows;
    only visible rows are reproduced.
-   Seller IDs are abbreviated in this document for readability.

### 11. Conclusion

The analysis covers 99,441 orders and 96,096 unique customers, with
97.02% of orders recorded as delivered. Product revenue based on item
prices was R\$13.59 million. The reported repeat-customer rate was
3.11%; repeat customers had lower average order value per order but
higher reported revenue per customer.

`beleza_saude` was the highest-revenue category in the supplied results,
while `cama_mesa_banho` had the most distinct orders. Seller rankings
showed that the highest order volume and highest revenue did not
necessarily belong to the same seller.

The clearest operational relationship in the supplied results was
between delivery timeliness and customer reviews: late deliveries
averaged 2.56, compared with 4.29 for on-time or early deliveries.
Delivery performance and customer retention therefore merit further
investigation.

Overall, this project demonstrates how SQL can transform relational
e-commerce data into business measures, comparisons, and questions for
further analysis.
