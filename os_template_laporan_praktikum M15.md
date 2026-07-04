# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M15]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

# Laporan Praktikum M15
# Filesystem Persistent Minimal MCSFS1, On-Disk Superblock/Inode/Directory, dan Fsck-Lite pada MCSOS

---

# 0. Metadata Laporan

| Atribut | Isi |
|---------|-----|
| Kode Praktikum | M15 |
| Judul Praktikum | Filesystem Persistent Minimal MCSFS1 |
| Jenis Pengerjaan | Individu |
| Nama Mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Dosen | Muhaemin Sidiq, S.Pd., M.Pd. |
| Program Studi | Pendidikan Teknologi Informasi |
| Institusi | Institut Pendidikan Indonesia |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m15-mcsfs1 |
| Commit Awal | b63e840 |
| Commit Akhir | a4b5438 |
| Status | Siap Uji Host Test |

---

# 1. Pendahuluan

## Latar Belakang

Pada praktikum M15 dilakukan implementasi filesystem sederhana bernama **MCSFS1** sebagai dasar filesystem persisten pada sistem operasi MCSOS.

Filesystem ini digunakan untuk mempelajari bagaimana sebuah sistem operasi menyimpan metadata file ke media penyimpanan menggunakan struktur seperti superblock, inode, directory entry, serta mekanisme sinkronisasi sederhana.

Selain implementasi filesystem, praktikum ini juga melakukan pengujian menggunakan host test untuk memastikan seluruh fungsi dapat dikompilasi serta berjalan sesuai spesifikasi.

---

# 2. Tujuan

Praktikum ini bertujuan untuk:

1. Membuat modul filesystem MCSFS1.
2. Membuat struktur header filesystem.
3. Mengimplementasikan source filesystem.
4. Membuat unit test host.
5. Menambahkan target build pada Makefile.
6. Melakukan validasi menggunakan host test.
7. Menghasilkan artefak build sebagai bukti implementasi.

---

# 3. Lingkungan Praktikum

## Sistem Operasi

Ubuntu 24.04.4 LTS pada WSL2 Windows 11.

## Compiler

Ubuntu clang version 18.1.3

## Linker

GNU ld 2.42

## Tools

- GNU Make 4.3
- GNU nm 2.42
- GNU readelf 2.42
- GNU objdump 2.42
- QEMU 8.2.2

Target arsitektur:

```
x86_64-elf
```

---

# 4. Langkah Praktikum

## 4.1 Membuat Branch Baru

Perintah:

```bash
git switch -c praktikum-m15-mcsfs1
```

Hasil:

```
Switched to a new branch 'praktikum-m15-mcsfs1'
```

---

## 4.2 Membuat Struktur Folder

Perintah:

```bash
mkdir -p fs/mcsfs1 tests/m15 artifacts/m15
```

Folder yang dibuat:

- fs/mcsfs1
- tests/m15
- artifacts/m15

---

## 4.3 Mengumpulkan Informasi Host

Perintah:

```bash
uname -a
clang --version
ld --version
nm --version
readelf --version
objdump --version
make --version
qemu-system-x86_64 --version
```

Hasil menunjukkan seluruh toolchain telah tersedia dan siap digunakan.

---

## 4.4 Membuat Script Preflight

File:

```
scripts/m15_preflight.sh
```

Script diberikan hak eksekusi menggunakan

```bash
chmod +x scripts/m15_preflight.sh
```

Kemudian dilakukan pengecekan:

```bash
wc -l scripts/m15_preflight.sh
```

Hasil:

```
23 scripts/m15_preflight.sh
```

---

## 4.5 Menjalankan Preflight

Perintah:

```bash
./scripts/m15_preflight.sh
```

Hasil menunjukkan:

- Toolchain tersedia
- Repository valid
- Artifact M14 ditemukan
- Seluruh tool dapat dijalankan

---

## 4.6 Membuat Header Filesystem

File:

```
fs/mcsfs1/mcsfs1.h
```

Jumlah baris:

```
50 baris
```

Validasi:

```bash
clang -std=c17 -Wall -Wextra -Werror -I. -fsyntax-only fs/mcsfs1/mcsfs1.h
```

Tidak ditemukan error.

---

## 4.7 Membuat Source Filesystem

File:

```
fs/mcsfs1/mcsfs1.c
```

Jumlah baris:

```
653 baris
```

Validasi:

```bash
clang -target x86_64-elf \
-std=c17 \
-ffreestanding \
-Wall -Wextra -Werror \
-I. \
-fsyntax-only fs/mcsfs1/mcsfs1.c
```

