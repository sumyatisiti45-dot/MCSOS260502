# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M13]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

# 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode Praktikum | M13 |
| Judul Praktikum | Virtual File System (VFS), RAM File System (RAMFS), dan File Descriptor |
| Jenis Pengerjaan | Individu |
| Nama Mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama Kelompok | - |
| Anggota Kelompok | - |
| Tanggal Praktikum | 2026 |
| Tanggal Pengumpulan | 2026 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m13-vfs-ramfs |
| Commit Akhir | 6cf6715 |
| Status Readiness | Siap Demonstrasi Praktikum |

---

# 1. Sampul

# Laporan Praktikum M13

## Virtual File System (VFS), RAM File System (RAMFS), dan File Descriptor

Disusun oleh:

| Nama | NIM | Kelas |
|---|---|---|
| Siti Sumyati | 2583207073008 | 1B |

Dosen Pengampu:

**Muhaemin Sidiq, S.Pd., M.Pd.**

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

2026

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa seluruh implementasi, pengujian, dan dokumentasi pada Praktikum M13 merupakan hasil pengerjaan sendiri berdasarkan panduan Praktikum MCSOS260502. Seluruh proses implementasi dilakukan pada repository Git dan seluruh bukti pengujian diperoleh dari hasil build, host test, audit, commit, serta push repository.

| Pernyataan | Status |
|---|---|
| Semua perubahan dicatat pada Git | Ya |
| Menggunakan repository sendiri | Ya |
| Host Test dijalankan | Ya |
| Audit dijalankan | Ya |
| Build berhasil | Ya |

---

# 3. Tujuan Praktikum

Tujuan praktikum M13 adalah:

1. Mengimplementasikan Virtual File System (VFS).
2. Mengimplementasikan RAM File System (RAMFS).
3. Mengimplementasikan File Descriptor.
4. Melakukan Host Test terhadap implementasi VFS.
5. Melakukan Freestanding Object Build.
6. Melakukan Audit menggunakan toolchain.
7. Mengintegrasikan seluruh implementasi ke dalam Makefile.

---

# 4. Capaian Pembelajaran Praktikum

Setelah menyelesaikan praktikum ini mahasiswa mampu:

- Memahami konsep Virtual File System.
- Memahami konsep RAM File System.
- Mengimplementasikan File Descriptor.
- Mengimplementasikan operasi dasar sistem berkas.
- Melakukan pengujian Host Test.
- Melakukan Build Object Freestanding.
- Melakukan Audit Object File.
- Menggunakan Git sebagai version control.

---

# 5. Peta Milestone MCSOS

Milestone yang dibahas pada laporan ini adalah:

✅ **M13 – Virtual File System (VFS), RAMFS, dan File Descriptor**

Batas cakupan praktikum:

- Implementasi header VFS.
- Implementasi RAMFS.
- Implementasi File Descriptor.
- Implementasi antarmuka system VFS.
- Host Test.
- Object Build.
- Audit.

---

# 6. Dasar Teori

## 6.1 Virtual File System (VFS)

Virtual File System merupakan lapisan abstraksi yang menyediakan antarmuka umum bagi berbagai jenis sistem berkas sehingga kernel tidak bergantung pada satu jenis file system tertentu.

## 6.2 RAM File System (RAMFS)

RAMFS merupakan sistem berkas sederhana yang seluruh data disimpan di memori utama sehingga memiliki akses yang cepat dan mudah digunakan sebagai media pembelajaran.

## 6.3 File Descriptor

File Descriptor merupakan identitas numerik yang digunakan proses untuk mengakses file yang sedang dibuka. Descriptor menyimpan informasi mengenai file serta posisi baca dan tulis.

## 6.4 Operasi Dasar Sistem Berkas

Operasi dasar sistem berkas meliputi:

- Membuka file
- Menutup file
- Membaca file
- Menulis file
- Mengelola File Descriptor

---

# 7. Lingkungan Praktikum

## 7.1 Host

- Windows 11
- Ubuntu WSL2

## 7.2 Toolchain

- Clang
- LLVM
- GNU Make
- Git
- Bash

## 7.3 Repository

Repository:

```
~/src/mcsos
```

Branch:

```
praktikum-m13-vfs-ramfs
```

Repository GitHub:

```
https://github.com/sumyatisiti45-dot/MCSOS260502
```

---

# 8. Repository dan Struktur File

## 8.1 Struktur Folder

```
include/
kernel/vfs/
tests/
build/m13/
```

## 8.2 File yang Dibuat

```
include/mcs_vfs.h

kernel/vfs/ramfs.c

kernel/vfs/fd.c

kernel/vfs/sys_vfs.c

tests/m13_vfs_host_test.c
```

## 8.3 Ringkasan Perubahan

Perubahan yang dilakukan selama praktikum:

- Menambahkan header VFS.
- Menambahkan implementasi RAMFS.
- Menambahkan implementasi File Descriptor.
- Menambahkan antarmuka System VFS.
- Menambahkan Host Test.
- Menambahkan target M13 pada Makefile.
- Melakukan commit ke repository Git.
- Melakukan push ke GitHub.
# 9. Desain Teknis

