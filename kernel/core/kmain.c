#include <stdint.h>
#include <mcsos/arch/cpu.h>
#include <mcsos/arch/idt.h>
#include <mcsos/arch/pic.h>
#include <mcsos/arch/pit.h>
#include <mcsos/kernel/log.h>
#include <mcsos/kernel/panic.h>
#include <mcsos/kernel/version.h>
#include "pmm.h"

extern char __kernel_start[];
extern char __kernel_end[];

static struct pmm_state kernel_pmm;
static uint8_t kernel_pmm_bitmap[PMM_BITMAP_BYTES] __attribute__((aligned(4096)));

static void m6_pmm_init(void) {
    struct boot_mem_region regions[] = {
        { .base = 0x00000000ULL, .length = 0x0009f000ULL, .type = BOOT_MEM_USABLE },
        { .base = 0x0009f000ULL, .length = 0x00001000ULL, .type = BOOT_MEM_RESERVED },
        { .base = 0x00100000ULL, .length = 0x00300000ULL, .type = BOOT_MEM_USABLE },
        { .base = (uint64_t)(uintptr_t)__kernel_start,
          .length = (uint64_t)((uintptr_t)__kernel_end - (uintptr_t)__kernel_start),
          .type = BOOT_MEM_KERNEL_AND_MODULES },
        { .base = 0x00500000ULL, .length = 0x00400000ULL, .type = BOOT_MEM_USABLE },
    };

    bool ok = pmm_init_from_map(&kernel_pmm,
                                regions,
                                sizeof(regions) / sizeof(regions[0]),
                                kernel_pmm_bitmap,
                                sizeof(kernel_pmm_bitmap),
                                PMM_MAX_PHYS_BYTES);
    if (!ok) {
        KERNEL_PANIC("pmm_init_from_map failed", 0x6D6D70ULL);
    }

    log_writeln("[m6] pmm initialized");
    log_key_value_hex64("frames_managed", pmm_frame_count(&kernel_pmm));
    log_key_value_hex64("frames_free", pmm_free_count(&kernel_pmm));

    uint64_t f = pmm_alloc_frame(&kernel_pmm);
    if (f == PMM_INVALID_FRAME) {
        KERNEL_PANIC("pmm_alloc_frame failed", 0x6D6D70ULL);
    }
    log_key_value_hex64("[m6] sample_frame", f);

    if (!pmm_free_frame(&kernel_pmm, f)) {
        KERNEL_PANIC("pmm_free_frame failed", 0x6D6D70ULL);
    }
    log_writeln("[m6] alloc/free OK");
}

static void m4_selftest(void) {
    KERNEL_ASSERT(__kernel_end > __kernel_start);
    KERNEL_ASSERT(sizeof(uintptr_t) == 8u);
    KERNEL_ASSERT(sizeof(x86_64_idt_entry_t) == 16u);
    KERNEL_ASSERT(x86_64_idt_base_for_test() != 0u);
    KERNEL_ASSERT(x86_64_idt_limit_for_test() == 4095u);
    log_writeln("[M4] selftest: IDT invariants passed");
}

void kmain(void) {
    log_init();
    log_write(MCSOS_NAME);
    log_write(" ");
    log_write(MCSOS_VERSION);
    log_write(" ");
    log_write(MCSOS_MILESTONE);
    log_writeln(" kernel entered");
    log_key_value_hex64("kernel_start", (uint64_t)(uintptr_t)__kernel_start);
    log_key_value_hex64("kernel_end",   (uint64_t)(uintptr_t)__kernel_end);
    log_key_value_hex64("rflags_before_idt", cpu_read_rflags());

    log_writeln("[MCSOS:M5] boot: external interrupt bring-up start");
    x86_64_idt_init();
    log_writeln("[MCSOS:M5] idt: loaded");
    pic_remap();
    pic_mask_all();
    log_writeln("[MCSOS:M5] pic: remapped; mask master=0xFF slave=0xFF");
    pic_unmask_irq(0);
    log_writeln("[MCSOS:M5] pit: configured 100Hz");
    pit_configure_hz(100);
    log_writeln("[MCSOS:M5] sti: enabling interrupts");
    __asm__ volatile("sti");

    m4_selftest();
    m6_pmm_init();

#ifdef MCSOS_M4_TRIGGER_BREAKPOINT
    log_writeln("[M4] triggering intentional breakpoint exception");
    x86_64_trigger_breakpoint_for_test();
    log_writeln("[M4] returned from breakpoint handler");
#endif

#ifdef MCSOS_M4_TRIGGER_PANIC
    KERNEL_PANIC("intentional M4 panic test", 0x4D43534F533034u);
#else
    log_writeln("[M4] IDT and exception dispatch path installed");
    log_writeln("[M4] ready for QEMU smoke test and GDB audit");
    for (;;) {
        __asm__ volatile("hlt");
    }
#endif
}
