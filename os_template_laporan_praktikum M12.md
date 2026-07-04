# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_M12_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  



---

# LAPORAN PRAKTIKUM M12
## Sinkronisasi Kernel Awal: Spinlock, Mutex Kooperatif, Lock-Order Validator, dan Diagnosis Race/Deadlock pada MCSOS

---

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum |M4 |
| Judul praktikum |  Interrupt Descriptor Table, Exception Trap Path, Trap Frame, dan FaultHandling Awal  |
| Jenis pengerjaan | Individu  |
| Nama mahasiswa | Siti Sumyati |
| NIM |  2583207073008 |
| Kelas | 1b` |
| Nama kelompok | `[isi jika kelompok]` |
| Anggota kelompok | `[nama, NIM, peran ringkas]` |
| Tanggal praktikum | `[YYYY-MM-DD]` |
| Tanggal pengumpulan | `[YYYY-MM-DD]` |
| Repository | `[URL repo privat / path lokal]` |
| Branch | `[nama branch]` |
| Commit awal | `` `[hash commit awal]` `` |
| Commit akhir | `` `[hash commit akhir]` `` |
| Status readiness yang diklaim | `[belum siap uji / siap uji QEMU / siap demonstrasi praktikum / kandidat siap pakai terbatas]` |

---

## 1. Sampul

# Laporan Praktikum `[M4]`  
## `[J Interrupt Descriptor Table, Exception Trap Path, Trap Frame, dan FaultHandling Awal ]`

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1b | individu  |
| `[opsional]` | `[opsional]` | `[opsional]` | `[opsional]` |


Dosen Pengampu: **Muhaemin Sidiq, S.Pd., M.Pd.**  
Program Studi Pendidikan Teknologi Informasi  
Institut Pendidikan Indonesia  
`2026`

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa seluruh implementasi, pengujian, dan dokumentasi pada Praktikum M13 merupakan hasil pengerjaan saya sendiri berdasarkan panduan Praktikum MCSOS260502. Seluruh sumber referensi dan bantuan yang digunakan telah dicantumkan pada bagian daftar referensi. Repository Git mencerminkan seluruh proses pengerjaan yang dilakukan selama praktikum.

---

# 3. Tujuan Praktikum

Praktikum M13 bertujuan untuk mengimplementasikan **Virtual File System (VFS)** sederhana beserta **RAM File System (RAMFS)** pada MCSOS. Selain itu dilakukan implementasi manajemen **File Descriptor (FD)**, operasi dasar sistem berkas, pengujian host, build object freestanding, audit hasil kompilasi, serta integrasi ke sistem build menggunakan Makefile.

---

# 4. Capaian Pembelajaran Praktikum

Setelah menyelesaikan praktikum ini mahasiswa mampu:

- Memahami konsep Virtual File System (VFS).
- Memahami konsep RAM File System (RAMFS).
- Mengimplementasikan manajemen File Descriptor.
- Mengimplementasikan operasi dasar sistem berkas.
- Melakukan pengujian host terhadap implementasi VFS.
- Melakukan build object freestanding.
- Melakukan audit object file menggunakan toolchain.
- Menggunakan Git sebagai version control.

---

# 5. Peta Milestone MCSOS

Milestone yang dikerjakan pada laporan ini adalah:

✅ **M13 – Virtual File System (VFS) dan RAMFS**

---

# 6. Dasar Teori

## 6.1 Virtual File System (VFS)

Virtual File System (VFS) merupakan lapisan abstraksi yang menyediakan antarmuka umum bagi berbagai jenis sistem berkas. Dengan adanya VFS, kernel dapat mengakses berbagai implementasi file system melalui mekanisme yang seragam sehingga memudahkan pengelolaan file pada sistem operasi.

## 6.2 RAM File System (RAMFS)

RAM File System (RAMFS) merupakan sistem berkas sederhana yang seluruh datanya disimpan di memori utama (RAM). Sistem ini memiliki akses yang cepat karena tidak bergantung pada media penyimpanan permanen dan sering digunakan sebagai implementasi awal dalam pengembangan kernel.

## 6.3 File Descriptor

File Descriptor (FD) merupakan identitas numerik yang digunakan proses untuk mengakses file yang sedang dibuka. Setiap descriptor menyimpan informasi mengenai file, posisi baca/tulis, serta hak akses terhadap file tersebut.

## 6.4 Operasi Dasar Sistem Berkas

Operasi dasar sistem berkas meliputi pembuatan file, pembukaan file, pembacaan data, penulisan data, penutupan file, serta pencarian file berdasarkan nama. Operasi tersebut menjadi dasar layanan file pada sistem operasi.

---

# 7. Lingkungan Praktikum

## Host

- Windows 11
- Ubuntu WSL2

## Toolchain

- Clang
- LLVM
- GNU Make
- Git
- Bash

## Repository

Repository praktikum:

```
~/src/mcsos
```

Branch yang digunakan:

```
praktikum-m13-vfs-ramfs
```

---

# 8. Repository dan Struktur File

## Struktur Folder

```
include/
kernel/vfs/
tests/
build/m13/
```

## File yang Dibuat

```
include/mcs_vfs.h

