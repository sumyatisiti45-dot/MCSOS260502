SHELL := /usr/bin/env bash

# Output paths
BUILD_DIR    := build

KERNEL       := $(BUILD_DIR)/mcsos-m5.elf
BP_KERNEL    := $(BUILD_DIR)/kernel.breakpoint.elf
PANIC_KERNEL := $(BUILD_DIR)/kernel.panic.elf

MAP          := $(BUILD_DIR)/mcsos-m5.map
BP_MAP       := $(BUILD_DIR)/kernel.breakpoint.map
PANIC_MAP    := $(BUILD_DIR)/kernel.panic.map

DISASM       := $(BUILD_DIR)/disassembly.txt
SYMS         := $(BUILD_DIR)/symbols.txt

# Toolchain
CC      := clang
LD      := ld.lld
OBJDUMP := objdump
READELF := readelf
NM      := nm

# Compiler flags
COMMON_CFLAGS := \
	--target=x86_64-unknown-none-elf \
	-std=c17 \
	-ffreestanding \
	-fno-builtin \
	-fno-stack-protector \
	-fno-stack-check \
	-fno-pic \
	-fno-pie \
	-fno-lto \
	-m64 \
	-march=x86-64 \
	-mabi=sysv \
	-mno-red-zone \
	-mno-mmx \
	-mno-sse \
	-mno-sse2 \
	-mcmodel=kernel \
	-Wall \
	-Wextra \
	-Werror \
	-Ikernel/arch/x86_64/include \
	-Ikernel/include

COMMON_ASFLAGS := \
	--target=x86_64-unknown-none-elf \
	-ffreestanding \
	-fno-pic \
	-fno-pie \
	-m64 \
	-mno-red-zone \
	-Wall \
	-Wextra \
	-Werror \
	-Ikernel/arch/x86_64/include \
	-Ikernel/include

CFLAGS       := $(COMMON_CFLAGS)
ASFLAGS      := $(COMMON_ASFLAGS)
BP_CFLAGS    := $(COMMON_CFLAGS) -DMCSOS_M4_TRIGGER_BREAKPOINT=1
PANIC_CFLAGS := $(COMMON_CFLAGS) -DMCSOS_M4_TRIGGER_PANIC=1

LDFLAGS := \
	-nostdlib \
	-static \
	-z max-page-size=0x1000 \
	-T linker.ld

# Sources & objects
SRC_C := $(shell find kernel -name '*.c' | LC_ALL=C sort)
SRC_S := $(shell find kernel -name '*.S' | LC_ALL=C sort)

OBJ       := $(patsubst %.c,$(BUILD_DIR)/normal/%.o,$(SRC_C)) \
             $(patsubst %.S,$(BUILD_DIR)/normal/%.o,$(SRC_S))

BP_OBJ    := $(patsubst %.c,$(BUILD_DIR)/breakpoint/%.o,$(SRC_C)) \
             $(patsubst %.S,$(BUILD_DIR)/breakpoint/%.o,$(SRC_S))

PANIC_OBJ := $(patsubst %.c,$(BUILD_DIR)/panic/%.o,$(SRC_C)) \
             $(patsubst %.S,$(BUILD_DIR)/panic/%.o,$(SRC_S))

# Phony targets
.PHONY: all build breakpoint panic inspect audit clean distclean grade check

all: build inspect

build:      $(KERNEL)
breakpoint: $(BP_KERNEL)
panic:      $(PANIC_KERNEL)

# Compile rules - normal
$(BUILD_DIR)/normal/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/%.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

# Compile rules - breakpoint
$(BUILD_DIR)/breakpoint/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(BP_CFLAGS) -c $< -o $@

$(BUILD_DIR)/breakpoint/%.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

# Compile rules - panic
$(BUILD_DIR)/panic/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(PANIC_CFLAGS) -c $< -o $@

$(BUILD_DIR)/panic/%.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

# Link
$(KERNEL): $(OBJ) linker.ld
	mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS) -Map=$(MAP) -o $@ $(OBJ)

$(BP_KERNEL): $(BP_OBJ) linker.ld
	mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS) -Map=$(BP_MAP) -o $@ $(BP_OBJ)

$(PANIC_KERNEL): $(PANIC_OBJ) linker.ld
	mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS) -Map=$(PANIC_MAP) -o $@ $(PANIC_OBJ)

# Inspect & audit
inspect: $(KERNEL)
	$(READELF) -h $(KERNEL) > $(BUILD_DIR)/readelf-header.txt
	$(READELF) -l $(KERNEL) > $(BUILD_DIR)/readelf-program-headers.txt
	$(READELF) -S $(KERNEL) > $(BUILD_DIR)/readelf-sections.txt
	nm -u $(KERNEL) > $(BUILD_DIR)/undefined.txt
	$(NM) -n $(KERNEL) > $(SYMS)
	$(OBJDUMP) -d -Mintel $(KERNEL) > $(DISASM)
	grep -q 'ELF64' $(BUILD_DIR)/readelf-header.txt
	grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64' $(BUILD_DIR)/readelf-header.txt
	grep -q 'kmain' $(SYMS)
	grep -q 'x86_64_idt_init' $(SYMS)
	grep -q 'x86_64_trap_dispatch' $(SYMS)
	grep -q 'iretq' $(DISASM)
	grep -q 'lidt' $(DISASM)

