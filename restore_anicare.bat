@echo off
REM ==============================
REM Restore Anicare SQL files to Aiven MySQL safely
REM ==============================

REM Aiven MySQL credentials
SET HOST=mysql-1b3619d5-jagtapriya24-5069.j.aivencloud.com
SET PORT=28901
SET USER=avnadmin
SET PASSWORD=AVNS_7naPZBluPnIkL7OEP3n
SET DB=defaultdb

REM Path to your SQL files
SET SQL_PATH=D:\riya\anicare\database

REM ==============================
REM Import SQL files safely using INSERT IGNORE
REM ==============================

REM Function to safely import a SQL file
FOR %%F IN (
    anicare_db_users.sql
    anicare_db_pet_records.sql
    anicare_db_appointments.sql
    anicare_db_vets.sql
    anicare_db_consultation_history.sql
    anicare_db_cases.sql
    anicare_db_diagnosis_history.sql
    anicare_db_feedback.sql
    anicare_db_ngo.sql
    anicare_db_volunteers.sql
    anicare_db_vet_appointments.sql
    anicare_db_stray_reports.sql
    anicare_db_contact_messages.sql
) DO (
    echo Importing %%F ...
    mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% --ssl-mode=REQUIRED %DB% --force < "%SQL_PATH%\%%F"
)

echo ==============================
echo All SQL files have been restored safely!
echo ==============================
pause