kernel/vfs/ramfs.c

kernel/vfs/fd.c

kernel/vfs/sys_vfs.c

tests/m13_vfs_host_test.c
```

## Git Diff

Perubahan yang dilakukan meliputi:

- Penambahan header `mcs_vfs.h`.
- Implementasi `ramfs.c`.
- Implementasi `fd.c`.
- Implementasi `sys_vfs.c`.
- Penambahan `m13_vfs_host_test.c`.
- Penambahan target M13 pada Makefile.
# 10. Checkpoint Buildable

Setelah seluruh file implementasi selesai dibuat, dilakukan pengecekan sintaks untuk memastikan setiap file dapat dikompilasi tanpa error.

Pengecekan dilakukan terhadap:

- `include/mcs_sync.h`
- `kernel/sync/lockdep.c`
- `kernel/sync/spinlock.c`
- `kernel/sync/mutex.c`
- `tests/m12_sync_host_test.c`

Seluruh file berhasil melewati pengecekan menggunakan `clang -fsyntax-only` tanpa menghasilkan error.

---

# 11. Perintah Uji dan Validasi

## 11.1 Host Test

Perintah:

```bash
make m12-host-test
```

Hasil:

- Program host berhasil dikompilasi.
- Seluruh pengujian berhasil dijalankan.
- Tidak ditemukan kegagalan pengujian.

Status:

```
PASS
```

---

## 11.2 Freestanding Build

Perintah:

```bash
make m12-freestanding
```

Hasil:

- File object freestanding berhasil dibuat.
- Kompilasi selesai tanpa error.

Status:

```
PASS
```

---

## 11.3 Audit

Perintah:

```bash
make m12-audit
```

Audit menghasilkan beberapa file:

```
build/m12/m12_host_test
build/m12/m12_sync_combined.o
build/m12/nm_undefined.log
build/m12/readelf_header.log
build/m12/objdump.log
build/m12/sha256.log
```

Hasil audit menunjukkan:

- Tidak terdapat undefined symbol.
- Object berhasil dikenali sebagai ELF64.
- Machine Architecture adalah AMD x86-64.
- File checksum berhasil dibuat.

Status:

```
PASS
```

---

# 12. Hasil Uji

Ringkasan hasil pengujian ditunjukkan pada tabel berikut.

| Pengujian | Status |
|-----------|--------|
| Syntax Check | PASS |
| Host Test | PASS |
| Freestanding Build | PASS |
| Audit | PASS |
| Git Commit | PASS |
| Git Push | PASS |

Seluruh tahapan praktikum berhasil diselesaikan tanpa ditemukan error pada implementasi akhir.

---

# 13. Analisis Teknis

Implementasi sinkronisasi pada M12 berhasil memenuhi tujuan praktikum.

Lockdep digunakan untuk melakukan validasi urutan pengambilan lock sehingga potensi deadlock dapat dideteksi sejak awal.

Spinlock digunakan sebagai mekanisme sinkronisasi untuk melindungi critical section dengan teknik busy waiting.

Mutex kooperatif digunakan untuk memastikan hanya satu owner yang dapat mengakses resource tertentu dalam satu waktu.

Setelah implementasi selesai dilakukan host test yang menunjukkan seluruh fungsi bekerja sesuai harapan.

Tahap selanjutnya dilakukan freestanding build untuk memastikan implementasi dapat dikompilasi sebagai bagian dari kernel.

Proses audit menggunakan `nm`, `readelf`, `objdump`, dan `sha256sum` menunjukkan object file berhasil dibuat dengan benar dan tidak memiliki undefined symbol.

Berdasarkan hasil tersebut implementasi M12 dinyatakan berhasil.

---

# 14. Debugging dan Failure Modes

Selama proses pengerjaan ditemukan beberapa kendala.

## Kendala

- Target `m12-host-test` belum tersedia pada Makefile.
- Build tidak dapat dijalankan karena target M12 belum ditambahkan.

## Solusi

Target berikut ditambahkan ke Makefile:

- `m12-host-test`
- `m12-freestanding`
- `m12-audit`
- `m12-all`

Setelah target ditambahkan, proses build dan pengujian dapat dijalankan dengan baik.

---

# 15. Prosedur Rollback

Apabila implementasi mengalami kegagalan maka proses rollback dapat dilakukan menggunakan Git.

Contoh:

```bash
git restore .
```

atau

```bash
git reset --hard HEAD
```

Rollback dilakukan sebelum proses commit apabila ditemukan kesalahan implementasi.

---

# 16. Keamanan dan Reliability

Implementasi memperhatikan beberapa aspek berikut.

- Validasi urutan lock menggunakan Lockdep.
- Pencegahan akses bersamaan menggunakan Spinlock.
- Pengendalian owner menggunakan Mutex.
- Audit object file untuk memastikan hasil kompilasi valid.
- Version control menggunakan Git sehingga perubahan dapat ditelusuri kembali.

# 17. Pembagian Kerja Kelompok

Praktikum M12 dikerjakan secara individu sehingga tidak terdapat pembagian tugas antaranggota.

---

# 18. Kriteria Lulus Praktikum

Kriteria kelulusan praktikum M12 telah terpenuhi, yaitu:

- Implementasi `mcs_sync.h` selesai.
- Implementasi `lockdep.c` selesai.
- Implementasi `spinlock.c` selesai.
- Implementasi `mutex.c` selesai.
- Host test berhasil dijalankan.
- Freestanding build berhasil.
- Audit berhasil.
- Repository berhasil di-push ke GitHub.

---

# 19. Readiness Review

Readiness praktikum diperiksa berdasarkan hasil build dan pengujian.

| Pemeriksaan | Status |
|-------------|--------|
| Header | ✔ |
| Lockdep | ✔ |
| Spinlock | ✔ |
| Mutex | ✔ |
| Host Test | ✔ |
| Freestanding | ✔ |
| Audit | ✔ |
| Git | ✔ |

Status akhir:

```
READY
```

---

# 20. Rubrik Penilaian

Bagian ini disediakan untuk dosen atau asisten praktikum.

---

# 21. Kesimpulan

Praktikum M12 berhasil diselesaikan dengan mengimplementasikan mekanisme sinkronisasi dasar pada kernel MCSOS.

Komponen yang berhasil dibuat meliputi:

- Lockdep
- Spinlock
- Mutex Kooperatif

Seluruh file berhasil dikompilasi tanpa error.

Host test berhasil dijalankan.

Freestanding build berhasil dilakukan.

Audit object file berhasil menghasilkan file ELF yang valid.

Perubahan berhasil disimpan menggunakan Git dan dikirim ke repository GitHub pada branch:

```
praktikum-m12-sync
```

Dengan demikian seluruh tujuan praktikum M12 telah tercapai.

---

# 22. Lampiran

## Struktur Folder

```
include/
├── mcs_sync.h

