# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M2]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  

---

# 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M2 |
| Judul praktikum | Boot Image, Kernel ELF64, Early Serial Console, dan Readiness Gate M2 |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | Sesuai jadwal praktikum |
| Tanggal pengumpulan | Sesuai tanggal pengumpulan |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | m2 |
| Commit awal | 9feb3e5 |
| Commit akhir | 280d6df |
| Status readiness yang diklaim | Siap uji QEMU |

---

# 1. Sampul

# Laporan Praktikum M2

## Boot Image, Kernel ELF64, Early Serial Console, dan Readiness Gate M2

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

Saya menyatakan bahwa laporan praktikum M2 ini merupakan hasil pekerjaan sendiri berdasarkan panduan praktikum MCSOS. Seluruh proses implementasi, konfigurasi boot image, penyusunan kernel ELF64, pengujian menggunakan QEMU, serta dokumentasi dilakukan secara mandiri.

Apabila menggunakan dokumentasi resmi maupun AI sebagai pendamping belajar, seluruh hasil telah diverifikasi kembali melalui pengujian langsung sebelum dimasukkan ke dalam laporan.

| Pernyataan | Status |
|---|---|
| Semua penggunaan referensi dicantumkan | Ya |
| Semua penggunaan AI diverifikasi kembali | Ya |
| Repository sesuai commit akhir | Ya |
| Tidak ada klaim tanpa bukti | Ya |

---

# 3. Tujuan Praktikum

Praktikum M2 bertujuan menghasilkan image kernel yang dapat di-boot menggunakan QEMU serta menampilkan keluaran awal melalui serial console.

Tujuan praktikum adalah:

1. Menyusun kernel berformat ELF64.
2. Menyiapkan boot image menggunakan Limine.
3. Menjalankan kernel melalui QEMU.
4. Memastikan early serial console bekerja dengan benar.
5. Menghasilkan artefak build dan log sebagai evidence.
6. Menyiapkan repository untuk milestone berikutnya.

---

# 4. Capaian Pembelajaran Praktikum

Setelah menyelesaikan praktikum ini mahasiswa mampu:

| CPL | Bukti |
|---|---|
| Menyusun kernel ELF64 | Hasil build kernel |
| Menyiapkan boot image | ISO berhasil dibuat |
| Menjalankan kernel pada QEMU | Serial log berhasil muncul |
| Melakukan validasi build | Build log dan evidence |

---

# 5. Peta Milestone MCSOS

| Milestone | Status |
|---|---|
| M0 | Selesai |
| M1 | Selesai |
| M2 | Selesai |
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

# 6. Dasar Teori Ringkas

## 6.1 Konsep Sistem Operasi yang Diuji

Pada praktikum M2 mahasiswa mempelajari proses booting sistem operasi mulai dari bootloader hingga kernel berhasil dijalankan. Kernel dibangun dalam format ELF64 dan dimuat oleh bootloader Limine. Setelah kernel berhasil dimuat, informasi awal sistem ditampilkan melalui serial console sebagai bukti bahwa proses boot berhasil.

## 6.2 Konsep Arsitektur x86_64 yang Relevan

| Konsep | Relevansi | Bukti |
|---|---|---|
| ELF64 | Format executable kernel | readelf |
| Linker Script | Menentukan layout kernel | linker.ld |
| UEFI | Firmware untuk proses boot | OVMF |
| Serial Console | Menampilkan log kernel | Output QEMU |
| QEMU | Emulator target x86_64 | QEMU berhasil dijalankan |

## 6.3 Konsep Implementasi Freestanding

| Aspek | Implementasi |
|---|---|
| Bahasa | C17 Freestanding |
| Assembly | x86_64 Assembly |
| Compiler | Clang |
| Linker | LLD |
| ABI | x86_64 System V ABI |
| Runtime | Tanpa libc (freestanding) |

## 6.4 Referensi Teori

| No | Referensi | Kegunaan |
|---|---|---|
| 1 | Operating Systems: Three Easy Pieces | Konsep sistem operasi |
| 2 | Intel Software Developer Manual | Arsitektur x86_64 |
| 3 | Limine Documentation | Bootloader |
| 4 | QEMU Documentation | Emulator |

---

# 7. Lingkungan Praktikum

## 7.1 Host dan Target

