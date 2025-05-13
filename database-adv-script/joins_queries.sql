-- joins_queries.sql
-- This script demonstrates various types of JOIN operations in SQL.


-- INNER JOIN
-- This Query retrieves all booking and the respective users who made them
SELECT * FROM booking 
INNER JOIN "user" ON booking.user_id = "user".user_id;

-- LEFT JOIN
-- This Quesrt retrieves all properties and their reviws including those without reviews
SELECT * FROM property
LEFT JOIN review ON property.property_id = review.property_id;

-- FULL OUTER JOIN
-- This Quesrt retrieves all users and their booking including those without bookings
SELECT * FROM "user"
FULL OUTER JOIN booking ON user.user_id = booking.user_id;