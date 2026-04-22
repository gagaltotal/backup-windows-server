# backup-windows-server

Script `backup.bat` melakukan backup **seluruh isi drive `C:\`** ke share NAS menggunakan `robocopy`, dengan pengecualian hanya untuk folder sistem Windows dan folder junctions/symlinks yang tidak perlu dibackup.

## Konfigurasi

Edit `backup.bat` dan sesuaikan nilai berikut di bagian CONFIG:

```batch
set NAS=\\192.168.1.666\backup\backup-windows-server
set USERNAS=your_username
set PASSNAS=your_password
```

- `NAS` : alamat share NAS
- `USERNAS` : nama pengguna NAS
- `PASSNAS` : password NAS (support karakter spesial seperti `!`, gunakan quotes)
- `DEST` : lokasi tujuan di NAS (default: `%NAS%\server2012_full`)
- `LOG` : file log backup (default: `C:\backup_log.txt`)

## Cara Kerja

1. **Connect ke NAS** - Menghubungkan ke share NAS dengan kredensial yang diberikan
2. **Create Destination** - Membuat folder tujuan di NAS jika belum ada
3. **Robocopy Backup** - Copy semua file dari `C:\` ke NAS dengan opsi:
   - `/E` : salin semua subfolder, termasuk yang kosong
   - `/Z` : mode restartable (resume jika koneksi terputus)
   - `/R:2` : coba ulang 2 kali jika gagal
   - `/W:5` : tunggu 5 detik antar percobaan
   - `/FFT` : toleransi timestamp 2 detik (untuk kompatibilitas FAT)
   - **/XJ** : **skip junctions & symlinks** (PENTING: mencegah infinite loop di Application Data)
   - `/DCOPY:DA` : copy directory ownership & attributes
   - `/COPY:DAT` : copy data, attributes, timestamps
   - `/TEE` : output ke console dan log file
   - `/XD` : exclude directories tertentu
   - `/XF` : exclude files tertentu
4. **Error Handling** - Cek status code robocopy dan report hasilnya
5. **Disconnect NAS** - Melepaskan koneksi ke NAS

## Folder yang di-Backup

### Termasuk dalam backup:
- Semua data aplikasi (ProgramData) kecuali Microsoft
- XAMPP dan web server stack lainnya
- Users profile dan documents
- Program Files (aplikasi)
- Semua folder dan file custom di C:\

### Dikecualikan dari backup:
- `C:\Windows` - folder sistem operasi (OS files)
- `C:\Program Files` - aplikasi standar sistem
- `C:\Program Files (x86)` - aplikasi 32-bit sistem
- `C:\ProgramData\Microsoft` - data Microsoft system
- `C:\$Recycle.Bin` - recycle bin
- `C:\System Volume Information` - informasi sistem
- **Junctions & Symlinks** - automatically skipped dengan `/XJ`
  - Mencegah infinite loop di Application Data
  - Skip semua folder yang berupa link/shortcut

### Files Dikecualikan:
- `pagefile.sys` - Windows page file
- `hiberfil.sys` - hibernate file
- `swapfile.sys` - swap file
- `thumbs.db` - thumbnail database

## Penggunaan

1. **Edit konfigurasi** - Sesuaikan NAS path, username, dan password
2. **Jalankan dengan Administrator** - Script memerlukan hak admin
3. **Monitor log** - Lihat file `C:\backup_log.txt` untuk detail backup

```batch
backup.bat
```

## Robocopy Exit Codes

- `0-3` : Success - backup berhasil
- `4-7` : Warning - beberapa file skip (normal untuk permission denied)
- `8+` : Error - ada masalah backup

## Troubleshooting

### Password dengan karakter spesial
Gunakan format berikut untuk password dengan `!`, `&`, `|`, dll:
```batch
set "PASSNAS=myPassword!@#$%"
```
Quotes melindungi karakter spesial agar tidak di-interpret oleh batch.

### Koneksi NAS Error
- Pastikan NAS path benar: `\\IP\share`
- Test manual di Command Prompt (as Administrator):
  ```batch
  net use \\192.168.1.12\backup\backup-windows-server "password" /user:username
  ```
- Pastikan username/password benar
- Pastikan NAS accessible dari network

### Infinite Loop / Hang
Script menggunakan `/XJ` untuk skip junctions, sehingga tidak akan hang.
Jika masih hang, pastikan:
- Network connection stabil
- NAS tidak ada timeout issue
- Disk space cukup

### File Permission Denied
Exit code 4-7 dengan beberapa file skip adalah normal untuk:
- System files (digunakan OS saat ini)
- Files yang di-lock aplikasi
- Folder yang memerlukan special permission

## Performance Tips

- **Backup pertama kali** : Memakan waktu lama (tergantung ukuran data)
- **Backup berikutnya** : Lebih cepat (hanya sync file yang berubah)
- **Network speed** : Gunakan network dengan latency rendah
- **NAS speed** : Pastikan NAS memiliki response time yang baik

## Security Notes

- Password disimpan di plain text di file batch
- Gunakan strong password (mix of uppercase, lowercase, numbers, symbols)
- Simpan file backup.bat dengan permission terbatas
- Pertimbangkan untuk menyimpan password di config terpisah

## Catatan

- Script dirancang untuk **Windows Server 2012 R2** tapi kompatibel dengan Windows versi lainnya
- Tested dengan robocopy built-in Windows
- Log file terus di-append, clear secara berkala jika file terlalu besar
- Untuk production, pertimbangkan scheduling dengan Windows Task Scheduler
