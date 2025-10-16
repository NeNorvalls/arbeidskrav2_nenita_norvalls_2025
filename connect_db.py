import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

def get_connection(db_name=None):
    """
    Create and return a connection to the MySQL database.
    If db_name is not given, it uses DB_NAME from .env.
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "127.0.0.1"),
            port=int(os.getenv("DB_PORT", 3306)),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            database=db_name or os.getenv("DB_NAME", "ga_bibliotek")
        )
        print(f"✅ Connected to {db_name or os.getenv('DB_NAME')}")
        return connection

    except mysql.connector.Error as err:
        print(f"❌ Error connecting to MySQL: {err}")
        return None
