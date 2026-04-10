# backup-windows-server

Script `backup.bat` melakukan backup folder `C:\Users` ke NAS Synology menggunakan `robocopy`.

## Konfigurasi

Edit `backup.bat` dan sesuaikan nilai berikut:

- `NAS` : alamat share NAS, contoh `\\192.168.1.666\backup\backup-windows-server`
- `USERNAS` : nama pengguna NAS, contoh `nasuser`
- `PASSNAS` : password NAS, contoh `naspassword`
- `SOURCE` : folder sumber di Windows, default `C:\Users`
- `DEST` : lokasi tujuan di NAS, dibangun dari `%NAS%\server2012_users`
  - contoh hasil akhir: `\\192.168.1.666\backup\backup-windows-server\server2012_users`
- `LOG` : file log backup, default `C:\backup_log.txt`

## Cara kerja

1. Menghubungkan ke NAS dengan `net use`.
2. Membuat folder tujuan di NAS jika belum ada.
3. Menjalankan `robocopy` dengan opsi:
   - `/E` : salin semua subfolder termasuk kosong
   - `/Z` : mode restartable
   - `/XO` : lewati file yang lebih tua di tujuan
   - `/R:2` : mencoba ulang 2 kali pada file yang gagal
   - `/W:5` : menunggu 5 detik antar percobaan
   - `/FFT` : gunakan timestamp 2 detik toleransi
   - `/XA:SH` : kecualikan file tersembunyi dan sistem
   - `/XD` : kecualikan `All Users`, `Default`, `Default User`, `Public`
   - `/LOG+:%LOG%` : tambahkan output ke file log
4. Mencatat waktu mulai dan selesai ke `C:\backup_log.txt`.
5. Melepaskan koneksi NAS dengan `net use /delete`.

## Penggunaan

- Jalankan `backup.bat` di Windows dengan hak administrator.
- Pastikan `net use` dan `robocopy` tersedia di sistem.
- Pastikan share NAS dapat diakses dari mesin Windows.

## Catatan

- `backup.bat` menggunakan path Windows (`C:\Users` dan `C:\backup_log.txt`).
- Pastikan credential NAS sudah benar sebelum menjalankan.
- Jika ingin mengubah folder tujuan, edit variabel `DEST`.

