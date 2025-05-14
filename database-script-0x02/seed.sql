-- seed.sql

-- Insert Users
INSERT INTO "user" (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Alice', 'Smith', 'alice@example.com', 'hash1', '1234567890', 'guest'),
  ('22222222-2222-2222-2222-222222222222', 'Bob', 'Johnson', 'bob@example.com', 'hash2', '0987654321', 'host'),
  ('33333333-3333-3333-3333-333333333333', 'Charlie', 'Brown', 'charlie@example.com', 'hash3', '1112223333', 'guest');

-- Insert Properties
INSERT INTO property (property_id, host_id, name, description, location, pricepernight)
VALUES
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Sunny Villa', 'A cozy beachside villa.', 'Miami, FL', 150.00),
  ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Mountain Retreat', 'A peaceful cabin in the woods.', 'Aspen, CO', 200.00);

-- Insert Bookings
INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, status)
VALUES
  ('bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '2025-07-01', '2025-07-05', 600.00, 'confirmed'),
  ('bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', '2025-08-10', '2025-08-15', 1000.00, 'pending');

-- Insert Payments
INSERT INTO payment (payment_id, booking_id, amount, payment_method)
VALUES
  ('ccccccc1-cccc-cccc-cccc-cccccccccccc', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 600.00, 'credit_card');

-- Insert Reviews
INSERT INTO review (review_id, property_id, user_id, rating, comment)
VALUES
  ('ddddddd1-dddd-dddd-dddd-dddddddddddd', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 5, 'Amazing stay! Loved the place.'),
  ('ddddddd2-dddd-dddd-dddd-dddddddddddd', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 4, 'Very peaceful and clean.');

-- Insert Messages
INSERT INTO message (message_id, sender_id, recipient_id, message_body)
VALUES
  ('eeeeeee1-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Hi, is the villa available in July?'),
  ('eeeeeee2-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Yes, the dates are open!');