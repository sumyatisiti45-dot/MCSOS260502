# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M10]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M10 |
| Judul praktikum | ABI System Call Awal, Dispatcher Syscall, Validasi Argumen, dan Jalur `int 0x80` Terkendali pada MCSOS |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | 29 Juni 2026 |
| Tanggal pengumpulan | 29 Juni 2026 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | `praktikum-m10-syscall` |
| Commit awal | `62931ef` |
| Commit akhir | `3c7e873` |
| Status readiness yang diklaim | Siap uji praktikum |

---

# 1. Sampul

# Laporan Praktikum M10

## ABI System Call Awal, Dispatcher Syscall, Validasi Argumen, dan Jalur `int 0x80` Terkendali pada MCSOS

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1B | Individu |

**Dosen Pengampu:** Muhaemin Sidiq, S.Pd., M.Pd.

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

Tahun Akademik 2025/2026

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan ini disusun berdasarkan hasil praktikum yang saya kerjakan sendiri dengan mengikuti panduan Praktikum M10. Bantuan AI digunakan sebagai pendamping untuk memahami langkah-langkah implementasi, penyusunan dokumentasi, serta pengecekan hasil. Seluruh implementasi telah diverifikasi melalui proses build, host test, audit, commit Git, dan push ke repository.

| Pernyataan | Status |
|---|---|
| Semua potongan kode eksternal diberi atribusi | Ya |
| Semua penggunaan AI assistant dicatat | Ya |
| Repository yang dikumpulkan sesuai commit akhir | Ya |
| Tidak ada klaim tanpa bukti | Ya |

**Catatan penggunaan bantuan eksternal**

```text
Menggunakan ChatGPT sebagai pendamping untuk memahami panduan praktikum, membantu proses debugging, penyusunan laporan Markdown, dan verifikasi hasil implementasi. Seluruh hasil diuji kembali menggunakan host test, audit, dan Git.
```

---

# 3. Tujuan Praktikum

1. Mengimplementasikan Application Binary Interface (ABI) untuk system call pada MCSOS.
2. Membuat dispatcher syscall untuk menangani layanan kernel.
3. Menerapkan validasi argumen sebelum diproses oleh kernel.
4. Mengimplementasikan jalur pemanggilan system call menggunakan `int 0x80`.
5. Melakukan pengujian menggunakan host unit test, freestanding build, dan audit.
6. Mendokumentasikan seluruh hasil implementasi ke dalam repository GitHub.

---

# 4. Capaian Pembelajaran Praktikum

Setelah praktikum ini mahasiswa mampu:

| CPL/CPMK Praktikum | Bukti |
|---|---|
| Memahami konsep ABI System Call | Header `syscall.h` berhasil dibuat |
| Mengimplementasikan dispatcher syscall | `kernel/syscall/syscall.c` berhasil dikompilasi |
| Memahami jalur `int 0x80` | `syscall_entry.S` berhasil dibuat |
| Melakukan pengujian host dan audit | `make m10-host-test`, `make m10-audit`, dan `make m10-all` berhasil dijalankan |

# 5. Lingkungan Pengembangan

## Sistem Operasi
- Windows 11
- WSL2 Ubuntu

## Compiler
- Clang
- LLVM
- ld.lld

## Tools
- Git
- Make
- Readelf
- Objdump
- NM
- SHA256SUM
- Nano
- Terminal Linux

## Struktur Direktori

```
include/
└── mcsos/
    └── syscall.h

kernel/
└── syscall/
    ├── syscall.c
    └── syscall_entry.S

tests/
└── test_syscall_host.c

build/
└── m10/

Makefile
```

---

# 6. Implementasi

## Header System Call

Header `include/mcsos/syscall.h` dibuat untuk mendefinisikan ABI system call, nomor system call, struktur frame, status error, callback kernel, serta deklarasi fungsi dispatcher.

Fungsi utama yang tersedia antara lain:

- `mcsos_syscall_init()`
- `mcsos_syscall_dispatch()`
- `mcsos_syscall_dispatch_frame()`
- `mcsos_copy_from_user()`
- `mcsos_user_check_range()`

---

## Dispatcher System Call

File `kernel/syscall/syscall.c` digunakan sebagai dispatcher utama.

Dispatcher bertugas:

- menerima nomor syscall
- melakukan validasi nomor syscall
- melakukan validasi alamat user
- memanggil handler sesuai nomor syscall
- mengembalikan nilai hasil eksekusi

Beberapa layanan syscall yang diimplementasikan yaitu:

- SYS_PING
- SYS_GET_TICKS
- SYS_WRITE_SERIAL
- SYS_YIELD
- SYS_EXIT_THREAD

---

## Assembly Entry

File

```
kernel/syscall/syscall_entry.S
```

digunakan sebagai pintu masuk interrupt `int 0x80`.

Assembly bertugas:

- menyimpan register
- memanggil dispatcher kernel
- mengembalikan hasil syscall
- menjalankan `iretq`

---

## Host Unit Test

Host unit test dibuat pada

```
tests/test_syscall_host.c
```

Pengujian meliputi:

- syscall ping
- dispatcher
- validasi nomor syscall
- copy user memory
- pengecekan return value

---

## Makefile

Makefile ditambahkan target:

- m10-host-test
- m10-freestanding
- m10-audit
- m10-all

Seluruh target berhasil dijalankan tanpa error.

---

# 7. Hasil Pengujian

