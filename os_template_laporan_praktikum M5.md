# Template Laporan Praktikum Sistem Operasi Lanjut — MCSOS

**Nama file laporan:** `laporan_praktikum_[M5]_[nim_atau_kelompok].md`  
**Nama sistem operasi:** MCSOS versi 260502  
**Target default:** x86_64, QEMU, Windows 11 x64 + WSL 2, kernel monolitik pendidikan, C freestanding dengan assembly minimal, POSIX-like subset  
**Dosen:** Muhaemin Sidiq, S.Pd., M.Pd.  
**Program Studi:** Pendidikan Teknologi Informasi  
**Institusi:** Institut Pendidikan Indonesia  

---

## 0. Metadata Laporan

| Atribut | Isi |
|---|---|
| Kode praktikum | M5 |
| Judul praktikum | External Interrupt, Legacy PIC Remap, dan PIT Timer Tick pada MCSOS |
| Jenis pengerjaan | Individu |
| Nama mahasiswa | Siti Sumyati |
| NIM | 2583207073008 |
| Kelas | 1b |
| Nama kelompok | - |
| Anggota kelompok | - |
| Tanggal praktikum | 2026-06-28 |
| Tanggal pengumpulan | 2026-06-28 |
| Repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum/m5-timer-irq |
| Commit awal | `e55887b` |
| Commit akhir | `213d8e6` |
| Status readiness yang diklaim | siap uji QEMU |

---

## 1. Sampul

# Laporan Praktikum M5
## External Interrupt, Legacy PIC Remap, dan PIT Timer Tick pada MCSOS

Disusun oleh:

| Nama | NIM | Kelas | Peran |
|---|---|---|---|
| Siti Sumyati | 2583207073008 | 1b | individu |

Dosen Pengampu: **Muhaemin Sidiq, S.Pd., M.Pd.**
Program Studi Pendidikan Teknologi Informasi
Institut Pendidikan Indonesia
Tahun Akademik 2025/2026

---

## 2. Pernyataan Orisinalitas dan Integritas Akademik

Saya menyatakan bahwa laporan ini disusun berdasarkan pekerjaan praktikum sendiri. Bantuan eksternal, referensi, dokumentasi resmi, dan AI assistant dicatat pada bagian referensi dan lampiran.

| Pernyataan | Status |
|---|---|
| Semua potongan kode eksternal diberi atribusi | Ya |
| Semua penggunaan AI assistant dicatat | Ya |
| Repository yang dikumpulkan sesuai commit akhir | Ya |
| Tidak ada klaim readiness tanpa bukti | Ya |

Catatan penggunaan bantuan eksternal:

```text
Menggunakan AI assistant (Claude) untuk membantu debug masalah boot (Limine protocol vs Multiboot2,
GRUB segment crosses 4GiB), troubleshooting QEMU, dan penyusunan laporan. Seluruh kode diverifikasi
mandiri melalui make grade, QEMU smoke test, dan GDB session.
```

---

## 3. Tujuan Praktikum

1. Mengimplementasikan remap legacy PIC 8259A ke vector 0x20..0x2F agar tidak tumpang tindih dengan exception CPU
2. Mengonfigurasi PIT 8254 channel 0 pada frekuensi 100 Hz menggunakan divisor 11931 dan command word 0x36
3. Memperluas trap dispatcher M4 untuk membedakan IRQ hardware dari exception CPU
4. Membuktikan tick timer periodik IRQ0 melalui serial log QEMU dan GDB breakpoint

---

## 4. Capaian Pembelajaran Praktikum

