-- Index for searching users by email
CREATE INDEX idx_user_email ON "user"(email);

-- Index for joining/searching bookings by user_id and property_id
CREATE INDEX idx_booking_user_id ON booking(user_id);
CREATE INDEX idx_booking_property_id ON booking(property_id);

-- Index for joining/searching properties by host_id
CREATE INDEX idx_property_host_id ON property(host_id);
CREATE INDEX idx_property_id ON property(property_id);