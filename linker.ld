OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

KERNEL_PHYS_BASE = 0x200000;
KERNEL_VIRT_BASE = 0xffffffff80000000;

SECTIONS
{
    . = KERNEL_VIRT_BASE;

    __kernel_start = .;

    .multiboot2 : ALIGN(8)   { *(.multiboot2) }
    .text       : ALIGN(4096){ *(.text .text.*) }
    .rodata     : ALIGN(4096){ *(.rodata .rodata.*) }
    .data       : ALIGN(4096){ *(.data .data.*) }
    .bss        : ALIGN(4096){
        *(COMMON)
        *(.bss .bss.*)
        . = ALIGN(16);
        . += 65536;
        stack_top = .;
    }

    __kernel_end = .;
}