| CPL/CPMK praktikum | Bukti yang ditunjukkan |
|---|---|
| Menjelaskan perbedaan exception CPU dan external hardware interrupt | Analisis di bagian dasar teori dan failure mode |
| Mengimplementasikan PIC remap ICW1-ICW4 | pic.c, serial log: `pic: remapped` |
| Mengonfigurasi PIT channel 0 100 Hz | pit.c, serial log: `pit: configured 100Hz` |
| Memperluas IDT hingga vector 47 | isr.S, symbols.txt: isr_stub_32..47 |
| Membuktikan tick periodik dengan EOI benar | Serial log: `[MCSOS:TIMER] ticks=0x64, 0xc8, ...` |
| Menggunakan GDB untuk debug interrupt | GDB session: breakpoint trap_dispatch hit periodik |

---

## 5. Peta Milestone MCSOS

| Milestone | Fokus | Status dalam laporan |
|---|---|---|
| M0 | Requirements, governance, baseline arsitektur | selesai praktikum |
| M1 | Toolchain reproducible, Git, QEMU, GDB | selesai praktikum |
| M2 | Boot image, kernel ELF64, early console | selesai praktikum |
| M3 | Panic path, linker map, GDB, observability awal | selesai praktikum |
| M4 | IDT, exception stubs, trap dispatcher | selesai praktikum |
| M5 | External interrupt, PIC remap, PIT timer tick | selesai praktikum |

Batas cakupan praktikum:

```text
M5 mencakup: PIC remap, PIT 100Hz, IRQ0 handler, EOI, IDT vector 32-47.
Non-goals: APIC, IOAPIC, HPET, LAPIC timer, SMP, preemptive scheduler, user mode.
```

---

## 6. Dasar Teori Ringkas

### 6.1 Konsep Sistem Operasi yang Diuji

```text
External Interrupt: interrupt yang berasal dari perangkat keras eksternal melalui PIC,
berbeda dari exception CPU yang dibangkitkan oleh kondisi error prosesor.

PIC (Programmable Interrupt Controller) 8259A: mengatur routing IRQ hardware ke vector IDT.
Secara default IRQ0-7 dipetakan ke vector 8-15 yang tumpang tindih dengan exception CPU (0-31),
sehingga perlu diremap ke vector 0x20-0x2F.

PIT (Programmable Interval Timer) 8254: menghasilkan interrupt periodik melalui channel 0.
Frekuensi dasar 1.193.182 Hz, divisor = 1193182/100 = 11931 untuk 100 Hz.

EOI (End-of-Interrupt): sinyal yang harus dikirim ke PIC setelah setiap IRQ ditangani,
agar PIC dapat menerima dan meneruskan interrupt berikutnya.
```

### 6.2 Konsep Arsitektur x86_64 yang Relevan

| Konsep | Relevansi pada praktikum | Bukti/verifikasi |
|---|---|---|
| IDT (Interrupt Descriptor Table) | Memetakan vector 0-47 ke handler stub | readelf, objdump: lidt, iretq |
| Port I/O (inb/outb) | Komunikasi dengan PIC dan PIT | disassembly.txt: outb |
| IRQ vector remapping | PIC dipindah ke 0x20-0x2F | serial log: pic remapped |
| cli/sti | Mengontrol kapan interrupt diaktifkan | kernel.c: urutan boot |
| iretq | Kembali dari interrupt handler | disassembly.txt: iretq |

### 6.3 Konsep Implementasi Freestanding

| Aspek | Keputusan praktikum |
|---|---|
| Bahasa | C17 freestanding + assembly AT&T |
| Runtime | tanpa hosted libc (nm -u kosong) |
| ABI | x86_64 System V |
| Compiler flags kritis | -ffreestanding -mno-red-zone -nostdlib -mcmodel=kernel |
| Risiko undefined behavior | volatile untuk g_ticks, cli/sti ordering |

### 6.4 Referensi Teori yang Digunakan

| No. | Sumber | Bagian yang digunakan | Alasan relevansi |
|---|---|---|---|
| [1] | Intel SDM | Vol. 3A, Ch. 6: Interrupt and Exception Handling | IDT, iretq, interrupt flag |
| [2] | Intel 8259A Datasheet | ICW1-ICW4, OCW | PIC remap implementation |
| [3] | Intel 8254 Datasheet | Counter modes, command word | PIT configuration |
| [4] | QEMU Documentation | Invocation, GDB usage | QEMU flags, gdbstub |

