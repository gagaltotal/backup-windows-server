# backup-windows-server

Script `backup.bat` melakukan backup **seluruh isi drive `C:\`** ke share NAS menggunakan `robocopy`, termasuk XAMPP dan folder aplikasi lainnya, dengan pengecualian hanya untuk folder sistem Windows yang tidak perlu dibackup.

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
4. **Menjalankan `robocopy` dari `C:\` ke `%DEST%`** dengan opsi:
   - `/E` : salin semua subfolder, termasuk yang kosong
   - `/Z` : mode restartable (resume jika koneksi terputus)
   - `/XJ` : **skip semua junctions dan symlinks** (PENTING: mencegah loop infinite di Application Data yang bersifat recursive)
   - `/XO` : lewati file yang lebih tua di tujuan (deduplication)
   - `/XN` : lewati file yang lebih baru di tujuan
   - `/XC` : lewati file yang sudah ada dan tidak berubah
   - `/R:2` : coba ulang 2 kali jika gagal
   - `/W:5` : tunggu 5 detik antar percobaan
   - `/FFT` : gunakan toleransi timestamp 2 detik
   - `/TEE` : tampilkan output ke layar dan log
   - `/XD` : kecualikan folder sistem yang tidak perlu dibackup
   - `/LOG+:%LOG%` : tambahkan output ke file log
5. **Deduplication Check**: Memeriksa apakah folder besar (XAMPP, Users, ProgramData) sudah ada di NAS untuk menghindari duplikasi.
6. Mencatat waktu mulai dan selesai backup ke file log.
7. Melepaskan koneksi ke NAS.

## Folder yang di-backup

**Termasuk dalam backup:**
- `C:\xampp` - web server stack XAMPP
- `C:\Users` - profil pengguna dan aplikasi data (dengan skip junctions)
- `C:\ProgramData` - data aplikasi (kecuali Microsoft dan junctions)
- `C:\Program Files` - aplikasi 32-bit dan 64-bit (kecuali Oracle)
- Semua folder dan file lainnya di `C:\`

**Dikecualikan dari backup:**
- `C:\Windows` - folder sistem operasi
- `C:\$Recycle.Bin` - trash bin
- `C:\System Volume Information` - informasi volume sistem
- `C:\ProgramData\Microsoft` - data Microsoft (sudah ada di Windows)
- `C:\Program Files\Common Files\Oracle` - file umum Oracle
- **Junctions & Symlinks** - skip otomatis dengan `/XJ` untuk mencegah loop (terutama di Application Data)

## Penggunaan

- Jalankan `backup.bat` di Windows dengan hak **Administrator**.
- Pastikan `net use` dan `robocopy` tersedia pada mesin Windows.
- Pastikan share NAS dapat diakses dan kredensial sudah benar.
- Koneksi internet/jaringan harus stabil untuk menghindari timeout.

## Fitur Utama

### 1. **Skip Junctions dengan /XJ**
   - Mencegah loop infinite yang terjadi pada folder dengan junction (seperti Application Data)
   - Folder recursive yang bersifat link akan di-skip otomatis

### 2. **Deduplication Logic**
   - Menggunakan `/XO /XN /XC` untuk skip file yang sudah ada di NAS
   - Deduplication check menampilkan folder yang sudah di-backup

### 3. **Resume Mode**
   - Menggunakan `/Z` sehingga jika koneksi putus, backup dapat dilanjutkan dari titik terakhir

### 4. **Logging**
   - Semua aktivitas backup dicatat ke `C:\backup_log.txt`
   - Log berisi waktu mulai, selesai, dan daftar file yang di-backup

## Perhatian Penting

**Junctions & Symlinks:**
- Jika Anda memiliki folder custom yang bersifat junction/link, gunakan `/XJ` atau tambahkan ke daftar exclude.
- Application Data sering kali junction, script ini sudah handle dengan `/XJ`.

**Performa:**
- Backup pertama kali akan memakan waktu lama tergantung ukuran data di `C:\`.
- Backup berikutnya akan lebih cepat karena hanya sync file yang berubah.

**NAS Connection:**
- Pastikan NAS tidak memutus koneksi saat backup berlangsung.
- Jika NAS memiliki timeout, pertimbangkan untuk menambah `/R` (retry) atau `/W` (wait time).

**Admin Rights:**
- Beberapa folder memerlukan hak administrator untuk diakses.
- Jalankan `backup.bat` dengan `Run as Administrator`.
