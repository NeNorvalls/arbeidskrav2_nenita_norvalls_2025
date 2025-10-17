# 💡 SQL Commands Used — Explanation and Purpose

This section explains all SQL commands used in the `ga_bibliotek` project —  
what each does, why it’s needed, and how it contributes to the database design.

---

## 1) Database and Table Structure Commands (DDL)

### `DROP DATABASE IF EXISTS ga_bibliotek;`
-- • Removes the existing database if it already exists.  
-- • Prevents errors when re-running the script.  
-- • Used to reset the workspace before creating a fresh database.

---

### `CREATE DATABASE ga_bibliotek CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
-- • Creates a new database called `ga_bibliotek`.  
-- • Uses `utf8mb4` encoding to support Norwegian letters (æøå) and Unicode text.  
-- • Ensures correct text storage and sorting.

---

### `USE ga_bibliotek;`
-- • Activates the `ga_bibliotek` database.  
-- • All following table commands and queries will use this database.

---

### `CREATE TABLE ... ( ... ) ENGINE = InnoDB;`
-- • Creates a new table structure with columns, data types, and constraints.  
-- • `ENGINE = InnoDB` allows foreign keys and supports transactions.  
-- • Defines how data is stored and related across tables.

---

### `PRIMARY KEY`
-- • Ensures each record in the table has a unique identifier.  
-- • Prevents duplicate entries for the same item or person.

---

### `FOREIGN KEY (...) REFERENCES ...`
-- • Creates relationships between tables.  
-- • Ensures data in child tables matches valid data in parent tables.  
-- • Maintains referential integrity throughout the database.

---

### `ON UPDATE CASCADE`
-- • Automatically updates related records if a referenced key changes.  
-- • Keeps data synchronized between linked tables.

---

### `ON DELETE RESTRICT`
-- • Prevents deletion of records that are still referenced in other tables.  
-- • Protects important data from being removed accidentally.

---

### `CHECK (...)`
-- • Adds a logical rule for column values.  
-- • Ensures only valid and meaningful data can be inserted.

---

### `AUTO_INCREMENT`
-- • Automatically generates unique ID numbers for new records.  
-- • Commonly used for borrower IDs (`LNr`) and loan numbers (`UtlånsNr`).

---

### `DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci`
-- • Ensures consistent character encoding for all tables.  
-- • Supports full Unicode including Norwegian characters (æøå).

---

## 2) Data Manipulation Commands (DML)

### `INSERT INTO ... VALUES (...);`
-- • Adds new records into a table.  
-- • Used to insert data for books, copies, borrowers, and loans.

---

### `ON DUPLICATE KEY UPDATE`
-- • Updates existing data instead of inserting duplicates.  
-- • Ensures unique records such as ISBN or borrower ID remain consistent.

---

### `UPDATE ... SET ... WHERE ...;`
-- • Modifies existing records that meet a specific condition.  
-- • Used to update borrower details or other information.

---

## 3) Reading and Reporting Data (SELECT)

### `SELECT ... FROM ...;`
-- • Retrieves data from one or more tables.  
-- • Used to display, analyze, and verify database content.

---

### `*` (Asterisk)
-- • Selects all columns from the specified table.  
-- • Useful for quick overviews or testing.

---

### `JOIN`
-- • Combines data from two or more related tables.  
-- • Returns only matching records based on relationships.

---

### `LEFT JOIN`
-- • Returns all rows from the left table, even if no matches exist in the right table.  
-- • Useful for showing books with or without loans.

---

### `ON`
-- • Defines how tables are connected in a join.  
-- • Specifies matching columns for relationships.

---

### `AS`
-- • Creates a short alias for a table or column name.  
-- • Makes complex SQL queries easier to read and write.

---

### `WHERE`
-- • Filters results based on a condition.  
-- • Used to select only the rows that meet specific criteria.

---

### `GROUP BY`
-- • Groups rows with the same values for aggregate functions like `COUNT()`.  
-- • Used to summarize results per book, borrower, or author.

---

