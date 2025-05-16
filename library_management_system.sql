-- ========================================================
-- Library Management System Database
-- Created: May 14, 2025
-- ========================================================

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- ========================================================
-- Table structure for MEMBERS
-- ========================================================
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE,
    membership_status ENUM('Active', 'Expired', 'Suspended') DEFAULT 'Active',
    
    -- Ensure email format is valid
    CONSTRAINT chk_email CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
    
    -- Set expiry date to one year after membership date
    CONSTRAINT chk_expiry_date CHECK (membership_expiry >= membership_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Stores information about library members';

-- ========================================================
-- Table structure for CATEGORIES
-- ========================================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    
    -- Self-referencing foreign key to create a category hierarchy
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book categories/genres';

-- ========================================================
-- Table structure for AUTHORS
-- ========================================================
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(50),
    biography TEXT,
    
    -- Create a unique index on author name combination
    UNIQUE INDEX idx_author_name (first_name, last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Information about book authors';

-- ========================================================
-- Table structure for PUBLISHERS
-- ========================================================
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book publishers information';

-- ========================================================
-- Table structure for BOOKS
-- ========================================================
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(50),
    num_pages INT,
    language VARCHAR(50) DEFAULT 'English',
    summary TEXT,
    cover_image_url VARCHAR(255),
    added_date DATE DEFAULT (CURRENT_DATE),
    
    -- Foreign key reference to publishers
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
        
    -- Constraints for valid ISBN and page numbers
    CONSTRAINT chk_isbn CHECK (isbn REGEXP '^[0-9-]{10,17}$'),
    CONSTRAINT chk_pages CHECK (num_pages > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Main book information';

-- ========================================================
-- Table structure for BOOK_AUTHORS (Many-to-Many)
-- ========================================================
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role ENUM('Primary', 'Co-author', 'Editor', 'Translator') DEFAULT 'Primary',
    
    -- Composite primary key
    PRIMARY KEY (book_id, author_id),
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Maps books to their authors (M:M relationship)';

-- ========================================================
-- Table structure for BOOK_CATEGORIES (Many-to-Many)
-- ========================================================
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    
    -- Composite primary key
    PRIMARY KEY (book_id, category_id),
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Maps books to their categories (M:M relationship)';

-- ========================================================
-- Table structure for BOOK_ITEMS (physical copies)
-- ========================================================
CREATE TABLE book_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(100) NOT NULL,
    status ENUM('Available', 'Borrowed', 'Reserved', 'Lost', 'Damaged') DEFAULT 'Available',
    acquisition_date DATE DEFAULT (CURRENT_DATE),
    price DECIMAL(10,2),
    condition ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'New',
    
    -- Foreign key reference to books
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Physical copies of books in the library';

-- ========================================================
-- Table structure for LOANS
-- ========================================================
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATETIME NULL,
    renewal_count INT DEFAULT 0,
    
    -- Foreign keys
    FOREIGN KEY (item_id) REFERENCES book_items(item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- Constraints
    CONSTRAINT chk_due_date CHECK (due_date >= DATE(loan_date)),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date),
    CONSTRAINT chk_renewal CHECK (renewal_count >= 0 AND renewal_count <= 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Records of books borrowed by library members';

-- ========================================================
-- Table structure for FINES
-- ========================================================
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL,
    fine_date DATE DEFAULT (CURRENT_DATE),
    reason VARCHAR(255) NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    payment_date DATETIME NULL,
    
    -- Foreign keys
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- Constraint for positive fine amount
    CONSTRAINT chk_fine_amount CHECK (fine_amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Fines for late returns or damaged books';

-- ========================================================
-- Table structure for RESERVATIONS
-- ========================================================
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    notification_status ENUM('Not Sent', 'Sent', 'Failed') DEFAULT 'Not Sent',
    
    -- Foreign keys
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- Constraint for valid expiry date
    CONSTRAINT chk_res_expiry CHECK (expiry_date > DATE(reservation_date))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book reservations by members';

-- ========================================================
-- Table structure for STAFF
-- ========================================================
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    position VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    status ENUM('Active', 'On Leave', 'Terminated') DEFAULT 'Active',
    password_hash VARCHAR(255) NOT NULL,
    
    -- Constraint for valid email
    CONSTRAINT chk_staff_email CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Library staff information';

-- ========================================================
-- Table structure for EVENTS
-- ========================================================
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    location VARCHAR(100),
    max_attendees INT,
    staff_id INT,
    status ENUM('Scheduled', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    
    -- Foreign key reference to staff (event organizer)
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
        
    -- Constraints for valid event times
    CONSTRAINT chk_event_times CHECK (end_datetime > start_datetime),
    CONSTRAINT chk_max_attendees CHECK (max_attendees > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Library events and programs';

-- ========================================================
-- Table structure for EVENT_REGISTRATIONS (Many-to-Many)
-- ========================================================
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No-show', 'Cancelled') DEFAULT 'Registered',
    
    -- Foreign keys
    FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- Unique constraint to prevent duplicate registrations
    UNIQUE KEY (event_id, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Event registrations by members';

-- ========================================================
-- Views for common operations
-- ========================================================

-- View for available books
CREATE VIEW available_books AS
SELECT b.book_id, b.title, b.isbn, 
       CONCAT(a.first_name, ' ', a.last_name) AS author,
       COUNT(bi.item_id) AS available_copies
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN book_items bi ON b.book_id = bi.book_id
WHERE bi.status = 'Available'
GROUP BY b.book_id, b.title, b.isbn, author;

-- View for overdue loans
CREATE VIEW overdue_loans AS
SELECT l.loan_id, b.title, bi.barcode,
       CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       m.email AS member_email,
       l.loan_date, l.due_date,
       DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM loans l
JOIN book_items bi ON l.item_id = bi.item_id
JOIN books b ON bi.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;

-- View for member borrowing history
CREATE VIEW member_borrowing_history AS
SELECT m.member_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       b.title, l.loan_date, l.due_date, l.return_date,
       CASE 
           WHEN l.return_date IS NULL AND l.due_date < CURRENT_DATE THEN 'Overdue'
           WHEN l.return_date IS NULL THEN 'Borrowed'
           ELSE 'Returned'
       END AS status
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN book_items bi ON l.item_id = bi.item_id
JOIN books b ON bi.book_id = b.book_id
ORDER BY m.member_id, l.loan_date DESC;

-- View for popular books (most borrowed)
CREATE VIEW popular_books AS
SELECT b.book_id, b.title, COUNT(l.loan_id) AS borrow_count
FROM books b
JOIN book_items bi ON b.book_id = bi.book_id
JOIN loans l ON bi.item_id = l.item_id
GROUP BY b.book_id, b.title
ORDER BY borrow_count DESC;

-- ========================================================
-- Index creation for performance optimization
-- ========================================================

-- Index for book searches
CREATE INDEX idx_book_title ON books(title);
CREATE INDEX idx_isbn ON books(isbn);

-- Index for member searches
CREATE INDEX idx_member_name ON members(last_name, first_name);
CREATE INDEX idx_member_email ON members(email);

-- Index for loan status checking
CREATE INDEX idx_loan_status ON loans(due_date, return_date);

-- Index for item availability
CREATE INDEX idx_item_status ON book_items(status);

-- ========================================================
-- End of Library Management System Database
-- ========================================================
