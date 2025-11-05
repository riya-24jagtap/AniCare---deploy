import sqlite3

def register_pet(user_id, pet_data):
    conn = sqlite3.connect('anicare.db')
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO pets (
            user_id, name, type, breed, gender, dob, color,
            chip_number, license_number, vaccination_status,
            medical_conditions, photo_path
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        user_id,
        pet_data['name'],
        pet_data['type'],
        pet_data['breed'],
        pet_data['gender'],
        pet_data['dob'],
        pet_data['color'],
        pet_data['chip_number'],
        pet_data['license_number'],
        pet_data['vaccination_status'],
        pet_data['medical_conditions'],
        pet_data['photo_path']
    ))

    conn.commit()
    conn.close()
