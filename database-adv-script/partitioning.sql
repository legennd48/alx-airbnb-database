-- partitioning.sql
-- This script demonstrates table partitioning for the 'booking' table by year.
-- It includes performance analysis before and after partitioning.

-- Analyze query performance before partitioning
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- backup data fo booking table
ALTER TABLE booking RENAME TO booking_old;

-- Create the partitioned parent table with PARTITION BY
CREATE TABLE booking (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL NOT NULL,
    status VARCHAR CHECK (status IN ('pending', 'confirmed', 'canceled')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date)
) PARTITION BY RANGE (start_date);

-- restore data from booking_old to partitioned booking table
INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)


-- Create partitions for each year
CREATE TABLE booking_2024 PARTITION OF booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE booking_2025 PARTITION OF booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE booking_future PARTITION OF booking
    FOR VALUES FROM ('2026-01-01') TO ('2100-01-01');

-- Analyze query performance after partitioning
EXPLAIN ANALYZE
SELECT * FROM booking WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';