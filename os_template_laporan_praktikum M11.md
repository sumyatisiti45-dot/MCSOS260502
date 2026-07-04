# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M11]_[2583207073008].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


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
## 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan ini disusun berdasarkan pekerjaan praktikum sendiri sesuai pembagian peran yang tercatat. Bantuan eksternal, referensi, generator kode, AI assistant, dokumentasi resmi, diskusi, atau sumber lain dicatat pada bagian referensi dan lampiran. Saya tidak mengklaim hasil yang tidak dibuktikan oleh log, test, commit, atau artefak lain.

| Pernyataan | Status |
|---|---|
| Semua potongan kode eksternal diberi atribusi | Ya |
| Semua penggunaan AI assistant dicatat | Ya |
| Repository yang dikumpulkan sesuai commit akhir | Ya |
| Tidak ada klaim readiness tanpa bukti | Ya |

Catatan penggunaan bantuan eksternal:

```text
Alat:
- ChatGPT (OpenAI)
- GitHub (repository praktikum)
- Dokumentasi resmi LLVM/Clang
- Panduan Praktikum M11 MCSOS260502

Prompt ringkas:
- Meminta penjelasan langkah implementasi ELF Loader.
- Meminta bantuan memperbaiki error kompilasi, linker, dan Makefile.
- Meminta penjelasan hasil host test, freestanding build, dan audit.
- Meminta bantuan penyusunan laporan praktikum dalam format Markdown.

Bagian yang dibantu:
- Penjelasan konsep ELF Loader.
- Penyusunan struktur laporan.
- Analisis hasil pengujian.
- Pemeriksaan langkah implementasi.

Verifikasi mandiri:
- Seluruh kode diketik, dikompilasi, dan dijalankan sendiri.
- Host test berhasil dijalankan.
- Freestanding build berhasil.
- Audit berhasil.
- Commit dan push ke GitHub berhasil dilakukan pada branch
  praktikum-m11-elf-loader.
```

# Tujuan Praktikum

Pada Milestone 11 dilakukan implementasi **ELF Loader** sebagai dasar proses pemuatan program pengguna (user program). Modul ini bertugas melakukan validasi berkas ELF64 sebelum executable dimuat ke memori.

Adapun tujuan praktikum ini adalah:

- Memahami struktur file ELF64.
- Melakukan validasi header ELF.
- Memvalidasi Program Header.
- Memastikan alamat user berada pada rentang yang diizinkan.
- Menyusun rencana pemuatan executable (Process Image Plan).
- Melakukan pengujian host test dan freestanding build.

---

# Capaian Praktikum

Setelah menyelesaikan Milestone M11, diperoleh beberapa capaian sebagai berikut.

- Berhasil membuat header ELF Loader.
- Berhasil membuat implementasi ELF Loader.
- Berhasil membuat host test.
- Berhasil melakukan validasi berbagai kondisi ELF.
- Berhasil melakukan build freestanding.
- Berhasil melakukan audit object file.
- Berhasil melakukan commit dan push ke repository GitHub.

---

# Dasar Teori

## ELF (Executable and Linkable Format)

ELF merupakan format standar executable yang digunakan pada sistem operasi berbasis UNIX maupun Linux. Format ini menyimpan informasi mengenai struktur executable, section, symbol, serta program header yang digunakan oleh loader ketika program dijalankan.

Pada sistem operasi, ELF Loader berfungsi membaca executable kemudian memeriksa apakah format file valid sebelum dipetakan ke ruang alamat proses.

---

## ELF Header

ELF Header merupakan bagian pertama dari executable.

Header berisi informasi penting seperti:

- Magic Number
- Class (32-bit / 64-bit)
- Endian
- Machine Architecture
- Entry Point
- Program Header Offset
- Section Header Offset

Apabila salah satu informasi tidak sesuai maka executable dianggap tidak valid.

---

## Program Header

Program Header menjelaskan bagaimana executable akan dimuat ke memori.

Setiap Program Header memuat informasi berupa:

- Virtual Address
- File Offset
- Memory Size
- File Size
- Permission (Read, Write, Execute)
- Alignment

Loader melakukan pemeriksaan terhadap seluruh Program Header sebelum executable diproses.

---

## User Memory Validation

Selain memvalidasi struktur ELF, loader juga memeriksa apakah seluruh alamat virtual berada pada ruang alamat user yang diperbolehkan.

Validasi ini bertujuan untuk mencegah executable mengakses alamat kernel maupun alamat yang tidak sah.

---

## Process Image Plan

Setelah seluruh validasi berhasil dilakukan, loader akan menyusun Process Image Plan.

Informasi yang disimpan antara lain:

