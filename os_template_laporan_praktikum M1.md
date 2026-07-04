# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M1]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  


---

# 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M1 |
| Judul praktikum | Toolchain Reproducible dan Pemeriksaan Kesiapan Lingkungan Pengembangan MCSOS 260502 |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | Sesuai jadwal praktikum |
| Tanggal pengumpulan | Sesuai pengumpulan |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | m1 |
| Commit awal | fd838b2 |
| Commit akhir | 9feb3e5 |
| Status readiness yang diklaim | Siap uji QEMU |

---

# 1. Sampul

# Laporan Praktikum M1

## Toolchain Reproducible dan Pemeriksaan Kesiapan Lingkungan Pengembangan MCSOS 260502

Disusun oleh

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1B | Individu |

**Dosen Pengampu**

Muhaemin Sidiq, S.Pd., M.Pd.

Program Studi Pendidikan Teknologi Informasi

Institut Pendidikan Indonesia

2026

---

# 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan praktikum ini merupakan hasil pekerjaan sendiri berdasarkan panduan praktikum MCSOS. Seluruh proses instalasi toolchain, konfigurasi lingkungan pengembangan, pengujian compiler, linker, emulator, serta dokumentasi dilakukan secara mandiri.

Apabila menggunakan dokumentasi resmi maupun AI sebagai pendamping belajar, seluruh hasil diverifikasi kembali melalui pengujian langsung sebelum dimasukkan ke dalam laporan.

| Pernyataan | Status |
|---|---|
| Semua penggunaan referensi dicantumkan | Ya |
| Semua penggunaan AI diverifikasi kembali | Ya |
| Repository sesuai commit akhir | Ya |
| Tidak ada klaim tanpa bukti | Ya |

---

# 3. Tujuan Praktikum

Praktikum M1 bertujuan membangun lingkungan pengembangan yang dapat direproduksi sehingga seluruh milestone berikutnya dapat dikerjakan menggunakan konfigurasi yang sama.

Tujuan praktikum adalah:

1. Menyiapkan toolchain LLVM untuk target x86_64.
2. Memastikan compiler, linker, assembler, debugger, dan emulator bekerja dengan baik.
3. Membuat metadata lingkungan pengembangan.
4. Melakukan proof compile freestanding.
5. Melakukan pemeriksaan reproducibility.
6. Menghasilkan evidence sebagai dasar milestone berikutnya.

---

# 4. Capaian Pembelajaran

Setelah menyelesaikan praktikum ini mahasiswa mampu:

| CPL | Bukti |
|---|---|
| Menggunakan toolchain LLVM | Output versi toolchain |
| Menggunakan Git | Repository dan commit |
| Menggunakan Makefile | Build berhasil |
| Menghasilkan object freestanding | Proof compile |
| Memverifikasi reproducibility | Metadata build |

---

# 5. Peta Milestone

| Milestone | Status |
|---|---|
| M0 | Selesai |
| M1 | Selesai |
| M2 | Belum |
| M3 | Belum |
| M4 | Belum |
| M5 | Belum |
| M6 | Belum |
| M7 | Belum |
| M8 | Belum |
| M9 | Belum |
| M10 | Belum |
| M11 | Belum |
| M12 | Belum |
| M13 | Belum |
| M14 | Belum |
| M15 | Belum |
| M16 | Belum |

---

# 6. Dasar Teori

## 6.1 Toolchain

Toolchain merupakan kumpulan perangkat lunak yang digunakan untuk membangun kernel sistem operasi. Pada praktikum ini digunakan Clang sebagai compiler, LLD sebagai linker, NASM sebagai assembler, GNU Binutils sebagai alat inspeksi ELF, QEMU sebagai emulator, serta GDB sebagai debugger.

## 6.2 Reproducible Build

Reproducible build merupakan proses menghasilkan output build yang konsisten apabila source code dan toolchain yang digunakan sama.

## 6.3 Freestanding Environment

Kernel sistem operasi tidak menggunakan library standar seperti program biasa sehingga proses kompilasi menggunakan mode freestanding dengan opsi seperti `-ffreestanding`, `-nostdlib`, dan `-mno-red-zone`.

## 6.4 Target x86_64

Arsitektur target MCSOS adalah x86_64 sehingga seluruh proses kompilasi menggunakan target LLVM x86_64-unknown-none-elf agar menghasilkan object yang sesuai untuk kernel.
---

# 7. Lingkungan Praktikum

## 7.1 Host dan Target

