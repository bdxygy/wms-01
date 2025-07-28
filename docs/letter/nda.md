# PERJANJIAN KERJASAMA PENGEMBANGAN SISTEM MANAJEMEN GUDANG (WMS)

**Tanggal:** _________________  
**Lokasi:** _________________

## PIHAK-PIHAK YANG TERLIBAT

**PIHAK PERTAMA (PENGEMBANG):**
- Nama: _________________________________
- Alamat: _______________________________
- Telepon: ______________________________
- Email: ________________________________

**PIHAK KEDUA (PELANGGAN):**
- Nama Perusahaan: ______________________
- Nama PIC: _____________________________
- Alamat: _______________________________
- Telepon: ______________________________
- Email: ________________________________

---

## PASAL 1: OBJEK PERJANJIAN

Pihak Pertama akan mengembangkan dan menyediakan **Sistem Manajemen Gudang (WMS)** yang mencakup aplikasi web dan mobile untuk mengelola inventori, transaksi, dan operasional gudang Pihak Kedua.

---

## PASAL 2: FITUR-FITUR SISTEM

### A. SISTEM BACKEND (LENGKAP & SIAP PRODUKSI)
- **40+ Endpoint API** yang sudah terintegrasi penuh
- **Sistem Keamanan JWT** dengan kontrol akses berbasis peran
- **Database SQLite dengan Drizzle ORM** untuk performa optimal
- **Validasi Data Lengkap** menggunakan Zod untuk keamanan
- **Tracking IMEI** untuk produk elektronik
- **Sistem Barcode** otomatis untuk semua produk
- **Upload Foto (Comming Soon)** sebagai bukti transaksi
- **Pagination & Filter** untuk data besar
- **Audit Trail** dengan soft delete untuk jejak data

### B. APLIKASI MOBILE (95% LENGKAP - SIAP PRODUKSI)
- **Sistem Login Multi-Peran** (Owner, Admin, Staff, Cashier)
- **Dashboard Khusus** sesuai peran pengguna
- **Kamera Profesional** untuk foto produk dan bukti transaksi
- **Scanner Barcode** dengan dukungan multiple format
- **Scanner IMEI** dengan validasi industri standar
- **Manajemen Produk Lengkap** (tambah, edit, hapus, detail)
- **Sistem Transaksi** untuk penjualan dan transfer
- **Manajemen Toko** untuk multi-lokasi
- **Currency Mata Uang** yang didukung dengan pengaturan global
- **Bahasa Indonesia & Inggris** dengan sistem internasionalisasi
- **Desain Modern** mengikuti Material Design 3
- **100+ File Dart** dengan arsitektur production-ready

### C. MANAJEMEN PENGGUNA & HAK AKSES
- **OWNER**: Akses penuh sistem, kelola semua toko dan pengguna
- **ADMIN**: Akses terbatas per toko, kelola staff
- **STAFF**: Akses baca dan cek produk
- **CASHIER**: Hanya transaksi penjualan

### D. FITUR BISNIS UTAMA
- **Multi-Toko**: Kelola beberapa toko dalam satu sistem
- **Inventori Real-time**: Update stok otomatis
- **Barcode System**: Generate dan scan barcode produk
- **IMEI Tracking**: Khusus produk elektronik
- **Foto Bukti (Comming Soon)**: Dokumentasi transaksi
- **Laporan (Comming Soon)**: Dashboard dan metrik bisnis
- **Data Scoped (Comming Soon)**: Setiap owner hanya melihat data miliknya

---

## PASAL 3: DELIVERABLES (YANG DISERAHKAN)

### A. KODE SUMBER LENGKAP
- **Backend**: 51 file TypeScript siap produksi
- **Mobile**: 100+ file Dart dengan arsitektur modern
- **Database**: Schema lengkap dengan migrasi
- **Dokumentasi**: Panduan instalasi dan penggunaan

### B. DEPLOYMENT & SETUP
- **Instalasi sistem** di server Pihak Kedua
- **Konfigurasi database** dan environment
- **Testing lengkap** semua fitur
- **Handover** dan pelatihan penggunaan

---

## PASAL 4: TIMELINE PENGERJAAN

| Fase | Deskripsi | Estimasi Waktu |
|------|-----------|----------------|
| 1 | Setup & Konfigurasi Sistem | 1-2 hari |
| 2 | Kustomisasi sesuai kebutuhan | 2-3 hari |
| 3 | Testing & Debugging | 1-2 hari |
| 4 | Deployment & Pelatihan | 1 hari |
| **TOTAL** | **Siap Produksi** | **5-8 hari** |

---

## PASAL 5: NILAI KONTRAK

**Total Biaya Pengembangan Tahap Pertama:** Rp 5000000

**Pembayaran:**
- **DP 0%**: Rp 0 (sebelum mulai)
- **Pelunasan tahap pertama 100%**: Rp 5000000 (setelah selesai)

---

## PASAL 6: HAK CIPTA & KEPEMILIKAN

- **Kode sumber** tetap menjadi milik penuh Pihak Pertama setelah pelunasan
- **Dokumentasi** dan panduan disertakan
- **Hak modifikasi** sepenuhnya milik Pihak Kedua

---

