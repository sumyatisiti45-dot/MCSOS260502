# Architecture Overview

## Target
- Architecture: x86_64
- Host OS: Windows 11 x64
- Environment: WSL 2
- Emulator: QEMU
- Firmware: OVMF

## Kernel Model
Educational monolithic kernel.

## Language
Freestanding C.

## Build System
clang + ld.lld + Makefile

## Non-goals
- userspace
- scheduler
- filesystem
- networking
- GUI

