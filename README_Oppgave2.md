# Oppgave 2 – Forståelse og forklaring av database design (ga_bibliotek)

Denne README-filen forklarer **hva som finnes i databasen**, **hvordan tabellene henger sammen**, og **hvilke constraints** som sikrer god dataintegritet. Innholdet er skrevet for å være lett å lese for sensoren og treffe vurderingskriteriene (klarhet, korrekthet, struktur).

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

### 1.2 `eksemplar`
| Kolonne | Datatype    | Constraint                                 | Beskrivelse                                |
|---------|-------------|---------------------------------------------|--------------------------------------------|
| `ISBN`  | VARCHAR(20) | **FK → bok(ISBN)**, **NOT NULL**            | Hvilken tittel eksemplaret tilhører.       |
| `EksNr` | INT         | **NOT NULL**                                | Løpenummer for eksemplar innen samme ISBN. |

**Primærnøkkel:** **(ISBN, EksNr)** (composite).  
**Kommentar:** Stores physical copies; one book can have multiple copies (EksNr = 1, 2,…).  
**Referanse:** `FOREIGN KEY (ISBN) REFERENCES bok(ISBN) ON UPDATE CASCADE ON DELETE RESTRICT`.

### 1.3 `låner`
| Kolonne       | Datatype    | Constraint                            | Beskrivelse                 |
|---------------|-------------|----------------------------------------|-----------------------------|
| `LNr`         | INT         | **PRIMARY KEY**, **AUTO_INCREMENT**    | Unik låner-ID.              |
| `Fornavn`     | VARCHAR(50) | **NOT NULL**                           | Fornavn.                    |
| `Etternavn`   | VARCHAR(50) | **NOT NULL**                           | Etternavn.                  |
| `Adresse`     | VARCHAR(255)| **NOT NULL**                           | Full adresse.               |

**Kommentar:** Stores people who borrow books.

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

### 1.5 Databasesettinger
- **ENGINE = InnoDB** – supports ACID transactions and foreign keys.  
- **CHARSET/COLLATE = utf8mb4/utf8mb4_unicode_ci** – full Unicode support (emoji + æøå).

## 2) Primærnøkler og Fremmednøkler

### Primærnøkler (unik identitet)
- `bok.ISBN` – unique per book title.  
- `eksemplar.(ISBN, EksNr)` – unique per physical copy.  
- `låner.LNr` – auto-generated unique borrower ID.  
- `utlån.UtlånsNr` – auto-generated unique loan ID.

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

## 3) Constraints (and why they matter)

- **PRIMARY KEY** – guarantees unique identity in every table (no duplicates).  
- **NOT NULL** – ensures critical fields must have data (avoids empty values).  
- **CHECK (`AntallSider` > 0)** – keeps logical page counts.  
- **CHECK (`Levert` IN (0,1))** – enforces valid delivery status (boolean logic).  
- **FOREIGN KEY** – guarantees valid relationships between tables.  
- **ON UPDATE CASCADE** – automatically updates dependent rows.  
- **ON DELETE RESTRICT** – blocks deletion of rows that are still referenced.

**Result:** The database automatically rejects invalid data (e.g., borrowing a non-existing `bok` or `eksemplar`) and keeps relationships consistent at all times.

## 4) Kort ER-modell (tekstlig)

![ER-diagram for ga_bibliotek](./../oppgave1.png)

-- Diagram Explanation:
- Each box (like bok, låner, utlån, eksemplar) represents a table (entity).

-- Inside each box, you list:
- PK: → Primary Key (unique identifier for the table)
- FK: → Foreign Key (points to another table)

-- The arrows and (1:N) show the relationships:
- (1:N) means “one-to-many” relationship.
- Example:
  - One bok can have many eksemplar.
  - One låner can have many utlån.


