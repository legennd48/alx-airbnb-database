# Booking Table Partitioning Performance Report

This report documents the impact of implementing table partitioning on the `booking` table by year, using the `start_date` column as the partition key. The goal is to optimize query performance for large datasets, especially for queries filtered by date ranges.

---

## Query Performance Before Partitioning

**Query:**
```sql
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';
```

```
Seq Scan on booking  (cost=0.00..1.03 rows=1 width=128) (actual time=0.036..0.045 rows=1 loops=1)
  Filter: ((start_date >= '2024-06-01'::date) AND (start_date <= '2024-06-30'::date))
  Rows Removed by Filter: 7
Planning Time: 1.182 ms
Execution Time: 0.163 ms
(5 rows)
```
### Observation
- The query performs a sequential scan over the entire booking table, checking every row to find matches.
- As the table grows, this approach becomes increasingly inefficient, leading to slower query times.


## Partitioning Implementation
Partitioning was implemented by creating the following Partitions:

```sql
-- Partition for bookings in 2024
CREATE TABLE booking_2024 PARTITION OF booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Partition for bookings in 2025
CREATE TABLE booking_2025 PARTITION OF booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Default partition for bookings from 2026 onwards
CREATE TABLE booking_future PARTITION OF booking
    FOR VALUES FROM ('2026-01-01') TO ('2100-01-01');
```  

## Query Performance After Partitioning
### Query:
```sql
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';
```
### Result:
```
Seq Scan on booking_2024 booking  (cost=0.00..17.80 rows=3 width=128) (actual time=0.018..0.024 rows=1 loops=1)
  Filter: ((start_date >= '2024-06-01'::date) AND (start_date <= '2024-06-30'::date))
  Rows Removed by Filter: 1
Planning Time: 0.773 ms
Execution Time: 0.057 ms
(5 rows)
```
### Observation
- The query now scans only the relevant partition (booking_2024) instead of the entire table.
- Fewer rows are checked, and execution time is reduced.
- This improvement will be much more significant as the dataset grows.

## Conclusion
Partitioning the booking table by year on the start_date column significantly improves query performance for date-based queries. After partitioning, PostgreSQL only scans the relevant partition(s), reducing I/O and execution time. This makes the database more scalable and responsive as data volume increases.

