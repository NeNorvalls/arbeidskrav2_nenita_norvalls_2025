from connect_db import get_connection

# Connect (uses DB_NAME from .env automatically)
cnx = get_connection()

if cnx:
    cur = cnx.cursor()
    cur.execute("SHOW TABLES")

    print("\n:books: Tables in ga_bibliotek:")
    for (tbl,) in cur:
        print(f"- {tbl}")

    cur.close()
    cnx.close()
    print("\n:lock: Connection closed.")
else:
    print(":x: Failed to connect.")
