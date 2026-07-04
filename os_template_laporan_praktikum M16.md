# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M16]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M16 |
| Judul praktikum | Crash Consistency, Write-Ahead Journal, Recovery, dan Fault-Injection Test untuk MCSFS1J pada MCSOS |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | 2026-06-30 |
| Tanggal pengumpulan | 2026-06-30 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m16-journal-recovery |
| Commit awal | *(diisi hash commit awal branch M16)* |
| Commit akhir | *(diisi hash commit terakhir)* |
| Status readiness yang diklaim | Siap uji QEMU |
# Laporan Praktikum M16

## Crash Consistency, Write-Ahead Journal, Recovery, dan Fault-Injection Test untuk MCSFS1J pada MCSOS

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1B | Individu |

Dosen Pengampu:

**Muhaemin Sidiq, S.Pd., M.Pd.**

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

2026
## 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan ini disusun berdasarkan hasil praktikum yang saya kerjakan sendiri. Bantuan berupa dokumentasi, referensi teknis, serta AI assistant digunakan sebagai pendukung untuk memahami materi dan membantu penyusunan dokumentasi. Seluruh hasil implementasi diverifikasi kembali melalui proses build, host test, audit, dan pengujian kernel sebelum dikumpulkan.

| Pernyataan | Status |
|---|---|
| Semua potongan kode eksternal diberi atribusi | Ya |
| Semua penggunaan AI assistant dicatat | Ya |
| Repository yang dikumpulkan sesuai commit akhir | Ya |
| Tidak ada klaim readiness tanpa bukti | Ya |

Catatan penggunaan bantuan eksternal:

- Dokumentasi praktikum M16
- GitHub repository MCSOS
- ChatGPT sebagai pendamping penjelasan dan dokumentasi
## 3. Tujuan Praktikum

1. Mengimplementasikan mekanisme Write-Ahead Journal pada MCSFS1J.
2. Mempelajari proses recovery setelah terjadi crash melalui journal replay.
3. Memastikan source journal dapat dikompilasi pada lingkungan freestanding x86_64.
4. Melakukan host unit test, audit object, dan build kernel sebagai bukti implementasi berhasil.
## 4. Capaian Pembelajaran Praktikum

| CPL/CPMK praktikum | Bukti |
|---|---|
| Memahami konsep journaling filesystem | Host test berhasil |
| Mampu membangun object freestanding | Freestanding build berhasil |
| Mampu melakukan audit object kernel | make audit berhasil |
## 5. Peta Milestone MCSOS

| Milestone | Fokus | Status |
|---|---|---|
| M16 | Crash Consistency, Journal Recovery, Fault Injection | ☑ Selesai praktikum |

### Batas cakupan praktikum

Praktikum M16 berfokus pada implementasi MCSFS1J Journal Recovery, host unit test, freestanding object, audit object, integrasi build kernel, serta pengumpulan evidence hasil pengujian. Implementasi penuh filesystem pada kernel tidak menjadi bagian dari cakupan praktikum ini.
## 6. Dasar Teori Ringkas

### 6.1 Konsep Sistem Operasi yang Diuji

Pada praktikum M16 dipelajari konsep crash consistency menggunakan mekanisme Write-Ahead Journaling (WAL). Setiap perubahan metadata maupun data dicatat terlebih dahulu ke journal sebelum ditulis ke filesystem utama. Apabila terjadi crash, sistem dapat melakukan proses recovery menggunakan journal sehingga kondisi filesystem tetap konsisten.

### 6.2 Konsep Arsitektur x86_64 yang Relevan

| Konsep | Relevansi pada praktikum | Bukti |
|---|---|---|
| ELF64 | Object journal dikompilasi menjadi format ELF64 | readelf_header.txt |
| Freestanding | Source dapat dikompilasi tanpa library standar | make freestanding |
| Object File | Modul journal dapat diintegrasikan ke kernel | m16_mcsfs_journal.o |

### 6.3 Konsep Implementasi Freestanding

| Aspek | Keputusan |
|---|---|
| Bahasa | C17 Freestanding |
| Runtime | Tanpa Hosted libc |
| ABI | x86_64-elf |
| Compiler | Clang |
| Compiler Flag | -ffreestanding, -Wall, -Wextra, -Werror |