| Komponen | Nilai |
|---|---|
| Host OS | Windows 11 x64 |
| Lingkungan Build | Ubuntu WSL2 |
| Target ISA | x86_64 |
| Target ABI | x86_64-unknown-none-elf |
| Emulator | QEMU x86_64 |
| Firmware Emulator | OVMF UEFI Firmware |
| Debugger | GDB |
| Build System | GNU Make |
| Compiler | Clang |
| Linker | LLD |
| Assembler | NASM |

---

## 7.2 Versi Toolchain

Versi toolchain diperiksa untuk memastikan seluruh perangkat lunak yang digunakan sesuai dengan kebutuhan praktikum.

Perintah yang dijalankan:

```bash
date -u +"date_utc=%Y-%m-%dT%H:%M:%SZ"
uname -a
git --version
make --version
clang --version
ld.lld --version
nasm -v
qemu-system-x86_64 --version
gdb --version
python3 --version
```

Seluruh perintah berhasil dijalankan dan menghasilkan informasi versi toolchain yang digunakan selama praktikum.

---

## 7.3 Lokasi Repository

| Item | Nilai |
|---|---|
| Path Repository | ~/src/mcsos |
| Filesystem | Linux (WSL2) |
| Remote Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | m1 |
| Commit Awal | fd838b2 |
| Commit Akhir | 9feb3e5 |

Repository ditempatkan pada filesystem Linux agar proses build bersifat reproducible dan memiliki performa yang lebih baik dibandingkan apabila berada pada direktori `/mnt/c`.

---

# 8. Repository dan Struktur File

## 8.1 Struktur Direktori

Struktur direktori utama repository adalah sebagai berikut.

```text
mcsos/
├── artifacts/
├── build/
├── configs/
├── docs/
├── evidence/
├── include/
├── iso_root/
├── kernel/
├── scripts/
├── tests/
├── tools/
├── Makefile
└── README.md
```

Direktori tersebut digunakan sebagai dasar seluruh milestone MCSOS.

---

## 8.2 File yang Dibuat atau Diubah

| File | Jenis Perubahan | Alasan |
|---|---|---|
| Makefile | Ubah | Menambahkan target M1 |
| docs/readiness/M1-toolchain.md | Baru | Dokumentasi readiness |
| build/meta/toolchain-versions.txt | Baru | Metadata toolchain |
| build/meta/host-readiness.txt | Baru | Status host |
| build/proof/freestanding_probe.o | Baru | Bukti proof compile |
| scripts/check_toolchain.sh | Baru | Pemeriksaan toolchain |
| scripts/collect_meta.sh | Baru | Mengumpulkan metadata |
| scripts/proof_compile.sh | Baru | Proof compile |
| scripts/repro_check.sh | Baru | Pemeriksaan reproducibility |

---

## 8.3 Ringkasan Perubahan

Repository berhasil diperbarui dengan penambahan script otomatis untuk melakukan pemeriksaan toolchain, menghasilkan metadata, melakukan proof compile, dan memverifikasi reproducibility.

Seluruh perubahan disimpan menggunakan Git sehingga dapat dilacak melalui commit history.

---

# 9. Desain Teknis

## 9.1 Permasalahan

Sebelum milestone M1 dimulai belum terdapat mekanisme untuk memastikan bahwa seluruh lingkungan pengembangan memiliki toolchain yang sama. Hal tersebut dapat menyebabkan hasil build berbeda pada setiap komputer.

---

## 9.2 Solusi

Solusi yang diterapkan adalah membuat serangkaian script otomatis yang bertugas melakukan pemeriksaan lingkungan pengembangan, mencatat metadata, melakukan proof compile, serta menghasilkan evidence yang dapat digunakan pada milestone berikutnya.

---

## 9.3 Diagram Alur

```text
Pengguna
    │
    ▼
Check Toolchain
    │
    ▼
Collect Metadata
    │
    ▼
Proof Compile
    │
    ▼
Reproducibility Check
    │
    ▼
Evidence M1
```

Diagram tersebut menunjukkan bahwa seluruh proses M1 dilakukan secara berurutan mulai dari pemeriksaan toolchain hingga menghasilkan evidence.

---

## 9.4 Invariant

Selama proses praktikum M1 berlaku beberapa aturan berikut.

1. Repository harus berada pada filesystem Linux.
2. Toolchain harus tersedia sebelum proses build dilakukan.
3. Metadata harus dihasilkan setiap kali pemeriksaan dilakukan.
4. Proof compile harus menghasilkan object freestanding.
5. Evidence disimpan pada direktori build dan docs.
---

# 10. Langkah Kerja Implementasi

