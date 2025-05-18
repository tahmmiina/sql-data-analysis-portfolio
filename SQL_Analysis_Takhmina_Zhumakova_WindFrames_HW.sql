WITH base_sales AS (
    SELECT
        t.calendar_year,
        ch.channel_desc,
        co.country_region,
        SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
        JOIN sh.customers cu ON s.cust_id = cu.cust_id
        JOIN sh.countries co ON cu.country_id = co.country_id
        JOIN sh.times t ON s.time_id = t.time_id
    WHERE 
        t.calendar_year BETWEEN 1999 AND 2001
        AND co.country_region IN ('Americas', 'Asia', 'Europe')
    GROUP BY 
        t.calendar_year, ch.channel_desc, co.country_region
),
region_totals AS (
    SELECT
        calendar_year,
        country_region,
        SUM(amount_sold) AS region_total
    FROM base_sales
    GROUP BY calendar_year, country_region
),
sales_with_pct AS (
    SELECT
        bs.calendar_year,
        bs.channel_desc,
        bs.country_region,
        bs.amount_sold,
        rt.region_total,
        ROUND((bs.amount_sold / rt.region_total) * 100, 2) AS pct_by_channel
    FROM base_sales bs
    JOIN region_totals rt 
        ON bs.calendar_year = rt.calendar_year 
        AND bs.country_region = rt.country_region
),
sales_with_prev AS (
    SELECT
        swp.*,
        LAG(pct_by_channel) OVER (
            PARTITION BY country_region, channel_desc
            ORDER BY calendar_year
        ) AS pct_previous_period
    FROM sales_with_pct swp
)
SELECT
    calendar_year,
    country_region,
    channel_desc,
    TO_CHAR(amount_sold, '999,999,990.00') AS "AMOUNT_SOLD",
    TO_CHAR(pct_by_channel, '990.00') || '%' AS "% BY CHANNELS",
    CASE 
        WHEN pct_previous_period IS NULL THEN 'N/A'
        ELSE TO_CHAR(pct_previous_period, '990.00') || '%'
    END AS "% PREVIOUS PERIOD",
    CASE 
        WHEN pct_previous_period IS NULL THEN 'N/A'
        ELSE TO_CHAR(ROUND(pct_by_channel - pct_previous_period, 2), '990.00') || '%'
    END AS "% DIFF"
FROM sales_with_prev
ORDER BY 
    country_region ASC,
    calendar_year ASC,
    channel_desc ASC;

--task 2
--could not do task 2(

--task3
RANGE: Looks at rows with similar values, like salaries close to each other.

ROWS: Looks at a set number of rows before and after, like the last 3 orders.

GROUPS: Looks at rows with the same value together, like all sales on the same day.

