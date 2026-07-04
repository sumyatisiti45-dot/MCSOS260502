# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS-M0

**Nama file laporan:** `laporan_praktikum_[kode_praktikum]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  

---

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M0 |
| Judul praktikum | Baseline Requirements, Governance, dan Lingkungan Pengembangan Reproducible MCSOS 260502 |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1B |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | 2026-05-04 |
| Tanggal pengumpulan | 2026-05-09 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | m0 |
| Commit awal | c003d57 |
| Commit akhir | fd838b2 |
| Status readiness yang diklaim | Siap melanjutkan ke M1 |

---

# 1. Sampul

# Laporan Praktikum M0

## Baseline Requirements, Governance, dan Lingkungan Pengembangan Reproducible MCSOS 260502

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1B PTI | Individu |

**Dosen Pengampu:** Muhaemin Sidiq, S.Pd., M.Pd.

**Program Studi Pendidikan Teknologi Informasi**  
**Institut Pendidikan Indonesia**

**2026**

---

## 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan praktikum M0 ini merupakan hasil pekerjaan praktikum yang saya kerjakan sendiri berdasarkan panduan praktikum MCSOS. Seluruh proses instalasi, konfigurasi lingkungan pengembangan, pembuatan repository, pengujian toolchain, serta dokumentasi dilakukan menggunakan komputer pribadi dengan lingkungan Windows 11 dan WSL2 Ubuntu.

Apabila dalam proses pengerjaan menggunakan referensi seperti dokumentasi resmi LLVM, Ubuntu, Git, QEMU, Microsoft WSL, maupun bantuan AI sebagai pendamping belajar, seluruh hasil tetap diverifikasi kembali melalui pengujian langsung pada lingkungan praktikum sebelum dicantumkan ke dalam laporan ini.

---

## 3. Tujuan Praktikum

Praktikum M0 bertujuan membangun lingkungan pengembangan yang dapat direproduksi sebagai dasar pengembangan sistem operasi MCSOS.

Tujuan yang ingin dicapai adalah:

1. Menginstal dan mengonfigurasi Windows Subsystem for Linux (WSL2) sebagai lingkungan pengembangan.
2. Menyiapkan repository MCSOS pada filesystem Linux.
3. Menginstal toolchain pengembangan seperti Clang, LLD, Git, Make, NASM, QEMU, dan GDB.
4. Melakukan verifikasi bahwa seluruh tool dapat digunakan dengan benar.
5. Menyiapkan struktur repository, dokumen awal, serta sistem version control menggunakan Git.
6. Menghasilkan baseline yang siap digunakan pada praktikum M1.

---

## 4. Capaian Pembelajaran Praktikum

Setelah menyelesaikan praktikum ini, mahasiswa diharapkan mampu:

| CPL/CPMK | Bukti |
|---|---|
| Menggunakan WSL2 sebagai lingkungan pengembangan | WSL Ubuntu berhasil dijalankan |
| Menginstal toolchain pengembangan sistem operasi | Clang, Git, Make, NASM, QEMU, dan GDB berhasil terpasang |
| Membuat repository Git | Repository berhasil dibuat dan memiliki commit awal |
| Memahami struktur awal proyek MCSOS | Struktur direktori berhasil dibuat |
| Memverifikasi toolchain menggunakan command Linux | Seluruh command berhasil dijalankan |

---

## 5. Peta Milestone MCSOS

| Milestone | Fokus | Status |
|---|---|---|
| M0 | Baseline Requirements dan Environment | ✅ Selesai |
| M1 | Toolchain Reproducible | Belum |
| M2 | Boot Image | Belum |
| M3 | Panic dan Debug | Belum |
| M4 | IDT dan Exception | Belum |
| M5 | Timer dan IRQ | Belum |
| M6 | Physical Memory Manager | Belum |
| M7 | Virtual Memory Manager | Belum |
| M8 | Kernel Heap | Belum |
| M9 | Scheduler | Belum |
| M10 | Syscall | Belum |
| M11 | ELF Loader | Belum |
| M12 | Synchronization | Belum |
| M13 | VFS | Belum |
| M14 | Block Device | Belum |
| M15 | MCSFS1 | Belum |
| M16 | Journal Recovery | Belum |

---

## 6. Dasar Teori

Praktikum M0 merupakan tahap awal pengembangan sistem operasi MCSOS. Fokus utama praktikum ini bukan membangun kernel, melainkan memastikan lingkungan pengembangan telah siap digunakan untuk seluruh milestone berikutnya.

Lingkungan pengembangan menggunakan Windows 11 sebagai host operating system dan Ubuntu WSL2 sebagai build environment. Seluruh source code disimpan pada filesystem Linux agar proses build berjalan konsisten dan tidak dipengaruhi oleh perbedaan permission maupun line ending pada Windows.

Toolchain yang digunakan terdiri dari Clang sebagai compiler, LLD sebagai linker, GNU Binutils untuk inspeksi file ELF, NASM untuk assembly x86-64, Git sebagai version control, Make sebagai build system, serta QEMU sebagai emulator target x86_64.

Dengan lingkungan yang telah tervalidasi, seluruh praktikum berikutnya dapat dikerjakan secara reproducible sehingga hasil build dan pengujian dapat direproduksi pada komputer lain yang memiliki konfigurasi serupa.
---

# 7. Lingkungan Praktikum

## 7.1 Perangkat Keras

Praktikum dilaksanakan menggunakan komputer pribadi dengan spesifikasi yang memenuhi kebutuhan pengembangan sistem operasi berbasis x86_64.

| Komponen | Keterangan |
|---|---|
| Sistem Operasi Host | Windows 11 64-bit |
| Virtualisasi | WSL2 |
| Distribusi Linux | Ubuntu LTS |
| Arsitektur Target | x86_64 |
| Penyimpanan Source | Filesystem Linux (~/src/mcsos) |

---

## 7.2 Perangkat Lunak

Lingkungan pengembangan menggunakan toolchain LLVM dan berbagai utilitas pendukung yang diperlukan selama praktikum.

| Software | Fungsi |
|---|---|
| Git | Version Control |
| Clang | Compiler C |
| LLD | Linker |
| Make | Build System |
| NASM | Assembler |
| LLVM Binutils | Readelf, Objdump, NM |
| QEMU | Emulator x86_64 |
| GDB | Debugger |
| Python 3 | Script Pendukung |

Seluruh tool berhasil dikenali oleh sistem dan siap digunakan pada praktikum berikutnya.

---

# 8. Struktur Repository

Repository MCSOS ditempatkan pada filesystem Linux agar proses build bersifat reproducible.

Direktori utama repository berada pada:

```text
~/src/mcsos
```

Struktur direktori utama adalah sebagai berikut.

```text
mcsos/
├── artifacts/
├── build/
├── configs/
├── docs/
├── evidence/
├── fs/
├── include/
├── iso_root/
├── kernel/
├── logs/
├── scripts/
├── tests/
├── third_party/
├── Makefile
└── README.md
```

Struktur tersebut menjadi dasar pengembangan seluruh milestone MCSOS berikutnya.

---

# 9. Konfigurasi Git

Repository diinisialisasi menggunakan Git untuk mendokumentasikan seluruh perkembangan praktikum.

Konfigurasi yang dilakukan meliputi:

- Inisialisasi repository.
- Penambahan remote GitHub.
- Pembuatan branch praktikum.
- Commit perubahan.
- Push ke repository GitHub.

Repository GitHub:

```text
https://github.com/sumyatisiti45-dot/MCSOS260502
```

Branch M0:

```text
m0
```

Commit baseline:

```text
fd838b2
```

---

# 10. Langkah Pelaksanaan Praktikum

Tahapan pengerjaan praktikum M0 dilakukan secara berurutan sebagai berikut.

## 10.1 Menyiapkan Workspace

Workspace dibuat pada filesystem Linux WSL2.

```bash
mkdir -p ~/src
cd ~/src
```

Repository kemudian ditempatkan pada direktori tersebut.

---

## 10.2 Menyiapkan Repository

Repository MCSOS berhasil dibuat dan digunakan sebagai tempat seluruh source code praktikum.

Seluruh file dapat diakses melalui terminal Ubuntu.

---

## 10.3 Verifikasi Toolchain

Toolchain diverifikasi menggunakan beberapa command untuk memastikan seluruh software berhasil diinstal.

Contoh pengujian:

```bash
clang --version
git --version
make --version
nasm -v
qemu-system-x86_64 --version
python3 --version
```

Seluruh command berhasil dijalankan tanpa error.

---

## 10.4 Verifikasi Direktori

Repository diperiksa untuk memastikan struktur direktori sesuai dengan panduan praktikum.

Direktori seperti `kernel`, `docs`, `tests`, `scripts`, `build`, dan `evidence` berhasil dikenali.

---

# 11. Hasil Praktikum

Hasil yang diperoleh pada praktikum M0 adalah:

- Lingkungan WSL2 berhasil digunakan.
- Toolchain LLVM berhasil dipasang.
- Repository Git berhasil dibuat.
- Struktur project MCSOS telah lengkap.
- Source code berada pada filesystem Linux.
- Repository berhasil dihubungkan ke GitHub.
- Baseline M0 siap digunakan sebagai dasar pengerjaan milestone berikutnya.

Status akhir praktikum:

**M0 berhasil diselesaikan dan lingkungan pengembangan siap digunakan untuk M1.**
---

# 12. Analisis Hasil Praktikum

Praktikum M0 merupakan tahapan awal dalam pengembangan sistem operasi MCSOS. Pada tahap ini belum dilakukan pengembangan kernel, melainkan mempersiapkan lingkungan kerja agar seluruh milestone berikutnya dapat dikerjakan secara konsisten dan dapat direproduksi.

Berdasarkan hasil pengujian, seluruh tool utama berhasil digunakan tanpa mengalami kegagalan. Repository berhasil dibuat pada filesystem Linux WSL2 sehingga proses build tidak dipengaruhi oleh perbedaan filesystem Windows.

Penggunaan Git sejak awal praktikum mempermudah pengelolaan perubahan source code dan dokumentasi perkembangan setiap milestone. Dengan adanya repository GitHub, seluruh pekerjaan dapat dicadangkan dan dikembangkan menggunakan branch terpisah.

Lingkungan pengembangan yang telah berhasil disiapkan menjadi fondasi utama untuk melanjutkan praktikum M1 sampai M16.

---

# 13. Kendala yang Ditemui

Selama pengerjaan praktikum terdapat beberapa kendala, antara lain:

1. Penyesuaian penggunaan terminal Linux pada WSL2.
2. Proses instalasi beberapa toolchain membutuhkan waktu karena harus mengunduh paket dari repository Ubuntu.
3. Penyesuaian struktur direktori repository agar sesuai dengan panduan praktikum.
4. Verifikasi beberapa command memerlukan pengecekan ulang agar seluruh tool benar-benar tersedia.

Seluruh kendala tersebut dapat diselesaikan dengan melakukan pengecekan konfigurasi, instalasi ulang paket yang diperlukan, serta mengikuti panduan praktikum secara bertahap.

---

# 14. Validasi

Validasi dilakukan untuk memastikan lingkungan pengembangan telah memenuhi kebutuhan praktikum.

Checklist validasi:

| Pengujian | Status |
|-----------|--------|
| WSL2 berjalan | ✅ |
| Ubuntu dapat digunakan | ✅ |
| Git terpasang | ✅ |
| Clang terpasang | ✅ |
| LLD terpasang | ✅ |
| Make terpasang | ✅ |
| NASM terpasang | ✅ |
| Python3 tersedia | ✅ |
| QEMU tersedia | ✅ |
| Repository Git berhasil dibuat | ✅ |
| Repository GitHub berhasil digunakan | ✅ |

Hasil validasi menunjukkan seluruh komponen yang diperlukan telah tersedia.

---

# 15. Kesimpulan

Praktikum M0 berhasil dilaksanakan dengan baik. Lingkungan pengembangan sistem operasi MCSOS berhasil dipersiapkan menggunakan Windows 11 dan Ubuntu WSL2.

Seluruh toolchain berhasil diinstal dan diverifikasi sehingga dapat digunakan untuk proses kompilasi, debugging, maupun pengujian pada milestone berikutnya.

Repository Git berhasil dibuat dan dihubungkan dengan GitHub sehingga seluruh perkembangan praktikum dapat terdokumentasi dengan baik.

Dengan selesainya praktikum M0, lingkungan pengembangan dinyatakan siap digunakan untuk melanjutkan pengerjaan praktikum M1.

---

# 16. Daftar Pustaka

1. LLVM Project. *Clang Documentation*. https://clang.llvm.org/docs/

2. GNU Project. *GNU Make Manual*. https://www.gnu.org/software/make/

3. Git Documentation. https://git-scm.com/docs

4. Microsoft. *Windows Subsystem for Linux Documentation*. https://learn.microsoft.com/windows/wsl/

5. QEMU Project Documentation. https://www.qemu.org/docs/

6. NASM Documentation. https://www.nasm.us/

7. Panduan Praktikum Sistem Operasi Lanjut MCSOS 260502 Milestone M0.

---

# Lampiran

## Lampiran A — Bukti Repository GitHub

Repository praktikum:

```
https://github.com/sumyatisiti45-dot/MCSOS260502
```

Branch yang digunakan:

```
m0
```

Commit terakhir:

```
fd838b2
```

---

## Lampiran B — Dokumentasi

Lampiran berisi:

- Screenshot terminal WSL2.
- Screenshot hasil instalasi toolchain.
- Screenshot repository GitHub.
- Screenshot struktur repository.
- Screenshot commit Git.
- Screenshot branch M0.

---

## Lampiran C — Status Akhir Praktikum

| Item | Status |
|------|--------|
| Repository dibuat | ✅ |
| Toolchain terpasang | ✅ |
| Build environment siap | ✅ |
| GitHub berhasil digunakan | ✅ |
| Branch M0 tersedia | ✅ |
| Siap melanjutkan M1 | ✅ |
---

# 17. Failure Modes dan Prosedur Rollback

| Failure Mode | Gejala | Penyebab | Penanganan |
|--------------|---------|----------|------------|
| WSL2 belum aktif | Perintah `wsl` tidak dikenali | Fitur Windows belum diaktifkan | Mengaktifkan fitur WSL kemudian restart komputer. |
| Toolchain belum tersedia | `command not found` | Paket belum terinstal | Melakukan instalasi menggunakan `apt install` kemudian memverifikasi kembali. |
| Repository berada di `/mnt/c` | Script validasi memberi peringatan | Repository dibuat pada filesystem Windows | Memindahkan repository ke `~/src/mcsos`. |
| Git belum dikonfigurasi | Commit gagal | `user.name` atau `user.email` belum diatur | Mengatur identitas Git menggunakan `git config --global`. |
| Smoke test gagal | Object tidak terbentuk | Target compiler atau flag salah | Memperbaiki konfigurasi compiler kemudian menjalankan ulang proses build. |

Seluruh kendala yang muncul selama praktikum berhasil diselesaikan sehingga baseline M0 dapat diselesaikan dengan baik.

---

# 18. Readiness Review M0

| Area | Evidence | Status | Catatan |
|------|----------|--------|---------|
| WSL2 | `wsl --list --verbose` | PASS | Ubuntu berjalan pada WSL2 |
| Repository | `pwd` | PASS | Repository berada di `~/src/mcsos` |
| Toolchain | `tools/check_env.sh` | PASS | Tool utama tersedia |
| Metadata | `build/meta/toolchain-versions.txt` | PASS | Metadata berhasil dibuat |
| Smoke Test | `make smoke` | PASS | Object ELF64 berhasil dibuat |
| Documentation | Direktori `docs/` | PASS | Dokumen baseline tersedia |
| Threat Model | `docs/security/threat_model.md` | PASS | Dokumen tersedia |
| Risk Register | `docs/governance/risk_register.md` | PASS | Dokumen tersedia |
| Verification Matrix | `docs/testing/verification_matrix.md` | PASS | Dokumen tersedia |
| Git Traceability | `git log --oneline` | PASS | Commit baseline tersedia |

### Kesimpulan Readiness

Praktikum M0 dinyatakan **lulus** sebagai baseline lingkungan pengembangan dan governance. Lingkungan dinyatakan **siap melanjutkan ke M1**, namun belum mengklaim sistem operasi telah bootable atau siap produksi.

---

# 19. Jawaban Pertanyaan Analisis

### 1. Mengapa repository tidak disarankan berada di `/mnt/c`?

Karena filesystem Linux pada WSL2 memberikan kompatibilitas yang lebih baik terhadap permission, performa, dan case-sensitive dibandingkan filesystem Windows.

### 2. Apa perbedaan host, build environment, dan target?

Host merupakan sistem operasi yang digunakan pengguna (Windows 11). Build environment adalah Ubuntu pada WSL2 tempat proses kompilasi dilakukan. Target adalah arsitektur x86_64 yang akan menjalankan kernel MCSOS.

### 3. Mengapa compiler harus menggunakan target eksplisit?

Agar object yang dihasilkan sesuai dengan arsitektur kernel dan tidak bergantung pada konfigurasi compiler host.

### 4. Apa arti ELF64 relocatable?

Menunjukkan bahwa file object berhasil dikompilasi sebagai object 64-bit yang masih memerlukan proses linking sebelum menjadi executable kernel.

### 5. Mengapa menggunakan `-mno-red-zone`?

Karena kernel tidak menggunakan red zone seperti aplikasi user space sehingga interrupt tidak merusak data pada stack.

### 6. Mengapa M0 belum boleh disebut siap boot?

Karena pada M0 belum dilakukan proses pembuatan maupun pengujian kernel bootable. Tahap ini hanya menyiapkan lingkungan pengembangan.

### 7. Apa fungsi pencatatan versi toolchain?

Untuk memastikan proses build dapat direproduksi menggunakan versi tool yang sama.

### 8. Apa risiko jika versi toolchain tidak dicatat?

Hasil kompilasi dapat berbeda pada komputer lain sehingga menyulitkan proses debugging dan reproduksi hasil.

### 9. Mengapa threat model diperlukan?

Agar risiko keamanan dapat diidentifikasi sejak awal sebelum sistem berkembang menjadi lebih kompleks.

### 10. Requirement mana yang paling sulit diverifikasi?

Verifikasi reproducibility toolchain karena memerlukan pemeriksaan terhadap banyak komponen secara bersamaan.

### 11. Apa rollback jika smoke test gagal?

Memeriksa kembali target compiler, konfigurasi build, kemudian mengulang proses kompilasi hingga menghasilkan object ELF64 yang benar.

### 12. Bagaimana pembagian peran memengaruhi kualitas proyek?

Pembagian peran membantu proses pengembangan lebih terstruktur, meningkatkan kualitas dokumentasi, pengujian, dan integrasi repository.

---

# 20. Penutup

Seluruh tujuan praktikum M0 berhasil dicapai. Lingkungan pengembangan, repository, toolchain, dokumentasi awal, dan evidence telah tersedia sehingga milestone berikutnya dapat dikerjakan pada lingkungan yang konsisten dan terdokumentasi dengan baik.