| Komponen | Keterangan |
|---|---|
| Sistem Operasi Host | Windows 11 x64 |
| Lingkungan Linux | WSL2 Ubuntu |
| Target | x86_64 |
| Emulator | QEMU |
| Firmware | OVMF UEFI |

---

## 7.2 Toolchain

| Tool | Fungsi |
|---|---|
| Git | Version Control |
| Clang | Compiler |
| LLD | Linker |
| NASM | Assembler |
| Make | Build System |
| Python3 | Script Pendukung |
| QEMU | Emulator |
| GDB | Debugger |

---

## 7.3 Struktur Repository

Repository MCSOS menggunakan struktur direktori yang telah disiapkan sejak milestone sebelumnya.

Direktori utama yang digunakan selama M2 antara lain:

```text
kernel/
boot/
configs/
docs/
tools/
scripts/
build/
evidence/
artifacts/
```

Seluruh direktori berhasil dikenali dan digunakan selama proses implementasi M2.

---

# 8. Desain Implementasi

## 8.1 Arsitektur Boot

Urutan proses boot pada M2 adalah sebagai berikut.

```
UEFI
    │
    ▼
OVMF
    │
    ▼
Limine Bootloader
    │
    ▼
Kernel ELF64
    │
    ▼
Early Serial Console
```

Bootloader bertugas memuat kernel ELF64 ke memori, kemudian kontrol dialihkan ke fungsi awal kernel sehingga kernel dapat menampilkan pesan awal melalui serial console.

---

## 8.2 Artefak yang Dihasilkan

| Artefak | Keterangan |
|---|---|
| mcsos.iso | Boot image |
| mcsos-m2.elf | Kernel ELF64 |
| build log | Bukti build |
| serial log | Bukti boot |
| readelf | Verifikasi ELF |
| objdump | Verifikasi simbol |
---

# 9. Struktur Repository dan Artefak

## 9.1 Struktur Repository

Selama praktikum M2, repository MCSOS memiliki struktur direktori sebagai berikut.

```text
mcsos/
├── boot/
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
└── linker.ld
```

Struktur tersebut digunakan sebagai dasar implementasi kernel, proses build, serta penyimpanan evidence praktikum.

---

## 9.2 Artefak yang Dihasilkan

| Artefak | Lokasi | Keterangan |
|---------|--------|------------|
| mcsos-m2.elf | build/ | Kernel ELF64 |
| mcsos.iso | build/ | Boot image |
| readelf-header.txt | build/ | Header ELF |
| readelf-sections.txt | build/ | Section ELF |
| readelf-program-headers.txt | build/ | Program Header |
| disassembly.txt | build/ | Hasil objdump |
| symbols.txt | build/ | Simbol kernel |
| build.log | logs/m2/ | Log proses build |
| qemu.log | logs/m2/ | Log serial QEMU |

---

## 9.3 Ringkasan Implementasi

Implementasi M2 menghasilkan kernel berformat ELF64 yang dapat dimuat oleh bootloader Limine. Kernel berhasil dijalankan menggunakan QEMU dan menampilkan pesan awal melalui serial console. Seluruh artefak build berhasil dibuat sebagai bukti keberhasilan implementasi.

---

# 10. Langkah Kerja Implementasi

Pada praktikum M2 seluruh implementasi dilakukan secara bertahap mulai dari pemeriksaan kesiapan repository, pemeriksaan artefak M1, konfigurasi boot image, proses build kernel, hingga pengujian menggunakan QEMU. Setiap langkah dilakukan secara berurutan agar kernel dapat dijalankan dengan benar.

---

## Langkah 1 – Pemeriksaan Lokasi Repository

### Tujuan

Memastikan repository berada pada filesystem Linux (WSL2).

### Perintah

```bash
pwd
```

### Hasil

Repository berada pada direktori:

```text
~/src/mcsos
```

### Indikator Keberhasilan

- Repository berada pada filesystem Linux.
- Tidak berada pada `/mnt/c`.

---

## Langkah 2 – Pemeriksaan Repository Git

### Tujuan

Memastikan repository dalam kondisi bersih sebelum implementasi M2.

### Perintah

```bash
git status
git branch --show-current
git log --oneline -5
```

### Hasil

Repository berada pada branch M2 dan tidak terdapat perubahan yang belum disimpan.

### Indikator Keberhasilan

