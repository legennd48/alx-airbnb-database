# Database Advanced Script

This directory contains SQL scripts that demonstrate advanced database operations, particularly focusing on different types of SQL JOINs. These scripts are designed to showcase how to retrieve and manipulate data from multiple related tables in a relational database.

## Files

- **joins_queries.sql**: This script demonstrates the use of various SQL JOIN operations, including:
  - **INNER JOIN**: Retrieves rows with matching data in both tables.
  - **LEFT JOIN**: Retrieves all rows from the left table and the matching rows from the right table, with `NULL` for non-matching rows.
  - **FULL OUTER JOIN**: Retrieves all rows from both tables, with `NULL` for non-matching rows in either table.

## Usage

1. Ensure you have a relational database (e.g., PostgreSQL, MySQL) set up with the required tables (`user`, `booking`, `property`, `review`).
2. Load the SQL script into your database client or execute it using a command-line tool.
3. Review the output of each query to understand how the different JOIN operations work.

## Example Tables

The queries in this script assume the following tables exist in your database:

- **user**: Contains user information (e.g., `user_id`, `name`).
- **booking**: Contains booking details (e.g., `booking_id`, `user_id`).
- **property**: Contains property details (e.g., `property_id`, `name`).
- **review**: Contains reviews for properties (e.g., `review_id`, `property_id`).

## Learning Objectives

By exploring the queries in this script, you will learn:
- How to use different types of JOINs to combine data from multiple tables.
- How to handle scenarios where some rows do not have matching data in related tables.
- How to write efficient and readable SQL queries for complex data retrieval.

## Notes

- Ensure that table and column names match those in your database schema.
- Some table names (e.g., `"user"`) are quoted to avoid conflicts with reserved keywords in SQL.

Feel free to modify the queries to suit your database schema or to experiment with different JOIN conditions.