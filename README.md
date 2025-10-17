# Oppgave 2 – Forståelse og forklaring av database design (25%)

Databasen **ga_bibliotek** er designet for å støtte et biblioteksystem hvor brukere kan låne bøker, og biblioteket kan holde oversikt over bøker, eksemplarer, låntakere og utlånstransaksjoner.  
Databasen består av flere tabeller:

- `bok`
- `eksemplar`
- `låner`
- `utlån`

---

## 1.1 bok

| Kolonne | Datatype | Constraints | Beskrivelse |
|----------|-----------|-------------|--------------|
| `ISBN` | VARCHAR(20) | PRIMARY KEY, NOT NULL | Unique book identifier |
| `Tittel` | VARCHAR(255) | NOT NULL | Book title |
| `Forfatter` | VARCHAR(100) | NOT NULL | Author name |
| `Forlag` | VARCHAR(100) | NOT NULL | Publisher name |
| `UtgittÅr` | SMALLINT UNSIGNED | NOT NULL | Year of publication |
| `AntallSider` | INT | NOT NULL, CHECK (AntallSider > 0) | Number of pages |

**Forklaring (English):**  
This table stores information about each book title in the library.  
Each record represents a unique book, identified by its ISBN.

---

## 1.2 eksemplar

| Kolonne | Datatype | Constraints | Beskrivelse |
|----------|-----------|-------------|--------------|
| `ISBN` | VARCHAR(20) | NOT NULL, FOREIGN KEY → bok(ISBN) | Links each copy to its book |
| `EksNr` | INT | NOT NULL | Copy number for the same book |
| **Primary Key** | (`ISBN`, `EksNr`) |  | Ensures each physical copy is unique |

**Forklaring (English):**  
This table represents the physical copies of each book.  
A book can have multiple copies, and the combination of `ISBN` and `EksNr` ensures uniqueness.

---

## 1.3 låner

| Kolonne | Datatype | Constraints | Beskrivelse |
|----------|-----------|-------------|--------------|
| `LNr` | INT | AUTO_INCREMENT, PRIMARY KEY | Unique borrower ID |
| `Fornavn` | VARCHAR(50) | NOT NULL | Borrower’s first name |
| `Etternavn` | VARCHAR(50) | NOT NULL | Borrower’s last name |
| `Adresse` | VARCHAR(255) | NOT NULL | Borrower’s address |

**Forklaring (English):**  
This table stores borrower information for contact and tracking purposes.  
Each borrower is given a unique ID automatically.

---

## 1.4 utlån

| Kolonne | Datatype | Constraints | Beskrivelse |
|----------|-----------|-------------|--------------|
| `UtlånsNr` | INT | AUTO_INCREMENT, PRIMARY KEY | Unique loan transaction number |
| `LNr` | INT | FOREIGN KEY → låner(LNr), NOT NULL | Identifies the borrower |
| `ISBN` | VARCHAR(20) | FOREIGN KEY → eksemplar(ISBN, EksNr), NOT NULL | Identifies the book |
| `EksNr` | INT | FOREIGN KEY → eksemplar(ISBN, EksNr), NOT NULL | Identifies which copy of the book was borrowed |
| `Utlånsdato` | DATE | NOT NULL | The date when the book was borrowed |
| `Levert` | TINYINT(1) | NOT NULL, CHECK (Levert IN (0,1)) | Indicates if the book is returned (1) or not (0) |

**Forklaring (English):**  
This table tracks which borrower has borrowed which specific copy of a book and when it was borrowed or returned.

---

## 2. Primærnøkler og Fremmednøkler

| Tabell | Primærnøkkel | Fremmednøkler | Relasjon |
|---------|---------------|----------------|-----------|
| **bok** | `ISBN` | — | Central reference for all books |
| **eksemplar** | (`ISBN`, `EksNr`) | `ISBN → bok(ISBN)` | Each copy belongs to a single book |
| **låner** | `LNr` | — | Each borrower has a unique ID |
| **utlån** | `UtlånsNr` | `LNr → låner(LNr)` and `(ISBN, EksNr) → eksemplar(ISBN, EksNr)` | Each loan links one borrower to a specific book copy |