- Working tree bersih.
- Branch aktif sesuai.
- Riwayat commit tersedia.

---

## Langkah 3 – Pemeriksaan Artefak M0

### Tujuan

Memastikan seluruh dokumen dasar dari M0 masih tersedia.

### Perintah

```bash
ls docs/
```

### Hasil

Seluruh dokumen M0 berhasil ditemukan.

### Indikator Keberhasilan

- Dokumen M0 tersedia.
- Repository siap digunakan.

---

## Langkah 4 – Pemeriksaan Artefak M1

### Tujuan

Memastikan seluruh evidence M1 masih tersedia sebelum melanjutkan implementasi M2.

### Perintah

```bash
ls build/meta
ls build/proof
```

### Hasil

Metadata toolchain dan proof compile berhasil ditemukan.

### Indikator Keberhasilan

- Metadata tersedia.
- Proof compile tersedia.
---

## Langkah 5 – Pemeriksaan Toolchain

### Tujuan

Memastikan seluruh tool yang diperlukan pada praktikum M2 telah tersedia dan dapat digunakan.

### Perintah

```bash
clang --version
ld.lld --version
nasm -v
qemu-system-x86_64 --version
python3 --version
make --version
git --version
```

### Hasil

Seluruh tool berhasil dikenali dan menampilkan informasi versinya masing-masing sehingga siap digunakan selama proses build.

### Indikator Keberhasilan

- Clang tersedia.
- LLD tersedia.
- NASM tersedia.
- QEMU tersedia.
- Python tersedia.
- Make tersedia.
- Git tersedia.

---

## Langkah 6 – Pemeriksaan Firmware OVMF

### Tujuan

Memastikan firmware OVMF tersedia sebagai firmware UEFI untuk menjalankan kernel pada QEMU.

### Perintah

```bash
find /usr/share -name "OVMF*.fd"
```

### Hasil

File firmware OVMF berhasil ditemukan sehingga QEMU dapat dijalankan menggunakan mode UEFI.

### Indikator Keberhasilan

- File OVMF ditemukan.
- Firmware dapat digunakan oleh QEMU.

---

## Langkah 7 – Menjalankan Script Preflight

### Tujuan

Memastikan seluruh persyaratan awal praktikum M2 telah terpenuhi.

### Perintah

```bash
bash tools/scripts/m2_preflight.sh
```

### Hasil

Script preflight berhasil dijalankan dan seluruh pemeriksaan menghasilkan status berhasil.

### Indikator Keberhasilan

- Script selesai tanpa error.
- Seluruh pemeriksaan PASS.

---

## Langkah 8 – Pemeriksaan Struktur Kernel

### Tujuan

Memastikan direktori dan file kernel tersedia sesuai kebutuhan implementasi M2.

### Perintah

```bash
find kernel -maxdepth 2 -type f
```

### Hasil

Seluruh file kernel berhasil ditemukan dan siap digunakan selama proses build.

### Indikator Keberhasilan

- Struktur kernel lengkap.
- Tidak ada file utama yang hilang.

---

## Langkah 9 – Pemeriksaan Konfigurasi Boot

### Tujuan

Memastikan konfigurasi bootloader telah tersedia.

### Perintah

```bash
ls boot
cat boot/limine.conf
```

### Hasil

File konfigurasi bootloader berhasil ditemukan dan siap digunakan untuk membangun boot image.

### Indikator Keberhasilan

- File `limine.conf` tersedia.
- Konfigurasi dapat dibaca.

---

## Langkah 10 – Proses Build Kernel

### Tujuan

Membangun kernel MCSOS dalam format ELF64.

### Perintah

```bash
make clean
make all
```

### Hasil

Kernel berhasil dikompilasi tanpa error dan menghasilkan file ELF64.

### Indikator Keberhasilan

- Build berhasil.
- Tidak terdapat error.
- Kernel ELF64 berhasil dibuat.
---

## Langkah 11 – Pemeriksaan File Kernel

### Tujuan

Memastikan file kernel ELF64 berhasil dibuat setelah proses build.

### Perintah

```bash
ls -lh build/
file build/mcsos-m2.elf
```

### Hasil

File `mcsos-m2.elf` berhasil dibuat dan dikenali sebagai executable ELF64 untuk arsitektur x86_64.

### Indikator Keberhasilan

- File kernel tersedia.
- Format ELF64 sesuai target.
- Tidak terdapat error.

