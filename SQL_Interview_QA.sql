/*
SQL INTERVIEW PREPARATION — QUESTIONS, ANSWERS, AND QUERY EXAMPLES
Dialect: MySQL 8.0

IMPORTANT: The setup below drops tables named employees and departments.
Use a practice database only; do not run it against important data.
Run the setup section first, then try the example queries.
*/

-- =========================================================
-- 1. DATABASE FUNDAMENTALS
-- =========================================================
-- Q1. What is a database?
-- Answer: An organized collection of data that can be stored, accessed, and managed.
-- Q2. What is a DBMS?
-- Answer: Software used to create and manage databases. MySQL is a relational DBMS.
-- Q3. What is SQL?
-- Answer: Structured Query Language is used to define, retrieve, and manipulate relational data.
-- Q4. What are DDL, DML, DQL, DCL, and TCL?
-- DDL: CREATE, ALTER, DROP, TRUNCATE
-- DML: INSERT, UPDATE, DELETE
-- DQL: SELECT (often categorized separately)
-- DCL: GRANT, REVOKE
-- TCL: COMMIT, ROLLBACK, SAVEPOINT

-- =========================================================
-- 2. SAMPLE DATABASE SETUP (MySQL 8.0)
-- =========================================================
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    job_title VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE,
    department_id INT,
    manager_id INT,
    CONSTRAINT chk_salary CHECK (salary >= 0),
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

INSERT INTO departments VALUES
(10, 'Engineering', 'Pune'),
(20, 'HR', 'Mumbai'),
(30, 'Finance', 'Pune'),
(40, 'Marketing', 'Delhi');

INSERT INTO employees VALUES
(1, 'Asha', 'asha@example.com', 'Manager', 90000.00, '2020-01-15', 10, NULL),
(2, 'Ravi', 'ravi@example.com', 'Developer', 65000.00, '2021-06-10', 10, 1),
(3, 'Meera', 'meera@example.com', 'Developer', 70000.00, '2022-03-20', 10, 1),
(4, 'Karan', 'karan@example.com', 'HR Executive', 50000.00, '2021-09-01', 20, NULL),
(5, 'Sara', 'sara@example.com', 'Accountant', 60000.00, '2023-02-11', 30, NULL),
(6, 'Vikram', 'vikram@example.com', 'Analyst', 55000.00, '2022-11-05', 30, NULL),
(7, 'Nina', 'nina@example.com', 'Marketing Executive', 48000.00, '2024-01-08', 40, NULL),
(8, 'Ishaan', 'ishaan@example.com', 'Intern', 25000.00, '2024-06-01', 10, 2);

-- =========================================================
-- 3. DATA TYPES, SELECT, WHERE, ORDER BY
-- =========================================================
-- Q5. Common types: INT, DECIMAL, VARCHAR, CHAR, DATE, DATETIME, TIMESTAMP, BOOLEAN.
-- In MySQL, BOOLEAN is an alias for TINYINT(1).

-- Q6. Select all columns.
SELECT * FROM employees;

-- Q7. Select specific columns.
SELECT employee_name, job_title, salary FROM employees;

-- Q8. Filter rows using WHERE.
SELECT employee_name, salary FROM employees WHERE salary > 60000;

-- Q9. Combine conditions with AND and OR.
SELECT employee_name, salary, department_id
FROM employees
WHERE salary >= 50000 AND department_id = 10;

SELECT employee_name, department_id
FROM employees
WHERE department_id = 10 OR department_id = 30;

-- Q10. IN, BETWEEN, LIKE, and IS NULL.
SELECT employee_name FROM employees WHERE department_id IN (10, 30);
SELECT employee_name, salary FROM employees WHERE salary BETWEEN 50000 AND 70000;
SELECT employee_name FROM employees WHERE employee_name LIKE 'S%';
SELECT employee_name FROM employees WHERE manager_id IS NULL;

-- Q11. Sort results.
SELECT employee_name, salary FROM employees ORDER BY salary DESC;
SELECT employee_name, department_id, salary
FROM employees ORDER BY department_id ASC, salary DESC;