**Forklaring (English):**  
Primary keys uniquely identify each record, ensuring there are no duplicates.  
Foreign keys create logical relationships between tables and enforce referential integrity.  
For example, a loan record cannot exist without a valid borrower and an existing book copy.

---

## 3. Constraints

| Type | Eksempel | Formål |
|------|-----------|--------|
| **NOT NULL** | Kolonner som `Tittel`, `Fornavn`, `Utlånsdato` | Ensures mandatory data is always provided |
| **PRIMARY KEY** | `ISBN`, `LNr`, `UtlånsNr` | Guarantees unique identification of each record |
| **FOREIGN KEY** | `LNr → låner(LNr)` | Links related tables, maintaining data consistency |
| **AUTO_INCREMENT** | `LNr`, `UtlånsNr` | Automatically generates unique IDs |
| **CHECK** | `AntallSider > 0`, `Levert IN (0,1)` | Ensures logical and valid values only |

**Forklaring (English):**  
Constraints are rules that maintain data accuracy and reliability.  
They prevent incomplete or invalid data (like missing book titles or negative page counts)  
and ensure the entire database remains consistent.

---

## 4. Hvordan designet sikrer dataintegritet

**Forklaring (English):**

- **Consistency:**  
  Foreign keys ensure that all relationships between tables are valid and consistent.

- **Accuracy:**  
  `NOT NULL`, `CHECK`, and appropriate data types guarantee realistic and correct data.

- **Reliability:**  
  `ON UPDATE CASCADE` ensures that related records stay synchronized.

- **Safety:**  
  `ON DELETE RESTRICT` prevents accidental deletion of important linked data.

- **Scalability:**  
  The design can easily be extended with new tables (for example, authors or categories)  
  without affecting the existing structure.

---

## 5. ER-diagram (for visualisering)

Et forenklet Entity-Relationship-diagram for **ga_bibliotek** ser slik ut:



bok (ISBN PK)
│
│ 1 ────< n
│
eksemplar (ISBN, EksNr PK)
│
│ 1 ────< n
│
utlån (UtlånsNr PK, LNr FK, ISBN+EksNr FK)
│
│ n ────> 1
│
låner (LNr PK)


#______________________________________
-- ============================================
-- Oppgave 1 – ga_bibliotek (database + sample data)
-- ============================================


-- 1) Skriv en SQL som oppretter databasen ‘ga_bibliotek’.
--    (Create or select the database)
DROP DATABASE IF EXISTS `ga_bibliotek`;
CREATE DATABASE `ga_bibliotek`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `ga_bibliotek`;
-- • DROP DATABASE IF EXISTS — Removes old version if it exists.
-- • CREATE DATABASE — Creates a new database using UTF-8 encoding.
-- • USE ga_bibliotek — Selects this database for next commands.