kernel/
└── sync/
    ├── lockdep.c
    ├── spinlock.c
    └── mutex.c

tests/
└── m12_sync_host_test.c

build/
└── m12/
```

---

## Perintah yang Digunakan

```bash
make m12-host-test

make m12-freestanding

make m12-audit

git add .

git commit -m "M12 Synchronization selesai"

git push -u origin praktikum-m12-sync
```

---

## Bukti Pengujian

Lampirkan screenshot berikut:

- Host Test PASS
- Freestanding PASS
- Audit PASS
- Git Status
- Git Commit
- Git Push
- Branch GitHub

---

# 23. Daftar Referensi

1. Intel Corporation. *Intel® 64 and IA-32 Architectures Software Developer's Manual.*

2. LLVM Project. *Clang Documentation.*

3. GNU Project. *GNU Make Manual.*

4. Linux Kernel Documentation. *Locking and Synchronization.*

5. Dokumentasi Git. *Git SCM Documentation.*

6. Panduan Praktikum MCSOS260502 Milestone 12.

---

# 24. Checklist Final

| Item | Status |
|------|--------|
| Header selesai | ✔ |
| Lockdep selesai | ✔ |
| Spinlock selesai | ✔ |
| Mutex selesai | ✔ |
| Host Test PASS | ✔ |
| Freestanding PASS | ✔ |
| Audit PASS | ✔ |
| Commit Git | ✔ |
| Push GitHub | ✔ |
| Laporan selesai | ✔ |

---

# 25. Pernyataan Pengumpulan

Saya menyatakan bahwa seluruh implementasi pada praktikum M12 telah dikerjakan, diuji, dan didokumentasikan sesuai panduan praktikum.

Branch:

```
praktikum-m12-sync
```

Commit:

```
M12 Synchronization selesai
```

Status akhir:

```
SELESAI
```