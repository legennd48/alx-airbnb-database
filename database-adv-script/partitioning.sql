-- partitioning.sql
-- This script demonstrates table partitioning for the 'booking' table by year.
-- It includes performance analysis before and after partitioning.

-- Analyze query performance before partitioning
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';


-- Create partitions for the 'booking' table by year
-- Partition for bookings in 2024
CREATE TABLE booking_2024 PARTITION OF booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Partition for bookings in 2025
CREATE TABLE booking_2025 PARTITION OF booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Default partition for bookings from 2026 onwards
CREATE TABLE booking_future PARTITION OF booking
    FOR VALUES FROM ('2026-01-01') TO ('2100-01-01');


-- Analyze query performance after partitioning
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';
