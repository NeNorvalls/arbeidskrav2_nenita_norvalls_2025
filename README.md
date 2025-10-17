# Oppgave 2 – Forståelse og forklaring av database design (ga_bibliotek)

Denne README-filen forklarer **hva som finnes i databasen**, **hvordan tabellene henger sammen**, og **hvilke constraints** som sikrer god dataintegritet. Innholdet er skrevet for å være lett å lese for sensoren og treffe vurderingskriteriene (klarhet, korrekthet, struktur).

---

## 1) Tabellstrukturer

### 1.1 `bok`
| Kolonne       | Datatype                 | Constraint                     | Beskrivelse                         |
|---------------|--------------------------|---------------------------------|-------------------------------------|
| `ISBN`        | VARCHAR(20)             | **PRIMARY KEY**                | Unik ID for hver bok.               |
| `Tittel`      | VARCHAR(255)            | **NOT NULL**                   | Boktittel.                          |
| `Forfatter`   | VARCHAR(100)            | **NOT NULL**                   | Navn på forfatter.                  |
| `Forlag`      | VARCHAR(100)            | **NOT NULL**                   | Forlag.                             |
| `UtgittÅr`    | SMALLINT UNSIGNED       | **NOT NULL**                   | År boken ble utgitt (ikke negativ). |
| `AntallSider` | INT                     | **NOT NULL**, **CHECK > 0**    | Antall sider, må være > 0.          |

**Kommentar:** Table for book metadata; one row per title. `ISBN` acts as the natural primary key.

---

### 1.2 `eksemplar`
| Kolonne | Datatype    | Constraint                                 | Beskrivelse                                |
|---------|-------------|---------------------------------------------|--------------------------------------------|
| `ISBN`  | VARCHAR(20) | **FK → bok(ISBN)**, **NOT NULL**            | Hvilken tittel eksemplaret tilhører.       |
| `EksNr` | INT         | **NOT NULL**                                | Løpenummer for eksemplar innen samme ISBN. |

**Primærnøkkel:** **(ISBN, EksNr)** (composite).  
**Kommentar:** Stores physical copies; one book can have multiple copies (EksNr = 1, 2,…).  
**Referanse:** `FOREIGN KEY (ISBN) REFERENCES bok(ISBN) ON UPDATE CASCADE ON DELETE RESTRICT`.

---

### 1.3 `låner`
| Kolonne       | Datatype    | Constraint                            | Beskrivelse                 |
|---------------|-------------|----------------------------------------|-----------------------------|
| `LNr`         | INT         | **PRIMARY KEY**, **AUTO_INCREMENT**    | Unik låner-ID.              |
| `Fornavn`     | VARCHAR(50) | **NOT NULL**                           | Fornavn.                    |
| `Etternavn`   | VARCHAR(50) | **NOT NULL**                           | Etternavn.                  |
| `Adresse`     | VARCHAR(255)| **NOT NULL**                           | Full adresse.               |

**Kommentar:** Stores people who borrow books.

---

### 1.4 `utlån`
| Kolonne       | Datatype     | Constraint                                                  | Beskrivelse                                 |
|---------------|--------------|-------------------------------------------------------------|---------------------------------------------|
| `UtlånsNr`    | INT          | **PRIMARY KEY**, **AUTO_INCREMENT**                         | Unik løpenr for utlån.                      |
| `LNr`         | INT          | **FK → låner(LNr)**, **NOT NULL**                           | Hvem som lånte.                             |
| `ISBN`        | VARCHAR(20)  | **FK-del → eksemplar(ISBN, EksNr)**, **NOT NULL**           | Hvilken tittel som ble lånt.                |
| `EksNr`       | INT          | **FK-del → eksemplar(ISBN, EksNr)**, **NOT NULL**           | Hvilket fysisk eksemplar.                   |
| `Utlånsdato`  | DATE         | **NOT NULL**                                                | Når utlånet skjedde.                        |
| `Levert`      | TINYINT(1)   | **NOT NULL**, **CHECK (Levert IN (0,1))**                   | 0 = not returned, 1 = returned.             |

**Fremmednøkler:**  
- `FOREIGN KEY (LNr) REFERENCES låner(LNr) ON UPDATE CASCADE ON DELETE RESTRICT`  
- `FOREIGN KEY (ISBN, EksNr) REFERENCES eksemplar(ISBN, EksNr) ON UPDATE CASCADE ON DELETE RESTRICT`

**Kommentar:** Connects `låner` ↔ `eksemplar` (meaning which specific copy was borrowed).

---

### 1.5 Databasesettinger
- **ENGINE = InnoDB** – supports ACID transactions and foreign keys.  
- **CHARSET/COLLATE = utf8mb4/utf8mb4_unicode_ci** – full Unicode support (emoji + æøå).

---

## 2) Primærnøkler og Fremmednøkler

### Primærnøkler (unik identitet)
- `bok.ISBN` – unique per book title.  
- `eksemplar.(ISBN, EksNr)` – unique per physical copy.  
- `låner.LNr` – auto-generated unique borrower ID.  
- `utlån.UtlånsNr` – auto-generated unique loan ID.

---

### Fremmednøkler (relasjoner og dataintegritet)
- `eksemplar.ISBN` → `bok.ISBN`  
  - **Effect:** Prevents creating an `eksemplar` for a `bok` that doesn’t exist.  
    If a `bok` is deleted while it still has `eksemplar`, the delete is blocked (RESTRICT).  
    If `ISBN` changes, it automatically updates in `eksemplar` (CASCADE).
- `utlån.LNr` → `låner.LNr`  
  - **Effect:** Ensures every `utlån` points to a valid `låner`.  
    A `låner` cannot be deleted if there are active `utlån` (RESTRICT).  
    If `LNr` changes, related `utlån` update automatically (CASCADE).
- `utlån.(ISBN, EksNr)` → `eksemplar.(ISBN, EksNr)`  
  - **Effect:** Ensures each `utlån` references an existing, specific `eksemplar`.  
    Prevents borrowing non-existing copies. Updates cascade; deletion is restricted.

**How this preserves referential integrity:**  
Foreign keys make sure every “pointer” in the database always refers to something real, preventing broken or missing links.

---

## 3) Constraints (and why they matter)

- **PRIMARY KEY** – guarantees unique identity in every table (no duplicates).  
- **NOT NULL** – ensures critical fields must have data (avoids empty values).  
- **CHECK (`AntallSider` > 0)** – keeps logical page counts.  
- **CHECK (`Levert` IN (0,1))** – enforces valid delivery status (boolean logic).  
- **FOREIGN KEY** – guarantees valid relationships between tables.  
- **ON UPDATE CASCADE** – automatically updates dependent rows.  
- **ON DELETE RESTRICT** – blocks deletion of rows that are still referenced.

**Result:** The database automatically rejects invalid data (e.g., borrowing a non-existing `bok` or `eksemplar`) and keeps relationships consistent at all times.

---

## 4) Kort ER-modell (tekstlig)

    ![ER-diagram for ga_bibliotek](https://i.ibb.co/FkXrqWKv/oppgave1.png)

## Diagram Explanation:
- Each box (like bok, låner, utlån, eksemplar) represents a table (entity).
### Inside each box, you list:
- PK: → Primary Key (unique identifier for the table)
- FK: → Foreign Key (points to another table)
### The arrows and (1:N) show the relationships:
- (1:N) means “one-to-many” relationship.
- Example:
-- One bok can have many eksemplar.
-- One låner can have many utlån.


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