## PASAL 7: GARANSI & SUPPORT

### A. GARANSI TEKNIS
- **30 hari garansi** bug fixing setelah delivery
- **Sistem berjalan stabil** sesuai spesifikasi
- **Performance optimal** untuk operasional harian

### B. SUPPORT LANJUTAN (OPSIONAL)
Lihat **Formulir Layanan Tambahan** di bawah untuk:
- Backup database berkala *Bulanan,Mingguan,harian
- Update fitur rutin
- Maintenance sistem *Bulanan,Mingguan,harian

---

## PASAL 8: KERAHASIAAN DATA

- **Pihak Pertama** wajib menjaga kerahasiaan data bisnis Pihak Kedua
- **Data tidak boleh** dibagikan kepada pihak ketiga
- **Akses data** hanya untuk keperluan pengembangan dan support
- **Penghapusan data** dari sistem Pihak Pertama setelah handover

---

## PASAL 9: FORCE MAJEURE

Jika terjadi keadaan kahar (bencana alam, pandemi, dll) yang mempengaruhi timeline, kedua pihak akan bermusyawarah untuk penyesuaian jadwal.

---

## PASAL 10: PENYELESAIAN SENGKETA

Segala perselisihan diselesaikan secara musyawarah. Jika tidak tercapai kesepakatan, akan diselesaikan melalui jalur hukum yang berlaku di Indonesia.

---

## TANDA TANGAN

**PIHAK PERTAMA (PENGEMBANG)**

Nama: ________________________  
Tanda Tangan: _________________  
Tanggal: ______________________

**PIHAK KEDUA (PELANGGAN)**

Nama: ________________________  
Jabatan: ______________________  
Tanda Tangan: _________________  
Tanggal: ______________________  
Materai: ______________________

---

# FORMULIR LAYANAN TAMBAHAN

## A. LAYANAN BACKUP DATABASE

### Paket Backup Otomatis
- **Harian**: Rp 50.000/bulan
  - Backup setiap hari jam 23:00
  - Simpan 30 hari terakhir
  
- **Mingguan**: Rp 75.000/bulan
  - Backup setiap Minggu
  - Simpan 12 minggu terakhir
  - Laporan bulanan
  
- **Bulanan**: Rp 50.000/bulan
  - Backup setiap awal bulan
  - Simpan 12 bulan terakhir
  - Laporan tahunan

### Fitur Backup
- **Cloud Storage** 24/7 aman dengan enkripsi
- **Restore cepat** maksimal 1 jam

---

## B. LAYANAN MAINTENANCE SISTEM

- **Maintenance**: Rp 200.000/bulan
  - Performance check
  - Monthly report
  - Sudah termasuk backup DB

---

## D. FITUR ADD-ONS (COMING SOON FEATURES)

### Paket Fitur Tambahan
- **Upload Foto**: Rp 550.000 (one-time)
  - Implementasi upload foto untuk bukti transaksi
  - Kompresi dan storage management
  - API endpoint lengkap untuk photo handling
  - Integration dengan mobile app
  - Estimasi: 3-4 hari pengerjaan
  
- **Sistem Laporan & Analytics**: Rp 850.000 (one-time)
  - Dashboard metrik bisnis lengkap
  - Laporan penjualan harian/bulanan/tahunan
  - Export laporan ke PDF/Excel
  - Grafik dan visualisasi data
  - Real-time analytics
  - Estimasi: 7-10 hari pengerjaan
  
- **Product Check System**: Rp 650.000 (one-time)
  - Sistem check ketersediaan produk
  - Barcode scanning untuk stock verification
  - Real-time inventory validation
  - Multi-store product checking
  - Audit trail untuk setiap pengecekan
  - Mobile app integration lengkap
  - Estimasi: 4-5 hari pengerjaan

## E. LAYANAN CUSTOM DEVELOPMENT

### Pengembangan Fitur Khusus
- **Analisis Kebutuhan**: Rp 200.000
- **Development**: Rp 100.000/hari
- **Deployment**: Rp 100.000

### Estimasi Fitur Umum
- **Modul Backend Baru**: 5-10 hari (Mulai Rp 250.000)
- **Mobile Feature**: 2-10 hari (Mulai Rp 250.000)

---

## PEMILIHAN LAYANAN TAMBAHAN

**Saya tertarik dengan layanan berikut:**

### Maintenance (Rp 200.000/bulan)

### Fitur Add-ons (One-time Payment)
☐ Upload Foto Backend (Rp 550.000)  
☐ Sistem Laporan & Analytics (Rp 850.000)  
☐ Product Check System (Rp 650.000)  

### Custom Development
☐ Ya, akan diskusi kebutuhan spesifik  
☐ Tidak untuk saat ini

**Total Biaya Layanan Bulanan:** Rp _______________
**Total Biaya Fitur Add-ons (One-time):** Rp _______________
**GRAND TOTAL:** Rp _______________

**Mulai Tanggal:** _______________

---

**Catatan Khusus/Permintaan:**
_________________________________________________
_________________________________________________
_________________________________________________

**Persetujuan Layanan Tambahan:**

**PIHAK PERTAMA**  
Tanda Tangan: _________________

**PIHAK KEDUA**  
Tanda Tangan: _________________