### 6.4 Referensi

| No | Referensi | Bagian |
|---|---|---|
| 1 | Panduan Praktikum M16 | Implementasi Journal |
| 2 | Dokumentasi LLVM Clang | Freestanding Build |
| 3 | Dokumentasi GNU Make | Build System |
## 7. Lingkungan Praktikum

### 7.1 Host dan Target

| Komponen | Nilai |
|---|---|
| Host OS | Windows 11 |
| Build Environment | Ubuntu 24.04 LTS (WSL2) |
| Target ISA | x86_64 |
| Target ABI | x86_64-elf |
| Compiler | Clang |
| Build System | GNU Make |
| Emulator | QEMU x86_64 |

### 7.2 Versi Toolchain

Toolchain yang digunakan telah diverifikasi menggunakan script preflight praktikum M16 sehingga compiler, linker, make, dan QEMU tersedia pada lingkungan WSL.

### 7.3 Lokasi Repository

| Item | Nilai |
|---|---|
| Path Repository | ~/src/mcsos |
| File System Linux | Ya |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m16-journal-recovery |
## 8. Repository dan Struktur File

### 8.1 Struktur Direktori

```text
kernel/
└── fs/
    └── mcsfs1j/
        └── m16_mcsfs_journal.c

tests/
└── m16/
    └── Makefile

build/
└── m16/

evidence/
└── m16/

logs/
└── m16/
```

### 8.2 File yang Dibuat atau Diubah

| File | Jenis | Alasan |
|---|---|---|
| kernel/fs/mcsfs1j/m16_mcsfs_journal.c | Baru | Implementasi journal recovery |
| tests/m16/Makefile | Ubah | Host test dan freestanding build |
| build/m16 | Baru | Menyimpan object file |
| evidence/m16 | Baru | Menyimpan evidence audit |

### 8.3 Ringkasan Perubahan

Selama praktikum dilakukan penambahan modul journal recovery, konfigurasi Makefile untuk pengujian, serta penyimpanan evidence hasil audit dan build.
## 9. Desain Teknis

### 9.1 Masalah yang Diselesaikan

Filesystem memerlukan mekanisme recovery agar tetap konsisten apabila terjadi crash ketika proses penulisan data berlangsung.

### 9.2 Keputusan Desain

| Keputusan | Alasan |
|---|---|
| Menggunakan Write-Ahead Journal | Menjamin konsistensi data |
| Menggunakan Host Test | Mempermudah validasi algoritma |
| Menggunakan Freestanding Build | Memastikan source dapat masuk ke kernel |

### 9.3 Diagram Sederhana

```text
Write Request
      │
      ▼
Journal Record
      │
      ▼
Commit Journal
      │
      ▼
Filesystem
      │
      ▼
Recovery setelah Crash
```

### 9.4 Kontrak Antarmuka

Modul journal menyediakan proses pencatatan transaksi, commit, replay, dan recovery sebelum data ditulis ke filesystem utama.

### 9.5 Struktur Data

Struktur journal terdiri dari descriptor, payload, commit record, dan metadata journal.

### 9.6 Invariant

- Descriptor selalu ditulis sebelum commit.
- Commit hanya dilakukan setelah payload lengkap.
- Recovery dijalankan apabila ditemukan journal yang belum selesai.

### 9.7 Ownership

Seluruh buffer journal dikelola oleh modul filesystem.

### 9.8 Memory Safety

Implementasi memeriksa ukuran buffer dan validitas descriptor sebelum recovery dilakukan.

### 9.9 Security Boundary

Input journal divalidasi sebelum diproses agar descriptor yang rusak tidak menyebabkan kerusakan filesystem.
## 10. Langkah Kerja Implementasi

### Langkah 1 – Membuat Branch

```bash
git checkout -b praktikum-m16-journal-recovery
```

### Langkah 2 – Menyiapkan Folder

```bash
mkdir -p kernel/fs/mcsfs1j tests/m16 build/m16 evidence/m16 logs/m16
```

### Langkah 3 – Menjalankan Preflight

