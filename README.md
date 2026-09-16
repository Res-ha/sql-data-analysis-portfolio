# SQL Data Analysis Portfolio

A curated collection of SQL projects covering customer analytics, retail performance, e-commerce transactions, and core aggregation techniques. The projects were completed as part of DQLab learning challenges and organized for portfolio review.

## Projects

| No. | Project | Focus | Main tools |
| --- | --- | --- | --- |
| 01 | [Fundamental SQL: GROUP BY and HAVING](01-fundamental-sql-group-by-and-having/) | Aggregation, filtering groups, customer subscriptions | MySQL, MariaDB |
| 02 | [Data Engineer Challenge with SQL](02-data-engineer-challenge-with-sql/) | Product and transaction analysis | SQL, MySQL |
| 03 | [Retail Sales Performance](03-retail-sales-performance/) | Revenue, promotion effectiveness, order status | SQL, MySQL |
| 04 | [B2B Retail Customer Analytics](04-b2b-retail-customer-analytics/) | Quarterly sales, customer acquisition, customer segmentation | SQL, MySQL, MariaDB |
| 05 | [E-Commerce Data Analysis](05-ecommerce-data-analysis/) | Buyer behavior, seller analysis, product performance, payment duration | SQL, DuckDB, Python, Colab |

## Repository Structure

Each project folder contains the SQL source, concise project documentation, and the associated completion certificate. The e-commerce project also includes its notebook and CSV datasets so the analysis can be reproduced locally.

```text
sql-data-analysis-portfolio/
├── 01-fundamental-sql-group-by-and-having/
├── 02-data-engineer-challenge-with-sql/
├── 03-retail-sales-performance/
├── 04-b2b-retail-customer-analytics/
└── 05-ecommerce-data-analysis/
    └── data/
```

## How to Use

1. Open the project folder you want to review.
2. Read its `README.md` and documentation file for context.
3. Prepare the tables referenced in the SQL header.
4. Run each query separately in a compatible SQL environment.

For the e-commerce notebook, upload the four CSV files from its `data/` directory to Google Drive or adjust the notebook paths to your local environment.

## Notes

- SQL files are read-only analysis scripts; they do not modify source data.
- The e-commerce CSV files use semicolons (`;`) as delimiters.
- Values such as `NA` in date columns may need to be converted to `NULL` during import.
- Query logic is preserved from the learning projects, with formatting and documentation standardized for readability.

## Author

**Resha Ananda Rahman**  
[GitHub](https://github.com/Res-ha)