## 9.1 Masalah

Sebelum implementasi M13, kernel belum memiliki mekanisme untuk mengelola sistem berkas secara terstruktur. Belum tersedia Virtual File System (VFS), RAM File System (RAMFS), maupun File Descriptor sehingga operasi file belum dapat dilakukan.

## 9.2 Solusi

Solusi yang diterapkan adalah mengimplementasikan:

- Header VFS (`mcs_vfs.h`)
- RAM File System (`ramfs.c`)
- File Descriptor (`fd.c`)
- Antarmuka System VFS (`sys_vfs.c`)
- Host Test (`m13_vfs_host_test.c`)
- Integrasi target M13 ke dalam Makefile

Dengan implementasi tersebut kernel memiliki layanan dasar sistem berkas yang dapat diuji menggunakan host test.

## 9.3 Diagram

Alur implementasi VFS:

```
User Program
      │
      ▼
System Call
      │
      ▼
Virtual File System
      │
      ├──────────────┐
      ▼              ▼
 File Descriptor   RAMFS
      │              │
      └──────┬───────┘
             ▼
          Memory
```

## 9.4 Struktur Data

Struktur data utama yang digunakan meliputi:

- Struktur VFS
- Struktur File Descriptor
- Struktur RAMFS
- Struktur File
- Struktur Direktori

## 9.5 Manajemen Resource

Implementasi mengatur:

- Alokasi File Descriptor
- Penyimpanan data pada RAMFS
- Validasi akses file
- Operasi buka dan tutup file

## 9.6 Keamanan Memori

Beberapa validasi dilakukan untuk menjaga keamanan implementasi:

- Pemeriksaan pointer.
- Pemeriksaan batas ukuran data.
- Validasi descriptor.
- Validasi akses file.

---

# 10. Langkah Kerja Implementasi

## Langkah 1

Membuat branch baru:

```bash
git checkout -b praktikum-m13-vfs-ramfs
```

## Langkah 2

Membuat struktur direktori:

```bash
mkdir -p include kernel/vfs tests build/m13
```

## Langkah 3

Membuat file:

- include/mcs_vfs.h
- kernel/vfs/ramfs.c
- kernel/vfs/fd.c
- kernel/vfs/sys_vfs.c
- tests/m13_vfs_host_test.c

Kemudian dilakukan pemeriksaan sintaks menggunakan:

```bash
clang -std=c17 -Wall -Wextra -Werror -Iinclude -fsyntax-only
```

## Langkah 4

Menambahkan target M13 pada Makefile kemudian menjalankan:

```bash
make m13-host-test
make m13-objects
make m13-audit
```

## Langkah 5

Melakukan version control menggunakan Git:

```bash
git add .
git commit -m "M13 VFS RAMFS selesai"
git push -u origin praktikum-m13-vfs-ramfs
```

---

# 11. Checkpoint Buildable

Checkpoint yang berhasil dicapai:

| Checkpoint | Status |
|------------|--------|
| Header VFS | ✅ |
| RAMFS | ✅ |
| File Descriptor | ✅ |
| System VFS | ✅ |
| Host Test | ✅ |
| Object Build | ✅ |
| Audit | ✅ |

Seluruh checkpoint berhasil dilewati tanpa error kompilasi.

---

# 12. Perintah Uji dan Validasi

## 12.1 Host Test

Perintah:

```bash
make m13-host-test
```

Hasil:

```
M13 VFS/FD/RAMFS host tests: PASS
```

## 12.2 Object Build

Perintah:

```bash
make m13-objects
```

Berhasil menghasilkan:

- ramfs.o
- fd.o
- sys_vfs.o

## 12.3 Audit

Perintah:

```bash
make m13-audit
```

Audit berhasil menghasilkan:

- vfs.o
- nm-undefined.txt
- readelf-vfs.txt
- objdump-vfs.txt
- sha256sums.txt

Tidak ditemukan undefined symbol.

---

# 13. Hasil Uji

Hasil pengujian menunjukkan bahwa seluruh implementasi berhasil dikompilasi dan dijalankan.

Ringkasan hasil:

| Pengujian | Status |
|-----------|--------|
| Header | PASS |
| RAMFS | PASS |
| File Descriptor | PASS |
| System VFS | PASS |
| Host Test | PASS |
| Object Build | PASS |
| Audit | PASS |

Implementasi berhasil memenuhi seluruh checkpoint pada praktikum M13.

# 14. Analisis Teknis

Implementasi M13 berhasil menambahkan Virtual File System (VFS), RAM File System (RAMFS), dan File Descriptor ke dalam kernel MCSOS. Struktur VFS digunakan sebagai antarmuka umum sistem berkas, sedangkan RAMFS menjadi implementasi file system yang seluruh datanya disimpan di memori. File Descriptor digunakan untuk mengelola file yang sedang dibuka oleh proses.

Seluruh file berhasil dikompilasi menggunakan Clang tanpa menghasilkan error sintaks. Host Test menunjukkan bahwa implementasi telah berjalan sesuai dengan yang diharapkan. Object build dan audit juga berhasil dilakukan tanpa ditemukan undefined symbol.

