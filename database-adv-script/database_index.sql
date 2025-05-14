-- Analyze performance BEFORE creating indexes
EXPLAIN ANALYZE SELECT * FROM "user" WHERE email = 'alice@example.com';
EXPLAIN ANALYZE SELECT * FROM booking WHERE user_id = '11111111-1111-1111-1111-111111111111';
EXPLAIN ANALYZE SELECT * FROM booking WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
EXPLAIN ANALYZE SELECT * FROM property WHERE host_id = '22222222-2222-2222-2222-222222222222';
EXPLAIN ANALYZE SELECT * FROM property WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

-- Create indexes
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_booking_user_id ON booking(user_id);
CREATE INDEX idx_booking_property_id ON booking(property_id);
CREATE INDEX idx_property_host_id ON property(host_id);

-- Analyze performance AFTER creating indexes
EXPLAIN ANALYZE SELECT * FROM "user" WHERE email = 'alice@example.com';
EXPLAIN ANALYZE SELECT * FROM booking WHERE user_id = '11111111-1111-1111-1111-111111111111';
EXPLAIN ANALYZE SELECT * FROM booking WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
EXPLAIN ANALYZE SELECT * FROM property WHERE host_id = '22222222-2222-2222-2222-222222222222';
EXPLAIN ANALYZE SELECT * FROM property WHERE property_id = 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