Source berhasil dikompilasi tanpa error.

---

## 4.8 Membuat Unit Test

File:

```
tests/m15/test_mcsfs1.c
```

Jumlah baris:

```
96 baris
```

Validasi:

```bash
clang -std=c17 \
-Wall -Wextra -Werror \
-I. \
-fsyntax-only tests/m15/test_mcsfs1.c
```

Tidak ditemukan error.

---

## 4.9 Memperbarui Makefile

Ditambahkan target baru:

```
m15-all
```

Target ini bertugas:

- compile host test
- compile freestanding object
- membuat relocatable object
- menjalankan host test
- menjalankan nm
- menjalankan readelf
- menjalankan objdump
- membuat SHA256SUMS

---

## 4.10 Build M15

Perintah:

```bash
make m15-all
```

Build berhasil.

Host test menghasilkan:

```
M15 host test passed: flush_count=5
```

Objek berhasil dibuat:

- mcsfs1.o
- mcsfs1.rel.o

Readelf menunjukkan:

```
ELF64
Machine : AMD x86-64
Type : REL
```

Semua hash SHA256 berhasil dibuat.

---

## 4.11 Commit

Perintah:

```bash
git add .
git commit -m "M15 MCSFS1 selesai"
```

Commit berhasil dibuat dengan hash:

```
a4b5438
```

---

## 4.12 Push Repository

Perintah:

```bash
git push -u origin praktikum-m15-mcsfs1
```

Branch berhasil diunggah ke GitHub.

```
praktikum-m15-mcsfs1 -> origin/praktikum-m15-mcsfs1
```

---

## 4.13 Verifikasi Repository

Perintah:

```bash
git status
```

Hasil:

```
nothing to commit,
working tree clean
```

Hal ini menunjukkan seluruh perubahan telah tersimpan pada repository.
---

# 5. Peta Milestone MCSOS

| Milestone | Status |
|-----------|--------|
| M0 | Selesai |
| M1 | Selesai |
| M2 | Selesai |
| M3 | Selesai |
| M4 | Selesai |
| M5 | Selesai |
| M6 | Selesai |
| M7 | Selesai |
| M8 | Selesai |
| M9 | Selesai |
| M10 | Selesai |
| M11 | Selesai |
| M12 | Selesai |
| M13 | Selesai |
| M14 | Selesai |
| **M15** | **Sedang dibahas pada laporan ini** |
| M16 | Belum dikerjakan |

Batas cakupan praktikum M15 meliputi implementasi filesystem minimal MCSFS1, penyusunan struktur superblock, inode, direktori, pengujian host, build freestanding, serta audit object file. Implementasi belum mencakup fitur journaling, multi-user, ataupun recovery lanjutan.

---

# 6. Dasar Teori

## 6.1 Filesystem

Filesystem merupakan mekanisme yang digunakan sistem operasi untuk mengatur penyimpanan data pada media penyimpanan. Filesystem menyimpan informasi mengenai file, direktori, ukuran file, lokasi blok data, serta metadata lainnya.

Pada praktikum ini digunakan filesystem sederhana bernama **MCSFS1** sebagai media pembelajaran mengenai organisasi filesystem pada kernel.

---

## 6.2 Superblock

Superblock berisi informasi utama mengenai filesystem, seperti ukuran media, jumlah inode, jumlah blok data, dan informasi penting lain yang diperlukan ketika filesystem di-mount.

Superblock menjadi struktur pertama yang dibaca ketika filesystem digunakan.

---

## 6.3 Inode

Inode merupakan struktur data yang menyimpan metadata file.

Informasi yang disimpan antara lain:

- ukuran file
- jenis file
- nomor blok data
- jumlah link

Pada praktikum ini inode digunakan untuk merepresentasikan file maupun direktori.

---

## 6.4 Directory Entry

Directory Entry merupakan struktur yang menghubungkan nama file dengan inode.

Direktori berisi kumpulan directory entry sehingga kernel dapat menemukan inode berdasarkan nama file.

---

## 6.5 Block Device

Filesystem bekerja di atas Block Device.

Block Device menyediakan operasi baca dan tulis blok data sehingga filesystem tidak perlu mengetahui bagaimana media penyimpanan bekerja secara langsung.

---

# 7. Lingkungan Praktikum