---

# 15. Debugging dan Failure Modes

Selama proses praktikum dilakukan beberapa pemeriksaan untuk memastikan implementasi berjalan dengan baik.

| Pemeriksaan | Hasil |
|-------------|--------|
| Syntax Check | Berhasil |
| Host Test | PASS |
| Object Build | Berhasil |
| Audit | Berhasil |
| Git Commit | Berhasil |
| Git Push | Berhasil |

Permasalahan yang sempat ditemukan adalah target M13 pada Makefile belum tersedia sehingga perlu ditambahkan sebelum proses build dapat dijalankan.

---

# 16. Prosedur Rollback

Apabila terjadi kesalahan implementasi, langkah rollback yang dapat dilakukan adalah:

1. Mengembalikan perubahan menggunakan Git.
2. Menghapus file hasil build.

Perintah yang digunakan:

```bash
git restore .
make clean
```

Apabila diperlukan, branch dapat dikembalikan ke commit sebelumnya menggunakan Git.

---

# 17. Keamanan dan Reliability

Implementasi memperhatikan beberapa aspek berikut:

- Validasi parameter.
- Validasi File Descriptor.
- Validasi struktur VFS.
- Pemeriksaan batas data.
- Pemeriksaan pointer.
- Pemeriksaan hasil build menggunakan audit.

Dengan validasi tersebut implementasi menjadi lebih aman dan mudah diuji.

---

# 18. Pembagian Kerja Kelompok

Praktikum M13 dikerjakan secara individu sehingga tidak terdapat pembagian tugas antaranggota.

---

# 19. Kriteria Lulus Praktikum

Kriteria kelulusan yang berhasil dipenuhi:

- Implementasi `mcs_vfs.h`
- Implementasi `ramfs.c`
- Implementasi `fd.c`
- Implementasi `sys_vfs.c`
- Host Test berhasil
- Object Build berhasil
- Audit berhasil
- Repository berhasil di-push ke GitHub

---

# 20. Readiness Review

| Pemeriksaan | Status |
|-------------|--------|
| Header | ✔ |
| RAMFS | ✔ |
| File Descriptor | ✔ |
| System VFS | ✔ |
| Host Test | ✔ |
| Object Build | ✔ |
| Audit | ✔ |
| Git | ✔ |

Status akhir:

```
READY
```

---

# 21. Rubrik Penilaian

Bagian ini disediakan untuk dosen atau asisten praktikum.

---

# 22. Kesimpulan

Praktikum M13 berhasil diselesaikan dengan mengimplementasikan Virtual File System (VFS), RAM File System (RAMFS), dan File Descriptor pada MCSOS.

Seluruh file berhasil dikompilasi tanpa error. Host Test berhasil dijalankan dengan status PASS. Object Build berhasil menghasilkan object file yang valid. Audit berhasil dilakukan tanpa ditemukan undefined symbol.

Seluruh perubahan berhasil disimpan menggunakan Git dan dikirim ke repository GitHub pada branch:

```
praktikum-m13-vfs-ramfs
```

Dengan demikian seluruh tujuan praktikum M13 telah tercapai.

---

# 23. Lampiran

## Struktur Folder

```
include/
├── mcs_vfs.h

kernel/
└── vfs/
    ├── ramfs.c
    ├── fd.c
    └── sys_vfs.c

tests/
└── m13_vfs_host_test.c

build/
└── m13/
```

## Perintah yang Digunakan

```bash
make m13-host-test

make m13-objects

make m13-audit

git add .

git commit -m "M13 VFS RAMFS selesai"

git push -u origin praktikum-m13-vfs-ramfs
```

## Bukti Pengujian

Lampirkan screenshot berikut:

- Host Test PASS
- Object Build
- Audit PASS
- Git Status
- Git Commit
- Git Push
- Branch GitHub

---

# 24. Daftar Referensi

1. Intel Corporation. *Intel® 64 and IA-32 Architectures Software Developer's Manual.*

2. LLVM Project. *Clang Documentation.*

3. GNU Project. *GNU Make Manual.*

4. Linux Kernel Documentation. *Virtual File System (VFS).*

5. Git SCM Documentation.

6. Panduan Praktikum MCSOS260502 Milestone 13.

---

# 25. Checklist Final

| Item | Status |
|------|--------|
| Header selesai | ✔ |
| RAMFS selesai | ✔ |
| File Descriptor selesai | ✔ |
| System VFS selesai | ✔ |
| Host Test PASS | ✔ |
| Object Build PASS | ✔ |
| Audit PASS | ✔ |
| Commit Git | ✔ |
| Push GitHub | ✔ |
| Laporan selesai | ✔ |

---

# 26. Pernyataan Pengumpulan

**Commit Akhir:**

```
6cf6715
```

**Status:**

```
SELESAI
```

**Ringkasan:**

Praktikum M13 telah berhasil diselesaikan dengan mengimplementasikan Virtual File System (VFS), RAM File System (RAMFS), dan File Descriptor. Seluruh pengujian, build, audit, commit, dan push ke GitHub berhasil dilakukan sesuai panduan praktikum.