-- aggregations_and_window_functions.sql
-- This script demonstrates the use of aggregations and window functions in SQL.


-- Quesry to Finfd the total number of bookings made by each user using the xount and groupby function
SELECT booking.user_id, COUNT(booking.user_id) AS total_bookings
FROM booking
GROUP BY booking.user_id;

-- Query to rank properies based on the total number of bookings they have received
-- This query uses the RANK() to rank properties based on the total number of bookings they have gotten
SELECT property.property_id, COUNT(booking.property_id) AS total_bookings,
       RANK() OVER (ORDER BY COUNT(booking.property_id) DESC) AS property_rank
FROM property
LEFT JOIN booking ON property.property_id = booking.property_id
GROUP BY property.property_id, property.name
ORDER BY property_rank;


-- Query to rank properties based on the total number of bookings they have received using ROW_NUMBER
-- SELECT property.property_id, property.name, COUNT(booking.property_id) AS total_bookings,
--       ROW_NUMBER() OVER (ORDER BY COUNT(booking.property_id) DESC) AS property_rank
-- FROM property
-- LEFT JOIN booking ON property.property_id = booking.property_id
-- GROUP BY property.property_id, property.name
-- ORDER BY property_rank;

