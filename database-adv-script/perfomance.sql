-- Initial query: Retrieve all bookings with user, property, and payment details
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


-- improved query
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