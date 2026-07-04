# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_M9_2583207073008.md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

# 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M9 |
| Judul praktikum | Kernel Thread, Runqueue Round-Robin Kooperatif, Context Switch x86_64, dan Integrasi Scheduler Awal pada MCSOS |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B PTI |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | (Isi tanggal praktikum) |
| Tanggal pengumpulan | (Isi tanggal pengumpulan) |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum-m9-scheduler |
| Commit awal | Branch `praktikum-m9-scheduler` |
| Commit akhir | `62931ef` |
| Status readiness yang diklaim | Siap demonstrasi praktikum |

---

# 1. Sampul

# Laporan Praktikum M9

## Kernel Thread, Runqueue Round-Robin Kooperatif, Context Switch x86_64, dan Integrasi Scheduler Awal pada MCSOS

Disusun oleh

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | (Isi NIM) | 1B PTI | Individu |

**Dosen Pengampu**

Muhaemin Sidiq, S.Pd., M.Pd.

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan praktikum ini disusun berdasarkan hasil pengerjaan praktikum secara mandiri. Seluruh proses implementasi, pengujian, serta dokumentasi dilakukan pada repository Git menggunakan branch khusus praktikum M9. Bantuan berupa dokumentasi resmi dan AI digunakan sebagai pendamping belajar, sedangkan seluruh hasil telah diverifikasi kembali melalui proses build, audit, dan pengujian secara langsung.

| Pernyataan | Status |
|---|---|
| Semua potongan kode eksternal diberi atribusi | Ya |
| Semua penggunaan AI Assistant dicatat | Ya |
| Repository sesuai commit akhir | Ya |
| Tidak ada klaim tanpa bukti | Ya |

### Catatan penggunaan bantuan eksternal

- AI digunakan untuk membantu memahami langkah praktikum dan penyusunan laporan.
- Dokumentasi Clang, GNU Make, Git, dan referensi x86_64 digunakan sebagai acuan implementasi.
- Seluruh hasil diverifikasi kembali menggunakan proses build, host test, audit, dan Git commit.

---

# 3. Tujuan Praktikum

Praktikum M9 bertujuan mengimplementasikan mekanisme scheduler sederhana pada kernel MCSOS menggunakan pendekatan cooperative round-robin. Selain itu, praktikum ini juga bertujuan mengimplementasikan mekanisme context switch berbasis assembly x86_64 sehingga kernel mampu melakukan perpindahan antar thread secara terstruktur.

Tujuan yang ingin dicapai adalah:

1. Mengimplementasikan struktur kernel thread pada sistem operasi MCSOS.
2. Mengembangkan scheduler cooperative round-robin sederhana.
3. Mengimplementasikan context switch menggunakan assembly x86_64.
4. Melakukan host unit test untuk memastikan scheduler berjalan dengan benar.
5. Melakukan audit menggunakan `readelf`, `nm`, `objdump`, dan `sha256sum`.
6. Menyimpan seluruh perubahan ke repository Git menggunakan branch khusus praktikum M9.

---

# 4. Capaian Pembelajaran Praktikum

Setelah menyelesaikan praktikum ini, mahasiswa mampu:

| CPL/CPMK Praktikum | Bukti |
|---|---|
| Mengimplementasikan kernel thread | File `kernel/mcsos_thread.c` |
| Mengimplementasikan context switch x86_64 | File `kernel/arch/x86_64/context_switch.S` |
| Menjalankan host unit test scheduler | Output `M9 scheduler host unit test PASS` |
| Melakukan audit object file | Output `readelf`, `nm`, `objdump`, dan `sha256sum` |
| Mengelola perubahan menggunakan Git | Commit `62931ef` dan branch `praktikum-m9-scheduler` |

# 5. Peta Milestone MCSOS

