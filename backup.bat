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

:: ================================
:: CONFIG NAS LOGIN
:: ================================
set "NAS=\192.168.1.666\backup\backup-windows-server"
set "USERNAS=your_username"
set "PASSNAS=your_password"

:: ================================
:: SOURCE & DESTINATION
:: ================================
set "SOURCE=C:"
set "DEST=%NAS%\server2012_full"
set "LOG=C:\backup_log.txt"

:: ================================
:: CONNECT NAS
:: ================================
net use %NAS% /delete >nul 2>&1
net use %NAS% /user:%USERNAS% %PASSNAS% /persistent

if errorlevel 1 (
echo [ERROR] Gagal konek ke NAS!
pause
exit /b
)

:: ================================
:: CREATE DEST
:: ================================
if not exist "%DEST%" mkdir "%DEST%"

:: ================================
:: BACKUP START
:: ================================
echo Backup started at %date% %time%
echo Backup started at %date% %time% >> %LOG%

robocopy "%SOURCE%" "%DEST%" ^
/E ^
/Z ^
/XO ^
/R:2 ^
/W:5 ^
/FFT ^
/XA ^
/TEE ^
/NP ^
/XD ^
"C:\Windows" ^
"C:\Program Files" ^
"C:\Program Files (x86)" ^
"C:\ProgramData\Microsoft" ^
"C:$Recycle.Bin" ^
"C:\System Volume Information" ^
/LOG+:"%LOG%"

echo.
echo Backup finished at %date% %time%
echo Backup finished at %date% %time% >> %LOG%
echo ================================ >> %LOG%

:: ================================
:: DISCONNECT NAS
:: ================================
net use %NAS% /delete