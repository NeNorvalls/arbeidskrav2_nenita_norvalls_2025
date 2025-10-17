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



-- 2) Skriv en SQL spørring som henter forfatternavn og tittel på alle bøker sortert alfabetisk etter forfatter.
--    (Show author and title of all books, sorted by author)
SELECT Forfatter, Tittel
FROM bok
ORDER BY Forfatter, Tittel;



-- 3) Skriv en SQL spørring som henter alle bøker med mer enn 300 sider.
--    (Show all books with more than 300 pages)
SELECT *
FROM bok
WHERE AntallSider > 300
ORDER BY AntallSider DESC, Tittel;



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



-- 5) Skriv en SQL som legger til en ny låner i tabellen 'låner'.
--    (Add a new borrower to the table)
INSERT INTO låner (Fornavn, Etternavn, Adresse)
VALUES ('Nina','Nordmann','Storgata 1')
AS v
ON DUPLICATE KEY UPDATE
  Adresse = v.Adresse;



-- 6) Skriv en SQL som oppdaterer adresse for en spesifikk låner.
--    (Update address for one borrower)
UPDATE låner
SET Adresse = 'Nyveien 42'
WHERE LNr = 3;



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



-- 8) Skriv en SQL som henter alle bøker og antall eksemplarer for hver bok.
--    (Show all books and how many copies each has)
SELECT b.ISBN,
       b.Tittel,
       COUNT(e.EksNr) AS antall_eksemplar
FROM bok AS b
LEFT JOIN eksemplar AS e ON e.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY b.Tittel;



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



-- 10) Skriv en SQL som henter antall utlån per bok.
--     (Show number of loans per book)
SELECT b.ISBN,
       b.Tittel,
       COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY antall_utlån DESC, b.Tittel;



-- 11) Skriv en SQL som henter alle bøker som ikke har blitt lånt ut.
--     (Show all books never borrowed)
SELECT b.ISBN,
       b.Tittel
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
WHERE u.ISBN IS NULL
ORDER BY b.Tittel;



-- 12) Skriv en SQL som henter forfatter og antall utlånte bøker per forfatter.
--     (Show author and number of borrowed books per author)
SELECT b.Forfatter,
       COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.Forfatter
ORDER BY antall_utlån DESC, b.Forfatter;

