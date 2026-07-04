# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M14]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

# Laporan Praktikum MCSOS

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode Praktikum | M14 |
| Judul Praktikum | Block Device Layer |
| Jenis Pengerjaan | Individu |
| Nama Mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Tanggal Praktikum | 2026 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m14-block-device |
| Commit Awal | a6b0219 |
| Commit Akhir | b63e840 |
| Status Readiness | Siap Demonstrasi Praktikum |

---

# 1. Sampul

# Laporan Praktikum M14

## Block Device Layer

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1B | Individu |

Dosen Pengampu:

**Muhaemin Sidiq, S.Pd., M.Pd.**

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

2026

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa seluruh pekerjaan pada Praktikum M14 dikerjakan secara mandiri. Seluruh implementasi dilakukan pada repository Git pribadi menggunakan branch `praktikum-m14-block-device`.

Bantuan dokumentasi, referensi resmi, serta AI digunakan sebagai pendamping pembelajaran dan seluruh hasil diverifikasi kembali melalui proses build, host test, audit, commit, dan push ke repository GitHub.

| Pernyataan | Status |
|---|---|
| Semua implementasi telah diuji | Ya |
| Semua artefak tersedia | Ya |
| Repository sesuai commit akhir | Ya |
| Tidak ada klaim tanpa bukti | Ya |

---

# 3. Tujuan Praktikum

Tujuan Praktikum M14 adalah:

1. Membuat antarmuka Block Device pada kernel MCSOS.
2. Mengimplementasikan RAM Block Device.
3. Mengimplementasikan Block Cache.
4. Melakukan pengujian Host Test.
5. Melakukan Freestanding Build.
6. Melakukan Audit Object File.
7. Menyimpan artefak hasil pengujian.
8. Melakukan commit dan push ke GitHub.

---

# 4. Capaian Pembelajaran Praktikum

Setelah praktikum selesai mahasiswa mampu:

| Capaian | Bukti |
|---|---|
| Membuat Block Device Layer | block.h |
| Membuat Driver RAM Block | ramblk.c |
| Membuat Block Cache | bcache.c |
| Melakukan Host Test | PASS |
| Melakukan Freestanding Build | PASS |
| Melakukan Audit | PASS |
| Menggunakan Git Branch | praktikum-m14-block-device |
| Push Repository ke GitHub | Berhasil |

---

# 5. Peta Milestone MCSOS

| Milestone | Status |
|---|---|
| M0 | ✔ |
| M1 | ✔ |
| M2 | ✔ |
| M3 | ✔ |
| M4 | ✔ |
| M5 | ✔ |
| M6 | ✔ |
| M7 | ✔ |
| M8 | ✔ |
| M9 | ✔ |
| M10 | ✔ |
| M11 | ✔ |
| M12 | ✔ |
| M13 | ✔ |
| **M14** | ✔ |
| M15 | Belum |
| M16 | Belum |
---

# 6. Dasar Teori

## 6.1 Konsep Block Device

Block Device merupakan perangkat penyimpanan yang mengelola data dalam satuan blok dengan ukuran tetap. Sistem operasi melakukan operasi baca dan tulis melalui nomor blok sehingga akses data lebih terstruktur dan efisien.

## 6.2 RAM Block Device

RAM Block Device adalah implementasi block device yang menggunakan memori utama sebagai media penyimpanan sementara. Implementasi ini digunakan sebagai media pengujian karena memiliki kecepatan akses tinggi dan tidak memerlukan perangkat keras tambahan.

## 6.3 Block Cache

Block Cache digunakan untuk menyimpan blok data yang sering diakses agar proses pembacaan berikutnya tidak selalu mengambil data langsung dari media penyimpanan. Mekanisme ini meningkatkan performa sistem dan mengurangi jumlah operasi I/O.

## 6.4 Host Test

Host Test merupakan pengujian yang dijalankan pada sistem host menggunakan compiler standar. Pengujian ini memastikan implementasi Block Device berjalan sesuai fungsi sebelum dikompilasi sebagai bagian dari kernel freestanding.

---

# 7. Lingkungan Praktikum

## 7.1 Host

| Komponen | Nilai |
|---|---|
| Host OS | Windows 11 |
| Build Environment | Ubuntu WSL2 |
| Target | x86_64 |
| Emulator | QEMU |
| Bahasa | C17 |

## 7.2 Toolchain

| Tools | Keterangan |
|---|---|
| clang | Compiler |
| ld | Linker |
| nm | Symbol Inspector |
| readelf | ELF Inspector |
| objdump | Disassembler |
| sha256sum | Hash Generator |
| make | Build System |
| git | Version Control |

## 7.3 Repository

| Item | Nilai |
|---|---|
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m14-block-device |
| Commit Awal | a6b0219 |
| Commit Akhir | b63e840 |

---

# 8. Repository dan Struktur File

## 8.1 Struktur Folder

```text
include/
└── mcsos/
    └── block.h

kernel/
└── block/
    ├── block.c
    ├── ramblk.c
    └── bcache.c

tests/
└── host/
    └── test_m14_block.c

scripts/
└── m14_preflight.sh

artifacts/
└── m14/
```