Pada praktikum M1 seluruh implementasi dilakukan secara bertahap mulai dari menyiapkan struktur repository hingga melakukan commit hasil praktikum. Setiap langkah memiliki tujuan, perintah yang dijalankan, hasil yang diperoleh, serta indikator keberhasilan.

---

## Langkah 6 – Membuat Struktur Repository M1

### Tujuan

Menyiapkan struktur direktori yang akan digunakan untuk menyimpan metadata, proof compile, dokumentasi, evidence, serta script pendukung selama pengerjaan milestone M1.

### Perintah

```bash
mkdir -p docs/readiness
mkdir -p docs/security
mkdir -p docs/testing
mkdir -p build/meta
mkdir -p build/proof
mkdir -p tools/scripts
```

### Hasil

Seluruh direktori berhasil dibuat tanpa error dan siap digunakan pada langkah berikutnya.

### Indikator Keberhasilan

- Direktori berhasil dibuat.
- Tidak terdapat pesan error.
- Repository siap digunakan.

---

## Langkah 7 – Membuat Script collect_meta.sh

### Tujuan

Script ini digunakan untuk mengumpulkan metadata lingkungan pengembangan seperti informasi sistem operasi, compiler, linker, assembler, Git, serta tool lain yang digunakan selama praktikum.

### Perintah

```bash
./tools/scripts/collect_meta.sh
```

Kemudian dilakukan pemeriksaan hasil.

```bash
ls -l build/meta
```

### Hasil

Script berhasil dijalankan dan menghasilkan beberapa file metadata pada direktori `build/meta`.

### Artefak

| File | Fungsi |
|------|--------|
| toolchain-versions.txt | Menyimpan versi toolchain |
| host-readiness.txt | Menyimpan informasi host |

### Indikator Keberhasilan

- Script berjalan tanpa error.
- File metadata berhasil dibuat.

---

## Langkah 8 – Membuat Script check_toolchain.sh

### Tujuan

Melakukan pemeriksaan otomatis terhadap toolchain yang digunakan selama praktikum.

### Perintah

```bash
./tools/scripts/check_toolchain.sh
```

### Hasil

Seluruh tool seperti Clang, LLD, Git, Make, NASM, Python, dan QEMU berhasil dikenali.

### Indikator Keberhasilan

- Seluruh tool terdeteksi.
- Tidak terdapat tool yang hilang.
- Pemeriksaan selesai tanpa error.

---

## Langkah 9 – Membuat Source Proof Freestanding

### Tujuan

Membuat source code sederhana untuk membuktikan bahwa compiler mampu menghasilkan object freestanding sesuai target kernel.

### Hasil

Source berhasil dibuat dan siap digunakan pada proses proof compile.

---

## Langkah 10 – Membuat Script proof_compile.sh

### Tujuan

Melakukan kompilasi source freestanding sehingga menghasilkan object ELF64.

### Perintah

```bash
./tools/scripts/proof_compile.sh
```

### Hasil

Compiler berhasil menghasilkan object freestanding dan evidence build.

### Artefak

| File | Fungsi |
|------|--------|
| freestanding_probe.o | Bukti proof compile |

### Indikator Keberhasilan

- Object berhasil dibuat.
- Format ELF64 sesuai target.

---

## Langkah 11 – Membuat Script qemu_probe.sh

### Tujuan

Memastikan QEMU tersedia dan dapat digunakan sebagai emulator target x86_64.

### Perintah

```bash
./tools/scripts/qemu_probe.sh
```

### Hasil

QEMU berhasil dikenali dan informasi versi berhasil ditampilkan.

### Indikator Keberhasilan

- QEMU tersedia.
- Script selesai tanpa error.

---

## Langkah 12 – Membuat Script repro_check.sh

### Tujuan

Memastikan hasil proof compile bersifat reproducible dengan membandingkan hash dua hasil build.

### Perintah

```bash
./tools/scripts/repro_check.sh
```

### Hasil

Hash kedua object sama sehingga proses build dinyatakan reproducible.

### Indikator Keberhasilan

- Hash identik.
- Tidak terdapat perbedaan hasil build.

---

## Langkah 13 – Membuat Makefile Minimum M1

### Tujuan

Menjadikan Makefile sebagai antarmuka utama seluruh proses build M1.

### Perintah

```bash
make meta
make proof
make qemu-probe
make repro
make test
```

### Hasil

Seluruh target berhasil dijalankan melalui Makefile.

### Indikator Keberhasilan

- Semua target berhasil dieksekusi.
- Tidak ada error saat build.

---

## Langkah 14 – Membuat Dokumen Invariants

### Tujuan

Mendokumentasikan aturan dasar yang harus dipenuhi selama pengembangan MCSOS.

### Hasil

