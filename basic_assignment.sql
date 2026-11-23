-- select  current_database(), current_user;


-- Assignment answers are as follows


CREATE table authors (
author_id INT primary KEY,
author_name VARCHAR(100) NOT NULL,
country VARCHAR(100)
)



CREATE table books (
book_id INT primary KEY,
book_title VARCHAR(100) NOT null,
author_id INT,
category VARCHAR(50), 
price DECIMAL(10,2),
published_year INT
)



insert into authors (author_id, author_name, country) values
(1, 'JK Rowling', 'UK'),
(2, 'R. Tagore', 'India'),
(3, 'Shakespeare', 'UK'),
(4, 'Frank herbert', 'UK'),
(5, 'RK narayan', 'UK')



INSERT INTO books (book_id, book_title, author_id, category, price, published_year) VALUES
    (1,  'Harry Potter and the Philosopher''s Stone', 1, 'Fantasy',  399.00, 1997),
    (2,  'Harry Potter and the Chamber of Secrets',   1, 'Fantasy',  429.00, 1998),
    (3,  'Gitanjali',                                 2, 'Poetry',   199.00, 1910),
    (4,  'The Home and the World',                    2, 'Fiction',  249.00, 1916),
    (5,  'Hamlet',                                    3, 'Drama',    149.00, 1603),
    (6,  'Macbeth',                                   3, 'Drama',    149.00, 1623),
    (7,  'Dune',                                      4, 'Sci-Fi',   499.00, 1965),
    (8,  'Dune Messiah',                              4, 'Sci-Fi',   449.00, 1969),
    (9,  'Malgudi Days',                              5, 'Fiction',  229.00, 1943),
    (10, 'The Guide',                                 5, 'Fiction',  279.00, 1958);


INSERT INTO books (book_id, book_title, author_id, category, price, published_year) VALUES
    (11, 'Harry Potter and the Goblet of Fire',          1, 'Fantasy', 749.00, 2000),
    (12, 'Children of Dune',                             4, 'Sci-Fi',  799.00, 1976),
    (13, 'The Complete Works of Shakespeare',            3, 'Drama',   949.00, 1623),
    (14, 'The Collected Poems and Plays of Tagore',      2, 'Poetry',  999.00, 1936);
    
 

INSERT INTO authors (author_id, author_name, country)
VALUES (6, 'Eric Matthes', 'USA');

INSERT INTO books (book_id, book_title, author_id, category, price, published_year)
VALUES (15, 'Python Crash Course, 3rd Edition', 6, 'Programming', 599.00, 2023);


-- Section 1: Basic Queries


-- Task 1: Display all books.
SELECT * FROM authors;

-- Task 2: Display only the book title and price.
SELECT book_title, price FROM books ;

-- Task 3: Display the book title as Book Name and price as Book Price using column aliases.
SELECT book_title AS "Book_Name", price AS "Book_price";
FROM books;

 -- Task 4: Display all unique book categories.
SELECT DISTINCT(category) FROM books;

-- Section 2: Filtering Data

-- Task 5: Display books priced above ₹700

SELECT * FROM books WHERE price > 700 ORDER BY price;
	
-- Task 6: Display books priced between ₹500 and ₹800.
	
SELECT * FROM books WHERE price BETWEEN 500 AND 800;

-- Task 7: Display books that belong to the Programming category.
	SELECT * FROM books WHERE category = 'Programming';

-- Task 8: Display books whose titles start with the letter S.
-- all books i have so any of the title doesnt start with s so i am using T
SELECT * FROM books WHERE book_title LIKE 'T%';


-- Task 9: Display books published after 2020.
 SELECT * FROM books WHERE published_year > 2000;

 
 -- Task 10: Display books sorted by price in descending order.
 SELECT * FROM books ORDER BY price DESC;
 
 
 
 -- Task 11: Display the top 3 most expensive books.
  SELECT * FROM books ORDER BY price DESC LIMIT 3;
 
 /*
 Task 12: Find:
Total number of books
Total price of all books
Average book price
Highest book price
Lowest book price
*/
 
 SELECT Count(*) AS total_price FROM books;
 SELECT sum(price) AS sum_price FROM books;
 SELECT AVG(price) AS average_price FROM books;
 SELECT max(price) AS maximum_price FROM books;
 SELECT min(price) AS minimum_price FROM books; 
 
 
 
 -- Task 13: Display the average book price for each category.
 
 SELECT category, AVG(price) FROM books GROUP BY category;
 
 
 -- Task 14: Display only those categories whose average book price is greater than ₹650.
 -- no category had avg book price greater than 650 so i used 450
 
 SELECT category FROM books GROUP BY category HAVING AVG(price) > 450;
 
 
 
 -- Task 15: Display each book along with its author's name using an INNER JOIN.
 
 SELECT a.author_name, b.book_title, b.category, b.published_year, b.price
 FROM books b 
 JOIN authors a ON a.author_id = b.author_id;
 
-- Task 16: Display all authors along with the books they have written using a LEFT JOIN.

SELECT a.author_name, b.book_title, b.published_year, b.price
FROM authors a
LEFT JOIN books b ON b.author_id = a.author_id;

-- Task 17: Display all books along with their author details using a RIGHT JOIN.
SELECT b.book_id, b.book_title, b.category, b.price, b.published_year,
       a.author_id, a.author_name, a.country
FROM authors a
RIGHT JOIN books b ON a.author_id = b.author_id;


-- Task 18: Insert a new book into the Books table.
INSERT INTO books (book_id, book_title, author_id, category, price, published_year)
VALUES (16, 'Swami and Friends', 5, 'Fiction', 259.00, 1935);

SELECT * FROM books WHERE book_id = 16;

-- Task 19: Update the price of the book you inserted.

UPDATE books
SET price = 500
WHERE book_id = 16;

SELECT * FROM books WHERE book_id = 16;

-- Task 20: Delete the book record that you inserted.
DELETE FROM books
WHERE book_id = 16;

SELECT * FROM books WHERE book_id = 16;

/*
Task 21: Create a new table named Publishers with the following columns:
publisher_id
publisher_name
country
established_year
Apply the following constraints:
PRIMARY KEY
NOT NULL
UNIQUE
*/

CREATE table publishers (
publisher_id INT primary KEY,
publisher_name VARCHAR(100) NOT NULL UNIQUE ,
country VARCHAR(100),
established_year INT
)



