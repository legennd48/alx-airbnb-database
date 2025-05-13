# Database Advanced Script

This directory contains SQL scripts that demonstrate advanced database operations, particularly focusing on the use of subqueries and JOINs. These scripts are designed to showcase how to retrieve and manipulate data from multiple related tables in a relational database.

## Files

- **joins_queries.sql**: Demonstrates the use of various SQL JOIN operations, including:
  - **INNER JOIN**: Retrieves rows with matching data in both tables.
  - **LEFT JOIN**: Retrieves all rows from the left table and the matching rows from the right table, with `NULL` for non-matching rows.
  - **FULL OUTER JOIN**: Retrieves all rows from both tables, with `NULL` for non-matching rows in either table.

- **subqueries.sql**: Demonstrates the use of subqueries in SQL, including:
  - **Subqueries with `IN`**: Retrieves all properties with an average rating of 4.0 or higher.
  - **Correlated Subqueries**: Retrieves all users who have made more than 3 bookings by dynamically evaluating the subquery for each user.
  - **Non-Correlated Subqueries**: Solves the same problem as the correlated subquery but uses a subquery that is independent of the outer query.

## Usage

1. Ensure you have a relational database (e.g., PostgreSQL, MySQL) set up with the required tables (`user`, `booking`, `property`, `review`).
2. Load the SQL scripts into your database client or execute them using a command-line tool.
3. Review the output of each query to understand how the different SQL operations work.

## Example Tables

The queries in these scripts assume the following tables exist in your database:

- **user**: Contains user information (e.g., `user_id`, `name`).
- **booking**: Contains booking details (e.g., `booking_id`, `user_id`).
- **property**: Contains property details (e.g., `property_id`, `name`).
- **review**: Contains reviews for properties (e.g., `review_id`, `property_id`, `rating`).

## Learning Objectives

By exploring the queries in these scripts, you will learn:
- How to use different types of JOINs to combine data from multiple tables.
- How to use subqueries to filter and aggregate data.
- The difference between correlated and non-correlated subqueries.
- How to write efficient and readable SQL queries for complex data retrieval.

## Notes

- Ensure that table and column names match those in your database schema.
- Some table names (e.g., `"user"`) are quoted to avoid conflicts with reserved keywords in SQL.
- Pay attention to performance considerations when using correlated subqueries, as they can be less efficient for large datasets.

Feel free to modify the queries to suit your database schema or to experiment with different SQL techniques.