---

## Langkah 12 – Pemeriksaan Header ELF

### Tujuan

Memastikan header ELF sesuai dengan arsitektur yang digunakan.

### Perintah

```bash
readelf -h build/mcsos-m2.elf
```

### Hasil

Header ELF berhasil ditampilkan dan menunjukkan bahwa kernel menggunakan format ELF64 untuk arsitektur x86_64.

### Indikator Keberhasilan

- ELF64.
- Machine: Advanced Micro Devices X86-64.
- Entry point berhasil ditampilkan.

---

## Langkah 13 – Pemeriksaan Section ELF

### Tujuan

Memastikan section pada kernel berhasil dibuat.

### Perintah

```bash
readelf -S build/mcsos-m2.elf
```

### Hasil

Seluruh section kernel berhasil ditampilkan sesuai hasil proses linking.

### Indikator Keberhasilan

- Section berhasil ditampilkan.
- Tidak terdapat error.

---

## Langkah 14 – Pemeriksaan Program Header

### Tujuan

Memastikan program header kernel telah terbentuk dengan benar.

### Perintah

```bash
readelf -l build/mcsos-m2.elf
```

### Hasil

Program header berhasil ditampilkan sesuai layout kernel.

### Indikator Keberhasilan

- Program header tersedia.
- Layout
---

## Langkah 15 – Menjalankan Kernel Menggunakan QEMU

### Tujuan

Memastikan kernel MCSOS dapat dijalankan menggunakan emulator QEMU.

### Perintah

```bash
make run
```

atau

```bash
bash tools/scripts/run_qemu.sh
```

### Hasil

QEMU berhasil dijalankan dan bootloader Limine berhasil memuat kernel MCSOS.

### Indikator Keberhasilan

- QEMU berhasil dijalankan.
- Kernel berhasil dimuat.
- Tidak terjadi kernel panic saat boot awal.

---

## Langkah 16 – Pemeriksaan Serial Console

### Tujuan

Memastikan kernel berhasil mengirimkan pesan awal melalui serial console.

### Perintah

```bash
cat logs/m2/qemu_serial.log
```

### Hasil

Pesan awal kernel berhasil ditampilkan melalui serial console sebagai bukti bahwa kernel telah berjalan dengan benar.

### Indikator Keberhasilan

- Serial console aktif.
- Pesan boot kernel muncul.
- Tidak terdapat error pada proses boot.

---

## Langkah 17 – Audit Hasil Build

### Tujuan

Memastikan hasil build memenuhi persyaratan praktikum M2.

### Perintah

```bash
make inspect
make audit
```

### Hasil

Proses audit berhasil dilakukan dan seluruh pemeriksaan terhadap file ELF, simbol kernel, serta artefak build dinyatakan sesuai.

### Indikator Keberhasilan

- Audit berhasil dijalankan.
- Tidak terdapat undefined symbol.
- Seluruh pemeriksaan PASS.

---

## Langkah 18 – Pengumpulan Evidence

### Tujuan

Mengumpulkan seluruh artefak hasil build sebagai bukti penyelesaian praktikum M2.

### Perintah

```bash
mkdir -p evidence/m2
cp build/*.txt evidence/m2/
cp logs/m2/* evidence/m2/
```

### Hasil

Seluruh evidence berhasil dikumpulkan ke dalam direktori `evidence/m2`.

### Indikator Keberhasilan

- Evidence berhasil disimpan.
- Seluruh file pendukung tersedia.

---

## Langkah 19 – Commit Hasil Praktikum

### Tujuan

Menyimpan seluruh perubahan hasil implementasi M2 ke dalam repository Git.

### Perintah

```bash
git add .
git commit -m "M2 bootable early serial baseline"
git push origin m2
```

### Hasil

Seluruh perubahan berhasil di-commit dan dikirim ke repository GitHub pada branch **m2**.

Commit akhir:

```text
280d6df
```

### Indikator Keberhasilan

- Commit berhasil dibuat.
- Branch **m2** berhasil di-push
---

# 11. Checkpoint Buildable

Checkpoint buildable dilakukan untuk memastikan bahwa seluruh implementasi pada milestone M2 telah berhasil dibangun dan memenuhi persyaratan praktikum sebelum melanjutkan ke milestone berikutnya.

## 11.1 Pemeriksaan Build