```bash
chmod +x scripts/m16_preflight.sh
./scripts/m16_preflight.sh
```

### Langkah 4 – Implementasi Journal

Membuat file:

```text
kernel/fs/mcsfs1j/m16_mcsfs_journal.c
```

### Langkah 5 – Konfigurasi Makefile

Menyesuaikan `tests/m16/Makefile` agar host test dan freestanding build dapat dijalankan.

### Langkah 6 – Host Test

```bash
make clean
make host
```

Hasil:

```text
M16 host tests PASS
```

### Langkah 7 – Freestanding Build

```bash
make freestanding
```

### Langkah 8 – Audit

```bash
make audit
```

### Langkah 9 – Menyimpan Evidence

```bash
cp m16_mcsfs_journal.o ../../build/m16/

cp nm_undefined.txt \
readelf_header.txt \
objdump_disasm.txt \
sha256sum.txt \
../../evidence/m16/
```

### Langkah 10 – Build Kernel

```bash
make clean all
make inspect
make audit
```

### Langkah 11 – Push ke GitHub

```bash
git add .
git commit -m "M16: journal recovery implementation"
git push -u origin praktikum-m16-journal-recovery
```
## 10. Langkah Kerja Implementasi

### Langkah 1 – Membuat Branch

```bash
git checkout -b praktikum-m16-journal-recovery
```

### Langkah 2 – Menyiapkan Folder

```bash
mkdir -p kernel/fs/mcsfs1j tests/m16 build/m16 evidence/m16 logs/m16
```

### Langkah 3 – Menjalankan Preflight

```bash
chmod +x scripts/m16_preflight.sh
./scripts/m16_preflight.sh
```

### Langkah 4 – Implementasi Journal

Membuat file:

```text
kernel/fs/mcsfs1j/m16_mcsfs_journal.c
```

### Langkah 5 – Konfigurasi Makefile

Menyesuaikan `tests/m16/Makefile` agar host test dan freestanding build dapat dijalankan.

### Langkah 6 – Host Test

```bash
make clean
make host
```

Hasil:

```text
M16 host tests PASS
```

### Langkah 7 – Freestanding Build

```bash
make freestanding
```

### Langkah 8 – Audit

```bash
make audit
```

### Langkah 9 – Menyimpan Evidence

```bash
cp m16_mcsfs_journal.o ../../build/m16/

cp nm_undefined.txt \
readelf_header.txt \
objdump_disasm.txt \
sha256sum.txt \
../../evidence/m16/
```

### Langkah 10 – Build Kernel

```bash
make clean all
make inspect
make audit
```

### Langkah 11 – Push ke GitHub

```bash
git add .
git commit -m "M16: journal recovery implementation"
git push -u origin praktikum-m16-journal-recovery
```
## 11. Checkpoint Buildable

| Checkpoint | Perintah | Expected Result | Status |
|---|---|---|---|
| Clean Build | `make clean all` | Kernel berhasil dibangun | PASS |
| Inspect | `make inspect` | Symbol dan ELF tervalidasi | PASS |
| Audit | `make audit` | Tidak ada undefined symbol | PASS |
| Host Test | `make host` | M16 host tests PASS | PASS |
| Freestanding Build | `make freestanding` | Object file berhasil dibuat | PASS |

Catatan:

Seluruh checkpoint berhasil dijalankan setelah penyesuaian konfigurasi Makefile dan proses linking kernel selesai diperbaiki.

---

## 12. Perintah Uji dan Validasi

### 12.1 Host Test

```bash
make clean
make host
```

Hasil

```text
M16 host tests PASS
```

Status

PASS

---

### 12.2 Freestanding Build

```bash
make freestanding
```

Hasil

```text
m16_mcsfs_journal.o berhasil dibuat.
```

Status

PASS

---

### 12.3 Audit

```bash
make audit
```

Hasil

```text
nm_undefined.txt kosong
readelf_header.txt berhasil dibuat
objdump_disasm.txt berhasil dibuat
sha256sum.txt berhasil dibuat
```

Status

PASS

---

### 12.4 Kernel Build

```bash
make clean all
```

Status

PASS

---

### 12.5 Inspect

```bash
make inspect
```

