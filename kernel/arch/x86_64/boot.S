.section .multiboot2,"a"
.align 8
mb2_start:
.long 0xe85250d6
.long 0
.long mb2_end - mb2_start
.long -(0xe85250d6 + 0 + (mb2_end - mb2_start))
.short 0; .short 0; .long 8
mb2_end:
.section .bss
.align 16
.space 16384
stack_top:
.section .text
.global _start
.code64
_start:
    lea stack_top(%rip),%rsp
    call kmain
1:  hlt; jmp 1b
