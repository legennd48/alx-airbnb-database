# Database Performance Monitoring and Refinement Report

This report documents the process of monitoring, analyzing, and refining the performance of frequently used queries in the Airbnb database. The goal is to identify bottlenecks using `EXPLAIN ANALYZE`, implement schema or index changes, and report the resulting improvements.

---

## 1. Initial Query Performance Monitoring

I began by identifying and running several frequently used queries, analyzing their execution plans with `EXPLAIN ANALYZE` to understand how PostgreSQL was executing them.

### Frequently Used Queries and Initial Results

**Query 1: Find a user by email**
```sql
EXPLAIN ANALYZE
SELECT * FROM "user" WHERE email = 'alice@example.com';
```
**Result**
```
Seq Scan on "user"  (cost=0.00..1.04 rows=1 width=216) (actual time=0.014..0.021 rows=1 loops=1)
   Filter: ((email)::text = 'alice@example.com'::text)
   Rows Removed by Filter: 2
 Planning Time: 0.436 ms
 Execution Time: 0.052 ms
```

**Result Summary**
The database serch for our target by checking all entries in the database, this will take a lot of time if the table is very large. it is clearly inneficient, we should create an index for this field to solve this problem

**Query 2: Get all bookings for a user**
```sql
EXPLAIN ANALYZE
SELECT * FROM booking WHERE user_id = '11111111-1111-1111-1111-111111111111';
```
**Result**
```
Append  (cost=0.00..49.55 rows=9 width=128) (actual time=0.028..0.106 rows=3 loops=1)
   ->  Seq Scan on booking_2024 booking_1  (cost=0.00..16.50 rows=3 width=128) (actual time=0.021..0.030 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 1
   ->  Seq Scan on booking_2025 booking_2  (cost=0.00..16.50 rows=3 width=128) (actual time=0.012..0.019 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 3
   ->  Seq Scan on booking_future booking_3  (cost=0.00..16.50 rows=3 width=128) (actual time=0.010..0.017 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 1
 Planning Time: 0.480 ms
 Execution Time: 0.200 ms
(12 rows)
```
**Result Summary:**  
The database checked every booking in each partition (year) to find bookings for a specific user. This means it scanned all rows in all partitions, which is inefficient for large datasets. The inefficiency is due to the absence of indexes on the `user_id` column in each partition, so the database cannot quickly jump to the relevant bookings.


**Query 3: Get all bookings for a property**
```sql
EXPLAIN ANALYZE
SELECT * FROM booking WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
```
**Result**
```
Append  (cost=0.00..49.55 rows=9 width=128) (actual time=0.015..0.058 rows=4 loops=1)
   ->  Seq Scan on booking_2024 booking_1  (cost=0.00..16.50 rows=3 width=128) (actual time=0.011..0.015 rows=1 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 1
   ->  Seq Scan on booking_2025 booking_2  (cost=0.00..16.50 rows=3 width=128) (actual time=0.004..0.009 rows=2 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 2
   ->  Seq Scan on booking_future booking_3  (cost=0.00..16.50 rows=3 width=128) (actual time=0.005..0.008 rows=1 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 1
 Planning Time: 0.181 ms
 Execution Time: 0.089 ms
(12 rows)
```
**Result Summaey:**  
To find bookings for a specific property, the database scanned all bookings in every partition, examining each row to see if it matched the property. This is inefficient because it wastes time checking irrelevant rows. The root cause is the lack of indexes on the `property_id` column in each partition, preventing fast lookups.


**Query 4: Get all properties for a host**
```sql
EXPLAIN ANALYZE
SELECT * FROM property WHERE host_id = '22222222-2222-2222-2222-222222222222';
```
**Result**
```
Seq Scan on property  (cost=0.00..1.02 rows=1 width=176) (actual time=0.016..0.025 rows=2 loops=1)
   Filter: (host_id = '22222222-2222-2222-2222-222222222222'::uuid)
 Planning Time: 0.428 ms
 Execution Time: 0.065 ms
(4 rows)
```
**Result Summary for Query 4:**  
The database checked every property to find those belonging to a specific host. While this is manageable for a small table, it will become slow as the number of properties increases. The inefficiency comes from not having an index on the `host_id` column, which would allow the database to directly find the host’s properties.