## 8.2 File yang Dibuat

| File | Keterangan |
|---|---|
| include/mcsos/block.h | Header Block Device |
| kernel/block/block.c | Implementasi Block Layer |
| kernel/block/ramblk.c | Driver RAM Block |
| kernel/block/bcache.c | Block Cache |
| tests/host/test_m14_block.c | Host Test |
| scripts/m14_preflight.sh | Preflight Script |

## 8.3 Git Diff

Seluruh perubahan berhasil dicatat menggunakan Git dan disimpan pada branch:

```text
praktikum-m14-block-device
```

Seluruh perubahan berhasil di-commit dan di-push ke GitHub.

---

# 9. Desain Teknis

## 9.1 Masalah

Kernel MCSOS belum memiliki Block Device Layer sehingga belum tersedia mekanisme standar untuk melakukan operasi baca dan tulis terhadap media penyimpanan.

## 9.2 Solusi

Solusi yang diterapkan adalah membangun Block Device Layer yang terdiri atas:

- Block Interface
- RAM Block Device
- Block Cache
- Host Test

## 9.3 Diagram

```text
          User
            │
            ▼
     Block Interface
            │
      ┌─────┴─────┐
      ▼           ▼
 RAM Block    Block Cache
      │
      ▼
 Memory Storage
```

## 9.4 Struktur Data

Struktur data utama terdiri atas:

- Block Device
- Block Cache
- Block Buffer

## 9.5 Memory Safety

Implementasi menggunakan validasi ukuran blok, pemeriksaan indeks, serta pengelolaan memori secara terstruktur sehingga mengurangi risiko akses di luar batas.

---

# 10. Langkah Kerja Implementasi

## Langkah 1

Membuat branch baru.

```bash
git switch -c praktikum-m14-block-device
```

---

## Langkah 2

Membuat struktur folder.

```bash
mkdir -p include/mcsos kernel/block tests/host scripts artifacts/m14
```

---

## Langkah 3

Membuat file:

- block.h
- block.c
- ramblk.c
- bcache.c
- test_m14_block.c

Kemudian dilakukan pemeriksaan sintaks menggunakan clang.

---

## Langkah 4

Menambahkan target Build pada Makefile kemudian menjalankan:

```bash
make m14-host-test
make m14-freestanding
make m14-audit
```

Seluruh proses berhasil dijalankan.

---

## Langkah 5

Melakukan commit dan push ke GitHub.

```bash
git add .
git commit -m "M14 Block Device selesai"
git push -u origin praktikum-m14-block-device
```

Branch berhasil tersimpan pada repository GitHub.
---

# 11. Checkpoint Buildable

| Checkpoint | Hasil | Status |
|---|---|---|
| Preflight | Berhasil | PASS |
| Host Test | M14 host tests PASS | PASS |
| Freestanding Build | Object file berhasil dibuat | PASS |
| Audit | Tidak ada undefined symbol | PASS |
| Git Commit | Berhasil | PASS |
| Git Push | Berhasil | PASS |

Seluruh checkpoint berhasil dilewati tanpa kesalahan yang menghambat proses build.

---

# 12. Perintah Uji dan Validasi

## 12.1 Host Test

Perintah:

```bash
make m14-host-test
```

Hasil:

```text
M14 host tests PASS
```

Status:

```text
PASS
```

---

## 12.2 Freestanding Build

Perintah:

```bash
make m14-freestanding
```

Hasil:

```text
Freestanding object berhasil dikompilasi.
```

Status:

```text
PASS
```

---

## 12.3 Audit

Perintah:

```bash
make m14-audit
```

Hasil:

- readelf berhasil dibuat
- objdump berhasil dibuat
- nm tidak menemukan undefined symbol
- sha256 berhasil dibuat

Status:

```text
PASS
```

---

## 12.4 Git

Perintah:

```bash
git status
git add .
git commit -m "M14 Block Device selesai"
git push
```

Status:

```text
PASS
```

---

# 13. Hasil Uji

| Pengujian | Hasil |
|---|---|
| Host Test | PASS |
| Freestanding Build | PASS |
| Audit | PASS |
| Git Commit | PASS |
| Git Push | PASS |

Artefak yang dihasilkan:

- m14_nm_undefined.txt
- m14_readelf_block.txt
- m14_objdump_block.txt
- m14_sha256.txt
- preflight.log
- git_status_before_m14.txt

Semua artefak berhasil dibuat selama proses praktikum.

---

# 14. Analisis Teknis

Implementasi Block Device berhasil memenuhi tujuan praktikum.

Layer Block Device mampu menyediakan antarmuka untuk operasi baca dan tulis menggunakan media penyimpanan berbasis RAM. Implementasi Block Cache membantu mengurangi akses langsung ke media penyimpanan sehingga meningkatkan efisiensi.

Seluruh modul berhasil dikompilasi menggunakan mode freestanding dan lolos pengujian host tanpa error.

Audit menggunakan `readelf`, `objdump`, `nm`, dan `sha256sum` menunjukkan bahwa object file berhasil dibangun dengan benar dan tidak memiliki undefined symbol.

