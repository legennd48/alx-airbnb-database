# Index Performance Analysis

This report documents the impact of adding indexes to high-usage columns in the `user`, `booking`, and `property` tables of the Airbnb database. The goal is to measure and analyze query performance before and after index creation using PostgreSQL's `EXPLAIN ANALYZE`.

## Methodology

1. **Identify high-usage columns:** Columns frequently used in `WHERE`, `JOIN`, or `ORDER BY` clauses were selected for indexing.
2. **Seed the database:** The database was populated with sample data from `seed.sql`.
3. **Measure baseline performance:** For each target query, `EXPLAIN ANALYZE` was run before adding the index.
4. **Create the index:** The relevant `CREATE INDEX` statement was executed.
5. **Measure post-index performance:** The same query was run again with `EXPLAIN ANALYZE`.
6. **Compare and analyze:** Execution plans and timings were compared to assess the impact of each index.

---

## Indexes Tested

- `idx_user_email` on `"user"(email)`
- `idx_booking_user_id` on `booking(user_id)`
- `idx_booking_property_id` on `booking(property_id)`
- `idx_property_host_id` on `property(host_id)`
- `idx_property_id` on `property(property_id)` <br>
    <sub><em>Note: usually already indexed as a primary key.</em></sub>

---

## Results

### 1. Index on `"user"(email)`

**Query:**
```sql
SELECT * FROM "user" WHERE email = 'alice@example.com';
```

<details>
<summary>Before Index</summary>

```
Seq Scan on "user"  (cost=0.00..1.04 rows=1 width=216) (actual time=0.015..0.022 rows=1 loops=1)
    Filter: ((email)::text = 'alice@example.com'::text)
    Rows Removed by Filter: 2
Planning Time: 0.343 ms
Execution Time: 0.057 ms
(5 rows)
```
</details>

<details>
<summary>After Index</summary>

```
Index Scan using user_email_key on "user"  (cost=0.15..8.17 rows=1 width=216) (actual time=0.026..0.032 rows=1 loops=1)
    Index Cond: ((email)::text = 'alice@example.com'::text)
Planning Time: 0.472 ms
Execution Time: 0.087 ms
(4 rows)
```
</details>

---

### 2. Index on `booking(user_id)`

**Query:**
```sql
SELECT * FROM booking WHERE user_id = '11111111-1111-1111-1111-111111111111';
```

<details>
<summary>Before Index</summary>

```
Seq Scan on booking  (cost=0.00..16.50 rows=3 width=128) (actual time=0.019..0.025 rows=1 loops=1)
    Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.101 ms
Execution Time: 0.061 ms
(5 rows)
```
</details>

<details>
<summary>After Index</summary>

```
Seq Scan on booking  (cost=0.00..1.02 rows=1 width=128) (actual time=0.013..0.020 rows=1 loops=1)
    Filter: (user_id = '11111111-1111-1111-1111-111111111111'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.326 ms
Execution Time: 0.055 ms
(5 rows)
```
</details>

---

### 3. Index on `booking(property_id)`

**Query:**
```sql
SELECT * FROM booking WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
```

<details>
<summary>Before Index</summary>

```
Seq Scan on booking  (cost=0.00..1.02 rows=1 width=128) (actual time=0.022..0.031 rows=1 loops=1)
    Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.114 ms
Execution Time: 0.068 ms
(5 rows)
```
</details>

<details>
<summary>After Index</summary>

```
Seq Scan on booking  (cost=0.00..1.02 rows=1 width=128) (actual time=0.015..0.022 rows=1 loops=1)
    Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.369 ms
Execution Time: 0.057 ms
```
</details>

---

### 4. Index on `property(host_id)`

**Query:**
```sql
SELECT * FROM property WHERE host_id = '22222222-2222-2222-2222-222222222222';
```

<details>
<summary>Before Index</summary>

```
Seq Scan on property  (cost=0.00..15.00 rows=2 width=176) (actual time=0.017..0.027 rows=2 loops=1)
    Filter: (host_id = '22222222-2222-2222-2222-222222222222'::uuid)
Planning Time: 0.352 ms
Execution Time: 0.068 ms
(4 rows)
```
</details>

<details>
<summary>After Index</summary>

```
Seq Scan on property  (cost=0.00..1.02 rows=1 width=176) (actual time=0.012..0.019 rows=2 loops=1)
    Filter: (host_id = '22222222-2222-2222-2222-222222222222'::uuid)
Planning Time: 0.369 ms
Execution Time: 0.051 ms
(4 rows)
```
</details>

---

### 5. Index on `property(property_id)`

**Query:**
```sql
SELECT * FROM property WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
```

<details>
<summary>Before Index</summary>

```
Seq Scan on property  (cost=0.00..1.02 rows=1 width=176) (actual time=0.022..0.029 rows=1 loops=1)
    Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.136 ms
Execution Time: 0.073 ms
```
</details>

<details>
<summary>After Index</summary>

```
Seq Scan on property  (cost=0.00..1.02 rows=1 width=176) (actual time=0.017..0.024 rows=1 loops=1)
    Filter: (property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid)
    Rows Removed by Filter: 1
Planning Time: 0.439 ms
Execution Time: 0.063 ms
(5 rows)
```
</details>

> **Observation:**  
> No change, as `property_id` is the primary key and already indexed by default.

---

## General Analysis

- **Small datasets:** PostgreSQL often prefers sequential scans for small tables, as reading the whole table is faster than using an index.
- **Larger datasets:** As data grows, the query planner will start using indexes, resulting in significant performance improvements, especially for selective queries.
- **Index scan vs. seq scan:** The presence of an index allows the planner to use an index scan, which is much faster for large tables and selective queries.
- **Redundant indexes:** Avoid creating indexes on primary key columns, as they are already indexed.

---

## Conclusion

Indexes are crucial for optimizing query performance, especially as your database grows.  
For small tables, you may not see immediate benefits, but indexes become essential for scalability.  
Always analyze your query plans with `EXPLAIN ANALYZE` before and after adding indexes to ensure they are being used effectively.