# Normalization to 3NF

## Objective
Apply normalization principles to ensure the Airbnb database schema adheres to Third Normal Form (3NF), eliminating redundancy and ensuring data integrity.

---
![Normalized Database Schema](./normalized.png)
---

## Step 1: First Normal Form (1NF)
- **Goal**: Eliminate repeating groups and ensure atomicity.
- **Actions Taken**:
  - All tables have atomic columns (no arrays or nested fields).
  - Each column contains a single value per row.
  - Each table has a primary key for unique identification.

✅ **All tables meet 1NF**.

---

## Step 2: Second Normal Form (2NF)
- **Goal**: Ensure all non-key attributes are fully functionally dependent on the primary key.
- **Actions Taken**:
  - No partial dependencies exist because:
    - All primary keys are single-column (UUIDs).
    - Attributes depend fully on the primary key in each table.

✅ **All tables meet 2NF**.

---

## Step 3: Third Normal Form (3NF)
- **Goal**: Eliminate transitive dependencies (non-key → non-key).
- **Actions Taken**:
  - **User Table**: No transitive dependencies; each field relates directly to `user_id`.
  - **Property Table**: `host_id` is a FK to `User`, no derived values like `host_name`.
  - **Booking Table**: `total_price` depends on `booking_id`, and calculated externally.
  - **Review, Payment, Message Tables**: All attributes depend directly on their primary keys.

✅ **All tables meet 3NF**.

---