---

# 15. Debugging dan Failure Modes

Selama proses pengerjaan ditemukan beberapa kendala, antara lain:

| Permasalahan | Penyebab | Solusi |
|---|---|---|
| Header tidak ditemukan | Path include belum sesuai | Menambahkan `-Iinclude` |
| Target Makefile belum tersedia | Rule Makefile belum dibuat | Menambahkan target `m14-host-test`, `m14-freestanding`, dan `m14-audit` |
| Git Push gagal | Token GitHub belum memiliki izin Write | Membuat Fine-grained Personal Access Token dengan izin `Contents: Read and Write` |

Setelah dilakukan perbaikan, seluruh proses build, audit, commit, dan push berhasil diselesaikan.
---

# 16. Prosedur Rollback

Apabila implementasi M14 mengalami kegagalan, proses rollback dapat dilakukan menggunakan Git.

Rollback ke commit sebelumnya:

```bash
git log --oneline
git checkout <commit>
```

Rollback commit terakhir:

```bash
git revert <commit>
```

Membersihkan hasil build:

```bash
make clean
```

Status:

```text
Rollback berhasil dilakukan menggunakan Git apabila diperlukan.
```

---

# 17. Keamanan dan Reliability

## 17.1 Keamanan

Implementasi Block Device melakukan validasi terhadap:

- Nomor blok.
- Ukuran blok.
- Pointer data.
- Kapasitas RAM Block.

Validasi tersebut bertujuan mencegah akses memori di luar batas.

## 17.2 Reliability

Untuk meningkatkan keandalan sistem dilakukan:

- Block Cache.
- Validasi parameter.
- Host Test.
- Freestanding Build.
- Audit Object File.

Semua pengujian berhasil diselesaikan tanpa error.

---

# 18. Pembagian Kerja Kelompok

Praktikum dikerjakan secara **individu**.

---

# 19. Kriteria Lulus Praktikum

| Kriteria | Status |
|---|---|
| Host Test PASS | ✔ |
| Freestanding Build PASS | ✔ |
| Audit PASS | ✔ |
| Git Commit | ✔ |
| Git Push | ✔ |
| Working Tree Clean | ✔ |

Seluruh kriteria kelulusan berhasil dipenuhi.

---

# 20. Readiness Review

Status Readiness:

```text
Siap Demonstrasi Praktikum
```

Alasan:

- Host Test berhasil.
- Freestanding Build berhasil.
- Audit berhasil.
- Commit berhasil.
- Push ke GitHub berhasil.
- Repository dalam kondisi bersih (Working Tree Clean).

---

# 21. Rubrik Penilaian

Bagian ini diisi oleh dosen.

---

# 22. Kesimpulan

Praktikum M14 berhasil diselesaikan dengan membangun Block Device Layer yang terdiri dari Block Interface, RAM Block Device, dan Block Cache.

Seluruh implementasi berhasil dikompilasi menggunakan mode freestanding, lolos Host Test, serta lolos Audit.

Seluruh perubahan berhasil dicatat menggunakan Git, di-commit, kemudian di-push ke repository GitHub.

---

# 23. Lampiran

## Lampiran A

Screenshot Host Test

## Lampiran B

Screenshot Freestanding Build

## Lampiran C

Screenshot Audit

## Lampiran D

Screenshot Git Commit

## Lampiran E

Screenshot Git Push

## Lampiran F

Artefak Audit

- m14_nm_undefined.txt
- m14_readelf_block.txt
- m14_objdump_block.txt
- m14_sha256.txt
- preflight.log
- git_status_before_m14.txt

---

# 24. Daftar Referensi

1. Intel Corporation. *Intel 64 and IA-32 Architectures Software Developer's Manual.*

2. Operating Systems: Three Easy Pieces.

3. Dokumentasi LLVM Clang.

4. Dokumentasi GNU Make.

5. Dokumentasi Git.

6. Dokumentasi QEMU.

---

# 25. Checklist Final

| Checklist | Status |
|---|---|
| Header selesai | ✔ |
| Block Layer selesai | ✔ |
| RAM Block selesai | ✔ |
| Block Cache selesai | ✔ |
| Host Test PASS | ✔ |
| Freestanding PASS | ✔ |
| Audit PASS | ✔ |
| Git Commit | ✔ |
| Git Push | ✔ |
| Working Tree Clean | ✔ |
| Laporan Markdown selesai | ✔ |

---

# 26. Pernyataan Pengumpulan

Commit Akhir:

```text
b63e840
```

Status:

```text
SELESAI
```

Ringkasan:

Praktikum M14 Block Device berhasil diselesaikan dengan mengimplementasikan Block Device Layer, RAM Block Device, dan Block Cache. Seluruh pengujian Host Test, Freestanding Build, serta Audit berhasil dilaksanakan. Seluruh perubahan telah di-commit dan di-push ke repository GitHub menggunakan branch `praktikum-m14-block-device`. Repository berada pada kondisi **working tree clean** sehingga siap digunakan sebagai bukti pengumpulan.