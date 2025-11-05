@echo off
REM === MySQL Auto Backup Script ===

set MYSQL_USER=root
set MYSQL_PASS=root
set DB_NAME=anicare_db
set BACKUP_PATH=D:\riya\anicare\database

REM Create backup folder if it doesn't exist
if not exist "%BACKUP_PATH%" mkdir "%BACKUP_PATH%"

REM Generate filename with date YYYY-MM-DD
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c-%%a-%%b
set FILE_NAME=%DB_NAME%_%DATE%.sql

REM Run mysqldump
"C:\xampp\mysql\bin\mysqldump.exe" -u %MYSQL_USER% -p%MYSQL_PASS% %DB_NAME% > "%BACKUP_PATH%\%FILE_NAME%"

echo Backup completed: %BACKUP_PATH%\%FILE_NAME%
pause
