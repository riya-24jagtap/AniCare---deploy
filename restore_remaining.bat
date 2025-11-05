@echo off
REM =====================================
REM Restore All Anicare SQL Files (Safe Mode)
REM =====================================

REM Aiven MySQL credentials
SET HOST=mysql-1b3619d5-jagtapriya24-5069.j.aivencloud.com
SET PORT=28901
SET USER=avnadmin
SET PASSWORD=AVNS_7naPZBluPnIkL7OEP3n
SET DB=defaultdb

REM Path to SQL files
SET SQL_PATH=D:\riya\anicare\database
SET TEMP_PATH=%SQL_PATH%\temp_sql
SET LOG_FILE=%SQL_PATH%\restore_log.txt

IF NOT EXIST "%TEMP_PATH%" mkdir "%TEMP_PATH%"
echo ===================================== > "%LOG_FILE%"
echo Restore started at %DATE% %TIME% >> "%LOG_FILE%"
echo ===================================== >> "%LOG_FILE%"

FOR %%F IN ("%SQL_PATH%\*.sql") DO (
    echo Checking %%~nxF ...
    FINDSTR /I /R "INSERT[ ]*INTO" "%%F" >nul
    IF %ERRORLEVEL% EQU 0 (
        echo Importing %%~nxF ...
        echo [Importing] %%~nxF >> "%LOG_FILE%"
        powershell -Command "(Get-Content '%%F') -replace 'INSERT INTO', 'INSERT IGNORE INTO' | Set-Content '%TEMP_PATH%\%%~nxF'"
        mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% --ssl-mode=REQUIRED %DB% --force < "%TEMP_PATH%\%%~nxF" >> "%LOG_FILE%" 2>&1
    ) ELSE (
        echo Skipping %%~nxF (no data found)
        echo [Skipped] %%~nxF (no data found) >> "%LOG_FILE%"
    )
)

echo =====================================
echo All SQL files have been safely restored!
echo Logs saved to: %LOG_FILE%
echo =====================================
pause