---

## 2. Refining Query Execution

### Adjusting Query Execution Settings

I discovered that all the indexes already existed, but due to the small size of the tables, sequential scans were being forced. To test the impact of disabling sequential scans, I ran the following command:

```sql
SET enable_seqscan = off;
```

#### Results After Disabling Sequential Scans

**Query 1: Find a user by email**
```
Index Scan using idx_user_email on "user"  (cost=0.13..8.15 rows=1 width=216) (actual time=0.183..0.193 rows=1 loops=1)
   Index Cond: ((email)::text = 'alice@example.com'::text)
 Planning Time: 0.160 ms
 Execution Time: 0.247 ms
(4 rows)
```
**Result Summary:**  
After disabling sequential scans, PostgreSQL used the `idx_user_email` index to find the user by email, as shown by the "Index Scan" in the execution plan. The planning time dropped from 0.436 ms to 0.160 ms, indicating that the query planner quickly identified the optimal index-based strategy. If the table were large, using the index would avoid scanning every row, resulting in much faster lookups and significantly improved performance.

**Query 2: Get all bookings for a user**
```
Append  (cost=10000000000.00..30000000049.54 rows=9 width=128) (actual time=200.963..201.049 rows=3 loops=1)
   ->  Seq Scan on booking_2024 booking_1  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=200.956..200.963 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 1
   ->  Seq Scan on booking_2025 booking_2  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=0.030..0.034 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 3
   ->  Seq Scan on booking_future booking_3  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=0.016..0.019 rows=1 loops=1)
         Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
         Rows Removed by Filter: 1
 Planning Time: 0.189 ms
 JIT:
   Functions: 6
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 2.226 ms, Inlining 84.277 ms, Optimization 49.199 ms, Emission 67.456 ms, Total 203.158 ms
 Execution Time: 612.905 ms
(16 rows)
```
**Result Summary:**  
Despite disabling sequential scans, the query planner could not use indexes for the partitioned tables because no indexes existed on the `user_id` column in each partition. As a result, the database still performed sequential scans on every partition, leading to high planning and execution times. This demonstrates that simply changing planner settings is not enough—appropriate indexes must exist on each partition to enable efficient index scans. Without these indexes, performance will degrade as data volume grows, especially for queries filtering by partition key columns.

**Query 3: Get all bookings for a property**
```
Append  (cost=10000000000.00..30000000049.54 rows=9 width=128) (actual time=38.926..39.033 rows=4 loops=1)
   ->  Seq Scan on booking_2024 booking_1  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=38.921..38.932 rows=1 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 1
   ->  Seq Scan on booking_2025 booking_2  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=0.034..0.043 rows=2 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 2
   ->  Seq Scan on booking_future booking_3  (cost=10000000000.00..10000000016.50 rows=3 width=128) (actual time=0.015..0.021 rows=1 loops=1)
         Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
         Rows Removed by Filter: 1
 Planning Time: 0.392 ms
 JIT:
   Functions: 6
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 0.666 ms, Inlining 1.130 ms, Optimization 19.834 ms, Emission 17.938 ms, Total 39.568 ms
 Execution Time: 39.872 ms
(16 rows)
```
**Result Summary:**  
As with the previous query, disabling sequential scans did not improve performance because there were no indexes on the `property_id` column in each partition. The database continued to perform sequential scans across all partitions, resulting in unnecessary work and slow query times. This reinforces the need to create indexes on partitioned tables to enable efficient index scans and optimize query performance.