audit: inspect breakpoint panic
	! $(NM) -u $(KERNEL)       | grep .
	! $(NM) -u $(BP_KERNEL)    | grep .
	! $(NM) -u $(PANIC_KERNEL) | grep .
	grep -q 'isr_stub_14' $(SYMS)
	grep -q 'x86_64_exception_stubs' $(SYMS)
	$(READELF) -S $(KERNEL) | grep -q '\.text'
	$(READELF) -S $(KERNEL) | grep -q '\.rodata'

# Check (M7 host test)
check: all
	mkdir -p $(BUILD_DIR)
	clang -std=c17 -Wall -Wextra -Werror \
		-DMCSOS_HOST_TEST \
		-Ikernel/include \
		kernel/core/vmm.c \
		tests/test_vmm_host.c \
		-o $(BUILD_DIR)/test_vmm_host
	./$(BUILD_DIR)/test_vmm_host
	nm -u $(BUILD_DIR)/vmm.o 2>/dev/null || true
	clang -std=c17 -Wall -Wextra -Werror \
		-ffreestanding -fno-builtin -fno-stack-protector -mno-red-zone \
		-Ikernel/include \
		-c kernel/core/vmm.c -o $(BUILD_DIR)/vmm.o
	nm -u $(BUILD_DIR)/vmm.o
	objdump -dr $(BUILD_DIR)/vmm.o > $(BUILD_DIR)/vmm.objdump.txt
	grep -q 'invlpg' $(BUILD_DIR)/vmm.objdump.txt
	grep -q 'cr3' $(BUILD_DIR)/vmm.objdump.txt
	echo "[PASS] M7 check selesai"

# Clean
clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf iso_root limine evidence

grade: clean audit
# ==========================
# M8 Kernel Heap
# ==========================

m8-kmem-host-test:
	mkdir -p build/m8
	clang -std=c17 -Wall -Wextra -Werror \
		-DMCSOS_HOST_TEST \
		-Iinclude \
		tests/test_kmem.c \
		kernel/mm/kmem.c \
		-o build/m8/test_kmem
	./build/m8/test_kmem

m8-kmem-freestanding:
	mkdir -p build/m8
	clang -std=c17 -Wall -Wextra -Werror \
		-ffreestanding -fno-builtin \
		-Iinclude \
		-c kernel/mm/kmem.c \
		-o build/m8/kmem.o

m8-audit: m8-kmem-freestanding
	readelf -h build/m8/kmem.o > build/m8/readelf_h.txt
	readelf -S build/m8/kmem.o > build/m8/readelf_s.txt
	nm -u build/m8/kmem.o > build/m8/nm_u.txt
	objdump -dr build/m8/kmem.o > build/m8/kmem.objdump.txt

m8-all: m8-kmem-host-test m8-audit
	@echo "[PASS] M8 selesai"

CC := clang
LD := ld.lld
OBJDUMP ?= objdump
READELF ?= readelf
NM ?= nm
SHA256SUM ?= sha256sum

BUILD := build/m9
CFLAGS_HOST := -std=c17 -Wall -Wextra -Werror -DMCSOS_HOST_TEST -Iinclude
CFLAGS_KERNEL := -target x86_64-unknown-none-elf -std=c17 -ffreestanding -fno-stack-protector -fno-pic -mno-red-zone -Wall -Wextra -Werror -Iinclude
ASFLAGS_KERNEL := -target x86_64-unknown-none-elf -ffreestanding -fno-stack-protector -fno-pic -mno-red-zone

.PHONY: m9-all m9-host-test m9-freestanding m9-audit m9-clean

m9-all: m9-host-test m9-freestanding m9-audit

$(BUILD):
	mkdir -p $(BUILD)

m9-host-test: $(BUILD)
	$(CC) $(CFLAGS_HOST) tests/test_scheduler_host.c kernel/mcsos_thread.c -o $(BUILD)/m9_host_test
	$(BUILD)/m9_host_test | tee $(BUILD)/test_scheduler.log

m9-freestanding: $(BUILD)
	$(CC) $(CFLAGS_KERNEL) -c kernel/mcsos_thread.c -o $(BUILD)/mcsos_thread.freestanding.o
	$(CC) $(ASFLAGS_KERNEL) -c kernel/arch/x86_64/context_switch.S $(BUILD)/context_switch.o
	$(LD) -r $(BUILD)/mcsos_thread.freestanding.o $(BUILD)/context_switch.o -o $(BUILD)/m9_scheduler_combined.o

m9-audit: m9-freestanding
	$(NM) -u $(BUILD)/m9_scheduler_combined.o | tee $(BUILD)/nm_undefined.log
	$(READELF) -h $(BUILD)/m9_scheduler_combined.o | tee $(BUILD)/readelf_header.log
	$(OBJDUMP) -d $(BUILD)/m9_scheduler_combined.o | grep -E 'mcsos_context_switch|jmp|ret|hlt' | tee $(BUILD)/objdump_key.log
	$(SHA256SUM) $(BUILD)/m9_host_test $(BUILD)/m9_scheduler_combined.o | tee $(BUILD)/sha256.log

m9-clean:
	rm -rf $(BUILD)
