-- subqueries.sql
-- This script demonstrates the use of subqueries in SQL.

-- Using subqueries to get all properties with average rating of 4.0 or higher
SELECT * FROM property
WHERE proprty_id IN (
    SELECT property_id FROM review
    GROUP BY property_id
    HAVING AVG(rating) >= 4.0
)
ORDER BY property_id;

-- Using corelated SubQueries to get all User who have made more that 3 bookings
SELECT * FROM "user"
WHERE (
    SELECT COUNT(booking_id) FROM booking
    WHERE booking.user_id = "user".user_id
) > 3


-- noncorrelated subquery use. same problem as above
-- SELECT * from "user"
-- WHERE user_id IN (
--    SELECT user_id FROM booking
--    GROUP BY user_id
--    HAVING COUNT(booking_id) > 3
-- )
-- ORDER BY user_id;