-- 2) Skriv en SQL som oppretter tabellen ‘bok’.
--    (Create table ‘bok’ — one row per book title)
CREATE TABLE `bok` (
  `ISBN`        VARCHAR(20)  PRIMARY KEY,
  `Tittel`      VARCHAR(255) NOT NULL,
  `Forfatter`   VARCHAR(100) NOT NULL,
  `Forlag`      VARCHAR(100) NOT NULL,
  `UtgittÅr`    SMALLINT UNSIGNED NOT NULL,
  `AntallSider` INT NOT NULL CHECK (`AntallSider` > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
-- • CREATE TABLE bok — Stores book information.
-- • ISBN — Unique ID (primary key).
-- • NOT NULL — Ensures all values must be filled.
-- • CHECK (AntallSider > 0) — Avoids zero or negative pages.
-- • ENGINE/CHARSET — Sets table storage and text format.


-- 3) Skriv en SQL som oppretter tabellen ‘eksemplar’.
--    (Create table ‘eksemplar’ — physical copies of books)
CREATE TABLE `eksemplar` (
  `ISBN`  VARCHAR(20) NOT NULL,
  `EksNr` INT         NOT NULL,
  PRIMARY KEY (`ISBN`, `EksNr`),
  CONSTRAINT `fk_eksemplar_bok`
    FOREIGN KEY (`ISBN`) REFERENCES `bok`(`ISBN`)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
-- • PRIMARY KEY (ISBN, EksNr) — One record per book copy.
-- • FOREIGN KEY (ISBN) — Links each copy to an existing book.
-- • ON UPDATE CASCADE — Updates copies if ISBN changes.
-- • ON DELETE RESTRICT — Prevents deleting books that still have copies.


-- 4) Skriv en SQL som oppretter tabellen ‘låner’.
--    (Create table ‘låner’ — borrowers)
CREATE TABLE `låner` (
  `LNr`       INT AUTO_INCREMENT PRIMARY KEY,
  `Fornavn`   VARCHAR(50)  NOT NULL,
  `Etternavn` VARCHAR(50)  NOT NULL,
  `Adresse`   VARCHAR(255) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
-- • LNr AUTO_INCREMENT — Automatically assigns borrower ID.
-- • Stores borrower’s first name, last name, and address.


-- 5) Skriv en SQL som oppretter tabellen ‘utlån’.
--    (Create table ‘utlån’ — tracks book loans)
CREATE TABLE `utlån` (
  `UtlånsNr`   INT AUTO_INCREMENT PRIMARY KEY,
  `LNr`        INT         NOT NULL,
  `ISBN`       VARCHAR(20) NOT NULL,
  `EksNr`      INT         NOT NULL,
  `Utlånsdato` DATE        NOT NULL,
  `Levert`     TINYINT(1)  NOT NULL CHECK (`Levert` IN (0,1)),
  CONSTRAINT `fk_utlån_låner`
    FOREIGN KEY (`LNr`) REFERENCES `låner`(`LNr`)
      ON UPDATE CASCADE
      ON DELETE RESTRICT,
  CONSTRAINT `fk_utlån_eksemplar`
    FOREIGN KEY (`ISBN`, `EksNr`) REFERENCES `eksemplar`(`ISBN`, `EksNr`)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
-- • UtlånsNr AUTO_INCREMENT — Each loan gets a unique number.
-- • LNr, ISBN, EksNr — Link borrower to the specific copy.
-- • Utlånsdato — Date the book was borrowed.
-- • Levert (0/1) — Whether it’s returned.
-- • ON UPDATE / DELETE — Keep database consistent.


-- 6) Skriv en SQL som legger til eksempeldata i tabellene.
--    (Insert example data into tables)
INSERT INTO `bok` (`ISBN`, `Tittel`, `Forfatter`, `Forlag`, `UtgittÅr`, `AntallSider`) VALUES
('8203188843','Kristin Lavransdatter: Kransen','Undset, Sigrid','Aschehoug',1920,323),
('8203190483','Fyret: en ny sak for Dalgliesh','James, P. D.','Aschehoug',2005,413),
('8203191543','Lasso rundt fru Luna','Mykle, Agnar','Gyldendal',1954,614),
('8203191201','Victoria','Hamsun, Knut','Gyldendal',1898,111),
('8253029533','Jonas','Bjørneboe, Jens','Pax',1955,302),
('8274822231','Den gamle mannen og havet','Hemingway, Ernest','Gyldendal',1952,99);
-- • Adds example book data (ISBN, title, author, etc.).


INSERT INTO `eksemplar` (`ISBN`, `EksNr`) VALUES
('8203188843',1), ('8203188843',2),
('8203190483',1),
('8203191543',1), ('8203191543',2),
('8203191201',1),
('8253029533',1),
('8274822231',1);
-- • Adds example book copies with copy numbers.


INSERT INTO `låner` (`Fornavn`, `Etternavn`, `Adresse`) VALUES
('Lise','Jensen','Erling Skjalgssons gate 56'),
('Joakim','Gjertsen','Grinda 2'),
('Katrine','Garvik','Ottar Birtings gate 9'),
('Emilie','Marcussen','Kyrre Grepps gate 29'),
('Valter','Ellefsen','Fyrstikkbakken 5D'),
('Tormod','Vaaler','Lassons gate 32'),
('Asle','Eekhoff','Kirkeveien 5'),
('Birte','Aass','Henrik Wergelands Allé 47');
-- • Adds sample borrowers (first name, last name, address).


INSERT INTO `utlån` (`LNr`, `ISBN`, `EksNr`, `Utlånsdato`, `Levert`) VALUES
(1,'8203188843',1,'2022-08-25',1),
(2,'8203190483',1,'2022-08-26',0),
(3,'8203188843',2,'2022-09-02',0),
(4,'8203191543',1,'2022-09-02',1),
(5,'8203191201',1,'2022-09-06',0),
(6,'8253029533',1,'2022-09-09',0),
(7,'8274822231',1,'2022-09-11',1);
-- • Adds sample loan records (who borrowed which book, and if returned).


-- 7) Skriv en SQL som verifiserer data i tabellene.
--    (Run simple checks and overviews)
SELECT COUNT(*) AS `antall_bøker`
FROM `bok`;
-- • Counts total number of books.

