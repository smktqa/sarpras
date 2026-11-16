# SARPRAS - Sistem Sarana & Prasarana Sekolah

Aplikasi web untuk mengelola inventaris aset sekolah: KIB A (Tanah), KIB D (Jalan/Irigasi/Jaringan), KIB E (Buku), dan Barang Habis Pakai, lengkap dengan rekap, import/export Excel, serta cetak PDF berkop.

Dibangun dengan Django 6 dan SQLite, antarmuka Bootstrap 5.

## Fitur

**KIB A - Tanah**
- CRUD data tanah (kode barang, luas, lokasi, status, tahun perolehan)
- Cetak laporan PDF dengan kop sekolah, QR code, dan total luas

**KIB D - Jalan / Irigasi / Jaringan**
- CRUD data jalan (panjang, lokasi, kondisi, tahun perolehan)
- Cetak laporan PDF

**KIB E - Buku**
- CRUD buku + upload cover
- Pencarian judul/kode/pengarang
- Import dari Excel dan export ke Excel
- Rekap jumlah judul, eksemplar, dan kondisi
- Cetak laporan PDF

**Barang Habis Pakai (BHP)**
- Master barang + stok
- Pencatatan barang masuk dan keluar (transaksional, stok tidak boleh minus)
- Riwayat transaksi per barang
- Import CSV/Excel
- Laporan transaksi per periode (PDF)

**Admin**
- Semua model terdaftar di Django admin (`/admin/`)

## Stack

| Komponen | Versi |
|---|---|
| Python | 3.12+ (diuji di 3.14) |
| Django | 6.0.2 |
| Database | SQLite |
| PDF | xhtml2pdf |
| Excel | openpyxl |
| QR code | qrcode + Pillow |
| UI | Bootstrap 5.3 (CDN) |

## Struktur

```
.
├─ manage.py
├─ requirements.txt
├─ run.ps1                  # bootstrap + jalankan server (Windows)
├─ config/                  # settings, urls, wsgi/asgi
└─ sarpras/                 # app utama
   ├─ models.py             # Tanah, Jalan, Buku, BarangHabisPakai(+Masuk/Keluar)
   ├─ views.py              # seluruh logika view
   ├─ urls.py
   ├─ admin.py
   ├─ migrations/
   ├─ static/sarpras/       # logo, css
   └─ templates/
      ├─ sarpras/           # dashboard, KIB A/D/E, form, PDF
      └─ bhp/               # stok, transaksi, riwayat, PDF
```

## Menjalankan (Windows)

Cara cepat:

```powershell
.\run.ps1
```

Skrip akan otomatis membuat virtual environment, memasang dependency, dan menjalankan server di <http://127.0.0.1:8000>.

Opsi:

```powershell
.\run.ps1 -Port 8001      # ganti port
.\run.ps1 -Rebuild        # buat ulang venv dari nol
```

Manual:

```powershell
py -3.14 -m venv venv
.\venv\Scripts\python.exe -m pip install -r requirements.txt
.\venv\Scripts\python.exe manage.py migrate
.\venv\Scripts\python.exe manage.py createsuperuser
.\venv\Scripts\python.exe manage.py runserver
```

## Login

Area admin ada di `/admin/`. Buat akun dengan `python manage.py createsuperuser`.

> Catatan: halaman aplikasi (dashboard, KIB, BHP) saat ini belum memakai autentikasi.

## Deploy

Aplikasi ini dirancang untuk bisa dijalankan di hosting shared berbasis Phusion Passenger (mis. serv00), dengan catatan:

- `collectstatic` ke folder `public/` yang disajikan langsung oleh web server
- set `DEBUG = False`, `SECRET_KEY` dari environment, dan `ALLOWED_HOSTS`
- dependency native (`Pillow`, `cryptography`) perlu dikompilasi di FreeBSD

## Known issues

- `/buku/` dipaginasi 10 baris di view, tetapi template belum menampilkan tombol halaman
- Form edit Jalan tidak mengisi nilai lama (field kosong saat edit)
- Hapus data memakai GET (belum POST + CSRF)
- Belum ada login/otorisasi pada halaman aplikasi
- `semua_kib_cetak_pdf` dan blok kode setelah `return` di `buku_cetak_pdf` tidak terpakai