### `COUNT()`
-- • Counts the number of rows or matching records.  
-- • Commonly used for counting loans or copies.

---

### `ORDER BY`
-- • Sorts query results in ascending or descending order.  
-- • Used to organize output clearly by name, date, or count.

---

### `IS NULL`
-- • Finds records where no matching data exists.  
-- • Used to identify books that were never borrowed.

---

## 💡 SQL Command Categories and Their Purposes

This section explains each main category of SQL commands used in the `ga_bibliotek` project.  
It describes what they do, why they’re important, and how they help keep the database functional, accurate, and well-organized.

---

### 🧱 DDL (CREATE, DROP, FK, PK, etc.)
-- • DDL stands for **Data Definition Language**.  
-- • These commands define and protect the **structure** of the database.  
-- • They are responsible for creating, deleting, or altering databases and tables.

**Purpose:**  
- To build the foundation of the `ga_bibliotek` database.  
- To define how tables like `bok`, `låner`, `utlån`, and `eksemplar` are structured.  
- To ensure every table has a **primary key** and **foreign key** for correct linking.  
- To maintain integrity when data is added, updated, or deleted.  
- Examples include: `CREATE DATABASE`, `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`.

---

### ✏️ DML (INSERT, UPDATE)
-- • DML stands for **Data Manipulation Language**.  
-- • These commands work **inside** the tables to manage the actual data.  
-- • They add, edit, or remove the information stored in each table.

**Purpose:**  
- To insert new records such as books, borrowers, and loan data.  
- To update existing details (for example, changing a borrower’s address).  
- To make sure data can be safely added and updated without duplication.  
- To demonstrate real data management within the designed structure.  
- Examples include: `INSERT INTO`, `UPDATE`, `ON DUPLICATE KEY UPDATE`.

---

### 📊 SELECT / JOIN / GROUP BY
-- • These commands are used for **reading**, **analyzing**, and **reporting** data.  
-- • They combine multiple tables and summarize their information.

**Purpose:**  
- To display which borrower borrowed which book and when.  
- To count how many copies or loans each book or borrower has.  
- To connect related data using `JOIN` between tables (e.g., `låner` ↔ `utlån`).  
- To summarize results by category, like total loans per book or author using `GROUP BY`.  
- Examples include: `SELECT`, `JOIN`, `LEFT JOIN`, `GROUP BY`, `COUNT()`.

---

### 🔎 ORDER BY / WHERE
-- • These commands help **filter** and **organize** query results.  
-- • `WHERE` sets specific conditions for which data should appear.  
-- • `ORDER BY` sorts the final results in a chosen order (ascending or descending).

**Purpose:**  
- To show only relevant data (for example, books published after 2000).  
- To sort reports clearly by title, author, or number of loans.  
- To make data easier to read and logically organized.  
- Examples include: `WHERE`, `ORDER BY`, `IS NULL`.

---

### 🧩 CHECK / CASCADE / RESTRICT
-- • These are **data integrity constraints** that protect the quality and consistency of data.  
-- • They ensure that every value entered into the database is valid and logically correct.

**Purpose:**  
- `CHECK` — Ensures logical values (e.g., pages must be > 0, status must be 0 or 1).  
- `ON UPDATE CASCADE` — Automatically updates linked data when a key changes.  
- `ON DELETE RESTRICT` — Prevents deletion of records still in use by other tables.  
- Together, these maintain **referential integrity** and prevent broken links between data.  
- Examples include: `CHECK (...)`, `ON UPDATE CASCADE`, `ON DELETE RESTRICT`.

---

✅ **In Summary:**  
These five categories of SQL commands work together to make the `ga_bibliotek` database:  
- **Structured** – through DDL commands that define tables and keys.  
- **Functional** – through DML commands that add and update real data.  
- **Informative** – through SELECT and JOIN queries that generate reports.  
- **Organized** – through WHERE and ORDER BY filters for clarity.  
- **Protected** – through constraints like CHECK, CASCADE, and RESTRICT to ensure data accuracy and safety.

---