| Milestone | Fokus | Status dalam laporan |
|---|---|---|
| M0 | Requirements, governance, baseline arsitektur | Tidak dibahas |
| M1 | Toolchain reproducible, Git, QEMU, metadata build | Tidak dibahas |
| M2 | Boot image, kernel ELF64, early console | Tidak dibahas |
| M3 | Panic path, linker map, GDB | Tidak dibahas |
| M4 | Trap, exception, interrupt, timer | Tidak dibahas |
| M5 | PMM, VMM, page table, kernel heap | Tidak dibahas |
| M6 | Thread, scheduler, synchronization | Tidak dibahas |
| M7 | Syscall ABI dan user program loader | Tidak dibahas |
| M8 | Kernel Heap Memory Manager | Tidak dibahas |
| **M9** | **Kernel Thread, Scheduler, Context Switch** | **Selesai Praktikum** |
| M10 | Persistent Filesystem | Tidak dibahas |
| M11 | Networking Stack | Tidak dibahas |
| M12 | Security Model | Tidak dibahas |
| M13 | SMP | Tidak dibahas |
| M14 | Framebuffer | Tidak dibahas |
| M15 | Virtualization | Tidak dibahas |
| M16 | Observability dan Release | Tidak dibahas |

### Batas Cakupan Praktikum

Praktikum M9 hanya berfokus pada implementasi kernel thread, scheduler cooperative round-robin, context switch menggunakan assembly x86_64, host unit test, freestanding build, serta proses audit terhadap object file. Praktikum ini belum mencakup implementasi multitasking penuh, preemptive scheduler, maupun sinkronisasi lanjutan.

---

# 6. Dasar Teori Ringkas

## 6.1 Konsep Sistem Operasi yang Diuji

Kernel scheduler merupakan komponen sistem operasi yang bertugas menentukan thread mana yang akan memperoleh giliran menggunakan CPU. Pada praktikum ini digunakan scheduler cooperative round-robin sehingga perpindahan thread dilakukan secara teratur berdasarkan antrean (runqueue). Selain scheduler, diterapkan pula context switch untuk menyimpan dan memulihkan register CPU ketika terjadi perpindahan thread.

## 6.2 Konsep Arsitektur x86_64 yang Relevan

| Konsep | Relevansi | Bukti |
|---|---|---|
| Context Switch | Menyimpan dan memulihkan register CPU | `context_switch.S` |
| x86_64 Assembly | Digunakan untuk implementasi perpindahan context | Objdump berhasil |
| ELF Relocatable Object | Digunakan sebagai hasil build freestanding | `readelf` berhasil |
| Freestanding Kernel | Kernel dibangun tanpa library sistem operasi | Build berhasil |

## 6.3 Konsep Implementasi Freestanding

| Aspek | Implementasi |
|---|---|
| Bahasa | C17 Freestanding |
| Assembly | GAS x86_64 |
| ABI | x86_64 System V |
| Compiler | Clang |
| Build System | GNU Make |

## 6.4 Referensi

1. Intel® 64 and IA-32 Architectures Software Developer's Manual.
2. Operating Systems: Three Easy Pieces.
3. Dokumentasi LLVM Clang.
4. Dokumentasi GNU Make.

---

# 7. Lingkungan Praktikum

## 7.1 Host dan Target

| Komponen | Nilai |
|---|---|
| Host OS | Windows 11 x64 |
| Build Environment | WSL2 Ubuntu |
| Target ISA | x86_64 |
| Compiler | Clang |
| Linker | LLD |
| Emulator | QEMU |
| Build System | GNU Make |
| Bahasa | C17 Freestanding |
| Assembly | GAS x86_64 |

## 7.2 Lokasi Repository

| Item | Nilai |
|---|---|
| Repository | `~/src/mcsos` |
| Remote Repository | `https://github.com/sumyatisiti45-dot/MCSOS260502` |
| Branch | `praktikum-m9-scheduler` |
| Commit Akhir | `62931ef` |

---

# 8. Repository dan Struktur File

## 8.1 Struktur Direktori

```text
mcsos/
├── include/
│   └── mcsos_thread.h
├── kernel/
│   ├── mcsos_thread.c
│   └── arch/
│       └── x86_64/
│           └── context_switch.S
├── tests/
│   └── test_scheduler_host.c
├── build/
│   └── m9/
└── Makefile
```

## 8.2 File yang Dibuat atau Diubah

| File | Perubahan | Alasan |
|---|---|---|
| Makefile | Diubah | Menambahkan target M9 |
| include/mcsos_thread.h | Baru | Deklarasi scheduler |
| kernel/mcsos_thread.c | Baru | Implementasi scheduler |
| kernel/arch/x86_64/context_switch.S | Baru | Context switch assembly |
| tests/test_scheduler_host.c | Baru | Host Unit Test |

