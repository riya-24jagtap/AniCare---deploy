import sqlite3

conn = sqlite3.connect('anicare.db')
cursor = conn.cursor()

cursor.execute("SELECT name, email, password, role FROM users")
users = cursor.fetchall()

print("=== Registered Users ===")
for user in users:
    print(f"Name: {user[0]}, Email: {user[1]}, Password: {user[2]}, Role: {user[3]}")

conn.close()
