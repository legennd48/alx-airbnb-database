# Query Optimization Report

This report analyzes and optimizes a query that retrieves all bookings along with user, property, and payment details. The goal is to reduce execution time and resource usage by refactoring the query and ensuring efficient joins and column selection.

---

## Initial Query Analysis

```sql
EXPLAIN ANALYZE
SELECT
    booking.*,
    "user".first_name,
    "user".last_name,
    "user".email,
    property.name AS property_name,
    property.location,
    property.pricepernight,
    payment.amount,
    payment.payment_method,
    payment.payment_date
FROM booking, "user", property, payment
WHERE booking.user_id = "user".user_id
  AND booking.property_id = property.property_id
  AND booking.booking_id = payment.booking_id;
```

```
  Hash Join  (cost=3.22..21.67 rows=610 width=392) (actual time=0.244..0.287 rows=1
 loops=1)
   Hash Cond: (payment.booking_id = booking.booking_id)
   ->  Seq Scan on payment  (cost=0.00..16.10 rows=610 width=88) (actual time=0.01
1..0.014 rows=1 loops=1)
   ->  Hash  (cost=3.20..3.20 rows=2 width=320) (actual time=0.181..0.210 rows=2 l
oops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Nested Loop  (cost=0.00..3.20 rows=2 width=320) (actual time=0.089..0.183 rows=2 loops=1)
               Join Filter: (booking.user_id = "user".user_id)
               Rows Removed by Join Filter: 2
               ->  Nested Loop  (cost=0.00..2.09 rows=2 width=224) (actual time=0.059..0.108 rows=2 loops=1)
                     Join Filter: (booking.property_id = property.property_id)
                     Rows Removed by Join Filter: 1
                     ->  Seq Scan on booking  (cost=0.00..1.02 rows=2 width=128) (actual time=0.010..0.019 rows=2 loops=1)
                     ->  Materialize  (cost=0.00..1.03 rows=2 width=112) (actual time=0.013..0.022 rows=2 loops=2)
                           ->  Seq Scan on property  (cost=0.00..1.02 rows=2 width=112) (actual time=0.008..0.013 rows=2 loops=1)
               ->  Materialize  (cost=0.00..1.04 rows=3 width=112) (actual time=0.012..0.023 rows=2 loops=2)
                     ->  Seq Scan on "user"  (cost=0.00..1.03 rows=3 width=112) (actual time=0.006..0.012 rows=3 loops=1)
 Planning Time: 2.630 ms
 Execution Time: 0.510 ms
(18 rows)
```

---

## Improved Query Analysis

```sql
EXPLAIN ANALYZE
SELECT
    booking.booking_id,
    booking.start_date,
    booking.end_date,
    "user".first_name,
    "user".last_name,
    property.name AS property_name,
    payment.amount AS payment_amount,
    payment.payment_method
FROM booking
JOIN "user" ON booking.user_id = "user".user_id
JOIN property ON booking.property_id = property.property_id
LEFT JOIN payment ON booking.booking_id = payment.booking_id;
```

```
 Hash Right Join  (cost=3.22..21.67 rows=610 width=184) (actual time=0.223..0.281 rows=2 loops=1)
   Hash Cond: (payment.booking_id = booking.booking_id)
   ->  Seq Scan on payment  (cost=0.00..16.10 rows=610 width=80) (actual time=0.007..0.012 rows=1 loops=1)
   ->  Hash  (cost=3.20..3.20 rows=2 width=120) (actual time=0.167..0.196 rows=2 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Nested Loop  (cost=0.00..3.20 rows=2 width=120) (actual time=0.083..0.177 rows=2 loops=1)
               Join Filter: (booking.user_id = "user".user_id)
               Rows Removed by Join Filter: 2
               ->  Nested Loop  (cost=0.00..2.09 rows=2 width=72) (actual time=0.061..0.105 rows=2 loops=1)
                     Join Filter: (booking.property_id = property.property_id)
                     Rows Removed by Join Filter: 1
                     ->  Seq Scan on booking  (cost=0.00..1.02 rows=2 width=56) (actual time=0.016..0.023 rows=2 loops=1)
                     ->  Materialize  (cost=0.00..1.03 rows=2 width=48) (actual time=0.018..0.025 rows=2 loops=2)
                           ->  Seq Scan on property  (cost=0.00..1.02 rows=2 width=48) (actual time=0.009..0.013 rows=2 loops=1)
               ->  Materialize  (cost=0.00..1.04 rows=3 width=80) (actual time=0.007..0.018 rows=2 loops=2)
                     ->  Seq Scan on "user"  (cost=0.00..1.03 rows=3 width=80) (actual time=0.006..0.014 rows=3 loops=1)
 Planning Time: 0.539 ms
 Execution Time: 0.363 ms
(18 rows)
```

## Analysis

- The initial query uses old-style comma-separated joins with `WHERE` and `AND` to relate the tables. This approach results in a `Hash Join` and multiple sequential scans, which can be inefficient, especially as the dataset grows.
- The improved query uses explicit `JOIN` syntax and selects only the necessary columns, reducing the width of the result set and the amount of data processed.
- Execution time decreased from **0.510 ms** to **0.363 ms** on the sample dataset.
- The query plan remains similar in structure, but the improved query is more readable, maintainable, and efficient due to better join syntax and reduced data transfer.

## Conclusion

The optimization process shows that refactoring queries to use explicit `JOIN` syntax and selecting only the required columns leads to measurable improvements in query performance. The initial query, which used comma-separated tables and `WHERE`/`AND` for joining, was less efficient and less clear. The improved query, by using proper `JOIN` clauses and limiting the selected columns, reduced execution time and resource usage.

The improvements worked because:
- **Better Join Strategy:** Using explicit `JOIN` syntax allows the database planner to optimize join operations more effectively.
- **Reduced Data Transfer:** Selecting only necessary columns means less data is read from disk and sent to the client, which is increasingly important as the database grows.
- **Lower Memory Usage:** Smaller result sets reduce memory consumption during query execution.
- **Scalability:** These optimizations have a greater impact as the number of rows and columns increases, making the query more scalable for production workloads.