---

# 9. Desain Teknis

## 9.1 Masalah yang Diselesaikan

Sebelum praktikum M9, kernel MCSOS belum memiliki mekanisme scheduler sehingga hanya dapat menjalankan satu alur eksekusi. Pada praktikum ini ditambahkan scheduler cooperative beserta context switch agar kernel mampu mengelola beberapa thread secara terstruktur.

## 9.2 Keputusan Desain

| Keputusan | Alasan |
|---|---|
| Cooperative Scheduler | Implementasi lebih sederhana untuk tahap awal |
| Round Robin | Pembagian giliran CPU secara bergantian |
| Assembly x86_64 | Mengakses register CPU secara langsung |

## 9.3 Diagram Arsitektur

```text
Kernel Thread
      │
      ▼
 Scheduler
      │
      ▼
 Run Queue
      │
      ▼
 Context Switch
      │
      ▼
 CPU Register
```

## 9.4 Struktur Data

Struktur utama menggunakan representasi kernel thread yang berisi informasi status thread, stack pointer, register, dan hubungan antar thread pada runqueue.

---

# 10. Langkah Kerja Implementasi

## Langkah 1

Membuat branch baru praktikum M9.

```bash
git switch -c praktikum-m9-scheduler
```

**Hasil**

Branch berhasil dibuat dan digunakan sebagai branch pengembangan M9.

---

## Langkah 2

Membuat struktur direktori praktikum.

```bash
mkdir -p include kernel tests scripts build/m9
```

**Hasil**

Direktori M9 berhasil dibuat.

---

## Langkah 3

Membuat file:

- `include/mcsos_thread.h`
- `kernel/mcsos_thread.c`
- `kernel/arch/x86_64/context_switch.S`
- `tests/test_scheduler_host.c`

**Hasil**

Seluruh file berhasil dibuat tanpa kesalahan sintaks.

---

## Langkah 4

Melakukan host syntax checking.

```bash
clang -std=c17 -Wall -Wextra -Werror \
-DMCSOS_HOST_TEST \
-Iinclude \
-fsyntax-only tests/test_scheduler_host.c
```

**Hasil**

Tidak ditemukan syntax error sehingga proses implementasi dapat dilanjutkan.

# 11. Checkpoint Buildable

| Checkpoint | Perintah | Hasil | Status |
|---|---|---|---|
| Host Test | `make m9-host-test` | Scheduler host unit test berhasil | PASS |
| Freestanding Build | `make m9-freestanding` | Object scheduler berhasil dibuat | PASS |
| Audit | `make m9-audit` | readelf, nm, objdump berhasil | PASS |
| Keseluruhan M9 | `make m9-all` | Seluruh target berhasil dijalankan | PASS |

### Catatan

Seluruh proses build M9 berhasil dilakukan tanpa error yang menyebabkan kegagalan proses. Seluruh target Makefile dapat dijalankan sesuai tujuan praktikum.

---

# 12. Perintah Uji dan Validasi

## 12.1 Host Unit Test

Perintah yang digunakan:

```bash
make m9-host-test
```

Hasil:

```text
M9 scheduler host unit test PASS
```

Status: **PASS**

---

## 12.2 Freestanding Build

Perintah:

```bash
make m9-freestanding
```

Hasil:

- Berhasil menghasilkan object file scheduler.
- Berhasil menghasilkan object file context switch.

Status: **PASS**

---

## 12.3 Audit

Perintah:

```bash
make m9-audit
```

Audit yang dilakukan meliputi:

- readelf
- nm
- objdump
- sha256sum

Status: **PASS**

---

## 12.4 Pengujian Keseluruhan

Perintah:

```bash
make m9-all
```

Hasil:

Seluruh proses host test, build freestanding, audit, dan verifikasi berhasil dijalankan.

Status: **PASS**

---

# 13. Hasil Uji

## 13.1 Ringkasan Hasil

| No | Pengujian | Hasil | Status |
|---|---|---|---|
| 1 | Host Scheduler Test | PASS | PASS |
| 2 | Freestanding Build | PASS | PASS |
| 3 | Readelf | PASS | PASS |
| 4 | NM | PASS | PASS |
| 5 | Objdump | PASS | PASS |
| 6 | SHA256 | PASS | PASS |
| 7 | Make m9-all | PASS | PASS |

