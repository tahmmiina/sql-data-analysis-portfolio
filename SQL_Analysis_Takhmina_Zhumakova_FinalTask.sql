WITH region_sales AS (
    SELECT
        ch.channel_desc,
        co.country_region,
        SUM(s.quantity_sold) AS total_quantity
    FROM
        sh.sales s
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
        JOIN sh.customers cu ON s.cust_id = cu.cust_id
        JOIN sh.countries co ON cu.country_id = co.country_id
    GROUP BY
        ch.channel_desc,
        co.country_region
),
channel_totals AS (
    SELECT
        channel_desc,
        SUM(total_quantity) AS channel_total_quantity
    FROM region_sales
    GROUP BY channel_desc
),
ranked_regions AS (
    SELECT
        rs.channel_desc,
        rs.country_region,
        rs.total_quantity,
        ct.channel_total_quantity,
        RANK() OVER (PARTITION BY rs.channel_desc ORDER BY rs.total_quantity DESC) AS region_rank
    FROM region_sales rs
    JOIN channel_totals ct ON rs.channel_desc = ct.channel_desc
)
SELECT
    channel_desc AS "CHANNEL_DESC",
    country_region AS "COUNTRY_REGION",
    TO_CHAR(total_quantity, '999,999,990.00') AS "SALES",
    TO_CHAR((total_quantity / channel_total_quantity) * 100, '990.00') || '%' AS "SALES %"
FROM ranked_regions
WHERE region_rank = 1
ORDER BY total_quantity DESC;




--Task 2


WITH yearly_sales AS (
    SELECT
        p.prod_subcategory,
        t.calendar_year,
        SUM(s.amount_sold) AS total_sales
    FROM
        sh.sales s
        JOIN sh.products p ON s.prod_id = p.prod_id
        JOIN sh.times t ON s.time_id = t.time_id
    WHERE
        t.calendar_year BETWEEN 1997 AND 2001
    GROUP BY
        p.prod_subcategory,
        t.calendar_year
),
sales_with_lags AS (
    SELECT
        prod_subcategory,
        calendar_year,
        total_sales,
        LAG(total_sales, 1) OVER (
            PARTITION BY prod_subcategory
            ORDER BY calendar_year
        ) AS prev_year_sales
    FROM yearly_sales
),
filtered_years AS (
    SELECT *
    FROM sales_with_lags
    WHERE calendar_year BETWEEN 1998 AND 2001
      AND total_sales > prev_year_sales
),
subcategory_counts AS (
    SELECT
        prod_subcategory,
        COUNT(*) AS rising_years
    FROM filtered_years
    GROUP BY prod_subcategory
)
SELECT
    prod_subcategory
FROM subcategory_counts
WHERE rising_years = 4;

--Task 3

WITH filtered_sales AS (
    SELECT
        t.calendar_year,
        t.calendar_quarter_desc,
        p.prod_category,
        s.amount_sold
    FROM
        sh.sales s
        JOIN sh.products p ON s.prod_id = p.prod_id
        JOIN sh.times t ON s.time_id = t.time_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
    WHERE
        t.calendar_year IN (1999, 2000)
        AND p.prod_category IN ('Electronics', 'Hardware', 'Software/Other')
        AND ch.channel_desc IN ('Partners', 'Internet')
),
quarterly_sales AS (
    SELECT
        calendar_year,
        calendar_quarter_desc,
        prod_category,
        ROUND(SUM(amount_sold), 2) AS sales
    FROM filtered_sales
    GROUP BY
        calendar_year, calendar_quarter_desc, prod_category
),
q1_sales AS (
    SELECT
        calendar_year,
        prod_category,
        sales AS q1_sales
    FROM quarterly_sales
    WHERE calendar_quarter_desc = 'Q1'
),
sales_with_diff AS (
    SELECT
        qs.calendar_year,
        qs.calendar_quarter_desc,
        qs.prod_category,
        qs.sales,
        CASE
            WHEN qs.calendar_quarter_desc = 'Q1' THEN 'N/A'
            ELSE TO_CHAR(ROUND(((qs.sales - q1.q1_sales) / NULLIF(q1.q1_sales, 0)) * 100, 2), '990.00') || '%'
        END AS diff_percent
    FROM quarterly_sales qs
    LEFT JOIN q1_sales q1
        ON qs.calendar_year = q1.calendar_year AND qs.prod_category = q1.prod_category
),
final_report AS (
    SELECT
        calendar_year,
        calendar_quarter_desc,
        prod_category,
        sales AS "SALES$",
        diff_percent AS "DIFF_PERCENT",
        ROUND(SUM(sales) OVER (
            PARTITION BY calendar_year, prod_category
            ORDER BY
                CASE calendar_quarter_desc
                    WHEN 'Q1' THEN 1
                    WHEN 'Q2' THEN 2
                    WHEN 'Q3' THEN 3
                    WHEN 'Q4' THEN 4
                    ELSE 5
                END
        ), 2) AS "CUM_SUM$"
    FROM sales_with_diff
)
SELECT *
FROM final_report
ORDER BY
    calendar_year ASC,
    CASE calendar_quarter_desc
        WHEN 'Q1' THEN 1
        WHEN 'Q2' THEN 2
        WHEN 'Q3' THEN 3
        WHEN 'Q4' THEN 4
        ELSE 5
    END ASC,
    "SALES$" DESC;