---

## 7. Lingkungan Praktikum

### 7.1 Host dan Target

| Komponen | Nilai |
|---|---|
| Host OS | Windows 11 x64 |
| Lingkungan build | WSL 2 Ubuntu 24.04 |
| Target ISA | x86_64 |
| Target ABI | x86_64-unknown-none-elf |
| Emulator | QEMU system x86_64 |
| Firmware emulator | OVMF (/usr/share/ovmf/OVMF.fd) |
| Debugger | GDB 15.1 |
| Build system | Make |
| Bahasa utama | C17 freestanding |
| Assembly | GAS (AT&T syntax via Clang) |

### 7.2 Versi Toolchain

```text
clang version 18.x (target x86_64-unknown-none-elf)
ld.lld 18.x
GNU Make 4.3
QEMU 8.x (qemu-system-x86_64)
GDB 15.1 (Ubuntu 15.1-1ubuntu1~24.04.1)
```

### 7.3 Lokasi Repository

| Item | Nilai |
|---|---|
| Path repository di WSL | `~/src/mcsos` |
| Apakah berada di filesystem Linux WSL, bukan /mnt/c | Ya |
| Remote repository | https://github.com/sumyatisiti45-dot/MCSOS260502 |
| Branch | praktikum/m5-timer-irq |
| Commit hash awal | `e55887b` |
| Commit hash akhir | `213d8e6` |

---

## 8. Repository dan Struktur File

### 8.1 Struktur Direktori yang Relevan

```text
mcsos/
├── kernel/
│   ├── arch/x86_64/
│   │   ├── boot.S         # entry point _start, Multiboot2 header
│   │   ├── isr.S          # ISR stubs vector 0-47, isr_common_stub
│   │   ├── idt.c          # IDT init, trap dispatcher
│   │   ├── pic.c          # PIC remap, mask, unmask, EOI
│   │   └── pit.c          # PIT configure, timer_on_irq0
│   ├── core/
│   │   ├── kmain.c        # urutan boot M5
│   │   ├── serial.c       # serial output
│   │   └── panic.c        # kernel panic path
│   └── include/mcsos/
├── linker.ld              # higher-half kernel layout
├── Makefile
├── configs/limine/limine.conf
├── evidence/M5/           # semua bukti M5
└── docs/reports/          # laporan ini
```

---

## 9. Desain dan Arsitektur M5

### 9.1 State Machine Boot

```text
BOOT_EARLY -> SERIAL_READY -> IDT_READY -> PIC_REMAP_MASKED
-> PIT_CONFIGURED -> IRQ0_UNMASKED -> INTERRUPTS_ENABLED -> TICKING
```

### 9.2 Alur IRQ0

```text
PIT channel 0 --IRQ0--> PIC master IR0 --vector 0x20--> IDT[32]
    -> isr_stub_32 -> isr_common_stub -> x86_64_trap_dispatch()
    -> timer_on_irq0() -> pic_send_eoi(0)
```

### 9.3 Invariants

| Invariant | Cara Uji |
|---|---|
| IDT dimuat sebelum sti | Urutan log: idt loaded sebelum sti |
| PIC diremap ke 0x20/0x28 | Serial log: pic remapped |
| IRQ selain IRQ0 tetap masked | pic_mask_all() sebelum unmask_irq(0) |
| EOI dikirim setelah setiap IRQ | Tick berlanjut periodik |
| Tidak ada libc host | nm -u kosong |

---

## 10. Implementasi

### 10.1 Urutan Boot di kmain

```c
cpu_cli();
serial_init();
x86_64_idt_init();
pic_remap();
pic_mask_all();
pic_unmask_irq(0);
pit_configure_hz(100);
cpu_sti();
for (;;) { cpu_hlt(); }
```

### 10.2 PIC Remap (ICW1-ICW4)