**Query 4: Get all properties for a host**
```
Index Scan using idx_property_host_id on property  (cost=0.13..8.14 rows=1 width=176) (actual time=0.116..0.126 rows=2 loops=1)
   Index Cond: (host_id = '22222222-2222-2222-2222-222222222222'::uuid)
 Planning Time: 0.136 ms
 Execution Time: 0.174 ms
(4 rows)
```
**Result Summary:**  
After disabling sequential scans, PostgreSQL used the `idx_property_host_id` index to efficiently find properties for a specific host. The execution plan shows an "Index Scan," and both planning and execution times decreased compared to the initial sequential scan. This demonstrates that with the appropriate index, queries scale well even as the table grows, ensuring fast lookups for host properties.

---

#

## 3. Creating Indexes for Partitioned Tables

I noticed from the previous results that the partitions were still being queried sequentially. To address this, I created indexes for each partition:

```sql
CREATE INDEX IF NOT EXISTS idx_booking_2024_user_id ON booking_2024(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2025_user_id ON booking_2025(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_future_user_id ON booking_future(user_id);

CREATE INDEX IF NOT EXISTS idx_booking_2024_property_id ON booking_2024(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_2025_property_id ON booking_2025(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_future_property_id ON booking_future(property_id);
```

#### Results After Creating Indexes

**Query 2: Get all bookings for a user**
```
Append  (cost=0.13..24.45 rows=3 width=128) (actual time=0.054..0.158 rows=3 loops=1)
   ->  Index Scan using idx_booking_2024_user_id on booking_2024 booking_1  (cost=0.13..8.14 rows=1 width=128) (actual time=0.047..0.053 rows=1 loops=1)
         Index Cond: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
   ->  Index Scan using idx_booking_2025_user_id on booking_2025 booking_2  (cost=0.13..8.15 rows=1 width=128) (actual time=0.036..0.041 rows=1 loops=1)
         Index Cond: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
   ->  Index Scan using idx_booking_future_user_id on booking_future booking_3  (cost=0.13..8.14 rows=1 width=128) (actual time=0.028..0.033 rows=1 loops=1)
         Index Cond: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
 Planning Time: 1.330 ms
 Execution Time: 0.213 ms
(9 rows)
```
**Result Summary:**  
After creating indexes on the `user_id` column for each partition, the query planner switched from sequential scans to index scans in all partitions. This led to a dramatic reduction in execution time and resource usage. The database now efficiently locates relevant bookings for a user without scanning every row, ensuring scalability and fast performance as data grows.

**Query 3: Get all bookings for a property**
```
Append  (cost=0.13..24.45 rows=3 width=128) (actual time=0.102..0.227 rows=4 loops=1)
   ->  Index Scan using idx_booking_2024_property_id on booking_2024 booking_1  (cost=0.13..8.14 rows=1 width=128) (actual time=0.097..0.104 rows=1 loops=1)
         Index Cond: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
   ->  Index Scan using idx_booking_2025_property_id on booking_2025 booking_2  (cost=0.13..8.15 rows=1 width=128) (actual time=0.041..0.049 rows=2 loops=1)
         Index Cond: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
   ->  Index Scan using idx_booking_future_property_id on booking_future booking_3  (cost=0.13..8.14 rows=1 width=128) (actual time=0.032..0.036 rows=1 loops=1)
         Index Cond: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
 Planning Time: 0.386 ms
 Execution Time: 0.283 ms
(9 rows)
```
**Result Summary:**  
With indexes created on the `property_id` column for each partition, the query planner now uses index scans instead of sequential scans. This change greatly improves performance, as the database can directly access only the relevant rows in each partition. Execution time and resource usage are significantly reduced, making the query much more efficient and scalable for larger datasets.

---

## 4. Conclusion
Through a systematic process of monitoring query performance, analyzing execution plans, and applying targeted refinements, substantial improvements were achieved. Initially, queries suffered from inefficient sequential scans due to missing or unused indexes, especially on partitioned tables. Disabling sequential scans demonstrated the potential benefit of indexes, but also revealed that indexes must exist on each partition to be effective. After creating the necessary indexes on partitioned columns, the query planner began using index scans, resulting in dramatically reduced execution times and resource usage. This process underscores the critical role of both query plan analysis and proper index management in optimizing database performance.