Dokumen invariants berhasil dibuat sebagai acuan milestone berikutnya.

---

## Langkah 15 – Membuat Threat Model

### Tujuan

Mengidentifikasi risiko terhadap toolchain dan lingkungan pengembangan.

### Hasil

Dokumen threat model berhasil dibuat sebagai dasar pembahasan keamanan.

---

## Langkah 16 – Membuat Readiness Review

### Tujuan

Melakukan evaluasi kesiapan lingkungan pengembangan sebelum memasuki milestone berikutnya.

### Hasil

Readiness review menunjukkan seluruh persyaratan M1 telah terpenuhi.

---

## Langkah 17 – Clean Checkout Rehearsal

### Tujuan

Membuktikan bahwa repository dapat dibangun ulang dari kondisi bersih.

### Perintah

```bash
make distclean
make test
```

### Hasil

Seluruh pengujian berhasil dijalankan kembali tanpa bergantung pada file hasil build sebelumnya.

### Indikator Keberhasilan

- Build berhasil.
- Test berhasil.
- Repository bersifat reproducible.

---

## Langkah 18 – Commit Hasil Praktikum

### Tujuan

Menyimpan seluruh perubahan ke repository Git sebagai akhir pengerjaan milestone M1.

### Perintah

```bash
git add .
git commit -m "Complete M1 toolchain readiness and proof validation"
git push
```

### Hasil

Perubahan berhasil disimpan ke GitHub.

Commit akhir:

```
9feb3e5
```

### Indikator Keberhasilan

- Commit berhasil dibuat.
- Branch m1 berhasil di-push ke GitHub.
- Repository siap digunakan pada milestone M2.
---

# 11. Checkpoint Buildable

Checkpoint buildable dilakukan untuk memastikan bahwa seluruh implementasi pada milestone M1 telah berhasil dibangun dan seluruh komponen yang diperlukan dapat digunakan kembali tanpa mengalami kegagalan.

## Tujuan

Checkpoint buildable bertujuan untuk memverifikasi bahwa hasil implementasi M1 telah memenuhi persyaratan dasar sebelum melanjutkan ke milestone berikutnya.

## Pemeriksaan

| No | Pemeriksaan | Status |
|----|-------------|--------|
| 1 | Toolchain LLVM berhasil dikenali | PASS |
| 2 | Metadata berhasil dibuat | PASS |
| 3 | Proof compile berhasil | PASS |
| 4 | QEMU berhasil dikenali | PASS |
| 5 | Reproducibility berhasil | PASS |
| 6 | Target Makefile berhasil dijalankan | PASS |

## Hasil

Berdasarkan seluruh pemeriksaan di atas, implementasi milestone M1 berhasil memenuhi seluruh checkpoint buildable. Seluruh script berjalan dengan baik, metadata berhasil dibuat, proof compile menghasilkan object freestanding, dan repository dinyatakan siap digunakan untuk milestone M2.

---

# 12. Perintah Uji dan Validasi

Untuk memastikan seluruh implementasi berjalan dengan benar, dilakukan beberapa pengujian menggunakan target yang tersedia pada Makefile.

| Perintah | Fungsi | Status |
|----------|--------|--------|
| `make check` | Memeriksa toolchain | PASS |
| `make meta` | Menghasilkan metadata | PASS |
| `make proof` | Melakukan proof compile | PASS |
| `make qemu-probe` | Memeriksa QEMU | PASS |
| `make repro` | Memeriksa reproducibility | PASS |
| `make test` | Menjalankan seluruh pengujian | PASS |

Seluruh pengujian berhasil dijalankan tanpa menghasilkan error sehingga implementasi M1 dinyatakan valid.

---

# 13. Hasil Uji

Ringkasan hasil pengujian milestone M1 disajikan pada tabel berikut.

| No | Pengujian | Hasil |
|----|-----------|-------|
| 1 | Pemeriksaan Toolchain | Berhasil |
| 2 | Pembuatan Metadata | Berhasil |
| 3 | Proof Compile | Berhasil |
| 4 | Pemeriksaan QEMU | Berhasil |
| 5 | Reproducibility | Berhasil |
| 6 | Pengujian Keseluruhan | Berhasil |

### Kesimpulan Hasil Uji

Seluruh pengujian pada milestone M1 berhasil diselesaikan sesuai dengan tujuan praktikum. Toolchain dapat digunakan dengan baik, metadata berhasil dibuat, proof compile menghasilkan object freestanding, serta hasil build bersifat reproducible. Dengan demikian milestone M1 dinyatakan berhasil dan siap menjadi dasar untuk melanjutkan pengembangan pada milestone M2.