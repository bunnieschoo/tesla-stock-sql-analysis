-- 1. Preview the cleaned Tesla stock data
SELECT *
FROM public.tesla_stock_prices
ORDER BY trade_date
LIMIT 10;
-- 2. Calculate average daily return (%)
SELECT
    ROUND(AVG(daily_return), 4) AS avg_daily_return_pct
FROM (
    SELECT
        (
            close_price
            / LAG(close_price) OVER (ORDER BY trade_date)
            - 1
        ) * 100 AS daily_return
    FROM public.tesla_stock_prices
) AS daily_returns;
-- 3. Calculate daily volatility (%)
SELECT
    ROUND(STDDEV(daily_return), 4) AS daily_volatility_pct
FROM (
    SELECT
        (
            close_price
            / LAG(close_price) OVER (ORDER BY trade_date)
            - 1
        ) * 100 AS daily_return
    FROM public.tesla_stock_prices
) AS daily_returns;
-- 4. Calculate annualised volatility (%)
SELECT
    ROUND(
        (STDDEV(daily_return) * SQRT(252))::NUMERIC,
        4
    ) AS annualised_volatility_pct
FROM (
    SELECT
        (
            close_price
            / LAG(close_price) OVER (ORDER BY trade_date)
            - 1
        ) * 100 AS daily_return
    FROM public.tesla_stock_prices
) AS daily_returns;
-- 5. Find the highest and lowest closing prices
SELECT
    MAX(close_price) AS highest_close,
    MIN(close_price) AS lowest_close
FROM public.tesla_stock_prices;
-- 6. Find the dates of the highest and lowest closing prices
SELECT
    trade_date,
    close_price
FROM public.tesla_stock_prices
WHERE close_price = (
    SELECT MAX(close_price)
    FROM public.tesla_stock_prices
)
OR close_price = (
    SELECT MIN(close_price)
    FROM public.tesla_stock_prices
)
ORDER BY close_price DESC;
-- 7. Check the date range of the dataset
SELECT
    MIN(trade_date) AS first_date,
    MAX(trade_date) AS last_date,
    COUNT(*) AS total_rows
FROM public.tesla_stock_prices;
-- 8. Check for duplicate trading dates
SELECT
    trade_date,
    COUNT(*) AS rows_per_date
FROM public.tesla_stock_prices
GROUP BY trade_date
HAVING COUNT(*) > 1
ORDER BY trade_date;
-- 9. Check for missing values
SELECT
    COUNT(*) FILTER (WHERE trade_date IS NULL) AS missing_dates,
    COUNT(*) FILTER (WHERE close_price IS NULL) AS missing_closes,
    COUNT(*) FILTER (WHERE open_price IS NULL) AS missing_opens,
    COUNT(*) FILTER (WHERE high_price IS NULL) AS missing_highs,
    COUNT(*) FILTER (WHERE low_price IS NULL) AS missing_lows,
    COUNT(*) FILTER (WHERE trading_volume IS NULL) AS missing_volumes
FROM public.tesla_stock_prices;
-- 10. Inspect the earliest and latest stock prices
SELECT
    trade_date,
    open_price,
    high_price,
    low_price,
    close_price,
    trading_volume
FROM public.tesla_stock_prices
ORDER BY trade_date
LIMIT 5;
-- 11. Inspect prices around Tesla's stock splits
SELECT
    trade_date,
    close_price
FROM public.tesla_stock_prices
WHERE trade_date BETWEEN DATE '2020-08-25' AND DATE '2020-09-04'
   OR trade_date BETWEEN DATE '2022-08-19' AND DATE '2022-08-31'
ORDER BY trade_date;
-- 12. Calculate the percentage change in closing price
-- across the dataset
SELECT
    (SELECT trade_date
     FROM public.tesla_stock_prices
     ORDER BY trade_date
     LIMIT 1) AS first_date,

    (SELECT close_price
     FROM public.tesla_stock_prices
     ORDER BY trade_date
     LIMIT 1) AS first_close,

    (SELECT trade_date
     FROM public.tesla_stock_prices
     ORDER BY trade_date DESC
     LIMIT 1) AS last_date,

    (SELECT close_price
     FROM public.tesla_stock_prices
     ORDER BY trade_date DESC
     LIMIT 1) AS last_close,

    ROUND(
        (
            (SELECT close_price
             FROM public.tesla_stock_prices
             ORDER BY trade_date DESC
             LIMIT 1)
            /
            (SELECT close_price
             FROM public.tesla_stock_prices
             ORDER BY trade_date
             LIMIT 1)
            - 1
        ) * 100,
        2
    ) AS price_change_pct;
    -- 13. Calculate year-by-year price changes
WITH yearly_prices AS (
    SELECT
        EXTRACT(YEAR FROM trade_date) AS year,
        FIRST_VALUE(close_price) OVER (
            PARTITION BY EXTRACT(YEAR FROM trade_date)
            ORDER BY trade_date
        ) AS first_close,
        FIRST_VALUE(close_price) OVER (
            PARTITION BY EXTRACT(YEAR FROM trade_date)
            ORDER BY trade_date DESC
        ) AS last_close
    FROM public.tesla_stock_prices
)
SELECT DISTINCT
    year,
    ROUND(first_close, 2) AS first_close,
    ROUND(last_close, 2) AS last_close,
    ROUND(
        ((last_close / first_close) - 1) * 100,
        2
    ) AS yearly_price_change_pct
FROM yearly_prices
ORDER BY year;
-- 14. Verify first and last trading dates for each year
SELECT
    EXTRACT(YEAR FROM trade_date)::INT AS year,
    MIN(trade_date) AS first_trading_date,
    MAX(trade_date) AS last_trading_date,
    COUNT(*) AS trading_days
FROM public.tesla_stock_prices
GROUP BY EXTRACT(YEAR FROM trade_date)
ORDER BY year;
-- 15. Calculate calendar-year price returns
WITH year_end_prices AS (
    SELECT DISTINCT ON (EXTRACT(YEAR FROM trade_date))
        EXTRACT(YEAR FROM trade_date)::INT AS year,
        trade_date AS year_end_date,
        close_price AS year_end_close
    FROM public.tesla_stock_prices
    ORDER BY EXTRACT(YEAR FROM trade_date), trade_date DESC
),
yearly_returns AS (
    SELECT
        year,
        year_end_date,
        year_end_close,
        LAG(year_end_close) OVER (
            ORDER BY year
        ) AS previous_year_end_close
    FROM year_end_prices
)
SELECT
    year,
    year_end_date,
    ROUND(year_end_close, 2) AS year_end_close,
    ROUND(previous_year_end_close, 2)
        AS previous_year_end_close,
    ROUND(
        (
            year_end_close / previous_year_end_close - 1
        ) * 100,
        2
    ) AS annual_price_return_pct
FROM yearly_returns
ORDER BY year;