## Host Test

Perintah

```bash
make m10-host-test
```

Hasil

```text
M10 syscall host tests passed
```

Status:

✅ Berhasil

---

## Freestanding Build

Perintah

```bash
make m10-freestanding
```

Status:

✅ Berhasil

Object yang dihasilkan:

```
build/m10/syscall.o
build/m10/syscall_entry.o
build/m10/m10_syscall_combined.o
```

---

## Audit

Perintah

```bash
make m10-audit
```

Audit berhasil menghasilkan:

- readelf
- nm
- objdump
- sha256

Status:

✅ Berhasil

---

## Build Keseluruhan

Perintah

```bash
make m10-all
```

Status:

✅ Seluruh proses berhasil dijalankan.

---

# 8. Git Repository

Branch yang digunakan:

```text
praktikum-m10-syscall
```

Commit:

```text
M10 Syscall selesai
```

Push berhasil dilakukan ke GitHub sehingga branch telah tersimpan pada repository.

# 9. Analisis Hasil

Implementasi pada praktikum M10 berhasil menambahkan mekanisme awal system call pada MCSOS. Header `syscall.h` digunakan untuk mendefinisikan ABI, nomor system call, struktur frame, serta deklarasi fungsi dispatcher. File `syscall.c` berfungsi sebagai dispatcher yang menerima nomor syscall, melakukan validasi, kemudian memanggil layanan kernel sesuai permintaan. Selain itu, file `syscall_entry.S` menjadi jalur masuk interrupt `int 0x80` yang menghubungkan kode pengguna dengan kernel.

Pengujian host menunjukkan bahwa seluruh fungsi dasar dapat berjalan dengan baik. Build freestanding berhasil menghasilkan object file kernel tanpa kesalahan kompilasi. Audit menggunakan `readelf`, `objdump`, `nm`, dan `sha256sum` juga menunjukkan bahwa hasil build telah memenuhi syarat yang ditentukan pada praktikum.

---

# 10. Kendala dan Solusi

| Kendala | Solusi |
|---------|--------|
| Target M10 belum muncul pada Makefile | Menambahkan target `m10-host-test`, `m10-freestanding`, `m10-audit`, dan `m10-all` pada bagian bawah Makefile. |
| Kesalahan path file assembly | Mengubah path menjadi `kernel/syscall/syscall_entry.S`. |
| Kesalahan saat build freestanding | Memastikan parameter compiler dan linker sesuai dengan target x86_64 freestanding. |
| Error saat pengujian | Memperbaiki konfigurasi Makefile dan memastikan seluruh file berhasil dikompilasi. |

---

# 11. Hasil Akhir Praktikum

| Pengujian | Hasil |
|-----------|-------|
| Host Test | ✅ Lulus |
| Freestanding Build | ✅ Lulus |
| Audit | ✅ Lulus |
| Build Keseluruhan | ✅ Lulus |
| Git Commit | ✅ Berhasil |
| Git Push | ✅ Berhasil |

---

# 12. Kesimpulan

Praktikum M10 berhasil diselesaikan dengan mengimplementasikan mekanisme dasar system call pada sistem operasi MCSOS. Seluruh komponen utama berhasil dibuat, mulai dari header ABI, dispatcher syscall, entry assembly, host unit test, hingga penyesuaian Makefile. Hasil pengujian menunjukkan bahwa seluruh proses build, host test, freestanding build, dan audit dapat dijalankan tanpa error. Repository Git juga berhasil diperbarui melalui proses commit dan push pada branch `praktikum-m10-syscall`.

---

# 13. Lampiran

## Struktur File

```
include/
└── mcsos/
    └── syscall.h

kernel/
└── syscall/
    ├── syscall.c
    └── syscall_entry.S

tests/
└── test_syscall_host.c

build/
└── m10/

Makefile
```

---

## Branch Git

```text
praktikum-m10-syscall
```

---

## Commit

```text
M10 Syscall selesai
```

---

## Output Host Test

```text
M10 syscall host tests passed
```

---

## Output Build

```bash
make m10-host-test
make m10-freestanding
make m10-audit
make m10-all
```

Seluruh perintah berhasil dijalankan tanpa error.

---

# 14. Referensi

1. Panduan Praktikum M10 MCSOS 260502.
2. Dokumentasi LLVM Clang.
3. Dokumentasi GNU Make.
4. Dokumentasi ELF x86_64.
5. Dokumentasi Git.

---

# 15. Checklist Praktikum

| Item | Status |
|------|--------|
| Membuat branch M10 | ✅ |
| Membuat `syscall.h` | ✅ |
| Membuat `syscall.c` | ✅ |
| Membuat `syscall_entry.S` | ✅ |
| Membuat host test | ✅ |
| Menambahkan target Makefile | ✅ |
| Host Test | ✅ |
| Freestanding Build | ✅ |
| Audit | ✅ |
| Build Keseluruhan | ✅ |
| Git Commit | ✅ |
| Git Push | ✅ |
| Laporan Markdown | ✅ |

---

# 16. Penutup

Praktikum M10 telah berhasil diselesaikan. Implementasi ABI system call, dispatcher syscall, validasi argumen, dan jalur interrupt `int 0x80` dapat berjalan sesuai tujuan praktikum. Seluruh tahapan mulai dari implementasi, pengujian, audit, hingga dokumentasi telah dilakukan dan menghasilkan keluaran yang sesuai dengan panduan praktikum.