import mysql.connector
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Connect using environment variables
db = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE"),
    port=os.getenv("MYSQL_PORT")
)

# Create a cursor and execute a simple command
cursor = db.cursor()
cursor.execute("SHOW TABLES;")

# Fetch all rows (this avoids the type warning)
tables = cursor.fetchall()

# Print the list of tables
for table in tables:
    print(table)

# Clean up
cursor.close()
db.close()