```c
outb(PIC1_COMMAND, 0x11); // ICW1: cascade, ICW4 needed
outb(PIC2_COMMAND, 0x11);
outb(PIC1_DATA, 0x20);    // ICW2: master offset 0x20
outb(PIC2_DATA, 0x28);    // ICW2: slave offset 0x28
outb(PIC1_DATA, 0x04);    // ICW3: slave at IR2
outb(PIC2_DATA, 0x02);    // ICW3: cascade identity
outb(PIC1_DATA, 0x01);    // ICW4: 8086 mode
outb(PIC2_DATA, 0x01);
```

### 10.3 PIT Konfigurasi 100 Hz

```c
uint32_t divisor = 1193182 / 100; // = 11931
outb(PIT_COMMAND, 0x36);          // channel 0, lobyte/hibyte, mode 3
outb(PIT_CHANNEL0, divisor & 0xFF);
outb(PIT_CHANNEL0, (divisor >> 8) & 0xFF);
```

---

## 11. Hasil Uji

### 11.1 Build Grade

```text
make clean && make grade -> semua cek lulus, tidak ada error/warning
nm -u build/mcsos-m5.elf -> (kosong = tidak ada dependency host)
isr_stub_14, x86_64_exception_stubs, .text, .rodata -> ditemukan
```

### 11.2 Serial Log QEMU

```text
limine: Loading executable `boot():/boot/mcsos-m5.elf`...
MCSOS 260502 M3 kernel entered
kernel_start=0xffffffff80000000
kernel_end=0xffffffff8001a030
rflags_before_idt=0x0000000000000082
[MCSOS:M5] boot: external interrupt bring-up start
idt_base=0xffffffff80005000
idt_limit=0x0000000000000fff
[M4] IDT loaded
[MCSOS:M5] idt: loaded
[MCSOS:M5] pic: remapped; mask master=0xFF slave=0xFF
[MCSOS:M5] pit: configured 100Hz
[MCSOS:M5] sti: enabling interrupts
[M4] selftest: IDT invariants passed
[M4] IDT and exception dispatch path installed
[M4] ready for QEMU smoke test and GDB audit
[MCSOS:TIMER] ticks=0x0000000000000064
[MCSOS:TIMER] ticks=0x00000000000000c8
[MCSOS:TIMER] ticks=0x000000000000012c
[MCSOS:TIMER] ticks=0x0000000000000190
[MCSOS:TIMER] ticks=0x00000000000001f4
```

### 11.3 GDB Debug Session

```text
target remote :1234 -> connected at 0x000000000000fff0
break kmain           -> Breakpoint 1 at 0xffffffff80001570
break x86_64_idt_init -> Breakpoint 2 at 0xffffffff800010c0
break x86_64_trap_dispatch -> Breakpoint 3 at 0xffffffff80001d80

continue -> Breakpoint 1 hit: kmain
continue -> Breakpoint 2 hit: x86_64_idt_init
continue -> Breakpoint 3 hit: x86_64_trap_dispatch (IRQ0 periodik)

rip    = 0xffffffff80001d80 <x86_64_trap_dispatch>
rsp    = 0xffffffff80009f58
eflags = 0x96 [IOPL=0 SF AF PF]
```

---

## 12. Analisis Failure Mode

| Failure Mode | Gejala | Diagnosis | Mitigasi |
|---|---|---|---|
| IRQ sebelum IDT siap | Triple fault, QEMU reboot | GDB break _start | cli di awal, sti paling akhir |
| EOI tidak dikirim | Tick hanya sekali | Breakpoint setelah timer_on_irq0 | pic_send_eoi(irq) wajib dipanggil |
| IRQ0 masked | Tidak ada tick | Cetak mask PIC | pic_unmask_irq(0) setelah pic_mask_all |
| Protocol mismatch | Limine tidak load kernel | Lihat error Limine | Gunakan protocol: limine + UEFI OVMF |
| Segment crosses 4GiB | GRUB tidak load kernel | Error GRUB | Gunakan Limine UEFI bukan GRUB Multiboot2 |