-- Q12. DISTINCT returns unique values.
SELECT DISTINCT department_id FROM employees;

-- =========================================================
-- 4. AGGREGATES, GROUP BY, HAVING
-- =========================================================
-- Q13. Aggregate functions calculate one result from multiple rows:
-- COUNT(), SUM(), AVG(), MIN(), MAX().
SELECT COUNT(*) AS employee_count FROM employees;

SELECT SUM(salary) AS total_salary,
       AVG(salary) AS average_salary,
       MIN(salary) AS minimum_salary,
       MAX(salary) AS maximum_salary
FROM employees;

-- Q14. Count employees in each department.
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;

-- Q15. WHERE vs HAVING:
-- WHERE filters rows before grouping; HAVING filters groups after GROUP BY.
SELECT department_id, AVG(salary) AS average_salary
FROM employees
WHERE salary >= 25000
GROUP BY department_id
HAVING AVG(salary) > 55000;

-- Q16. Departments with at least two employees.
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 2;

-- Q17. COUNT(*) counts rows; COUNT(column) counts non-NULL values in that column.

-- =========================================================
-- 5. JOINS
-- =========================================================
-- Q18. INNER JOIN returns matching rows from both tables.
SELECT e.employee_name, d.department_name
FROM employees AS e
INNER JOIN departments AS d
ON e.department_id = d.department_id;

-- LEFT JOIN returns all rows from the left table and matching rows from the right.
SELECT d.department_name, e.employee_name
FROM departments AS d
LEFT JOIN employees AS e
ON d.department_id = e.department_id
ORDER BY d.department_id, e.employee_name;

-- Find departments with no employees.
SELECT d.department_name
FROM departments AS d
LEFT JOIN employees AS e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- Self join: each employee and their manager.
SELECT e.employee_name AS employee, m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

-- =========================================================
-- 6. SUBQUERIES
-- =========================================================
-- Q19. A subquery is a query nested inside another query.
-- Employees earning more than the overall average.
SELECT employee_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees earning more than their department's average.
SELECT e.employee_name, e.salary, e.department_id
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);

-- Employees in Engineering.
SELECT employee_name
FROM employees
WHERE department_id = (
    SELECT department_id FROM departments
    WHERE department_name = 'Engineering'
);

-- =========================================================
-- 7. COMMON INTERVIEW QUERY PROBLEMS
-- =========================================================
-- Q20. Find the second-highest distinct salary.
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Q21. Highest-paid employee(s) in each department.
SELECT e.employee_name, e.department_id, e.salary
FROM employees AS e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);

-- Q22. Find duplicate values in a column (example pattern; email in our sample is UNIQUE).
-- SELECT email, COUNT(*) AS occurrences
-- FROM some_table
-- GROUP BY email
-- HAVING COUNT(*) > 1;

-- Q23. Employees hired after 1 January 2022.
SELECT employee_name, hire_date
FROM employees
WHERE hire_date > '2022-01-01'
ORDER BY hire_date;

-- Q24. This UPDATE changes data; uncomment only when you intend to do it.
-- UPDATE employees SET salary = salary * 1.05 WHERE department_id = 10;

