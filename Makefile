



SHELL := /usr/bin/env bash
.DEFAULT_GOAL := hel
.PHONY: help meta check proof qemu-probe repro test clean distclean

help:

	@echo "MCSOS M1 targets:"
	@echo " make meta - collect host and toolchain metadata"
	@echo " make check - verify required tools and repository path"
	@echo " make proof - build freestanding x86_64 ELF proof"
	@echo " make qemu-probe - verify QEMU machine and OVMF availability"
	@echo " make repro - run reproducibility check for proof artifact"
	@echo " make test - run all M1 checks"
	@echo " make clean - remove generated proof output"
	@echo " make distclean - remove all generated build output"

meta:
	@./tools/scripts/collect_meta.sh

check:
	@./tools/scripts/check_toolchain.sh

proof:
	@./tools/scripts/proof_compile.sh

qemu-probe:
	@./tools/scripts/qemu_probe.sh

repro:
	@./tools/scripts/repro_check.sh

test: meta check proof qemu-probe repro
	@echo "OK: M1 test suite passed"

clean:
	@rm -rf build/proof build/repro
	@echo "OK: cleaned proof and reproducibility outputs"

distclean:
	@rm -rf build
	@echo "OK: removed build directory"
inspect-proof:
	@echo "Inspecting proof artifacts..."
	@readelf -h build/proof/freestanding_probe.o
	@readelf -h build/proof/freestanding_probe.elf
	@objdump -d build/proof/freestanding_probe.elf | head

repro-check:
	@echo "Checking reproducibility artifacts..."
	@test -f build/repro/repro-status.txt && cat build/repro/repro-status.txt
	@test -f build/repro/sha256-diff.txt && cat build/repro/sha256-diff.txt
