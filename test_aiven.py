import pymysql

# Connect to Aiven MySQL
conn = pymysql.connect(
    host='mysql-1b3619d5-jagtapriya24-5069.j.aivencloud.com',
    user='avnadmin',
    password='AVNS_7naPZBluPnIkL7OEP3n',  # Your actual password
    database='defaultdb',
    port=28901
)

try:
    cursor = conn.cursor()
    cursor.execute("SELECT 1 + 2 AS three;")
    result = cursor.fetchone()
    print("Query result:", result)
finally:
    conn.close()