- Entry Point
- Jumlah Segment
- Virtual Address setiap segment
- File Offset
- Memory Size
- File Size
- Alignment
- Permission

Process Image Plan inilah yang nantinya digunakan pada proses loading executable ke memori.

---

# Struktur Folder

Implementasi M11 menambahkan beberapa file baru pada repository.

```text
include/
└── mcsos/
    └── user/
        └── m11_elf_loader.h

kernel/
└── user/
    └── m11_elf_loader.c

tests/
└── m11/
    └── m11_host_test.c
```

---

# Branch Repository

Branch yang digunakan selama implementasi adalah:

```text
praktikum-m11-elf-loader
```

Seluruh perubahan dikerjakan pada branch tersebut sebelum dilakukan commit dan push ke repository GitHub.

# Implementasi

## 1. Membuat Branch Baru

Sebelum memulai implementasi Milestone 11 dibuat branch baru agar pengembangan M11 terpisah dari milestone sebelumnya.

Perintah yang digunakan:

```bash
git switch -c praktikum-m11-elf-loader
```

Hasil:

```text
Switched to a new branch 'praktikum-m11-elf-loader'
```

---

## 2. Membuat Struktur Folder

Struktur folder dibuat untuk menempatkan file header, source code, dan host test.

Perintah:

```bash
mkdir -p include/mcsos/user kernel/user tests/m11 build/m11
```

Folder yang berhasil dibuat yaitu:

- include/mcsos/user
- kernel/user
- tests/m11
- build/m11

---

## 3. Membuat Header ELF Loader

File yang dibuat:

```text
include/mcsos/user/m11_elf_loader.h
```

Header ini berisi:

- Konstanta ELF64
- Struktur ELF Header
- Struktur Program Header
- Struktur User Region
- Struktur Segment Plan
- Struktur Process Image Plan
- Deklarasi fungsi ELF Loader

Header kemudian diuji menggunakan:

```bash
clang -std=c17 -Wall -Wextra -Werror -Iinclude -fsyntax-only include/mcsos/user/m11_elf_loader.h
```

Hasil pengujian tidak menampilkan error sehingga header berhasil dikompilasi.

---

## 4. Membuat Implementasi ELF Loader

File implementasi dibuat pada:

```text
kernel/user/m11_elf_loader.c
```

Implementasi meliputi beberapa fungsi utama, yaitu:

- m11_validate_user_range()
- m11_validate_ident()
- m11_validate_phdr_bounds()
- m11_validate_load_segment()
- m11_elf64_plan_load()
- m11_error_name()

Seluruh fungsi digunakan untuk melakukan validasi executable ELF64 sebelum diproses oleh sistem.

---

## 5. Pemeriksaan Sintaks Source

Setelah implementasi selesai dilakukan pengecekan sintaks.

Perintah:

```bash
clang -std=c17 -Wall -Wextra -Werror -DMCSOS_HOST_TEST -Iinclude -fsyntax-only kernel/user/m11_elf_loader.c
```

Hasil:

Tidak terdapat error sehingga source code dinyatakan valid.

---

## 6. Membuat Host Test

File pengujian dibuat pada:

```text
tests/m11/m11_host_test.c
```

Host test digunakan untuk menguji berbagai kondisi ELF, antara lain:

- ELF valid
- Magic Number salah
- Machine salah
- Entry berada di luar user region
- Memory Size lebih kecil dari File Size
- File melebihi ukuran image
- Alignment tidak valid
- Segment berada di luar user region

Pengujian dilakukan menggunakan beberapa skenario agar seluruh fungsi validasi dapat dipastikan bekerja dengan baik.

---

## 7. Menambahkan Target Makefile

Pada Makefile ditambahkan target baru yaitu:

```text
m11-host-test
m11-freestanding
m11-audit
m11-all
```

Target tersebut digunakan untuk:

- Mengompilasi host test
- Mengompilasi freestanding object
- Melakukan audit object file
- Menjalankan seluruh proses M11

---

# Pengujian

## Host Test

Perintah:

```bash
make m11-host-test
```

Hasil:

```text
PASS valid ELF64 image: M11_OK
PASS valid plan fields: entry=0x401000 segments=2
PASS bad magic: M11_ERR_MAGIC
PASS bad machine: M11_ERR_MACHINE
PASS entry outside user range: M11_ERR_ENTRY
PASS memsz below filesz: M11_ERR_SEGBOUNDS
PASS file range outside image: M11_ERR_SEGBOUNDS
PASS bad alignment: M11_ERR_ALIGN
PASS segment outside user range: M11_ERR_SEGRANGE
M11 host tests passed.
```

Seluruh pengujian berhasil dilewati tanpa error.

---

## Freestanding Build

