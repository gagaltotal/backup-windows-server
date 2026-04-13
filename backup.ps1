# ================================

# CONFIG

# ================================

$NAS = "\192.168.1.666\backup\backup-windows-server"
$User = "your_username"
$Pass = "your_password"
$Source = "C:"
$Dest = "$NAS\server2012_full"
$Log = "C:\backup_log.txt"

# ================================

# EXCLUDE FOLDERS

# ================================

$ExcludeDirs = @(
"C:\Windows",
"C:\Program Files",
"C:\Program Files (x86)",
"C:\ProgramData\Microsoft",
"C:$Recycle.Bin",
"C:\System Volume Information"
)

# ================================

# CONNECT NAS

# ================================

Write-Host "Connecting to NAS..." -ForegroundColor Cyan

cmd.exe /c "net use $NAS /delete" | Out-Null
cmd.exe /c "net use $NAS /user:$User $Pass /persistent:no"

if (!(Test-Path $NAS)) {
Write-Host "ERROR: Tidak bisa konek ke NAS!" -ForegroundColor Red
exit
}

# ================================

# CREATE DEST

# ================================

if (!(Test-Path $Dest)) {
New-Item -ItemType Directory -Path $Dest | Out-Null
}

# ================================

# START BACKUP

# ================================

Write-Host "Starting backup..." -ForegroundColor Green
Add-Content $Log "Backup started at $(Get-Date)"

$Files = Get-ChildItem -Path $Source -Recurse -File -ErrorAction SilentlyContinue |
Where-Object {
$exclude = $false
foreach ($dir in $ExcludeDirs) {
if ($_.FullName.StartsWith($dir)) { $exclude = $true }
}
-not $exclude
}

$total = $Files.Count
$counter = 0

foreach ($file in $Files) {
$counter++

```
$relativePath = $file.FullName.Substring(3)
$destPath = Join-Path $Dest $relativePath
$destDir = Split-Path $destPath

if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

if (!(Test-Path $destPath) -or $file.LastWriteTime -gt (Get-Item $destPath -ErrorAction SilentlyContinue).LastWriteTime) {
    Copy-Item $file.FullName -Destination $destPath -Force
}

$percent = [math]::Round(($counter / $total) * 100, 2)

Write-Progress -Activity "Backup in progress..." `
    -Status "$counter / $total files ($percent%)" `
    -PercentComplete $percent
```

}

# ================================

# FINISH

# ================================

Add-Content $Log "Backup finished at $(Get-Date)"
Write-Host "Backup completed successfully!" -ForegroundColor Green

# ================================

# DISCONNECT NAS

# ================================

cmd.exe /c "net use $NAS /delete" | Out-Null
