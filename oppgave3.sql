-- ============================================
-- Oppgave 3 – SQL Queries for ga_bibliotek
-- ============================================

USE ga_bibliotek;

-- 1) Books published after 2000
SELECT * FROM bok
WHERE UtgittÅr > 2000
ORDER BY UtgittÅr, Tittel;

-- 2) Author + title, alphabetically by author
SELECT Forfatter, Tittel
FROM bok
ORDER BY Forfatter, Tittel;

-- 3) Books with more than 300 pages
SELECT * FROM bok
WHERE AntallSider > 300
ORDER BY AntallSider DESC, Tittel;

-- 4) Add a new book safely (upsert)
INSERT INTO bok (ISBN, Tittel, Forfatter, Forlag, UtgittÅr, AntallSider)
VALUES ('9788203361234','Naiv. Super','Loe, Erlend','Cappelen Damm',1996,208)
AS v
ON DUPLICATE KEY UPDATE
  Tittel=v.Tittel, Forfatter=v.Forfatter, Forlag=v.Forlag,
  UtgittÅr=v.UtgittÅr, AntallSider=v.AntallSider;

-- 5) Add a new borrower safely
INSERT INTO låner (Fornavn, Etternavn, Adresse)
VALUES ('Nina','Nordmann','Storgata 1')
AS v
ON DUPLICATE KEY UPDATE
  Adresse = v.Adresse;

-- 6) Update a borrower's address (run intentionally)
UPDATE låner
SET Adresse = 'Nyveien 42'
WHERE LNr = 3;

-- 7) All loans with borrower name and book title
SELECT u.UtlånsNr, l.Fornavn, l.Etternavn, b.Tittel, u.Utlånsdato, u.Levert
FROM utlån AS u
JOIN låner AS l ON u.LNr = l.LNr
JOIN bok   AS b ON u.ISBN = b.ISBN
ORDER BY u.UtlånsNr;

-- 8) All books + number of copies
SELECT b.ISBN, b.Tittel, COUNT(e.EksNr) AS antall_eksemplar
FROM bok AS b
LEFT JOIN eksemplar AS e ON e.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY b.Tittel;

-- 9) Number of loans per borrower
SELECT l.LNr, l.Fornavn, l.Etternavn, COUNT(u.UtlånsNr) AS antall_utlån
FROM låner AS l
LEFT JOIN utlån AS u ON u.LNr = l.LNr
GROUP BY l.LNr, l.Fornavn, l.Etternavn
ORDER BY antall_utlån DESC, l.Etternavn, l.Fornavn;

-- 10) Number of loans per book
SELECT b.ISBN, b.Tittel, COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.ISBN, b.Tittel
ORDER BY antall_utlån DESC, b.Tittel;

-- 11) Books never borrowed
SELECT b.ISBN, b.Tittel
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
WHERE u.ISBN IS NULL
ORDER BY b.Tittel;

-- 12) Author + total borrowed books per author
SELECT b.Forfatter, COUNT(u.UtlånsNr) AS antall_utlån
FROM bok AS b
LEFT JOIN utlån AS u ON u.ISBN = b.ISBN
GROUP BY b.Forfatter
ORDER BY antall_utlån DESC, b.Forfatter;
