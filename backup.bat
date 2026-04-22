@echo off
color 0A

echo ====================================================================================================================
echo =  ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗ =
echo =  ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝ =
echo =  ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝    ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║███████╗ =
echo =  ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════██║ =
echo =  ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝███████║ =
echo =  ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝ =                                                                                                           
echo =  BACKUP WINDOWS SERVER - NAS                                                                                     =
echo ====================================================================================================================

:: CONFIG
set NAS=\\192.168.1.666\backup\backup-windows-server
set USERNAS=your_username
set PASSNAS=your_password

set SOURCE=C:
set DEST=%NAS%\server2012_full
set LOG=C:\backup_log.txt

:: CONNECT NAS
net use %NAS% /delete >nul 2>&1
net use %NAS% /user:%USERNAS% %PASSNAS% /persistent:no

if errorlevel 1 (
echo [ERROR] Gagal konek ke NAS!
pause
exit /b
)

:: CREATE DEST
if not exist "%DEST%" mkdir "%DEST%"

echo Backup started at %date% %time%
echo Backup started at %date% %time% >> %LOG%

:: ================= BACKUP FULL C: DRIVE =================
:: /XJ     = Skip junctions dan symlinks (PENTING! Mencegah loop infinite di Application Data)
:: /XD     = Exclude directories
:: /E      = Include empty directories
:: /Z      = Resume mode (untuk gangguan koneksi)
:: /FFT    = Fat File Time (toleransi time differences)
:: /XO     = Exclude older files (untuk deduplication)
:: /XN     = Exclude newer files
:: /XC     = Exclude changed files
robocopy "%SOURCE%" "%DEST%" /E /Z /R:2 /W:5 /FFT /TEE ^
/XO /XN /XC ^
/XJ ^
/XD ^
"C:\Windows" ^
"C:\$Recycle.Bin" ^
"C:\System Volume Information" ^
"C:\ProgramData\Microsoft" ^
"C:\Program Files\Common Files\Oracle" ^
/LOG+:%LOG%

echo.
echo [INFO] Main backup completed. Checking for already-backed-up folders...
echo.

:: ================= DEDUPLICATION - Skip if already in NAS =================
:: Folder yang sudah di-backup jangan di-copy lagi untuk menghindari duplikasi
if exist "%DEST%\xampp" (
    echo [SKIP] XAMPP folder sudah ada di NAS - tidak perlu re-backup
    echo [SKIP] XAMPP folder sudah ada di NAS >> %LOG%
)
if exist "%DEST%\Users" (
    echo [SKIP] Users folder sudah ada di NAS - tidak perlu re-backup
    echo [SKIP] Users folder sudah ada di NAS >> %LOG%
)
if exist "%DEST%\ProgramData" (
    echo [SKIP] ProgramData folder sudah ada di NAS - tidak perlu re-backup
    echo [SKIP] ProgramData folder sudah ada di NAS >> %LOG%
)

echo.
echo Backup finished at %date% %time%
echo Backup finished at %date% %time% >> %LOG%
echo ============================================ >> %LOG%

:: ================= DISCONNECT NAS =================
net use %NAS% /delete

echo.
echo ==== SELESAI ====
pause
:: =================================================
:: END
:: =================================================