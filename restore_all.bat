@echo off
REM ==============================
REM Restore all Anicare SQL files safely
REM ==============================

SET HOST=mysql-1b3619d5-jagtapriya24-5069.j.aivencloud.com
SET PORT=28901
SET USER=avnadmin
SET PASSWORD=AVNS_7naPZBluPnIkL7OEP3n
SET DB=defaultdb
SET SQL_PATH=D:\riya\anicare\database

REM Temporary folder for modified SQL files
SET TEMP_PATH=%SQL_PATH%\temp_sql
IF NOT EXIST "%TEMP_PATH%" mkdir "%TEMP_PATH%"

REM Loop through all SQL files
FOR %%F IN ("%SQL_PATH%\*.sql") DO (
    echo Processing %%~nxF ...
    REM Replace INSERT INTO with INSERT IGNORE INTO to avoid duplicates
    powershell -Command "(Get-Content '%%F') -replace 'INSERT INTO', 'INSERT IGNORE INTO' | Set-Content '%TEMP_PATH%\%%~nxF'"
    REM Import the modified file
    mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% --ssl-mode=REQUIRED %DB% --force < "%TEMP_PATH%\%%~nxF"
)

echo ==============================
echo All SQL files have been restored safely!
echo ==============================
pause
