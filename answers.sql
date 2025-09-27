-- 1. library_db.sql
-- Library Management System schema (MySQL 8+)
CREATE DATABASE library_db;
USE library_db;

-- 2. Publishers
CREATE TABLE publishers (
publisher_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL UNIQUE,
address TEXT,
website VARCHAR(255),
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- Insert Values
INSERT INTO publishers (name, address, website)
VALUES
('Oxford Press', '123 Main St, Nairobi', 'https://oxford.example'),
('Pearson Education', '45 Kenyatta Ave, Nairobi', 'https://pearson.example'),
('McGraw Hill', '78 Moi Avenue, Mombasa', 'https://mcgrawhill.example'),
('Longhorn Publishers', '12 Kimathi St, Nairobi', 'https://longhorn.example'),
('East African Educational Publishers', '56 Uhuru Highway, Kisumu', 'https://eaep.example');

-- 3. Authors
CREATE TABLE authors (
author_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
bio TEXT,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
UNIQUE KEY ux_author_name (first_name, last_name)
);

-- Insert Authors Values
INSERT INTO authors (first_name, last_name, bio) VALUES
('Jane', 'Austen', 'English novelist known for works on British society.'),
('Mark', 'Twain', 'American writer and humorist.'),
('Chinua', 'Achebe', 'Nigerian novelist, poet, and critic, author of "Things Fall Apart".'),
('Ngugi', 'wa Thiong\'o', 'Kenyan writer and academic, known for literature in Gikuyu and English.'),
('George', 'Orwell', 'English novelist, essayist, and critic, author of "1984" and "Animal Farm".'),
('Maya', 'Angelou', 'American poet, singer, and civil rights activist.');

-- 4. Categories
CREATE TABLE categories (
category_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL UNIQUE,
description TEXT
);

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Fiction', 'Literary works of imaginative narration'),
('Science', 'Books related to scientific topics'),
('History', 'Books that explore past events and civilizations'),
('Biography', 'Life stories of notable individuals'),
('Children', 'Books written specifically for young readers');

-- 5.Members
CREATE TABLE members (
member_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
email VARCHAR(255) NOT NULL UNIQUE,
phone VARCHAR(20),
address TEXT,
join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
is_active TINYINT(1) NOT NULL DEFAULT 1
);

-- Sample Members
INSERT INTO members (first_name, last_name, email, phone, address) VALUES
('Alice', 'Wanjiku', 'alice@example.com', '0712345678', 'Nairobi'),
('Bob', 'Otieno', 'bob@example.com', '0723456789', 'Mombasa'),
('Cynthia', 'Mwangi', 'cynthia@example.com', '0734567890', 'Kisumu'),
('David', 'Kamau', 'david@example.com', '0745678901', 'Nakuru'),
('Evelyn', 'Mutiso', 'evelyn@example.com', '0756789012', 'Eldoret'),
('Francis', 'Njoroge', 'francis@example.com', '0767890123', 'Thika'),
('Grace', 'Achieng', 'grace@example.com', '0778901234', 'Kakamega');

-- 6. Books
CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(20) UNIQUE,
  title VARCHAR(255) NOT NULL,
  publisher_id INT,
  publication_year YEAR,
  copies_total INT NOT NULL DEFAULT 1,
  copies_available INT NOT NULL DEFAULT 1,
  description TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id)
    REFERENCES publishers(publisher_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CHECK (copies_total >= 0),
  CHECK (copies_available >= 0 AND copies_available <= copies_total)
);

-- Sample Books
INSERT INTO books (isbn, title, publisher_id, publication_year, copies_total, copies_available, description) VALUES
('978-1234567890', 'Pride and Prejudice', 1, 1813, 5, 5, 'Classic novel by Jane Austen.'),
('978-0987654321', 'Adventures of Huckleberry Finn', 2, 1884, 3, 3, 'Classic American novel by Mark Twain.'),
('978-1111111111', 'Things Fall Apart', 3, 1958, 4, 4, 'Seminal African novel by Chinua Achebe.'),
('978-2222222222', 'Petals of Blood', 4, 1977, 6, 6, 'Kenyan novel by Ngugi wa Thiong\'o.'),
('978-3333333333', '1984', 5, 1949, 7, 7, 'Dystopian novel by George Orwell.');


