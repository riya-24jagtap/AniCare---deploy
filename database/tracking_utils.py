import sqlite3

def track_animal(user_id, tracking_data):
    conn = sqlite3.connect('anicare.db')
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO tracking (
            reporter_id, animal_type, breed, health_status,
            last_seen_location, last_seen_time, notes, image_path
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        user_id,
        tracking_data['animal_type'],
        tracking_data['breed'],
        tracking_data['health_status'],
        tracking_data['last_seen_location'],
        tracking_data['last_seen_time'],
        tracking_data['notes'],
        tracking_data['image_path']
    ))

    conn.commit()
    conn.close()
