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
BUILD_M10 := build/m10

.PHONY: m10-all m10-host-test m10-freestanding m10-audit

m10-all: m10-host-test m10-freestanding m10-audit

$(BUILD_M10):
	mkdir -p $(BUILD_M10)

m10-host-test: $(BUILD_M10)
	$(CC) -std=c17 -Wall -Wextra -Werror -DMCSOS_HOST_TEST -Iinclude \
	tests/test_syscall_host.c \
	kernel/syscall/syscall.c \
	-o $(BUILD_M10)/m10_host_test
	$(BUILD_M10)/m10_host_test | tee $(BUILD_M10)/test_syscall.log

m10-freestanding: $(BUILD_M10)
	$(CC) -target x86_64-unknown-none-elf -std=c17 -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-Wall -Wextra -Werror -Iinclude \
	-c kernel/syscall/syscall.c \
	-o $(BUILD_M10)/syscall.o
	$(CC) -target x86_64-unknown-none-elf -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-c kernel/syscall/syscall_entry.S \
	-o $(BUILD_M10)/syscall_entry.o
	$(LD) -r $(BUILD_M10)/syscall.o $(BUILD_M10)/syscall_entry.o \
	-o $(BUILD_M10)/m10_syscall_combined.o

m10-audit: m10-freestanding
	$(NM) -u $(BUILD_M10)/m10_syscall_combined.o | tee $(BUILD_M10)/nm_undefined.log
	$(READELF) -h $(BUILD_M10)/m10_syscall_combined.o | tee $(BUILD_M10)/readelf_header.log
	$(OBJDUMP) -d $(BUILD_M10)/m10_syscall_combined.o | tee $(BUILD_M10)/objdump.log
	$(SHA256SUM) $(BUILD_M10)/m10_host_test $(BUILD_M10)/m10_syscall_combined.o | tee $(BUILD_M10)/sha256.log

BUILD_M11 := build/m11

.PHONY: m11-all m11-host-test m11-freestanding m11-audit

m11-all: m11-host-test m11-freestanding m11-audit

$(BUILD_M11):
	mkdir -p $(BUILD_M11)

m11-host-test: $(BUILD_M11)
	$(CC) -std=c17 -Wall -Wextra -Werror -DMCSOS_HOST_TEST -Iinclude \
	tests/m11/m11_host_test.c \
	kernel/user/m11_elf_loader.c \
	-o $(BUILD_M11)/m11_host_test
	$(BUILD_M11)/m11_host_test | tee $(BUILD_M11)/test_m11.log

m11-freestanding: $(BUILD_M11)
	$(CC) -target x86_64-unknown-none-elf -std=c17 -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-Wall -Wextra -Werror -Iinclude \
	-c kernel/user/m11_elf_loader.c \
	-o $(BUILD_M11)/m11_elf_loader.o

m11-audit: m11-freestanding
	$(NM) -u $(BUILD_M11)/m11_elf_loader.o | tee $(BUILD_M11)/nm_undefined.log
	$(READELF) -h $(BUILD_M11)/m11_elf_loader.o | tee $(BUILD_M11)/readelf_header.log
	$(OBJDUMP) -d $(BUILD_M11)/m11_elf_loader.o | tee $(BUILD_M11)/objdump.log
	$(SHA256SUM) $(BUILD_M11)/m11_host_test $(BUILD_M11)/m11_elf_loader.o | tee $(BUILD_M11)/sha256.log
BUILD_M12 := build/m12

.PHONY: m12-all m12-host-test m12-freestanding m12-audit

m12-all: m12-host-test m12-freestanding m12-audit

$(BUILD_M12):
	mkdir -p $(BUILD_M12)

m12-host-test: $(BUILD_M12)
	$(CC) -std=c17 -Wall -Wextra -Werror -DMCSOS_HOST_TEST -Iinclude \
	tests/m12_sync_host_test.c \
	kernel/sync/lockdep.c \
	kernel/sync/spinlock.c \
	kernel/sync/mutex.c \
	-o $(BUILD_M12)/m12_host_test
	$(BUILD_M12)/m12_host_test | tee $(BUILD_M12)/test_m12.log

m12-freestanding: $(BUILD_M12)
	$(CC) -target x86_64-unknown-none-elf -std=c17 -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-Wall -Wextra -Werror -Iinclude \
	-c kernel/sync/lockdep.c \
	-o $(BUILD_M12)/lockdep.o

	$(CC) -target x86_64-unknown-none-elf -std=c17 -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-Wall -Wextra -Werror -Iinclude \
	-c kernel/sync/spinlock.c \
	-o $(BUILD_M12)/spinlock.o

	$(CC) -target x86_64-unknown-none-elf -std=c17 -ffreestanding \
	-fno-stack-protector -fno-pic -mno-red-zone \
	-Wall -Wextra -Werror -Iinclude \
	-c kernel/sync/mutex.c \
	-o $(BUILD_M12)/mutex.o

	$(LD) -r \
	$(BUILD_M12)/lockdep.o \
	$(BUILD_M12)/spinlock.o \
	$(BUILD_M12)/mutex.o \
	-o $(BUILD_M12)/m12_sync_combined.o

