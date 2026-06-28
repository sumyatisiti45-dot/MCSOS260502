# Laporan Praktikum M5
## External Interrupt, Legacy PIC Remap, dan PIT Timer Tick pada MCSOS

**Nama**          : Siti Sumyati
**NIM**           : 258320707
**Kelas**         : 1B
**Dosen**         : Muhaemin Sidiq, S.Pd., M.Pd.
**Program Studi** : Pendidikan Teknologi Informasi
**Institusi**     : Institut Pendidikan Indonesia
**Tanggal**       : 28 Juni 2026
**Branch Git**    : praktikum/m5-timer-irq
**Commit**        : bd9fc1f

---

## 1. Tujuan
1. Remap legacy PIC 8259A ke vector 0x20..0x2F
2. Konfigurasi PIT 8254 channel 0 frekuensi 100 Hz
3. Memperluas trap dispatcher M4 untuk membedakan IRQ dari exception
4. Membuktikan tick timer periodik melalui serial log QEMU

## 2. Dasar Teori
- **Exception vs IRQ**: Exception dibangkitkan CPU (vector 0-31), IRQ dari hardware eksternal via PIC (vector 32-47 setelah remap)
- **PIC Remap**: ICW1-ICW4 memindahkan IRQ0-7 ke 0x20-0x27 agar tidak tumpang tindih dengan exception
- **PIT Divisor**: `1193182 / 100 = 11931`, command word 0x36
- **EOI**: Harus dikirim setelah setiap IRQ agar PIC melanjutkan interrupt berikutnya

## 3. Lingkungan
| Komponen | Detail |
|---|---|
| Host | Windows 11 + WSL 2 Ubuntu 24.04 |
| Compiler | clang --target=x86_64-unknown-none-elf |
| Linker | ld.lld |
| Emulator | QEMU x86_64 + OVMF UEFI |
| Bootloader | Limine (protocol: limine) |
| Commit | bd9fc1f |

## 4. Desain
### Alur IRQ0
PIT -> PIC master IR0 -> vector 0x20 -> IDT[32] -> isr_stub_32

-> isr_common_stub -> x86_64_trap_dispatch -> timer_on_irq0 -> pic_send_eoi(0)
### Urutan Boot
cli -> serial_init -> idt_init -> pic_remap -> pic_mask_all

-> pic_unmask_irq(0) -> pit_configure_hz(100) -> sti -> hlt loop

## 5. Hasil Uji
### Serial Log QEMU
[MCSOS:M5] boot: external interrupt bring-up start

[MCSOS:M5] idt: loaded

[MCSOS:M5] pic: remapped; mask master=0xFF slave=0xFF

[MCSOS:M5] pit: configured 100Hz

[MCSOS:M5] sti: enabling interrupts

[MCSOS:TIMER] ticks=0x64

[MCSOS:TIMER] ticks=0xc8

[MCSOS:TIMER] ticks=0x12c
### GDB Session
Breakpoint kmain          @ 0xffffffff80001570 -> HIT

Breakpoint x86_64_idt_init @ 0xffffffff800010c0 -> HIT

Breakpoint x86_64_trap_dispatch @ 0xffffffff80001d80 -> HIT (periodik)

rip = 0xffffffff80001d80

rsp = 0xffffffff80009f58

## 6. Failure Mode dan Mitigasi
| Failure | Gejala | Mitigasi |
|---|---|---|
| IRQ sebelum IDT siap | Triple fault | cli di awal, sti paling akhir |
| EOI tidak dikirim | Tick hanya sekali | pic_send_eoi(irq) wajib dipanggil |
| IRQ0 masked | Tidak ada tick | pic_unmask_irq(0) setelah pic_mask_all |

## 7. Kesimpulan
M5 berhasil: PIC diremap, PIT 100Hz aktif, IRQ0 masuk dispatcher secara periodik, tick terverifikasi di serial log dan GDB. Status: **siap uji QEMU untuk external interrupt awal**.

## 8. Referensi
[1] Intel, *Intel 64 and IA-32 SDM*, 2026.
[2] Intel, *8259A PIC Datasheet*, 2026.
[3] Intel, *8254 PIT Datasheet*, 2026.
[4] QEMU Project, *QEMU Documentation*, 2026.
