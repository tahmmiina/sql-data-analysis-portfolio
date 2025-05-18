--Task 2
--5. Hand over your investigation's results to your trainer. The results must include:

      --a) Space consumption of ‘table_to_delete’ table before and after each operation; nothing changed in mine
      --b) Duration of each operation (DELETE, TRUNCATE) 48 sec and 0.128 sec

--1. Create table ‘table_to_delete’ and fill it with the following query:
 CREATE TABLE table_to_delete AS
 SELECT 'veeeeeeery_long_string' || x AS col
 FROM generate_series(1,(10^7)::int) x;
 -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)

SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';


               DELETE FROM table_to_delete
               WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all rows
               
               EXPLAIN ANALYZE DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0;

               
               VACUUM FULL VERBOSE table_to_delete;
               
               DROP TABLE IF EXISTS table_to_delete;
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1, (10^7)::int) x;

TRUNCATE table_to_delete;

SELECT *, pg_size_pretty(total_bytes) AS total,
                    pg_size_pretty(index_bytes) AS INDEX,
                    pg_size_pretty(toast_bytes) AS toast,
                    pg_size_pretty(table_bytes) AS TABLE
FROM (
    SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
    FROM (
        SELECT c.oid,
                nspname AS table_schema,
                relname AS TABLE_NAME,
                c.reltuples AS row_estimate,
                pg_total_relation_size(c.oid) AS total_bytes,
                pg_indexes_size(c.oid) AS index_bytes,
                pg_total_relation_size(reltoastrelid) AS toast_bytes
        FROM pg_class c
        LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE relkind = 'r'
    ) a
) a
WHERE table_name LIKE '%table_to_delete%';



              
               
               
               