-- 7. Book <-> Author (Many-to-Many)
CREATE TABLE book_authors (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(author_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sample Book-Authors
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), -- Pride and Prejudice → Jane Austen
(2, 2), -- Adventures of Huckleberry Finn → Mark Twain
(3, 3), -- Things Fall Apart → Chinua Achebe
(4, 4), -- Petals of Blood → Ngugi wa Thiong'o
(5, 5); -- 1984 → George Orwell

-- 8.Book <-> Category (Many-to-Many)
CREATE TABLE book_categories (
  book_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (book_id, category_id),
  CONSTRAINT fk_bc_book FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bc_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sample Book-Categories
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), -- Pride and Prejudice → Fiction
(2, 1), -- Adventures of Huckleberry Finn → Fiction
(3, 1), -- Things Fall Apart → Fiction
(3, 3), -- Things Fall Apart → History
(4, 1), -- Petals of Blood → Fiction
(4, 3), -- Petals of Blood → History
(5, 1), -- 1984 → Fiction
(5, 3), -- 1984 → History
(5, 2); -- 1984 → Science (dystopian/social science themes)

-- 9.Library Card (One-to-One with Member)
CREATE TABLE library_cards (
  card_id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL UNIQUE,  -- enforces one-to-one: one card per member
  barcode VARCHAR(64) NOT NULL UNIQUE,
  issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  expiry_date DATE,
  CONSTRAINT fk_card_member FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sample Library Cards
INSERT INTO library_cards (member_id, barcode, expiry_date) VALUES
(3, 'CARD1003', '2026-09-23'),
(4, 'CARD1004', '2026-09-23'),
(5, 'CARD1005', '2026-09-23'),
(6, 'CARD1006', '2026-09-23'),
(7, 'CARD1007', '2026-09-23');


-- Loans (One-to-Many: card -> loans)
CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  card_id INT NOT NULL,
  loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  due_date DATE NOT NULL,
  return_date DATE,
  status ENUM('on-loan','returned','overdue','lost') NOT NULL DEFAULT 'on-loan',
  CONSTRAINT fk_loans_book FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_loans_card FOREIGN KEY (card_id) REFERENCES library_cards(card_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CHECK (due_date >= loan_date)
);

-- Sample Loans
INSERT INTO loans (book_id, card_id, due_date, return_date, status) VALUES
(3, 3, '2025-10-20', NULL, 'on-loan'),         -- Cynthia borrowed "Things Fall Apart"
(4, 4, '2025-10-22', '2025-10-18', 'returned'),-- David borrowed "Petals of Blood" and returned it early
(5, 5, '2025-10-25', NULL, 'on-loan'),         -- Evelyn borrowed "1984"
(2, 6, '2025-10-12', NULL, 'overdue'),         -- Francis borrowed "Adventures of Huckleberry Finn" but overdue
(1, 7, '2025-10-30', NULL, 'lost');            -- Grace borrowed "Pride and Prejudice" but reported lost

-- Reservations
CREATE TABLE reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  card_id INT NOT NULL,
  reserved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP,
  status ENUM('active','fulfilled','cancelled','expired') NOT NULL DEFAULT 'active',
  CONSTRAINT fk_res_book FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_res_card FOREIGN KEY (card_id) REFERENCES library_cards(card_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Sample Reservations
INSERT INTO reservations (book_id, card_id, expires_at, status) VALUES
(2, 3, '2025-10-01', 'active'),     -- Cynthia reserved "Adventures of Huckleberry Finn"
(3, 4, '2025-10-02', 'fulfilled'),  -- David reserved "Things Fall Apart" and got it
(4, 5, '2025-10-03', 'cancelled'),  -- Evelyn cancelled her reservation for "Petals of Blood"
(5, 6, '2025-10-04', 'active'),     -- Francis reserved "1984"
(1, 7, '2025-10-05', 'expired');    -- Grace reserved "Pride and Prejudice" but it expired


-- Fines
CREATE TABLE fines (
  fine_id INT AUTO_INCREMENT PRIMARY KEY,
  loan_id INT NOT NULL,
  amount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  is_paid TINYINT(1) NOT NULL DEFAULT 0,
  issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  paid_at TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT fk_fines_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sample Fines
INSERT INTO fines (loan_id, amount, is_paid, paid_at) VALUES
(2, 30.00, 1, '2025-09-25 10:15:00'), -- Loan 2: fine paid
(3, 20.00, 0, NULL),                  -- Loan 3: fine not yet paid
(4, 15.00, 1, '2025-09-26 14:30:00'), -- Loan 4: fine paid
(5, 40.00, 0, NULL),                  -- Loan 5: overdue/lost fine pending
(6, 100.00, 0, NULL);                 -- Loan 6: lost book fine unpaid


-- END OF SCHEMA