Status

PASS

---

### 12.6 Git

```bash
git push -u origin praktikum-m16-journal-recovery
```

Status

PASS

---

## 13. Hasil Uji

### 13.1 Ringkasan

| Pengujian | Hasil |
|---|---|
| Preflight | PASS |
| Host Test | PASS |
| Freestanding Build | PASS |
| Audit | PASS |
| Build Kernel | PASS |
| Inspect | PASS |
| Git Push | PASS |

---

### 13.2 Log Penting

Host test berhasil dijalankan dengan hasil:

```text
M16 host tests PASS
```

Kernel berhasil dibangun kembali menggunakan target M16 tanpa ditemukan undefined symbol.

---

### 13.3 Artefak

| Artefak | Lokasi |
|---|---|
| m16_mcsfs_journal.o | build/m16 |
| nm_undefined.txt | evidence/m16 |
| readelf_header.txt | evidence/m16 |
| objdump_disasm.txt | evidence/m16 |
| sha256sum.txt | evidence/m16 |
| build_kernel.log | logs/m16 |

---

## 14. Analisis Teknis

Implementasi journal recovery berhasil dikompilasi pada mode host maupun freestanding. Seluruh proses audit menunjukkan bahwa object tidak memiliki undefined symbol sehingga dapat digunakan sebagai bagian dari kernel. Setelah dilakukan penyesuaian konfigurasi Makefile, proses build kernel, inspect, dan audit berhasil diselesaikan. Hal ini menunjukkan bahwa modul journal recovery telah terintegrasi dengan baik ke dalam lingkungan pengembangan MCSOS.

---

## 15. Debugging dan Failure Modes

Selama proses implementasi ditemukan beberapa kendala.

| Kendala | Penyebab | Solusi |
|---|---|---|
| Host test gagal | Path source pada Makefile belum sesuai | Mengubah path menuju m16_mcsfs_journal.c |
| Build kernel gagal | Include path belum lengkap | Menambahkan -Iinclude pada Makefile |
| Inspect gagal | Konflik variabel OBJ pada Makefile | Mengubah variabel M14 agar tidak menimpa variabel kernel |

Seluruh permasalahan berhasil diperbaiki sehingga proses build dan audit dapat dijalankan kembali.

---

## 16. Prosedur Rollback

Apabila implementasi M16 mengalami kegagalan maka rollback dapat dilakukan menggunakan Git.

```bash
git checkout main
```

atau

```bash
git checkout <commit_hash>
```

Membersihkan hasil build.

```bash
make clean
```

Selanjutnya membangun ulang kernel.

```bash
make clean all
```

Rollback dapat dilakukan tanpa memengaruhi branch praktikum M16 karena seluruh perubahan berada pada branch:

```text
praktikum-m16-journal-recovery
```
## 17. Keamanan dan Reliability

### 17.1 Risiko Keamanan

| Risiko | Boundary | Dampak | Mitigasi | Evidence |
|---|---|---|---|---|
| Journal rusak | Filesystem | Recovery gagal | Validasi journal header | Host test |
| Data tidak lengkap | Journal | Inkonsistensi data | Commit record | Audit |
| Write gagal | Storage | Kehilangan data | Recovery journal | Build dan Audit |

### 17.2 Reliability

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Crash saat write | Data tidak konsisten | Write-Ahead Journal |
| Object tidak valid | Kernel gagal build | Freestanding Build |
| Undefined Symbol | Link gagal | Audit Object |

### 17.3 Negative Test

| Pengujian | Hasil |
|---|---|
| Host Test | PASS |
| Audit | PASS |
| Freestanding Build | PASS |

---

## 18. Pembagian Kerja Kelompok

Praktikum dikerjakan secara individu sehingga bagian ini tidak berlaku.

| Nama | NIM | Peran | Kontribusi |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | Individu | Seluruh implementasi dan dokumentasi |

---

## 19. Kriteria Lulus Praktikum

| Kriteria | Status | Evidence |
|---|---|---|
| Build berhasil | PASS | make clean all |
| Host Test | PASS | M16 host tests PASS |
| Freestanding Build | PASS | m16_mcsfs_journal.o |
| Audit | PASS | make audit |
| Inspect | PASS | make inspect |
| Git Commit | PASS | Git log |
| Git Push | PASS | GitHub Repository |

