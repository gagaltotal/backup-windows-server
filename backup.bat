@echo off
color 0A

echo ====================================================================================================================
echo =  ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗ =
echo =  ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝ =
echo =  ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝    ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║███████╗ =
echo =  ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════██║ =
echo =  ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝███████║ =
echo =  ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝ =
echo =  BACKUP WINDOWS SERVER - NAS - Gagaltotal666                                                                     =
echo ====================================================================================================================

:: CONFIG
set NAS=\\192.168.1.666\backup\backup-windows-server
set USERNAS=your_username
set PASSNAS=your_password

:: PATH
set SOURCE=C:\
set DEST=%NAS%\server2012_full
set LOG=C:\backup_log.txt

:: ================= CONNECT NAS =================
echo [INFO] Attempting to connect to NAS: %NAS%

:: Delete previous connection
net use %NAS% /delete >nul 2>&1

:: Proper syntax dengan password yang di-quote untuk handle special characters
net use %NAS% "%PASSNAS%" /user:%USERNAS% /persistent:no

if errorlevel 1 (
    echo [ERROR] Gagal konek ke NAS!
    echo [ERROR] Check:
    echo   1. NAS Path: %NAS%
    echo   2. Username: %USERNAS%
    echo   3. Password sudah benar?
    echo   4. Network connectivity
    echo [ERROR] Connection failed at %date% %time% >> "%LOG%"
    pause
    exit /b 1
)

echo [INFO] Connected to NAS successfully
echo [INFO] Connected to NAS at %date% %time% >> "%LOG%"

:: ================= CREATE DEST =================
if not exist "%DEST%" mkdir "%DEST%"
echo [INFO] Destination folder ready: %DEST%

echo.
echo [INFO] Backup started at %date% %time%
echo [INFO] Backup started at %date% %time% >> "%LOG%"
echo.

:: ================= BACKUP FULL C: DRIVE =================
echo [INFO] Starting main backup of C:\ ...
echo.

:: Robocopy with /XJ to skip junctions - robocopy will recursively skip all junctions
robocopy C:\ "%DEST%" /E /Z /R:2 /W:5 /FFT /XJ /DCOPY:DA /COPY:DAT /TEE /LOG+:"%LOG%" /XD "C:\Windows" "C:\Program Files" "C:\Program Files (x86)" "C:\ProgramData\Microsoft" "C:\$Recycle.Bin" "C:\System Volume Information" /XF pagefile.sys hiberfil.sys swapfile.sys thumbs.db

set RC=%ERRORLEVEL%

echo.
echo ================= BACKUP RESULT =================
if %RC% GEQ 8 (
    echo [ERROR] Robocopy error! Code: %RC%
    echo [ERROR] Backup FAILED - Code: %RC% at %date% %time% >> "%LOG%"
) else if %RC% GEQ 4 (
    echo [WARNING] Some files could not be copied. Code: %RC%
    echo [WARNING] Some files skipped - Code: %RC% at %date% %time% >> "%LOG%"
) else (
    echo [SUCCESS] Backup completed successfully! Code: %RC%
    echo [INFO] Backup completed - Code: %RC% at %date% %time% >> "%LOG%"
)

echo ================================================== 
echo.

echo [INFO] Finished at %date% %time% >> "%LOG%"

:: ================= DISCONNECT NAS =================
echo [INFO] Disconnecting from NAS...
net use %NAS% /delete >nul 2>&1
echo [INFO] Disconnected from NAS

echo.
echo ==== SELESAI ====
pause
:: ================= END =================