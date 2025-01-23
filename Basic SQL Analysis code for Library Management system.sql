-- Library Management System Project 2

-- BASIC SQL Operations
-- 1. Database Setup

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
	(
		branch_id VARCHAR (10) PRIMARY KEY,
		manager_id VARCHAR (10),
		branch_address VARCHAR (55),
		contact_no VARCHAR (10)
	);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(25),
		position VARCHAR(15),
		salary INT,
		branch_id VARCHAR (25) -- FK
	);

DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
		isbn VARCHAR (20) PRIMARY KEY,
		book_title VARCHAR(75),
		category VARCHAR(25),
		rental_price FLOAT,
		status VARCHAR(15),
		author VARCHAR(35),
		publisher VARCHAR(55)
	);

ALTER TABLE books
ALTER column category TYPE VARCHAR(20)

DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
		member_id  VARCHAR(10) PRIMARY KEY,
		member_name VARCHAR(25),
		member_address VARCHAR(75),
		reg_date DATE
	);


DROP TABLE issued_status;
CREATE TABLE issued_status
	(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10), -- FK
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(25), -- FK
	issued_emp_id VARCHAR(10) -- FK
	);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
		return_id VARCHAR(10) PRIMARY KEY,
		issued_id VARCHAR(10),
		return_book_name VARCHAR(75),
		return_date DATE,
		return_book_isbn VARCHAR(20)
	);

--FOREIGN KEY

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

--  2. CRUD Operations
-- Create: Inserted sample records into the books table.
-- Read: Retrieved and displayed data from various tables.
-- Update: Updated records in the employees table.
-- Delete: Removed records from the members table as needed.

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
SELECT * FROM members;

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT (issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1

-- 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**


CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2

SELECT * FROM book_cnts
ORDER BY no_issued DESC;

-- 4. Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1

-- 10. List Members Who Registered in the Last 360 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '360 days'

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C130', 'sam', '145 Main St', '2024-06-01'),
('C131', 'john', '133 Main St', '2024-05-01');

-- 10. List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	el.*,
	b.manager_id,
	e2.emp_name as manager	
FROM employees as el
JOIN 
branch as b
ON b.branch_id = el.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE books_price_greater_than_seven
AS
SELECT * FROM Books
WHERE rental_price > 7

SELECT * FROM books_price_greater_than_seven

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
	DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

SELECT * FROM return_status