Perintah:

```bash
make m11-freestanding
```

Hasil:

Object file berhasil dikompilasi menggunakan target freestanding x86_64 tanpa error.

---

## Audit

Perintah:

```bash
make m11-audit
```

Audit menghasilkan:

- nm undefined symbol
- readelf header
- objdump
- sha256 checksum

Seluruh proses audit berhasil dijalankan.

---

# Hasil Implementasi

Milestone M11 berhasil diimplementasikan dengan baik.

ELF Loader mampu:

- Memvalidasi format ELF64.
- Memvalidasi Program Header.
- Memvalidasi ruang alamat user.
- Menyusun Process Image Plan.
- Menghasilkan kode kesalahan sesuai kondisi executable.
- Lulus seluruh host test.
- Berhasil dikompilasi pada mode freestanding.

# Analisis

Berdasarkan hasil implementasi dan pengujian, modul ELF Loader telah berhasil dikembangkan sesuai tujuan Milestone 11. Implementasi mampu melakukan validasi terhadap file ELF64 sebelum proses pemuatan ke memori dilakukan.

Validasi yang dilakukan meliputi pemeriksaan magic number, arsitektur mesin, ukuran header, program header, alignment, ukuran segment, serta rentang alamat memori pengguna. Dengan adanya validasi tersebut, hanya executable yang memenuhi spesifikasi yang dapat diproses lebih lanjut.

Pengujian menggunakan host test menunjukkan bahwa setiap kondisi kesalahan dapat dideteksi dengan benar melalui kode error yang sesuai. Selain itu, proses kompilasi freestanding dan audit object file juga berhasil tanpa menghasilkan error.

Secara keseluruhan implementasi M11 sudah memenuhi kebutuhan dasar untuk proses loading executable pada sistem operasi MCSOS.

---

# Kendala yang Dihadapi

Selama proses pengerjaan Milestone 11 terdapat beberapa kendala, antara lain:

- Kesalahan penempatan isi file header ke dalam file source sehingga menyebabkan fungsi tidak ditemukan saat proses linking.
- Kesalahan path include pada file `m11_elf_loader.c`.
- Error `undefined reference` akibat implementasi fungsi belum sesuai.
- Penyesuaian Makefile agar target `m11-host-test`, `m11-freestanding`, dan `m11-audit` dapat dijalankan dengan benar.

Setelah dilakukan perbaikan, seluruh proses build dan pengujian berhasil diselesaikan.

---

# Kesimpulan

Berdasarkan hasil implementasi dan pengujian dapat disimpulkan bahwa:

1. ELF Loader berhasil diimplementasikan.
2. Validasi ELF64 berjalan sesuai kebutuhan.
3. Validasi Program Header berhasil dilakukan.
4. Validasi ruang alamat user berhasil dilakukan.
5. Process Image Plan berhasil disusun.
6. Host test berhasil dilewati tanpa error.
7. Freestanding build berhasil dikompilasi.
8. Audit object berhasil dijalankan.
9. Seluruh perubahan berhasil disimpan ke Git dan diunggah ke GitHub.

Milestone 11 berhasil diselesaikan dan menjadi dasar untuk implementasi proses eksekusi program pada milestone berikutnya.

---

# Commit Git

Commit yang digunakan pada Milestone 11:

```text
M11 ELF Loader selesai
```

---

# Branch

Branch yang digunakan:

```text
praktikum-m11-elf-loader
```

---

# Push Repository

Branch berhasil dikirim ke repository GitHub menggunakan perintah:

```bash
git push -u origin praktikum-m11-elf-loader
```

Status push berhasil ditunjukkan dengan pesan:

```text
branch 'praktikum-m11-elf-loader' set up to track
'origin/praktikum-m11-elf-loader'
```

---

# Daftar File yang Ditambahkan

```
include/mcsos/user/m11_elf_loader.h
kernel/user/m11_elf_loader.c
tests/m11/m11_host_test.c
```

Selain itu dilakukan perubahan pada:

```
Makefile
```

---

# Dokumentasi Pengujian

## Host Test

```bash
make m11-host-test
```

Status:

```
PASS
```

---

## Freestanding

```bash
make m11-freestanding
```

Status:

```
PASS
```

---

## Audit

```bash
make m11-audit
```

Status:

```
PASS
```

---

# Penutup

Milestone M11 berhasil diselesaikan sesuai target. Implementasi ELF Loader mampu melakukan validasi executable ELF64, menyusun process image plan, serta menghasilkan proses build dan pengujian yang berhasil tanpa error. Seluruh hasil implementasi telah disimpan ke repository GitHub sehingga siap digunakan sebagai dasar untuk melanjutkan ke Milestone M12.