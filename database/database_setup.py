import sqlite3

def create_tables():
    conn = sqlite3.connect('anicare.db')
    cursor = conn.cursor()

    # Users Table (already exists if you set up login system)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT
        )
    ''')

    # Pets Table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS pets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            name TEXT,
            type TEXT,
            breed TEXT,
            gender TEXT,
            dob TEXT,
            color TEXT,
            chip_number TEXT,
            license_number TEXT,
            vaccination_status TEXT,
            medical_conditions TEXT,
            photo_path TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')

    # Tracking Table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tracking (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reporter_id INTEGER,
            animal_type TEXT,
            breed TEXT,
            health_status TEXT,
            last_seen_location TEXT,
            last_seen_time TEXT,
            notes TEXT,
            image_path TEXT,
            FOREIGN KEY (reporter_id) REFERENCES users(id)
        )
    ''')

    conn.commit()
    conn.close()