SELECT `ISBN`, COUNT(*) AS `antall_eksemplar`
FROM `eksemplar`
GROUP BY `ISBN`;
-- • Counts number of copies per book.

SELECT *
FROM `låner`
ORDER BY `LNr`;
-- • Lists all borrowers ordered by borrower number.

SELECT u.`UtlånsNr`,
       l.`Fornavn`,
       l.`Etternavn`,
       b.`Tittel`,
       u.`Utlånsdato`,
       u.`Levert`
FROM `utlån` AS u
JOIN `låner` AS l ON u.`LNr` = l.`LNr`
JOIN `eksemplar` AS e ON u.`ISBN` = e.`ISBN` AND u.`EksNr` = e.`EksNr`
JOIN `bok` AS b ON e.`ISBN` = b.`ISBN`
ORDER BY u.`UtlånsNr`;
-- • Combines all tables to show who borrowed what and when.


-- ============================================
-- Oppgave 3 – SQL Queries for ga_bibliotek
-- ============================================

USE ga_bibliotek;

-- 1) Skriv en SQL spørring som henter alle bøker publisert etter år 2000.
--    (Get all books published after year 2000)
SELECT *
FROM bok
WHERE UtgittÅr > 2000
ORDER BY UtgittÅr, Tittel;
-- • SELECT * FROM bok          — Get all book columns.
-- • WHERE UtgittÅr > 2000      — Keep books after year 2000.
-- • ORDER BY UtgittÅr, Tittel  — Sort by year, then by title.


-- 2) Skriv en SQL spørring som henter forfatternavn og tittel på alle bøker sortert alfabetisk etter forfatter.
--    (Show author and title of all books, sorted by author)
SELECT Forfatter, Tittel
FROM bok
ORDER BY Forfatter, Tittel;
-- • SELECT Forfatter, Tittel   — Return only author and title.
-- • FROM bok                   — Read from the books table.
-- • ORDER BY Forfatter, Tittel — Sort alphabetically by author and title.


-- 3) Skriv en SQL spørring som henter alle bøker med mer enn 300 sider.
--    (Show all books with more than 300 pages)
SELECT *
FROM bok
WHERE AntallSider > 300
ORDER BY AntallSider DESC, Tittel;
-- • SELECT * FROM bok                — Get full book data.
-- • WHERE AntallSider > 300          — Keep books over 300 pages.
-- • ORDER BY AntallSider DESC, Tittel — Sort by page count (largest first), then title.


-- 4) Skriv en SQL som legger til en ny bok i tabellen 'bok'. (Bok finner du selv)
--    (Add a new book; if it exists, update it)
INSERT INTO bok (ISBN, Tittel, Forfatter, Forlag, UtgittÅr, AntallSider)
VALUES ('9788203361234','Naiv. Super','Loe, Erlend','Cappelen Damm',1996,208)
AS v
ON DUPLICATE KEY UPDATE
  Tittel       = v.Tittel,
  Forfatter    = v.Forfatter,
  Forlag       = v.Forlag,
  UtgittÅr     = v.UtgittÅr,
  AntallSider  = v.AntallSider;
-- • INSERT INTO bok (...)     — Add a new book row.
-- • VALUES (...)              — Provide all column values.
-- • ON DUPLICATE KEY UPDATE   — If ISBN exists, update the data.


-- 5) Skriv en SQL som legger til en ny låner i tabellen 'låner'.
--    (Add a new borrower to the table)
INSERT INTO låner (Fornavn, Etternavn, Adresse)
VALUES ('Nina','Nordmann','Storgata 1')
AS v
ON DUPLICATE KEY UPDATE
  Adresse = v.Adresse;