---

## 13.2 Log Penting

Host Test

```text
M9 scheduler host unit test PASS
```

Audit

```text
ELF64
Advanced Micro Devices X86-64
```

Objdump berhasil menemukan symbol:

```text
mcsos_context_switch
```

SHA256 berhasil dibuat terhadap seluruh artefak build.

---

## 13.3 Artefak

| Artefak | Lokasi |
|---|---|
| m9_host_test | build/m9/ |
| m9_scheduler_combined.o | build/m9/ |
| readelf_header.log | build/m9/ |
| nm_undefined.log | build/m9/ |
| objdump_key.log | build/m9/ |
| sha256.log | build/m9/ |

---

# 14. Analisis Teknis

Implementasi scheduler berhasil dijalankan menggunakan metode cooperative round-robin. Scheduler mampu melakukan pengelolaan antrean thread sesuai urutan yang telah ditentukan.

Penggunaan context switch berbasis assembly x86_64 memungkinkan proses perpindahan thread dilakukan secara langsung melalui penyimpanan dan pemulihan register CPU.

Seluruh proses build berhasil dilakukan menggunakan compiler Clang pada mode freestanding sehingga implementasi tidak bergantung pada library sistem operasi.

Audit menggunakan readelf, nm, objdump, dan sha256sum menunjukkan bahwa object file berhasil dibangun dengan format ELF64 serta memiliki symbol yang diperlukan untuk proses scheduler.

Host unit test menghasilkan keluaran:

```text
M9 scheduler host unit test PASS
```

yang menunjukkan implementasi scheduler telah berjalan sesuai tujuan praktikum.

---

# 15. Debugging dan Failure Modes

Selama proses praktikum ditemukan beberapa kendala yang berhasil diperbaiki.

| Permasalahan | Penyebab | Solusi |
|---|---|---|
| File scheduler tidak ditemukan | Nama file pada Makefile tidak sesuai | Mengubah menjadi `test_scheduler_host.c` |
| Context switch tidak ditemukan | Path file assembly salah | Mengubah path menjadi `kernel/arch/x86_64/context_switch.S` |
| Error build Makefile | Target menggunakan lokasi file yang salah | Memperbaiki target Makefile |
| Host test gagal | File test belum dipanggil dengan benar | Menyesuaikan nama file pada Makefile |

Setelah seluruh perbaikan dilakukan, seluruh proses build dan pengujian berhasil dijalankan hingga selesai.

---

# 16. Prosedur Rollback

Jika implementasi M9 mengalami kegagalan, rollback dapat dilakukan menggunakan Git.

Kembali ke commit sebelumnya:

```bash
git checkout <commit-sebelumnya>
```

Membatalkan commit:

```bash
git revert <commit>
```

Membersihkan hasil build:

```bash
make clean
```

Seluruh source code tetap tersimpan pada repository sehingga implementasi dapat dipulihkan kembali apabila terjadi kesalahan selama pengembangan.

# 17. Keamanan dan Reliability

## 17.1 Risiko Keamanan

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Kesalahan context switch | Thread tidak dapat berpindah dengan benar | Implementasi assembly diverifikasi menggunakan objdump |
| Kesalahan scheduler | Runqueue menjadi tidak valid | Host unit test dilakukan sebelum build |
| Kesalahan build | Kernel gagal dikompilasi | Audit menggunakan readelf dan nm |

---

## 17.2 Reliability

Scheduler diuji menggunakan host unit test sehingga fungsi-fungsi utama dapat berjalan dengan benar sebelum diintegrasikan ke kernel. Proses build freestanding juga memastikan bahwa implementasi tidak bergantung pada library sistem operasi.

---

## 17.3 Negative Test

| Pengujian | Hasil |
|---|---|
| Build sebelum perbaikan Makefile | Gagal |
| Build setelah perbaikan Makefile | Berhasil |
| Host Test | PASS |
| Audit | PASS |

---

# 18. Pembagian Kerja

