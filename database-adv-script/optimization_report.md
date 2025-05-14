# Query Optimization Report

This report analyzes and optimizes a query that retrieves all bookings along with user, property, and payment details. The goal is to reduce execution time and resource usage by refactoring the query and ensuring efficient joins and column selection.

---

## Initial Query

```sql
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
FROM booking
JOIN "user" ON booking.user_id = "user".user_id
JOIN property ON booking.property_id = property.property_id
LEFT JOIN payment ON booking.booking_id = payment.booking_id;
```

---

## Query Analysis

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
FROM booking
JOIN "user" ON booking.user_id = "user".user_id
JOIN property ON booking.property_id = property.property_id
LEFT JOIN payment ON booking.booking_id = payment.booking_id;
```

```
 Hash Right Join  (cost=3.22..21.67 rows=610 width=392) (actual time=0.256..0.313 rows=2 loops=1)
   Hash Cond: (payment.booking_id = booking.booking_id)
   ->  Seq Scan on payment  (cost=0.00..16.10 rows=610 width=88) (actual time=0.013..0.018 rows=1 loops=1)
   ->  Hash  (cost=3.20..3.20 rows=2 width=320) (actual time=0.164..0.193 rows=2 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Nested Loop  (cost=0.00..3.20 rows=2 width=320) (actual time=0.073..0.169 rows=2 loops=1)
               Join Filter: (booking.user_id = "user".user_id)
               Rows Removed by Join Filter: 2
               ->  Nested Loop  (cost=0.00..2.09 rows=2 width=224) (actual time=0.050..0.099 rows=2 loops=1)
                     Join Filter: (booking.property_id = property.property_id)
                     Rows Removed by Join Filter: 1
                     ->  Seq Scan on booking  (cost=0.00..1.02 rows=2 width=128) (actual time=0.013..0.022 rows=2 loops=1)
                     ->  Materialize  (cost=0.00..1.03 rows=2 width=112) (actual time=0.013..0.021 rows=2 loops=2)
                           ->  Seq Scan on property  (cost=0.00..1.02 rows=2 width=112) (actual time=0.008..0.013 rows=2 loops=1)
               ->  Materialize  (cost=0.00..1.04 rows=3 width=112) (actual time=0.008..0.020 rows=2 loops=2)
                     ->  Seq Scan on "user"  (cost=0.00..1.03 rows=3 width=112) (actual time=0.008..0.014 rows=3 loops=1)
 Planning Time: 0.718 ms
 Execution Time: 0.450 ms
(18 rows)
```

---

## Improved Query

```sql
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

- The improved query reduces the width of the result set by selecting only necessary columns, which improves performance as data volume increases.
- Execution time decreased from **0.450 ms** to **0.363 ms** on the sample dataset.
- The query plan remains similar, but the smaller result set makes the query more efficient and scalable.

## Conclusion

The optimization process demonstrated that even small changes—such as selecting only the necessary columns instead of using `SELECT *`—can lead to measurable improvements in query performance. In this case, the execution time decreased and the result set became more efficient to process and transfer, even though the underlying join strategy remained similar.

The improvements worked because:
- **Reduced Data Transfer:** By limiting the columns selected, less data is read from disk and sent to the client, which is especially important as the database grows.
- **Lower Memory Usage:** Smaller result sets mean less memory is used during query execution.
- **Scalability:** These optimizations have a greater impact as the number of rows and columns increases, making the query more scalable for production workloads.
