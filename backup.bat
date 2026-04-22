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
set DEST=\\192.168.1.666\backup\backup-windows-server\server2012_full
set LOG=C:\backup_log.txt
 
:: ================= CONNECT NAS =================
net use %NAS% /delete >nul 2>&1
net use %NAS% %PASSNAS% /user:%USERNAS% /persistent:no
if errorlevel 1 (
    echo [ERROR] Gagal konek ke NAS!
    pause
    exit /b 1
)
 
:: ================= CREATE DEST =================
if not exist "%DEST%" mkdir "%DEST%"
 
echo.
echo [INFO] Backup started at %date% %time%
echo [INFO] Backup started at %date% %time% >> "%LOG%"
echo. >> "%LOG%"

:: ===============================================================
:: BACKUP FULL C:\ - Dengan exclusion folder OS dan junction point
::
:: Flag penting:
::   /E       = copy semua subfolder termasuk yang kosong
::   /Z       = restartable mode (resume jika putus)
::   /B       = backup mode (bypass permission restriction)
::   /COPYALL = copy semua atribut file
::   /R:2     = retry 2x jika gagal
::   /W:5     = tunggu 5 detik antar retry
::   /FFT     = toleransi timestamp FAT (hindari false mismatch)
::   /XO      = skip file yang lebih lama dari destination (hindari duplikasi)
::   /XJ      = SKIP semua junction point / symlink (cegah recursive loop!)
::   /XD      = exclude folder tertentu
::   /XF      = exclude file tertentu
::   /TEE     = tampilkan output ke layar sekaligus ke log
::   /LOG+    = append ke log file
:: ===============================================================
robocopy "%SOURCE%" "%DEST%" /E /Z /B /COPYALL /R:2 /W:5 /FFT /XO /XJ /TEE 
/LOG+:"%LOG%" /XD "%SOURCE%Windows" 
"%SOURCE%$Recycle.Bin" 
"%SOURCE%System Volume Information" 
"%SOURCE%Recovery" 
"%SOURCE%ProgramData\Microsoft\Windows\Caches" 
"%SOURCE%ProgramData\Microsoft\Crypto" 
"%SOURCE%ProgramData\Microsoft\Search" 
"%SOURCE%ProgramData\Microsoft\Windows Defender" 
"%SOURCE%Users\All Users" 
"%SOURCE%Users\Default User" 
"%SOURCE%Config.Msi" /XF "pagefile.sys" "swapfile.sys" "hiberfil.sys" "*.tmp" "*.temp" "thumbs.db" "desktop.ini"
 
:: Tangkap exit code robocopy
:: 0  = tidak ada file yang dicopy (sudah sama semua)
:: 1  = ada file yang berhasil dicopy
:: 2  = ada extra file di destination (tidak masalah)
:: 4  = ada mismatch
:: 8+ = ERROR
set ROBO_EXIT=%ERRORLEVEL%
 
if %ROBO_EXIT% GEQ 8 (
    echo [ERROR] Robocopy gagal dengan exit code: %ROBO_EXIT%
    echo [ERROR] Robocopy gagal dengan exit code: %ROBO_EXIT% >> "%LOG%"
) else if %ROBO_EXIT% EQU 0 (
    echo [INFO] Semua file sudah up-to-date, tidak ada yang perlu dicopy.
    echo [INFO] Semua file sudah up-to-date >> "%LOG%"
) else (
    echo [INFO] Backup selesai. Robocopy exit code: %ROBO_EXIT% (normal)
    echo [INFO] Backup selesai. Exit code: %ROBO_EXIT% >> "%LOG%"
)
 
echo.
echo ============================================
echo [INFO] Backup finished at %date% %time%
echo [INFO] Backup finished at %date% %time% >> "%LOG%"
echo ============================================ >> "%LOG%"
 
:: ================= DISCONNECT NAS =================
net use %NAS% /delete >nul 2>&1
 
echo.
echo ==== SELESAI ====
pause
:: ================= END =================