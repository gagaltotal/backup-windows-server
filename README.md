# backup-windows-server

Script `backup.bat` melakukan backup seluruh isi drive `C:\` ke share NAS menggunakan `robocopy`, dengan pengecualian folder sistem utama.

## Konfigurasi

Edit `backup.bat` dan sesuaikan nilai berikut:

- `NAS` : alamat share NAS, contoh `\\192.168.1.666\backup\backup-windows-server`
- `USERNAS` : nama pengguna NAS
- `PASSNAS` : password NAS
- `SOURCE` : folder sumber di Windows, default `C:\`
- `DEST` : lokasi tujuan di NAS, dibangun dari `%NAS%\server2012_full`
  - contoh hasil akhir: `\\192.168.1.666\backup\backup-windows-server\server2012_full`
- `LOG` : file log backup, default `C:\backup_log.txt`

## Cara kerja

1. Menghapus koneksi `net use` sebelumnya ke path NAS.
2. Menghubungkan ke NAS dengan kredensial yang diberikan.
3. Membuat folder tujuan di NAS jika belum ada.
4. Menjalankan `robocopy` dari `C:\` ke `%DEST%` dengan opsi:
   - `/E` : salin semua subfolder, termasuk yang kosong
   - `/Z` : mode restartable
   - `/XO` : lewati file yang lebih tua di tujuan
   - `/R:2` : coba ulang 2 kali jika gagal
   - `/W:5` : tunggu 5 detik antar percobaan
   - `/FFT` : gunakan toleransi timestamp 2 detik
   - `/TEE` : tampilkan output ke layar dan log
   - `/XD` : kecualikan folder sistem yang tidak perlu dibackup
   - `/LOG+:%LOG%` : tambahkan output ke file log
5. Mencatat waktu mulai dan selesai backup ke file log.
6. Melepaskan koneksi ke NAS.

## Penggunaan

- Jalankan `backup.bat` di Windows dengan hak administrator.
- Pastikan `net use` dan `robocopy` tersedia pada mesin Windows.
- Pastikan share NAS dapat diakses dan kredensial sudah benar.

## Perhatian

- `backup.bat` saat ini mengecualikan folder:
  - `C:\Windows`
  - `C:\Program Files`
  - `C:\Program Files (x86)`
  - `C:\ProgramData\Microsoft`
  - `C:\$Recycle.Bin`
  - `C:\System Volume Information`
- Jika Anda ingin membackup folder lain, sesuaikan parameter `SOURCE` dan `DEST` di `backup.bat`.
- Jangan jalankan script ini pada perangkat non-Windows, karena path dan perintah bersifat khusus Windows.