Praktikum ini dikerjakan secara **individu**, sehingga seluruh proses implementasi, pengujian, dokumentasi, dan integrasi dilakukan oleh penulis.

| Nama | Peran |
|---|---|
| Siti Sumyati | Implementasi, Pengujian, Dokumentasi |

---

# 19. Kriteria Lulus Praktikum

| Kriteria | Status |
|---|---|
| Source berhasil dibuat | PASS |
| Host Unit Test | PASS |
| Freestanding Build | PASS |
| Audit | PASS |
| Makefile M9 | PASS |
| Git Commit | PASS |
| Git Push | PASS |
| Dokumentasi | PASS |

---

# 20. Readiness Review

Status akhir praktikum:

**Siap Demonstrasi Praktikum**

Alasan:

- Scheduler berhasil diimplementasikan.
- Context switch berhasil dikompilasi.
- Host unit test menghasilkan PASS.
- Audit berhasil dijalankan.
- Build freestanding berhasil.
- Seluruh perubahan telah diunggah ke GitHub pada branch `praktikum-m9-scheduler`.

Known Issue:

- Masih terdapat warning kecil saat proses compile assembly, namun tidak memengaruhi hasil build maupun proses pengujian.

---

# 21. Rubrik Penilaian

| Komponen | Nilai |
|---|---:|
| Implementasi Scheduler | 30 |
| Context Switch | 20 |
| Pengujian | 20 |
| Analisis | 10 |
| Dokumentasi | 10 |
| Git Repository | 10 |
| **Total** | **100** |

---

# 22. Kesimpulan

Praktikum M9 berhasil diselesaikan dengan mengimplementasikan scheduler cooperative round-robin beserta mekanisme context switch berbasis assembly x86_64. Seluruh proses pengembangan dimulai dari pembuatan branch Git, implementasi source code, penyusunan host unit test, hingga penambahan target pada Makefile.

Hasil pengujian menunjukkan bahwa seluruh target berhasil dijalankan. Host unit test menghasilkan status **PASS**, proses freestanding build berhasil dilakukan, serta audit menggunakan `readelf`, `nm`, `objdump`, dan `sha256sum` berjalan tanpa kegagalan. Seluruh perubahan juga berhasil disimpan menggunakan Git dan diunggah ke repository GitHub.

Melalui praktikum ini diperoleh pemahaman mengenai mekanisme dasar scheduler, context switch, serta proses validasi implementasi kernel menggunakan berbagai alat analisis yang tersedia pada lingkungan pengembangan MCSOS.

---

# 23. Lampiran

## Lampiran A — Commit

```text
62931ef  M9 Scheduler selesai
```

---

## Lampiran B — Branch

```text
praktikum-m9-scheduler
```

---

## Lampiran C — Build

```text
make m9-host-test
PASS

make m9-freestanding
PASS

make m9-audit
PASS

make m9-all
PASS
```

---

## Lampiran D — Git

```text
git add .
git commit -m "M9 Scheduler selesai"
git push -u origin praktikum-m9-scheduler
```

---

# 24. Daftar Referensi

[1] Intel Corporation, *Intel® 64 and IA-32 Architectures Software Developer's Manual.*

[2] Arpaci-Dusseau, *Operating Systems: Three Easy Pieces.*

[3] LLVM Project, *Clang Documentation.*

[4] GNU Project, *GNU Make Manual.*

[5] Dokumentasi Praktikum MCSOS Milestone 9.

---

# 25. Checklist Pengumpulan

| Checklist | Status |
|---|---|
| Source code lengkap | Ya |
| Build berhasil | Ya |
| Host Test PASS | Ya |
| Audit PASS | Ya |
| Git Commit | Ya |
| Git Push | Ya |
| Laporan Markdown | Ya |

---

# 26. Pernyataan Pengumpulan

Commit akhir:

```text
62931ef
```

Branch:

```text
praktikum-m9-scheduler
```

Status akhir:

**Siap Demonstrasi Praktikum**

Ringkasan:

Praktikum M9 berhasil diselesaikan dengan implementasi scheduler cooperative round-robin, context switch x86_64, host unit test, freestanding build, audit, serta integrasi Git. Seluruh tahapan pengujian menunjukkan hasil **PASS** sehingga implementasi dinyatakan berhasil sesuai tujuan praktikum.