-- • INSERT INTO låner (...)   — Add a new borrower.
-- • VALUES (...)              — Insert name and address.
-- • ON DUPLICATE KEY UPDATE   — Update address if already exists.


-- 6) Skriv en SQL som oppdaterer adresse for en spesifikk låner.
--    (Update address for one borrower)
UPDATE låner
SET Adresse = 'Nyveien 42'
WHERE LNr = 3;
-- • UPDATE låner        — Change borrower details.
-- • SET Adresse = ...   — Assign a new address.
-- • WHERE LNr = 3       — Update borrower with ID 3 only.


-- 7) Skriv en SQL som henter alle utlån sammen med lånerens navn og bokens tittel.
--    (Show all loans with borrower’s name and book title)
SELECT u.UtlånsNr,
       l.Fornavn,
       l.Etternavn,
       b.Tittel,
       u.Utlånsdato,
       u.Levert
FROM utlån AS u
JOIN låner AS l ON u.LNr = l.LNr
JOIN bok   AS b ON u.ISBN = b.ISBN
ORDER BY u.UtlånsNr;
-- • FROM utlån AS u          — Start from the loan table.
-- • JOIN låner AS l ...      — Link each loan to a borrower.
-- • JOIN bok AS b ...        — Link each loan to a book.
-- • SELECT ...               — Show loan info, borrower, and title.
-- • ORDER BY u.UtlånsNr      — Sort results by loan number.


-- 8) Skriv en SQL som henter alle bøker og antall eksemplarer for hver bok.
--    (Show all books and how many copies each has)
SELECT b.ISBN,
       b.Tittel,
       COUNT(e.EksNr) AS antall_eksemplar
FROM bok AS b
LEFT JOIN eksemplar AS e ON e.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY b.Tittel;
-- • SELECT ISBN, Tittel, COUNT — Count copies per book.
-- • LEFT JOIN eksemplar ...   — Include books even with zero copies.
-- • GROUP BY ISBN, Tittel     — Combine by book.
-- • ORDER BY Tittel           — Sort alphabetically.


-- 9) Skriv en SQL som henter antall utlån per låner.
--    (Show how many loans each borrower has)
SELECT l.LNr,
       l.Fornavn,
       l.Etternavn,
       COUNT(u.UtlånsNr) AS antall_utlån
FROM låner AS l
LEFT JOIN utlån AS u ON u.LNr = l.LNr
GROUP BY l.LNr, l.Fornavn, l.Etternavn
ORDER BY antall_utlån DESC, l.Etternavn, l.Fornavn;
-- • LEFT JOIN utlån ...      — Keep borrowers even with 0 loans.
-- • COUNT(u.UtlånsNr)        — Count total loans per borrower.
-- • GROUP BY ...             — One line per borrower.
-- • ORDER BY antall_utlån... — Sort by most active first.


-- 10) Skriv en SQL som henter antall utlån per bok.
--     (Show number of loans per book)
SELECT b.ISBN,
       b.Tittel,
       COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY antall_utlån DESC, b.Tittel;
-- • LEFT JOIN utlån ...      — Include books with 0 loans.
-- • COUNT(u.UtlånsNr)        — Count number of loans.
-- • GROUP BY ISBN, Tittel    — One line per book.
-- • ORDER BY antall_utlån... — Sort by most borrowed first.


-- 11) Skriv en SQL som henter alle bøker som ikke har blitt lånt ut.
--     (Show all books never borrowed)
SELECT b.ISBN,
       b.Tittel
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
WHERE u.ISBN IS NULL
ORDER BY b.Tittel;
-- • LEFT JOIN ...          — Link books with loans.
-- • WHERE u.ISBN IS NULL   — Keep only books never borrowed.
-- • ORDER BY b.Tittel      — Sort titles alphabetically.


-- 12) Skriv en SQL som henter forfatter og antall utlånte bøker per forfatter.
--     (Show author and number of borrowed books per author)
SELECT b.Forfatter,
       COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.Forfatter
ORDER BY antall_utlån DESC, b.Forfatter;
-- • SELECT Forfatter, COUNT — Count total loans by author.
-- • LEFT JOIN utlån ...     — Include authors even with 0 loans.
-- • GROUP BY Forfatter      — Combine per author.
-- • ORDER BY antall_utlån...— Sort by most borrowed first.

