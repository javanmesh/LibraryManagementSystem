# Library Management System

A comprehensive database management system for libraries built using MySQL.

## Project Description

This Library Management System provides a complete database infrastructure to manage library operations including:

- Book and author management
- Library member registration and management
- Book borrowing and returning
- Reservation system
- Fine calculation for late returns
- Event management and registration
- Staff information management

The database is designed with a robust relational structure that maintains data integrity through proper constraints and relationships.

## Entity Relationship Diagram

The Entity Relationship Diagram (ERD) showing the database structure is attached in the repo



## Database Features

### Tables and Relationships
- **Members**: Library patrons who can borrow books
- **Books**: Core book information (title, ISBN, etc.)
- **Book Items**: Physical copies of books with status tracking
- **Authors**: Book author information
- **Categories**: Book categories/genres with hierarchical structure
- **Publishers**: Publishing company information
- **Loans**: Records of borrowed books
- **Reservations**: Book reservation system
- **Fines**: Late return penalties
- **Staff**: Library employee information
- **Events**: Library events and programs
- **Junction Tables**: Book-Authors, Book-Categories, Event-Registrations

### Key Features
- Primary Keys (PK) on all tables
- Foreign Keys (FK) for referential integrity
- NOT NULL constraints on required fields
- UNIQUE constraints (e.g., ISBN, email addresses)
- CHECK constraints for data validation
- Default values and timestamps for tracking
- Views for common operations (available books, overdue loans)
- Indexes for performance optimization

## Setup Instructions

1. Clone this repository
2. Open MySQL Workbench or your preferred MySQL client
3. Run the `library_management_system.sql` file to create the database
4. The database will be created with all tables, relationships, constraints, views and indexes

## Database Schema Details

The database includes various relationship types:

- **One-to-Many (1:M)**: Books to Book Items, Members to Loans
- **Many-to-Many (M:M)**: Books to Authors, Books to Categories
- **Self-Referencing**: Categories hierarchy (parent-child relationship)

The schema also includes constraints like:
- CHECK constraints to ensure data validity (e.g., valid email formats)
- UNIQUE constraints to prevent duplicates
- Default values for common fields
- Automatic timestamps for tracking

## Views

The database includes several useful views:
- `available_books`: Shows all books with available copies
- `overdue_loans`: Shows all loans that are currently overdue
- `member_borrowing_history`: Shows the complete borrowing history for each member
- `popular_books`: Shows most frequently borrowed books

## Usage Examples

Here are some example queries you might use:

```sql
-- Find all available books
SELECT * FROM available_books;

-- Find all overdue books
SELECT * FROM overdue_loans;

-- Find borrowing history for a specific member
SELECT * FROM member_borrowing_history WHERE member_id = 1;

-- Find the most popular books in the library
SELECT * FROM popular_books LIMIT 10;
```