---

## 13. Keamanan dan Reliability

| Aspek | Implementasi |
|---|---|
| Semua IRQ di-mask saat boot | pic_mask_all() dipanggil sebelum unmask |
| Hanya IRQ0 dibuka | pic_unmask_irq(0) saja |
| sti dipanggil paling akhir | Setelah IDT, PIC, PIT siap |
| Exception fatal tetap panic | x86_64_trap_dispatch: vector non-IRQ masuk panic |
| Tidak ada dependency host | nm -u kosong, -ffreestanding -nostdlib |

---

## 19. Kriteria Lulus Praktikum

| Kriteria minimum | Status | Evidence |
|---|---|---|
| Proyek dapat dibangun dari clean checkout | PASS | m5-build.log |
| Perintah build terdokumentasi | PASS | Makefile, laporan bagian 10 |
| QEMU boot dan timer tick berjalan | PASS | m5-qemu-serial.log |
| Serial log disimpan | PASS | evidence/M5/m5-qemu-serial.log |
| Panic path terbaca | PASS | panic.c, kernel_panic() |
| Tidak ada warning kritis pada build | PASS | m5-build.log |
| Perubahan Git terkomit | PASS | commit 213d8e6 |
| Desain dan failure mode dijelaskan | PASS | bagian 9 dan 12 |
| Disassembly/readelf evidence tersedia | PASS | evidence/M5/ |
| GDB debug session | PASS | evidence/M5/gdb-session.txt |

---

## 20. Readiness Review

| Status | Definisi | Pilihan |
|---|---|---|
| Belum siap uji | Build/test belum stabil | [ ] |
| Siap uji QEMU | Build bersih, QEMU berjalan, log tersedia | [x] |
| Siap demonstrasi praktikum | Siap ditunjukkan di kelas | [ ] |
| Kandidat siap pakai terbatas | Hanya untuk penggunaan terbatas | [ ] |

Alasan readiness:

```text
Build lulus make grade tanpa error. QEMU boot via Limine UEFI + OVMF menghasilkan
tick periodik IRQ0 yang terverifikasi di serial log. GDB breakpoint di kmain,
x86_64_idt_init, dan x86_64_trap_dispatch semua tercapai.
```

Known issues:

| No. | Issue | Dampak | Workaround | Target perbaikan |
|---|---|---|---|---|
| 1 | Boot hanya via Limine UEFI, tidak via GRUB Multiboot2 | Ketergantungan OVMF | Gunakan -bios /usr/share/ovmf/OVMF.fd | M6 |
| 2 | Tidak ada debug symbol (-g tidak dipakai) | GDB tidak menampilkan source | Gunakan nm untuk symbol address | M6 |

---

## 22. Kesimpulan

### 22.1 Yang Berhasil

```text
- PIC 8259A berhasil diremap ke vector 0x20/0x28
- PIT 8254 channel 0 dikonfigurasi 100 Hz (divisor 11931)
- IRQ0 masuk trap dispatcher secara periodik
- EOI dikirim dengan benar sehingga tick berlanjut
- Serial log menampilkan ticks=0x64, 0xc8, 0x12c, dst.
- GDB breakpoint di kmain, idt_init, trap_dispatch semua hit
- make grade lulus tanpa error/warning
- nm -u kosong (freestanding, tidak ada dependency host)
```

### 22.2 Yang Belum Berhasil

```text
- Boot via GRUB Multiboot2 tidak berhasil (segment crosses 4GiB border)
  karena kernel higher-half 0xffffffff80000000 tidak didukung GRUB Multiboot2
- Debug symbol belum diaktifkan sehingga GDB tidak menampilkan source code
```

### 22.3 Rencana Perbaikan