| Pemeriksaan | Status |
|-------------|--------|
| Build kernel berhasil | PASS |
| Kernel ELF64 berhasil dibuat | PASS |
| Boot image berhasil dibuat | PASS |
| QEMU berhasil dijalankan | PASS |
| Serial console berhasil menampilkan output | PASS |
| Audit berhasil | PASS |

### Hasil

Seluruh proses build berhasil diselesaikan tanpa error. Kernel dapat dijalankan menggunakan QEMU dan menghasilkan output melalui serial console sesuai dengan tujuan praktikum M2.

---

# 12. Perintah Uji dan Validasi

Pengujian dilakukan untuk memastikan seluruh implementasi pada milestone M2 berjalan sesuai dengan yang diharapkan.

| No | Perintah | Fungsi | Status |
|----|----------|--------|--------|
| 1 | `make clean` | Membersihkan hasil build | PASS |
| 2 | `make all` | Membangun kernel | PASS |
| 3 | `make inspect` | Pemeriksaan file ELF | PASS |
| 4 | `make audit` | Audit kernel | PASS |
| 5 | `make run` | Menjalankan kernel pada QEMU | PASS |

### Hasil

Seluruh pengujian berhasil dijalankan tanpa menghasilkan error sehingga implementasi milestone M2 dinyatakan berhasil.

---

# 13. Hasil Uji

Ringkasan hasil pengujian ditampilkan pada tabel berikut.

| No | Pengujian | Hasil | Status |
|----|-----------|--------|--------|
| 1 | Build Kernel ELF64 | Berhasil | PASS |
| 2 | Boot Image | Berhasil | PASS |
| 3 | Pemeriksaan Header ELF | Berhasil | PASS |
| 4 | Pemeriksaan Section ELF | Berhasil | PASS |
| 5 | Pemeriksaan Program Header | Berhasil | PASS |
| 6 | Menjalankan Kernel pada QEMU | Berhasil | PASS |
| 7 | Serial Console | Berhasil | PASS |
| 8 | Audit Build | Berhasil | PASS |

### Kesimpulan Hasil Uji

Seluruh pengujian pada milestone M2 berhasil dilaksanakan sesuai dengan tujuan praktikum. Kernel berhasil dibangun dalam format ELF64, boot image berhasil dibuat, kernel dapat dijalankan menggunakan emulator QEMU, serta serial console berhasil menampilkan keluaran awal kernel. Berdasarkan hasil tersebut, milestone M2 dinyatakan berhasil diselesaikan.

---

# 14. Analisis Teknis

Implementasi pada milestone M2 berhasil menghasilkan kernel awal yang dapat dijalankan menggunakan bootloader Limine. Proses build menghasilkan file kernel ELF64 yang sesuai dengan target arsitektur x86_64. Pengujian menggunakan QEMU menunjukkan bahwa kernel berhasil dimuat dan dapat menampilkan informasi awal melalui serial console.

Penggunaan tool seperti `readelf`, `objdump`, dan `nm` membantu memverifikasi struktur file
file ELF64 yang dihasilkan. Hasil pemeriksaan menunjukkan bahwa header ELF, section, program header, serta simbol kernel telah terbentuk sesuai kebutuhan milestone M2.

Selain itu, penggunaan serial console mempermudah proses debugging karena informasi awal kernel dapat ditampilkan tanpa memerlukan antarmuka grafis. Dengan demikian, apabila terjadi kesalahan pada tahap boot, proses analisis dapat dilakukan lebih mudah melalui log serial yang dihasilkan.

Secara keseluruhan implementasi M2 telah memenuhi tujuan praktikum, yaitu menghasilkan kernel awal yang dapat di-boot menggunakan QEMU dan menjadi dasar pengembangan untuk milestone selanjutnya.

---

# 15. Failure Modes dan Debugging

Selama proses implementasi M2 terdapat beberapa potensi kegagalan yang dapat terjadi. Tabel berikut menjelaskan penyebab serta solusi yang dilakukan.

| No | Failure Mode | Penyebab | Solusi |
|----|--------------|----------|--------|
| 1 | Build gagal | Source belum lengkap | Memeriksa kembali source dan Makefile |
| 2 | Kernel tidak ditemukan | Link gagal | Memastikan proses linking berhasil |
| 3 | QEMU tidak dapat dijalankan | OVMF belum tersedia | Memasang paket OVMF |
| 4 | Serial console tidak muncul | Konfigurasi serial salah | Memeriksa parameter QEMU |
| 5 | Audit gagal | Simbol kernel tidak ditemukan | Memeriksa hasil build dan linking |