m12-audit: m12-freestanding
	$(NM) -u $(BUILD_M12)/m12_sync_combined.o | tee $(BUILD_M12)/nm_undefined.log
	$(READELF) -h $(BUILD_M12)/m12_sync_combined.o | tee $(BUILD_M12)/readelf_header.log
	$(OBJDUMP) -d $(BUILD_M12)/m12_sync_combined.o | tee $(BUILD_M12)/objdump.log
	$(SHA256SUM) \
	$(BUILD_M12)/m12_host_test \
	$(BUILD_M12)/m12_sync_combined.o | tee $(BUILD_M12)/sha256.log

CC ?= cc
CLANG ?= clang
OBJDUMP ?= objdump
READELF ?= readelf
NM ?= nm
LD ?= ld
SHA256SUM ?= sha256sum

BUILD := build/m13
INCLUDES := -Iinclude
HOST_CFLAGS := -std=c17 -Wall -Wextra -Werror -O2 $(INCLUDES)
FREESTANDING_CFLAGS := -target x86_64-elf -std=c17 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -mno-red-zone -Wall -Wextra -Werror -O2 $(INCLUDES)
VFS_SRCS := kernel/vfs/ramfs.c kernel/vfs/fd.c kernel/vfs/sys_vfs.c

.PHONY: m13-all m13-host-test m13-objects m13-audit clean

m13-all: m13-host-test m13-objects m13-audit

m13-host-test: $(BUILD)/m13_vfs_host_test
	./$(BUILD)/m13_vfs_host_test | tee $(BUILD)/host-test.log

$(BUILD)/m13_vfs_host_test: tests/m13_vfs_host_test.c $(VFS_SRCS) include/mcs_vfs.h
	mkdir -p $(BUILD)
	$(CC) $(HOST_CFLAGS) tests/m13_vfs_host_test.c $(VFS_SRCS) -o $@

m13-objects: $(BUILD)/ramfs.o $(BUILD)/fd.o $(BUILD)/sys_vfs.o

$(BUILD)/ramfs.o: kernel/vfs/ramfs.c include/mcs_vfs.h
	mkdir -p $(BUILD)
	$(CLANG) $(FREESTANDING_CFLAGS) -c $< -o $@

$(BUILD)/fd.o: kernel/vfs/fd.c include/mcs_vfs.h
	mkdir -p $(BUILD)
	$(CLANG) $(FREESTANDING_CFLAGS) -c $< -o $@

$(BUILD)/sys_vfs.o: kernel/vfs/sys_vfs.c include/mcs_vfs.h
	mkdir -p $(BUILD)
	$(CLANG) $(FREESTANDING_CFLAGS) -c $< -o $@

m13-audit: m13-objects
	$(LD) -r -m elf_x86_64 $(BUILD)/ramfs.o $(BUILD)/fd.o $(BUILD)/sys_vfs.o -o $(BUILD)/vfs.o
	$(NM) -u $(BUILD)/vfs.o > $(BUILD)/nm-undefined.txt
	$(READELF) -h $(BUILD)/vfs.o > $(BUILD)/readelf-vfs.txt
	$(OBJDUMP) -dr $(BUILD)/vfs.o > $(BUILD)/objdump-vfs.txt
	$(SHA256SUM) $(BUILD)/ramfs.o $(BUILD)/fd.o $(BUILD)/sys_vfs.o $(BUILD)/vfs.o $(BUILD)/m13_vfs_host_test > $(BUILD)/sha256sums.txt
	test ! -s $(BUILD)/nm-undefined.txt

clean:
	rm -rf $(BUILD)

CC ?= cc
CLANG ?= clang
CFLAGS_HOST := -std=c17 -Wall -Wextra -Werror -Iinclude -O2
CFLAGS_FREESTANDING := --target=x86_64-elf -std=c17 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -mno-red-zone -Wall -Wextra -Werror -Iinclude -O2 -c
SRC := kernel/block/block.c kernel/block/ramblk.c kernel/block/bcache.c
OBJ := build/block.o build/ramblk.o build/bcache.o

.PHONY: m14-all m14-host-test m14-freestanding m14-audit
m14-all: m14-host-test m14-freestanding m14-audit

m14-host-test: build/test_m14_block
	./build/test_m14_block

build/test_m14_block: tests/host/test_m14_block.c $(SRC) include/mcsos/block.h
	mkdir -p build
	$(CC) $(CFLAGS_HOST) tests/host/test_m14_block.c $(SRC) -o $@

m14-freestanding: $(OBJ)

build/%.o: kernel/block/%.c include/mcsos/block.h
	mkdir -p build
	$(CLANG) $(CFLAGS_FREESTANDING) $< -o $@

m14-audit: m14-freestanding
	ld -r -o build/m14_block_layer.o $(OBJ)
	nm -u build/m14_block_layer.o > artifacts/m14_nm_undefined.txt
	readelf -h build/m14_block_layer.o > artifacts/m14_readelf_block.txt
	objdump -dr build/m14_block_layer.o > artifacts/m14_objdump_block.txt
	sha256sum $(OBJ) build/m14_block_layer.o build/test_m14_block > artifacts/m14_sha256.txt
	test ! -s artifacts/m14_nm_undefined.txt


