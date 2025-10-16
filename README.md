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