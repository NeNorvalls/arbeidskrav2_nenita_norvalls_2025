-- ============================================ Oppgave 3 – SQL Queries for ga_bibliotek ============================================

```sql

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
-- • ORDER BY antall_utlån...— Sort by most borrowed first.```