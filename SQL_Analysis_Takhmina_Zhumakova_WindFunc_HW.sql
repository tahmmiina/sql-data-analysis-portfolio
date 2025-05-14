SELECT 'countries' AS table_name, COUNT(1) FROM sh.countries UNION ALL 
SELECT 'customers', COUNT(1) FROM sh.customers UNION ALL 
SELECT 'channels', COUNT(1) FROM sh.channels UNION ALL 
SELECT 'times', COUNT(1) FROM sh.times UNION ALL 
SELECT 'products', COUNT(1) FROM sh.products UNION ALL 
SELECT 'promotions', COUNT(1) FROM sh.promotions UNION ALL 
SELECT 'costs', COUNT(1) FROM sh.costs UNION ALL 
SELECT 'sales', COUNT(1) FROM sh.sales UNION ALL 
SELECT 'supplementary_demographics', COUNT(1) FROM sh.supplementary_demographics 
UNION ALL 
SELECT 'profits', COUNT(1) FROM sh.profits; 

--Task1 

WITH customer_sales AS (
    SELECT
        ch.channel_desc,
        c.cust_id,
        c.cust_first_name,
        c.cust_last_name,
        SUM(s.amount_sold) AS total_sales
    FROM
        sh.sales s
        JOIN sh.customers c ON s.cust_id = c.cust_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
    GROUP BY
        ch.channel_desc,
        c.cust_id,
        c.cust_first_name,
        c.cust_last_name
),
channel_totals AS (
    SELECT
        channel_desc,
        SUM(total_sales) AS channel_total
    FROM customer_sales
    GROUP BY channel_desc
),
ranked_customers AS (
    SELECT
        cs.channel_desc,
        cs.cust_id,
        cs.cust_first_name,
        cs.cust_last_name,
        cs.total_sales,
        ct.channel_total,
        RANK() OVER (
            PARTITION BY cs.channel_desc
            ORDER BY cs.total_sales DESC
        ) AS sales_rank
    FROM customer_sales cs
    JOIN channel_totals ct ON cs.channel_desc = ct.channel_desc
)
SELECT
    channel_desc,
    cust_id,
    cust_first_name,
    cust_last_name,
    TO_CHAR(total_sales, '999,999,990.00') AS amount_sold,
    TO_CHAR((total_sales / channel_total) * 100, '990.9999') || '%' AS sales_percentage
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY channel_desc, total_sales DESC;

--Task 2
SELECT
    p.prod_name,
    TO_CHAR(SUM(s.amount_sold), 'FM999,999,990.00') AS total_sales,
    TO_CHAR(SUM(SUM(s.amount_sold)) OVER (), 'FM999,999,990.00') AS year_sum
FROM
    sh.sales s
JOIN sh.products p ON s.prod_id = p.prod_id
JOIN sh.customers c ON s.cust_id = c.cust_id
JOIN sh.countries co ON c.country_id = co.country_id
JOIN sh.times t ON s.time_id = t.time_id
WHERE
    p.prod_category = 'Photo'
    AND co.country_name IN (
        'China', 'India', 'Japan', 'Korea', 'Indonesia', 'Thailand',
        'Malaysia', 'Vietnam', 'Singapore', 'Philippines'
    )
    AND t.calendar_year = 2000
GROUP BY
    p.prod_name
ORDER BY
    year_sum DESC;

--Task 3
WITH customer_yearly_sales AS (
    SELECT
        s.channel_id,
        ch.channel_desc,
        s.cust_id,
        c.cust_first_name,
        c.cust_last_name,
        EXTRACT(YEAR FROM t.time_id) AS sales_year,
        SUM(s.amount_sold) AS total_sales
    FROM
        sh.sales s
        JOIN sh.customers c ON s.cust_id = c.cust_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
        JOIN sh.times t ON s.time_id = t.time_id
    WHERE
        EXTRACT(YEAR FROM t.time_id) IN (1998, 1999, 2001)
    GROUP BY
        s.channel_id, ch.channel_desc, s.cust_id, c.cust_first_name, c.cust_last_name, EXTRACT(YEAR FROM t.time_id)
),
ranked_customers AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY sales_year
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM customer_yearly_sales
),
top_customers AS (
    SELECT *
    FROM ranked_customers
    WHERE sales_rank <= 300
)
SELECT
    channel_desc,
    sales_year,
    cust_id,
    cust_first_name,
    cust_last_name,
    TO_CHAR(total_sales, 'FM999,999,990.00') AS total_sales
FROM top_customers
ORDER BY channel_desc, sales_year, total_sales DESC;

--Task 4
SELECT
    CASE 
        WHEN co.country_name IN ('United Kingdom', 'France', 'Germany', 'Italy', 'Spain') THEN 'Europe'
        WHEN co.country_name IN ('United States', 'Canada', 'Mexico', 'Brazil', 'Argentina') THEN 'Americas'
    END AS region,
    TO_CHAR(t.time_id, 'Month') AS month,
    p.prod_category,
    TO_CHAR(SUM(s.amount_sold), 'FM999,999,990.00') AS total_sales
FROM
    sh.sales s
    JOIN sh.products p ON s.prod_id = p.prod_id
    JOIN sh.customers c ON s.cust_id = c.cust_id
    JOIN sh.countries co ON c.country_id = co.country_id
    JOIN sh.times t ON s.time_id = t.time_id
WHERE
    EXTRACT(YEAR FROM t.time_id) = 2000
    AND EXTRACT(MONTH FROM t.time_id) IN (1, 2, 3)
    AND co.country_name IN (
        'United States', 'Canada', 'Mexico', 'Brazil', 'Argentina',
        'United Kingdom', 'France', 'Germany', 'Italy', 'Spain'
    )
GROUP BY
    region,
    TO_CHAR(t.time_id, 'Month'),
    p.prod_category
ORDER BY
    region,
    p.prod_category,
    MIN(t.time_id);
