-- ====================== Oppgave 1 – ga_bibliotek (database + sample data) =======================

-- 1) Skriv en SQL som oppretter databasen ‘ga_bibliotek’.
--    (Create or select the database)
```sql

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
-- • Combines all tables to show who borrowed what and when.```