---

## 20. Readiness Review

| Status | Pilihan |
|---|---|
| Belum siap uji | |
| **Siap uji QEMU** | ☑ |
| Siap demonstrasi praktikum | |
| Kandidat siap pakai terbatas | |

### Alasan

Seluruh tahapan implementasi berhasil dijalankan mulai dari host test, freestanding build, audit, build kernel, inspect, hingga push repository. Evidence hasil pengujian berhasil dikumpulkan sehingga implementasi dinyatakan siap untuk dilakukan pengujian pada lingkungan QEMU.

### Known Issues

Belum ditemukan kendala yang menghambat proses build setelah konfigurasi Makefile diperbaiki.

---

## 21. Rubrik Penilaian

| Komponen | Bobot |
|---|---:|
| Kebenaran Fungsional | 30 |
| Desain | 20 |
| Pengujian | 20 |
| Analisis | 10 |
| Keamanan | 10 |
| Dokumentasi | 10 |
| **Total** | **100** |

Bagian nilai diisi oleh dosen pengampu.

---

## 22. Kesimpulan

### 22.1 Yang Berhasil

Implementasi Journal Recovery berhasil dikembangkan pada MCSFS1J. Seluruh proses host test, freestanding build, audit object, build kernel, inspect, dan push repository berhasil dilakukan.

### 22.2 Yang Belum Berhasil

Pengujian crash menggunakan fault injection penuh pada lingkungan QEMU belum dilakukan pada praktikum ini.

### 22.3 Rencana Perbaikan

Pengembangan berikutnya adalah mengintegrasikan journal recovery secara penuh dengan filesystem MCSFS1 sehingga recovery dapat dijalankan langsung ketika sistem melakukan boot setelah terjadi crash.

---

## 23. Lampiran

### Lampiran A – Commit Log

```bash
git log --oneline -5
```

---

### Lampiran B – Diff

```bash
git diff --stat
```

---

### Lampiran C – Build Log

```
logs/m16/build_kernel.log
```

---

### Lampiran D – Evidence

```
evidence/m16/
```

Berisi:

- nm_undefined.txt
- readelf_header.txt
- objdump_disasm.txt
- sha256sum.txt

---

### Lampiran E – Object

```
build/m16/m16_mcsfs_journal.o
```

---

### Lampiran F – Screenshot

Masukkan screenshot berikut.

1. Preflight
2. Host Test PASS
3. Freestanding Build
4. Audit
5. Build Kernel
6. Inspect
7. Git Push

---

## 24. Daftar Referensi

[1] Muhaemin Sidiq, Modul Praktikum MCSOS 260502 M16.

[2] Intel Corporation, Intel® 64 and IA-32 Architectures Software Developer's Manual.

[3] LLVM Project Documentation.

[4] GNU Make Manual.

[5] Operating Systems: Three Easy Pieces.

---

## 25. Checklist Final Sebelum Pengumpulan

| Checklist | Status |
|---|---|
| Metadata lengkap | Ya |
| Build berhasil | Ya |
| Host Test berhasil | Ya |
| Freestanding Build berhasil | Ya |
| Audit berhasil | Ya |
| Build Kernel berhasil | Ya |
| Git Commit | Ya |
| Git Push | Ya |
| Evidence lengkap | Ya |
| Laporan Markdown | Ya |

---

## 26. Pernyataan Pengumpulan

Saya menyatakan bahwa seluruh hasil praktikum M16 telah diselesaikan sesuai prosedur praktikum, didukung oleh evidence hasil build, host test, audit, dan repository GitHub pada branch:

```
praktikum-m16-journal-recovery
```

Status akhir:

```
Siap uji QEMU
```

Ringkasan:

Implementasi M16 berhasil diselesaikan mulai dari pembangunan modul journal recovery, pengujian host, kompilasi freestanding, audit object, integrasi kernel, hingga penyimpanan evidence dan pengunggahan ke GitHub. Seluruh tahapan utama berhasil dilaksanakan sesuai target praktikum.