Seluruh permasalahan yang muncul selama implementasi berhasil diselesaikan sehingga proses build dapat dilanjutkan hingga selesai.

---

# 16. Prosedur Rollback

Apabila proses implementasi mengalami kegagalan, langkah pemulihan dilakukan sebagai berikut.

1. Membersihkan hasil build menggunakan `make clean`.
2. Memeriksa kembali struktur repository.
3. Menjalankan kembali proses build menggunakan `make all`.
4. Melakukan pemeriksaan dengan `make inspect`.
5. Menjalankan audit menggunakan `make audit`.
6. Menjalankan kembali kernel menggunakan QEMU.

Langkah tersebut memastikan repository kembali ke kondisi yang dapat dibangun tanpa harus mengulang seluruh implementasi.

---

# 17. Keamanan dan Reliability

Implementasi M2 memperhatikan aspek keamanan dan keandalan selama proses build maupun pengujian.

| Aspek | Implementasi |
|--------|--------------|
| Version Control | Menggunakan Git |
| Build Reproducibility | Menggunakan Makefile |
| Audit | Menggunakan inspect dan audit |
| Emulator | QEMU dengan OVMF |
| Dokumentasi | Evidence dan log build |

Seluruh artefak hasil implementasi disimpan sebagai evidence sehingga proses praktikum dapat ditelusuri kembali apabila diperlukan.
---

# 18. Kesimpulan

Berdasarkan seluruh tahapan implementasi dan pengujian yang telah dilakukan, milestone M2 berhasil diselesaikan sesuai dengan tujuan praktikum. Kernel MCSOS berhasil dibangun dalam format ELF64, boot image berhasil dibuat menggunakan bootloader Limine, serta kernel dapat dijalankan menggunakan emulator QEMU.

Seluruh pengujian menunjukkan hasil yang sesuai, mulai dari pemeriksaan struktur ELF, proses build, audit kernel, hingga keluaran melalui serial console. Dengan demikian, lingkungan pengembangan telah memenuhi persyaratan untuk melanjutkan implementasi pada milestone berikutnya.

---

# 19. Lampiran

Lampiran yang disertakan sebagai bukti pengerjaan praktikum M2 meliputi:

| No | Lampiran |
|----|----------|
| 1 | Screenshot proses build |
| 2 | Screenshot hasil `make all` |
| 3 | Screenshot hasil `make inspect` |
| 4 | Screenshot hasil `make audit` |
| 5 | Screenshot kernel berjalan pada QEMU |
| 6 | Screenshot serial console |
| 7 | Screenshot repository GitHub |
| 8 | Screenshot commit M2 |

Seluruh lampiran disimpan sebagai evidence pendukung laporan.

---

# 20. Daftar Referensi

1. Intel Corporation. *Intel® 64 and IA-32 Architectures Software Developer's Manual*.
2. QEMU Project Documentation.
3. Limine Bootloader Documentation.
4. LLVM Project Documentation.
5. GNU Make Documentation.
6. Panduan Praktikum MCSOS Milestone M2.

---

# 21. Checklist Pengumpulan

| No | Item | Status |
|----|------|--------|
| 1 | Repository GitHub | ✓ |
| 2 | Branch M2 | ✓ |
| 3 | Commit M2 | ✓ |
| 4 | Laporan Markdown | ✓ |
| 5 | Screenshot Evidence | ✓ |
| 6 | Build Log | ✓ |
| 7 | Serial Log | ✓ |
| 8 | Audit Log | ✓ |

---

# 22. Pernyataan Pengumpulan

Saya menyatakan bahwa seluruh proses implementasi pada milestone M2 telah dikerjakan sesuai dengan panduan praktikum. Seluruh bukti pengujian, log build, evidence, dan repository yang dilampirkan merupakan hasil pengerjaan sendiri serta telah diverifikasi sebelum dikumpulkan.

Apabila di kemudian hari ditemukan kesalahan atau ketidaksesuaian, saya bersedia melakukan perbaikan sesuai dengan arahan dosen pengampu.

---

# Selesai