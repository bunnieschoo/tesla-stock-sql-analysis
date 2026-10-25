# Tesla Stock Price Analysis with SQL

## Project Overview

This project analyses Tesla's historical stock-price data using PostgreSQL and SQL. The aim is to practise financial data analysis, data cleaning, window functions, and descriptive statistics.

The analysis examines daily price movements, historical volatility, price ranges, and yearly performance.

## Dataset

* **Company:** Tesla, Inc.
* **Source:** [Tesla Stock Price — Kaggle](https://www.kaggle.com/datasets/jillanisofttech/tesla-stock-price)
* **Period:** 2 January 2015 – 16 January 2024
* **Observations:** 2,274 rows
* **Frequency:** Daily trading observations
* **Tools:** PostgreSQL, SQL, VS Code

The dataset includes trading dates, opening prices, daily highs and lows, closing prices, and trading volume.

## Tools and Techniques

* PostgreSQL for data storage and analysis
* SQL filtering, aggregation, and subqueries
* `LAG()` and window functions to calculate price returns
* `STDDEV()` to measure historical volatility
* `SQRT()` to annualise daily volatility
* Common table expressions (CTEs) to organise multi-step queries
* Data-quality checks for missing values and duplicate trading dates

## Data Preparation and Quality Checks

The raw CSV data was imported into a staging table before being converted into a structured table with date, numeric price, and trading-volume data types.

The analysis included checks for:

* Missing values in key columns
* Duplicate trading dates
* The dataset's date range and row count

The cleaned table contains 2,274 rows, with no missing values in the checked columns and no duplicate trading dates detected.

## Analysis and Preliminary Findings

### Daily Returns

Daily percentage returns were calculated using consecutive closing prices and the SQL `LAG()` window function.

* Average daily return: **0.1822%**

### Historical Volatility

Volatility was measured using the sample standard deviation of daily percentage returns.

* Daily volatility: **3.5498%**
* Annualised volatility estimate: **56.3514%**

Annualised volatility was estimated by multiplying daily volatility by the square root of 252 trading days.

### Price Range

* Highest recorded closing price: **$409.97**, on 4 November 2021
* Lowest recorded closing price: **$9.58**, on 10 February 2016

### Overall Recorded Price Change

The recorded closing price increased by **1,404.10%** between the first and last observations in the dataset.

This is a price-change calculation, not a verified total investment return.

### Yearly Performance

Yearly price movements were calculated by comparing closing prices within each calendar year. A separate query calculates calendar-year price returns using the previous year's closing price where available.

The 2024 data covers only part of January and should not be interpreted as a full-year result.

## Limitations

* The dataset's historical price-adjustment methodology has not been definitively confirmed from the source documentation.
* Tesla has had stock splits during the period studied. Price returns and volatility should therefore be treated as preliminary until consistent split adjustment is confirmed.
* Price changes exclude dividends, transaction costs, and taxes.
* Historical volatility describes past price fluctuations and does not predict future volatility.
* The dataset ends on 16 January 2024, so it does not represent Tesla's current performance.

## Conclusion

This project demonstrates how SQL can be used to prepare financial data, calculate returns and volatility, and investigate historical stock-price movements.

It also highlights the importance of data quality, consistent price adjustments, and careful interpretation when analysing financial markets.