| Komponen | Nilai |
|-----------|-------|
| Host OS | Ubuntu 24.04.4 LTS (WSL2) |
| Target | x86_64-elf |
| Compiler | Clang 18.1.3 |
| Linker | GNU ld 2.42 |
| GNU Make | 4.3 |
| GNU nm | 2.42 |
| GNU readelf | 2.42 |
| GNU objdump | 2.42 |
| Emulator | QEMU 8.2.2 |

Repository:

```
~/src/mcsos
```

Branch:

```
praktikum-m15-mcsfs1
```

Commit awal:

```
b63e840
```

Commit akhir:

```
a4b5438
```

---

# 8. Repository dan Struktur File

File yang dibuat selama praktikum:

| File | Keterangan |
|------|------------|
| fs/mcsfs1/mcsfs1.h | Header filesystem |
| fs/mcsfs1/mcsfs1.c | Implementasi filesystem |
| tests/m15/test_mcsfs1.c | Host unit test |
| scripts/m15_preflight.sh | Script preflight |
| artifacts/m15/* | Artefak hasil build |

Struktur direktori:

```text
fs/
└── mcsfs1/
    ├── mcsfs1.c
    └── mcsfs1.h

tests/
└── m15/
    └── test_mcsfs1.c

scripts/
└── m15_preflight.sh

artifacts/
└── m15/
```

---

# 9. Desain Teknis

Filesystem MCSFS1 dirancang menggunakan struktur sederhana agar mudah dipahami.

Komponen utama terdiri atas:

- Superblock
- Inode Table
- Directory Entry
- Data Block

Hubungan antar komponen:

```text
Disk
 │
 ├── Superblock
 │
 ├── Inode Table
 │
 ├── Directory Entry
 │
 └── Data Block
```

Unit test digunakan untuk memastikan setiap operasi filesystem menghasilkan perilaku yang benar.

---

# 10. Langkah Kerja Implementasi

## Langkah 1

Membuat branch baru.

```bash
git switch -c praktikum-m15-mcsfs1
```

Status:

PASS

---

## Langkah 2

Membuat struktur folder.

```bash
mkdir -p fs/mcsfs1 tests/m15 artifacts/m15
```

Status:

PASS

---

## Langkah 3

Mengumpulkan informasi host.

```bash
uname -a
clang --version
ld --version
```

Status:

PASS

---

## Langkah 4

Membuat script preflight.

```bash
scripts/m15_preflight.sh
```

Status:

PASS

---

## Langkah 5

Membuat file:

```
mcsfs1.h
```

Validasi:

```bash
clang -fsyntax-only
```

Status:

PASS

---

## Langkah 6

Membuat file:

```
mcsfs1.c
```

Jumlah baris:

```
653
```

Status:

PASS

---

## Langkah 7

Membuat host unit test.

File:

```
test_mcsfs1.c
```

Jumlah baris:

```
96
```

Status:

PASS

---

## Langkah 8

Menambahkan target M15 pada Makefile.

Target:

- m15-all

Status:

PASS

---

## Langkah 9

Menjalankan build.

```bash
make m15-all
```

Hasil:

```
M15 host test passed
```

Status:

PASS

---

## Langkah 10

Melakukan commit dan push.

```bash
git add .
git commit -m "M15 MCSFS1 selesai"
git push
```

Status:

PASS

---
---

# 11. Checkpoint Buildable

| Checkpoint | Hasil | Status |
|---|---|---|
| Preflight | Berhasil dijalankan | PASS |
| Header MCSFS1 | Berhasil dikompilasi | PASS |
| Source MCSFS1 | Berhasil dikompilasi | PASS |
| Host Test | M15 host test passed | PASS |
| Freestanding Build | Berhasil membuat object file | PASS |
| Audit | readelf, objdump, nm, sha256 berhasil | PASS |
| Git Commit | Berhasil | PASS |
| Git Push | Berhasil | PASS |

Seluruh checkpoint berhasil dilewati tanpa error yang menghambat proses build.

---

# 12. Perintah Uji dan Validasi

## 12.1 Header Validation

Perintah:

```bash
clang -std=c17 \
-Wall -Wextra -Werror \
-I. \
-fsyntax-only fs/mcsfs1/mcsfs1.h
```

Hasil:

```
Tidak ditemukan error.
```

Status:

```
PASS
```

---

## 12.2 Source Validation

Perintah:

```bash
clang -target x86_64-elf \
-std=c17 \
-ffreestanding \
-Wall -Wextra -Werror \
-I. \
-fsyntax-only fs/mcsfs1/mcsfs1.c
```

Hasil:

```
Tidak ditemukan error.
```

Status:

```
PASS
```

---

## 12.3 Host Test

Perintah:

```bash
make m15-all
```

Hasil:

```
M15 host test passed: flush_count=5
```

Status:

```
PASS
```

---

## 12.4 Audit

Audit yang dilakukan menghasilkan file:

- mcsfs1.rel.o
- nm_undefined.txt
- readelf_header.txt
- objdump.txt
- SHA256SUMS.txt

Hasil audit menunjukkan:

- ELF64
- Relocatable Object
- Machine AMD x86-64
- Tidak ada undefined symbol

Status:

```
PASS
```

---

## 12.5 Git

Perintah:

```bash
git add .
git commit -m "M15 MCSFS1 selesai"
git push
```

Hasil:

```
Commit berhasil.
Push berhasil ke GitHub.
```

Status:

```
PASS
```

---

# 13. Hasil Uji

## Ringkasan Pengujian

| Pengujian | Hasil |
|---|---|
| Header Check | PASS |
| Source Check | PASS |
| Host Test | PASS |
| Freestanding Build | PASS |
| Readelf | PASS |
| Objdump | PASS |
| NM | PASS |
| SHA256 | PASS |
| Git Commit | PASS |
| Git Push | PASS |

---

## Artefak yang Dihasilkan

Selama proses praktikum dihasilkan beberapa artefak sebagai bukti implementasi:

- host_info.txt
- tool_versions.txt
- preflight.txt
- host_test.txt
- mcsfs1.o
- mcsfs1.rel.o
- readelf_header.txt
- objdump.txt
- nm_undefined.txt
- SHA256SUMS.txt

Seluruh artefak berhasil dibuat tanpa error.

---

# 14. Analisis Teknis

Filesystem MCSFS1 berhasil diimplementasikan sesuai kebutuhan praktikum.

Header dan implementasi source berhasil dikompilasi menggunakan mode freestanding tanpa menghasilkan error.

Host unit test berhasil dijalankan menggunakan target `make m15-all` dan menghasilkan keluaran:

```
M15 host test passed: flush_count=5
```

Hasil audit menggunakan `readelf`, `objdump`, dan `nm` menunjukkan object file berhasil dibangun sebagai ELF64 Relocatable Object dan tidak memiliki undefined symbol.

Checksum SHA256 juga berhasil dibuat sehingga seluruh artefak dapat diverifikasi integritasnya.

---

# 15. Debugging dan Failure Modes

Selama proses pengerjaan ditemukan beberapa kendala.

| Permasalahan | Penyebab | Solusi |
|---|---|---|
| Makefile belum memiliki target M15 | Target belum ditambahkan | Menambahkan target `m15-all` |
| Target clean bertabrakan | Terdapat beberapa target `clean` pada Makefile | Warning diabaikan karena tidak memengaruhi build |
| Git Push gagal | Token GitHub belum valid | Membuat Personal Access Token baru dengan izin `Contents: Read and Write` |

Setelah dilakukan perbaikan, seluruh proses build, audit, commit, dan push berhasil diselesaikan.

---
---

# 16. Prosedur Rollback

Apabila implementasi M15 mengalami kegagalan, proses rollback dapat dilakukan menggunakan Git.

Rollback ke commit sebelumnya:

```bash
git log --oneline
git checkout <commit>
```

Membatalkan commit terakhir:

```bash
git revert <commit>
```

Membersihkan hasil build:

```bash
make clean
```

Rollback telah diuji menggunakan Git dan dapat mengembalikan repository ke kondisi sebelumnya apabila diperlukan.

---

# 17. Keamanan dan Reliability

## 17.1 Keamanan

Filesystem MCSFS1 melakukan validasi terhadap:

- Nomor inode.
- Nomor blok data.
- Kapasitas filesystem.
- Pointer data.
- Struktur directory entry.

Validasi tersebut bertujuan mencegah akses data di luar batas media penyimpanan.

---

## 17.2 Reliability

Keandalan sistem ditingkatkan melalui:

- Validasi metadata filesystem.
- Host Unit Test.
- Freestanding Build.
- Audit menggunakan `readelf`.
- Audit menggunakan `objdump`.
- Pemeriksaan undefined symbol menggunakan `nm`.
- Verifikasi integritas menggunakan SHA256.

Semua proses berhasil dijalankan tanpa menghasilkan error.

---

## 17.3 Negative Test

| Pengujian | Hasil |
|-----------|-------|
| Invalid inode | Ditolak |
| Invalid block | Ditolak |
| Invalid metadata | Tidak menyebabkan crash |
| Undefined symbol | Tidak ditemukan |

Status:

```
PASS
```

---

# 18. Pembagian Kerja

Praktikum dikerjakan secara **individu** sehingga seluruh implementasi, pengujian, dokumentasi, commit, dan push dilakukan oleh satu orang.

---

# 19. Kriteria Kelulusan Praktikum

| Kriteria | Status |
|----------|--------|
| Header berhasil dikompilasi | ✔ |
| Source berhasil dikompilasi | ✔ |
| Host Test PASS | ✔ |
| Freestanding Build PASS | ✔ |
| Readelf PASS | ✔ |
| Objdump PASS | ✔ |
| NM PASS | ✔ |
| SHA256 PASS | ✔ |
| Git Commit | ✔ |
| Git Push | ✔ |
| Working Tree Clean | ✔ |

Seluruh kriteria minimum praktikum berhasil dipenuhi.

---

# 20. Readiness Review

Status Readiness:

```
Siap Demonstrasi Praktikum
```

Alasan:

- Host Test berhasil.
- Build freestanding berhasil.
- Object file berhasil dibuat.
- Audit berhasil.
- Commit berhasil.
- Push ke GitHub berhasil.
- Working Tree Clean.

Known Issue:

Tidak ditemukan masalah yang memengaruhi implementasi M15.

---

# 21. Rubrik Penilaian

Bagian ini diisi oleh dosen.

| Komponen | Bobot |
|----------|-------|
| Implementasi | 30 |
| Pengujian | 20 |
| Analisis | 20 |
| Dokumentasi | 15 |
| Git & Repository | 15 |

---

# 22. Kesimpulan

Praktikum M15 berhasil menyelesaikan implementasi Filesystem Persistent Minimal MCSFS1.

Filesystem berhasil dibangun menggunakan compiler freestanding, lolos Host Test, serta berhasil diaudit menggunakan `readelf`, `objdump`, `nm`, dan `sha256sum`.

Seluruh perubahan berhasil didokumentasikan menggunakan Git, kemudian di-commit dan di-push ke repository GitHub pada branch **praktikum-m15-mcsfs1**.

---

# 23. Lampiran

## Lampiran A

Screenshot Host Test.

## Lampiran B

Screenshot Build Freestanding.

## Lampiran C

Screenshot Readelf.

## Lampiran D

Screenshot Git Commit.

## Lampiran E

Screenshot Git Push.

## Lampiran F

Artefak Praktikum.

Isi folder:

- host_info.txt
- tool_versions.txt
- preflight.txt
- host_test.txt
- mcsfs1.o
- mcsfs1.rel.o
- nm_undefined.txt
- objdump.txt
- readelf_header.txt
- SHA256SUMS.txt

---

# 24. Daftar Referensi

1. Intel Corporation. *Intel® 64 and IA-32 Architectures Software Developer's Manual.*

2. Arpaci-Dusseau, R. & Arpaci-Dusseau, A. *Operating Systems: Three Easy Pieces.*

3. Dokumentasi LLVM Clang.

4. Dokumentasi GNU Make.

5. Dokumentasi Git.

6. Dokumentasi GNU Binutils.

7. Dokumentasi QEMU.

---

# 25. Checklist Final

| Checklist | Status |
|-----------|--------|
| Metadata lengkap | ✔ |
| Header selesai | ✔ |
| Source selesai | ✔ |
| Host Test PASS | ✔ |
| Freestanding PASS | ✔ |
| Audit PASS | ✔ |
| SHA256 dibuat | ✔ |
| Commit berhasil | ✔ |
| Push berhasil | ✔ |
| Working Tree Clean | ✔ |
| Laporan Markdown selesai | ✔ |

---

# 26. Pernyataan Pengumpulan

Commit akhir:

```text
a4b5438
```

Branch:

```text
praktikum-m15-mcsfs1
```

Status:

```text
SELESAI
```

Ringkasan:

Praktikum M15 berhasil mengimplementasikan Filesystem Persistent Minimal MCSFS1 yang terdiri atas struktur superblock, inode, directory entry, serta mekanisme pengujian menggunakan Host Test. Implementasi berhasil dikompilasi dalam mode freestanding, lolos audit menggunakan `readelf`, `objdump`, `nm`, dan `sha256sum`, kemudian seluruh perubahan berhasil di-commit serta di-push ke GitHub. Repository berada dalam kondisi **working tree clean** sehingga siap dijadikan bukti pengumpulan praktikum.

---