```text
- M6: Tambahkan -g untuk debug symbol agar GDB lebih informatif
- M6: Investigasi alternatif boot (Limine protocol native atau GRUB dengan relocation)
- M6: Implementasi scheduler tick berbasis g_ticks dari M5
```

---

## 23. Lampiran

### Lampiran A — Commit Log

```text
213d8e6 M5: update NIM dan kelas di laporan
bfb087a M5: laporan praktikum M5
bd9fc1f M5: force add serial log and build log as evidence
2ed06a6 M5: add manifest
a17dabd M5: evidence - build log, ELF audit, serial log, GDB session
4170782 M5: evidence GDB session - IRQ0 trap_dispatch confirmed periodic
e55887b Progress M5 before interrupt debugging
```

### Lampiran B — Serial Log Lengkap

```text
Lihat: evidence/M5/m5-qemu-serial.log
```

### Lampiran C — Build Log

```text
Lihat: evidence/M5/m5-build.log
```

### Lampiran D — ELF Audit

```text
Lihat: evidence/M5/readelf-header.txt
       evidence/M5/readelf-sections.txt
       evidence/M5/readelf-program-headers.txt
       evidence/M5/kernel.syms.txt
       evidence/M5/undefined.txt
       evidence/M5/kernel.disasm.txt
```

### Lampiran E — GDB Session

```text
Lihat: evidence/M5/gdb-session.txt
```

---

## 24. Daftar Referensi

```text
[1] Intel Corporation, Intel 64 and IA-32 Architectures Software Developer's Manual.
    Accessed: Jun. 28, 2026. [Online].
    Available: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

[2] Intel Corporation, 8259A Programmable Interrupt Controller Datasheet.
    Accessed: Jun. 28, 2026. [Online].
    Available: https://www.alldatasheet.com/datasheet-pdf/pdf/66107/INTEL/8259A.html

[3] Intel Corporation, 8254 Programmable Interval Timer Datasheet.
    Accessed: Jun. 28, 2026. [Online].
    Available: https://www.alldatasheet.com/datasheet-pdf/pdf/66099/INTEL/8254.html

[4] QEMU Project, "Invocation," QEMU Documentation.
    Accessed: Jun. 28, 2026. [Online].
    Available: https://www.qemu.org/docs/master/system/invocation.html

[5] QEMU Project, "GDB usage," QEMU Documentation.
    Accessed: Jun. 28, 2026. [Online].
    Available: https://www.qemu.org/docs/master/system/gdb.html
```

---

## 25. Checklist Final Sebelum Pengumpulan

| Checklist | Status |
|---|---|
| Semua placeholder sudah diganti | Ya |
| Metadata laporan lengkap | Ya |
| Commit awal dan akhir dicatat | Ya |
| Perintah build dan test dapat dijalankan ulang | Ya |
| Log build dilampirkan | Ya |
| Log QEMU/test dilampirkan | Ya |
| Desain, invariants, dan failure modes dijelaskan | Ya |
| Security/reliability dibahas | Ya |
| Readiness review tidak berlebihan | Ya |
| Referensi memakai format IEEE | Ya |
| Laporan disimpan sebagai Markdown | Ya |

---

## 26. Pernyataan Pengumpulan

```text
213d8e6
```

Status akhir yang diklaim:

```text
siap uji QEMU
```

Ringkasan:

```text
Praktikum M5 berhasil mengimplementasikan jalur external interrupt awal pada MCSOS x86_64.
PIC 8259A diremap ke vector 0x20/0x28, PIT 8254 dikonfigurasi 100 Hz, IRQ0 masuk dispatcher
secara periodik dengan EOI yang benar. Serial log QEMU menampilkan tick periodik dan GDB
memverifikasi semua breakpoint. Build lulus make grade tanpa error. Keterbatasan: boot hanya
via Limine UEFI (tidak via GRUB Multiboot2) karena kernel higher-half di atas 4GiB.
Status: siap uji QEMU untuk external interrupt dan PIT timer awal.
```
ENDOFFILE