-- =========================================================
-- 8. CTEs
-- =========================================================
-- Q25. A Common Table Expression is a named result set defined using WITH
-- and available to the statement that follows it.
WITH department_averages AS (
    SELECT department_id, AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT department_id, average_salary
FROM department_averages
WHERE average_salary > 55000;

-- =========================================================
-- 9. WINDOW FUNCTIONS
-- =========================================================
-- Q26. Window functions calculate across related rows without collapsing rows
-- into one row per group, unlike GROUP BY.
SELECT employee_name, department_id, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- Rank employees within each department.
SELECT employee_name, department_id, salary,
       ROW_NUMBER() OVER (
           PARTITION BY department_id ORDER BY salary DESC
       ) AS row_num
FROM employees;

-- Top two employees per department by salary.
WITH ranked_employees AS (
    SELECT employee_name, department_id, salary,
           ROW_NUMBER() OVER (
               PARTITION BY department_id ORDER BY salary DESC
           ) AS row_num
    FROM employees
)
SELECT employee_name, department_id, salary
FROM ranked_employees
WHERE row_num <= 2;

-- ROW_NUMBER: unique sequential number.
-- RANK: ties share rank; gaps can follow ties.
-- DENSE_RANK: ties share rank; no gaps follow ties.

-- =========================================================
-- 10. CONSTRAINTS AND KEYS
-- =========================================================
-- Q27. Constraints enforce rules: NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY,
-- CHECK, and DEFAULT.
-- Q28. A PRIMARY KEY uniquely identifies each row and cannot be NULL.
-- A table has one primary-key constraint, which can consist of multiple columns.
-- Q29. A FOREIGN KEY references a key in another or the same table and helps
-- enforce referential integrity.
-- Q30. PRIMARY KEY vs UNIQUE: primary keys cannot be NULL and identify rows;
-- UNIQUE prevents duplicate non-NULL values. MySQL permits multiple NULLs
-- in a UNIQUE index.

-- =========================================================
-- 11. INDEXES AND QUERY OPTIMIZATION
-- =========================================================
-- Q31. An index can speed up lookups and sorting, but takes storage and can
-- increase the cost of INSERT, UPDATE, and DELETE.
-- Create an index only when appropriate for your workload:
-- CREATE INDEX idx_employees_department_salary ON employees (department_id, salary);

-- Q32. EXPLAIN shows how MySQL plans to execute a query.
EXPLAIN
SELECT employee_name, salary
FROM employees
WHERE department_id = 10
ORDER BY salary DESC;

-- Optimization tips:
-- 1. Select only columns you need instead of always using SELECT *.
-- 2. Consider indexes for selective filters and join columns.
-- 3. Use EXPLAIN and measure before changing indexes.
-- 4. Avoid applying functions to indexed columns in WHERE when a range condition works.
-- 5. Indexes do not help every query, especially on tiny tables.

-- =========================================================
-- 12. NORMALIZATION
-- =========================================================
-- Q33. Normalization organizes tables to reduce duplication and avoid anomalies.
-- 1NF: each field contains an atomic value; avoid repeating groups.
-- 2NF: in 1NF and no partial dependency on part of a composite candidate key.
-- 3NF: in 2NF and no inappropriate transitive dependency of non-key attributes.
-- BCNF: every determinant is a candidate key.
-- Design example: store department details once in departments and reference
-- department_id from employees instead of repeating department details per employee.

-- =========================================================
-- 13. TRANSACTIONS AND ACID
-- =========================================================
-- Q34. A transaction is a group of operations treated as a unit.
-- ACID: Atomicity, Consistency, Isolation, Durability.
-- Example only; run intentionally in a test database:
-- START TRANSACTION;
-- UPDATE employees SET salary = salary + 1000 WHERE employee_id = 2;
-- UPDATE employees SET salary = salary - 1000 WHERE employee_id = 3;
-- COMMIT;
-- Use ROLLBACK instead of COMMIT to undo changes before committing.

-- =========================================================
-- 14. QUICK REVISION QUESTIONS
-- =========================================================
-- Q35. DELETE vs TRUNCATE vs DROP?
-- DELETE removes selected rows and supports WHERE.
-- TRUNCATE removes all rows; in MySQL it is DDL and causes an implicit commit.
-- DROP removes the table definition and its data.

-- Q36. UNION vs UNION ALL?
-- UNION removes duplicate rows; UNION ALL keeps duplicates.

-- Q37. What is NULL?
-- NULL represents missing or unknown data. Use IS NULL / IS NOT NULL, not = NULL.

-- Q38. CHAR vs VARCHAR?
-- CHAR is fixed-length; VARCHAR stores variable-length text up to its limit.

-- Q39. What is an alias?
-- An alias gives a column or table a temporary name, often using AS.

-- Q40. What is the logical order of common SELECT clauses?
-- FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT.
-- This is a conceptual processing order, not the written order of the query.

-- End of SQL interview preparation notes.
